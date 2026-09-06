import 'package:vibe_swipe/src/core/utils/app_exports.dart';

class ArtistDiscussionDetailReplyTile extends StatelessWidget {
  const ArtistDiscussionDetailReplyTile({
    super.key,
    required this.reply,
    this.isLiked = false,
    this.onLikeTap,
    this.onOptionsTap,
  });

  final Map<String, dynamic> reply;
  final bool isLiked;
  final VoidCallback? onLikeTap;
  final VoidCallback? onOptionsTap;

  @override
  Widget build(BuildContext context) {
    final author = reply['author'] as String;
    final date = reply['date'] as String;
    final text = reply['text'] as String;
    final likes = reply['likes'] as int;
    final authorAvatarUrl = (reply['authorAvatarUrl'] as String?) ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryWhite.withValues(alpha: 0.10),
          width: 1.09.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40.r,
                height: 40.r,
                child: authorAvatarUrl.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: authorAvatarUrl,
                          width: 40.r,
                          height: 40.r,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => CircleAvatar(
                            radius: 20.r,
                            backgroundColor: AppColors.listenerBackButtonBorder,
                            child: Icon(
                              Icons.person,
                              size: 20.r,
                              color: AppColors.coolGray,
                            ),
                          ),
                          errorWidget: (_, __, ___) => CircleAvatar(
                            radius: 20.r,
                            backgroundColor: AppColors.listenerBackButtonBorder,
                            child: Text(
                              author.isNotEmpty ? author[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryWhite,
                              ),
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 20.r,
                        backgroundColor: AppColors.listenerBackButtonBorder,
                        child: Text(
                          author.isNotEmpty ? author[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                      ),
              ),
              12.pw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                author,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryWhite,
                                ),
                              ),
                              4.ph,
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.huegrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (onOptionsTap != null)
                          GestureDetector(
                            onTap: onOptionsTap,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
                              child: Icon(
                                Icons.more_vert,
                                color: AppColors.huegrey,
                                size: 18.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    10.ph,
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.coolGray,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          12.ph,
          Row(
            children: [
              GestureDetector(
                onTap: onLikeTap,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      isLiked ? AppColors.listenerLiveRed : Colors.white,
                      BlendMode.srcIn,
                    ),
                  child: Image.asset(
                    'assets/icons/png/artist_community_post_like_btn_icn.png',
                  ),
                ),
              ),
              8.pw,
              Text(
                '$likes',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isLiked ? AppColors.listenerLiveRed : AppColors.coolGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
