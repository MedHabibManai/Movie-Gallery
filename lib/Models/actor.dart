
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