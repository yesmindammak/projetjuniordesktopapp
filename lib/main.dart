import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/login_screen.dart';

import 'utils/app_colors.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const OliveOilAnalyzerApp());
}

class OliveOilAnalyzerApp extends StatelessWidget {
  const OliveOilAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MENANA ORGANIC FOOD',
      debugShowCheckedModeBanner: false,

      // ── Required to fix DatePickerDialog crash ────────────────────────────
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('ar'),
        Locale('en'),
      ],

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.accent,
          onPrimary: Colors.white,
          surface: AppColors.surface,
          background: AppColors.bg,
        ),
        scaffoldBackgroundColor: AppColors.bg,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: GoogleFonts.inter(
            fontSize: 28, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, letterSpacing: -0.5),
          titleLarge: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14, color: AppColors.textPrimary),
          labelMedium: GoogleFonts.inter(
            fontSize: 12, color: AppColors.textSecondary),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: AppColors.border,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary),
          iconTheme: const IconThemeData(
            color: AppColors.textSecondary, size: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600, fontSize: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(
              vertical: 13, horizontal: 20),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.accent, width: 1.5),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600, fontSize: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(
              vertical: 13, horizontal: 20),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border)),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(
              color: AppColors.borderFocus, width: 1.8)),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: AppColors.error)),
          labelStyle: GoogleFonts.inter(
            fontSize: 13, color: AppColors.textSecondary),
          errorStyle: GoogleFonts.inter(fontSize: 11),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border, thickness: 1, space: 1),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceAlt,
          labelStyle: GoogleFonts.inter(fontSize: 12),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6)),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}