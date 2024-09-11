
import 'package:flutter/material.dart';
import 'package:testlearn/Providers/movie_provider.dart';
import 'package:testlearn/Providers/actor_provider.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:testlearn/Providers/review_provider.dart';
import 'package:testlearn/Models/movie.dart';
import 'package:testlearn/Widgets/actor_details.dart';


class MovieDetails extends StatefulWidget {
  final Movie movie;

  const MovieDetails({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieDetailsState createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final actorProvider = Provider.of<ActorProvider>(context, listen: false);
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    // Fetch actors, videos, and reviews when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      actorProvider.resetActors();
      actorProvider.fetchActors(widget.movie.id);
      movieProvider.fetchMovieVideos(widget.movie.id); // Fetch videos
      reviewProvider.fetchReviews(widget.movie.id); // Fetch reviews
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
        centerTitle: true,
      ),
      body: Consumer3<ActorProvider, MovieProvider, ReviewProvider>(
        builder: (context, actorProvider, movieProvider, reviewProvider, _) {
          final isFavorite = movieProvider.isFavorite(widget.movie.id);

          if (actorProvider.isLoading || movieProvider.isVideoLoading || reviewProvider.isLoading) {
            // Show loading spinner if any provider is loading
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      widget.movie.posterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 300,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 100,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: FloatingActionButton(
                        backgroundColor: isFavorite ? Colors.red : Colors.green,
                        onPressed: () {
                          if (isFavorite) {
                            movieProvider.removeFromFavorites(widget.movie);
                          } else {
                            movieProvider.addToFavorites(widget.movie);
                          }
                        },
                        child: Icon(
                          isFavorite ? Icons.remove : Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movie.title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rating: ${widget.movie.voteAverage} ⭐',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Release Date: ${widget.movie.releaseDate}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.movie.overview, // Overview of the movie
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Actors:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (actorProvider.actors.isEmpty)
                        const Center(child: Text("No actors found."))
                      else
                        SizedBox(
                          height: 200, // Set a fixed height for the horizontal list
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: actorProvider.actors.length,
                            itemBuilder: (context, index) {
                              final actor = actorProvider.actors[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ActorDetails(actor: actor),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: NetworkImage(actor.profileUrl),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        actor.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        actor.character,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'Trailer:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (movieProvider.videos.isEmpty)
                        const Center(child: Text("No trailers available."))
                      else
                        SizedBox(
                          height: 200,
                          child: WebViewWidget(
                            controller: _webViewController
                              ..loadRequest(Uri.parse('https://www.youtube.com/embed/${movieProvider.videos.first.key}')),
                          ),
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'Reviews:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (reviewProvider.reviews.isEmpty)
                        const Center(child: Text("No reviews available."))
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviewProvider.reviews.length > 10
                              ? 10
                              : reviewProvider.reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviewProvider.reviews[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(review.avatarUrl),
                              ),
                              title: Text(review.author),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (review.rating != null)
                                    Text('Rating: ${review.rating} ⭐'),
                                  const SizedBox(height: 4),
                                  Text(review.content),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}