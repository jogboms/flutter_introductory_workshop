class Wine {
  const Wine({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.year,
    required this.rating,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String imagePath;
  final int year;
  final int rating;
  final DateTime createdAt;

  @override
  bool operator ==(covariant Wine other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          imagePath == other.imagePath &&
          year == other.year &&
          rating == other.rating &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ imagePath.hashCode ^ year.hashCode ^ rating.hashCode ^ createdAt.hashCode;

  @override
  String toString() =>
      'Wine{id: $id, name: $name, imagePath: $imagePath, year: $year, rating: $rating, createdAt: $createdAt}';
}
