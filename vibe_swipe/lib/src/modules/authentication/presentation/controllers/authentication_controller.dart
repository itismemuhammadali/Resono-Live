import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
      "title": "Share Your Sound & Go Live",
      "subtitle": "Upload your music, host live performances, and let the world discover your unique style.",
      "image": "assets/images/png/share_your_sound.png",
      "feature": "LIVE STREAMING",
    },
    {
      "title": "Reach Real Listeners",
      "subtitle": "Connect with fans who actually vibe with your music through our swipe discovery.",
      "image": "assets/images/png/reach_real_listeners.png",
      "feature": "MUSIC DISCOVERY",
    },
    {
      "title": "Community & Super Chat",
      "subtitle": "Interact directly with your fans, build your community, and earn with Super Chat.",
      "image": "assets/images/png/track_your_growth.png",
      "feature": "SUPER CHAT",
    },
  ];

  static const List<Map<String, String>> _listenerOnboarding = [
    {
      "title": "Live Stream & Performances",
      "subtitle":
          "Watch real-time artist broadcasts, live video sessions,\nand exclusive stage performances.",
      "image": "assets/images/png/discover_music_instantly.png",
      "feature": "LIVE STREAMING",
    },
    {
      "title": "Swipe & Discover Music",
      "subtitle":
          "Preview fresh tracks with a simple swipe. Like\nwhat you hear and curate your personalized vibe.",
      "image": "assets/images/png/swipe_listen_decide.png",
      "feature": "MUSIC DISCOVERY",
    },
    {
      "title": "Community & Super Chat",
      "subtitle":
          "Join genre discussions, interact with top artists,\nand support creators with Super Chat.",
      "image": "assets/images/png/your_taste_your_feed.png",
      "feature": "SUPER CHAT",
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

      try {
        await _authService.updateDisplayName(name).timeout(const Duration(seconds: 5));
      } catch (e) {
        appPrint('[Auth] Note: updateDisplayName skipped/timed out: $e');
      }

      try {
        await _firestoreService.createUserData(
          uid: uid,
          name: name,
          email: email,
          role: AppConfig.userRole,
        );
      } catch (e) {
        appPrint('[Auth] Note: createUserData skipped/error: $e');
      }

      try {
        await _authService.sendEmailVerification();
      } catch (e) {
        appPrint('[Auth] Note: sendEmailVerification skipped/error: $e');
      }

      try {
        await _authHandler.setupUser(credential.user, true);
        final token = await credential.user!.getIdToken().timeout(const Duration(seconds: 5));
        await _authHandler.storeToken(token, true);
      } catch (e) {
        appPrint('[Auth] Note: setupUser/storeToken error: $e');
      }

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

  Future<bool> resendVerificationEmail() async {
    try {
      await _authService.sendEmailVerification();
      return true;
    } catch (e) {
      appPrint('[Auth] Error resending verification email: $e');
      return false;
    }
  }

  Future<bool> checkEmailVerified() async {
    try {
      await _authService.reloadUser();
      return _authService.isEmailVerified;
    } catch (e) {
      appPrint('[Auth] Error reloading user status: $e');
      return false;
    }
  }

  bool get isEmailVerified => _authService.isEmailVerified;

  Future<void> cancelPendingSignUp() async {
    _setError(null);
    try {
      final user = _authService.currentUser;
      if (user != null && !user.emailVerified) {
        final uid = user.uid;
        await _firestoreService.deleteUserData(uid);
        try {
          await user.delete().timeout(const Duration(seconds: 4));
        } catch (e) {
          appPrint('[Auth] Note: user.delete skipped/error: $e');
        }
        if (_authService.currentUser == null || _authService.currentUser?.uid == uid) {
          await _authHandler.logout();
        }
      }
    } catch (e) {
      appPrint('[Auth] Error in cancelPendingSignUp: $e');
    }
  }

  Future<void> cancelPendingLogin() async {
    _setError(null);
    try {
      await _authHandler.logout();
    } catch (e) {
      appPrint('[Auth] Error in cancelPendingLogin: $e');
    }
  }

  void _syncUserRole(String? roleStr) {
    if (roleStr == null || roleStr.isEmpty) return;
    final normalized = roleStr.toLowerCase().trim();
    if (normalized == 'artist') {
      AppConfig.userRole = UserRole.artist;
    } else if (normalized == 'listener') {
      AppConfig.userRole = UserRole.listener;
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
      _syncUserRole(roleStr);

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
      _syncUserRole(roleStr);

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

  Future<bool> isProfileCompleted(String uid) async {
    try {
      final data = await _firestoreService.getUserData(uid);
      if (data == null) return false;
      if (data['profileCompleted'] == true) return true;
      if (AppConfig.userRole == UserRole.artist) {
        final artistName = data['artistName'] as String?;
        final genres = data['genres'];
        return artistName != null && artistName.isNotEmpty && genres is List && genres.isNotEmpty;
      } else {
        final username = data['username'] as String?;
        final fav = data['favoriteGenres'];
        return username != null && username.isNotEmpty && fav is List && fav.isNotEmpty;
      }
    } catch (e) {
      appPrint('[Auth] Error checking profile completion: $e');
      return false;
    }
  }

  Future<bool> signInWithGoogle({bool isSignUp = false}) async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _authService.signInWithGoogle();
      final uid = credential.user!.uid;

      final roleStr = await _firestoreService.getUserRole(uid);
      if (!isSignUp) {
        _syncUserRole(roleStr);
      }

      final googleName = credential.user!.displayName;
      final resolvedName = (googleName != null && googleName.trim().isNotEmpty)
          ? googleName.trim()
          : (credential.user!.email != null && credential.user!.email!.isNotEmpty
              ? credential.user!.email!.split('@').first
              : (AppConfig.userRole == UserRole.artist ? 'Artist' : 'Music Lover'));

      if (roleStr == null || isSignUp) {
        await _firestoreService.createUserData(
          uid: uid,
          name: resolvedName,
          email: credential.user!.email ?? '',
          role: AppConfig.userRole,
          profileImageUrl: credential.user!.photoURL,
        );
      }

      await _authHandler.setupUser(credential.user, true);
      final token = await credential.user!.getIdToken();
      await _authHandler.storeToken(token, true);

      _setLoading(false);
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'ERROR_ABORTED_BY_USER') return false;
      _setError(_mapAuthError(e.code));
      return false;
    } catch (e) {
      appPrint('[Auth] Google Sign-In error: $e');
      _setLoading(false);
      _setError('Google sign in failed. Please try again.');
      return false;
    }
  }

  Future<bool> signInWithApple({bool isSignUp = false}) async {
    _setLoading(true);
    _setError(null);
    try {
      final credential = await _authService.signInWithApple();
      final uid = credential.user!.uid;

      final roleStr = await _firestoreService.getUserRole(uid);
      if (!isSignUp) {
        _syncUserRole(roleStr);
      }

      final appleName = _authService.lastAppleFullName;
      final existingName = credential.user!.displayName;
      final resolvedName = (appleName != null && appleName.trim().isNotEmpty)
          ? appleName.trim()
          : (existingName != null && existingName.trim().isNotEmpty)
              ? existingName.trim()
              : (credential.user!.email != null && credential.user!.email!.isNotEmpty
                  ? credential.user!.email!.split('@').first
                  : (AppConfig.userRole == UserRole.artist ? 'Artist' : 'Music Lover'));

      if (roleStr == null || isSignUp) {
        await _firestoreService.createUserData(
          uid: uid,
          name: resolvedName,
          email: credential.user!.email ?? '',
          role: AppConfig.userRole,
          profileImageUrl: credential.user!.photoURL,
        );
      } else if (resolvedName != 'Artist' && resolvedName != 'Music Lover') {
        await _firestoreService.updateUserData(uid, {'name': resolvedName});
      }

      await _authHandler.setupUser(credential.user, true);
      final token = await credential.user!.getIdToken();
      await _authHandler.storeToken(token, true);

      _setLoading(false);
      return true;
    } on SignInWithAppleAuthorizationException catch (e) {
      _setLoading(false);
      if (e.code == AuthorizationErrorCode.canceled) {
        appPrint('[Auth] Apple Sign-In cancelled by user');
        return false;
      }
      appPrint('[Auth] Apple Sign-In authorization error: ${e.code} - ${e.message}');
      _setError('Apple Sign-In could not be completed. Please try again.');
      return false;
    } on fb.FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'ERROR_ABORTED_BY_USER') return false;
      _setError(_mapAuthError(e.code));
      return false;
    } catch (e) {
      appPrint('[Auth] Apple Sign-In error: $e');
      _setLoading(false);
      final err = e.toString().toLowerCase();
      if (err.contains('canceled') || err.contains('cancelled') || err.contains('1001')) {
        return false;
      }
      if (!kIsWeb && Platform.isAndroid) {
        _setError('Apple Sign-In is not supported on this device.');
      } else {
        _setError('Apple Sign-In failed. Please try again.');
      }
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
