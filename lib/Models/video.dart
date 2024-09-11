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