import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/food_delivery/presentation/cubit/restaurant_list_cubit.dart';
import 'package:food_delivery_app/features/food_delivery/presentation/cubit/restaurant_list_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockGetRestaurants mockGetRestaurants;

  setUp(() {
    mockGetRestaurants = MockGetRestaurants();
  });

  group('RestaurantListCubit', () {
    test('initial state is RestaurantListInitial', () {
      final cubit = RestaurantListCubit(mockGetRestaurants);
      expect(cubit.state, isA<RestaurantListInitial>());
      cubit.close();
    });

    blocTest<RestaurantListCubit, RestaurantListState>(
      'emits [Loading, Loaded] on successful loadRestaurants',
      build: () {
        when(() => mockGetRestaurants())
            .thenAnswer((_) async => [tRestaurant, tRestaurant2]);
        return RestaurantListCubit(mockGetRestaurants);
      },
      act: (cubit) => cubit.loadRestaurants(),
      expect: () => [
        isA<RestaurantListLoading>(),
        isA<RestaurantListLoaded>().having(
          (s) => s.restaurants,
          'restaurants',
          [tRestaurant, tRestaurant2],
        ),
      ],
    );

    blocTest<RestaurantListCubit, RestaurantListState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => mockGetRestaurants())
            .thenThrow(Exception('Network error'));
        return RestaurantListCubit(mockGetRestaurants);
      },
      act: (cubit) => cubit.loadRestaurants(),
      expect: () => [
        isA<RestaurantListLoading>(),
        isA<RestaurantListError>(),
      ],
    );

    blocTest<RestaurantListCubit, RestaurantListState>(
      'emits Loaded with empty list when no restaurants',
      build: () {
        when(() => mockGetRestaurants()).thenAnswer((_) async => []);
        return RestaurantListCubit(mockGetRestaurants);
      },
      act: (cubit) => cubit.loadRestaurants(),
      expect: () => [
        isA<RestaurantListLoading>(),
        isA<RestaurantListLoaded>().having(
          (s) => s.restaurants,
          'restaurants',
          isEmpty,
        ),
      ],
    );
  });
}
