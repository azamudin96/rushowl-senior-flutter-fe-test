import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../di/injection.dart';
import '../../domain/entities/order.dart' as entity;
import '../cubit/cart_cubit.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import '../widgets/order_status_stepper.dart';
import 'help_support_screen.dart';

final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

class OrderTrackingScreen extends StatefulWidget {
  final bool popToFirst;

  const OrderTrackingScreen({super.key, this.popToFirst = true});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _isPopping = false;

  void _closeAndClearCart() {
    if (_isPopping) return;
    _isPopping = true;
    if (widget.popToFirst) {
      getIt<CartCubit>().clearCart();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.popToFirst,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _closeAndClearCart();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Status'),
          leading: IconButton(
            onPressed: _closeAndClearCart,
            icon: const Icon(Icons.chevron_left, size: 28),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                final state = context.read<OrderCubit>().state;
                if (state is OrderTracking) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          HelpSupportScreen(order: state.order),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                width: 38,
                height: 38,
                child: Icon(
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        body: _isPopping
            ? const SizedBox.shrink()
            : BlocBuilder<OrderCubit, OrderState>(
                builder: (context, state) {
                  return switch (state) {
                    OrderInitial() || OrderPlacing() =>
                      const Center(child: CircularProgressIndicator()),
                    OrderTracking(:final order) =>
                      _TrackingContent(order: order),
                    OrderError(:final message) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline, size: 48),
                            const SizedBox(height: 16),
                            Text(message),
                          ],
                        ),
                      ),
                  };
                },
              ),
      ),
    );
  }
}

class _TrackingContent extends StatelessWidget {
  final entity.Order order;

  const _TrackingContent({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    // Build item summary string
    final itemSummary = order.items
        .map((i) => i.menuItem.name)
        .join(' + ');

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Estimated Delivery Time ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    children: [
                      Text(
                        '15-20 min',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ESTIMATED DELIVERY TIME',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white54,
                          letterSpacing: 1.5,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Status Stepper ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OrderStatusStepper(
                    currentStatus: order.status,
                    estimatedDelivery: order.estimatedDelivery,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Live Map ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(3.1390, 101.6869),
                          initialZoom: 14,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.food_delivery_app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(3.1360, 101.6839),
                                child: Icon(
                                  Icons.restaurant,
                                  color: primary,
                                  size: 28,
                                ),
                              ),
                              Marker(
                                point: LatLng(3.1390, 101.6869),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primary,
                                  ),
                                  child: const Icon(
                                    Icons.navigation,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const Marker(
                                point: LatLng(3.1420, 101.6899),
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Map label
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Live Tracking',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Delivery Partner ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary.withAlpha(40),
                        ),
                        child: Icon(
                          Icons.person,
                          color: primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Name + rating
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Marcus Johnson',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.star, size: 14, color: primary),
                                const SizedBox(width: 4),
                                Text(
                                  '4.9',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  ' \u2022 Delivery Partner',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Chat button
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2A2A2A),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Call button
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primary,
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // ── Bottom Order Info ──
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            border: Border(
              top: BorderSide(color: Color(0xFF2A2A2A)),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Order ${order.id}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        itemSummary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _currencyFormat.format(order.total),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
