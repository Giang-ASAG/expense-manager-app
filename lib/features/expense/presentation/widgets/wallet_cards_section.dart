import 'package:expense_manager_app/core/services/rtdb_service.dart';
import 'package:expense_manager_app/features/expense/data/models/wallet_model.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';
import '../../../../core/style/app_text_styles.dart';

String _formatVND(double amount) {
  return amount
      .toStringAsFixed(0)
      .replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
  ) +
      ' đ';
}

class WalletCardsSection extends StatelessWidget {
  const WalletCardsSection({
    super.key,
    required this.userId,
    required this.onAddWallet,
  });

  final String userId;
  final VoidCallback onAddWallet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ví của tôi', style: AppTextStyles.sectionTitle),
              GestureDetector(
                onTap: () {}, // TODO: Navigate to wallet management
                child: const Text(
                  'Quản lý →',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<WalletModel>>(
          stream: RTDBService().getWalletsStream(userId),
          builder: (context, snapshot) {
            final wallets = snapshot.data ?? [];
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20, bottom: 4),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  ...wallets.map(
                        (w) => SummaryCard(
                      title: w.bankName,
                      amount: _formatVND(w.balance),
                      isPrimary: w.isDefault,
                    ),
                  ),
                  AddWalletCard(onTap: onAddWallet),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Add Wallet Card ──

class AddWalletCard extends StatelessWidget {
  const AddWalletCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 140,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryLight,
              child: Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Thêm ví',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}