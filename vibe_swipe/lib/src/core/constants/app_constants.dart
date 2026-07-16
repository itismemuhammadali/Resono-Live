import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // ── Genres ──────────────────────────────────────────────────
  static const List<String> genres = [
    'Pop',
    'Rock',
    'Hip Hop',
    'Electronic',
    'Jazz',
    'Classical',
    'R&B',
    'Country',
    'Blues',
    'Reggae',
    'Metal',
    'Folk',
    'Indie',
    'Soul',
    'Funk',
    'Latin',
    'Afrobeat',
    'K-Pop',
    'DJ',
    'Religious',
  ];

  // ── Support ─────────────────────────────────────────────────
  static const String supportEmail = 'support@soundwave.com';

  // ── Version ─────────────────────────────────────────────────
  static const String appVersion = 'SoundWave v1.0.0';

  // ── Fallbacks ───────────────────────────────────────────────
  static const String fallbackImageUrl =
      'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=600&q=80';

  static const List<Color> fallbackCoverColors = [
    Color(0xFF6A3093),
    Color(0xFFA044FF),
  ];

  // ── Community Topic Icons ───────────────────────────────────
  static const List<String> trendingTopicAssets = [
    'assets/icons/png/artist_trending_music_icn.png',
    'assets/icons/png/artist_trending_live_icn.png',
    'assets/icons/png/artist_trending_collab_icn.png',
    'assets/icons/png/artist_trending_new_releases_icn.png',
  ];
}
