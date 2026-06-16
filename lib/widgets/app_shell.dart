import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../services/localization_service.dart';
import '../screens/login_screen.dart';

class AppShell extends StatelessWidget {
  final String username, role, lang;
  final int selectedIndex;
  final void Function(int) onNavTap;
  final void Function(String) onLangChanged;
  final Widget body;

  const AppShell({
    super.key,
    required this.username, required this.role, required this.lang,
    required this.selectedIndex, required this.onNavTap,
    required this.onLangChanged, required this.body,
  });

  static List<_NavItem> navItems(String role, String lang) {
    String t(String k) => LocalizationService.translate(k, lang);
    if (role == 'admin') {
      return [
        _NavItem(Icons.home_outlined, Icons.home_rounded, t('dashboard')),
        _NavItem(Icons.admin_panel_settings_outlined,
          Icons.admin_panel_settings_rounded, t('admin_panel')),
      ];
    }
    return [
      _NavItem(Icons.home_outlined, Icons.home_rounded, t('dashboard')),
      _NavItem(Icons.science_outlined, Icons.science_rounded, t('new_analysis')),
      _NavItem(Icons.history_outlined, Icons.history_rounded, t('history')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = navItems(role, lang);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(children: [
        _Sidebar(
          username: username, role: role, lang: lang,
          selectedIndex: selectedIndex, navItems: items,
          onNavTap: onNavTap, onLangChanged: onLangChanged,
          onLogout: () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const LoginScreen())),
        ),
        Expanded(
          child: Stack(children: [
            // Subtle warm grid on every content page
            Positioned.fill(child: CustomPaint(painter: _WarmGridPainter())),
            body,
          ]),
        ),
      ]),
    );
  }
}

class _NavItem {
  final IconData icon, activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

class _Sidebar extends StatelessWidget {
  final String username, role, lang;
  final int selectedIndex;
  final List<_NavItem> navItems;
  final void Function(int) onNavTap;
  final void Function(String) onLangChanged;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.username, required this.role, required this.lang,
    required this.selectedIndex, required this.navItems,
    required this.onNavTap, required this.onLangChanged, required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(right: BorderSide(color: AppColors.sidebarBorder))),
      child: Column(children: [
        // ── Brand ──────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
          child: Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppColors.accentWarm,
                borderRadius: BorderRadius.circular(9)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset('assets/images/images.jpg', fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.eco_rounded, color: Colors.white, size: 20))),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MENANA', style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: 0.6)),
              Text('Organic Food', style: GoogleFonts.inter(
                fontSize: 9, color: AppColors.sidebarText)),
            ]),
          ]),
        ),
        Container(height: 1, color: AppColors.sidebarBorder),
        const SizedBox(height: 8),

        // ── Role badge ─────────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: role == 'admin'
              ? AppColors.accentWarm.withValues(alpha: 0.15)
              : AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: role == 'admin'
                ? AppColors.accentWarm.withValues(alpha: 0.4)
                : AppColors.accent.withValues(alpha: 0.4))),
          child: Row(children: [
            Icon(role == 'admin' ? Icons.shield_outlined : Icons.person_outline_rounded,
              size: 12,
              color: role == 'admin' ? AppColors.accentWarm : AppColors.accent),
            const SizedBox(width: 7),
            Text(role == 'admin' ? 'Administrateur' : 'Utilisateur',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600,
                color: role == 'admin' ? AppColors.accentWarm : AppColors.accent)),
          ]),
        ),
        const SizedBox(height: 10),

        // ── Nav ────────────────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            itemCount: navItems.length,
            itemBuilder: (_, i) {
              final sel = i == selectedIndex;
              return _NavTile(
                icon: sel ? navItems[i].activeIcon : navItems[i].icon,
                label: navItems[i].label,
                isSelected: sel,
                onTap: () => onNavTap(i));
            }),
        ),

        Container(height: 1, color: AppColors.sidebarBorder),

        // ── Lang picker ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: _LangRow(current: lang, onChanged: onLangChanged)),

        // ── User footer ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.sidebarBorder,
              borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: AppColors.accentWarm.withValues(alpha: 0.2),
                  shape: BoxShape.circle),
                child: Center(child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.accentWarm)))),
              const SizedBox(width: 8),
              Expanded(child: Text(username,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.sidebarText),
                overflow: TextOverflow.ellipsis)),
              GestureDetector(
                onTap: onLogout,
                child: Tooltip(message: 'Deconnexion',
                  child: Icon(Icons.logout_rounded,
                    size: 15, color: AppColors.sidebarText.withValues(alpha: 0.6)))),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _NavTile extends StatefulWidget {
  final IconData icon; final String label;
  final bool isSelected; final VoidCallback onTap;
  const _NavTile({required this.icon, required this.label,
    required this.isSelected, required this.onTap});
  @override State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
              ? AppColors.accent.withValues(alpha: 0.25)
              : _hov
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
              ? Border.all(color: AppColors.accent.withValues(alpha: 0.5))
              : null),
          child: Row(children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(widget.icon, key: ValueKey(widget.isSelected),
                size: 17,
                color: widget.isSelected
                  ? AppColors.accent
                  : AppColors.sidebarText)),
            const SizedBox(width: 11),
            Expanded(child: Text(widget.label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                color: widget.isSelected ? AppColors.accent : AppColors.sidebarText),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (widget.isSelected)
              Container(width: 5, height: 5,
                decoration: BoxDecoration(
                  color: AppColors.accent, shape: BoxShape.circle)),
          ]),
        ),
      ),
    );
  }
}

class _LangRow extends StatelessWidget {
  final String current; final void Function(String) onChanged;
  const _LangRow({required this.current, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.sidebarBorder,
        borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        for (final l in [('fr','FR'), ('ar','AR'), ('en','EN')])
          Expanded(child: GestureDetector(
            onTap: () => onChanged(l.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: current == l.$1
                  ? AppColors.accentWarm : Colors.transparent,
                borderRadius: BorderRadius.circular(6)),
              child: Text(l.$2, textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700,
                  color: current == l.$1
                    ? Colors.white : AppColors.sidebarText))))),
      ]),
    );
  }
}

// Warm subtle grid — visible on light bg
class _WarmGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7D9B4E).withValues(alpha: 0.07)
      ..strokeWidth = 0.8;
    const step = 44.0;
    for (double x = 0; x < size.width; x += step)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += step)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override bool shouldRepaint(_) => false;
}