import 'package:expense_manager_app/core/services/rtdb_service.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thất bại: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã có lỗi xảy ra. Vui lòng thử lại.')),
      );
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
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đăng nhập thất bại: $e')));
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Image.asset(
                    'assets/images/logo_app.png',
                    // Hoặc file logo riêng của anh
                    height: 120, // Anh có thể chỉnh kích thước lớn nhỏ tùy ý
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Ví Khôn',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(
                        0xFF2D4BFF,
                      ), // Cho màu xanh cho đồng bộ với nút
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form đăng nhập
                  // CustomTextField(
                  //   hintText: 'Email',
                  //   prefixIcon: Icons.person_outline,
                  //   controller: _emailController,
                  // ),
                  // const SizedBox(height: 16),
                  // CustomTextField(
                  //   hintText: 'Mật khẩu',
                  //   prefixIcon: Icons.lock_outline,
                  //   controller: _passwordController,
                  //   isPassword: true,
                  //   suffixIcon: const Icon(
                  //     Icons.visibility_outlined,
                  //     color: Colors.grey,
                  //   ),
                  // ),
                  const SizedBox(height: 32),

                  // PrimaryButton(
                  //   text: 'ĐĂNG NHẬP',
                  //   onPressed: _isLoading ? null : _handleLogin,
                  // ),
                  // const SizedBox(height: 24),
                  // TextButton(
                  //   onPressed: _isLoading
                  //       ? null
                  //       : () {
                  //           Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (_) => const CreateNewPasswordPage(),
                  //             ),
                  //           );
                  //         },
                  //   child: const Text(
                  //     'QUÊN MẬT KHẨU?',
                  //     style: TextStyle(
                  //       color: Color(0xFF7D7E83),
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),

                  // const SizedBox(height: 24),
                  // const Text('Hoặc', style: TextStyle(color: Colors.grey)),
                  // const SizedBox(height: 24),
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
                      const Text('Chưa có tài khoản? '),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RegisterPage(),
                                  ),
                                );
                              },
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: Color(0xFF2D4BFF),
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
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF2D4BFF)),
            ),
          ),
      ],
    );
  }
}
