import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class LiveChatInput extends StatefulWidget {
  final Function(String text) onSend;
  final VoidCallback onSuperChat;

  const LiveChatInput({
    super.key,
    required this.onSend,
    required this.onSuperChat,
  });

  @override
  State<LiveChatInput> createState() => _LiveChatInputState();
}

class _LiveChatInputState extends State<LiveChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primaryblack.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: AppColors.primaryWhite.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: widget.onSuperChat,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.superChatGold, AppColors.superChatGoldDark],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.star, color: Colors.white, size: 20.sp),
              ),
            ),
            8.pw,
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(color: AppColors.primaryWhite, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Send a message...',
                  hintStyle: TextStyle(
                    color: AppColors.primaryWhite.withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    widget.onSend(text.trim());
                    _controller.clear();
                  }
                },
              ),
            ),
            8.pw,
            GestureDetector(
              onTap: () {
                if (_controller.text.trim().isNotEmpty) {
                  widget.onSend(_controller.text.trim());
                  _controller.clear();
                }
              },
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.listenerYellow,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.send, color: AppColors.primaryblack, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
