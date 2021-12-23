import 'package:flutter/foundation.dart';
import 'package:flutter_introductory_workshop/domain.dart';
import 'package:uuid/uuid.dart';

class Store with ChangeNotifier {
  Store(this._repository);

  final WineRepository _repository;

  List<Wine> get items => _items.values.toList(growable: false);
  final Map<String, Wine> _items = <String, Wine>{};

  Future<List<Wine>> initialize() async {
    try {
      final List<Wine> items = await _repository.fetchAll();
      _items.addEntries(items.map((Wine item) => MapEntry<String, Wine>(item.id, item)).toList(growable: false));
      notifyListeners();
      return items;
    } catch (e) {
      return <Wine>[];
    }
  }

  Wine? get(String id) => _items[id];

  Future<String?> add() async {
    final Wine wine = Wine(
      id: const Uuid().v4(),
      imagePath: '',
      name: '',
      rating: 0,
      year: 0,
      createdAt: DateTime.now(),
    );
    try {
      await _repository.add(wine);
      _items.putIfAbsent(wine.id, () => wine);
      notifyListeners();
      return wine.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> remove(String id) async {
    try {
      await _repository.remove(id);
      _items.removeWhere((String wineId, _) => wineId == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> update(String id, {String? name, String? imagePath, int? year, int? rating}) async {
    try {
      final Wine wine = await _repository.update(id, name: name, imagePath: imagePath, year: year, rating: rating);
      _items.update(id, (_) => wine);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
