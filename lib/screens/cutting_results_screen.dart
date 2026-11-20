import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../engine/nesting_engine.dart';
import '../services/export_service.dart';

class CuttingResultsScreen extends StatelessWidget {
  final String projectName;
  final String clientName;
  final NestingResult result;

  const CuttingResultsScreen({
    super.key,
    required this.projectName,
    required this.clientName,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final materials = result.sheetsByMaterial.keys.toList();

    return DefaultTabController(
      length: math.max(1, materials.length),
      child: Scaffold(
        appBar: AppBar(
          title: Text("مخطط التقطيع الذكي - $projectName"),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final path = await ExportService.exportToDxf(
                    projectName: projectName,
                    result: result,
                  );
                  if (path != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("تم حفظ ملف CNC (DXF) في: $path"),
                        backgroundColor: const Color(0xFF0D9488),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.precision_manufacturing,
                    color: Colors.black, size: 18),
                label: const Text(
                  "تصدير DXF للـ CNC",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () => ExportService.exportToPdf(
                  projectName: projectName,
                  clientName: clientName,
                  result: result,
                ),
                icon: const Icon(Icons.picture_as_pdf,
                    color: Colors.black, size: 18),
                label: const Text(
                  "تصدير PDF للورشة",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DD4BF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
          bottom: materials.isEmpty
              ? null
              : TabBar(
                  isScrollable: true,
                  indicatorColor: const Color(0xFF2DD4BF),
                  labelColor: const Color(0xFF2DD4BF),
                  unselectedLabelColor: Colors.white70,
                  tabs: materials.map((mat) {
                    final count = result.sheetsByMaterial[mat]!.length;
                    return Tab(text: "$mat ($count لوح)");
                  }).toList(),
                ),
        ),
        body: Column(
          children: [
            // شريط الإحصائيات الإجمالية
            Container(
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statCard(
                    "إجمالي الألواح",
                    "${result.totalSheetsCount} لوح",
                    Icons.layers_outlined,
                    const Color(0xFF2DD4BF),
                  ),
                  _statCard(
                    "إجمالي شريط الحواف (PVC)",
                    "${result.totalEdgeMeters.toStringAsFixed(2)} متر",
                    Icons.straighten,
                    Colors.orangeAccent,
                  ),
                  _statCard(
                    "نسبة الهالك الإجمالية",
                    "${result.overallWastePercent.toStringAsFixed(1)}%",
                    Icons.pie_chart_outline,
                    result.overallWastePercent > 25
                        ? Colors.redAccent
                        : Colors.greenAccent,
                  ),
                  _statCard(
                    "عدد الخامات المفصولة",
                    "${materials.length} خامات",
                    Icons.category_outlined,
                    Colors.lightBlueAccent,
                  ),
                ],
              ),
            ),

            if (result.oversizedPieces.isNotEmpty)
              Container(
                width: double.infinity,
                color: Colors.red.withValues(alpha: 0.2),
                padding: const EdgeInsets.all(10),
                child: Text(
                  "تنبيه: يوجد ${result.oversizedPieces.length} قطعة مقاسها أكبر من مقاس اللوح القياسي!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),

            Expanded(
              child: materials.isEmpty
                  ? const Center(child: Text("لا توجد قطع للتقطيع"))
                  : TabBarView(
                      children: materials.map((mat) {
                        final sheets = result.sheetsByMaterial[mat]!;
                        final matEdgeMeters = sheets.fold(
                            0.0, (s, sh) => s + sh.totalEdgeMeters);
                        return _MaterialSheetsView(
                          materialName: mat,
                          sheets: sheets,
                          materialEdgeMeters: matEdgeMeters,
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ],
    );
  }
}

class _MaterialSheetsView extends StatelessWidget {
  final String materialName;
  final List<NestingSheet> sheets;
  final double materialEdgeMeters;

  const _MaterialSheetsView({
    required this.materialName,
    required this.sheets,
    required this.materialEdgeMeters,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sheets.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "خامة: $materialName",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2DD4BF)),
                ),
                Text(
                  "عدد الألواح: ${sheets.length}  |  شريط الحواف المطلوب لهذه الخامة: ${materialEdgeMeters.toStringAsFixed(2)} متر",
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        final sheet = sheets[index - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161F30),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "لوح رقم #${sheet.sheetNumber} (${sheet.sheetLength.toInt()} × ${sheet.sheetWidth.toInt()} سم)",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      _badge(
                          "استغلال ${sheet.utilizationPercent.toStringAsFixed(1)}%",
                          Colors.greenAccent),
                      const SizedBox(width: 8),
                      _badge("هالك ${sheet.wastePercent.toStringAsFixed(1)}%",
                          Colors.redAccent),
                      const SizedBox(width: 8),
                      _badge("قشاط ${sheet.totalEdgeMeters.toStringAsFixed(2)} م",
                          Colors.orangeAccent),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // لوحة رسم اللوح بالقطع
              Container(
                height: 320,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomPaint(
                  size: const Size(double.infinity, 300),
                  painter: _SheetBoardPainter(sheet: sheet),
                ),
              ),
              const SizedBox(height: 12),

              // جدول القطع الموجودة في هذا اللوح
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sheet.placedPieces.map((p) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      "${p.id} • ${p.partName}: ${p.placedLength.toStringAsFixed(1)} × ${p.placedWidth.toStringAsFixed(1)} سم ${p.rotated ? '(مدورة)' : ''}",
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SheetBoardPainter extends CustomPainter {
  final NestingSheet sheet;

  _SheetBoardPainter({required this.sheet});

  static const List<Color> _palette = [
    Color(0xFFCCFBF1),
    Color(0xFFE0F2FE),
    Color(0xFFFEF3C7),
    Color(0xFFF3E8FF),
    Color(0xFFDCFCE7),
    Color(0xFFFFE4E6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / sheet.sheetLength;
    final double scaleY = size.height / sheet.sheetWidth;
    final double scale = math.min(scaleX, scaleY);

    final double boardW = sheet.sheetLength * scale;
    final double boardH = sheet.sheetWidth * scale;
    final double offsetX = (size.width - boardW) / 2;
    final double offsetY = (size.height - boardH) / 2;

    // خلفية اللوح (الهالك يظهر بلون رمادي مخطط خفيف)
    final boardRect = Rect.fromLTWH(offsetX, offsetY, boardW, boardH);
    canvas.drawRect(boardRect, Paint()..color = const Color(0xFFF1F5F9));
    canvas.drawRect(
      boardRect,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    final edgePaint = Paint()
      ..color = const Color(0xFFEA580C) // لون برتقالي لشريط الحواف PVC
      ..strokeWidth = 3.0;

    for (int i = 0; i < sheet.placedPieces.length; i++) {
      final p = sheet.placedPieces[i];
      final rx = offsetX + (p.x * scale);
      final ry = offsetY + (p.y * scale);
      final rw = p.placedLength * scale;
      final rh = p.placedWidth * scale;

      final rect = Rect.fromLTWH(rx, ry, rw, rh);
      canvas.drawRect(
        rect,
        Paint()..color = _palette[i % _palette.length],
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = const Color(0xFF1E293B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      // رسم خطوط برتقالية للحواف اللي عليها قشاط
      if (!p.rotated) {
        if (p.edgeL1) canvas.drawLine(rect.topLeft, rect.topRight, edgePaint);
        if (p.edgeL2) canvas.drawLine(rect.bottomLeft, rect.bottomRight, edgePaint);
        if (p.edgeW1) canvas.drawLine(rect.topLeft, rect.bottomLeft, edgePaint);
        if (p.edgeW2) canvas.drawLine(rect.topRight, rect.bottomRight, edgePaint);
      } else {
        if (p.edgeL1) canvas.drawLine(rect.topLeft, rect.bottomLeft, edgePaint);
        if (p.edgeL2) canvas.drawLine(rect.topRight, rect.bottomRight, edgePaint);
        if (p.edgeW1) canvas.drawLine(rect.topLeft, rect.topRight, edgePaint);
        if (p.edgeW2) canvas.drawLine(rect.bottomLeft, rect.bottomRight, edgePaint);
      }

      // كتابة المقاس والرقم داخل القطعة لو مساحتها تسمح
      if (rw > 34 && rh > 18) {
        final label =
            "${p.id}\n${p.placedLength.toStringAsFixed(0)}×${p.placedWidth.toStringAsFixed(0)}";
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: rw - 4);

        tp.paint(
          canvas,
          Offset(rx + (rw - tp.width) / 2, ry + (rh - tp.height) / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SheetBoardPainter oldDelegate) => true;
}