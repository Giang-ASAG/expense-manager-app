import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onFabPressed;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabPressed,
  });

  static const _primary = Color(0xFF2D4BFF);

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Tổng quan'),
    _NavItem(icon: Icons.receipt_long_outlined, label: 'Lịch sử'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Thống kê'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Cài đặt'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // ── Bar ───────────────────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 2 icon bên trái
                  ...[0, 1].map((i) => Expanded(child: _buildItem(i))),
                  // Khoảng trống giữa cho FAB
                  const SizedBox(width: 72),
                  // 2 icon bên phải
                  ...[2, 3].map((i) => Expanded(child: _buildItem(i))),
                ],
              ),
            ),
          ),

          // ── FAB tròn ─────────────────────────────────────────────────────
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: onFabPressed,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = _items[index];
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon với pill background khi selected
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? _primary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                size: 22,
                color: isSelected ? _primary : const Color(0xFFBDBDBD),
              ),
            ),
            const SizedBox(height: 2),
            // Label
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? _primary : const Color(0xFFBDBDBD),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}