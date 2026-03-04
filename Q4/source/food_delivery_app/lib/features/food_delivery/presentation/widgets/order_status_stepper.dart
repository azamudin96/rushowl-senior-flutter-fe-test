import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/order.dart' as entity;

final _timeFormat = DateFormat('h:mm a');

class OrderStatusStepper extends StatefulWidget {
  final entity.OrderStatus currentStatus;
  final DateTime estimatedDelivery;

  const OrderStatusStepper({
    super.key,
    required this.currentStatus,
    required this.estimatedDelivery,
  });

  @override
  State<OrderStatusStepper> createState() => _OrderStatusStepperState();
}

class _OrderStatusStepperState extends State<OrderStatusStepper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final currentIndex =
        entity.OrderStatus.values.indexOf(widget.currentStatus);

    return Column(
      children: List.generate(entity.OrderStatus.values.length, (index) {
        final status = entity.OrderStatus.values[index];
        final isCompleted = index < currentIndex;
        final isCurrent = index == currentIndex;
        final isActive = index <= currentIndex;
        final isLast = index == entity.OrderStatus.values.length - 1;

        // Build subtitle text
        String subtitle;
        if (status == entity.OrderStatus.confirmed && isActive) {
          subtitle =
              '${status.subtitle} at ${_timeFormat.format(DateTime.now())}';
        } else if (status == entity.OrderStatus.delivered && !isActive) {
          subtitle =
              'Estimated arrival ${_timeFormat.format(widget.estimatedDelivery)}';
        } else {
          subtitle = status.subtitle;
        }

        final circle = Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? primary : const Color(0xFF2A2A2A),
          ),
          child: Icon(
            isCompleted ? Icons.check : status.icon,
            size: 22,
            color: isActive ? Colors.black : Colors.white38,
          ),
        );

        return SizedBox(
          height: isLast ? 56 : 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle + connecting line
              SizedBox(
                width: 56,
                child: Column(
                  children: [
                    if (isCurrent)
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, _) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Pulse ring
                                  Container(
                                    width: 44 * _pulseAnimation.value,
                                    height: 44 * _pulseAnimation.value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primary.withAlpha(
                                        (60 * (1.35 - _pulseAnimation.value))
                                            .toInt(),
                                      ),
                                    ),
                                  ),
                                  circle,
                                ],
                              );
                            },
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: Center(child: circle),
                      ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          constraints: const BoxConstraints(minHeight: 24),
                          color: index < currentIndex
                              ? primary
                              : const Color(0xFF2A2A2A),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    bottom: isLast ? 0 : 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCurrent
                              ? primary
                              : isActive
                                  ? Colors.white
                                  : Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isActive ? Colors.white54 : Colors.white30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

