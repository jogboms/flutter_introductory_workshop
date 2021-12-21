import 'package:flutter/material.dart';
import 'package:flutter_introductory_workshop/data.dart';
import 'package:flutter_introductory_workshop/store.dart';

import 'screens.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Store store = Store(WineRepositoryImpl());

  @override
  Widget build(BuildContext context) =>
      StoreProvider(store: store, child: MaterialApp(title: 'Winery', theme: ThemeData.dark(), home: const HomePage()));
}
