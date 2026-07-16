import 'package:flutter/material.dart';

class ArtistProfileArgs {
  const ArtistProfileArgs({
    required this.artistId,
    required this.artistName,
  });

  final String artistId;
  final String artistName;
}

class ArtistDto {
  const ArtistDto({
    required this.id,
    required this.name,
    required this.genre,
    required this.followersCount,
    required this.bio,
    required this.coverColors,
    required this.topSongs,
    this.coverUrl,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String genre;
  final String followersCount;
  final String bio;
  final List<Color> coverColors;
  final List<ArtistTopSongDto> topSongs;
  final String? coverUrl;
  final String? avatarUrl;
}

class ArtistTopSongDto {
  const ArtistTopSongDto({
    required this.id,
    required this.title,
    required this.playsCount,
    required this.coverColors,
    this.coverUrl,
  });

  final String id;
  final String title;
  final String playsCount;
  final List<Color> coverColors;
  final String? coverUrl;
}
