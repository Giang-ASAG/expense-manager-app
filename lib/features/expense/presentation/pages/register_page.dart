import 'package:expense_manager_app/features/expense/data/datasources/auth_remote_data_source.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/overview_page.dart';
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
            builder: (_) => OverviewPage(user: credential.user),
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
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                _buildHeader(),
                const SizedBox(height: 32),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 20),
                _buildTermsCheckbox(),
                const SizedBox(height: 24),
                _buildRegisterButton(),
                const SizedBox(height: 24),
                const Center(
                  child: Text('Hoặc', style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 24),
                SocialButton(
                  text: 'TIẾP TỤC VỚI GOOGLE',
                  iconPath: 'assets/images/google_icon.png',
                  onPressed: () {},
                ),
                const SizedBox(height: 32),
                _buildLoginLink(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildHeader() => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Tạo tài khoản\nmới',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1D1E),
          height: 1.3,
        ),
      ),
      SizedBox(height: 8),
      Text(
        'Điền thông tin bên dưới để bắt đầu.',
        style: TextStyle(fontSize: 14, color: Color(0xFF7D7E83)),
      ),
    ],
  );

  Widget _buildEmailField() => CustomTextField(
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

  Widget _buildPasswordField() => CustomTextField(
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

  Widget _buildConfirmPasswordField() => CustomTextField(
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

  Widget _buildTermsCheckbox() => Row(
    children: [
      Checkbox(
        value: _agreeToTerms,
        activeColor: const Color(0xFF2D4BFF),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onChanged: (value) =>
            setState(() => _agreeToTerms = value ?? false),
      ),
      Expanded(
        child: RichText(
          text: const TextSpan(
            text: 'Tôi đồng ý với ',
            style: TextStyle(color: Color(0xFF7D7E83), fontSize: 13),
            children: [
              TextSpan(
                text: 'Điều khoản dịch vụ',
                style: TextStyle(
                  color: Color(0xFF2D4BFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: ' và '),
              TextSpan(
                text: 'Chính sách bảo mật',
                style: TextStyle(
                  color: Color(0xFF2D4BFF),
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

  Widget _buildLoginLink() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text('Đã có tài khoản? '),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Text(
          'Đăng nhập',
          style: TextStyle(
            color: Color(0xFF2D4BFF),
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
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE8E9EA)),
        ),
        child: const Icon(Icons.chevron_left, color: Color(0xFF1A1D1E)),
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
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Colors.grey,
      ),
    );
  }
}