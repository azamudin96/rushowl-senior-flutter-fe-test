import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/restaurant.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addItem(MenuItem menuItem, Restaurant restaurant) {
    final existingIndex = state.items.indexWhere(
      (item) => item.menuItem.id == menuItem.id,
    );

    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      emit(state.copyWith(items: updatedItems));
    } else {
      emit(state.copyWith(
        items: [...state.items, CartItem(menuItem: menuItem, quantity: 1)],
        restaurant: () => restaurant,
      ));
    }
  }

  void removeItem(String menuItemId) {
    final updatedItems = state.items
        .where((item) => item.menuItem.id != menuItemId)
        .toList();
    if (updatedItems.isEmpty) {
      emit(state.copyWith(
        items: updatedItems,
        restaurant: () => null,
      ));
    } else {
      emit(state.copyWith(items: updatedItems));
    }
  }

  void updateQuantity(String menuItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(menuItemId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.menuItem.id == menuItemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    emit(state.copyWith(items: updatedItems));
  }

  void clearCart() {
    emit(const CartState());
  }
}
