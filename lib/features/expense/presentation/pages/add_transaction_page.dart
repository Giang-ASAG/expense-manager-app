import 'package:expense_manager_app/core/services/rtdb_service.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:expense_manager_app/features/expense/data/models/category_model.dart';
import 'package:expense_manager_app/features/expense/data/models/wallet_model.dart'; // Đảm bảo đúng đường dẫn model
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key, required this.isExpense});

  final bool isExpense;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  // 1. Controllers & State
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  late bool isExpense = widget.isExpense;
  String selectedCategory = 'Ăn uống';
  String? userId;
  String? selectedWalletId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUid();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // 2. Logic lấy UID từ máy
  Future<void> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_uid');
    });
  }

  // 3. Hàm xử lý khi bấm nút LƯU
  Future<void> _onSave() async {
    if (userId == null || selectedWalletId == null) return;

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số tiền')));
      return;
    }

    final double amount;
    try {
      amount = double.parse(amountText);
      if (amount <= 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Số tiền phải lớn hơn 0')));
        return;
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số tiền không hợp lệ')));
      return;
    }

    // ✅ Kiểm tra số dư nếu là chi phí
    if (isExpense) {
      final currentBalance = await RTDBService().getWalletBalance(
        userId!,
        selectedWalletId!,
      );

      if (amount > currentBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Số dư không đủ! Hiện có: ${currentBalance.toStringAsFixed(0)}₫',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final String name = _nameController.text.trim().isEmpty
          ? selectedCategory
          : _nameController.text.trim();

      await RTDBService().saveTransaction(
        uid: userId!,
        walletId: selectedWalletId!,
        amount: amount,
        category: selectedCategory,
        name: name,
        isExpense: isExpense,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu giao dịch thành công!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xảy ra lỗi, thử lại!')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Giao dịch mới',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildTypeToggle(),
                        const SizedBox(height: 24),
                        _buildInputGroup(),
                        const SizedBox(height: 20),
                        _buildWalletSelector(),
                        const SizedBox(height: 24),
                        _buildCategorySection(),
                      ],
                    ),
                  ),
                ),
                _buildSaveButton(),
              ],
            ),
    );
  }

  // --- UI Components ---

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _toggleItem('Chi phí', isExpense, AppColors.danger),
          _toggleItem('Thu nhập', !isExpense, AppColors.success),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool isActive, Color activeColor) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isExpense = (label == 'Chi phí')),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildTextField(
            Icons.description_outlined,
            'Tên giao dịch',
            controller: _nameController,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildTextField(
            Icons.attach_money,
            'Số tiền',
            isNumber: true,
            controller: _amountController,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildTextField(
            Icons.calendar_today_outlined,
            '24/03/2026',
            isReadOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isNumber = false,
    bool isReadOnly = false,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      readOnly: isReadOnly,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
        ),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildWalletSelector() {
    return StreamBuilder<List<WalletModel>>(
      stream: RTDBService().getWalletsStream(userId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("Vui lòng tạo ví trước");
        }

        final wallets = snapshot.data!;
        selectedWalletId ??= wallets.first.id;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedWalletId,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary,
              ),
              items: wallets.map((wallet) {
                return DropdownMenuItem<String>(
                  value: wallet.id,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${wallet.bankName} (${wallet.balance})",
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedWalletId = val),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection() {
    return StreamBuilder<List<CategoryModel>>(
      stream: RTDBService().getCategoriesStream(userId!, isExpense),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final categories = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            bool isSelected = selectedCategory == category.name;

            return GestureDetector(
              onTap: () => setState(() => selectedCategory = category.name),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? category.color : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.iconData,
                      color: isSelected ? Colors.white : category.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.name,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Lưu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
