import 'package:vibe_swipe/src/core/services/python_api_service.dart';

class AdCampaign {
  final String id;
  final String name;
  final String bannerUrl;
  final String destinationUrl;

  AdCampaign({
    required this.id,
    required this.name,
    required this.bannerUrl,
    required this.destinationUrl,
  });

  factory AdCampaign.fromJson(Map<String, dynamic> json) {
    return AdCampaign(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      bannerUrl: json['bannerUrl'] ?? 'https://placehold.co/600x400/png?text=Ad',
      destinationUrl: json['destinationUrl'] ?? '',
    );
  }
}

class AdsService {
  final PythonApiService _api = PythonApiService();

  Future<List<AdCampaign>> getActiveAds({String? placement}) async {
    try {
      final queryParams = placement != null ? {'placement': placement} : null;
      final response = await _api.get('/campaigns/api/ads/active', queryParams: queryParams);
      
      final adsList = response['ads'] as List<dynamic>? ?? [];
      return adsList.map((adJson) => AdCampaign.fromJson(adJson)).toList();
    } catch (e) {
      print('Error fetching active ads: $e');
      return [];
    }
  }

  Future<void> logAdView(String campaignId) async {
    try {
      await _api.post('/campaigns/api/ads/$campaignId/view');
    } catch (e) {
      print('Error logging ad view: $e');
    }
  }

  Future<void> logAdClick(String campaignId) async {
    try {
      await _api.post('/campaigns/api/ads/$campaignId/click');
    } catch (e) {
      print('Error logging ad click: $e');
    }
  }
}

// Global instance for easy access
final AdsService adsService = AdsService();
