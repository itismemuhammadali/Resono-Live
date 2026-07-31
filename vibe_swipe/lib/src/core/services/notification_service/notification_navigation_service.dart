import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_swipe/src/core/services/routing_service/app_routes.dart';
import 'package:vibe_swipe/src/core/services/routing_service/named_routes.dart';

class NotificationNavigationService {
  static Map<String, dynamic>? pendingNotificationData;

  static void handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] ?? '';
    final context = AppRouterGo.context;
    if (context == null) return;

    final route = _resolveRoute(type, data);
    if (route != null) {
      context.go(route);
    }
  }

  static String? _resolveRoute(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'live_stream_started':
      case 'scheduled_session_reminder':
        return listenerUpcomingPerformanceDetailView;
      case 'new_follower':
        return artistDashboardView;
      case 'new_performance_upload':
      case 'performance_like':
        return listenerDashboardView;
      case 'post_comment':
      case 'post_like':
        return artistPostDetailView;
      case 'tip_received':
      case 'payout_processed':
        return artistEarningsView;
      case 'payment_confirmed':
      case 'payment_failed':
        return '/payment-success';
      default:
        return listenerDashboardView;
    }
  }
}
