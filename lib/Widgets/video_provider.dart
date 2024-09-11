import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testlearn/Models/video.dart';


class VideoProvider with ChangeNotifier {
  List<Video> _videos = [];
  bool _isLoading = false;

  List<Video> get videos => _videos;
  bool get isLoading => _isLoading;

  Future<void> fetchVideos(int movieId) async {
    _isLoading = true;
    notifyListeners();

    final response = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/$movieId/videos?api_key=831c22f29f0fdfae6b59f84bba2cf263'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      // Filter out only trailers
      _videos = results
          .where((videoJson) => videoJson['type'] == 'Trailer')
          .map((videoJson) => Video.fromJson(videoJson))
          .toList();
    } else {
      // Handle errors
      _videos = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}