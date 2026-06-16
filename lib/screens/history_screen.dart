import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../models/analysis_model.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../services/pdf_service.dart';
import 'analysis_form_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String lang;
  const HistoryScreen({super.key, required this.lang});
  @override State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Analysis> _results = [];
  bool _loading = false;
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override void initState() { super.initState(); _fetch(); }
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _fetch([String? q]) async {
    setState(() => _loading = true);
    final list = (q == null || q.isEmpty)
      ? await DatabaseService.instance.readAllAnalyses()
      : await DatabaseService.instance.searchAnalyses(q);
    if (mounted) setState(() { _results = list; _loading = false; });
  }

  String _t(String k) => LocalizationService.translate(k, widget.lang);

  void _showDetail(Analysis a) {
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border)),
      child: SizedBox(width: 460, child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Analyse: ${a.codeEchantillon}',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary))),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                color: AppColors.textMuted, size: 18),
              onPressed: () => Navigator.pop(ctx)),
          ]),
          const SizedBox(height: 16),
          _dsec('Client', [
            _dr('Code', a.codeEchantillon),
            _dr('Nom', a.nomClient),
            _dr('Code client', a.codeClient),
            _dr('Quantite', '${a.quantiteHuile ?? "-"} L'),
          ]),
          _dsec('Dates', [
            _dr('Reception', '${a.dateReception.day}/${a.dateReception.month}/${a.dateReception.year}'),
            _dr('Analyse', '${a.dateAnalyse.day}/${a.dateAnalyse.month}/${a.dateAnalyse.year}'),
          ]),
          _dsec('Mesures', [
            _dr('Acidite', '${a.aciditeLibre.toStringAsFixed(2)}%', a.aciditeLibre <= 0.8),
            _dr('K232', a.k232Calcule.toStringAsFixed(4), a.k232Calcule <= 2.50),
            _dr('K270', a.k270Calcule.toStringAsFixed(4), a.k270Calcule <= 0.22),
            _dr('K274', a.k274Calcule.toStringAsFixed(4)),
            _dr('K266', a.k266Calcule.toStringAsFixed(4)),
            _dr('Delta K', a.deltaKCalcule.toStringAsFixed(4), a.deltaKCalcule.abs() <= 0.01),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: a.conforme ? AppColors.successLight : AppColors.errorLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: a.conforme
                  ? AppColors.success.withValues(alpha: 0.4)
                  : AppColors.error.withValues(alpha: 0.4))),
            child: Row(children: [
              Icon(a.conforme
                ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                color: a.conforme ? AppColors.success : AppColors.error, size: 18),
              const SizedBox(width: 10),
              Text(a.conforme ? 'CONFORME' : 'NON CONFORME',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13,
                  color: a.conforme ? AppColors.success : AppColors.error)),
            ])),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 14),
              label: const Text('PDF'),
              onPressed: () { Navigator.pop(ctx); PdfService.generatePdf(a); },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent))),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_t('cancel'),
                style: const TextStyle(color: AppColors.textSecondary))),
          ]),
        ]),
      )),
    ));
  }

  Widget _dr(String l, String v, [bool? ok]) {
    final color = ok == null ? AppColors.textPrimary
      : ok ? AppColors.success : AppColors.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        Text(v, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
      ]));
  }

  Widget _dsec(String title, List<Widget> rows) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(title, style: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: AppColors.textMuted, letterSpacing: 0.8))),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgSubtle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border)),
        child: Column(children: rows)),
      const SizedBox(height: 8),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header + search
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 16),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_t('history'), style: GoogleFonts.playfairDisplay(
                fontSize: 28, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Container(width: 40, height: 3,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2))),
            ])),
            SizedBox(width: 280, child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: _t('search_analysis'),
                hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textMuted, size: 17),
                suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted, size: 15),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                        _fetch();
                      })
                  : null,
                filled: true, fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10)),
              onChanged: (v) { setState(() => _search = v); _fetch(v); },
            )),
          ]),
        ),

        // Table container
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8, offset: const Offset(0, 2))]),
              child: Column(children: [
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSubtle,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                    border: const Border(bottom: BorderSide(color: AppColors.border))),
                  child: Row(children: [
                    _TH('', flex: 1),
                    _TH(_t('code'), flex: 2),
                    _TH(_t('client'), flex: 3),
                    _TH(_t('date'), flex: 2),
                    _TH(_t('free_acidity'), flex: 1),
                    _TH(_t('k232'), flex: 1),
                    _TH(_t('delta_k'), flex: 1),
                    
                    _TH('', flex: 1),  // 3-dot menu
                  ]),
                ),

                // Rows
                Expanded(
                  child: _loading
                    ? const Center(child: CircularProgressIndicator(
                        color: AppColors.accent))
                    : _results.isEmpty
                      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.inbox_outlined, size: 44,
                            color: AppColors.textMuted.withValues(alpha: 0.4)),
                          const SizedBox(height: 8),
                          Text('Aucune analyse', style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textMuted)),
                        ]))
                      : ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(13)),
                          child: ListView.separated(
                            itemCount: _results.length,
                            separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: AppColors.border),
                            itemBuilder: (_, i) => _HistoryRow(
                              analysis: _results[i],
                              lang: widget.lang,
                              onView: () => _showDetail(_results[i]),
                              onEdit: () async {
                                await showDialog(
                                  context: context,
                                  builder: (ctx) => Dialog(
                                    backgroundColor: AppColors.bg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                    insetPadding: const EdgeInsets.all(32),
                                    child: SizedBox(width: 800, height: 680,
                                      child: AnalysisFormScreen(
                                        analysis: _results[i],
                                        shellLang: widget.lang,
                                        onSaved: () {
                                          Navigator.pop(ctx);
                                          _fetch();
                                        }))));
                              },
                              onPdf: () => PdfService.generatePdf(_results[i]),
                              onDelete: () async {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: AppColors.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(color: AppColors.border)),
                                    title: Text(_t('confirm_delete'),
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary)),
                                    content: Text(
                                      _t('delete_msg') + ' "${_results[i].codeEchantillon}"?\n' + _t('irreversible'),
                                      style: GoogleFonts.inter(
                                        fontSize: 13, color: AppColors.textSecondary)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, false),
                                        child: Text(_t('cancel'),
                                          style: const TextStyle(
                                            color: AppColors.textSecondary))),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error, elevation: 0),
                                        child: Text(_t('delete'))),
                                    ],
                                  ));
                                if (ok == true) {
                                  await DatabaseService.instance
                                    .deleteAnalysis(_results[i].id!);
                                  _fetch();
                                }
                              },
                            ),
                          )),
                ),
       ] ),
          ),
        ),
      ),
    ]));
  }
}

