import 'package:flutter/material.dart';

class ListItem {
  final String text;
  final EdgeInsetsGeometry padding;

  ListItem({required this.text, this.padding = const EdgeInsets.only(right:8.0)});
}
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

class Actor {
  final int id;
  final String name;
  final String profileUrl;
  final String character;
  final String? biography;
  final String? birthday;
  final String? placeOfBirth;
  final String? deathday;

  Actor({
    required this.id,
    required this.name,
    required this.profileUrl,
    required this.character,
    this.biography,
    this.birthday,
    this.placeOfBirth,
    this.deathday,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'],
      name: json['name'],
      profileUrl: json['profile_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['profile_path']}'
          : 'https://via.placeholder.com/150',
      character: json['character'] ?? '',
      biography: json['biography'], // Add biography
      birthday: json['birthday'], // Add birthday
      placeOfBirth: json['place_of_birth'], // Add place of birth
      deathday: json['deathday'], // Add deathday if available
    );
  }
}

class Video {
  final String key;
  final String name;
  final String type;

  Video({required this.key, required this.name, required this.type});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      key: json['key'],
      name: json['name'],
      type: json['type'],
    );
  }
}
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

