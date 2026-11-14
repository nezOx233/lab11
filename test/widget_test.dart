import 'package:flutter_test/flutter_test.dart';
import 'package:lab11/main.dart';

void main() {
  testWidgets('Початковий екран відкривається', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Мій магазин'), findsOneWidget);
    expect(find.text('Завантажити дані'), findsOneWidget);
  });
}
