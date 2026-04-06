import 'package:expense_manager_app/features/expense/domain/entities/onboarding_entity.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/login_page.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/onboarding_content.dart';
// import domain/entities/onboarding_entity.dart

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  // Dữ liệu giả lập cho 3 bước onboarding
  final List<OnboardingEntity> _onboardingData = [
    OnboardingEntity(
      title: 'Quản Lý Chi Tiêu',
      description:
          'Ghi chép và theo dõi mọi khoản chi tiêu hàng ngày của bạn một cách dễ dàng.',
      imagePath: 'assets/images/onboarding1.png',
    ),
    OnboardingEntity(
      title: 'Phân Tích Thông Minh',
      description:
          'Xem lịch sử để hiểu rõ thói quen tiêu dùng của bản thân.',
      imagePath: 'assets/images/onboarding2.png',
    ),
    OnboardingEntity(
      title: 'Đồng Bộ Đám Mây',
      description:
          'Dữ liệu được lưu trữ an toàn trên Firebase, truy cập mọi lúc mọi nơi.',
      imagePath: 'assets/images/onboarding3.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose(); // Đừng quên dispose để tránh rò rỉ bộ nhớ
    super.dispose();
  }

  void _onNext() async {
    if (_currentPage == _onboardingData.length - 1) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_first_time', false);

      if (!mounted) return; // Thêm kiểm tra mounted để tránh lỗi nếu người dùng thoát app nhanh

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400), // Tăng lên 400ms cho mượt
        curve: Curves.easeInOut, // Hiệu ứng mượt hơn easeIn
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _onboardingData.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => OnboardingContent(
                title: _onboardingData[index].title,
                description: _onboardingData[index].description,
                imagePath: _onboardingData[index].imagePath,
              ),
            ),
          ),
          // Indicator (Dấu chấm)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => _buildDot(index)),
          ),
          const SizedBox(height: 40),
          // Nút LET'S GO
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: 64,
            ),
            child: PrimaryButton(
              text: _currentPage == 2 ? "BẮT ĐẦU NGAY" : "TIẾP TỤC",
              onPressed: _onNext,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 6, // Tăng độ dày một chút cho dễ nhìn
      width: _currentPage == index ? 24 : 8, // Hiệu ứng thanh dài thanh ngắn
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF2D4BFF)
            : const Color(0xFFE8E9EA),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
