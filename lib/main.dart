import 'package:expense_manager_app/core/services/notification_service.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/login_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/onboarding_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Khởi tạo Firebase
  await Firebase.initializeApp();
  await initializeDateFormatting('vi', null);
  await NotificationService.init();
  await NotificationService.scheduleDailyReminder();
  // Khởi tạo Dependency Injection (get_it)
  // await di.init();
  final prefs = await SharedPreferences.getInstance();
  // Nếu chưa từng lưu 'is_first_time', mặc định nó sẽ là true (lần đầu)
  final bool isFirstTime = prefs.getBool('is_first_time') ?? true;

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  const MyApp({super.key, required this.isFirstTime});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Chi Tiêu',
      debugShowCheckedModeBanner: false, // Ẩn dải băng DEBUG góc phải trên cùng
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true, // Kích hoạt giao diện Material Design 3
      ),
      // Đặt màn hình khởi chạy đầu tiên là OnboardingPage
      home: isFirstTime ? const OnboardingPage() : const LoginPage(),
    );
  }
}
