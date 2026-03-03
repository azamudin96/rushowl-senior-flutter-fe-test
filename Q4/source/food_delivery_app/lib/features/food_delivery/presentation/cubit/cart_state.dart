import 'package:equatable/equatable.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/entities/restaurant.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final Restaurant? restaurant;

  const CartState({
    this.items = const [],
    this.restaurant,
  });

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  double get deliveryFee => restaurant?.deliveryFee ?? 0;

  double get total => subtotal + deliveryFee;

  int get itemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    Restaurant? Function()? restaurant,
  }) {
    return CartState(
      items: items ?? this.items,
      restaurant: restaurant != null ? restaurant() : this.restaurant,
    );
  }

  @override
  List<Object?> get props => [items, restaurant];
}
