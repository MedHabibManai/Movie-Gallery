class Review {
  final String author;
  final String content;
  final String? avatarPath;
  final double? rating;

  Review({
    required this.author,
    required this.content,
    this.avatarPath,
    this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      author: json['author'] ?? 'Anonymous',
      content: json['content'] ?? '',
      avatarPath: json['author_details']['avatar_path'],
      rating: json['author_details']['rating']?.toDouble(),
    );
  }

  String get avatarUrl => avatarPath != null
      ? 'https://image.tmdb.org/t/p/w500$avatarPath'
      : 'https://www.gravatar.com/avatar/00000000000000000000000000000000';
}