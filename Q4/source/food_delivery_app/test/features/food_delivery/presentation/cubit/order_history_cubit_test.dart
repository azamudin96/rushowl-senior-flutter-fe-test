import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/food_delivery/domain/entities/order_history_item.dart';
import 'package:food_delivery_app/features/food_delivery/presentation/cubit/order_history_cubit.dart';
import 'package:food_delivery_app/features/food_delivery/presentation/cubit/order_history_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockGetOrderHistory mockGetOrderHistory;

  setUp(() {
    mockGetOrderHistory = MockGetOrderHistory();
  });

  group('OrderHistoryCubit', () {
    test('initial state is OrderHistoryInitial', () {
      final cubit = OrderHistoryCubit(mockGetOrderHistory);
      expect(cubit.state, isA<OrderHistoryInitial>());
      cubit.close();
    });

    blocTest<OrderHistoryCubit, OrderHistoryState>(
      'splits active and past orders on load',
      build: () {
        when(() => mockGetOrderHistory()).thenAnswer(
          (_) async => [tOrderHistoryItem, tActiveOrderHistoryItem],
        );
        return OrderHistoryCubit(mockGetOrderHistory);
      },
      act: (cubit) => cubit.loadOrders(),
      expect: () => [
        isA<OrderHistoryLoading>(),
        isA<OrderHistoryLoaded>()
            .having(
              (s) => s.activeOrders,
              'activeOrders',
              [tActiveOrderHistoryItem],
            )
            .having(
              (s) => s.pastOrders,
              'pastOrders',
              [tOrderHistoryItem],
            ),
      ],
    );

    blocTest<OrderHistoryCubit, OrderHistoryState>(
      'empty active orders when all are past',
      build: () {
        when(() => mockGetOrderHistory()).thenAnswer(
          (_) async => [tOrderHistoryItem],
        );
        return OrderHistoryCubit(mockGetOrderHistory);
      },
      act: (cubit) => cubit.loadOrders(),
      expect: () => [
        isA<OrderHistoryLoading>(),
        isA<OrderHistoryLoaded>()
            .having((s) => s.activeOrders, 'activeOrders', isEmpty)
            .having((s) => s.pastOrders, 'pastOrders', [tOrderHistoryItem]),
      ],
    );

    blocTest<OrderHistoryCubit, OrderHistoryState>(
      'empty past orders when all are active',
      build: () {
        when(() => mockGetOrderHistory()).thenAnswer(
          (_) async => [tActiveOrderHistoryItem],
        );
        return OrderHistoryCubit(mockGetOrderHistory);
      },
      act: (cubit) => cubit.loadOrders(),
      expect: () => [
        isA<OrderHistoryLoading>(),
        isA<OrderHistoryLoaded>()
            .having(
              (s) => s.activeOrders,
              'activeOrders',
              [tActiveOrderHistoryItem],
            )
            .having((s) => s.pastOrders, 'pastOrders', isEmpty),
      ],
    );

    blocTest<OrderHistoryCubit, OrderHistoryState>(
      'emits error on failure',
      build: () {
        when(() => mockGetOrderHistory())
            .thenThrow(Exception('Network error'));
        return OrderHistoryCubit(mockGetOrderHistory);
      },
      act: (cubit) => cubit.loadOrders(),
      expect: () => [
        isA<OrderHistoryLoading>(),
        isA<OrderHistoryError>(),
      ],
    );
  });
}
