import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:vibe_swipe/src/core/services/local_db_service/secure_storage.dart';

import '../utils/app_exports.dart';

class AuthHandler {
  AuthHandler._instance();
  static final AuthHandler ref = AuthHandler._instance();

  User? user;
  String? acessToken;
  String? onBoardToken;
  String? onBoadEmail;
  bool didLogOut = false;

  Prefs prefs = locator<Prefs>();
  FirebaseAuthService get _authService => locator<FirebaseAuthService>();

  bool get isLoggedIn => _authService.currentUser != null;

  fb.User? get firebaseUser => _authService.currentUser;

  Future<void> setupUser(fb.User? fbUser, bool isRemember) async {
    if (fbUser != null) {
      user = User(
        id: fbUser.uid,
        name: fbUser.displayName ?? '',
        email: fbUser.email ?? '',
      );
      if (isRemember) {
        await prefs.storeUser(user);
      }
    }
    didLogOut = false;
  }

  Future<void> storeToken(String? acessToken, bool isRemember) async {
    this.acessToken = acessToken;
    if (isRemember) {
      await prefs.storeToken(acessToken);
    }
  }

  Future<void> init() async {
    try {
      didLogOut = false;
      final fbUser = _authService.currentUser;
      if (fbUser != null) {
        user = User(
          id: fbUser.uid,
          name: fbUser.displayName ?? '',
          email: fbUser.email ?? '',
        );
        acessToken = await fbUser.getIdToken();
      } else {
        user = await prefs.fetchUser().catchError((_) => null);
        acessToken = await prefs.fetchToken().catchError((_) => null);
      }

      appPrint('[User]: $user');
      appPrint('[AccessToken]: $acessToken');
    } catch (e) {
      appPrint(e);
    }
  }

  void resetAuth() {
    didLogOut = false;
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      await prefs.deleteUser();
      await prefs.deleteToken();
      user = null;
      acessToken = null;
      didLogOut = true;
    } catch (e) {
      appPrint(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      final fbUser = _authService.currentUser;
      if (fbUser != null) {
        await fbUser.delete().catchError((e) {
          appPrint('Firebase account deletion error: $e');
        });
      }
      await logout();
    } catch (e) {
      appPrint(e);
      await logout();
    }
  }
}
