import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/restaurant.dart';
import '../../domain/usecases/get_menu_items.dart';
import 'menu_state.dart';

class MenuCubit extends Cubit<MenuState> {
  final GetMenuItems _getMenuItems;

  MenuCubit(this._getMenuItems) : super(const MenuInitial());

  Future<void> loadMenu(Restaurant restaurant) async {
    emit(const MenuLoading());
    try {
      final items = await _getMenuItems(restaurant.id);
      emit(MenuLoaded(restaurant: restaurant, items: items));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }
}
