import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order_history_item.dart';
import '../../domain/usecases/get_order_history.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final GetOrderHistory _getOrderHistory;

  OrderHistoryCubit(this._getOrderHistory)
      : super(const OrderHistoryInitial());

  Future<void> loadOrders() async {
    emit(const OrderHistoryLoading());
    try {
      final orders = await _getOrderHistory();
      final active = orders
          .where((o) => o.status == OrderHistoryStatus.inProgress)
          .toList();
      final past = orders
          .where((o) => o.status != OrderHistoryStatus.inProgress)
          .toList();
      emit(OrderHistoryLoaded(activeOrders: active, pastOrders: past));
    } catch (e) {
      emit(OrderHistoryError(e.toString()));
    }
  }
}
