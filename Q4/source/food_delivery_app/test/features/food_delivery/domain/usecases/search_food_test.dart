import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/food_delivery/domain/usecases/search_food.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockFoodDeliveryRepository mockRepository;
  late SearchFood useCase;

  setUp(() {
    mockRepository = MockFoodDeliveryRepository();
    useCase = SearchFood(mockRepository);
  });

  group('SearchFood', () {
    test('calls searchRestaurants and searchAllMenuItems concurrently',
        () async {
      when(() => mockRepository.searchRestaurants('pizza'))
          .thenAnswer((_) async => [tRestaurant]);
      when(() => mockRepository.searchAllMenuItems('pizza'))
          .thenAnswer((_) async => [tMenuItem]);

      final (restaurants, menuItems) = await useCase('pizza');

      expect(restaurants, [tRestaurant]);
      expect(menuItems, [tMenuItem]);
      verify(() => mockRepository.searchRestaurants('pizza')).called(1);
      verify(() => mockRepository.searchAllMenuItems('pizza')).called(1);
    });

    test('propagates error from repository', () async {
      when(() => mockRepository.searchRestaurants(any()))
          .thenThrow(Exception('Network error'));
      when(() => mockRepository.searchAllMenuItems(any()))
          .thenAnswer((_) async => []);

      expect(() => useCase('pizza'), throwsA(isA<Exception>()));
    });
  });
}
