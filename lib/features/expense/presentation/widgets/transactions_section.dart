import 'package:expense_manager_app/features/expense/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/style/app_text_styles.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:intl/intl.dart';

class TransactionsSection extends StatelessWidget {
  const TransactionsSection({
    super.key,
    required this.transactions,
    this.onSeeAll,
  });

  final List<TransactionModel> transactions;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 14),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Chưa có giao dịch nào',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              ),
            )
          else
            Column(
              children: transactions.map((tx) => TransactionItem(tx: tx)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Giao dịch gần đây', style: AppTextStyles.sectionTitle(context)),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            'Xem tất cả →',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class TransactionItem extends StatelessWidget {
  const TransactionItem({super.key, required this.tx});

  final TransactionModel tx;

  bool get _isIncome => tx.type == 'income';
  bool get _isTransfer => tx.type == 'transfer';

  Color get _color => _isTransfer
      ? Colors.blue
      : _isIncome
      ? AppColors.success
      : AppColors.danger;

  IconData get _icon {
    if (_isTransfer) return Icons.swap_horiz_rounded;
    final category = tx.category ?? '';
    const map = {
      'Ăn uống': Icons.fastfood_outlined,
      'Di chuyển': Icons.directions_car_outlined,
      'Mua sắm': Icons.shopping_bag_outlined,
      'Giải trí': Icons.play_circle_outline_rounded,
      'Sức khỏe': Icons.favorite_outline_rounded,
      'Giáo dục': Icons.school_outlined,
      'Hóa đơn': Icons.receipt_outlined,
      'Lương': Icons.account_balance_outlined,
      'Thưởng': Icons.card_giftcard_outlined,
      'Đầu tư': Icons.trending_up_rounded,
    };
    return map[category] ?? Icons.category_outlined;
  }

  String get _dateLabel {
    final date = DateTime.tryParse(tx.date);
    if (date == null) return tx.date;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDay = DateTime(date.year, date.month, date.day);
    if (txDay == today) return 'Hôm nay';
    if (txDay == yesterday) return 'Hôm qua';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatVND(double amount) {
    return NumberFormat.currency(
      locale: 'vi',
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIcon(context),
          const SizedBox(width: 14),
          _buildInfo(context),
          _buildAmount(),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_icon, color: _color, size: 20),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tx.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            _isTransfer
                ? 'Chuyển tiền · $_dateLabel'
                : '${tx.category ?? ''} · $_dateLabel',
            style: AppTextStyles.labelMuted(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAmount() {
    final prefix = _isTransfer ? '' : (_isIncome ? '+' : '-');
    return Text(
      '$prefix${_formatVND(tx.amount)}',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _color,
      ),
    );
  }
}