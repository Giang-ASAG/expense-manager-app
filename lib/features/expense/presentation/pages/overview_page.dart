import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/add_transaction_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/manage_categories_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/transfer_money_page.dart';
import 'package:expense_manager_app/features/expense/presentation/providers/overview_provider.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/add_wallet_bottom_sheet.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/overview_app_bar.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/quick_actions_section.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/spending_chart_section.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/total_balance_section.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/transactions_section.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/wallet_cards_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key, required this.user});

  final User? user;

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ✅ Non-null sau khi guard trong build()
  String get _uid => widget.user!.uid;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  void _handleAddTransaction(bool isExpense) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddTransactionPage(isExpense: isExpense),
    ),
  );

  void _handleTransfer() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => TransferMoneyPage()),
  );

  void _handleCategoryManagement() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => ManageCategoriesPage()),
  );

  void _handleAddWallet() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddWalletBottomSheet(userId: _uid),
  );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ✅ Guard user null — tránh crash khi dùng !
    if (widget.user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final totalBalance = ref.watch(totalBalanceProvider(_uid));
    final summary = ref.watch(monthlySummaryProvider(_uid));
    final weeklyData = ref.watch(weeklyExpenseProvider(_uid));
    final transactions = ref.watch(recentTransactionsProvider(_uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      appBar: OverviewAppBar(photoUrl: widget.user?.photoURL),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          // ✅ StreamProvider tự nhận data realtime từ Firebase
          // Chỉ cần delay nhỏ để animation refresh không tắt ngay
          onRefresh: () => Future.delayed(const Duration(milliseconds: 500)),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                TotalBalanceSection(
                  totalBalance: totalBalance.valueOrNull ?? 0.0,
                  totalIncome: summary.valueOrNull?['income'] ?? 0.0,
                  totalExpense: summary.valueOrNull?['expense'] ?? 0.0,
                ),
                const SizedBox(height: 24),
                WalletCardsSection(
                  userId: _uid,
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
                weeklyData.when(
                  data: (data) => SpendingChartSection(
                    weekData: data,
                    totalSpent: summary.valueOrNull?['expense'] ?? 0.0,
                  ),
                  loading: () => const _ChartSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
                transactions.when(
                  data: (list) => TransactionsSection(
                    transactions: list,
                    onSeeAll: () {
                      // TODO: Navigator → TransactionHistoryPage
                    },
                  ),
                  loading: () => const _TransactionSkeleton(),
                  error: (_, __) =>
                  const _ErrorTile(message: 'Không thể tải giao dịch'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Skeleton & Error widgets ───────────────────────────────────────────────

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _TransactionSkeleton extends StatelessWidget {
  const _TransactionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
          3,
              (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 12),
          Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}