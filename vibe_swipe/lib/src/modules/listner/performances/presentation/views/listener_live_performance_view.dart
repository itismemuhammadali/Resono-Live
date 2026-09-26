import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibe_swipe/src/core/services/in_app_purchase_service.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import '../../domain/entities/performance_featured_entity.dart';
import '../controllers/listener_performances_controller.dart';
import '../controllers/live_chat_controller.dart';
import '../controllers/tipping_controller.dart';
import '../widgets/live_chat_input.dart';
import '../widgets/live_chat_messages_list.dart';
import '../widgets/live_performance_action_bar.dart';
import '../widgets/live_performance_video_section.dart';
import '../widgets/paid_access_gate.dart';
import '../widgets/super_chat_bottom_sheet.dart';
import 'package:vibe_swipe/src/modules/artist/performances/presentation/widgets/super_chat_ticker.dart';
import 'package:vibe_swipe/src/modules/listner/performances/domain/entities/live_chat_message.dart';
import 'package:vibe_swipe/src/core/services/live_chat_service.dart';
import '../../../../../components/meta_ad_placement_widget.dart';

class ListenerLivePerformanceView extends ConsumerStatefulWidget {
  const ListenerLivePerformanceView({super.key, required this.featured});

  final PerformanceFeaturedEntity featured;

  @override
  ConsumerState<ListenerLivePerformanceView> createState() => _ListenerLivePerformanceViewState();
}

class _ListenerLivePerformanceViewState extends ConsumerState<ListenerLivePerformanceView> {
  final AgoraService _agoraService = locator<AgoraService>();
  bool _isAgoraLive = false;
  int? _remoteUid;
  // ignore: unused_field
  bool _isJoined = false;
  bool _isPaidPerformance = false;
  double? _ticketPrice;
  int? _ticketTier;
  bool _streamEnded = false;
  bool _agoraInitialized = false;
  bool _accessCheckCompleted = false;
  bool _accessCheckFailed = false;
  StreamSubscription? _performanceSubscription;
  StreamSubscription? _viewersSubscription;
  int _activeViewersCount = 0;
  bool _hasJoinedLivePerformance = false;

  List<LiveChatMessage> _pinnedSuperChats = [];
  StreamSubscription? _superChatsSubscription;
  LiveChatMessage? _latestSuperChatForAlert;
  Timer? _alertTimer;

