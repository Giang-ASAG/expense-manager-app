import 'package:expense_manager_app/core/database/database_helper.dart';
import 'package:expense_manager_app/core/services/notification_service.dart';
import 'package:expense_manager_app/core/style/app_theme.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/login_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/main_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/onboarding_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase với timeout
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 10));
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  // Khởi tạo DatabaseHelper
  try {
    final dbHelper = DatabaseHelper();
    await dbHelper.database;
  } catch (e) {
    print('Database initialization error: $e');
  }

  // Khởi tạo date formatting
  try {
    await initializeDateFormatting('vi', null);
  } catch (e) {
    print('Date formatting initialization error: $e');
  }

  // Khởi tạo Notification Service
  try {
    await NotificationService.init();
    // Schedule daily reminder - bọc trong try-catch riêng
    try {
      await NotificationService.scheduleDailyReminder().timeout(
        const Duration(seconds: 5),
      );
    } catch (e) {
      print('Notification scheduling error: $e');
    }
  } catch (e) {
    print('Notification initialization error: $e');
  }

  // Lấy SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('is_first_time') ?? true;

  runApp(ProviderScope(child: MyApp(isFirstTime: isFirstTime)));
}

class MyApp extends ConsumerWidget {
  final bool isFirstTime;

  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Ví Khôn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', ''),
        Locale('en', ''),
      ],
      locale: const Locale('vi', ''),
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
