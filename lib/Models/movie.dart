
class Movie {
  final int id;
  final String title;
  final String overview;
  final double popularity;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final List<int> genreIds;
  final List<int> actorIds;
  bool isFavorite; // Add this line

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.genreIds,
    required this.actorIds,
    this.isFavorite = false, // Add this line
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      popularity: json['popularity'].toDouble(),
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: json['vote_average'].toDouble(),
      voteCount: json['vote_count'],
      releaseDate: json['release_date'] ?? '',
      genreIds: List<int>.from(json['genre_ids']),
      actorIds: List<int>.from(json['actor_ids'] ?? []),
      isFavorite: false, // Initialize as false
    );
  }

  String get posterUrl => 'https://image.tmdb.org/t/p/w500$posterPath';
}