  @override
  void initState() {
    super.initState();
    _activeViewersCount = int.tryParse(widget.featured.viewCount) ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listenerPerformancesControllerProvider.notifier).setCurrentPerformance(widget.featured.id, artistId: widget.featured.artistId);
      if (widget.featured.videoUrl.isNotEmpty) {
        ref.read(listenerPerformancesControllerProvider.notifier).initVideo(widget.featured.videoUrl);
      }
      _checkAccess();
      _watchPerformanceStatus();
      _listenToSuperChats();
    });
  }

  void _listenToSuperChats() {
    _superChatsSubscription = LiveChatService.watchMessagesForOverlay(widget.featured.id).listen((messages) {
      if (!mounted) return;
      final superChats = messages.where((m) => m.isSuperChat).toList();
      final now = DateTime.now();
      final activePinned = <LiveChatMessage>[];

      for (final sc in superChats) {
        final elapsed = now.difference(sc.createdAt).inSeconds;
        if (elapsed < sc.tierDurationSeconds) {
          activePinned.add(sc);
        }
      }

      // Check if there is a new super chat for celebration alert
      if (superChats.isNotEmpty) {
        final newest = superChats.first;
        final isNew = _latestSuperChatForAlert == null || _latestSuperChatForAlert!.id != newest.id;
        final isRecent = now.difference(newest.createdAt).inSeconds < 10;
        if (isNew && isRecent) {
          _latestSuperChatForAlert = newest;
          _alertTimer?.cancel();
          _alertTimer = Timer(const Duration(seconds: 4), () {
            if (mounted) {
              setState(() {
                _latestSuperChatForAlert = null;
              });
            }
          });
        }
      }

      setState(() {
        _pinnedSuperChats = activePinned;
      });
    });
  }

  void _dismissSuperChat(String messageId) {
    setState(() {
      _pinnedSuperChats = _pinnedSuperChats.where((m) => m.id != messageId).toList();
    });
  }

  void _joinLivePerformance() {
    if (_hasJoinedLivePerformance) return;
    _hasJoinedLivePerformance = true;
    locator<FirestoreService>().joinPerformance(performanceId: widget.featured.id);
  }

  void _watchPerformanceStatus() {
    _viewersSubscription?.cancel();
    _viewersSubscription = locator<FirestoreService>()
        .watchPerformanceViewers(widget.featured.id)
        .listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _activeViewersCount = snapshot.docs.length;
      });
    }, onError: (e) {
      debugPrint('[ListenerLive] Error watching viewers subcollection: $e');
    });

    _performanceSubscription?.cancel();
    _performanceSubscription = locator<FirestoreService>()
        .watchPerformance(widget.featured.id)
        .listen((snapshot) {
      if (!mounted) return;
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) return;

      final status = data['status'] ?? 'upcoming';
      final isStreamLive = status == 'live';
      final rawCount = isStreamLive
          ? (data['current_live_viewers'] ?? data['viewers_count'] ?? 0)
          : (data['viewers_count'] ?? data['viewCount'] ?? 0);
      if (rawCount is int && _activeViewersCount == 0 && rawCount > 0) {
        setState(() {
          _activeViewersCount = rawCount < 0 ? 0 : rawCount;
        });
      }

      if (data.containsKey('isPaid')) {
        final isPaid = data['isPaid'] == true;
        final rawPrice = (data['ticketPrice'] as num?)?.toDouble() ??
            (data['price'] as num?)?.toDouble();
        final tier = (data['ticketTier'] ?? data['tierNumber']) as int?;
        final price = rawPrice ??
            (tier != null ? TicketTier.fromTierNumber(tier).price : null);
        if (isPaid != _isPaidPerformance || price != _ticketPrice || tier != _ticketTier) {
          setState(() {
            _isPaidPerformance = isPaid;
            if (price != null) _ticketPrice = price;
            if (tier != null) _ticketTier = tier;
          });
        }
      }

      if (status == 'ended' && !_streamEnded) {
        _handleStreamEnded();
      } else if (status == 'live' && !_isAgoraLive && !_agoraInitialized) {
        final hasPaidAccess = ref.read(tippingControllerProvider).hasPaid;
        if (!_isPaidPerformance && _accessCheckCompleted) {
          _joinLivePerformance();
          _initAgora();
        } else if (_isPaidPerformance && hasPaidAccess) {
          _joinLivePerformance();
          _initAgora();
        }
      }
    });
  }

  void _handleStreamEnded() {
    _agoraService.leaveChannel();
    setState(() {
      _isAgoraLive = false;
      _remoteUid = null;
      _streamEnded = true;
    });
  }

  Future<void> _checkAccess() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('performances')
          .doc(widget.featured.id)
          .get();
      final data = doc.data();
      if (data != null && mounted) {
        final isPaid = data['isPaid'] == true;
        final rawPrice = (data['ticketPrice'] as num?)?.toDouble() ??
            (data['price'] as num?)?.toDouble();
        final tier = (data['ticketTier'] ?? data['tierNumber']) as int?;
        final price = rawPrice ??
            (tier != null ? TicketTier.fromTierNumber(tier).price : null);
        final paidUsers = List<String>.from(data['paidUsers'] ?? []);
        final artistId = (data['artist_id'] ?? data['artistId']) as String?;
        final isArtist = artistId != null && artistId == userId;
        final hasAccess = !isPaid || isArtist || paidUsers.contains(userId);

        setState(() {
          _isPaidPerformance = isPaid;
          _ticketPrice = price;
          _ticketTier = tier ?? (price != null ? TicketTier.fromPrice(price).tierNumber : null);
          _accessCheckCompleted = true;
          _accessCheckFailed = false;
        });

        if (hasAccess) {
          ref.read(tippingControllerProvider.notifier).checkAccess(
            userId: userId,
            performanceId: widget.featured.id,
          );
          _joinLivePerformance();
          _initAgora();
        }
        return;
      }
    } catch (e) {
      appPrint('[LivePerformance] Direct checkAccess error: $e');
    }

    if (mounted) {
      setState(() {
        _accessCheckCompleted = true;
        _accessCheckFailed = true;
      });
    }
  }

  @override
  void dispose() {
    if (_hasJoinedLivePerformance) {
      locator<FirestoreService>().leavePerformance(performanceId: widget.featured.id);
    }
    _performanceSubscription?.cancel();
    _viewersSubscription?.cancel();
    _superChatsSubscription?.cancel();
    _alertTimer?.cancel();
    _agoraService.onUserJoined = null;
    _agoraService.onUserOffline = null;
    _agoraService.onJoinChannelSuccess = null;
    _agoraService.leaveChannel();
    _agoraService.dispose();
    super.dispose();
  }

  Future<void> _initAgora() async {
    if (_agoraInitialized) return;

    _agoraService.onJoinChannelSuccess = (connection, elapsed) {
      if (mounted) {
        setState(() {
          _isJoined = true;
        });
      }
    };

    _agoraService.onUserJoined = (connection, remoteUid, elapsed) {
      debugPrint('[ListenerLive] Remote user joined: $remoteUid');
      if (mounted) {
        setState(() {
          _remoteUid = remoteUid;
          _isAgoraLive = true;
        });
      }
    };

    _agoraService.onUserOffline = (connection, remoteUid, reason) {
      debugPrint('[ListenerLive] Remote user left: $remoteUid');
      if (mounted) {
        setState(() {
          _remoteUid = null;
          _isAgoraLive = false;
        });
      }
    };

    await _agoraService.initialize();
    if (!_agoraService.isInitialized) {
      debugPrint('[ListenerLive] Failed to initialize Agora engine');
      return;
    }
    await _agoraService.joinChannel(
      role: ClientRoleType.clientRoleAudience,
      performanceId: widget.featured.id,
    );
    _agoraInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(listenerPerformancesControllerProvider);
    final tipping = ref.watch(tippingControllerProvider);
    final notifier = ref.read(listenerPerformancesControllerProvider.notifier);

    ref.listen(tippingControllerProvider, (prev, next) {
      // Payment just completed — join Agora. If _initAgora was previously
      // called with _agoraInitialized = true (e.g. from the race condition on
      // the Firestore listener), reset the guard so we can actually join now.
      if (next.hasPaid && !(prev?.hasPaid ?? false) && mounted) {
        if (_agoraInitialized) {
          // Already initialized — leave and re-join so the artist stream is picked up.
          _agoraService.leaveChannel();
          _agoraInitialized = false;
        }
        _joinLivePerformance();
        _initAgora();
      }
    });

    final description = widget.featured.description.isNotEmpty
        ? widget.featured.description
        : 'Join ${widget.featured.artist} for an exclusive live '
            '${widget.featured.genre.toLowerCase()} music session '
            'featuring tracks from the latest album and unreleased material.';

    final showStream = !_isPaidPerformance || tipping.hasPaid;

    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Video / Stream is the base layer (takes full screen)
          Positioned.fill(
            child: !_accessCheckCompleted
                // Still checking — show a dark loading screen to prevent flash of free content
                ? Container(
                    color: AppColors.primaryblack,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.listenerYellow,
                            strokeWidth: 2,
                          ),
                          16.ph,
                          Text(
                            'Loading performance...',
                            style: TextStyle(
                              color: AppColors.primaryWhite.withValues(alpha: 0.6),
                              fontSize: 14.sp,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _accessCheckFailed
                    // Access check failed — show retry screen instead of granting free access
                    ? Container(
                        color: AppColors.primaryblack,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.signal_wifi_off_rounded,
                                    color: AppColors.primaryWhite.withValues(alpha: 0.4),
                                    size: 48.sp),
                                16.ph,
                                Text(
                                  'Could not verify access.',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryWhite,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                8.ph,
                                Text(
                                  'Check your connection and try again.',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 13.sp,
                                    color: AppColors.primaryWhite.withValues(alpha: 0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                24.ph,
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _accessCheckCompleted = false;
                                      _accessCheckFailed = false;
                                    });
                                    _checkAccess();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.listenerYellow,
                                    foregroundColor: AppColors.primaryblack,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 32.w, vertical: 14.h),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r)),
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                : showStream
                    ? LivePerformanceVideoSection(
                        featured: widget.featured,
                        isPlaying: controller.isPlaying,
                        isVideoInitialized: controller.isVideoInitialized,
                        onPlayPause: notifier.togglePlay,
                        isLive: _isAgoraLive,
                        videoController: controller.videoController,
                        isFullScreen: true,
                        liveChild: _isAgoraLive && _remoteUid != null && _agoraService.engine != null
                            ? AgoraVideoView(
                                controller: _agoraService.remoteVideoController(_remoteUid!),
                              )
                            : null,
                      )
                    : PaidAccessGate(
                        title: widget.featured.title,
                        artistName: widget.featured.artist,
                        artistId: widget.featured.artistId,
                        performanceId: widget.featured.id,
                        price: _ticketPrice ?? 0.0,
                        tierNumber: _ticketTier,
                      ),
          ),

          // 2. Gradient overlay at top for visibility of top row
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140.h,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Top Floating Row (Header)
          if (showStream && !_streamEnded)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                children: [
                  const CircularBackButton(),
                  12.pw,
                  // Artist profile / name
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryWhite.withValues(alpha: 0.3), width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18.r),
                            child: NetworkSnap(
                              imageUrl: widget.featured.artistImageUrl,
                              width: 36.w,
                              height: 36.w,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
                                  ),
                                ),
                                child: Icon(Icons.person, size: 18.sp, color: AppColors.primaryWhite),
                              ),
                            ),
                          ),
                        ),
                        10.pw,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.featured.artist,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryWhite,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.featured.genre,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 10.sp,
                                  color: AppColors.primaryWhite.withValues(alpha: 0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  12.pw,
                  // LIVE badge
                  if (widget.featured.isLive)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.listenerLiveRed,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'LIVE',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryWhite,
                        ),
                      ),
                    ),
                  8.pw,
                  // Watching Count
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_outlined, color: AppColors.primaryWhite, size: 12.sp),
                        4.pw,
                        Text(
                          '$_activeViewersCount',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 4. Active Super Chat Ticker (pinned under top row)
          if (showStream && !_streamEnded && _pinnedSuperChats.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 64.h,
              left: 0,
              right: 0,
              child: SuperChatTicker(
                pinnedSuperChats: _pinnedSuperChats,
                onDismiss: _dismissSuperChat,
              ),
            ),

          // 5. Celebration alerts (floats below Ticker)
          if (showStream && !_streamEnded && _latestSuperChatForAlert != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + (_pinnedSuperChats.isNotEmpty ? 140.h : 64.h),
              left: 16.w,
              right: 16.w,
              child: _SuperChatCelebrationAlert(message: _latestSuperChatForAlert!),
            ),

          // 5.5. Meta Ad stream overlay (floats on top right or top below header)
          if (showStream && !_streamEnded)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70.h,
              right: 16.w,
              child: const MetaAdPlacementWidget(
                type: MetaAdPlacementType.streamOverlay,
                placementName: 'Live Stream Overlay',
                isTestMode: true,
              ),
            ),

          // 6. Bottom Floating Panel (Title, Chat Messages, Input, Actions)
          if (showStream && !_streamEnded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.95),
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 8.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Description floating on stream
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.featured.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryWhite,
                            ),
                          ),
                          4.ph,
                          Text(
                            description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryWhite.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    12.ph,

                    // Chat messages list
                    SizedBox(
                      height: 240.h,
                      child: LiveChatMessagesList(
                        performanceId: widget.featured.id,
                      ),
                    ),
                    8.ph,

                    // Chat Input
                    LiveChatInput(
                      onSend: (text) => _sendChatMessage(text),
                      onSuperChat: () => _showSuperChatSheet(),
                    ),

                    // Action buttons
                    LivePerformanceActionBar(
                      isLiked: controller.isLiked,
                      isSaved: controller.isSaved,
                      isFollowing: controller.isFollowing,
                      onLike: notifier.togglePlay,
                      onSave: notifier.toggleSave,
                      onFollow: notifier.toggleFollow,
                      onTip: () => _showSuperChatSheet(),
                    ),
                  ],
                ),
              ),
            ),

          // Stream ended overlay
          if (_streamEnded)
            Positioned.fill(
              child: Container(
                color: AppColors.primaryblack.withValues(alpha: 0.85),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.videocam_off_outlined,
                          color: AppColors.primaryWhite.withValues(alpha: 0.5),
                          size: 48.sp,
                        ),
                        16.ph,
                        Text(
                          'The live stream has ended.\nThank you for watching!',
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryWhite.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                        ),
                        24.ph,
                        PrimaryElevatedButton(
                          onTap: () => AppRouterGo.back(),
                          text: 'Go Back',
                          width: 200.w,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _sendChatMessage(String text) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';
    ref.read(liveChatControllerProvider(widget.featured.id).notifier).sendTextMessage(
      text: text,
      senderId: userId,
      senderName: userName,
    );
  }

  void _showSuperChatSheet() {
    SuperChatBottomSheet.show(
      context,
      artistId: widget.featured.artistId,
      artistName: widget.featured.artist,
      performanceId: widget.featured.id,
    );
  }
}

