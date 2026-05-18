import 'package:flutter/material.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';
import '../../../../core/style/app_text_styles.dart';

class SpendingChartSection extends StatelessWidget {
  SpendingChartSection({
    super.key,
    this.weekData = const [0.4, 0.7, 0.5, 0.9, 0.3, 0.6, 0.8],
    this.totalSpent = 1840000,
  });

  /// Giá trị chuẩn hoá 0.0–1.0 cho 7 ngày
  final List<double> weekData;
  final double totalSpent;

  String _formatVND(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
    ) +
        ' đ';
  }

  List<String> _getLast7Days() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      if (index == 6) return 'Nay';
      return '${date.day}/${date.month}';
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(weekData.length == 7, 'weekData phải có đúng 7 phần tử');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 4),
            Text(
              'Đã chi ${_formatVND(totalSpent)} tuần này',
              style: AppTextStyles.labelMuted(context),
            ),
            const SizedBox(height: 20),
            _buildBars(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Chi tiêu theo tuần', style: AppTextStyles.sectionTitle(context)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
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

  Widget _buildBars(BuildContext context) {
    final days = _getLast7Days();

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
                    height: (weekData[i] * 64).clamp(4.0, 64.0),
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      isToday ? FontWeight.w700 : FontWeight.w400,
                      color: isToday
                          ? AppColors.primary
                          : AppColors.textSecondary(context),
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