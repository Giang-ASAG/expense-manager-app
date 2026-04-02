import 'package:expense_manager_app/features/expense/presentation/pages/add_transaction_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/expense_gallery_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/overview_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/settings_page.dart';
import 'package:expense_manager_app/features/expense/presentation/pages/transaction_history_page.dart';
import 'package:expense_manager_app/features/expense/presentation/widgets/custom_bottom_nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.user}); // ← nhận user từ ngoài
  final User? user;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Dùng getter vì cần widget.user
  List<Widget> get _pages => [
    OverviewPage(user: widget.user),
    // index 0
    TransactionHistoryPage(id: widget.user!.uid),
    // index 1
    ExpenseGalleryPage(id: widget.user!.uid),
    // index 2 - placeholder notifications
    const SettingsPage(),
    // index 3 - placeholder settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        onFabPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionPage(isExpense: true),
            ),
          );
        },
      ),
    );
  }
}
