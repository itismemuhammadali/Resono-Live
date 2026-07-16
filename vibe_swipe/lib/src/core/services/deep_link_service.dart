import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibe_swipe/src/core/utils/app_logger.dart';

class DeepLinkService {
  static const _pendingEmailKey = 'magic_link_pending_email';
  final _storage = const FlutterSecureStorage();
  final _appLinks = AppLinks();
  final _auth = FirebaseAuth.instance;

  StreamController<String>? _pendingEmailController;
  Stream<String> get pendingEmailStream =>
      _pendingEmailController?.stream ?? const Stream.empty();

  String? _pendingEmail;

  Future<void> init() async {
    _pendingEmailController = StreamController<String>.broadcast();

    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      await _handleLink(initialLink);
    }

    _appLinks.uriLinkStream.listen(
      (uri) async {
        await _handleLink(uri);
      },
      onError: (err) {
        appPrint('[DeepLink] Error: $err');
      },
    );
  }

  Future<void> _handleLink(Uri uri) async {
    appPrint('[DeepLink] Received: $uri');

    if (_auth.isSignInWithEmailLink(uri.toString())) {
      final email = _pendingEmail ?? await _storage.read(key: _pendingEmailKey);

      if (email != null && email.isNotEmpty) {
        try {
          await _auth.signInWithEmailLink(email: email, emailLink: uri.toString());
          appPrint('[DeepLink] Magic link sign-in success');
          await _storage.delete(key: _pendingEmailKey);
          _pendingEmailController?.add('success');
        } catch (e) {
          appPrint('[DeepLink] Sign-in failed: $e');
          _pendingEmailController?.add('error:$e');
        }
      } else {
        appPrint('[DeepLink] No pending email found for magic link');
        _pendingEmailController?.add('no_email');
      }
    }
  }

  Future<void> storePendingEmail(String email) async {
    _pendingEmail = email;
    await _storage.write(key: _pendingEmailKey, value: email);
    appPrint('[DeepLink] Stored pending email: $email');
  }

  Future<void> dispose() async {
    await _pendingEmailController?.close();
  }
}
