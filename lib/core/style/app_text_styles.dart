import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static TextStyle pageTitle(BuildContext context) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.headlineSmall?.color,
        letterSpacing: -0.3,
      );

  static TextStyle sectionTitle(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.titleMedium?.color,
      );

  static TextStyle labelMuted(BuildContext context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.bodySmall?.color,
      );
}
