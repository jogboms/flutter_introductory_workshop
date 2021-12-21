import 'package:flutter_introductory_workshop/domain.dart';

class WineRepositoryImpl implements WineRepository {
  @override
  Future<void> add(Wine wine) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<void> remove(String id) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  Future<Wine> update(String id, {String? name, String? imagePath, int? year, int? rating}) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
