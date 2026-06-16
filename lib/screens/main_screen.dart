import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import 'dashboard_screen.dart';
import 'analysis_form_screen.dart';
import 'history_screen.dart';
import 'admin_panel_screen.dart';

class MainScreen extends StatefulWidget {
  final String username;
  final String role;
  const MainScreen({super.key, required this.username, required this.role});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  String _lang = 'fr';

  // USER nav:  0=dashboard  1=nouvelle analyse  2=historique
  // ADMIN nav: 0=dashboard  1=panneau admin  (no form, history=admin panel)
  Widget _body() {
    if (widget.role == 'admin') {
      switch (_index) {
        case 0: return DashboardScreen(
          lang: _lang, role: widget.role, username: widget.username);
        case 1: return AdminPanelScreen(lang: _lang);
        default: return DashboardScreen(
          lang: _lang, role: widget.role, username: widget.username);
      }
    } else {
      // user
      switch (_index) {
        case 0: return DashboardScreen(
          lang: _lang, role: widget.role, username: widget.username);
        case 1: return AnalysisFormScreen(
          shellLang: _lang,
          onSaved: () => setState(() => _index = 2));
        case 2: return HistoryScreen(lang: _lang);
        default: return DashboardScreen(
          lang: _lang, role: widget.role, username: widget.username);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      username: widget.username,
      role: widget.role,
      selectedIndex: _index,
      lang: _lang,
      onNavTap: (i) => setState(() => _index = i),
      onLangChanged: (l) => setState(() => _lang = l),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: KeyedSubtree(key: ValueKey('$_index-$_lang'), child: _body()),
      ),
    );
  }
}