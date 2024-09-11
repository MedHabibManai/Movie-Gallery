import 'package:flutter/material.dart';
import 'package:testlearn/Models/review.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> fetchReviews(int movieId) async {
    _isLoading = true;
    notifyListeners();

    final url = 'https://api.themoviedb.org/3/movie/$movieId/reviews?api_key=831c22f29f0fdfae6b59f84bba2cf263';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reviewList = (data['results'] as List)
            .map((item) => Review.fromJson(item))
            .toList();
        _reviews = reviewList;
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }
}
