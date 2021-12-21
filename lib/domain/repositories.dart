import 'models.dart';

abstract class WineRepository {
  Future<void> add(Wine wine);

  Future<Wine> update(String id, {String? name, String? imagePath, int? year, int? rating});

  Future<void> remove(String id);
}
