import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AgoraService {
  RtcEngine? _engine;
  bool _isInitialized = false;

  RtcEngine? get engine => _engine;
  bool get isInitialized => _isInitialized;

  String get appId => dotenv.get('AGORA_APP_ID', fallback: '');
  String get channelName => dotenv.get('AGORA_CHANNEL_NAME', fallback: 'live-stream-test');
  bool get isTestMode => dotenv.get('AGORA_TEST_MODE', fallback: 'false').toLowerCase() == 'true';

  // Token refresh state
  Timer? _refreshTimer;
  String? _currentToken;
  String? _currentChannelId;
  int _currentUid = 0;
  int _tokenExpirySeconds = 3600; // default 1 hour
  static const int _refreshBufferSeconds = 300; // refresh 5 min before expiry

  // Event callbacks — set by the calling view
  void Function(RtcConnection connection, int remoteUid, int elapsed)? onUserJoined;
  void Function(RtcConnection connection, int remoteUid, UserOfflineReasonType reason)? onUserOffline;
  void Function(RtcConnection connection, RtcStats stats)? onLeaveChannel;
  void Function(RtcConnection connection, int elapsed)? onJoinChannelSuccess;
  void Function(String message, int code)? onError;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        areaCode: 0xFFFFFFFF,
      ));

      _registerEventHandlers();
      _isInitialized = true;
      debugPrint('[AgoraService] Engine initialized');
      return true;
    } catch (e) {
      debugPrint('[AgoraService] Failed to initialize: $e');
      _engine = null;
      _isInitialized = false;
      return false;
    }
  }

  void _registerEventHandlers() {
    _engine?.registerEventHandler(RtcEngineEventHandler(
      onUserJoined: (connection, remoteUid, elapsed) {
        debugPrint('[AgoraService] User joined: $remoteUid');
        onUserJoined?.call(connection, remoteUid, elapsed);
      },
      onUserOffline: (connection, remoteUid, reason) {
        debugPrint('[AgoraService] User offline: $remoteUid');
        onUserOffline?.call(connection, remoteUid, reason);
      },
      onJoinChannelSuccess: (connection, elapsed) {
        debugPrint('[AgoraService] Joined channel: ${connection.channelId}');
        onJoinChannelSuccess?.call(connection, elapsed);
      },
      onLeaveChannel: (connection, stats) {
        debugPrint('[AgoraService] Left channel');
        onLeaveChannel?.call(connection, stats);
      },
      onError: (err, msg) {
        debugPrint('[AgoraService] Error: ${err.name} - $msg');
        // Token expired — attempt refresh
        if (err.index == 109 || msg.contains('token')) {
          debugPrint('[AgoraService] Token error detected, refreshing...');
          _refreshToken();
        }
        onError?.call(msg, err.index);
      },
    ));
  }

  Future<String?> _fetchToken({required String channelName, int uid = 0, int expireTime = 3600, String role = 'publisher', String? performanceId}) async {
    // Use temp token from .env if available
    final tempToken = dotenv.tryGet('AGORA_TEMP_TOKEN');
    if (tempToken != null && tempToken.isNotEmpty) {
      debugPrint('[AgoraService] Using temp token from .env');
      return tempToken;
    }

    // In test mode, Agora allows null tokens — skip fetching
    if (isTestMode) {
      debugPrint('[AgoraService] Test mode — using null token');
      return null;
    }

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('generateAgoraToken');
      final result = await callable.call({
        'channelName': channelName,
        'uid': uid,
        'role': role,
        'expireTime': expireTime,
        if (performanceId != null) 'performanceId': performanceId,
      });

      final data = result.data as Map<String, dynamic>;
      debugPrint('[AgoraService] Token fetched successfully, expires in ${data['expiresIn']}s');
      _tokenExpirySeconds = data['expiresIn'] as int? ?? expireTime;
      return data['token'] as String?;
    } catch (e) {
      debugPrint('[AgoraService] Error fetching token: $e');
      return null;
    }
  }

  void _startRefreshTimer() {
    _cancelRefreshTimer();
    if (isTestMode) return;

    final refreshIn = (_tokenExpirySeconds - _refreshBufferSeconds).clamp(60, _tokenExpirySeconds);
    debugPrint('[AgoraService] Token refresh scheduled in ${refreshIn}s');
    _refreshTimer = Timer(Duration(seconds: refreshIn), () => _refreshToken());
  }

  void _cancelRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _refreshToken() async {
    if (_currentChannelId == null || _engine == null) return;
    if (isTestMode) return;

    debugPrint('[AgoraService] Refreshing token...');
    final newToken = await _fetchToken(
      channelName: _currentChannelId!,
      uid: _currentUid,
      expireTime: _tokenExpirySeconds,
    );

    if (newToken != null && _engine != null) {
      _currentToken = newToken;
      // Update token on the active channel without disconnecting
      await _engine!.renewToken(newToken);
      debugPrint('[AgoraService] Token refreshed successfully');
      _startRefreshTimer(); // schedule next refresh
    } else {
      debugPrint('[AgoraService] Token refresh failed');
    }
  }

  Future<void> joinChannel({
    required ClientRoleType role,
    String? channelToken,
    String? channelId,
    int uid = 0,
    bool enableVideo = true,
    bool enableAudio = true,
    String? performanceId,
  }) async {
    if (_engine == null) {
      debugPrint('[AgoraService] Engine not initialized');
      return;
    }

    final effectiveChannel = channelId ?? channelName;

    // Store for refresh
    _currentChannelId = effectiveChannel;
    _currentUid = uid;

    // Fetch a fresh token from the backend
    final agoraRole = role == ClientRoleType.clientRoleBroadcaster ? 'publisher' : 'subscriber';
    final token = channelToken ?? await _fetchToken(channelName: effectiveChannel, uid: uid, role: agoraRole, performanceId: performanceId);
    _currentToken = token;

    if (token == null || token.isEmpty) {
      debugPrint('[AgoraService] Using null token (test mode or fallback)');
    }

    if (enableVideo) await _engine!.enableVideo();
    if (enableAudio) {
      await _engine!.enableAudio();
      if (role == ClientRoleType.clientRoleBroadcaster) {
        await _engine!.enableLocalAudio(true);
      }
    }

    await _engine!.joinChannel(
      token: token ?? '',
      channelId: effectiveChannel,
      uid: uid,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: role,
        publishCameraTrack: role == ClientRoleType.clientRoleBroadcaster && enableVideo,
        publishMicrophoneTrack: role == ClientRoleType.clientRoleBroadcaster && enableAudio,
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
      ),
    );

    debugPrint('[AgoraService] Joining channel: $effectiveChannel as ${role.name}');
    _startRefreshTimer();
  }

  Future<void> leaveChannel() async {
    _cancelRefreshTimer();
    _currentToken = null;
    _currentChannelId = null;
    if (_engine == null) return;
    await _engine!.leaveChannel();
    debugPrint('[AgoraService] Left channel');
  }

  Future<void> toggleMicrophone(bool enabled) async {
    await _engine?.enableLocalAudio(enabled);
  }

  Future<void> toggleCamera(bool enabled) async {
    await _engine?.enableLocalVideo(enabled);
  }

  Future<void> switchCamera() async {
    await _engine?.switchCamera();
  }

  VideoViewController localVideoController() {
    return VideoViewController(
      rtcEngine: _engine!,
      canvas: const VideoCanvas(uid: 0),
    );
  }

  VideoViewController remoteVideoController(int remoteUid) {
    return VideoViewController.remote(
      rtcEngine: _engine!,
      canvas: VideoCanvas(uid: remoteUid),
      connection: RtcConnection(channelId: _currentChannelId ?? channelName),
    );
  }

  Future<void> dispose() async {
    _cancelRefreshTimer();
    await leaveChannel();
    await _engine?.release();
    _engine = null;
    _isInitialized = false;
    onUserJoined = null;
    onUserOffline = null;
    onJoinChannelSuccess = null;
    onLeaveChannel = null;
    onError = null;
    debugPrint('[AgoraService] Engine disposed');
  }
}
