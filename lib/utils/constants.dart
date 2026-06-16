// add at top of constants.dart
export 'app_colors.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AppTextStyles {
  static const TextStyle heading = TextStyle(
      fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const TextStyle subheading = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle body = TextStyle(
      fontSize: 16, color: AppColors.textPrimary);
  static const TextStyle bodySecondary = TextStyle(
      fontSize: 16, color: AppColors.textSecondary);
  static const TextStyle label = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static const TextStyle caption = TextStyle(
      fontSize: 12, color: AppColors.textSecondary);
  static const TextStyle button = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
}

class AppConstants {
  static const String companyName    = 'MENANA ORGANIC FOOD';
  static const String companySubtitle= 'MENANA Organic Food and Herbal Products';
  static const String companyCity    = 'Sousse';
  static const String companyMF      = '1830790TNM000';
  static const String labTitle       = 'Laboratoire de Contrôle Qualité';

  static const double maxAcidity = 0.8;
  static const double maxK232    = 2.50;
  static const double maxK270    = 0.22;
  static const double maxDeltaK  = 0.01;

  static const String appName    = 'Analyse Huile d\'Olive';
  static const String appVersion = '1.0.0';

  static const double borderRadius   = 12.0;
  static const double cardElevation  = 2.0;
  static const double defaultPadding = 16.0;
  static const double largePadding   = 24.0;
  static const double smallPadding   = 8.0;
}

class AppHelpers {
  static String formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  static String formatNumber(double value, int decimals) =>
      value.toStringAsFixed(decimals);

  static bool isValidDouble(String value) =>
      double.tryParse(value.replaceAll(',', '.')) != null;

  static double parseDouble(String value) =>
      double.parse(value.replaceAll(',', '.'));
}