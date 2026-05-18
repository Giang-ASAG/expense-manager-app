import 'package:flutter/material.dart';

/// ✅ Widget wrapper chuẩn cho tất cả các trang trong MainPage
/// Đảm bảo padding và spacing đồng bộ giữa các trang
class PageScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool useSafeArea;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const PageScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.showBackButton = false,
    this.useSafeArea = true,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFFF8F9FB),
      appBar: title != null || actions != null || showBackButton
          ? AppBar(
              elevation: 0,
              backgroundColor: const Color(0xFFF8F9FB),
              title: title != null
                  ? Text(
                      title!,
                      style: const TextStyle(
                        color: Color(0xFF1A1D1E),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
              leading: showBackButton
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Color(0xFF1A1D1E),
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              actions: actions,
            )
          : null,
      body: useSafeArea
          ? SafeArea(
              child: Padding(
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
                child: body,
              ),
            )
          : Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
              child: body,
            ),
      // ✅ Padding dưới để tránh navbar bị che
      resizeToAvoidBottomInset: true,
    );
  }
}
