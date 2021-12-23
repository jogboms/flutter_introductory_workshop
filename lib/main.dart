import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data.dart';
import 'domain.dart';
import 'store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CameraService.initialize();

  await Hive.initFlutter();
  Hive.registerAdapter(WineRepositoryHiveImpl.adapter);
  await Hive.openBox<Wine>(WineRepositoryHiveImpl.boxName);
  final WineRepository repository = WineRepositoryHiveImpl(Hive.box<Wine>(WineRepositoryHiveImpl.boxName));

  final Store store = Store(repository);
  await store.initialize();

  runApp(App(store: store));
}
