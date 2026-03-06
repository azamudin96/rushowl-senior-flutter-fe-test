import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/food_delivery/domain/usecases/get_menu_items.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockFoodDeliveryRepository mockRepository;
  late GetMenuItems useCase;

  setUp(() {
    mockRepository = MockFoodDeliveryRepository();
    useCase = GetMenuItems(mockRepository);
  });

  group('GetMenuItems', () {
    test('delegates to repository.getMenuItems with restaurantId', () async {
      when(() => mockRepository.getMenuItems('r1'))
          .thenAnswer((_) async => [tMenuItem, tMenuItem2]);

      final result = await useCase('r1');

      expect(result, [tMenuItem, tMenuItem2]);
      verify(() => mockRepository.getMenuItems('r1')).called(1);
    });

    test('propagates error from repository', () async {
      when(() => mockRepository.getMenuItems(any()))
          .thenThrow(Exception('Network error'));

      expect(() => useCase('r1'), throwsA(isA<Exception>()));
    });
  });
}
