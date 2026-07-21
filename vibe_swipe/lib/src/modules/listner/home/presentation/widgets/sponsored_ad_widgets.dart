import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibe_swipe/src/core/services/ads_service.dart';

class SponsoredAdBanner extends StatefulWidget {
  final String placement;
  
  const SponsoredAdBanner({Key? key, this.placement = 'Home Banner'}) : super(key: key);

  @override
  State<SponsoredAdBanner> createState() => _SponsoredAdBannerState();
}

class _SponsoredAdBannerState extends State<SponsoredAdBanner> {
  AdCampaign? _ad;
  bool _isLoading = true;
  bool _viewLogged = false;

  @override
  void initState() {
    super.initState();
    _fetchAd();
  }

  Future<void> _fetchAd() async {
    final ads = await adsService.getActiveAds(placement: widget.placement);
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
    if (_ad == null) return;
    
    adsService.logAdClick(_ad!.id);
    
    if (_ad!.destinationUrl.isNotEmpty) {
      final uri = Uri.parse(_ad!.destinationUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
    }
    
    if (_ad == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _onAdClicked,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              'Sponsored',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
