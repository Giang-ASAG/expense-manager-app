// lib/features/expense/presentation/pages/transaction_history_page.dart

import 'package:expense_manager_app/core/services/rtdb_service.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:expense_manager_app/features/expense/data/models/category_model.dart';
import 'package:expense_manager_app/features/expense/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  String? _userId;
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUid();
  }

  Future<void> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('user_uid');
    if (uid != null && mounted) setState(() => _userId = uid);
  }

  // --- Helpers ---

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _prevMonth() =>
      setState(() => _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1));

  void _nextMonth() =>
      setState(() => _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1));

  // Tổng thu / chi trong tháng
  Map<String, double> _monthSummary(List<TransactionModel> allItems) {
    double income = 0, expense = 0;
    for (final tx in allItems) {
      final date = DateTime.tryParse(tx.date);
      if (date == null) continue;
      if (date.year != _focusedMonth.year ||
          date.month != _focusedMonth.month) continue;
      if (tx.type == 'income') income += tx.amount;
      if (tx.type == 'expense') expense += tx.amount;
    }
    return {'income': income, 'expense': expense};
  }

  // Tổng thu / chi theo ngày (dùng cho badge trên lịch)
  Map<String, Map<String, double>> _dailySummary(
      List<TransactionModel> allItems) {
    final Map<String, Map<String, double>> map = {};
    for (final tx in allItems) {
      map.putIfAbsent(tx.date, () => {'income': 0, 'expense': 0});
      if (tx.type == 'income') map[tx.date]!['income'] = map[tx.date]!['income']! + tx.amount;
      if (tx.type == 'expense') map[tx.date]!['expense'] = map[tx.date]!['expense']! + tx.amount;
    }
    return map;
  }

  // Lọc giao dịch theo ngày đã chọn hoặc toàn tháng
  List<TransactionModel> _filtered(List<TransactionModel> allItems) {
    return allItems.where((tx) {
      final date = DateTime.tryParse(tx.date);
      if (date == null) return false;
      if (_selectedDate != null) {
        return tx.date == _dateKey(_selectedDate!);
      }
      return date.year == _focusedMonth.year &&
          date.month == _focusedMonth.month;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Lịch sử giao dịch',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<TransactionModel>>(
        stream: RTDBService().getTransactionsStream(_userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final allItems = snapshot.data ?? [];
          final summary = _monthSummary(allItems);
          final dailyMap = _dailySummary(allItems);
          final filtered = _filtered(allItems);

          return Column(
            children: [
              // --- Calendar ---
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildMonthHeader(),
                    const SizedBox(height: 12),
                    _buildWeekdayLabels(),
                    const SizedBox(height: 8),
                    _buildCalendarGrid(dailyMap),
                  ],
                ),
              ),

              // --- Tổng kết tháng ---
              //_buildMonthlySummary(summary),

              const SizedBox(height: 8),

              // --- Danh sách giao dịch ---
              Expanded(child: _buildTransactionList(filtered)),
            ],
          );
        },
      ),
    );
  }

  // --- Calendar Widgets ---

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _prevMonth,
          icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
        ),
        Text(
          DateFormat('MMMM, yyyy', 'vi').format(_focusedMonth),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    const labels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return Row(
      children: labels
          .map((l) => Expanded(
        child: Center(
          child: Text(
            l,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid(Map<String, Map<String, double>> dailyMap) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // CN=0, T2=1...T7=6

    final List<Widget> cells = [];

    // Ô trống đầu tháng
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    // Các ngày trong tháng
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final key = _dateKey(date);
      final isSelected = _selectedDate != null && _dateKey(_selectedDate!) == key;
      final isToday = _dateKey(DateTime.now()) == key;
      final dayData = dailyMap[key];

      // Badge: ưu tiên hiện income nếu có, nếu không thì expense
      String? badgeText;
      Color badgeColor = AppColors.success;
      if (dayData != null) {
        if ((dayData['income'] ?? 0) > 0) {
          badgeText = '+${_shortAmount(dayData['income']!)}';
          badgeColor = AppColors.success;
        } else if ((dayData['expense'] ?? 0) > 0) {
          badgeText = '-${_shortAmount(dayData['expense']!)}';
          badgeColor = AppColors.danger;
        }
      }

      cells.add(
        GestureDetector(
          onTap: () => setState(() {
            // Bỏ chọn nếu nhấn lại ngày đó
            _selectedDate = isSelected ? null : date;
          }),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2D4BFF)
                  : isToday
                  ? const Color(0xFF2D4BFF).withOpacity(0.15)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textPrimary,
                    fontWeight: isToday || isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                if (badgeText != null)
                  Text(
                    badgeText,
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : badgeColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: cells,
    );
  }

  Widget _buildMonthlySummary(Map<String, double> summary) {
    final fmt = NumberFormat.currency(locale: 'vi', symbol: '₫', decimalDigits: 0);
    final income = summary['income'] ?? 0;
    final expense = summary['expense'] ?? 0;
    final net = income - expense;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryCol('Thu nhập', '+${fmt.format(income)}', AppColors.success),
          ),
          Expanded(
            child: _summaryCol('Chi tiêu', '-${fmt.format(expense)}', AppColors.danger),
          ),
          Expanded(
            child: _summaryCol('Còn lại', fmt.format(net),
                net >= 0 ? AppColors.success : AppColors.danger),
          ),
        ],
      ),
    );
  }

  Widget _summaryCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildTransactionList(List<TransactionModel> items) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 48, color: AppColors.textSecondary),
            SizedBox(height: 8),
            Text('Không có giao dịch',
                style:
                TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    // Group theo ngày
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in items) {
      grouped.putIfAbsent(tx.date, () => []).add(tx);
    }
    final dateKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: dateKeys.fold(0, (sum, k) => sum! + 1 + grouped[k]!.length),
      itemBuilder: (context, index) {
        int cursor = 0;
        for (final key in dateKeys) {
          if (index == cursor) return _buildDateHeader(key, grouped[key]!);
          cursor++;
          final list = grouped[key]!;
          if (index < cursor + list.length) {
            return _buildTransactionItem(list[index - cursor]);
          }
          cursor += list.length;
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDateHeader(String dateStr, List<TransactionModel> txList) {
    final date = DateTime.tryParse(dateStr);
    final label = date == null
        ? dateStr
        : DateFormat('dd/MM/yyyy', 'vi').format(date);
    final weekday = date == null
        ? ''
        : DateFormat('EEEE', 'vi').format(date);

    double income = 0, expense = 0;
    for (final tx in txList) {
      if (tx.type == 'income') income += tx.amount;
      if (tx.type == 'expense') expense += tx.amount;
    }
    final fmt = NumberFormat.currency(locale: 'vi', symbol: '₫', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(width: 8),
          Text(weekday,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const Spacer(),
          if (income > 0)
            Text('+${fmt.format(income)}',
                style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          if (income > 0 && expense > 0) const SizedBox(width: 8),
          if (expense > 0)
            Text('-${fmt.format(expense)}',
                style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    final isExpense = tx.type == 'expense';
    final isTransfer = tx.type == 'transfer';

    final Color iconBg = isTransfer
        ? Colors.blue.shade50
        : isExpense
        ? Colors.red.shade50
        : Colors.green.shade50;
    final Color iconColor = isTransfer
        ? Colors.blue
        : isExpense
        ? AppColors.danger
        : AppColors.success;
    final IconData iconData = isTransfer
        ? CategoryModel.transferCategory.iconData
        : _getIconForCategory(tx.category);

    final fmt = NumberFormat.currency(locale: 'vi', symbol: '₫', decimalDigits: 0);
    final amountStr = isTransfer
        ? fmt.format(tx.amount)
        : '${isExpense ? '-' : '+'}${fmt.format(tx.amount)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  isTransfer ? 'Chuyển tiền' : (tx.category ?? ''),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(amountStr,
              style: TextStyle(
                  color: isTransfer
                      ? Colors.blue
                      : isExpense
                      ? AppColors.danger
                      : AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ],
      ),
    );
  }

  // Rút gọn số tiền cho badge (vd: 5000000 → 5M, 500000 → 500K)
  String _shortAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(0)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }

  IconData _getIconForCategory(String? category) {
    if (category == null) return Icons.category;
    final dummy = CategoryModel(
        id: '', name: category, icon: category, colorValue: 0, isExpense: true);
    return dummy.iconData;
  }
}