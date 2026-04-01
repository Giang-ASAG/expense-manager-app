import 'package:expense_manager_app/core/constants/fake_data_seeder.dart';
import 'package:expense_manager_app/core/services/rtdb_service.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/add_transaction_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/manage_categories_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/transfer_money_page.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/add_wallet_bottom_sheet.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/center_fab.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/overview_app_bar.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/quick_actions_section.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/spending_chart_section.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/total_balance_section.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/transaction_display_model.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/transactions_section.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/wallet_cards_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key, required this.user});

  final User? user;

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ✅ Đúng kiểu: Stream<double> thay vì double
  late final Stream<double> _totalBalanceStream;

  @override
  void initState() {
    super.initState();
    // Seed 50 giao dịch (mặc định)
    // await FakeDataSeeder.seed(widget.user!.uid);
    //
    // // Seed số lượng tuỳ chỉnh
    // await FakeDataSeeder.seed(widget.user!.uid, count: 100);

    // Xóa toàn bộ khi test xong
    // await FakeDataSeeder.clear(widget.user!.uid);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    // ✅ Cộng tổng balance của tất cả ví
    _totalBalanceStream = RTDBService().getTotalBalanceStream(widget.user!.uid);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── Handlers ─────────────────────────────────────────────────────────────

  void _handleAddTransaction(bool isExpense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionPage(isExpense: isExpense),
      ),
    );
  }

  void _handleTransfer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TransferMoneyPage()),
    );
  }

  void _handleCategoryManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ManageCategoriesPage()),
    );
  }

  void _handleSeeAllTransactions() {
    // TODO: Navigator.push → TransactionHistoryPage
  }

  void _handleAddWallet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddWalletBottomSheet(userId: widget.user!.uid),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      appBar: OverviewAppBar(photoUrl: widget.user?.photoURL),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ✅ Dùng StreamBuilder để hiển thị tổng số dư thật từ Firebase
              StreamBuilder<double>(
                stream: _totalBalanceStream,
                builder: (context, snapshot) {
                  final total = snapshot.data ?? 0.0;
                  return TotalBalanceSection(
                    totalBalance: total,
                    totalIncome: 0, // TODO: tính từ transactions
                    totalExpense: 0, // TODO: tính từ transactions
                  );
                },
              ),

              const SizedBox(height: 24),
              WalletCardsSection(
                userId: widget.user!.uid,
                onAddWallet: _handleAddWallet,
              ),
              const SizedBox(height: 24),
              QuickActionsSection(
                onExpense: () => _handleAddTransaction(true),
                onIncome: () => _handleAddTransaction(false),
                onTransfer: _handleTransfer,
                onCategory: _handleCategoryManagement,
              ),
              const SizedBox(height: 24),
              // TODO: truyền dữ liệu thật từ Firebase
              const SpendingChartSection(
                weekData: [0.4, 0.7, 0.5, 0.9, 0.3, 0.6, 0.8],
                totalSpent: 1840000,
              ),
              const SizedBox(height: 24),
              TransactionsSection(
                // TODO: thay bằng StreamBuilder lấy từ Firebase
                transactions: RTDBService().getRecentTransactionsStream(
                  widget.user!.uid,
                  limit: 5,
                ),
                onSeeAll: _handleSeeAllTransactions,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
