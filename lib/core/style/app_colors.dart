import 'package:flutter/material.dart';

abstract class AppColors {
  // Raw values for static Theme definition
  static const bgLight = Color(0xFFF8F9FB);
  static const bgDark = Color(0xFF0F1219);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF1B1E26);
  static const textPrimaryLight = Color(0xFF1A1D1E);
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryLight = Color(0xFF8A92A3);
  static const textSecondaryDark = Color(0xFFADB5C2);
  static const borderLight = Color(0xFFEEEFF4);
  static const borderDark = Color(0xFF2D323D);

  static Color background(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
  static Color surface(BuildContext context) => Theme.of(context).cardColor;
  static Color textPrimary(BuildContext context) => Theme.of(context).textTheme.titleMedium?.color ?? textPrimaryLight;
  static Color textSecondary(BuildContext context) => Theme.of(context).textTheme.bodySmall?.color ?? textSecondaryLight;
  static Color border(BuildContext context) => Theme.of(context).dividerColor.withOpacity(0.5);

  static const primary      = Color(0xFF2D4BFF);
  static const primaryLight = Color(0xFFEEF1FF);
  static const danger       = Color(0xFFFF4D6A);
  static const dangerLight  = Color(0xFFFFEDF0);
  static const success      = Color(0xFF12C98E);
  static const successLight = Color(0xFFE6FAF5);
  static const warning      = Color(0xFFFF9500);
  static const warningLight = Color(0xFFFFF3E0);
}
