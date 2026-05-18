import 'package:expense_manager_app/core/services/banks_service.dart';
import 'package:expense_manager_app/core/services/rtdb_service.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:expense_manager_app/features/expense/data/models/wallet_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddWalletBottomSheet extends StatefulWidget {
  final String userId;

  const AddWalletBottomSheet({super.key, required this.userId});

  @override
  State<AddWalletBottomSheet> createState() => _AddWalletBottomSheetState();
}

class _AddWalletBottomSheetState extends State<AddWalletBottomSheet> {
  late Future<List<BankModel>> _banksFuture;
  BankModel? _selectedBank;
  final _balanceController = TextEditingController();
  final _accountNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _banksFuture = BanksService.getBanks();
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  String _formatVND(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    return digits.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  double _parseVND(String formatted) {
    return double.tryParse(formatted.replaceAll('.', '')) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      // ✅ FIX: Bọc Column trong SingleChildScrollView để tránh overflow khi keyboard bật
      child: SingleChildScrollView(
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
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thêm ví mới',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.background(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textPrimary(context),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bank Dropdown
            _buildBankDropdown(context),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _accountNameController,
              label: 'Tên tài khoản',
              hint: 'VD: Ví chính, Tài khoản tiết kiệm',
              icon: Icons.label_outline,
              context: context,
            ),
            const SizedBox(height: 16),

            _buildBalanceField(context),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading || _selectedBank == null
                    ? null
                    : _handleCreateWallet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Tạo ví',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Bank Dropdown with FutureBuilder
  Widget _buildBankDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tên ngân hàng',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<BankModel>>(
          future: _banksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Text(
                'Lỗi tải danh sách ngân hàng: ${snapshot.error}',
                style: const TextStyle(color: AppColors.danger),
              );
            }

            final banks = snapshot.data ?? [];
            if (banks.isEmpty) {
              return Text(
                'Không có dữ liệu ngân hàng',
                style: TextStyle(color: AppColors.textSecondary(context)),
              );
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.background(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedBank != null
                      ? AppColors.primary
                      : AppColors.border(context),
                  width: _selectedBank != null ? 1.5 : 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BankModel>(
                  isExpanded: true,
                  value: _selectedBank,
                  dropdownColor: Theme.of(context).cardColor,
                  hint: Row(
                    children: [
                      Icon(
                        Icons.account_balance_outlined,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Chọn ngân hàng',
                        style: TextStyle(color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                  items: banks.map((bank) {
                    return DropdownMenuItem<BankModel>(
                      value: bank,
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.textSecondary(context),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              bank.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (BankModel? newValue) {
                    setState(() => _selectedBank = newValue);
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ✅ CLEAN: Tách balance field thành method riêng cho gọn
  Widget _buildBalanceField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Số dư ban đầu',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _balanceController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            final formatted = _formatVND(value);
            _balanceController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          },
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: '0',
            prefixIcon: Icon(
              Icons.payments_outlined,
              color: AppColors.textSecondary(context),
            ),
            suffixText: 'đ',
            suffixStyle: TextStyle(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: AppColors.background(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required BuildContext context,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColors.textPrimary(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSecondary(context)),
            prefixIcon: Icon(icon, color: AppColors.textSecondary(context)),
            filled: true,
            fillColor: AppColors.background(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleCreateWallet() async {
    if (_selectedBank == null || _balanceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng chọn ngân hàng và nhập số dư'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newWallet = WalletModel(
        id: '',
        bankName: _selectedBank!.name,
        accountName: _accountNameController.text.trim().isEmpty
            ? 'Ví chính'
            : _accountNameController.text.trim(),
        balance: _parseVND(_balanceController.text),
        isDefault: false,
      );

      await RTDBService().addNewWallet(widget.userId, newWallet);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
