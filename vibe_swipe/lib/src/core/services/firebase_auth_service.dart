import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_logger.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  static const _androidPackageName = 'com.sliconsystems.vibe_swipe';
  static const _iosBundleId = 'com.sliconsystems.vibe_swipe';
  static const _linkDomain = 'vibeswipe.page.link';

  Future<void> sendSignInLinkToEmail(String email) async {
    final actionCodeSettings = ActionCodeSettings(
      url: 'https://$_linkDomain/finishSignIn?email=$email',
      handleCodeInApp: true,
      androidPackageName: _androidPackageName,
      androidMinimumVersion: '21',
      androidInstallApp: true,
      iOSBundleId: _iosBundleId,
    );
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
    appPrint('[FirebaseAuth] Magic link sent to $email');
  }

  bool isSignInWithEmailLink(String link) {
    return _auth.isSignInWithEmailLink(link);
  }

  Future<UserCredential> signInWithEmailLink({
    required String email,
    required String link,
  }) async {
    try {
      final credential = await _auth.signInWithEmailLink(
        email: email,
        emailLink: link,
      );
      appPrint('[FirebaseAuth] Magic link sign-in success: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      appPrint('[FirebaseAuth] Magic link sign-in error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      appPrint('[FirebaseAuth] Sign up success: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      appPrint('[FirebaseAuth] Sign up error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      appPrint('[FirebaseAuth] Sign in success: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      appPrint('[FirebaseAuth] Sign in error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    appPrint('[FirebaseAuth] Signed out');
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
    appPrint('[FirebaseAuth] Password reset email sent to $email');
  }

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  String? getUid() => _auth.currentUser?.uid;
}
