import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isJoined = false;
  bool _isPaidPerformance = false;
  double _ticketPrice = 9.99;
  bool _streamEnded = false;
  bool _agoraInitialized = false;
  bool _accessCheckCompleted = false;
  StreamSubscription? _performanceSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listenerPerformancesControllerProvider.notifier).setCurrentPerformance(widget.featured.id, artistId: widget.featured.artistId);
      if (widget.featured.videoUrl.isNotEmpty) {
        ref.read(listenerPerformancesControllerProvider.notifier).initVideo(widget.featured.videoUrl);
      }
      _checkAccess();
      _watchPerformanceStatus();
    });
  }

  void _watchPerformanceStatus() {
    _performanceSubscription = locator<FirestoreService>()
        .watchPerformance(widget.featured.id)
        .listen((snapshot) {
      if (!mounted) return;
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) return;

      final status = data['status'] ?? 'upcoming';
      if (status == 'ended' && !_streamEnded) {
        _handleStreamEnded();
      } else if (status == 'live' && !_isAgoraLive && !_agoraInitialized) {
        // Only join Agora if access has already been confirmed.
        // _checkAccess() is async — if it hasn't resolved yet we skip here;
        // _checkAccess itself will call _initAgora() once it confirms access.
        final hasPaidAccess = ref.read(tippingControllerProvider).hasPaid;
        if (!_isPaidPerformance && _accessCheckCompleted) {
          _initAgora();
        } else if (_isPaidPerformance && hasPaidAccess) {
          _initAgora();
        }
        // If _accessCheckCompleted is false, _checkAccess() will handle it.
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
      final result = await StripeService().checkAccess(
        userId: userId,
        performanceId: widget.featured.id,
      );
      if (mounted) {
        setState(() {
          _isPaidPerformance = result['isPaid'] == true;
          _ticketPrice = (result['price'] ?? 9.99).toDouble();
          _accessCheckCompleted = true;
        });
        if (_isPaidPerformance && result['hasAccess'] == true) {
          ref.read(tippingControllerProvider.notifier).checkAccess(
            userId: userId,
            performanceId: widget.featured.id,
          );
          _initAgora();
        } else if (!_isPaidPerformance) {
          _initAgora();
        }
        // If isPaid && !hasAccess — show the paywall. Do NOT call _initAgora.
      }
    } catch (e) {
      // Network error: keep _isPaidPerformance as-is (default false = free stream).
      // Only call _initAgora if we haven't already decided it's a paid gate.
      if (mounted) {
        setState(() => _accessCheckCompleted = true);
        if (!_isPaidPerformance) {
          _initAgora();
        }
      }
    }
  }

  @override
  void dispose() {
    _performanceSubscription?.cancel();
    _agoraService.onUserJoined = null;
    _agoraService.onUserOffline = null;
    _agoraService.onJoinChannelSuccess = null;
    _agoraService.leaveChannel();
    _agoraService.dispose();
    super.dispose();
  }

  Future<void> _initAgora() async {
    if (_agoraInitialized) return;
    await [Permission.camera, Permission.microphone].request();

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
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // Video area — always uses LivePerformanceVideoSection as the container
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.60,
            width: double.infinity,
            child: Stack(
              children: [
                showStream
                    ? LivePerformanceVideoSection(
                        featured: widget.featured,
                        isPlaying: controller.isPlaying,
                        isVideoInitialized: controller.isVideoInitialized,
                        onPlayPause: notifier.togglePlay,
                        isLive: _isAgoraLive,
                        videoController: controller.videoController,
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
                        price: _ticketPrice,
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
          ),

          // Chat messages area
          if (showStream && !_streamEnded)
            Expanded(
              child: Column(
                children: [
                  // Title and description
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        12.ph,
                        Text(
                          widget.featured.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                        8.ph,
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primaryWhite.withValues(alpha: 0.55),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  8.ph,
                  // Live chat messages
                  Expanded(
                    child: LiveChatMessagesList(
                      performanceId: widget.featured.id,
                    ),
                  ),
                ],
              ),
            ),

          // Chat input
          if (showStream && !_streamEnded)
            LiveChatInput(
              onSend: (text) => _sendChatMessage(text),
              onSuperChat: () => _showSuperChatSheet(),
            ),

          // Action bar
          if (showStream && !_streamEnded)
            LivePerformanceActionBar(
              isLiked: controller.isLiked,
              isSaved: controller.isSaved,
              isFollowing: controller.isFollowing,
              onLike: notifier.togglePlay,
              onSave: notifier.toggleSave,
              onFollow: notifier.toggleFollow,
              onTip: () => _showSuperChatSheet(),
            ),
          12.ph,
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
