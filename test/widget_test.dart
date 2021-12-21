import 'package:flutter_introductory_workshop/app.dart';
import 'package:flutter_introductory_workshop/data.dart';
import 'package:flutter_introductory_workshop/store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(App(
      store: Store(WineRepositoryMemoryImpl()),
    ));

    expect(find.text('Winery'), findsOneWidget);
  });
}
