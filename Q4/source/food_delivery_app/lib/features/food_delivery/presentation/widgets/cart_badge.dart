import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../screens/checkout_screen.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CartCubit, CartState, int>(
      selector: (state) => state.itemCount,
      builder: (context, itemCount) {
        return IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CheckoutScreen(),
              ),
            );
          },
          icon: Badge(
            isLabelVisible: itemCount > 0,
            label: Text(
              '$itemCount',
              style: const TextStyle(fontSize: 10),
            ),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        );
      },
    );
  }
}
