import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../services/localization_service.dart';

class SettingsScreen extends StatelessWidget {
  final String lang;
  const SettingsScreen({super.key, required this.lang});

  String _t(String k) => LocalizationService.translate(k, lang);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parametres', style: GoogleFonts.inter(
              fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Configuration de l\'application', style: GoogleFonts.inter(
              fontSize: 13, color: Colors.white38)),
            const SizedBox(height: 28),

            // Company section
            _Section(
              title: 'Entreprise',
              children: [
                _SettingRow(Icons.business_outlined, 'Nom',
                  AppConstants.companyName),
                _SettingRow(Icons.location_on_outlined, 'Ville',
                  AppConstants.companyCity),
                _SettingRow(Icons.tag_outlined, 'MF',
                  AppConstants.companyMF),
              ],
            ),
            const SizedBox(height: 16),

            // Quality norms section
            _Section(
              title: 'Normes qualite (Huile d\'Olive Extra Vierge)',
              children: [
                _SettingRow(Icons.science_outlined, 'Acidite libre max',
                  '<= ${AppConstants.maxAcidity}%'),
                _SettingRow(Icons.science_outlined, 'K232 max',
                  '<= ${AppConstants.maxK232}'),
                _SettingRow(Icons.science_outlined, 'K270 max',
                  '<= ${AppConstants.maxK270}'),
                _SettingRow(Icons.science_outlined, 'Delta K max',
                  '<= ${AppConstants.maxDeltaK}'),
              ],
            ),
            const SizedBox(height: 16),

            // App info
            _Section(
              title: 'Application',
              children: [
                _SettingRow(Icons.info_outline_rounded, 'Version',
                  AppConstants.appVersion),
                _SettingRow(Icons.wifi_off_outlined, 'Mode',
                  '100% Hors ligne'),
                _SettingRow(Icons.storage_outlined, 'Base de donnees',
                  'SQLite local'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.adminSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adminBorder)),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: Colors.white38, letterSpacing: 0.5)))),
        const Divider(height: 1, color: AppColors.adminBorder),
        ...children,
      ]),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _SettingRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.adminBorder))),
      child: Row(children: [
        Icon(icon, size: 15, color: Colors.white30),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.inter(
          fontSize: 13, color: Colors.white60)),
        const Spacer(),
        Text(value, style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
      ]),
    );
  }
}