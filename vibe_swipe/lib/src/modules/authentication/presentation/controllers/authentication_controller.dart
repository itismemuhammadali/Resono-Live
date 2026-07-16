import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/main.dart' show deepLinkService;

final authControllerProvider =
    ChangeNotifierProvider.autoDispose<AuthController>((ref) {
  return AuthController();
});

class AuthController extends ChangeNotifier with Buffers {
  int _currentPage = 0;
  bool _isLoading = false;
  String? _errorMessage;

  int get currentPage => _currentPage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FirebaseAuthService get _authService => locator<FirebaseAuthService>();
  FirestoreService get _firestoreService => locator<FirestoreService>();
  AuthHandler get _authHandler => AuthHandler.ref;

  static const List<Map<String, String>> _artistOnboarding = [
    {
      "title": "Share Your Sound",
      "subtitle": "Upload your music and let the world discover your unique style.",
      "image": "assets/images/png/share_your_sound.png",
    },
    {
      "title": "Reach Real Listeners",
      "subtitle": "Connect with fans who actually vibe with your music.",
      "image": "assets/images/png/reach_real_listeners.png",
    },
    {
      "title": "Track Your Growth",
      "subtitle": "See how your music performs and grow your audience smarter.",
      "image": "assets/images/png/track_your_growth.png",
    },
  ];

  static const List<Map<String, String>> _listenerOnboarding = [
    {
      "title": "Discover Music Instantly",
      "subtitle":
          "Explore new tracks in seconds with short previews\ntailored just for you.",
      "image": "assets/images/png/discover_music_instantly.png",
    },
    {
      "title": "Swipe. Listen. Decide.",
      "subtitle":
          "Quickly react to songs with a simple swipe and shape\nyour personal music feed.",
      "image": "assets/images/png/swipe_listen_decide.png",
    },
    {
      "title": "Your Taste, Your Feed",
      "subtitle":
          "Every tap improves your experience. Get music\nrecommendations that match your vibe.",
      "image": "assets/images/png/your_taste_your_feed.png",
    },
  ];

  List<Map<String, String>> get onboardingData =>
      AppConfig.userRole == UserRole.artist
          ? _artistOnboarding
          : _listenerOnboarding;

  void setPage(int page) {
    if (_currentPage != page) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      await _authService.updateDisplayName(name);

      await _firestoreService.createUserData(
        uid: uid,
        name: name,
        email: email,
        role: AppConfig.userRole,
      );

      await _authHandler.setupUser(credential.user, true);
      final token = await credential.user!.getIdToken();
      await _authHandler.storeToken(token, true);

      _setLoading(false);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_mapAuthError(e.code));
      return false;
    } catch (e) {
      appPrint('[Auth] Unexpected error: $e');
      _setLoading(false);
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final roleStr = await _firestoreService.getUserRole(uid);
      if (roleStr != null) {
        AppConfig.userRole = roleStr == 'artist' ? UserRole.artist : UserRole.listener;
      }

      await _authHandler.setupUser(credential.user, true);
      final token = await credential.user!.getIdToken();
      await _authHandler.storeToken(token, true);

      _setLoading(false);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_mapAuthError(e.code));
      return false;
    } catch (e) {
      appPrint('[Auth] Sign in unexpected error: $e');
      _setLoading(false);
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
    } on fb.FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_mapAuthError(e.code));
    } catch (e) {
      _setLoading(false);
      _setError('Failed to send reset email.');
    }
  }

  Future<bool> sendMagicLink(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.sendSignInLinkToEmail(email);
      await deepLinkService.storePendingEmail(email);
      _setLoading(false);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_mapAuthError(e.code));
      return false;
    } catch (e) {
      appPrint('[Auth] Magic link error: $e');
      _setLoading(false);
      _setError('Failed to send magic link. Please try again.');
      return false;
    }
  }

  Future<bool> completeMagicLinkSignIn(String email, String link) async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _authService.signInWithEmailLink(
        email: email,
        link: link,
      );

      final uid = credential.user!.uid;
      final roleStr = await _firestoreService.getUserRole(uid);
      if (roleStr != null) {
        AppConfig.userRole = roleStr == 'artist' ? UserRole.artist : UserRole.listener;
      }

      await _authHandler.setupUser(credential.user, true);
      final token = await credential.user!.getIdToken();
      await _authHandler.storeToken(token, true);

      _setLoading(false);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_mapAuthError(e.code));
      return false;
    } catch (e) {
      appPrint('[Auth] Magic link sign-in error: $e');
      _setLoading(false);
      _setError('Magic link sign-in failed. Please try again.');
      return false;
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
