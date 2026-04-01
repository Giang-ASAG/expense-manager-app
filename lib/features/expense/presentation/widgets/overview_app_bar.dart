import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../core/style/app_text_styles.dart';

class OverviewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OverviewAppBar({super.key, required this.photoUrl});

  final String? photoUrl;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_greeting(), style: AppTextStyles.labelMuted),
          const SizedBox(height: 2),
          const Text('Tổng quan', style: AppTextStyles.pageTitle),
        ],
      ),
      actions: [
        const _NotificationBell(),
        const SizedBox(width: 12),
        _UserAvatar(photoUrl: photoUrl),
        const SizedBox(width: 20),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối 👋';
  }
}

// ── Sub-widgets (private, chỉ dùng trong file này) ──

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        Positioned(
          top: 7,
          right: 7,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
        color: AppColors.primaryLight,
        image: photoUrl != null
            ? DecorationImage(
          image: NetworkImage(photoUrl!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: photoUrl == null
          ? const Icon(Icons.person, color: AppColors.primary, size: 20)
          : null,
    );
  }
}