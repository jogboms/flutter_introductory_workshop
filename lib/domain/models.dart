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

  Wine copyWith({String? name, String? imagePath, int? year, int? rating}) => Wine(
        id: id,
        name: name ?? this.name,
        imagePath: imagePath ?? this.imagePath,
        year: year ?? this.year,
        rating: rating ?? this.rating,
        createdAt: createdAt,
      );

  bool get isNotComplete => name.isEmpty || year == 0;

  bool get isEmpty => name.isEmpty && imagePath.isEmpty && year == 0;

  @override
  String toString() =>
      'Wine{id: $id, name: $name, imagePath: $imagePath, year: $year, rating: $rating, createdAt: $createdAt}';
}

enum SortType { none, name, rating, year, createdAt }

extension SortTypeExtension on SortType {
  String get displayName => <SortType, String>{
        SortType.none: 'None',
        SortType.name: 'Name',
        SortType.rating: 'Rating',
        SortType.year: 'Year',
        SortType.createdAt: 'Created Date',
      }[this]!;
}
