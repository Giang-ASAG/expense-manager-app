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

  // Lazy cache: null = chưa build, non-null = đã build và giữ lại
  late final List<Widget?> _pageCache = List.filled(4, null);

  /// Trả về widget của page, build lần đầu nếu chưa có
  Widget _getPage(int index) {
    if (_pageCache[index] != null) return _pageCache[index]!;

    final Widget page;
    switch (index) {
      case 0:
        page = OverviewPage(user: widget.user);
      case 1:
        page = TransactionHistoryPage(id: widget.user!.uid);
      case 2:
        page = ExpenseGalleryPage(id: widget.user!.uid);
      case 3:
        page = SettingsPage(user: widget.user);
      default:
        page = OverviewPage(user: widget.user);
    }

    _pageCache[index] = page;
    return page;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Giữ state của các page đã từng mở bằng Offstage
      body: Stack(
        children: List.generate(4, (i) {
          // Chỉ build page khi đã được truy cập ít nhất một lần
          final isVisited = _pageCache[i] != null || i == _currentIndex;
          if (!isVisited) return const SizedBox.shrink();
          return Offstage(
            offstage: _currentIndex != i,
            child: _getPage(i),
          );
        }),
      ),
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
      // ✅ Fix: Đảm bảo body không bị che bởi nav bar
      resizeToAvoidBottomInset: true,
    );
  }
}
