import 'package:flutter/material.dart';
import 'package:flutter_introductory_workshop/store.dart';

import 'screens.dart';

class App extends StatefulWidget {
  const App({Key? key, required this.store}) : super(key: key);

  final Store store;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static const String title = 'Winery';

  @override
  void dispose() {
    widget.store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      StoreProvider(store: widget.store, child: const MaterialApp(title: title, home: HomePage(title: title)));
}
