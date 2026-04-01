import 'package:expense_manager_app/core/style/app_colors.dart';
import 'package:flutter/material.dart';


class CenterFAB extends StatelessWidget {
  const CenterFAB({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
    );
  }
}
