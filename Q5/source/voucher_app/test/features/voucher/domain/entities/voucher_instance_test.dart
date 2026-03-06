import 'package:flutter_test/flutter_test.dart';
import 'package:voucher_app/features/voucher/domain/entities/voucher_instance.dart';

import '../../../../helpers/test_fixtures.dart';

void main() {
  group('VoucherInstance', () {
    test('equality compares all props', () {
      const a = VoucherInstance(
        id: 'v2_1',
        amount: 2,
        displayNumber: '#8812',
      );
      expect(a, equals(tVoucher1));
    });

    test('copyWith toggles isSelected to true', () {
      final selected = tVoucher1.copyWith(isSelected: true);
      expect(selected.isSelected, true);
      expect(selected.id, tVoucher1.id);
      expect(selected.amount, tVoucher1.amount);
      expect(selected.displayNumber, tVoucher1.displayNumber);
    });

    test('copyWith toggles isSelected to false', () {
      final deselected = tSelectedVoucher1.copyWith(isSelected: false);
      expect(deselected.isSelected, false);
      expect(deselected.id, tSelectedVoucher1.id);
    });

    test('props includes all fields', () {
      expect(tVoucher1.props, ['v2_1', 2, '#8812', false]);
      expect(tSelectedVoucher1.props, ['v2_1', 2, '#8812', true]);
    });
  });
}
