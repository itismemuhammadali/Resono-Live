import 'dart:async';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/search_artist_entity.dart';

final listenerSearchControllerProvider =
    ChangeNotifierProvider.autoDispose<ListenerSearchController>(
      (ref) => ListenerSearchController(),
    );

class ListenerSearchController extends ChangeNotifier with Buffers {
  final TextEditingController searchTextController = TextEditingController();
  Timer? _debounce;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedGenre = '';
  String get selectedGenre => _selectedGenre;

  List<String> recentSearches = [];
  List<String> trendingGenres = [];
  List<SearchArtistEntity> trendingArtists = [];
  List<SearchArtistEntity> searchResults = [];

  bool _hasSearched = false;
  bool get hasSearched => _hasSearched;

  ListenerSearchController() {
    _loadInitialData();
    searchTextController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchTextController.removeListener(_onSearchChanged);
    searchTextController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(searchTextController.text.trim());
    });
  }

  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        locator<FirestoreService>().getTrendingGenres(limit: 10),
        locator<FirestoreService>().getTrendingArtists(limit: 10),
      ]);

      final genresData = results[0];
      trendingGenres = genresData
          .map((g) => (g['genre'] ?? '').toString())
          .where((g) => g.isNotEmpty)
          .toList();

      final artistsData = results[1];
      trendingArtists = artistsData
          .map((a) => SearchArtistEntity.fromMap(a))
          .where((a) => a.name.isNotEmpty)
          .toList();

      await _loadRecentSearches();
    } catch (e) {
      appPrint('[Search] Error loading initial data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = locator<Prefs>();
      final stored = await prefs.readList('recent_searches');
      recentSearches = (stored ?? []).take(10).toList();
    } catch (e) {
      recentSearches = [];
    }
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.isEmpty) return;
    recentSearches.remove(query);
    recentSearches.insert(0, query);
    if (recentSearches.length > 10) {
      recentSearches = recentSearches.sublist(0, 10);
    }
    try {
      final prefs = locator<Prefs>();
      await prefs.storeList('recent_searches', recentSearches);
    } catch (e) {
      appPrint('[Search] Error saving recent search: $e');
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty && _selectedGenre.isEmpty) {
      _hasSearched = false;
      searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _hasSearched = true;
    notifyListeners();

    try {
      final data = await locator<FirestoreService>().searchUsers(
        q: query.isNotEmpty ? query : null,
        genre: _selectedGenre.isNotEmpty ? _selectedGenre : null,
        limit: 20,
      );

      searchResults = data
          .map((u) => SearchArtistEntity.fromMap(u))
          .where((a) => a.name.isNotEmpty)
          .toList();

      if (query.isNotEmpty) {
        await _saveRecentSearch(query);
      }
    } catch (e) {
      appPrint('[Search] Error searching: $e');
      searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void onGenreSelected(String genre) {
    if (_selectedGenre == genre) {
      _selectedGenre = '';
    } else {
      _selectedGenre = genre;
    }
    _performSearch(searchTextController.text.trim());
  }

  void onRecentSearchTap(String query) {
    searchTextController.text = query;
  }

  void clearSearch() {
    searchTextController.clear();
    _selectedGenre = '';
    _hasSearched = false;
    searchResults = [];
    notifyListeners();
  }
}
