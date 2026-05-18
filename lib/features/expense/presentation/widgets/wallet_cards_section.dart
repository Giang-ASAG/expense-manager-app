import 'package:expense_manager_app/core/services/rtdb_service.dart';
import 'package:expense_manager_app/features/expense/data/models/wallet_model.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';
import '../../../../core/style/app_text_styles.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/manage_wallets_page.dart';

String _formatVND(double amount) {
  return amount
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          ) +
      ' đ';
}

// Màu gradient theo index ví
const List<List<Color>> _cardGradients = [
  [Color(0xFF667EEA), Color(0xFF764BA2)], // tím xanh
  [Color(0xFF11998E), Color(0xFF38EF7D)], // xanh lá
  [Color(0xFFFC466B), Color(0xFF3F5EFB)], // hồng tím
  [Color(0xFFF7971E), Color(0xFFFFD200)], // cam vàng
  [Color(0xFF1FA2FF), Color(0xFF12D8FA)], // xanh dương
];

List<Color> _gradientForIndex(int index) =>
    _cardGradients[index % _cardGradients.length];

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
              Text('Ví của tôi', style: AppTextStyles.sectionTitle(context)),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ManageWalletsPage(userId: userId),
                    ),
                  );
                },
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
                  ...wallets.asMap().entries.map(
                    (e) => WalletCard(
                      wallet: e.value,
                      gradient: _gradientForIndex(e.key),
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
  const AddWalletCard({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 155,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Thêm ví',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(context),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wallet Card ──

class WalletCard extends StatelessWidget {
  const WalletCard({super.key, required this.wallet, required this.gradient});

  final WalletModel wallet;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 155,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Vòng trang trí nền
          Positioned(
            top: -18,
            right: -18,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),

          // Nội dung
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chip icon ngân hàng
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),

                const Spacer(),

                // Tên ngân hàng
                Text(
                  wallet.bankName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),

                // Số dư
                Text(
                  _formatVND(wallet.balance),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Footer: tên tài khoản + badge mặc định
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        wallet.accountName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (wallet.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '✓ MĐ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
