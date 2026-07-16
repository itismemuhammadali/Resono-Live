import 'dart:typed_data';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';

final artistRegisterControllerProvider =
    ChangeNotifierProvider<ArtistRegisterController>((ref) {
      return ArtistRegisterController();
    });

class ArtistRegisterController extends ChangeNotifier with Buffers {
  // Artist setup
  String _artistName = '';
  String _bio = '';
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  XFile? _pickedBannerImage;
  Uint8List? _pickedBannerImageBytes;
  String _spotifyUrl = '';
  String _youtubeUrl = '';
  String _instagramUrl = '';
  bool _isPublicProfile = true;

  String get artistName => _artistName;
  String get bio => _bio;
  XFile? get pickedImage => _pickedImage;
  Uint8List? get pickedImageBytes => _pickedImageBytes;
  XFile? get pickedBannerImage => _pickedBannerImage;
  Uint8List? get pickedBannerImageBytes => _pickedBannerImageBytes;
  String get spotifyUrl => _spotifyUrl;
  String get youtubeUrl => _youtubeUrl;
  String get instagramUrl => _instagramUrl;
  bool get isPublicProfile => _isPublicProfile;

  void setArtistName(String value) {
    _artistName = value;
    notifyListeners();
  }

  void setBio(String value) {
    _bio = value;
    notifyListeners();
  }

  Future<void> setProfileImage(XFile file) async {
    _pickedImage = file;
    _pickedImageBytes = await file.readAsBytes();
    notifyListeners();
  }

  Future<void> setBannerImage(XFile file) async {
    _pickedBannerImage = file;
    _pickedBannerImageBytes = await file.readAsBytes();
    notifyListeners();
  }

  void setSpotifyUrl(String value) {
    _spotifyUrl = value;
    notifyListeners();
  }

  void setYoutubeUrl(String value) {
    _youtubeUrl = value;
    notifyListeners();
  }

  void setInstagramUrl(String value) {
    _instagramUrl = value;
    notifyListeners();
  }

  void togglePublicProfile(bool value) {
    _isPublicProfile = value;
    notifyListeners();
  }

  // Genres
  final List<String> genres = [
    'Pop',
    'Rock',
    'Hip Hop',
    'Electronic',
    'R&B',
    'Jazz',
    'Country',
    'Classical',
    'Indie',
    'Metal',
    'DJ',
    'Religious',
  ];

  final Set<String> _selectedGenres = {};

  Set<String> get selectedGenres => Set.unmodifiable(_selectedGenres);

  void toggleGenre(String genre) {
    if (_selectedGenres.contains(genre)) {
      _selectedGenres.remove(genre);
    } else {
      _selectedGenres.add(genre);
    }
    notifyListeners();
  }

  void reset() {
    _artistName = '';
    _bio = '';
    _pickedImage = null;
    _pickedImageBytes = null;
    _pickedBannerImage = null;
    _pickedBannerImageBytes = null;
    _spotifyUrl = '';
    _youtubeUrl = '';
    _instagramUrl = '';
    _isPublicProfile = true;
    _selectedGenres.clear();
    notifyListeners();
  }
}
