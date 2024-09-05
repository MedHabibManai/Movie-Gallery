import 'package:flutter/material.dart';
import 'package:testlearn/models.dart';
import 'package:testlearn/movie_provider.dart';
import 'package:testlearn/ActorProvider.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter_youtube_view/flutter_youtube_view.dart';
import 'package:testlearn/ReviewProvider.dart';

class HomePageItem extends StatelessWidget {
  final String text;

  final EdgeInsetsGeometry padding;
  final VoidCallback onTap;
  const HomePageItem({required this.text, this.padding = const EdgeInsets.only(right: 8), required this.onTap} );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:onTap,
      child: Padding(
        padding: padding,
        child: Container(
          color: Colors.green,
          height: 300,
          width: 400,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
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
class ActorDetails extends StatelessWidget {
  final Actor actor;

  const ActorDetails({Key? key, required this.actor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actorProvider = Provider.of<ActorProvider>(context, listen: false);

    // Fetch actor details and movies for this actor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      actorProvider.fetchActorDetails(actor.id);
      actorProvider.fetchMoviesByActor(actor.id);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(actor.name),
        centerTitle: true,
      ),
      body: Consumer<ActorProvider>(
        builder: (context, actorProvider, _) {
          if (actorProvider.isLoadingMovies || actorProvider.selectedActor == null) {
            return Center(child: CircularProgressIndicator());
          }

          final detailedActor = actorProvider.selectedActor!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: NetworkImage(detailedActor.profileUrl),
                      onBackgroundImageError: (_, __) {},
                      child: detailedActor.profileUrl.isEmpty
                          ? Icon(Icons.person, size: 80) // Placeholder for no image
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    detailedActor.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detailedActor.biography ?? 'Biography not available.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Movies:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (actorProvider.actorMovies.isEmpty)
                    const Center(child: Text("No movies found."))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: actorProvider.actorMovies.length,
                      itemBuilder: (context, index) {
                        final movie = actorProvider.actorMovies[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetails(movie: movie),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: Image.network(
                              movie.posterUrl,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.movie, size: 50); // Placeholder for movie image
                              },
                            ),
                            title: Text(movie.title),
                            subtitle: Text('Release Date: ${movie.releaseDate}'),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
