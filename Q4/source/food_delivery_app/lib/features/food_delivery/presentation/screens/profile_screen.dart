import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'order_history_screen.dart';
import 'search_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ── Avatar + Name ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                // Profile image with camera badge
                Stack(
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primary.withAlpha(50),
                          width: 4,
                        ),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
                          fit: BoxFit.cover,
                          placeholder: (_, __) => ColoredBox(
                            color: primary.withAlpha(40),
                            child: Icon(Icons.person, color: primary, size: 48),
                          ),
                          errorWidget: (_, __, ___) => ColoredBox(
                            color: primary.withAlpha(40),
                            child: Icon(Icons.person, color: primary, size: 48),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0D0D0D),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Alex Thompson',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'alex.thompson@example.com',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          // ── Section 1: Account ──
          _SectionCard(
            children: [
              _ProfileRow(
                icon: Icons.person_outline,
                title: 'My Account',
                primary: primary,
              ),
              _ProfileRow(
                icon: Icons.payment_outlined,
                title: 'Payment Methods',
                primary: primary,
              ),
              _ProfileRow(
                icon: Icons.location_on_outlined,
                title: 'Delivery Addresses',
                primary: primary,
                showDivider: false,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Section 2: Preferences ──
          _SectionCard(
            children: [
              _ProfileRow(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                primary: primary,
              ),
              _ProfileRow(
                icon: Icons.settings_outlined,
                title: 'App Settings',
                primary: primary,
                showDivider: false,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Section 3: Support ──
          _SectionCard(
            children: [
              _ProfileRow(
                icon: Icons.help_outline,
                title: 'Help & Support',
                primary: primary,
                showDivider: false,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Logout ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.redAccent),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white.withAlpha(80),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Version ──
          Center(
            child: Text(
              'Version 2.4.1 (620)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (i == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const SearchScreen(),
              ),
            );
          } else if (i == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const OrderHistoryScreen(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ── Grouped card section ──

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: children),
      ),
    );
  }
}

// ── Single row inside a section card ──

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color primary;
  final bool showDivider;

  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.primary,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: showDivider
                ? BorderRadius.zero
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(icon, color: primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withAlpha(80),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withAlpha(12),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
