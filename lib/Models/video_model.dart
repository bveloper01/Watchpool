class Video {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final String channelProfilePictureUrl;
  final String viewCount;
  final DateTime publishedAt;

  Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.channelProfilePictureUrl,
    required this.viewCount,
    required this.publishedAt,
  });

  factory Video.fromMap(Map<String, dynamic> snippet, Map<String, dynamic> statistics) {
    return Video(
      id: snippet['resourceId']['videoId'] ?? '',
      title: snippet['title'] ?? '',
      thumbnailUrl: snippet['thumbnails']['high']['url'] ?? '',
      channelTitle: snippet['channelTitle'] ?? '',
      channelProfilePictureUrl: snippet['channelProfilePictureUrl'] ?? '',
      viewCount: statistics['viewCount'] ?? '',
      publishedAt: DateTime.parse(snippet['publishedAt'] ?? ''),
    );
  }
}