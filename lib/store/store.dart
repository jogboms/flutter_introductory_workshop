import 'package:flutter/foundation.dart';
import 'package:flutter_introductory_workshop/domain.dart';

class Store with ChangeNotifier {
  Store(this.repository);

  final WineRepository repository;
}
