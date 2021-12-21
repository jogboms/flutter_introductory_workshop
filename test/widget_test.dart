import 'package:flutter_introductory_workshop/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Hello world'), findsOneWidget);
  });
}
