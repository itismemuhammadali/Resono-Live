import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/tab_item.dart';
import '../../../home/presentation/views/listener_home_view.dart';
import '../../../search/presentation/views/listener_search_view.dart';
import '../../../performances/presentation/views/listener_performances_view.dart';
import '../../../community/presentation/views/listener_community_view.dart';
import '../../../profile/presentation/views/listener_profile_view.dart';

final listenerDashboardControllerProvider = ChangeNotifierProvider.autoDispose(
  (ref) => ListenerDashboardController(),
);

class ListenerDashboardController extends ChangeNotifier with Buffers {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    ListenerHomeView(),
    ListenerSearchView(),
    ListenerPerformancesView(),
    ListenerCommunityView(),
    ListenerProfileView(),
  ];

  final List<TabItem> tabs = const [
    TabItem(
      selectedIcon: AppAssetsPng.homeSelectedIcn,
      unselectedIcon: AppAssetsPng.homeUnselectedIcn,
      label: 'Home',
    ),
    TabItem(
      selectedIcon: AppAssetsPng.searchSelectedIcn,
      unselectedIcon: AppAssetsPng.searchUnselectedIcn,
      label: 'Search',
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