class _SuperChatCelebrationAlert extends StatelessWidget {
  const _SuperChatCelebrationAlert({required this.message});
  final LiveChatMessage message;

  @override
  Widget build(BuildContext context) {
    List<Color> colors;
    switch (message.tier) {
      case SuperChatTier.platinum:
        colors = [AppColors.superChatPlatinumStart, AppColors.superChatPlatinumEnd];
        break;
      case SuperChatTier.gold:
        colors = [AppColors.superChatGoldStart, AppColors.superChatGoldEnd];
        break;
      case SuperChatTier.silver:
        colors = [AppColors.superChatSilverStart, AppColors.superChatSilverEnd];
        break;
      case SuperChatTier.bronze:
        colors = [AppColors.superChatBronzeStart, AppColors.superChatBronzeEnd];
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.5),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Text('✨', style: TextStyle(fontSize: 22.sp)),
          12.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NEW SUPER CHAT RECEIVED!',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 1.2,
                  ),
                ),
                4.ph,
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 13.sp,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: message.senderName,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(text: ' sent '),
                      TextSpan(
                        text: '\$${message.donationAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.superChatGold),
                      ),
                    ],
                  ),
                ),
                if (message.text.isNotEmpty) ...[
                  4.ph,
                  Text(
                    '"${message.text}"',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          12.pw,
          Text('🎉', style: TextStyle(fontSize: 22.sp)),
        ],
      ),
    );
  }
}
