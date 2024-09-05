import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models.dart'; // Assuming your models are defined in this file

class ActorProvider with ChangeNotifier {
  final String apiKey = '831c22f29f0fdfae6b59f84bba2cf263';
  List<Actor> _actors = [];
  List<Movie> _actorMovies = [];
  bool _isLoading = false;
  bool _isLoadingMovies = false;
  Actor? _selectedActor;

  List<Actor> get actors => _actors;
  List<Movie> get actorMovies => _actorMovies;
  bool get isLoading => _isLoading;
  bool get isLoadingMovies => _isLoadingMovies;
  Actor? get selectedActor => _selectedActor;

  void resetActors() {
    _actors = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchActors(int movieId) async {
    if (_isLoading) return;
    final url = 'https://api.themoviedb.org/3/movie/$movieId/credits?api_key=$apiKey';
    _isLoading = true;
    notifyListeners();

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['cast'];
      _actors = results.map((json) => Actor.fromJson(json)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoviesByActor(int actorId) async {
    if (_isLoadingMovies) return;
    final url = 'https://api.themoviedb.org/3/person/$actorId/movie_credits?api_key=$apiKey';
    _isLoadingMovies = true;
    notifyListeners();

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['cast'];
      _actorMovies = results.map((json) => Movie.fromJson(json)).toList();
    }

    _isLoadingMovies = false;
    notifyListeners();
  }

  Future<void> fetchActorDetails(int actorId) async {
    final url = 'https://api.themoviedb.org/3/person/$actorId?api_key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _selectedActor = Actor.fromJson(data);
      notifyListeners();
    } else {
      throw Exception('Failed to load actor details');
    }
  }
}
