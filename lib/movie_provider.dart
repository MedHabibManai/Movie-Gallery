import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models.dart'; // Assuming your models are defined in this file

class MovieProvider with ChangeNotifier {
  final String apiKey = '831c22f29f0fdfae6b59f84bba2cf263';
  final String accountId = '21440048';
  final sessionId = '0252db7882eca6552d36518e4fae675ee4249963';
  List<Movie> _movies = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  List<Video> _videos = [];
  bool _isVideoLoading = false;
  Set<int> _favoriteMovieIds = {}; // Store favorite movie IDs

  List<Video> get videos => _videos;
  bool get isVideoLoading => _isVideoLoading;
  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  MovieProvider() {
    fetchFavoriteMovies();
  }

  Future<void> fetchFavoriteMovies() async {
    final url = 'https://api.themoviedb.org/3/account/$accountId/favorite/movies?api_key=$apiKey&session_id=$sessionId';
    final response = await http.get(Uri.parse(url));
    print(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      _favoriteMovieIds = results.map<int>((json) => json['id']).toSet();
      notifyListeners(); // Notify listeners so that the UI can update with the new favorite list
    } else {
      // Handle error
    }
  }

  void resetMovies() {
    _movies = [];
    _isLoading = false;
    _hasMore = true;
    _currentPage = 1;
    notifyListeners();
  }

  bool isFavorite(int movieId) {
    return _favoriteMovieIds.contains(movieId);
  }

  Future<void> fetchMovies(String category) async {
    if (_isLoading || !_hasMore) return;

    final url = category == "favorites"
        ? 'https://api.themoviedb.org/3/account/$accountId/favorite/movies?api_key=$apiKey&session_id=$sessionId&page=$_currentPage'
        : 'https://api.themoviedb.org/3/movie/$category?api_key=$apiKey&page=$_currentPage';

    print(url);
    _isLoading = true;
    notifyListeners();

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      final List<Movie> newMovies = results.map((json) => Movie.fromJson(json)).toList();

      // Check if movies are already favorites
      for (var movie in newMovies) {
        if (_favoriteMovieIds.contains(movie.id)) {
          movie.isFavorite = true;
        }
      }

      _movies.addAll(newMovies);
      _isLoading = false;
      _currentPage++;
      if (newMovies.length < 20) { // Assuming TMDb returns 20 results per page
        _hasMore = false;
      }
    } else {
      _isLoading = false;
      _hasMore = false;
    }
    notifyListeners();
  }

  Future<void> fetchMoviesByQuery(String query) async {
    if (_isLoading || !_hasMore) return;
    final url = 'https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=$query&page=$_currentPage';
    print(url);
    _isLoading = true;
    notifyListeners();

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      final List<Movie> newMovies = results.map((json) => Movie.fromJson(json)).toList();

      _movies.addAll(newMovies);
      _isLoading = false;
      _currentPage++;
      if (newMovies.length < 20) {
        _hasMore = false;
      }
    } else {
      _isLoading = false;
      _hasMore = false;
    }
    notifyListeners();
  }

  Future<void> fetchMovieVideos(int movieId) async {
    _isVideoLoading = true;
    notifyListeners();

    final url = 'https://api.themoviedb.org/3/movie/$movieId/videos?api_key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      _videos = results
          .where((video) => video['type'] == 'Trailer')
          .map((json) => Video.fromJson(json))
          .toList();
    } else {
      // Handle errors as needed
    }

    _isVideoLoading = false;
    notifyListeners();
  }

  Future<void> addToFavorites(Movie movie) async {
    final url = 'https://api.themoviedb.org/3/account/$accountId/favorite?api_key=$apiKey&session_id=$sessionId';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json;charset=utf-8'},
      body: json.encode({
        'media_type': 'movie',
        'media_id': movie.id,
        'favorite': true,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      _favoriteMovieIds.add(movie.id);
      movie.isFavorite = true;
      _movies.add(movie);
      notifyListeners();
    } else {
      // Handle error
    }
  }

  Future<void> removeFromFavorites(Movie movie) async {
    final url = 'https://api.themoviedb.org/3/account/$accountId/favorite?api_key=$apiKey&session_id=$sessionId';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json;charset=utf-8'},
      body: json.encode({
        'media_type': 'movie',
        'media_id': movie.id,
        'favorite': false,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      _favoriteMovieIds.remove(movie.id);
      movie.isFavorite = false;
      _movies.remove(movie);
      notifyListeners();
    } else {
      // Handle error
    }
  }

  Future<void> toggleFavoriteStatus(Movie movie) async {
    if (isFavorite(movie.id)) {
      await removeFromFavorites(movie);
    } else {
      await addToFavorites(movie);
    }
  }

  List<Movie> get favoriteMovies {
    return _movies.where((movie) => _favoriteMovieIds.contains(movie.id)).toList();
  }
}