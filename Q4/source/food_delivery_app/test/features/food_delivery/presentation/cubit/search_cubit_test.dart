import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/food_delivery/presentation/cubit/search_cubit.dart';
import 'package:food_delivery_app/features/food_delivery/presentation/cubit/search_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockSearchFood mockSearchFood;
  late MockGetRestaurants mockGetRestaurants;
  late SearchCubit cubit;

  setUp(() {
    mockSearchFood = MockSearchFood();
    mockGetRestaurants = MockGetRestaurants();
  });

  tearDown(() => cubit.close());

  group('SearchCubit', () {
    test('loadSuggestions emits SearchInitial with top-rated restaurants',
        () async {
      when(() => mockGetRestaurants())
          .thenAnswer((_) async => [tRestaurant2, tRestaurant]);
      cubit = SearchCubit(mockSearchFood, mockGetRestaurants);

      await cubit.loadSuggestions();

      final state = cubit.state as SearchInitial;
      // sorted by rating desc, take 2: tRestaurant (4.5) then tRestaurant2 (4.0)
      expect(state.suggestions, [tRestaurant, tRestaurant2]);
    });

    test('search debounces by 300ms', () {
      fakeAsync((async) {
        when(() => mockGetRestaurants())
            .thenAnswer((_) async => [tRestaurant]);
        when(() => mockSearchFood('pizza'))
            .thenAnswer((_) async => ([tRestaurant], [tMenuItem]));
        cubit = SearchCubit(mockSearchFood, mockGetRestaurants);

        cubit.search('pizza');

        // Before 300ms — search should NOT have been called
        async.elapse(const Duration(milliseconds: 200));
        verifyNever(() => mockSearchFood('pizza'));

        // After 300ms — search should be called
        async.elapse(const Duration(milliseconds: 100));
        async.flushMicrotasks();
        verify(() => mockSearchFood('pizza')).called(1);
      });
    });

    test('rapid calls cancel previous debounce', () {
      fakeAsync((async) {
        when(() => mockGetRestaurants())
            .thenAnswer((_) async => [tRestaurant]);
        when(() => mockSearchFood('pasta'))
            .thenAnswer((_) async => ([tRestaurant], [tMenuItem2]));
        cubit = SearchCubit(mockSearchFood, mockGetRestaurants);

        cubit.search('piz');
        async.elapse(const Duration(milliseconds: 100));
        cubit.search('pasta');
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();

        // Only 'pasta' should be searched, 'piz' was cancelled
        verifyNever(() => mockSearchFood('piz'));
        verify(() => mockSearchFood('pasta')).called(1);
      });
    });

    test('empty query calls loadSuggestions instead of search', () {
      fakeAsync((async) {
        when(() => mockGetRestaurants())
            .thenAnswer((_) async => [tRestaurant]);
        cubit = SearchCubit(mockSearchFood, mockGetRestaurants);

        cubit.search('   ');
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();

        verifyNever(() => mockSearchFood(any()));
        // loadSuggestions should have been called
        verify(() => mockGetRestaurants()).called(1);
      });
    });

    test('recentSearches stores queries', () {
      fakeAsync((async) {
        when(() => mockGetRestaurants())
            .thenAnswer((_) async => [tRestaurant]);
        when(() => mockSearchFood('pizza'))
            .thenAnswer((_) async => ([tRestaurant], [tMenuItem]));
        cubit = SearchCubit(mockSearchFood, mockGetRestaurants);

        cubit.search('pizza');
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();

        expect(cubit.recentSearches, contains('pizza'));
      });
    });

    test('clearSearch cancels debounce and loads suggestions', () async {
      when(() => mockGetRestaurants())
          .thenAnswer((_) async => [tRestaurant]);
      cubit = SearchCubit(mockSearchFood, mockGetRestaurants);

      cubit.clearSearch();
      await Future<void>.delayed(Duration.zero);

      verify(() => mockGetRestaurants()).called(1);
    });

    test('loadSuggestions emits SearchError on failure', () async {
      when(() => mockGetRestaurants()).thenThrow(Exception('fail'));
      cubit = SearchCubit(mockSearchFood, mockGetRestaurants);

      await cubit.loadSuggestions();

      expect(cubit.state, isA<SearchError>());
    });

    test('close cancels debounce timer', () async {
      when(() => mockGetRestaurants())
          .thenAnswer((_) async => [tRestaurant]);
      cubit = SearchCubit(mockSearchFood, mockGetRestaurants);

      cubit.search('pizza');
      await cubit.close();

      expect(cubit.isClosed, true);
      verifyNever(() => mockSearchFood(any()));
    });
  });
}
