import 'dart:convert' show utf8;
import 'dart:io' show Platform;
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../utils/app_logger.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: (!kIsWeb && Platform.isIOS)
        ? '367306858996-oepl42avutap73h38qejqco3klqo40vp.apps.googleusercontent.com'
        : null,
    serverClientId: (!kIsWeb && !Platform.isIOS)
        ? '367306858996-l8k5q7fsg6g8f0honpm1od0gocshpd8d.apps.googleusercontent.com'
        : null,
  );

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  static const _androidPackageName = 'com.vibeswipellc.vibeswipe';
  static const _iosBundleId = 'com.vibeswipellc.vibeswipe';
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
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    appPrint('[FirebaseAuth] Signed out');
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
    appPrint('[FirebaseAuth] Password reset email sent to $email');
  }

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      appPrint('[FirebaseAuth] Google Sign-In success: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      appPrint('[FirebaseAuth] Google Sign-In error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      appPrint('[FirebaseAuth] Google Sign-In unexpected error: $e');
      rethrow;
    }
  }

  String? _lastAppleFullName;
  String? get lastAppleFullName => _lastAppleFullName;

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      WebAuthenticationOptions? webOptions;
      if (!kIsWeb && Platform.isAndroid) {
        webOptions = WebAuthenticationOptions(
          clientId: 'com.vibeswipellc.vibeswipe.service',
          redirectUri: Uri.parse(
            'https://vibe-swipe-llc.firebaseapp.com/__/auth/handler',
          ),
        );
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        webAuthenticationOptions: webOptions,
      );

      final idToken = appleCredential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Apple Sign-In failed to return an identity token.',
        );
      }

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: idToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Extract name provided by Apple (Apple only provides this on the first authorization)
      final givenName = appleCredential.givenName ?? '';
      final familyName = appleCredential.familyName ?? '';
      final fullName = '$givenName $familyName'.trim();
      if (fullName.isNotEmpty) {
        _lastAppleFullName = fullName;
        if (user != null) {
          await user.updateDisplayName(fullName);
        }
      }

      appPrint('[FirebaseAuth] Apple Sign-In success: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      appPrint('[FirebaseAuth] Apple Sign-In error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      appPrint('[FirebaseAuth] Apple Sign-In unexpected error: $e');
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      appPrint('[FirebaseAuth] Email verification sent to ${user.email}');
    }
  }

  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      appPrint('[FirebaseAuth] User reloaded. Email verified status: ${user.emailVerified}');
    }
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  String? getUid() => _auth.currentUser?.uid;
}
