import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/cart_item.dart';

final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;
  final ValueChanged<int> onQuantityChanged;

  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          // Food image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: cartItem.menuItem.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox(
                width: 70,
                height: 70,
                child: ColoredBox(
                  color: Color(0xFF2A2A2A),
                  child: Center(child: Icon(Icons.fastfood, size: 20)),
                ),
              ),
              errorWidget: (_, __, ___) => const SizedBox(
                width: 70,
                height: 70,
                child: ColoredBox(
                  color: Color(0xFF2A2A2A),
                  child: Icon(Icons.fastfood, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.menuItem.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currencyFormat.format(cartItem.subtotal),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Quantity controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CircleButton(
                icon: Icons.remove,
                color: primary,
                onTap: () => onQuantityChanged(cartItem.quantity - 1),
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '${cartItem.quantity}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _CircleButton(
                icon: Icons.add,
                color: primary,
                onTap: () => onQuantityChanged(cartItem.quantity + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(icon, size: 18, color: Colors.black),
      ),
    );
  }
}
