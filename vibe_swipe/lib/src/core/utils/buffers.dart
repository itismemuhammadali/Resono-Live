// mixin Bufferss on ChangeNotifier{}
// here we use on because changeNotifier is already mixin
import 'app_exports.dart';

mixin Buffers on ChangeNotifier {
  List<String> buffers = [];

  void addLoader(String id) {
    buffers.add(id);
    debugPrint('Buffer added: $id');
    notifyListeners();
  }

  void removeLoader(String id) {
    buffers.remove(id);
    debugPrint('Buffer remove: $id');
    notifyListeners();
  }

  bool hasLoader(String id) {
    return buffers.contains(id);
  }

  String sanitizeError(Object error, [String? friendlyMessage]) {
    final errorStr = error.toString();
    if (errorStr.contains('HandshakeException') && !kDebugMode) {
      return friendlyMessage ?? "Something went wrong. Please try again later.";
    }
    return errorStr;
  }

  @protected
  Future<void> executeAPI({
    bool isAuth = false,
    bool onUnAuthPrompt = false,
    bool showPromt = true,
    required String apiEndPoint,
    required Future<void> Function() onSuccess,
    Future<void> Function(Object)? onError,
    Future<void> Function()? onFinally,
  }) async {
    if (hasLoader(apiEndPoint)) return;
    try {
      addLoader(apiEndPoint);
      await onSuccess();
    } on UnAuthException catch (e) {
      if (!isAuth) {
        AuthHandler.ref.logout();
      }
      if (onUnAuthPrompt) {
        Prompts.showSnackBar(e.toString(), color: AppColors.eventRed);
      }
    } on SilentException catch (e) {
      appPrint('[SilentError]: ${e.toString()}');
      await onError?.call(e);
    } on TypeError catch (e) {
      appPrint('[SilentError-TypeMismatch]: ${e.toString()}');
      appPrint('[StackTrace]: ${e.stackTrace}');
      await onError?.call(e);
    } catch (e, stackTrace) {
      appPrint('[Error]: ${e.runtimeType}\n');
      appPrint('[Error-StackTrace]: $stackTrace');

      if (showPromt) {
        // Only show snackbar if it's not a silenced handshake error
        // or if sanitizeError didn't change it to a generic message when it was a handshake error
        // Actually, if it's a handshake error in release, we might want to SILENCE the snackbar entirely
        // as per previous requirement.
        
        final isHandshakeError = e.toString().contains('HandshakeException');
        if (isHandshakeError) {
          if (kDebugMode) {
            Prompts.showSnackBar(e.toString(), color: AppColors.eventRed);
          }
        } else {
          Prompts.showSnackBar(e.toString(), color: AppColors.eventRed);
        }
      }
      await onError?.call(e);
    } finally {
      removeLoader(apiEndPoint);
      await onFinally?.call();
    }
  }
}
