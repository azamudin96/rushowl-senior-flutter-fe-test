import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/voucher_instance.dart';

class VoucherCard extends StatelessWidget {
  final VoucherInstance voucher;
  final VoidCallback onTap;

  const VoucherCard({
    super.key,
    required this.voucher,
    required this.onTap,
  });

  IconData get _voucherIcon {
    return switch (voucher.amount) {
      2 => Icons.confirmation_number_outlined,
      5 => Icons.local_activity_outlined,
      _ => Icons.redeem_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = voucher.isSelected;

    return RepaintBoundary(
      child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDark,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _voucherIcon,
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
                const Spacer(),
                // Amount
                Text(
                  '\$${voucher.amount}.00',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF1F5F9),
                  ),
                ),
                const SizedBox(height: 2),
                // Instance number
                Text(
                  'Voucher ${voucher.displayNumber}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            // Checkmark
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.backgroundDark,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
