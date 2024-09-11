
import 'package:flutter/material.dart';
import 'package:testlearn/Providers/movie_provider.dart';
import 'package:provider/provider.dart';
import 'package:testlearn/Widgets/movie_details.dart';


class MovieGrid extends StatelessWidget {
  final String category;
  final String? query;

  const MovieGrid({Key? key, required this.category, this.query}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      movieProvider.resetMovies();
      if (category == "search" && query != null) {
        movieProvider.fetchMoviesByQuery(query!);
      } else {
        movieProvider.fetchMovies(category.toLowerCase());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(category == "search" ? "Search Results" : category),
        centerTitle: true,
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, _) {
          if (provider.movies.isEmpty && !provider.isLoading) {
            return const Center(
              child: Text("No results found."),
            );
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && provider.hasMore) {
                if (category == "search" && query != null) {
                  provider.fetchMoviesByQuery(query!);
                } else {
                  provider.fetchMovies(category.toLowerCase());
                }
              }
              return false;
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1.5,
                ),
                itemCount: provider.movies.length + (provider.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= provider.movies.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final movie = provider.movies[index];
                  final isFavorite = provider.isFavorite(movie.id);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MovieDetails(movie: movie)),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey, width: 1.5, style: BorderStyle.solid),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                            child: Image.network(
                              movie.posterUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                    size: 50,
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(movie.releaseDate),
                                  Spacer(),
                                  Text('${movie.voteAverage} ⭐'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
