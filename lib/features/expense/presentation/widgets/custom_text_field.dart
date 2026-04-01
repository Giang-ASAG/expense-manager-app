import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController controller;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.isPassword = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E9EA)),
      ),
      child: TextFormField(              // ✅ TextFormField thay vì TextField
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,            // ✅ validator hoạt động với Form
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF1A1D1E)),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          errorStyle: const TextStyle(fontSize: 12),
          errorBorder: InputBorder.none,        // giữ style container
          focusedErrorBorder: InputBorder.none,
        ),
      ),
    );
  }
}