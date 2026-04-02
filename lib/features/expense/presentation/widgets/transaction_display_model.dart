import 'package:flutter/material.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';

class TransactionDisplayModel {
  final String title;
  final String category;
  final String date;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final Color color;
  final Color colorLight;

  const TransactionDisplayModel({
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.color,
    required this.colorLight,
  });
}

// // Dữ liệu mẫu — thay bằng StreamBuilder từ Firebase sau
// const sampleTransactions = [
//   TransactionDisplayModel(
//     title: 'Netflix',
//     category: 'Entertainment',
//     date: 'Today, 10:30',
//     amount: 15.99,
//     isIncome: false,
//     icon: Icons.play_circle_outline_rounded,
//     color: AppColors.danger,
//     colorLight: AppColors.dangerLight,
//   ),
//   TransactionDisplayModel(
//     title: 'Salary',
//     category: 'Income',
//     date: 'Today, 09:00',
//     amount: 3200.00,
//     isIncome: true,
//     icon: Icons.account_balance_outlined,
//     color: AppColors.success,
//     colorLight: AppColors.successLight,
//   ),
//   TransactionDisplayModel(
//     title: 'Grab Food',
//     category: 'Food & Drink',
//     date: 'Yesterday',
//     amount: 8.50,
//     isIncome: false,
//     icon: Icons.fastfood_outlined,
//     color: AppColors.warning,
//     colorLight: AppColors.warningLight,
//   ),
//   TransactionDisplayModel(
//     title: 'Freelance',
//     category: 'Income',
//     date: '20 Mar',
//     amount: 450.00,
//     isIncome: true,
//     icon: Icons.laptop_outlined,
//     color: AppColors.primary,
//     colorLight: AppColors.primaryLight,
//   ),
// ];
