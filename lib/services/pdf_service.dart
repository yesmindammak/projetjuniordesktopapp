import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:io';
import '../models/analysis_model.dart';

class PdfService {
  static Future<void> generatePdf(Analysis analysis) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green700,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('MENANA ORGANIC FOOD',
                      style: pw.TextStyle(fontSize: 24,
                        fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    pw.Text('Laboratoire de Controle Qualite',
                      style: pw.TextStyle(fontSize: 12,
                        color: PdfColor.fromHex('#E0E0E0'))),
                    pw.SizedBox(height: 8),
                    pw.Text("RAPPORT D'ANALYSE",
                      style: pw.TextStyle(fontSize: 18,
                        fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Client Info
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#E3F2FD'),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('INFORMATIONS CLIENT',
                      style: pw.TextStyle(fontSize: 12,
                        fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.SizedBox(height: 8),
                    _row('Code Echantillon:', analysis.codeEchantillon),
                    _row('Nom Client:', analysis.nomClient),
                    _row('Code Client:', analysis.codeClient),
                    _row("Quantite d'Huile:", '${analysis.quantiteHuile ?? "-"} L'),
                    _row('Date Reception:',
                      '${analysis.dateReception.day}/${analysis.dateReception.month}/${analysis.dateReception.year}'),
                    _row('Date Analyse:',
                      '${analysis.dateAnalyse.day}/${analysis.dateAnalyse.month}/${analysis.dateAnalyse.year}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Results table
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FFF3E0'),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('RESULTATS ANALYSES',
                      style: pw.TextStyle(fontSize: 12,
                        fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.SizedBox(height: 12),
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.blue900
                      , width: 1.5),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(2.5),
                        1: const pw.FlexColumnWidth(1.2),
                        2: const pw.FlexColumnWidth(1.2),
                        3: const pw.FlexColumnWidth(0.8),
                      },
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: PdfColors.blue600),
                          children: [
                            _headerCell('Parametre'),
                            _headerCell('Resultat'),
                            _headerCell('Norme'),
                            _headerCell('Statut'),
                          ],
                        ),
                        _resultRow('Acidite Libre (%)',
                          analysis.aciditeLibre.toStringAsFixed(2),
                          '<= 0.8', analysis.aciditeLibre <= 0.8, false),
                        _resultRow('K232',
                          analysis.k232Calcule.toStringAsFixed(4),
                          '<= 2.50', analysis.k232Calcule <= 2.50, true),
                        _resultRow('K270',
                          analysis.k270Calcule.toStringAsFixed(4),
                          '<= 0.22', analysis.k270Calcule <= 0.22, false),
                        _resultRow('K274',
                          analysis.k274Calcule.toStringAsFixed(4),
                          '-', true, true),
                        _resultRow('K266',
                          analysis.k266Calcule.toStringAsFixed(4),
                          '-', true, false),
                        _resultRow('Delta K',
                          analysis.deltaKCalcule.toStringAsFixed(4),
                          '<= 0.01',
                          analysis.deltaKCalcule.abs() <= 0.01, true),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Conclusion — plain ASCII only
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: analysis.conforme
                      ? PdfColor.fromHex('#E8F5E9')
                      : PdfColor.fromHex('#FFEBEE'),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(
                    color: analysis.conforme ? PdfColors.green700 : PdfColors.grey700,
                    width: 2),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('CONCLUSION',
                      style: pw.TextStyle(fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: analysis.conforme ? PdfColors.green900 : PdfColors.grey900)),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      analysis.conforme
                          ? 'Echantillon CONFORME'
                          : 'Echantillon NON CONFORME',
                      style: pw.TextStyle(fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: analysis.conforme ? PdfColors.green700 : PdfColors.grey700)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  _signatureField('Analyste'),
                  _signatureField('Chef de Laboratoire'),
                ],
              ),
              pw.SizedBox(height: 20),

              // Footer
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Genere le: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} a ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, "0")}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              ),
            ],
          );
        },
      ),
    );

    await _save(doc, analysis);
  }

  static Future<void> _save(pw.Document doc, Analysis analysis) async {
    try {
      final userProfile = Platform.environment['USERPROFILE'] ?? '';
      final downloadsDir = Directory('$userProfile\\Downloads');
      final timestamp = DateTime.now()
          .toString().replaceAll(RegExp(r'[:\s.-]'), '_');
      final filename = 'Analyse_${analysis.codeEchantillon}_$timestamp.pdf';
      final filepath = '${downloadsDir.path}\\$filename';
      final file = File(filepath);
      await file.writeAsBytes(await doc.save());
      Process.run('start', [filepath], runInShell: true);
    } catch (e) {
      rethrow;
    }
  }

  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(children: [
        pw.Text(label,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 8),
        pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
      ]),
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text,
        style: pw.TextStyle(fontSize: 11,
          fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
    );
  }

  static pw.TableRow _resultRow(
    String param, String value, String norm,
    bool compliant, bool alternate,
  ) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: alternate ? PdfColor.fromHex('#FFF9E6') : PdfColors.white),
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(8),
          child: pw.Text(param, style: const pw.TextStyle(fontSize: 10))),
        pw.Padding(padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 10))),
        pw.Padding(padding: const pw.EdgeInsets.all(8),
          child: pw.Text(norm, style: const pw.TextStyle(fontSize: 10))),
        pw.Padding(padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            compliant ? 'OK' : 'NON',
            style: pw.TextStyle(
              fontSize: 11, fontWeight: pw.FontWeight.bold,
              color: compliant ? PdfColors.green700 : PdfColors.red700))),
      ],
    );
  }

  static pw.Widget _signatureField(String title) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Container(
          width: 120, height: 60,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.black, width: 1)))),
        pw.SizedBox(height: 4),
        pw.Text(title, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }
}