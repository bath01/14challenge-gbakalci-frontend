class MusicCategory {
  final int id;
  final String name;
  final int trackCount;

  const MusicCategory({
    required this.id,
    required this.name,
    required this.trackCount,
  });

  factory MusicCategory.fromJson(Map<String, dynamic> json) {
    return MusicCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      trackCount: json['trackCount'] as int? ?? 0,
    );
  }

  @override
  String toString() => 'MusicCategory(id: $id, name: $name, trackCount: $trackCount)';
}