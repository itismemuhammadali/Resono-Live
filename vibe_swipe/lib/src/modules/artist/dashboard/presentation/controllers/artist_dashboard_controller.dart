import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../../../listner/dashboard/domain/entities/tab_item.dart';
import '../../../analytics/presentation/views/artist_analytics_view.dart';
import '../../../community/presentation/views/artist_community_view.dart';
import '../../../home/presentation/views/artist_home_view.dart';
import '../../../performances/presentation/views/artist_performances_view.dart';
import '../../../profile/presentation/views/artist_profile_view.dart';

final artistDashboardInitialTabProvider = StateProvider<int>((ref) => 0);

final artistDashboardControllerProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ArtistDashboardController(
    initialTab: ref.read(artistDashboardInitialTabProvider),
  ),
);

class ArtistDashboardController extends ChangeNotifier with Buffers {
  ArtistDashboardController({int initialTab = 0}) : selectedIndex = initialTab;

  int selectedIndex;

  final List<Widget> screens = const [
    ArtistHomeView(),
    ArtistPerformancesView(),
    ArtistCommunityView(),
    ArtistAnalyticsView(),
    ArtistProfileView(),
  ];

  final List<TabItem> tabs = const [
    TabItem(
      selectedIcon: AppAssetsPng.homeSelectedIcn,
      unselectedIcon: AppAssetsPng.homeUnselectedIcn,
      label: 'Home',
    ),
    TabItem(
      selectedIcon: AppAssetsPng.performanceSelectedIcn,
      unselectedIcon: AppAssetsPng.performanceUnselectedIcn,
      label: 'Performances',
    ),
    TabItem(
      selectedIcon: AppAssetsPng.communitySelectedIcn,
      unselectedIcon: AppAssetsPng.communityUnselectedIcn,
      label: 'Community',
    ),
    TabItem(
      selectedIcon: AppAssetsPng.artistAnalyticsSelectedIcn,
      unselectedIcon: AppAssetsPng.artistAnalyticsUnselectedIcn,
      label: 'Analytics',
    ),
    TabItem(
      selectedIcon: AppAssetsPng.profileSelectedIcn,
      unselectedIcon: AppAssetsPng.profileUnselectedIcn,
      label: 'Profile',
    ),
  ];

  void onTabTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  bool isSelected(int index) => selectedIndex == index;
}
