import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';

class DashboardScreen extends StatefulWidget {
  final String lang, role, username;
  const DashboardScreen({super.key,
    required this.lang, required this.role, required this.username});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> _stats;
  @override void initState() { super.initState(); _load(); }
  void _load() => setState(() { _stats = DatabaseService.instance.getStatistics(); });
  String _t(String k) => LocalizationService.translate(k, widget.lang);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _stats,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              color: AppColors.accent));
          }
          final s       = snap.data ?? {};
          final total   = (s['total'] ?? 0) as int;
          final conf    = (s['conformes'] ?? 0) as int;
          final nonConf = (s['nonConformes'] ?? 0) as int;
          final taux    = s['tauxConformite'] ?? '0';
          final last    = s['lastAnalysisDate'] as DateTime?;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Page header ─────────────────────────────────────────────
                Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_t('dashboard'),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, letterSpacing: -0.3)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Text('${_t("hello")}, ',
                        style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary)),
                      Text(widget.username,
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppColors.accent)),
                    ]),
                  ]),
                ]),
                const SizedBox(height: 6),
                Container(width: 44, height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentWarm]),
                    borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 28),

                // ── Stat cards ──────────────────────────────────────────────
                IntrinsicHeight(
                  child: Row(children: [
                    _StatCard(
                      label: _t('total_analyses'),
                      value: '$total',
                      icon: Icons.analytics_outlined,
                      color: AppColors.accent,
                      subtitle: 'Toutes analyses'),
                    const SizedBox(width: 14),
                    _StatCard(
                      label: _t('compliant'),
                      value: '$conf',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      progress: total > 0 ? conf / total : 0,
                      subtitle: total > 0
                        ? '${(conf/total*100).toStringAsFixed(0)}% du total'
                        : '0% du total'),
                    const SizedBox(width: 14),
                    _StatCard(
                      label: _t('non_compliant'),
                      value: '$nonConf',
                      icon: Icons.cancel_outlined,
                      color: AppColors.error,
                      progress: total > 0 ? nonConf / total : 0,
                      subtitle: total > 0
                        ? '${(nonConf/total*100).toStringAsFixed(0)}% du total'
                        : '0% du total'),
                    const SizedBox(width: 14),
                    _StatCard(
                      label: _t('conformity_rate'),
                      value: '$taux%',
                      icon: Icons.pie_chart_outline_rounded,
                      color: AppColors.accentWarm,
                      subtitle: 'Taux de conformite'),
                  ]),
                ),
                const SizedBox(height: 20),

                // ── Bottom row ──────────────────────────────────────────────
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: _SectionCard(
                    title: _t('distribution_results'),
                    icon: Icons.bar_chart_rounded,
                    child: total == 0
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: Text('Aucune analyse enregistree',
                            style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textMuted))))
                      : Column(children: [
                          _ProgressRow(_t('compliant'), conf, total,
                            AppColors.success),
                          const SizedBox(height: 18),
                          _ProgressRow(_t('non_compliant'), nonConf, total,
                            AppColors.error),
                        ]),
                  )),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _StatCard extends StatefulWidget {
  final String label, value, subtitle;
  final IconData icon;
  final Color color;
  final double? progress;
  const _StatCard({
    required this.label, required this.value, required this.icon,
    required this.color, required this.subtitle, this.progress});
  @override State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hov = true),
        onExit: (_) => setState(() => _hov = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hov
                ? widget.color.withValues(alpha: 0.5)
                : widget.color.withValues(alpha: 0.2),
              width: _hov ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                color: _hov
                  ? widget.color.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.04),
                blurRadius: _hov ? 16 : 8,
                offset: const Offset(0, 3))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(widget.icon, color: widget.color, size: 19)),
              const Spacer(),
              if (widget.progress != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${((widget.progress ?? 0) * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      fontSize: 10, color: widget.color,
                      fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 14),
            // VALUE — must be visible, dark on white bg
            Text(widget.value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 32, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,  // dark, always visible
                height: 1)),
            const SizedBox(height: 4),
            Text(widget.label,
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),  // dark, always visible
            const SizedBox(height: 2),
            Text(widget.subtitle,
              style: GoogleFonts.inter(
                fontSize: 10, color: AppColors.textMuted)),
            if (widget.progress != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: widget.progress,
                  minHeight: 4,
                  backgroundColor: widget.color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(widget.color))),
            ],
          ]),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title; final IconData icon; final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 15, color: AppColors.accent),
          const SizedBox(width: 7),
          Text(title, style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 4),
        const Divider(color: AppColors.border, height: 16),
        child,
      ]),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label; final int value, total; final Color color;
  const _ProgressRow(this.label, this.value, this.total, this.color);
  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : value / total;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500,
          color: AppColors.textPrimary)),
        Text('$value / $total  (${(pct*100).toStringAsFixed(1)}%)',
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: pct, minHeight: 10,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation(color))),
    ]);
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _InfoTile(this.icon, this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(
          fontSize: 10, color: AppColors.textMuted)),
        Text(value, style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary)),
      ]),
    ]);
  }
}