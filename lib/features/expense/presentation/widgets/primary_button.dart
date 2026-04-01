import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // nullable để hỗ trợ disable
  final Color? backgroundColor;
  final Color? textColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xFF2D4BFF),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: (isEnabled ? backgroundColor! : Colors.grey)
                .withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? backgroundColor : Colors.grey.shade300,
          foregroundColor: isEnabled ? textColor : Colors.grey.shade500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}