import 'package:flutter_test/flutter_test.dart';

import 'package:food_delivery_app/app.dart';
import 'package:food_delivery_app/di/injection.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    setupDependencies();
    await tester.pumpWidget(const FoodDeliveryApp());
    expect(find.text('Food Delivery'), findsOneWidget);
  });
}
