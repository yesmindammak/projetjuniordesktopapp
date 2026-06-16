import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../models/analysis_model.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import '../services/pdf_service.dart';

class AdminPanelScreen extends StatefulWidget {
  final String lang;
  const AdminPanelScreen({super.key, required this.lang});
  @override State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  List<Analysis> _all = [];
  bool _loading = true;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = _search.isEmpty
      ? await DatabaseService.instance.readAllAnalyses()
      : await DatabaseService.instance.searchAnalyses(_search);
    if (mounted) setState(() { _all = data; _loading = false; });
  }

  String _t(String k) => LocalizationService.translate(k, widget.lang);

  Future<void> _delete(Analysis a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border)),
        title: Text(_t('confirm_delete'), style: GoogleFonts.inter(
          fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        content: Text('${_t("delete_msg")} "${a.codeEchantillon}"?\n${_t("irreversible")}',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: Text(_t('cancel'),
              style: const TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error, elevation: 0),
            child: Text(_t('delete'))),
        ]));
    if (ok == true) {
      await DatabaseService.instance.deleteAnalysis(a.id!);
      _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_t('deleted')), backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final total     = _all.length;
    final conformes = _all.where((a) => a.conforme).length;
    final nonConf   = total - conformes;
    final taux      = total == 0
      ? '0.0' : (conformes / total * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 16),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_t('admin_panel'), style: GoogleFonts.playfairDisplay(
                fontSize: 28, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Container(width: 40, height: 3,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2))),
            ])),
            // Mini stats
            _MiniStat('Total', '$total', AppColors.accent),
            const SizedBox(width: 10),
            _MiniStat(_t('compliant'), '$conformes', AppColors.success),
            const SizedBox(width: 10),
            _MiniStat('Taux', '$taux%', AppColors.warning),
          ]),
        ),

        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
          child: SizedBox(width: 320, child: TextField(
            controller: _searchCtrl,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: _t('search_analysis'),
              hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textMuted, size: 17),
              suffixIcon: _search.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 15,
                      color: AppColors.textMuted),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _search = '');
                      _load();
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
                borderSide: const BorderSide(
                  color: AppColors.borderFocus, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10)),
            onChanged: (v) { setState(() => _search = v); _load(); },
          )),
        ),

        // Table
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
                // Header row
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
                    _TH(_t('uv_analysis_k232'), flex: 1),
                    _TH(_t('uv_analysis_k270'), flex: 1),
                    _TH(_t('delta_k'), flex: 1),
                    _TH(_t('actions'), flex: 1),
                  ])),

                Expanded(
                  child: _loading
                    ? const Center(child: CircularProgressIndicator(
                        color: AppColors.accent))
                    : _all.isEmpty
                      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.inbox_outlined, size: 44,
                            color: AppColors.textMuted.withValues(alpha: 0.4)),
                          const SizedBox(height: 8),
                          Text(_t('no_data'), style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textMuted)),
                        ]))
                      : ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(13)),
                          child: ListView.separated(
                            itemCount: _all.length,
                            separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: AppColors.border),
                            itemBuilder: (_, i) => _AdminRow(
                              analysis: _all[i],
                              lang: widget.lang,
                              onPdf: () => PdfService.generatePdf(_all[i]),
                              onDelete: () => _delete(_all[i]),
                            ),
                          )),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value; final Color color;
  const _MiniStat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: color.withValues(alpha: 0.25))),
    child: Column(children: [
      Text(value, style: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: GoogleFonts.inter(
        fontSize: 10, color: AppColors.textMuted)),
    ]));
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

class _AdminRow extends StatefulWidget {
  final Analysis analysis; final String lang;
  final VoidCallback onPdf, onDelete;
  const _AdminRow({required this.analysis, required this.lang,
    required this.onPdf, required this.onDelete});
  @override State<_AdminRow> createState() => _AdminRowState();
}

class _AdminRowState extends State<_AdminRow> {
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
          Expanded(flex: 2, child: Text(a.codeEchantillon, style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
          Expanded(flex: 3, child: Text(a.nomClient, style: GoogleFonts.inter(
            fontSize: 12, color: AppColors.textSecondary))),
          Expanded(flex: 2, child: Text(
            '${a.dateAnalyse.day}/${a.dateAnalyse.month}/${a.dateAnalyse.year}',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted))),
          Expanded(flex: 1, child: Text(a.k232Calcule.toStringAsFixed(3),
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary))),
          Expanded(flex: 1, child: Text(a.k270Calcule.toStringAsFixed(3),
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary))),
          Expanded(flex: 1, child: Text(a.deltaKCalcule.toStringAsFixed(3),
            style: GoogleFonts.inter(fontSize: 11,
              color: a.deltaKCalcule.abs() <= 0.01
                ? AppColors.success : AppColors.error))),
          // 3-dot menu
          Expanded(flex: 1, child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded,
              size: 18, color: AppColors.textMuted),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.border)),
            onSelected: (v) {
              if (v == 'pdf') widget.onPdf();
              if (v == 'delete') widget.onDelete();
            },
            itemBuilder: (ctx) => [
              _mi(Icons.picture_as_pdf_outlined, 'PDF', 'pdf', AppColors.warning),
              const PopupMenuDivider(),
              _mi(Icons.delete_outline_rounded, _t('delete'), 'delete', AppColors.error),
            ],
          )),
        ]),
      ),
    );
  }

  PopupMenuItem<String> _mi(IconData icon, String label, String value, Color color) =>
    PopupMenuItem(value: value,
      child: Row(children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.inter(
          fontSize: 13, color: color, fontWeight: FontWeight.w500)),
      ]));
}