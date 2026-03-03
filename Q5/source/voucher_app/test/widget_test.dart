import 'package:flutter_test/flutter_test.dart';

import 'package:voucher_app/app.dart';
import 'package:voucher_app/di/injection.dart';

void main() {
  testWidgets('App renders voucher list screen', (WidgetTester tester) async {
    configureDependencies();
    await tester.pumpWidget(const App());

    expect(find.text('Vouchers'), findsOneWidget);
  });
}
