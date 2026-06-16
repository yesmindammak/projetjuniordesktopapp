// Replace your analysis_form_screen.dart with this.
// Key changes:
//   - accepts shellLang and onSaved callback (for in-shell usage)
//   - can still be used as a standalone pushed route (backward compat)
//   - fixed double-wrapped t() call bug
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';
import '../utils/calculations.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/result_card.dart';
import '../services/localization_service.dart';
import '../services/database_service.dart';
import '../models/analysis_model.dart';

class AnalysisFormScreen extends StatefulWidget {
  final Analysis? analysis;
  final String? shellLang;      // lang from shell (optional)
  final VoidCallback? onSaved;  // called after save instead of Navigator.pop

  const AnalysisFormScreen({
    super.key, this.analysis, this.shellLang, this.onSaved});

  @override
  State<AnalysisFormScreen> createState() => _AnalysisFormScreenState();
}

class _AnalysisFormScreenState extends State<AnalysisFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String currentLanguage;
  bool _saving = false;

  final teCodeEch       = TextEditingController();
  final teNomClient     = TextEditingController();
  final teCodeClient    = TextEditingController();
  final teQuantiteHuile = TextEditingController();
  final teDateReception = TextEditingController();
  final teDateAnalyse   = TextEditingController();
  final teAcidite       = TextEditingController();
  final teMasseK232     = TextEditingController();
  final teAbs232        = TextEditingController();
  final teMasseK270     = TextEditingController();
  final teAbs270        = TextEditingController();
  final teAbs274        = TextEditingController();
  final teAbs266        = TextEditingController();

  double? k232, k270, k274, k266, deltaK;
  bool? conforme;
  List<String> nonConformes = [];

  bool get _isEdit => widget.analysis != null;
  bool get _inShell => widget.onSaved != null;

  @override
  void initState() {
    super.initState();
    currentLanguage = widget.shellLang ?? 'fr';
    if (_isEdit) {
      final a = widget.analysis!;
      teCodeEch.text       = a.codeEchantillon;
      teNomClient.text     = a.nomClient;
      teCodeClient.text    = a.codeClient;
      teQuantiteHuile.text = a.quantiteHuile ?? '';
      teDateReception.text = _fmt(a.dateReception);
      teDateAnalyse.text   = _fmt(a.dateAnalyse);
      teAcidite.text       = a.aciditeLibre.toString();
      teMasseK232.text     = a.masseK232.toString();
      teAbs232.text        = a.absorbance232.toString();
      teMasseK270.text     = a.masseK270.toString();
      teAbs270.text        = a.absorbance270.toString();
      teAbs274.text        = a.absorbance274.toString();
      teAbs266.text        = a.absorbance266.toString();
      _compute();
    }
  }

  String _fmt(DateTime d) =>
    '${d.day.toString().padLeft(2,"0")}/${d.month.toString().padLeft(2,"0")}/${d.year}';

  @override
  void dispose() {
    teCodeEch.dispose(); teNomClient.dispose(); teCodeClient.dispose();
    teQuantiteHuile.dispose(); teDateReception.dispose(); teDateAnalyse.dispose();
    teAcidite.dispose(); teMasseK232.dispose(); teAbs232.dispose();
    teMasseK270.dispose(); teAbs270.dispose(); teAbs274.dispose(); teAbs266.dispose();
    super.dispose();
  }

  void _compute() {
    final mK232   = double.tryParse(teMasseK232.text.replaceAll(',', '.')) ?? 0;
    final a232    = double.tryParse(teAbs232.text.replaceAll(',', '.')) ?? 0;
    final mK270   = double.tryParse(teMasseK270.text.replaceAll(',', '.')) ?? 0;
    final a270    = double.tryParse(teAbs270.text.replaceAll(',', '.')) ?? 0;
    final a274    = double.tryParse(teAbs274.text.replaceAll(',', '.')) ?? 0;
    final a266    = double.tryParse(teAbs266.text.replaceAll(',', '.')) ?? 0;
    final acidite = double.tryParse(teAcidite.text.replaceAll(',', '.')) ?? 0;
    final hasK232 = mK232 > 0 && a232 > 0;
    final hasK270 = mK270 > 0 && a270 > 0;
    setState(() {
      k232   = hasK232 ? Calculations.calculateK232(a232, mK232) : null;
      k270   = hasK270 ? Calculations.calculateK270(a270, mK270) : null;
      k274   = hasK270 ? Calculations.calculateK274(a274, mK270) : null;
      k266   = hasK270 ? Calculations.calculateK266(a266, mK270) : null;
      deltaK = (k270 != null && k274 != null && k266 != null)
        ? Calculations.calculateDeltaK(k270!, k274!, k266!) : null;
      if (k232 != null && k270 != null && deltaK != null) {
        conforme = Calculations.isAnalysisCompliant(
          acidite: acidite, k232: k232!, k270: k270!, deltaK: deltaK!);
        nonConformes = Calculations.getNonCompliantParameters(
          acidite: acidite, k232: k232!, k270: k270!, deltaK: deltaK!);
      } else {
        conforme = null; nonConformes = [];
      }
    });
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context, locale: Locale(currentLanguage),
      initialDate: DateTime.now(),
      firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) { ctrl.text = _fmt(picked); _compute(); }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (k232 == null || k270 == null || deltaK == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t('fill_fields')),
        backgroundColor: AppColors.errorRed, behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _saving = true);
    try {
      DateTime parseDate(String s) {
        final p = s.split('/');
        return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      }
      final analysis = Analysis(
        id: _isEdit ? widget.analysis!.id : null,
        codeEchantillon: teCodeEch.text.trim(),
        nomClient:       teNomClient.text.trim(),
        codeClient:      teCodeClient.text.trim(),
        quantiteHuile:   teQuantiteHuile.text.trim().isEmpty
                           ? null : teQuantiteHuile.text.trim(),
        dateReception:   parseDate(teDateReception.text),
        dateAnalyse:     parseDate(teDateAnalyse.text),
        aciditeLibre:    double.parse(teAcidite.text.replaceAll(',', '.')),
        masseK232:       double.parse(teMasseK232.text.replaceAll(',', '.')),
        absorbance232:   double.parse(teAbs232.text.replaceAll(',', '.')),
        masseK270:       double.parse(teMasseK270.text.replaceAll(',', '.')),
        absorbance270:   double.parse(teAbs270.text.replaceAll(',', '.')),
        absorbance274:   double.parse(teAbs274.text.replaceAll(',', '.')),
        absorbance266:   double.parse(teAbs266.text.replaceAll(',', '.')),
        k232Calcule:     k232!, k270Calcule: k270!,
        k274Calcule:     k274!, k266Calcule: k266!,
        deltaKCalcule:   deltaK!, conforme: conforme ?? false,
        dateCreation:    DateTime.now(),
      );
      if (_isEdit) {
        await DatabaseService.instance.updateAnalysis(analysis);
      } else {
        await DatabaseService.instance.createAnalysis(analysis);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        // FIXED: was t(t('key')) — double wrap bug
        content: Text(t(_isEdit ? t('analysis_updated') : t('analysis_saved'))),
        backgroundColor: const Color.fromARGB(255, 130, 131, 66), behavior: SnackBarBehavior.floating));
      if (_inShell) {
        widget.onSaved!();
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur: $e'),
        backgroundColor: AppColors.errorRed, behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String t(String k) => LocalizationService.translate(k, currentLanguage);

  @override
  Widget build(BuildContext context) {
    // When used inside a dialog (in-shell), no Scaffold wrapper needed
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(children: [
                  Expanded(child: Text(
                    _isEdit ? t('edit_analysis') : t('new_analysis_form'),
                    style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: _inShell ? const Color.fromARGB(255, 241, 183, 117) : AppColors.textPrimary))),
                  if (!_inShell)
                    _LangPicker(current: currentLanguage,
                      onChanged: (l) => setState(() => currentLanguage = l)),
                ]),
                const SizedBox(height: 20),

                _Sec(t('sample_code').replaceAll(' *', '')),
                const SizedBox(height: 8),
                Card(margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(children: [
                      Row(children: [
                        Expanded(child: CustomTextField(t('sample_code'), teCodeEch, onChanged: (_) => _compute())),
                        const SizedBox(width: 8),
                        Expanded(child: CustomTextField(t('client_name'), teNomClient, onChanged: (_) => _compute())),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: CustomTextField(t('client_code'), teCodeClient, onChanged: (_) => _compute())),
                        const SizedBox(width: 8),
                        Expanded(child: CustomTextField(t('oil_quantity'), teQuantiteHuile, numeric: true, onChanged: (_) => _compute())),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: CustomTextField(t('reception_date'), teDateReception, readOnly: true, onTap: () => _selectDate(teDateReception))),
                        const SizedBox(width: 8),
                        Expanded(child: CustomTextField(t('analysis_date'), teDateAnalyse, readOnly: true, onTap: () => _selectDate(teDateAnalyse))),
                      ]),
                    ]))),

                _Sec(t('free_acidity').replaceAll(' *', '')),
                const SizedBox(height: 8),
                Card(margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CustomTextField(t('free_acidity'), teAcidite, numeric: true, onChanged: (_) => _compute()),
                      const SizedBox(height: 6),
                      Text('${t('standard')}: <= 0,8%', style: AppTextStyles.caption),
                    ]))),
                    

                _Sec(t('uv_analysis_k232')),
                const SizedBox(height: 8),
                Card(margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: CustomTextField(t('mass'), teMasseK232, numeric: true, onChanged: (_) => _compute())),
                        const SizedBox(width: 8),
                        Expanded(child: CustomTextField(t('abs_232'), teAbs232, numeric: true, onChanged: (_) => _compute())),
                      ]),
                      const SizedBox(height: 8),
                      ResultCard('K232 ${t("calculated")}', k232?.toStringAsFixed(4) ?? '-',
                        compliant: k232 == null ? null : k232! <= AppConstants.maxK232, norm: '<= 2,50'),
                    ]))),

                _Sec(t('uv_analysis_k270')),
                const SizedBox(height: 8),
                Card(margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: CustomTextField(t('mass'), teMasseK270, numeric: true, onChanged: (_) => _compute())),
                        const SizedBox(width: 8),
                        Expanded(child: CustomTextField(t('abs_270'), teAbs270, numeric: true, onChanged: (_) => _compute())),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: CustomTextField(t('abs_274'), teAbs274, numeric: true, onChanged: (_) => _compute())),
                        const SizedBox(width: 8),
                        Expanded(child: CustomTextField(t('abs_266'), teAbs266, numeric: true, onChanged: (_) => _compute())),
                      ]),
                      const SizedBox(height: 8),
                      ResultCard('K270 ${t("calculated")}', k270?.toStringAsFixed(4) ?? '-',
                        compliant: k270 == null ? null : k270! <= AppConstants.maxK270, norm: '<= 0,22'),
                      ResultCard('K274 ${t("calculated")}', k274?.toStringAsFixed(4) ?? '-'),
                      ResultCard('K266 ${t("calculated")}', k266?.toStringAsFixed(4) ?? '-'),
                      ResultCard('Delta K', deltaK?.toStringAsFixed(4) ?? '-',
                        compliant: deltaK == null ? null : deltaK!.abs() <= AppConstants.maxDeltaK, norm: '<= 0,01'),
                    ]))),

                // Conformity
                Card(
                  color: conforme == null ? null
                    : conforme! ? AppColors.successGreen.withValues(alpha: 0.1)
                                : AppColors.errorRed.withValues(alpha: 0.1),
                  margin: const EdgeInsets.only(bottom: 24),
                  child: ListTile(
                    leading: conforme == null
                      ? const Icon(Icons.info_outline, color: AppColors.textSecondary)
                      : Icon(conforme!
                          ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                          color: conforme! ? AppColors.successGreen : AppColors.errorRed, size: 28),
                    title: conforme == null
                      ? Text(t('fill_fields'))
                      : Text(conforme! ? 'CONFORME' : 'NON CONFORME',
                          style: TextStyle(fontWeight: FontWeight.w700,
                            color: conforme! ? AppColors.successGreen : AppColors.errorRed)),
                    subtitle: (conforme == false && nonConformes.isNotEmpty)
                      ? Text('${t("non_compliant")}: ${nonConformes.join(", ")}',
                          style: TextStyle(color: AppColors.errorRed, fontSize: 12))
                      : null)),

                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton(
                    onPressed: () {
                      if (_inShell) widget.onSaved!();
                      else Navigator.pop(context);
                    },
                    child: Text(t('cancel'))),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined, size: 18),
                    label: Text(_saving
                      ? 'Enregistrement...'
                      : t(_isEdit ? 'update' : 'save'))),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );

    // If called as standalone route, wrap in Scaffold+AppBar
    if (!_inShell) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? t('edit_analysis') : t('new_analysis_form')),
          actions: [
            _LangPicker(current: currentLanguage,
              onChanged: (l) => setState(() => currentLanguage = l)),
            const SizedBox(width: 12),
          ]),
        body: content);
    }
    return content;
  }
}

class _Sec extends StatelessWidget {
  final String label; const _Sec(this.label);
  @override
  Widget build(BuildContext context) => Text(label.toUpperCase(),
    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700,
      color: AppColors.textSecondary, letterSpacing: 1.1));
}

class _LangPicker extends StatelessWidget {
  final String current; final void Function(String) onChanged;
  const _LangPicker({required this.current, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: AppColors.border)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      for (final l in [('fr','FR'), ('ar','AR'), ('en','EN')])
        GestureDetector(onTap: () => onChanged(l.$1),
          child: AnimatedContainer(duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: current == l.$1 ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(5)),
            child: Text(l.$2, style: GoogleFonts.inter(fontSize: 10,
              fontWeight: FontWeight.w700,
              color: current == l.$1 ? AppColors.accent : AppColors.textMuted)))),
    ]));
}