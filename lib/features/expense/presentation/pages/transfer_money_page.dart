import 'package:expense_manager_app/core/services/rtdb_service.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:expense_manager_app/features/expense/data/models/wallet_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransferMoneyPage extends StatefulWidget {
  const TransferMoneyPage({super.key});

  @override
  State<TransferMoneyPage> createState() => _TransferMoneyPageState();
}

class _TransferMoneyPageState extends State<TransferMoneyPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _userId;
  List<WalletModel> _wallets = [];
  WalletModel? _fromWallet;
  WalletModel? _toWallet;
  bool _isLoading = false;
  bool _isWalletsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndWallets();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndWallets() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('user_uid');
    if (uid == null) return;

    setState(() => _userId = uid);

    // Lắng nghe stream ví từ Firebase
    RTDBService().getWalletsStream(uid).first.then((wallets) {
      if (!mounted) return;
      setState(() {
        _wallets = wallets;
        _isWalletsLoading = false;
        // Tự động chọn ví mặc định hoặc ví đầu tiên
        if (wallets.isNotEmpty) {
          _fromWallet = wallets.firstWhere(
                (w) => w.isDefault,
            orElse: () => wallets.first,
          );
        }
        if (wallets.length >= 2) {
          _toWallet = wallets.firstWhere(
                (w) => w.id != _fromWallet?.id,
            orElse: () => wallets[1],
          );
        }
      });
    });
  }

  void _swapWallets() {
    setState(() {
      final temp = _fromWallet;
      _fromWallet = _toWallet;
      _toWallet = temp;
    });
  }

  double get _parsedAmount =>
      double.tryParse(_amountController.text.trim()) ?? 0.0;

  bool get _canTransfer {
    if (_fromWallet == null || _toWallet == null) return false;
    if (_fromWallet!.id == _toWallet!.id) return false;
    if (_parsedAmount <= 0) return false;
    if (_parsedAmount > _fromWallet!.balance) return false;
    return true;
  }

  Future<void> _onTransfer() async {
    if (!_canTransfer || _userId == null) return;

    setState(() => _isLoading = true);
    try {
      await RTDBService().transferMoney(
        uid: _userId!,
        fromWalletId: _fromWallet!.id,
        toWalletId: _toWallet!.id,
        amount: _parsedAmount,
        note: "Chuyển tiền",
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Chuyển tiền thành công!',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Wallet Picker Bottom Sheet ───────────────────────────────────────────

  void _showWalletPicker({required bool isFrom}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isFrom ? 'Chọn ví nguồn' : 'Chọn ví đích',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ..._wallets.map((wallet) {
                final isSelected = isFrom
                    ? _fromWallet?.id == wallet.id
                    : _toWallet?.id == wallet.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isFrom) {
                        _fromWallet = wallet;
                      } else {
                        _toWallet = wallet;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.08)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor:
                          AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.account_balance_wallet,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wallet.accountName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                wallet.bankName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatCurrency(
                                  wallet.balance, wallet.currency),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (wallet.isDefault)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                  AppColors.success.withOpacity(0.1),
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
                          const Icon(Icons.check_circle,
                              color: AppColors.primary, size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.close,
                  color: AppColors.textPrimary, size: 20),
            ),
          ),
        ),
        title: const Text(
          'Chuyển tiền',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isWalletsLoading
          ? const Center(child: CircularProgressIndicator())
          : _wallets.length < 2
          ? _buildNotEnoughWallets()
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTransferCard(),
                  const SizedBox(height: 24),
                  _buildAmountInput(),
                  const SizedBox(height: 16),
                  _buildNoteInput(),
                  const SizedBox(height: 16),
                  _buildBalanceInfo(),
                ],
              ),
            ),
          ),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  // ── Transfer Card ────────────────────────────────────────────────────────

  Widget _buildTransferCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              _buildWalletSelector(
                label: 'Từ ví',
                wallet: _fromWallet,
                icon: Icons.outbox_rounded,
                color: AppColors.danger,
                isFrom: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: AppColors.border),
              ),
              _buildWalletSelector(
                label: 'Đến ví',
                wallet: _toWallet,
                icon: Icons.move_to_inbox_rounded,
                color: AppColors.success,
                isFrom: false,
              ),
            ],
          ),
          // Nút swap ở giữa
          GestureDetector(
            onTap: _swapWallets,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
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
    required bool isFrom,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showWalletPicker(isFrom: isFrom),
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
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    wallet?.accountName ?? 'Chọn ví',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: wallet != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (wallet != null)
                    Text(
                      wallet.bankName,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            if (wallet != null)
              Text(
                _formatCurrency(wallet.balance, wallet.currency),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // ── Amount Input ─────────────────────────────────────────────────────────

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Số tiền chuyển',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
            decoration: InputDecoration(
              hintText: '0',
              suffixText: 'đ',
              border: InputBorder.none,
            ),
          ),
          // Quick amounts
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
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          _shortCurrency(amount),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
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

  // ── Balance Info ─────────────────────────────────────────────────────────

  Widget _buildBalanceInfo() {
    if (_fromWallet == null || _parsedAmount <= 0) {
      return const SizedBox.shrink();
    }

    final isInsufficient = _parsedAmount > _fromWallet!.balance;
    final color = isInsufficient ? AppColors.danger : AppColors.success;
    final icon = isInsufficient
        ? Icons.error_outline
        : Icons.check_circle_outline;
    final msg = isInsufficient
        ? 'Số dư không đủ (còn ${_formatCurrency(_fromWallet!.balance, _fromWallet!.currency)})'
        : 'Số dư sau chuyển: ${_formatCurrency(_fromWallet!.balance - _parsedAmount, _fromWallet!.currency)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Note Input ───────────────────────────────────────────────────────────

  Widget _buildNoteInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _noteController,
        decoration: const InputDecoration(
          icon: Icon(Icons.notes, color: AppColors.textSecondary),
          hintText: 'Ghi chú chuyển khoản',
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ── Not Enough Wallets ───────────────────────────────────────────────────

  Widget _buildNotEnoughWallets() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.account_balance_wallet_outlined,
                  color: AppColors.textSecondary, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cần ít nhất 2 ví',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn cần có ít nhất 2 ví để thực hiện chuyển tiền',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── Confirm Button ───────────────────────────────────────────────────────

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _canTransfer && !_isLoading ? _onTransfer : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.border,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5),
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

  // ── Helpers ──────────────────────────────────────────────────────────────

  // Định dạng VNĐ: 1.500.000 đ
  String _formatCurrency(double amount, [String? _]) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$formatted đ';
  }

  // Nút quick amount: 50.000, 100.000, ...
  String _shortCurrency(int amount) {
    final formatted = amount
        .toString()
        .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$formatted đ';
  }
}
