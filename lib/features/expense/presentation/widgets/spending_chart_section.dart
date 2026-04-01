import 'package:flutter/material.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';
import '../../../../core/style/app_text_styles.dart';

class SpendingChartSection extends StatelessWidget {
  const SpendingChartSection({
    super.key,
    this.weekData = const [0.4, 0.7, 0.5, 0.9, 0.3, 0.6, 0.8],
    this.totalSpent = 1840000,
  });

  /// Giá trị chuẩn hoá 0.0–1.0 cho 7 ngày (Thứ 2 → Chủ nhật)
  final List<double> weekData;
  final double totalSpent;

  static const _days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  String _formatVND(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    ) +
        ' đ';
  }

  @override
  Widget build(BuildContext context) {
    assert(weekData.length == 7, 'weekData phải có đúng 7 phần tử');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 4),
            Text(
              'Đã chi ${_formatVND(totalSpent)} tuần này',
              style: AppTextStyles.labelMuted,
            ),
            const SizedBox(height: 20),
            _buildBars(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Chi tiêu theo tuần', style: AppTextStyles.sectionTitle),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Tuần này',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBars() {
    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(weekData.length, (i) {
          final isToday = i == 6;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400 + i * 60),
                    curve: Curves.easeOut,
                    height: weekData[i] * 64,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _days[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      isToday ? FontWeight.w700 : FontWeight.w400,
                      color: isToday
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}