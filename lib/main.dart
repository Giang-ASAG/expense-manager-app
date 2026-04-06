import 'package:expense_manager_app/core/database/database_helper.dart';
import 'package:expense_manager_app/core/services/notification_service.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/login_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/main_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/onboarding_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/overview_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Khởi tạo Firebase
  await Firebase.initializeApp();
  // --- THÊM DÒNG NÀY ---
  // Khởi tạo DatabaseHelper và gọi getter database để nó chạy hàm copy
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  await initializeDateFormatting('vi', null);
  await NotificationService.init();
  await NotificationService.scheduleDailyReminder();
  // Khởi tạo Dependency Injection (get_it)
  // await di.init();
  final prefs = await SharedPreferences.getInstance();
  // Nếu chưa từng lưu 'is_first_time', mặc định nó sẽ là true (lần đầu)
  final bool isFirstTime = prefs.getBool('is_first_time') ?? true;
  runApp(
    ProviderScope(
      // ✅ thêm vào đây
      child: MyApp(isFirstTime: isFirstTime),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ví Khôn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Logic phân luồng ở đây
      home: isFirstTime
          ? const OnboardingPage()
          : StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                // Nếu đang kiểm tra trạng thái thì hiện loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // Nếu snapshot.hasData nghĩa là đã đăng nhập trước đó rồi
                if (snapshot.hasData) {
                  final user = snapshot.data!;
                  return MainPage(user: user); // <--- Vào thẳng trang chủ
                }
                // Nếu chưa đăng nhập hoặc đã logout thì hiện trang Login
                return const LoginPage();
              },
            ),
    );
  }
}
