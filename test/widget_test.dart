import 'package:flutter_test/flutter_test.dart';
import 'package:burning2026/app/app.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BurnCenterApp());
    expect(find.byType(BurnCenterApp), findsOneWidget);
  });
}