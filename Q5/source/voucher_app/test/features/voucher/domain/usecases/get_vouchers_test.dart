import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:voucher_app/features/voucher/domain/usecases/get_vouchers.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockVoucherRepository mockRepository;
  late GetVouchers useCase;

  setUp(() {
    mockRepository = MockVoucherRepository();
    useCase = GetVouchers(mockRepository);
  });

  group('GetVouchers', () {
    test('delegates to repository.getVouchers', () {
      when(() => mockRepository.getVouchers()).thenReturn(tAllVouchers);

      final result = useCase();

      expect(result, tAllVouchers);
      verify(() => mockRepository.getVouchers()).called(1);
    });

    test('returns empty list when no vouchers', () {
      when(() => mockRepository.getVouchers()).thenReturn([]);

      final result = useCase();

      expect(result, isEmpty);
    });
  });
}
