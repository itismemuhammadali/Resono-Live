import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../controllers/listener_profile_controller.dart';
import 'package:vibe_swipe/src/components/listener_tab_toggle.dart';
import '../widgets/library_song_tile.dart';
import '../widgets/library_empty_state.dart';

class ListenerLibraryView extends ConsumerStatefulWidget {
  const ListenerLibraryView({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<ListenerLibraryView> createState() =>
      _ListenerLibraryViewState();
}

class _ListenerLibraryViewState extends ConsumerState<ListenerLibraryView> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(listenerProfileControllerProvider);
    final songs = _selectedTab == 0
        ? controller.savedSongsList
        : controller.listeningHistoryList;

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/png/app_background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.r),
                    bottomRight: Radius.circular(20.r),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.snowWhite.withValues(alpha: 0.4),
                      width: 1.w,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListenerPageHeader(
                      title: _selectedTab == 0 ? 'Your Library' : 'History',
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20.w,
                        right: 20.w,
                        bottom: 16.h,
                      ),
                      child: ListenerTabToggle(
                        tabs: const [
                          ListenerTabItem(label: 'Saved Songs'),
                          ListenerTabItem(label: 'History'),
                        ],
                        selectedIndex: _selectedTab,
                        onChanged: (tab) => setState(() => _selectedTab = tab),
                        containerColor: AppColors.listenerBackButtonBorder,
                        showBorder: false,
                        containerRadius: 16,
                        tabRadius: 12,
                        tabVerticalPadding: 12,
                      ),
                    ),
                  ],
                ),
              ),
              16.ph,
              Expanded(
                child: songs.isEmpty
                    ? LibraryEmptyState(isHistory: _selectedTab == 1)
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 4.h,
                        ),
                        itemCount: songs.length,
                        separatorBuilder: (_, __) => 12.ph,
                        itemBuilder: (context, index) => LibrarySongTile(
                          song: songs[index],
                          isHistory: _selectedTab == 1,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
