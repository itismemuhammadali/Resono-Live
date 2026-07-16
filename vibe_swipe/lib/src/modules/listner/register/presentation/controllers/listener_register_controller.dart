import 'package:vibe_swipe/src/core/utils/app_exports.dart';

final listenerRegisterControllerProvider =
    ChangeNotifierProvider<ListenerRegisterController>((ref) {
      return ListenerRegisterController();
    });

class ListenerRegisterController extends ChangeNotifier with Buffers {
  // Profile setup
  String _username = '';
  Uint8List? _profileImageBytes;

  String get username => _username;
  Uint8List? get profileImageBytes => _profileImageBytes;

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setProfileImage(Uint8List bytes) {
    _profileImageBytes = bytes;
    notifyListeners();
  }

  // Genres
  final List<String> genres = [
    'Pop',
    'Rock',
    'Hip Hop',
    'Electronic',
    'Jazz',
    'Classical',
    'R&B',
    'Country',
    'Blues',
    'Reggae',
    'Metal',
    'Folk',
    'Indie',
    'Soul',
    'Funk',
    'Latin',
    'Afrobeat',
    'K-Pop',
    'DJ',
    'Religious',
  ];

  final Set<String> _favoriteGenres = {};
  final Set<String> _dislikedGenres = {};

  Set<String> get favoriteGenres => Set.unmodifiable(_favoriteGenres);
  Set<String> get dislikedGenres => Set.unmodifiable(_dislikedGenres);

  void toggleFavorite(String genre) {
    if (_favoriteGenres.contains(genre)) {
      _favoriteGenres.remove(genre);
    } else {
      _favoriteGenres.add(genre);
      _dislikedGenres.remove(genre);
    }
    notifyListeners();
  }

  void toggleDisliked(String genre) {
    if (_dislikedGenres.contains(genre)) {
      _dislikedGenres.remove(genre);
    } else {
      _dislikedGenres.add(genre);
      _favoriteGenres.remove(genre);
    }
    notifyListeners();
  }

  void reset() {
    _username = '';
    _profileImageBytes = null;
    _favoriteGenres.clear();
    _dislikedGenres.clear();
    notifyListeners();
  }
}
