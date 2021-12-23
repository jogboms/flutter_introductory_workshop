import 'package:flutter_introductory_workshop/domain.dart';
import 'package:hive/hive.dart';

class WineRepositoryHiveImpl implements WineRepository {
  WineRepositoryHiveImpl(this._box);

  static const String boxName = 'wine1';
  static final TypeAdapter<Wine> adapter = _WineHiveAdapter();

  final Box<Wine> _box;

  @override
  Future<List<Wine>> fetchAll() async => _box.values.toList();

  @override
  Future<void> add(Wine wine) async => _box.put(wine.id, wine);

  @override
  Future<void> remove(String id) async => _box.delete(id);

  @override
  Future<Wine> update(String id, {String? name, String? imagePath, int? year, int? rating}) async {
    final Wine wine = _box.get(id)!.copyWith(name: name, imagePath: imagePath, year: year, rating: rating);
    await _box.put(id, wine);
    return wine;
  }
}

class WineRepositoryMemoryImpl implements WineRepository {
  final Map<String, Wine> _items = <String, Wine>{};

  @override
  Future<List<Wine>> fetchAll() async => _items.values.toList(growable: false);

  @override
  Future<void> add(Wine wine) async => _items.putIfAbsent(wine.id, () => wine);

  @override
  Future<void> remove(String id) async => _items.removeWhere((String wineId, _) => wineId == id);

  @override
  Future<Wine> update(String id, {String? name, String? imagePath, int? year, int? rating}) async =>
      _items.update(id, (Wine wine) => wine.copyWith(name: name, imagePath: imagePath, year: year, rating: rating));
}

class _WineHiveAdapter extends TypeAdapter<Wine> {
  @override
  final int typeId = 0;

  @override
  Wine read(BinaryReader reader) {
    final Map<dynamic, dynamic> json = reader.readMap();
    return Wine(
      id: json['id'].toString(),
      name: json['name'].toString(),
      year: int.parse(json['year'].toString()),
      rating: int.parse(json['rating'].toString()),
      imagePath: json['image_path'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  @override
  void write(BinaryWriter writer, Wine obj) => writer.writeMap(<String, dynamic>{
        'id': obj.id,
        'name': obj.name,
        'image_path': obj.imagePath,
        'year': obj.year,
        'rating': obj.rating,
        'created_at': obj.createdAt,
      });
}
