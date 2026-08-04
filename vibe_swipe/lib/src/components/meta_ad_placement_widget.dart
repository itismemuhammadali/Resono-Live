import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/core/services/ads_service.dart';

enum MetaAdPlacementType {
  banner,
  inlineFeed,
  streamOverlay,
  mediumRectangle,
}

class MetaAdPlacementWidget extends StatefulWidget {
  final MetaAdPlacementType type;
  final String placementName;
  final bool isTestMode;

  const MetaAdPlacementWidget({
    Key? key,
    required this.type,
    required this.placementName,
    this.isTestMode = true, // Default to true so developers can see the placeholder
  }) : super(key: key);

  @override
  State<MetaAdPlacementWidget> createState() => _MetaAdPlacementWidgetState();
}

class _MetaAdPlacementWidgetState extends State<MetaAdPlacementWidget> {
  AdCampaign? _ad;
  bool _isLoading = true;
  bool _viewLogged = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isTestMode) {
      _fetchAd();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _fetchAd() async {
    final ads = await adsService.getActiveAds(placement: widget.placementName);
    if (ads.isNotEmpty) {
      if (mounted) {
        setState(() {
          _ad = ads.first;
          _isLoading = false;
        });
      }

      if (_ad != null && !_viewLogged) {
        _viewLogged = true;
        adsService.logAdView(_ad!.id);
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onAdClicked() async {
    if (widget.isTestMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meta Ad clicked (Test Mode)')),
      );
      return;
    }

    if (_ad == null) return;

    adsService.logAdClick(_ad!.id);

    if (_ad!.destinationUrl.isNotEmpty) {
      final uri = Uri.parse(_ad!.destinationUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  Widget _buildPlaceholder(double height, {double? width}) {
    return GestureDetector(
      onTap: _onAdClicked,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D24),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.listenerActiveTab.withOpacity(0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ad_units, color: AppColors.subtitleGray.withOpacity(0.5), size: 24.sp),
                8.ph,
                Text(
                  'Meta Ad Placement\n(${widget.placementName})',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.subtitleGray.withOpacity(0.8),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.listenerActiveTab.withOpacity(0.2),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Sponsored',
                  style: TextStyle(
                    color: AppColors.listenerActiveTab,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealAd(double height, {double? width}) {
    if (_ad == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _onAdClicked,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          image: DecorationImage(
            image: NetworkImage(_ad!.bannerUrl),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Text(
              'Sponsored',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    }

    final bool showPlaceholder = widget.isTestMode || _ad == null;

    switch (widget.type) {
      case MetaAdPlacementType.banner:
        return showPlaceholder ? _buildPlaceholder(60.h) : _buildRealAd(60.h);
      case MetaAdPlacementType.mediumRectangle:
        return showPlaceholder ? _buildPlaceholder(250.h) : _buildRealAd(250.h);
      case MetaAdPlacementType.inlineFeed:
        return showPlaceholder ? _buildPlaceholder(120.h) : _buildRealAd(120.h);
      case MetaAdPlacementType.streamOverlay:
        return showPlaceholder
            ? _buildPlaceholder(80.h, width: 300.w)
            : _buildRealAd(80.h, width: 300.w);
    }
  }
}