class _TH extends StatelessWidget {
  final String text; final int flex;
  const _TH(this.text, {required this.flex});
  @override
  Widget build(BuildContext context) => Expanded(flex: flex, child:
    Text(text, style: GoogleFonts.inter(
      fontSize: 10, fontWeight: FontWeight.w700,
      color: AppColors.textMuted, letterSpacing: 0.5)));
}

class _HistoryRow extends StatefulWidget {
  final Analysis analysis;
  final String lang;
  final VoidCallback onView, onEdit, onPdf, onDelete;
  const _HistoryRow({required this.analysis, required this.lang,
    required this.onView, required this.onEdit,
    required this.onPdf, required this.onDelete});
  @override State<_HistoryRow> createState() => _HistoryRowState();
}

class _HistoryRowState extends State<_HistoryRow> {
  bool _hov = false;
  String _t(String k) => LocalizationService.translate(k, widget.lang);

  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
    final ok = a.conforme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _hov ? AppColors.bgSubtle : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(children: [
          Expanded(flex: 1, child: Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: ok ? AppColors.success.withValues(alpha: 0.1)
                       : AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle),
            child: Icon(ok ? Icons.check_rounded : Icons.close_rounded,
              size: 12, color: ok ? AppColors.success : AppColors.error))),
          Expanded(flex: 2, child: Text(a.codeEchantillon,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500,
              color: AppColors.textPrimary))),
          Expanded(flex: 3, child: Text(a.nomClient,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 2, child: Text(
            '${a.dateAnalyse.day}/${a.dateAnalyse.month}/${a.dateAnalyse.year}',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted))),
          Expanded(flex: 1, child: Text(a.aciditeLibre.toStringAsFixed(2),
            style: GoogleFonts.inter(fontSize: 11,
              color: a.aciditeLibre <= 0.8 ? AppColors.success : AppColors.error))),
          Expanded(flex: 1, child: Text(a.k232Calcule.toStringAsFixed(3),
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary))),
          Expanded(flex: 1, child: Text(a.deltaKCalcule.toStringAsFixed(3),
            style: GoogleFonts.inter(fontSize: 11,
              color: a.deltaKCalcule.abs() <= 0.01
                ? AppColors.success : AppColors.error))),

          // ── 3-dot menu (PDF / Modifier / Voir / Supprimer) ───────────────
          Expanded(flex: 1, child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded,
              size: 18, color: AppColors.textMuted),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.border)),
            onSelected: (v) {
              if (v == 'voir')     widget.onView();
              if (v == 'modifier') widget.onEdit();
              if (v == 'pdf')      widget.onPdf();
              if (v == 'delete')   widget.onDelete();
            },
            itemBuilder: (ctx) => [
              _mi(Icons.visibility_outlined, _t('voir') != 'voir'
                ? _t('voir') : 'Voir', 'voir', AppColors.textSecondary),
              _mi(Icons.edit_outlined, _t('modifier') != 'modifier'
                ? _t('modifier') : 'Modifier', 'modifier', AppColors.accent),
              _mi(Icons.picture_as_pdf_outlined, 'PDF', 'pdf', AppColors.warning),
              const PopupMenuDivider(),
              _mi(Icons.delete_outline_rounded, _t('delete'), 'delete', AppColors.error),
            ],
          )),
        ]),
      ),
    );
  }

  PopupMenuItem<String> _mi(IconData icon, String label, String value, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.inter(
          fontSize: 13, color: color, fontWeight: FontWeight.w500)),
      ]));
  }
}