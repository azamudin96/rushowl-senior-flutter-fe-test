import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/food_delivery/domain/usecases/get_order_history.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockFoodDeliveryRepository mockRepository;
  late GetOrderHistory useCase;

  setUp(() {
    mockRepository = MockFoodDeliveryRepository();
    useCase = GetOrderHistory(mockRepository);
  });

  group('GetOrderHistory', () {
    test('delegates to repository.getOrderHistory', () async {
      when(() => mockRepository.getOrderHistory())
          .thenAnswer((_) async => [tOrderHistoryItem]);

      final result = await useCase();

      expect(result, [tOrderHistoryItem]);
      verify(() => mockRepository.getOrderHistory()).called(1);
    });

    test('propagates error from repository', () async {
      when(() => mockRepository.getOrderHistory())
          .thenThrow(Exception('Network error'));

      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });
}
