import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/food_delivery/domain/usecases/get_restaurants.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockFoodDeliveryRepository mockRepository;
  late GetRestaurants useCase;

  setUp(() {
    mockRepository = MockFoodDeliveryRepository();
    useCase = GetRestaurants(mockRepository);
  });

  group('GetRestaurants', () {
    test('delegates to repository.getRestaurants', () async {
      when(() => mockRepository.getRestaurants())
          .thenAnswer((_) async => [tRestaurant, tRestaurant2]);

      final result = await useCase();

      expect(result, [tRestaurant, tRestaurant2]);
      verify(() => mockRepository.getRestaurants()).called(1);
    });

    test('propagates error from repository', () async {
      when(() => mockRepository.getRestaurants())
          .thenThrow(Exception('Network error'));

      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });
}
