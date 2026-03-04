import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/order.dart';

class HelpSupportScreen extends StatelessWidget {
  final Order order;

  const HelpSupportScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final itemSummary = order.items.length == 1
        ? '1 item'
        : '${order.items.length} items';

    final firstImageUrl =
        order.items.isNotEmpty ? order.items.first.menuItem.imageUrl : '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, size: 28),
        ),
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Order Info Card ──
                  _OrderInfoCard(
                    imageUrl: firstImageUrl,
                    orderId: order.id,
                    itemSummary: itemSummary,
                    status: order.status,
                  ),

                  const SizedBox(height: 20),

                  // ── Search Bar ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.white38,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Search for help',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Common Issues ──
                  Text(
                    'Common Issues',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const _IssueRow(
                    icon: Icons.location_on,
                    iconColor: Colors.blue,
                    label: 'Where is my order?',
                  ),
                  const _IssueRow(
                    icon: Icons.edit_location_alt,
                    iconColor: Colors.purple,
                    label: 'Change delivery address',
                  ),
                  const _IssueRow(
                    icon: Icons.cancel,
                    iconColor: Colors.redAccent,
                    label: 'Cancel order',
                  ),
                  _IssueRow(
                    icon: Icons.report_problem,
                    iconColor: primary,
                    label: 'Report a quality issue',
                  ),

                  const SizedBox(height: 24),

                  // ── Other ──
                  Text(
                    'Other',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const _IssueRow(
                    icon: Icons.help_outline,
                    iconColor: Colors.white54,
                    label: 'View FAQ',
                  ),
                  const _IssueRow(
                    icon: Icons.description_outlined,
                    iconColor: Colors.white54,
                    label: 'Terms of Service',
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Chat Button ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              border: Border(
                top: BorderSide(color: Color(0xFF2A2A2A)),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat, size: 20),
                  label: const Text(
                    'Chat with Support',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order Info Card ──

class _OrderInfoCard extends StatelessWidget {
  final String imageUrl;
  final String orderId;
  final String itemSummary;
  final OrderStatus status;

  const _OrderInfoCard({
    required this.imageUrl,
    required this.orderId,
    required this.itemSummary,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            // Order image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 56,
                      height: 56,
                      memCacheWidth: 56,
                      memCacheHeight: 56,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(
                        color: Color(0xFF2A2A2A),
                        child: SizedBox(width: 56, height: 56),
                      ),
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: Color(0xFF2A2A2A),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(
                            Icons.fastfood,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                    )
                  : const ColoredBox(
                      color: Color(0xFF2A2A2A),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          Icons.fastfood,
                          color: Colors.white38,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Order details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #$orderId',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    itemSummary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            // Status badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: primary.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.displayName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Issue Row ──

class _IssueRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _IssueRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white38,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
