import 'package:flutter/widgets.dart';

import 'store.dart';

class StoreProvider extends InheritedWidget {
  const StoreProvider({Key? key, required this.store, required Widget child}) : super(key: key, child: child);

  final Store store;

  static Store of(BuildContext context) {
    final StoreProvider? result = context.dependOnInheritedWidgetOfExactType<StoreProvider>();
    assert(result != null, 'No StoreProvider found in context');
    return result!.store;
  }

  @override
  bool updateShouldNotify(StoreProvider oldWidget) => store != oldWidget.store;
}

extension StoreProviderExtension on BuildContext {
  Store get store => StoreProvider.of(this);
}
