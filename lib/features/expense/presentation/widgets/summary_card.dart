import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final bool isPrimary;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF2D4BFF) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isPrimary)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: isPrimary ? Colors.white : Colors.black,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: isPrimary ? Colors.white70 : Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: isPrimary ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}