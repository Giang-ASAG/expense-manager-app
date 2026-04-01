import 'package:flutter/material.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';

class TotalBalanceSection extends StatelessWidget {
  const TotalBalanceSection({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
  });

  final double totalBalance;
  final double totalIncome;
  final double totalExpense;

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Số dư hiện tại',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Text(
              _formatVND(totalBalance),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _BalanceStat(
                  label: 'Thu nhập',
                  amount: _formatVND(totalIncome),
                  icon: Icons.arrow_downward_rounded,
                ),
                Container(
                  width: 1,
                  height: 36,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.white24,
                ),
                _BalanceStat(
                  label: 'Chi phí',
                  amount: _formatVND(totalExpense),
                  icon: Icons.arrow_upward_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widget ──

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({
    required this.label,
    required this.amount,
    required this.icon,
  });

  final String label;
  final String amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
