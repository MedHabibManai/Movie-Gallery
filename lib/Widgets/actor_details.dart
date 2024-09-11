import 'package:flutter/material.dart';
import 'package:testlearn/Providers/actor_provider.dart';
import 'package:provider/provider.dart';
import 'package:testlearn/Widgets/movie_details.dart';
import'package:testlearn/Models/actor.dart';
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