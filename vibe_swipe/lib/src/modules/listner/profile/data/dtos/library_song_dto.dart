import 'package:flutter/material.dart';

class LibrarySongDto {
  const LibrarySongDto({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.coverColors,
    this.coverUrl,
    this.album,
    this.duration,
    this.releaseYear,
  });

  final String id;
  final String title;
  final String artist;
  final String genre;
  final List<Color> coverColors;
  final String? coverUrl;
  final String? album;
  final String? duration;
  final String? releaseYear;
}
