import 'package:flutter_test/flutter_test.dart';

import 'package:optimised/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const OptimisedApp());
    expect(find.text('Optimised Image List'), findsOneWidget);
  });
}
