import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibe_swipe/src/core/utils/app_exports.dart';
import 'package:vibe_swipe/src/components/primary_elevated_button.dart';
import 'package:vibe_swipe/src/core/services/live_chat_service.dart';
import 'package:vibe_swipe/src/modules/listner/performances/domain/entities/live_chat_message.dart';
import '../../domain/entities/performance_entity.dart';
import '../widgets/live_chat_overlay.dart';
import '../widgets/super_chat_ticker.dart';

class ArtistLiveBroadcastView extends StatefulWidget {
  const ArtistLiveBroadcastView({super.key, required this.item});

  final PerformanceEntity item;

  @override
  State<ArtistLiveBroadcastView> createState() => _ArtistLiveBroadcastViewState();
}

class _ArtistLiveBroadcastViewState extends State<ArtistLiveBroadcastView> {
  final AgoraService _agoraService = locator<AgoraService>();
  bool _isLive = false;
  bool _isMicEnabled = true;
  bool _isCameraEnabled = true;
  bool _hasCamera = false;
  int _viewerCount = 0;
  DateTime? _streamStartTime;
  List<LiveChatMessage> _pinnedSuperChats = [];
  StreamSubscription? _performanceSubscription;
  StreamSubscription? _viewersSubscription;

  @override
  void initState() {
    super.initState();
    // Start watching viewer count immediately
    _watchViewerCount();

    _agoraService.onJoinChannelSuccess = (connection, elapsed) {
      if (mounted) {
        setState(() => _isLive = true);
        _watchViewerCount();
      }
    };
    _listenToSuperChats();
    if (widget.item.status == PerformanceStatus.live) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startLiveSession();
      });
    }
  }

  /// Listen to real-time viewer updates via active viewers subcollection
  /// with fallback to performance document current_live_viewers.
  void _watchViewerCount() {
    _performanceSubscription?.cancel();
    _viewersSubscription?.cancel();

    // Primary: listen to active viewers subcollection
    _viewersSubscription = locator<FirestoreService>()
        .watchPerformanceViewers(widget.item.id)
        .listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _viewerCount = snapshot.docs.length;
      });
    }, onError: (e) {
      debugPrint('[ArtistLive] Error watching viewers subcollection: $e');
    });

    // Secondary / Fallback: listen to performance document
    _performanceSubscription = locator<FirestoreService>()
        .watchPerformance(widget.item.id)
        .listen((snapshot) {
      if (!mounted) return;
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) return;
      final count = data['current_live_viewers'];
      if (count is int && count >= 0) {
        if (_viewerCount == 0 && count > 0) {
          setState(() => _viewerCount = count);
        }
      }
    });
  }

  void _listenToSuperChats() {
    LiveChatService.watchMessagesForOverlay(widget.item.id).listen((messages) {
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

  @override
  void dispose() {
    _agoraService.onJoinChannelSuccess = null;
    _agoraService.onUserJoined = null;
    _agoraService.onUserOffline = null;
    _performanceSubscription?.cancel();
    _viewersSubscription?.cancel();
    _leaveChannel();
    super.dispose();
  }

  Future<void> _startLiveSession() async {
    if (_isLive) return;
    var cameraStatus = await Permission.camera.status;
    var micStatus = await Permission.microphone.status;

    // If microphone is not yet granted, request it directly from the OS
    if (!micStatus.isGranted && !micStatus.isPermanentlyDenied) {
      micStatus = await Permission.microphone.request();
    }

    if (!cameraStatus.isGranted && !cameraStatus.isPermanentlyDenied) {
      cameraStatus = await Permission.camera.request();
    }

    final hasMic = micStatus.isGranted;
    final hasCamera = cameraStatus.isGranted;

    if (!hasMic) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Microphone permission is required for live streaming. Please enable it in Settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    await _agoraService.initialize();
    if (!_agoraService.isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize live streaming. Please try again.')),
        );
      }
      return;
    }

    await _agoraService.joinChannel(
      role: ClientRoleType.clientRoleBroadcaster,
      enableVideo: hasCamera,
      enableAudio: true,
    );

    // Update Firestore status to live
    await locator<FirestoreService>().startLivePerformance(
      performanceId: widget.item.id,
      channelName: _agoraService.channelName,
    );

    if (mounted) {
      setState(() {
        _hasCamera = hasCamera;
        _streamStartTime = DateTime.now();
      });
    }
  }

  Future<void> _leaveChannel() async {
    if (_agoraService.isInitialized) {
      await _agoraService.leaveChannel();
      await _agoraService.dispose();
    }
  }

  Future<void> _endSession() async {
    // Update Firestore status to ended
    await locator<FirestoreService>().endLivePerformance(widget.item.id);
    await _leaveChannel();
    if (mounted) {
      final duration = _streamStartTime != null
          ? DateTime.now().difference(_streamStartTime!)
          : Duration.zero;
      AppRouterGo.pushReplacement(
        artistSessionEndedView,
        extra: {
          'item': widget.item,
          'duration': _formatDuration(duration),
        },
      );
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  void _toggleMic() {
    setState(() {
      _isMicEnabled = !_isMicEnabled;
    });
    _agoraService.toggleMicrophone(_isMicEnabled);
  }

  void _toggleCamera() {
    setState(() {
      _isCameraEnabled = !_isCameraEnabled;
    });
    _agoraService.toggleCamera(_isCameraEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.listenerDashboardBg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview or background
          if (_isLive && _hasCamera && _agoraService.engine != null)
            AgoraVideoView(
              controller: _agoraService.localVideoController(),
            )
          else if (_isLive && !_hasCamera)
            // Audio-only live mode: show animated placeholder
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A2040), Color(0xFF0D121B)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: AppColors.listenerActiveTab.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.mic,
                        color: AppColors.listenerActiveTab,
                        size: 40.sp,
                      ),
                    ),
                    12.ph,
                    Text(
                      'Audio Only',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryWhite,
                      ),
                    ),
                    4.ph,
                    Text(
                      'No camera detected',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.huegrey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            NetworkSnap(
              imageUrl: widget.item.thumbnailUrl,
              width: 1.sw,
              height: 1.sh,
              fit: BoxFit.cover,
              radius: 0,
              errorWidget: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A2040), Color(0xFF0D121B)],
                  ),
                ),
              ),
            ),

          // Gradient overlay — light at top for controls visibility,
          // gentle at bottom so the artist can clearly see their own video.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.listenerDashboardBg.withValues(alpha: 0.45),
                  AppColors.listenerDashboardBg.withValues(alpha: 0.05),
                  AppColors.listenerDashboardBg.withValues(alpha: 0.05),
                  AppColors.listenerDashboardBg.withValues(alpha: 0.40),
                ],
                stops: const [0.0, 0.18, 0.72, 1.0],
              ),
            ),
          ),

          // Live chat overlay — positioned well above the control buttons
          // so messages don't overlap with mic/cam/flip row.
          if (_isLive)
            LiveChatOverlay(
              performanceId: widget.item.id,
              bottomOffset: 200,
            ),

          // Super Chat Ticker (pinned zone at top)
          if (_isLive && _pinnedSuperChats.isNotEmpty)
            Positioned(
              top: 60.h,
              left: 0,
              right: 0,
              child: SuperChatTicker(
                pinnedSuperChats: _pinnedSuperChats,
                onDismiss: _dismissSuperChat,
              ),
            ),

          // Content overlay
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar: back + LIVE badge + viewer count
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: Row(
                    children: [
                      const CircularBackButton(),
                      const Spacer(),
                      if (_isLive) ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: AppColors.listenerDislikeRed,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryWhite,
                            ),
                          ),
                        ),
                        10.pw,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: AppColors.listenerChipBg,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.visibility_outlined, color: AppColors.primaryWhite, size: 14.sp),
                              4.pw,
                              Text(
                                '$_viewerCount',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),

                // Title + description (shown before going live)
                if (!_isLive)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryWhite,
                            height: 1.25,
                          ),
                        ),
                        if (widget.item.description != null) ...[
                          6.ph,
                          Text(
                            widget.item.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryWhite.withValues(alpha: 0.60),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                20.ph,

                // Controls (shown when live)
                if (_isLive)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ControlButton(
                          icon: _isMicEnabled ? Icons.mic : Icons.mic_off,
                          label: _isMicEnabled ? 'Mic On' : 'Mic Off',
                          onTap: _toggleMic,
                        ),
                        if (_hasCamera) ...[
                          20.pw,
                          _ControlButton(
                            icon: _isCameraEnabled ? Icons.videocam : Icons.videocam_off,
                            label: _isCameraEnabled ? 'Cam On' : 'Cam Off',
                            onTap: _toggleCamera,
                          ),
                          20.pw,
                          _ControlButton(
                            icon: Icons.switch_camera,
                            label: 'Flip',
                            onTap: () => _agoraService.switchCamera(),
                          ),
                        ],
                      ],
                    ),
                  ),

                16.ph,

                // Start Live / End Session button
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                  child: _isLive
                      ? PrimaryElevatedButton(
                          onTap: _endSession,
                          text: 'End Session',
                          backgroundColor: AppColors.listenerDislikeRed,
                          textColor: AppColors.primaryWhite,
                        )
                      : PrimaryElevatedButton(
                          onTap: _startLiveSession,
                          text: 'Start Live Session',
                          leadingWidget: Image.asset(
                            'assets/icons/png/artist_start_live_session_icn.png',
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.listenerChipBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryWhite.withValues(alpha: 0.10),
                width: 1.09,
              ),
            ),
            child: Icon(icon, color: AppColors.primaryWhite, size: 24.sp),
          ),
          6.ph,
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.primaryWhite,
            ),
          ),
        ],
      ),
    );
  }
}
