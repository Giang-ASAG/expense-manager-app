import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        fixedSize: const Size(double.infinity, 56),
        side: BorderSide(color: Color(0xFFE8E9EA)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, height: 24), // Nhớ thêm icon vào assets
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF1A1D1E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
