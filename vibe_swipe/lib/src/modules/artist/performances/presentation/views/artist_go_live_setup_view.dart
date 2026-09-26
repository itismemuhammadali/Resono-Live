import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/core/services/in_app_purchase_service.dart';
import 'package:vibe_swipe/src/modules/artist/earnings/presentation/widgets/payout_required_dialog.dart';
import 'package:vibe_swipe/src/modules/artist/register/presentation/widgets/artist_labeled_field.dart';
import '../controllers/artist_performances_controller.dart';
import '../widgets/cover_image_upload_box.dart';

class ArtistGoLiveSetupView extends ConsumerStatefulWidget {
  const ArtistGoLiveSetupView({super.key});

  @override
  ConsumerState<ArtistGoLiveSetupView> createState() => _ArtistGoLiveSetupViewState();
}

class _ArtistGoLiveSetupViewState extends ConsumerState<ArtistGoLiveSetupView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  XFile? _coverImage;
  Uint8List? _coverImageBytes;
  String? _selectedCategory;
  bool _isPaid = false;
  TicketTier _selectedTier = TicketTier.allTiers[1]; // Default to Tier 2 ($5)

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    ImageSourceSheet.show(context, (file) async {
      if (file != null && mounted) {
        final bytes = await file.readAsBytes();
        setState(() {
          _coverImage = file;
          _coverImageBytes = bytes;
        });
      }
    });
  }

  Future<void> _handleSelectPaidAccess() async {
    final uid = locator<FirebaseAuthService>().getUid();
    if (uid != null) {
      final userData = await locator<FirestoreService>().getUserData(uid);
      final isPayoutSetup = userData?['stripeOnboardingComplete'] == true;
      if (!isPayoutSetup && mounted) {
        PayoutRequiredDialog.show(context);
        return;
      }
    }
    if (mounted) {
      setState(() => _isPaid = true);
    }
  }

  Future<void> _onGoLive() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a performance title')),
      );
      return;
    }

    if (_isPaid) {
      final uid = locator<FirebaseAuthService>().getUid();
      if (uid != null) {
        final userData = await locator<FirestoreService>().getUserData(uid);
        final isPayoutSetup = userData?['stripeOnboardingComplete'] == true;
        if (!isPayoutSetup && mounted) {
          PayoutRequiredDialog.show(context);
          return;
        }
      }
    }

    final controller = ref.read(artistPerformancesControllerProvider);
    final entity = await controller.startInstantLiveSession(
      title: title,
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      isPaid: _isPaid,
      ticketPrice: _isPaid ? _selectedTier.price : null,
      ticketTier: _isPaid ? _selectedTier.tierNumber : null,
      ticketProductId: _isPaid ? _selectedTier.productId : null,
      coverBytes: _coverImageBytes,
    );

    if (entity != null && mounted) {
      AppRouterGo.pushReplacement(
        artistLiveBroadcastView,
        extra: entity,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to start live stream. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(artistPerformancesControllerProvider);
    final isGoingLive = controller.isGoingLive;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: isGoingLive ? null : () => Navigator.of(context).pop(),
                    ),
                    8.pw,
                    Text(
                      'Go Live Setup',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.primaryWhite,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          6.pw,
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Stream Info',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.primaryWhite,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      4.ph,
                      Text(
                        'Set up your live stream details before broadcasting',
                        style: TextStyle(
                          color: AppColors.santagrey,
                          fontSize: 13.sp,
                        ),
                      ),
                      20.ph,
                      ArtistLabeledField(
                        label: 'Stream Title *',
                        hintText: 'e.g. Acoustic Sunset Live',
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => setState(() {}),
                      ),
                      18.ph,
                      Text(
                        'Cover Photo / Thumbnail',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.gray300,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      10.ph,
                      CoverImageUploadBox(
                        image: _coverImage,
                        imageBytes: _coverImageBytes,
                        onTap: isGoingLive ? () {} : _pickImage,
                      ),
                      18.ph,
                      ArtistLabeledField(
                        label: 'Description (Optional)',
                        hintText: 'What will you be playing or discussing?',
                        controller: _descriptionController,
                        maxLines: 4,
                        minLines: 3,
                        textInputType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      20.ph,
                      Text(
                        'Performance Access',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.gray300,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      10.ph,
                      Row(
                        children: [
                          Expanded(
                            child: _AccessTypeChip(
                              label: 'Free',
                              isSelected: !_isPaid,
                              onTap: isGoingLive
                                  ? null
                                  : () => setState(() => _isPaid = false),
                            ),
                          ),
                          12.pw,
                          Expanded(
                            child: _AccessTypeChip(
                              label: 'Paid (Ticket)',
                              isSelected: _isPaid,
                              onTap: isGoingLive ? null : _handleSelectPaidAccess,
                            ),
                          ),
                        ],
                      ),
                      if (_isPaid) ...[
                        16.ph,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select Ticket Tier',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: AppColors.gray300,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Price: \$${_selectedTier.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                color: AppColors.listenerYellow,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        10.ph,
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 10.h,
                            childAspectRatio: 2.1,
                          ),
                          itemCount: TicketTier.allTiers.length,
                          itemBuilder: (context, index) {
                            final tier = TicketTier.allTiers[index];
                            final isSelected =
                                _selectedTier.tierNumber == tier.tierNumber;
                            return _TicketTierTile(
                              tier: tier,
                              isSelected: isSelected,
                              onTap: isGoingLive
                                  ? null
                                  : () => setState(() => _selectedTier = tier),
                            );
                          },
                        ),
                      ],
                      22.ph,
                      Text(
                        'Category / Genre',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.gray300,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      12.ph,
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: ArtistPerformancesController.availableCategories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: isGoingLive
                                ? null
                                : (selected) {
                                    setState(() {
                                      _selectedCategory = selected ? category : null;
                                    });
                                  },
                            selectedColor: AppColors.listenerActiveTab,
                            backgroundColor: const Color(0xFF1E2433),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13.sp,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.listenerActiveTab
                                  : Colors.white.withValues(alpha: 0.1),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          );
                        }).toList(),
                      ),
                      32.ph,
                      PrimaryElevatedButton(
                        onTap: () => _onGoLive(),
                        enabled: !isGoingLive,
                        text: isGoingLive ? 'Starting Broadcast...' : 'Go Live Now',
                        loader: isGoingLive,
                        backgroundColor: AppColors.listenerYellow,
                        textColor: AppColors.primaryblack,
                        radius: 14,
                        buttonStyle: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          backgroundColor: AppColors.listenerYellow,
                          disabledBackgroundColor: AppColors.listenerYellow.withValues(alpha: 0.4),
                        ),
                      ),
                      24.ph,
                    ],
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

class _AccessTypeChip extends StatelessWidget {
  const _AccessTypeChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.listenerActiveTab.withValues(alpha: 0.15)
              : const Color(0xFF121821),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.listenerActiveTab
                : Colors.white.withValues(alpha: 0.1),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: isSelected ? AppColors.listenerActiveTab : AppColors.primaryWhite,
            fontSize: 15.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TicketTierTile extends StatelessWidget {
  const _TicketTierTile({
    required this.tier,
    required this.isSelected,
    this.onTap,
  });

  final TicketTier tier;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.listenerYellow.withValues(alpha: 0.12)
              : const Color(0xFF161C26),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.listenerYellow
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${tier.name} • ${tier.formattedPrice}',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: isSelected ? AppColors.listenerYellow : AppColors.primaryWhite,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  2.ph,
                  Text(
                    tier.subtitle,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.santagrey,
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.listenerYellow,
                size: 16.sp,
              ),
          ],
        ),
      ),
    );
  }
}
