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
    super.key,
    required this.type,
    required this.placementName,
    this.isTestMode = true,
  });

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
    _fetchAd();
  }

  Future<void> _fetchAd() async {
    try {
      final ads = await adsService.getActiveAds(placement: widget.placementName);
      if (!mounted) return;
      if (ads.isNotEmpty) {
        setState(() {
          _ad = ads.first;
          _isLoading = false;
        });

        if (!_viewLogged) {
          _viewLogged = true;
          adsService.logAdView(_ad!.id);
        }
      } else {
        setState(() {
          _ad = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _ad = null;
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
              color: Colors.black.withValues(alpha: 0.1),
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
              color: Colors.black.withValues(alpha: 0.6),
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
    if (_isLoading || _ad == null) {
      return const SizedBox.shrink();
    }

    switch (widget.type) {
      case MetaAdPlacementType.banner:
        return _buildRealAd(60.h);
      case MetaAdPlacementType.mediumRectangle:
        return _buildRealAd(250.h);
      case MetaAdPlacementType.inlineFeed:
        return _buildRealAd(120.h);
      case MetaAdPlacementType.streamOverlay:
        return _buildRealAd(80.h, width: 300.w);
    }
  }
}
