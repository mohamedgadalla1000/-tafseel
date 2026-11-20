import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../engine/nesting_engine.dart';

class ExportService {
  /// تصدير مخطط التقطيع بالكامل إلى ملف DXF جاهز لماكينات CNC (ArtCAM / Aspire)
  static Future<String?> exportToDxf({
    required String projectName,
    required NestingResult result,
  }) async {
    final StringBuffer dxf = StringBuffer();

    // Header
    dxf.writeln('0\nSECTION\n2\nHEADER\n0\nENDSEC');

    // Tables (Layers)
    dxf.writeln('0\nSECTION\n2\nTABLES\n0\nTABLE\n2\nLAYER');
    _writeDxfLayer(dxf, 'SHEET_BORDER', 3); // أخضر لحدود اللوح
    _writeDxfLayer(dxf, 'CUT_OUTLINE', 1); // أحمر للقص الخارجي
    _writeDxfLayer(dxf, 'PIECE_TEXT', 5); // أزرق لأسماء ومقاسات القطع
    dxf.writeln('0\nENDTAB\n0\nENDSEC');

    // Entities
    dxf.writeln('0\nSECTION\n2\nENTITIES');

    double offsetX = 0.0;
    const double sheetGapCm = 30.0; // مسافة فاصلة بين كل لوح واللي جنبه في الـ DXF

    result.sheetsByMaterial.forEach((material, sheets) {
      for (final sheet in sheets) {
        // 1. رسم حدود اللوح (بالمليمتر: * 10)
        final double sw = sheet.sheetLength * 10.0;
        final double sh = sheet.sheetWidth * 10.0;
        _writeDxfRect(dxf, 'SHEET_BORDER', offsetX, 0, sw, sh);

        // عنوان اللوح أعلى اللوح
        _writeDxfText(
          dxf,
          'PIECE_TEXT',
          offsetX,
          sh + 40.0,
          35.0,
          'Sheet #${sheet.sheetNumber} - $material (${sheet.sheetLength.toInt()}x${sheet.sheetWidth.toInt()} cm)',
        );

        // 2. رسم كل قطعة داخل اللوح بالمليمتر
        for (final p in sheet.placedPieces) {
          final double px = offsetX + (p.x * 10.0);
          final double py = p.y * 10.0;
          final double pw = p.placedLength * 10.0;
          final double ph = p.placedWidth * 10.0;

          _writeDxfRect(dxf, 'CUT_OUTLINE', px, py, pw, ph);

          final String dimLabel =
              '${p.id} | ${p.placedLength.toStringAsFixed(1)}x${p.placedWidth.toStringAsFixed(1)}';
          _writeDxfText(
            dxf,
            'PIECE_TEXT',
            px + 15.0,
            py + (ph / 2.0),
            18.0,
            dimLabel,
          );
        }

        offsetX += sw + (sheetGapCm * 10.0);
      }
    });

    dxf.writeln('0\nENDSEC\n0\nEOF');

    final Uint8List dxfBytes = Uint8List.fromList(utf8.encode(dxf.toString()));
    final String safeFileName =
        '${projectName.trim().isEmpty ? "Project" : projectName.trim().replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_')}_CNC.dxf';

    final dynamic picked = await FilePicker.saveFile(
      dialogTitle: 'حفظ ملف CNC (DXF)',
      fileName: safeFileName,
      bytes: dxfBytes,
      mimeType: 'application/dxf',
    );

    if (picked == null) return null;

    final String resolvedPath =
        picked is Uri ? picked.toFilePath() : picked.toString();

    if (resolvedPath.isNotEmpty) {
      final file = File(resolvedPath);
      if (!await file.exists()) {
        await file.writeAsBytes(dxfBytes);
      }
      return resolvedPath;
    }

    return safeFileName;
  }

  static void _writeDxfLayer(StringBuffer sb, String name, int color) {
    sb.writeln('0\nLAYER\n2\n$name\n70\n0\n62\n$color\n6\nCONTINUOUS');
  }

  static void _writeDxfRect(
    StringBuffer sb,
    String layer,
    double x,
    double y,
    double w,
    double h,
  ) {
    sb.writeln('0\nLWPOLYLINE\n8\n$layer\n90\n4\n70\n1');
    sb.writeln('10\n${x.toStringAsFixed(2)}\n20\n${y.toStringAsFixed(2)}');
    sb.writeln('10\n${(x + w).toStringAsFixed(2)}\n20\n${y.toStringAsFixed(2)}');
    sb.writeln('10\n${(x + w).toStringAsFixed(2)}\n20\n${(y + h).toStringAsFixed(2)}');
    sb.writeln('10\n${x.toStringAsFixed(2)}\n20\n${(y + h).toStringAsFixed(2)}');
  }

  static void _writeDxfText(
    StringBuffer sb,
    String layer,
    double x,
    double y,
    double height,
    String text,
  ) {
    // تنظيف النص للحروف الإنجليزية والأرقام لضمان توافق ArtCAM
    final safeText = text.replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim();
    final finalText = safeText.isEmpty ? 'PART' : safeText;
    sb.writeln(
        '0\nTEXT\n8\n$layer\n10\n${x.toStringAsFixed(2)}\n20\n${y.toStringAsFixed(2)}\n40\n$height\n1\n$finalText');
  }

  /// توليد وطباعة/حفظ تقرير PDF احترافي للورشة
  static Future<void> exportToPdf({
    required String projectName,
    required String clientName,
    required NestingResult result,
  }) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (context) => [
          // الهيدر
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.blueGrey900,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'شركة الإسراء - تقرير التقطيع الذكي (Cut List)',
                      style: pw.TextStyle(
                          color: PdfColors.tealAccent200,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'المشروع: $projectName  |  العميل: ${clientName.isEmpty ? "عام" : clientName}',
                      style: const pw.TextStyle(
                          color: PdfColors.white, fontSize: 11),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'إجمالي الألواح: ${result.totalSheetsCount} لوح',
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'إجمالي القشاط: ${result.totalEdgeMeters.toStringAsFixed(1)} متر',
                      style: const pw.TextStyle(
                          color: PdfColors.amber200, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // ملخص الخامات المنفصلة
          pw.Text('1. ملخص الخامات والألواح وشريط الحواف (PVC):',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: [
              'الخامة',
              'عدد الألواح',
              'مقاس اللوح (سم)',
              'نسبة الاستغلال',
              'شريط الحواف (متر)',
            ],
            data: result.sheetsByMaterial.entries.map((entry) {
              final mat = entry.key;
              final sheets = entry.value;
              final avgUtil = sheets.isEmpty
                  ? 0.0
                  : sheets.fold(0.0, (s, e) => s + e.utilizationPercent) /
                      sheets.length;
              final matEdge =
                  sheets.fold(0.0, (s, e) => s + e.totalEdgeMeters);
              final sizeStr = sheets.isEmpty
                  ? '-'
                  : '${sheets.first.sheetLength.toInt()} × ${sheets.first.sheetWidth.toInt()}';
              return [
                mat,
                '${sheets.length} لوح',
                sizeStr,
                '${avgUtil.toStringAsFixed(1)}%',
                '${matEdge.toStringAsFixed(2)} م',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
            cellAlignment: pw.Alignment.center,
          ),
          pw.SizedBox(height: 20),

          // مخططات تقطيع كل لوح
          pw.Text('2. مخطط رص الألواح وتفاصيل القطع:',
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          ...result.sheetsByMaterial.entries.expand((entry) {
            return entry.value.map((sheet) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 18),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'لوح #${sheet.sheetNumber} — الخامة: ${sheet.material}',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 11),
                        ),
                        pw.Text(
                          'استغلال: ${sheet.utilizationPercent.toStringAsFixed(1)}% | هالك: ${sheet.wastePercent.toStringAsFixed(1)}% | قشاط: ${sheet.totalEdgeMeters.toStringAsFixed(2)} م',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.teal800),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    // رسم اللوح Vector داخل الـ PDF
                    pw.Center(
                      child: pw.SizedBox(
                        width: 460,
                        height: 230,
                        child: pw.CustomPaint(
                          painter: (canvas, size) {
                            final scaleX = size.x / sheet.sheetLength;
                            final scaleY = size.y / sheet.sheetWidth;
                            final scale =
                                scaleX < scaleY ? scaleX : scaleY;

                            // حدود اللوح
                            canvas
                              ..setColor(PdfColors.grey200)
                              ..drawRect(0, 0, sheet.sheetLength * scale,
                                  sheet.sheetWidth * scale)
                              ..fillPath()
                              ..setColor(PdfColors.black)
                              ..setLineWidth(1.2)
                              ..drawRect(0, 0, sheet.sheetLength * scale,
                                  sheet.sheetWidth * scale)
                              ..strokePath();

                            // القطع
                            for (final p in sheet.placedPieces) {
                              final rx = p.x * scale;
                              final ry = p.y * scale;
                              final rw = p.placedLength * scale;
                              final rh = p.placedWidth * scale;

                              canvas
                                ..setColor(PdfColors.teal50)
                                ..drawRect(rx, ry, rw, rh)
                                ..fillPath()
                                ..setColor(PdfColors.teal900)
                                ..setLineWidth(0.7)
                                ..drawRect(rx, ry, rw, rh)
                                ..strokePath();
                            }
                          },
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: sheet.placedPieces.map((p) {
                        return pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey100,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            '${p.id}: ${p.partName} (${p.placedLength.toStringAsFixed(1)}×${p.placedWidth.toStringAsFixed(1)} سم)',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            });
          }),
        ],
      ),
    );

    final Uint8List pdfBytes = await doc.save();
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
      name: '${projectName}_CutList.pdf',
    );
  }
}