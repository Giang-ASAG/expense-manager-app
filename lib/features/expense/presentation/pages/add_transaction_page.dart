import 'package:expense_manager_app/core/services/rtdb_service.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:expense_manager_app/features/expense/data/models/category_model.dart';
import 'package:expense_manager_app/features/expense/data/models/wallet_model.dart';
import 'package:expense_manager_app/features/expense/presentation/providers/add_transaction_page.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/transaction_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  const AddTransactionPage({super.key, required this.isExpense});

  final bool isExpense;

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUid();
    // Set giá trị ban đầu từ param
    Future.microtask(() {
      ref
          .read(addTransactionProvider.notifier)
          .setExpenseType(widget.isExpense);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadUid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userId = prefs.getString('user_uid'));
  }

  Future<void> _onSave() async {
    if (_userId == null) return;

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showSnackBar('Vui lòng nhập số tiền');
      return;
    }

    final double amount;
    try {
      amount = double.parse(amountText);
      if (amount <= 0) {
        _showSnackBar('Số tiền phải lớn hơn 0');
        return;
      }
    } catch (_) {
      _showSnackBar('Số tiền không hợp lệ');
      return;
    }

    final name = _nameController.text.trim().isEmpty
        ? ref.read(addTransactionProvider).selectedCategory
        : _nameController.text.trim();

    final error = await ref
        .read(addTransactionProvider.notifier)
        .save(uid: _userId!, name: name, amount: amount);

    if (!mounted) return;

    if (error != null) {
      _showSnackBar(error, isError: true);
    } else {
      Navigator.pop(context);
      _showSnackBar('Lưu giao dịch thành công!');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addTransactionProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
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
          'Giao dịch mới',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _userId == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildTypeToggle(state, context),
                        const SizedBox(height: 24),
                        _buildInputGroup(context),
                        const SizedBox(height: 20),
                        _buildWalletSelector(state, context),
                        if (state.isExpense) ...[
                          const SizedBox(height: 20),
                          TransactionImagePicker(
                            onImageChanged: (file) => ref
                                .read(addTransactionProvider.notifier)
                                .setImage(file),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _buildCategorySection(state, context),
                        // ✅ Add spacing để tránh bị che bởi save button
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(top: false, child: _buildSaveButton(state, context)),
    );
  }

  Widget _buildTypeToggle(AddTransactionState state, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.border(context).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _toggleItem('Chi phí', state.isExpense, AppColors.danger, context),
          _toggleItem('Thu nhập', !state.isExpense, AppColors.success, context),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool isActive, Color activeColor, BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref
            .read(addTransactionProvider.notifier)
            .setExpenseType(label == 'Chi phí'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          _buildTextField(
            Icons.description_outlined,
            'Tên giao dịch',
            controller: _nameController,
            context: context,
          ),
          Divider(height: 1, color: AppColors.border(context)),
          _buildTextField(
            Icons.attach_money,
            'Số tiền',
            isNumber: true,
            controller: _amountController,
            context: context,
          ),
          Divider(height: 1, color: AppColors.border(context)),
          _buildTextField(
            Icons.calendar_today_outlined,
            '24/03/2026',
            isReadOnly: true,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    required BuildContext context,
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
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(context),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textSecondary(context),
          fontSize: 15,
        ),
        prefixIcon: Icon(icon, color: AppColors.textSecondary(context), size: 22),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        filled: false,
      ),
    );
  }

  Widget _buildWalletSelector(AddTransactionState state, BuildContext context) {
    return StreamBuilder<List<WalletModel>>(
      stream: RTDBService().getWalletsStream(_userId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Vui lòng tạo ví trước');
        }

        final wallets = snapshot.data!;

        // Set ví mặc định nếu chưa có
        if (state.selectedWalletId == null) {
          Future.microtask(
            () => ref
                .read(addTransactionProvider.notifier)
                .setWallet(wallets.first.id),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.selectedWalletId ?? wallets.first.id,
              isExpanded: true,
              dropdownColor: AppColors.surface(context),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.textSecondary(context),
              ),
              items: wallets.map((wallet) {
                return DropdownMenuItem<String>(
                  value: wallet.id,
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${wallet.bankName} (${wallet.balance})',
                        style: TextStyle(color: AppColors.textPrimary(context)),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(addTransactionProvider.notifier).setWallet(val);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(AddTransactionState state, BuildContext context) {
    return StreamBuilder<List<CategoryModel>>(
      stream: RTDBService().getCategoriesStream(_userId!, state.isExpense),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
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
          itemBuilder: (ctx, index) {
            final category = categories[index];
            final isSelected = state.selectedCategory == category.name;
            return GestureDetector(
              onTap: () => ref
                  .read(addTransactionProvider.notifier)
                  .setCategory(category.name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? category.color : AppColors.surface(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.border(context),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: category.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
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
                            : AppColors.textPrimary(context),
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

  Widget _buildSaveButton(AddTransactionState state, BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: state.isSaving ? null : _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: state.isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Lưu giao dịch',
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
}
