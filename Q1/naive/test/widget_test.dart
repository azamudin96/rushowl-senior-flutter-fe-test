import 'package:flutter_test/flutter_test.dart';

import 'package:naive/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(NaiveApp());
    expect(find.text('Naive Image List'), findsOneWidget);
  });
}
