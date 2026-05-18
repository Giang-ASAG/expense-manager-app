import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';

class CreateNewPasswordPage extends StatefulWidget {
  const CreateNewPasswordPage({super.key});

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Validation states
  bool get _hasNoNameOrEmail =>
      _newPasswordController.text.isNotEmpty &&
          !_newPasswordController.text.contains('@');

  bool get _hasMinLength => _newPasswordController.text.length >= 8;

  bool get _hasSymbolOrNumber =>
      _newPasswordController.text.contains(RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]'));

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Icon(Icons.chevron_left, color: AppColors.textPrimary(context)),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Tạo mật khẩu mới',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Mật khẩu mới của bạn phải khác với các mật khẩu đã sử dụng trước đó.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // New Password Field
              CustomTextField(
                hintText: 'Mật khẩu mới',
                prefixIcon: Icons.lock_outline,
                isPassword: _obscureNew,
                controller: _newPasswordController,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscureNew = !_obscureNew),
                  child: Icon(
                    _obscureNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Confirm Password Field
              CustomTextField(
                hintText: 'Xác nhận mật khẩu',
                prefixIcon: Icons.lock_outline,
                isPassword: _obscureConfirm,
                controller: _confirmPasswordController,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  child: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),

              const Spacer(),

              // Reset Password Button
              PrimaryButton(
                text: 'ĐẶT LẠI MẬT KHẨU',
                onPressed: () {
                  // TODO: Handle reset password
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Validation Rule Widget ──────────────────────────────────────────────────

class _ValidationRule extends StatelessWidget {
  final String label;
  final bool isValid;
  final bool isActive;

  const _ValidationRule({
    required this.label,
    required this.isValid,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor =
    isActive && isValid ? AppColors.primary : AppColors.textSecondary(context);

    return Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 20,
          color: activeColor,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: activeColor,
            fontWeight: isActive && isValid ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}