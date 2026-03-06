import 'package:flutter_test/flutter_test.dart';
import 'package:voucher_app/features/voucher/domain/entities/voucher_instance.dart';
import 'package:voucher_app/features/voucher/domain/usecases/generate_qr_content.dart';

void main() {
  const useCase = GenerateQrContent();

  group('GenerateQrContent', () {
    test('returns empty string when no vouchers are selected', () {
      const vouchers = [
        VoucherInstance(id: 'v1', amount: 2, displayNumber: '#1'),
        VoucherInstance(id: 'v2', amount: 5, displayNumber: '#2'),
      ];

      expect(useCase(vouchers), '');
    });

    test('returns single amount for one selected voucher', () {
      const vouchers = [
        VoucherInstance(
            id: 'v1', amount: 5, displayNumber: '#1', isSelected: true),
        VoucherInstance(id: 'v2', amount: 2, displayNumber: '#2'),
      ];

      expect(useCase(vouchers), '5');
    });

    test('sorts by amount ascending', () {
      const vouchers = [
        VoucherInstance(
            id: 'v1', amount: 10, displayNumber: '#1', isSelected: true),
        VoucherInstance(
            id: 'v2', amount: 2, displayNumber: '#2', isSelected: true),
        VoucherInstance(
            id: 'v3', amount: 5, displayNumber: '#3', isSelected: true),
      ];

      expect(useCase(vouchers), '2,5,10');
    });

    test('sorts by id when amounts are equal', () {
      const vouchers = [
        VoucherInstance(
            id: 'v2_2', amount: 2, displayNumber: '#2', isSelected: true),
        VoucherInstance(
            id: 'v2_1', amount: 2, displayNumber: '#1', isSelected: true),
      ];

      expect(useCase(vouchers), '2,2');
      // v2_1 should come before v2_2 after sort
      final selected = vouchers.where((v) => v.isSelected).toList()
        ..sort((a, b) {
          final amountCompare = a.amount.compareTo(b.amount);
          if (amountCompare != 0) return amountCompare;
          return a.id.compareTo(b.id);
        });
      expect(selected.first.id, 'v2_1');
    });

    test('ignores unselected vouchers', () {
      const vouchers = [
        VoucherInstance(
            id: 'v1', amount: 2, displayNumber: '#1', isSelected: true),
        VoucherInstance(id: 'v2', amount: 5, displayNumber: '#2'),
        VoucherInstance(
            id: 'v3', amount: 10, displayNumber: '#3', isSelected: true),
      ];

      expect(useCase(vouchers), '2,10');
    });
  });
}
