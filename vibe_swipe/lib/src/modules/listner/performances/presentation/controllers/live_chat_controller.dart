import 'dart:async';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/services/live_chat_service.dart';
import 'package:vibe_swipe/src/modules/listner/performances/domain/entities/live_chat_message.dart';

final liveChatControllerProvider = ChangeNotifierProvider.autoDispose
    .family<LiveChatController, String>((ref, performanceId) =>
        LiveChatController(performanceId));

class LiveChatController extends ChangeNotifier {
  final String performanceId;
  StreamSubscription? _subscription;
  List<LiveChatMessage> _messages = [];
  bool _isLoading = true;

  List<LiveChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  LiveChatController(this.performanceId) {
    _listenToMessages();
  }

  void _listenToMessages() {
    _subscription = LiveChatService.watchMessages(performanceId)
        .listen((messages) {
      _messages = messages;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendTextMessage({
    required String text,
    required String senderId,
    required String senderName,
    String senderAvatar = '',
  }) async {
    await LiveChatService.sendMessage(
      performanceId: performanceId,
      text: text,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
