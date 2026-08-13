import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import '../../domain/entities/legal_documents_content.dart';

class TermsAndPoliciesView extends ConsumerStatefulWidget {
  final String? initialSectionId;
  final bool isArtistViewInitial;

  const TermsAndPoliciesView({
    super.key,
    this.initialSectionId,
    this.isArtistViewInitial = false,
  });

  @override
  ConsumerState<TermsAndPoliciesView> createState() => _TermsAndPoliciesViewState();
}

class _TermsAndPoliciesViewState extends ConsumerState<TermsAndPoliciesView>
    with SingleTickerProviderStateMixin {
  late String _selectedSectionId;
  late bool _isArtistMode;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSectionId = widget.initialSectionId ?? LegalDocumentsContent.sections.first.id;
    _isArtistMode = widget.isArtistViewInitial || AppConfig.userRole == UserRole.artist;

    final initialIndex = LegalDocumentsContent.sections
        .indexWhere((s) => s.id == _selectedSectionId)
        .clamp(0, LegalDocumentsContent.sections.length - 1);

    _tabController = TabController(
      length: LegalDocumentsContent.sections.length,
      vsync: this,
      initialIndex: initialIndex,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedSectionId = LegalDocumentsContent.sections[_tabController.index].id;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'gavel':
        return Icons.gavel_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'music_note':
        return Icons.music_note_rounded;
      case 'copyright':
        return Icons.copyright_rounded;
      case 'payments':
        return Icons.payments_rounded;
      case 'info':
        return Icons.info_outline_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSection = LegalDocumentsContent.sections.firstWhere(
      (s) => s.id == _selectedSectionId,
      orElse: () => LegalDocumentsContent.sections.first,
    );

    final rawContent = _isArtistMode
        ? currentSection.artistContent
        : currentSection.listenerContent;

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: Row(
                children: [
                  const CircularBackButton(),
                  12.pw,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Legal & Policies',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                        2.ph,
                        Text(
                          'VibeSwipe Legal Compliance & Terms',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12.sp,
                            color: AppColors.santagrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            12.ph,

            // Role Mode Selector Pill (Listener Terms vs Artist Terms)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.listenerChipBg,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.listenerChipBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isArtistMode = false),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: !_isArtistMode
                                ? AppColors.listenerYellow
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Text(
                              '🎧 Listener Terms',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: !_isArtistMode
                                    ? AppColors.primaryblack
                                    : AppColors.santagrey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isArtistMode = true),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _isArtistMode
                                ? AppColors.listenerYellow
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Text(
                              '🎤 Artist Terms',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: _isArtistMode
                                    ? AppColors.primaryblack
                                    : AppColors.santagrey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            16.ph,

            // Category Tab Bar
            Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.listenerYellow,
                indicatorWeight: 3.h,
                labelColor: AppColors.listenerYellow,
                unselectedLabelColor: AppColors.santagrey,
                labelStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
                tabs: LegalDocumentsContent.sections.map((sec) {
                  return Tab(
                    child: Row(
                      children: [
                        Icon(_getIcon(sec.iconName), size: 16.sp),
                        6.pw,
                        Text(sec.title),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const Divider(color: AppColors.listenerChipBorder, height: 1),

            // Document Content Viewer
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Summary Header Card
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.listenerChipBg,
                            AppColors.listenerChipBg.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.listenerYellow.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: AppColors.listenerYellow.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIcon(currentSection.iconName),
                              color: AppColors.listenerYellow,
                              size: 24.sp,
                            ),
                          ),
                          14.pw,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentSection.title,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryWhite,
                                  ),
                                ),
                                4.ph,
                                Text(
                                  currentSection.summary,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12.sp,
                                    color: AppColors.santagrey,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    20.ph,

                    // Formatted Body Paragraphs
                    _buildFormattedContent(rawContent),

                    32.ph,

                    // Footer Contact Banner
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.listenerChipBg.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.listenerChipBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.mail_outline_rounded,
                                  color: AppColors.listenerYellow, size: 20.sp),
                              8.pw,
                              Text(
                                'Legal Questions & Inquiries',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryWhite,
                                ),
                              ),
                            ],
                          ),
                          8.ph,
                          Text(
                            'For questions regarding these legal terms, privacy policies, or copyright takedowns, reach out to legal@vibeswipe.com.',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12.sp,
                              color: AppColors.santagrey,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    20.ph,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedContent(String markdownText) {
    final lines = markdownText.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        widgets.add(SizedBox(height: 8.h));
      } else if (trimmed.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
            child: Text(
              trimmed.substring(2),
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.listenerYellow,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: 14.h, bottom: 6.h),
            child: Text(
              trimmed.substring(4),
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryWhite,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('• ')) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(left: 8.w, bottom: 6.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.listenerYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    trimmed.substring(2),
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 13.sp,
                      color: AppColors.primaryWhite.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (trimmed == '---') {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Divider(color: AppColors.listenerChipBorder),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              trimmed,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13.sp,
                color: AppColors.primaryWhite.withValues(alpha: 0.85),
                height: 1.45,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
