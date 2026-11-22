import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/unit_model.dart';

class IsometricUnitPainter extends CustomPainter {
  final ConfiguredUnit unit;

  IsometricUnitPainter({required this.unit});

  static const double _cos30 = 0.8660254;
  static const double _sin30 = 0.5;

  @override
  void paint(Canvas canvas, Size size) {
    final double wVal = math.max(25.0, unit.width);
    final double hVal = math.max(25.0, unit.height);
    final double dVal = math.max(20.0, unit.depth);

    final double maxDim = math.max(wVal, math.max(hVal, dVal));
    final double scale = (math.min(size.width, size.height) * 0.44) / math.max(35.0, maxDim);

    final double bw = (wVal * scale).clamp(44.0, size.width * 0.48);
    final double bh = (hVal * scale).clamp(36.0, size.height * 0.52);
    final double dPx = (dVal * scale * 0.55).clamp(16.0, 52.0);
    final Offset isoD = Offset(dPx * _cos30, -dPx * _sin30);

    final double totalVisualW = bw + isoD.dx;
    final double startX = (size.width - totalVisualW) * 0.5;

    final bool isWallHanging = unit.preset.category == MainCategory.kitchenWall &&
        unit.preset.kind != UnitTemplateKind.applianceTower &&
        unit.preset.id != 'kw_tall';

    final double legH = isWallHanging ? 0.0 : (size.height * 0.05).clamp(6.0, 12.0);
    final double bodyBottomY = size.height * 0.78 - legH;
    final double bodyTopY = bodyBottomY - bh;

    final Paint linePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final Paint fillFront = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    final Paint fillSide = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final Paint fillTop = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;

    // أرجل الوحدات الأرضية غير المعلقة
    if (!isWallHanging) {
      final List<Offset> footBases = [
        Offset(startX + 4, bodyBottomY),
        Offset(startX + bw - 4, bodyBottomY),
        Offset(startX + bw - 4 + isoD.dx, bodyBottomY + isoD.dy),
      ];
      for (final p in footBases) {
        canvas.drawLine(p, Offset(p.dx, p.dy + legH), linePaint);
      }
    }

    // السطح العلوي (أيزومترك قياسي نظيف)
    final Path topFace = Path()
      ..moveTo(startX, bodyTopY)
      ..lineTo(startX + bw, bodyTopY)
      ..lineTo(startX + bw + isoD.dx, bodyTopY + isoD.dy)
      ..lineTo(startX + isoD.dx, bodyTopY + isoD.dy)
      ..close();
    canvas.drawPath(topFace, fillTop);
    canvas.drawPath(topFace, linePaint);

    // الجنب الأيمن
    final Path sideFace = Path()
      ..moveTo(startX + bw, bodyTopY)
      ..lineTo(startX + bw + isoD.dx, bodyTopY + isoD.dy)
      ..lineTo(startX + bw + isoD.dx, bodyBottomY + isoD.dy)
      ..lineTo(startX + bw, bodyBottomY)
      ..close();
    canvas.drawPath(sideFace, fillSide);
    canvas.drawPath(sideFace, linePaint);

    // الواجهة الأمامية
    final Rect frontBox = Rect.fromLTWH(startX, bodyTopY, bw, bh);
    canvas.drawRect(frontBox, fillFront);
    canvas.drawRect(frontBox, linePaint);

    // تقسيمات الواجهة البسيطة والواضحة (أدراج / ضلف / أرفف)
    final double innerX = startX + 3;
    final double innerW = math.max(10.0, bw - 6);
    double curY = bodyTopY + 3;
    double availH = math.max(10.0, bh - 6);

    if (unit.drawersCount > 0 && unit.doorsCount == 0) {
      final int drwN = math.max(1, unit.drawersCount);
      final double dH = availH / drwN;
      for (int i = 0; i < drwN; i++) {
        canvas.drawRect(
          Rect.fromLTWH(innerX, curY + i * dH, innerW, math.max(5.0, dH - 1.5)),
          linePaint,
        );
      }
      return;
    }

    if (unit.drawersCount > 0) {
      final double drwZoneH = availH * 0.25;
      canvas.drawRect(Rect.fromLTWH(innerX, curY, innerW, drwZoneH - 1.5), linePaint);
      curY += drwZoneH;
      availH -= drwZoneH;
    }

    if (unit.doorsCount > 0) {
      final int dCount = math.max(1, unit.doorsCount);
      final double singleDoorW = innerW / dCount;
      for (int i = 0; i < dCount; i++) {
        canvas.drawRect(
          Rect.fromLTWH(
            innerX + i * singleDoorW + 1,
            curY,
            math.max(4.0, singleDoorW - 2),
            math.max(6.0, availH),
          ),
          linePaint,
        );
      }
    } else if (unit.shelvesCount > 0) {
      final int shN = math.max(1, math.min(6, unit.shelvesCount));
      for (int i = 1; i <= shN; i++) {
        final double sy = curY + (availH / (shN + 1)) * i;
        canvas.drawLine(Offset(innerX, sy), Offset(innerX + innerW, sy), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant IsometricUnitPainter oldDelegate) {
    return oldDelegate.unit.width != unit.width ||
        oldDelegate.unit.height != unit.height ||
        oldDelegate.unit.depth != unit.depth ||
        oldDelegate.unit.shelvesCount != unit.shelvesCount ||
        oldDelegate.unit.doorsCount != unit.doorsCount ||
        oldDelegate.unit.drawersCount != unit.drawersCount ||
        oldDelegate.unit.preset.id != unit.preset.id;
  }
}