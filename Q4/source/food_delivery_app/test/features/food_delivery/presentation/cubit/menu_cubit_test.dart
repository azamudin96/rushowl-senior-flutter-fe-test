import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/food_delivery/presentation/cubit/menu_cubit.dart';
import 'package:food_delivery_app/features/food_delivery/presentation/cubit/menu_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockGetMenuItems mockGetMenuItems;

  setUp(() {
    mockGetMenuItems = MockGetMenuItems();
  });

  group('MenuCubit', () {
    test('initial state is MenuInitial', () {
      final cubit = MenuCubit(mockGetMenuItems);
      expect(cubit.state, isA<MenuInitial>());
      cubit.close();
    });

    blocTest<MenuCubit, MenuState>(
      'emits [Loading, Loaded] on successful loadMenu',
      build: () {
        when(() => mockGetMenuItems('r1'))
            .thenAnswer((_) async => [tMenuItem, tMenuItem2]);
        return MenuCubit(mockGetMenuItems);
      },
      act: (cubit) => cubit.loadMenu(tRestaurant),
      expect: () => [
        isA<MenuLoading>(),
        isA<MenuLoaded>()
            .having((s) => s.items, 'items', [tMenuItem, tMenuItem2])
            .having((s) => s.restaurant, 'restaurant', tRestaurant),
      ],
    );

    blocTest<MenuCubit, MenuState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => mockGetMenuItems('r1'))
            .thenThrow(Exception('Network error'));
        return MenuCubit(mockGetMenuItems);
      },
      act: (cubit) => cubit.loadMenu(tRestaurant),
      expect: () => [
        isA<MenuLoading>(),
        isA<MenuError>(),
      ],
    );

    blocTest<MenuCubit, MenuState>(
      'passes correct restaurantId to use case',
      build: () {
        when(() => mockGetMenuItems('r2')).thenAnswer((_) async => []);
        return MenuCubit(mockGetMenuItems);
      },
      act: (cubit) => cubit.loadMenu(tRestaurant2),
      verify: (_) {
        verify(() => mockGetMenuItems('r2')).called(1);
        verifyNever(() => mockGetMenuItems('r1'));
      },
    );
  });
}
