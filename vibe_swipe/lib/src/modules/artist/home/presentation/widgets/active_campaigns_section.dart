import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/campaign_entity.dart';

class ActiveCampaignsSection extends StatelessWidget {
  const ActiveCampaignsSection({super.key, required this.campaigns});

  final List<CampaignEntity> campaigns;

  @override
  Widget build(BuildContext context) {
    if (campaigns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Campaigns',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryWhite,
          ),
        ),
        12.ph,
        ...campaigns.map(
          (campaign) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _CampaignCard(campaign: campaign),
          ),
        ),
      ],
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign});

  final CampaignEntity campaign;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
            children: [
              Expanded(
                child: Text(
                  campaign.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryWhite,
                  ),
                ),
              ),
              if (campaign.isActive)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.listenerActiveTab.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.listenerActiveTab,
                    ),
                  ),
                ),
            ],
          ),
          8.ph,
          Text(
            campaign.subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.huegrey,
            ),
          ),
        ],
      ),
    );
  }
}
