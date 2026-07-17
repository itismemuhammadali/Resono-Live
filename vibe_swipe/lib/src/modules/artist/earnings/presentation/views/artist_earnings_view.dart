import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/artist_earnings_controller.dart';
import '../../domain/entities/earning_entities.dart';

class ArtistEarningsView extends ConsumerWidget {
  const ArtistEarningsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(artistEarningsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryWhite),
          onPressed: () => AppRouterGo.back(),
        ),
        title: Text(
          'Earnings',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryWhite,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              12.ph,
              _MetricsPanel(controller: controller),
              20.ph,
              _WalletStatusCard(controller: controller),
              24.ph,
              _SectionTitle(title: 'Earnings by Performance'),
            12.ph,
            ...controller.performanceEarnings.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _PerformanceEarningTile(earning: e),
              ),
            ),
            24.ph,
            _SectionTitle(title: 'Pending Payouts'),
            12.ph,
            if (controller.pendingPayouts.isEmpty)
              _EmptyPayouts(message: 'No pending payouts')
            else
              ...controller.pendingPayouts.map(
                (p) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _PayoutTile(payout: p),
                ),
              ),
            24.ph,
            _SectionTitle(title: 'Paid Out'),
            12.ph,
            if (controller.paidPayouts.isEmpty)
              _EmptyPayouts(message: 'No paid payouts yet')
            else
              ...controller.paidPayouts.map(
                (p) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _PayoutTile(payout: p),
                ),
              ),
            32.ph,
          ],
        ),
      ),
    ),
  );
}
}

class _MetricsPanel extends StatelessWidget {
  const _MetricsPanel({required this.controller});
  final ArtistEarningsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.listenerChipBorder),
      ),
      child: Column(
        children: [
          _MetricRow(
            label: 'Gross Earnings',
            value: '\$${controller.grossEarnings.toStringAsFixed(2)}',
            valueColor: AppColors.primaryWhite,
          ),
          12.ph,
          _MetricRow(
            label: 'Platform Fee (15%)',
            value: '-\$${controller.platformFee.toStringAsFixed(2)}',
            valueColor: AppColors.eventRed,
          ),
          Divider(color: AppColors.listenerChipBorder, height: 24.h),
          _MetricRow(
            label: 'Net Earnings',
            value: '\$${controller.netEarnings.toStringAsFixed(2)}',
            valueColor: AppColors.primaryGreen,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.primaryWhite,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14.sp,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: AppColors.santagrey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 16.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryWhite,
      ),
    );
  }
}

class _PerformanceEarningTile extends StatelessWidget {
  const _PerformanceEarningTile({required this.earning});
  final PerformanceEarning earning;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.listenerChipBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  earning.performanceTitle,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryWhite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '\$${earning.netAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          8.ph,
          Row(
            children: [
              _StatChip(icon: Icons.visibility_outlined, label: '${earning.viewerCount}'),
              12.pw,
              _StatChip(icon: Icons.attach_money_rounded, label: '${earning.tipCount} tips'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.santagrey),
        4.pw,
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12.sp,
            color: AppColors.santagrey,
          ),
        ),
      ],
    );
  }
}

class _PayoutTile extends StatelessWidget {
  const _PayoutTile({required this.payout});
  final PayoutRecord payout;

  @override
  Widget build(BuildContext context) {
    final isPending = payout.status == PayoutStatus.pending;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.listenerChipBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payout.source,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryWhite,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.ph,
                Text(
                  '${payout.date.month}/${payout.date.day}/${payout.date.year}',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.sp,
                    color: AppColors.santagrey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${payout.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryWhite,
                ),
              ),
              4.ph,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isPending
                      ? AppColors.listenerYellow.withValues(alpha: 0.15)
                      : AppColors.primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  isPending ? 'Pending' : 'Paid',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: isPending ? AppColors.listenerYellow : AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyPayouts extends StatelessWidget {
  const _EmptyPayouts({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14.sp,
            color: AppColors.santagrey,
          ),
        ),
      ),
    );
  }
}

class _WalletStatusCard extends StatelessWidget {
  const _WalletStatusCard({required this.controller});
  final ArtistEarningsController controller;

  @override
  Widget build(BuildContext context) {
    final configured = controller.isWalletConfigured;
    final wallet = controller.payoutWallet;
    final method = wallet['payoutMethod'] ?? '';

    String title = 'Payout Wallet';
    String subtitle = 'Not configured';
    IconData icon = Icons.warning_amber_rounded;
    Color iconColor = AppColors.listenerYellow;

    if (configured) {
      if (method == 'bank') {
        final bankName = wallet['bankName'] ?? 'Bank Account';
        final accNum = wallet['accountNumber'] ?? '';
        final masked = accNum.length > 4 ? accNum.substring(accNum.length - 4) : accNum;
        title = bankName;
        subtitle = 'Account ending in ****$masked';
        icon = Icons.account_balance_rounded;
        iconColor = AppColors.primaryGreen;
      } else if (method == 'paypal') {
        final email = wallet['paypalEmail'] ?? 'PayPal';
        title = 'PayPal';
        subtitle = email;
        icon = Icons.payment_rounded;
        iconColor = AppColors.primaryGreen;
      } else if (method == 'crypto') {
        final addr = wallet['cryptoAddress'] ?? '';
        final network = wallet['cryptoNetwork'] ?? 'Crypto';
        final masked = addr.length > 8 ? '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}' : addr;
        title = 'Crypto - $network';
        subtitle = masked;
        icon = Icons.currency_bitcoin_rounded;
        iconColor = AppColors.primaryGreen;
      }
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.listenerChipBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: configured ? AppColors.listenerChipBorder : AppColors.listenerYellow.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          16.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryWhite,
                  ),
                ),
                4.ph,
                Text(
                  configured ? subtitle : 'Set up payout method to receive earnings',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12.sp,
                    color: AppColors.santagrey,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => AppRouterGo.push(artistWalletSetupView),
            style: ElevatedButton.styleFrom(
              backgroundColor: configured ? AppColors.listenerChipBorder : AppColors.listenerYellow,
              foregroundColor: configured ? AppColors.primaryWhite : AppColors.primaryblack,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
            ),
            child: Text(
              configured ? 'Manage' : 'Set Up',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
