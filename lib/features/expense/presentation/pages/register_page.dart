import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:expense_manager_app/features/expense/data/datasources/auth_remote_data_source.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/main_page.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/custom_text_field.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/primary_button.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/social_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authDataSource = AuthRemoteDataSource();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Logic ────────────────────────────────────────────────────────────────

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      _showError('Vui lòng đồng ý với điều khoản sử dụng.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await _authDataSource.signUpEmailPwd(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (credential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainPage(user: credential.user),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(_mapFirebaseError(e.code));
    } catch (e) {
      if (!mounted) return;
      _showError('Đã có lỗi xảy ra. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapFirebaseError(String code) {
    return switch (code) {
      'email-already-in-use' => 'Email này đã được sử dụng.',
      'invalid-email' => 'Email không hợp lệ.',
      'weak-password' => 'Mật khẩu quá yếu (tối thiểu 6 ký tự).',
      _ => 'Đăng ký thất bại. Vui lòng thử lại.',
    };
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _BackButton(),
                const SizedBox(height: 32),
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildEmailField(context),
                const SizedBox(height: 16),
                _buildPasswordField(context),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(context),
                const SizedBox(height: 20),
                _buildTermsCheckbox(context),
                const SizedBox(height: 24),
                _buildRegisterButton(),
                const SizedBox(height: 24),
                Center(
                  child: Text('Hoặc', style: TextStyle(color: AppColors.textSecondary(context))),
                ),
                const SizedBox(height: 24),
                SocialButton(
                  text: 'TIẾP TỤC VỚI GOOGLE',
                  iconPath: 'assets/images/google_icon.png',
                  onPressed: () {
                    // TODO: Google Sign up
                  },
                ),
                const SizedBox(height: 32),
                _buildLoginLink(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Tạo tài khoản\nmới',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary(context),
          height: 1.3,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Điền thông tin bên dưới để bắt đầu.',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context)),
      ),
    ],
  );

  Widget _buildEmailField(BuildContext context) => CustomTextField(
    hintText: 'Email',
    prefixIcon: Icons.email_outlined,
    controller: _emailController,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Vui lòng nhập email.';
      }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
        return 'Email không hợp lệ.';
      }
      return null;
    },
  );

  Widget _buildPasswordField(BuildContext context) => CustomTextField(
    hintText: 'Mật khẩu',
    prefixIcon: Icons.lock_outline,
    controller: _passwordController,
    isPassword: _obscurePassword,
    suffixIcon: _ToggleVisibilityIcon(
      obscure: _obscurePassword,
      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu.';
      if (value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự.';
      return null;
    },
  );

  Widget _buildConfirmPasswordField(BuildContext context) => CustomTextField(
    hintText: 'Xác nhận mật khẩu',
    prefixIcon: Icons.lock_outline,
    controller: _confirmPasswordController,
    isPassword: _obscureConfirm,
    suffixIcon: _ToggleVisibilityIcon(
      obscure: _obscureConfirm,
      onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
    ),
    validator: (value) {
      if (value != _passwordController.text) {
        return 'Mật khẩu không khớp.';
      }
      return null;
    },
  );

  Widget _buildTermsCheckbox(BuildContext context) => Row(
    children: [
      Checkbox(
        value: _agreeToTerms,
        activeColor: AppColors.primary,
        checkColor: Colors.white,
        side: BorderSide(color: AppColors.border(context), width: 1.5),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onChanged: (value) =>
            setState(() => _agreeToTerms = value ?? false),
      ),
      Expanded(
        child: RichText(
          text: TextSpan(
            text: 'Tôi đồng ý với ',
            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13),
            children: [
              const TextSpan(
                text: 'Điều khoản dịch vụ',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: ' và '),
              const TextSpan(
                text: 'Chính sách bảo mật',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildRegisterButton() => PrimaryButton(
    text: _isLoading ? 'ĐANG XỬ LÝ...' : 'ĐĂNG KÝ',
    onPressed: (_agreeToTerms && !_isLoading) ? _handleRegister : null,
  );

  Widget _buildLoginLink(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text('Đã có tài khoản? ', style: TextStyle(color: AppColors.textPrimary(context))),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Text(
          'Đăng nhập',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

// ── Private reusable widgets ─────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }
}

class _ToggleVisibilityIcon extends StatelessWidget {
  const _ToggleVisibilityIcon({required this.obscure, required this.onTap});

  final bool obscure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textSecondary(context),
      ),
    );
  }
}