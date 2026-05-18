import 'package:expense_manager_app/core/services/rtdb_service.dart';
import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:expense_manager_app/features/expense/data/datasources/auth_remote_data_source.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/create_new_password_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/register_page.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/custom_text_field.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/main_page.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/primary_button.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/social_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _authDataSource = AuthRemoteDataSource();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
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

  Future<void> _handleLogin() async {
    try {
      _setLoading(true);

      final credential = await _authDataSource.signInEmailPwd(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (credential.user != null) {
        final uid = credential.user!.uid;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_uid', uid);
        await prefs.setBool('is_logged_in', true);
        await RTDBService().initUserData(uid);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainPage(user: credential.user)),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnackBar('Đăng nhập thất bại: ${e.message}', isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Đã có lỗi xảy ra. Vui lòng thử lại.', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      _setLoading(true);

      final userCredential = await _authDataSource.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        final uid = userCredential.user!.uid;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_uid', uid);

        await RTDBService().initUserData(uid);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainPage(user: userCredential.user!),
          ),
        );
      } else {
        if (!mounted) return;
        _showSnackBar('Đăng nhập Google bị hủy bỏ');
      }
    } on Exception catch (e) {
      if (!mounted) return;

      // Xử lý các loại lỗi khác nhau
      String errorMessage = 'Đăng nhập thất bại';

      if (e.toString().contains('DEVELOPER_ERROR')) {
        errorMessage =
            'Lỗi Firebase: Cấu hình Google Sign-In chưa đúng. Vui lòng kiểm tra SHA-1 fingerprint trong Firebase Console.';
      } else if (e.toString().contains('sign_in_failed')) {
        errorMessage =
            'Google Sign-In thất bại. Vui lòng thử lại hoặc kiểm tra kết nối mạng.';
      } else if (e.toString().contains('NETWORK_ERROR')) {
        errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra Internet.';
      } else if (e.toString().contains('CANCELED')) {
        errorMessage = 'Người dùng hủy bỏ đăng nhập';
      } else {
        errorMessage = 'Lỗi: ${e.toString()}';
      }

      _showSnackBar(errorMessage, isError: true);
      print('Google Login Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background(context),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/images/logo_app.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Ví Khôn',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form đăng nhập
                  CustomTextField(
                    hintText: 'Email',
                    prefixIcon: Icons.person_outline,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hintText: 'Mật khẩu',
                    prefixIcon: Icons.lock_outline,
                    controller: _passwordController,
                    isPassword: _obscurePassword,
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  PrimaryButton(
                    text: 'ĐĂNG NHẬP',
                    onPressed: _isLoading ? null : _handleLogin,
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreateNewPasswordPage(),
                              ),
                            );
                          },
                    child: Text(
                      'QUÊN MẬT KHẨU?',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  // Đăng nhập Google
                  SocialButton(
                    text: 'TIẾP TỤC VỚI GOOGLE',
                    iconPath: 'assets/images/google_icon.png',
                    onPressed: _isLoading ? null : _handleGoogleLogin,
                  ),

                  const SizedBox(height: 40),

                  // Chưa có tài khoản
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: TextStyle(color: AppColors.textPrimary(context)),
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                              },
                        child: Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
