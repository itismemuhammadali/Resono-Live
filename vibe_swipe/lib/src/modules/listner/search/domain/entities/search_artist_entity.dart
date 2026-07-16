class SearchArtistEntity {
  const SearchArtistEntity({
    required this.uid,
    required this.name,
    required this.genre,
    this.profileImageUrl = '',
    this.followersCount = 0,
  });

  final String uid;
  final String name;
  final String genre;
  final String profileImageUrl;
  final int followersCount;

  factory SearchArtistEntity.fromMap(Map<String, dynamic> map) {
    final genres = map['genres'];
    String genreStr = '';
    if (genres is List && genres.isNotEmpty) {
      genreStr = genres.first.toString();
    }
    return SearchArtistEntity(
      uid: (map['uid'] ?? '').toString(),
      name: (map['name'] ?? map['artistName'] ?? '').toString(),
      genre: genreStr,
      profileImageUrl: (map['profileImageUrl'] ?? '').toString(),
      followersCount: map['followersCount'] is num ? (map['followersCount'] as num).toInt() : 0,
    );
  }
}
