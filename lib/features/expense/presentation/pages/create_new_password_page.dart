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
      backgroundColor: Colors.white,
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
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE8E9EA)),
                  ),
                  child: const Icon(Icons.chevron_left, color: Color(0xFF1A1D1E)),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Create Your New\nPassword',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D1E),
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'Your new password must be different\nfrom previous password.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7D7E83),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // New Password Field
              CustomTextField(
                hintText: 'New Password',
                prefixIcon: Icons.lock_outline,
                isPassword: _obscureNew,
                controller: _newPasswordController,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscureNew = !_obscureNew),
                  child: Icon(
                    _obscureNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Confirm Password Field
              CustomTextField(
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                isPassword: _obscureConfirm,
                controller: _confirmPasswordController,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  child: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),

              // const SizedBox(height: 24),
              //
              // // Validation Rules
              // _ValidationRule(
              //   label: 'Must not contain your name or email',
              //   isValid: _hasNoNameOrEmail,
              //   isActive: _newPasswordController.text.isNotEmpty,
              // ),
              // const SizedBox(height: 10),
              // _ValidationRule(
              //   label: 'At least 8 characters',
              //   isValid: _hasMinLength,
              //   isActive: _newPasswordController.text.isNotEmpty,
              // ),
              // const SizedBox(height: 10),
              // _ValidationRule(
              //   label: 'Contains a symbol or a number',
              //   isValid: _hasSymbolOrNumber,
              //   isActive: _newPasswordController.text.isNotEmpty,
              // ),

              const Spacer(),

              // Reset Password Button
              PrimaryButton(
                text: 'RESET PASSWORD',
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
    isActive && isValid ? const Color(0xFF2D4BFF) : const Color(0xFF7D7E83);

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