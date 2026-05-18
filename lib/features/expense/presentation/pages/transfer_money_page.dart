import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:expense_manager_app/features/expense/data/models/wallet_model.dart';
import 'package:expense_manager_app/features/expense/presentation/providers/overview_provider.dart';
import 'package:expense_manager_app/features/expense/presentation/providers/transfer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransferMoneyPage extends ConsumerStatefulWidget {
  const TransferMoneyPage({super.key});

  @override
  ConsumerState<TransferMoneyPage> createState() => _TransferMoneyPageState();
}

class _TransferMoneyPageState extends ConsumerState<TransferMoneyPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUid();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _userId = prefs.getString('user_uid'));
  }

  double get _parsedAmount =>
      double.tryParse(_amountController.text.trim()) ?? 0.0;

  Future<void> _onTransfer() async {
    if (_userId == null) return;

    final error = await ref
        .read(transferProvider.notifier)
        .transfer(
          uid: _userId!,
          amount: _parsedAmount,
          note: _noteController.text.trim().isEmpty
              ? 'Chuyển tiền'
              : _noteController.text.trim(),
        );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Chuyển tiền thành công!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final transferState = ref.watch(transferProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Icon(
                Icons.close,
                color: AppColors.textPrimary(context),
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          'Chuyển tiền',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _userId == null
          ? const Center(child: CircularProgressIndicator())
          : ref
                .watch(walletsProvider(_userId!))
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Lỗi: $e')),
                  data: (wallets) {
                    // Init ví mặc định 1 lần
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(transferProvider.notifier).initWallets(wallets);
                    });

                    if (wallets.length < 2) return _buildNotEnoughWallets(context);

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildTransferCard(transferState, wallets, context),
                                const SizedBox(height: 24),
                                _buildAmountInput(context),
                                const SizedBox(height: 16),
                                _buildNoteInput(context),
                                const SizedBox(height: 16),
                                _buildBalanceInfo(transferState, context),
                              ],
                            ),
                          ),
                        ),
                        _buildConfirmButton(transferState, context),
                      ],
                    );
                  },
                ),
    );
  }

  // ── Transfer Card ──────────────────────────────────────────────────────────

  Widget _buildTransferCard(TransferState state, List<WalletModel> wallets, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              _buildWalletSelector(
                label: 'Từ ví',
                wallet: state.fromWallet,
                icon: Icons.outbox_rounded,
                color: AppColors.danger,
                onTap: () => _showWalletPicker(
                  isFrom: true,
                  wallets: wallets,
                  state: state,
                  context: context,
                ),
                context: context,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: AppColors.border(context)),
              ),
              _buildWalletSelector(
                label: 'Đến ví',
                wallet: state.toWallet,
                icon: Icons.move_to_inbox_rounded,
                color: AppColors.success,
                onTap: () => _showWalletPicker(
                  isFrom: false,
                  wallets: wallets,
                  state: state,
                  context: context,
                ),
                context: context,
              ),
            ],
          ),
          GestureDetector(
            onTap: () => ref.read(transferProvider.notifier).swap(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border(context)),
              ),
              child: const Icon(Icons.swap_vert, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSelector({
    required String label,
    required WalletModel? wallet,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  Text(
                    wallet?.accountName ?? 'Chọn ví',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: wallet != null
                          ? AppColors.textPrimary(context)
                          : AppColors.textSecondary(context),
                    ),
                  ),
                  if (wallet != null)
                    Text(
                      wallet.bankName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                ],
              ),
            ),
            if (wallet != null)
              Text(
                _formatCurrency(wallet.balance),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textPrimary(context),
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: AppColors.textSecondary(context)),
          ],
        ),
      ),
    );
  }

  // ── Wallet Picker ──────────────────────────────────────────────────────────

  void _showWalletPicker({
    required bool isFrom,
    required List<WalletModel> wallets,
    required TransferState state,
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFrom ? 'Chọn ví nguồn' : 'Chọn ví đích',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 12),
            ...wallets.map((wallet) {
              final isSelected = isFrom
                  ? state.fromWallet?.id == wallet.id
                  : state.toWallet?.id == wallet.id;

              return GestureDetector(
                onTap: () {
                  if (isFrom) {
                    ref.read(transferProvider.notifier).setFrom(wallet);
                  } else {
                    ref.read(transferProvider.notifier).setTo(wallet);
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.08)
                        : AppColors.background(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border(context),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wallet.accountName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            Text(
                              wallet.bankName,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(wallet.balance),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          if (wallet.isDefault)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Mặc định',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Amount / Note / Balance ────────────────────────────────────────────────

  Widget _buildAmountInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Số tiền chuyển',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            decoration: const InputDecoration(
              hintText: '0',
              suffixText: 'đ',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
            ),
          ),
          Row(
            children: [50000, 100000, 200000, 500000].map((amount) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () {
                      _amountController.text = amount.toString();
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.background(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child: Center(
                        child: Text(
                          _shortCurrency(amount),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: TextField(
        controller: _noteController,
        style: TextStyle(color: AppColors.textPrimary(context)),
        decoration: InputDecoration(
          icon: Icon(Icons.notes, color: AppColors.textSecondary(context)),
          hintText: 'Ghi chú chuyển khoản',
          hintStyle: TextStyle(color: AppColors.textSecondary(context)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  Widget _buildBalanceInfo(TransferState state, BuildContext context) {
    if (state.fromWallet == null || _parsedAmount <= 0) {
      return const SizedBox.shrink();
    }

    final isInsufficient = _parsedAmount > state.fromWallet!.balance;
    final color = isInsufficient ? AppColors.danger : AppColors.success;
    final msg = isInsufficient
        ? 'Số dư không đủ (còn ${_formatCurrency(state.fromWallet!.balance)})'
        : 'Số dư sau chuyển: ${_formatCurrency(state.fromWallet!.balance - _parsedAmount)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isInsufficient ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotEnoughWallets(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.textSecondary(context),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Cần ít nhất 2 ví',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn cần có ít nhất 2 ví để thực hiện chuyển tiền',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary(context), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(TransferState state, BuildContext context) {
    final canTransfer =
        state.fromWallet != null &&
        state.toWallet != null &&
        state.fromWallet!.id != state.toWallet!.id &&
        _parsedAmount > 0 &&
        _parsedAmount <= (state.fromWallet?.balance ?? 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canTransfer && !state.isSaving ? _onTransfer : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.border(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: state.isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Xác nhận chuyển tiền',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatCurrency(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return '$formatted đ';
  }

  String _shortCurrency(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted đ';
  }
}
