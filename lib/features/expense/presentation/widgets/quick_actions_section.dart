import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../core/style/app_text_styles.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({
    super.key,
    required this.onExpense,
    required this.onIncome,
    required this.onTransfer,
    required this.onCategory,
  });

  final VoidCallback onExpense;
  final VoidCallback onIncome;
  final VoidCallback onTransfer;
  final VoidCallback onCategory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thao tác nhanh', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: QuickActionTile(
                  icon: Icons.remove_circle_outline,
                  label: 'Chi tiêu',
                  color: AppColors.danger,
                  colorLight: AppColors.dangerLight,
                  onTap: onExpense,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionTile(
                  icon: Icons.add_circle_outline,
                  label: 'Thu nhập',
                  color: AppColors.success,
                  colorLight: AppColors.successLight,
                  onTap: onIncome,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionTile(
                  icon: Icons.sync_alt_rounded,
                  label: 'Chuyển tiền',
                  color: AppColors.primary,
                  colorLight: AppColors.primaryLight,
                  onTap: onTransfer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionTile(
                  icon: Icons.category_outlined,
                  label: 'Danh mục',
                  color: AppColors.warning,
                  colorLight: AppColors.warningLight,
                  onTap: onCategory,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tile con — tái sử dụng độc lập ──

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.colorLight,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color colorLight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colorLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}