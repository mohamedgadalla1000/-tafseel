// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/unit_model.dart';

class IsometricUnitPainter extends CustomPainter {
  final ConfiguredUnit unit;

  IsometricUnitPainter({required this.unit});

  @override
  void paint(Canvas canvas, Size size) {
    final paintStroke = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round;

    final paintFillCarcass = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final paintFillSide = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final paintFillDoor = Paint()
      ..color = unit.glassDoors
          ? const Color(0xFFBAE6FD).withValues(alpha: 0.5)
          : const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    final paintHandle = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    // حساب مقياس الرسم المناسب للشاشة
    double maxDim = math.max(unit.width, math.max(unit.height, unit.depth));
    if (maxDim <= 0) maxDim = 100;
    double scale = (math.min(size.width, size.height) * 0.55) / maxDim;

    double w = unit.width * scale;
    double h = unit.height * scale;
    double d = unit.depth * scale * 0.65;

    // زاوية الأيزومتريك (30 درجة)
    const double angle = math.pi / 6;
    double dx = d * math.cos(angle);
    double dy = d * math.sin(angle);

    // نقطة البداية (مركز الرسم)
    double startX = (size.width - (w + dx)) / 2 + dx;
    double startY = (size.height - (h + dy)) / 2 + dy;

    // إحداثيات الواجهة الأمامية
    Offset flt = Offset(startX, startY);
    Offset frt = Offset(startX + w, startY);
    Offset flb = Offset(startX, startY + h);
    Offset frb = Offset(startX + w, startY + h);

    // إحداثيات الخلفية (المنظور)
    Offset blt = Offset(flt.dx - dx, flt.dy - dy);
    Offset brt = Offset(frt.dx - dx, frt.dy - dy);
    Offset blb = Offset(flb.dx - dx, flb.dy - dy);

    // 1. رسم الجنب الأيسر (المنظور 3D)
    Path leftSide = Path()
      ..moveTo(flt.dx, flt.dy)
      ..lineTo(blt.dx, blt.dy)
      ..lineTo(blb.dx, blb.dy)
      ..lineTo(flb.dx, flb.dy)
      ..close();
    canvas.drawPath(leftSide, paintFillSide);
    canvas.drawPath(leftSide, paintStroke);

    // 2. رسم السقف (المنظور 3D)
    Path topFace = Path()
      ..moveTo(flt.dx, flt.dy)
      ..lineTo(blt.dx, blt.dy)
      ..lineTo(brt.dx, brt.dy)
      ..lineTo(frt.dx, frt.dy)
      ..close();
    canvas.drawPath(topFace, paintFillCarcass);
    canvas.drawPath(topFace, paintStroke);

    // 3. رسم الواجهة الأمامية للشاسيه
    Rect frontRect = Rect.fromPoints(flt, frb);
    canvas.drawRect(frontRect, paintFillCarcass);
    canvas.drawRect(frontRect, paintStroke);

    // 4. رسم الأرفف الداخلية (تظهر إذا لم يكن هناك ضلف أو الضلف زجاج)
    if (unit.shelvesCount > 0 && (unit.doorsCount == 0 || unit.glassDoors)) {
      double stepY = h / (unit.shelvesCount + 1);
      final shelfPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      for (int i = 1; i <= unit.shelvesCount; i++) {
        double sy = flt.dy + (stepY * i);
        canvas.drawLine(
          Offset(flt.dx + 3, sy),
          Offset(frt.dx - 3, sy),
          shelfPaint,
        );
      }
    }

    // 5. رسم الأدراج والضلف على الواجهة
    double currentTopY = flt.dy;
    double remainingH = h;
    final frontElementStroke = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    if (unit.drawersCount > 0) {
      double drawersAreaH = (unit.doorsCount > 0) ? (h * 0.28) : h;
      double singleDrawerH = drawersAreaH / unit.drawersCount;

      for (int i = 0; i < unit.drawersCount; i++) {
        Rect dRect = Rect.fromLTWH(
          flt.dx + 2,
          currentTopY + (i * singleDrawerH) + 1,
          w - 4,
          singleDrawerH - 2,
        );
        canvas.drawRect(dRect, paintFillDoor);
        canvas.drawRect(dRect, frontElementStroke);

        double midX = dRect.center.dx;
        double midY =
            (unit.handleType == HandleType.builtIn) ? dRect.top + 4 : dRect.center.dy;
        canvas.drawLine(
          Offset(midX - 12, midY),
          Offset(midX + 12, midY),
          paintHandle,
        );
      }
      currentTopY += drawersAreaH;
      remainingH -= drawersAreaH;
    }

    if (unit.doorsCount > 0 && remainingH > 10) {
      double singleDoorW = w / unit.doorsCount;
      for (int i = 0; i < unit.doorsCount; i++) {
        Rect doorRect = Rect.fromLTWH(
          flt.dx + (i * singleDoorW) + 1.5,
          currentTopY + 1.5,
          singleDoorW - 3,
          remainingH - 3,
        );
        canvas.drawRect(doorRect, paintFillDoor);
        canvas.drawRect(doorRect, frontElementStroke);

        if (unit.handleType == HandleType.builtIn) {
          canvas.drawLine(
            Offset(doorRect.left + 4, doorRect.top + 3),
            Offset(doorRect.right - 4, doorRect.top + 3),
            paintHandle,
          );
        } else if (unit.handleType == HandleType.external) {
          double hx = (i % 2 == 0) ? doorRect.right - 7 : doorRect.left + 7;
          canvas.drawLine(
            Offset(hx, doorRect.top + 15),
            Offset(hx, doorRect.top + 45),
            paintHandle,
          );
        }
      }
    }

    // 6. رسم الأرجل السفلية (للوحدات الأرضية والدواليب)
    if (unit.preset.category == MainCategory.kitchenBase ||
        unit.preset.category == MainCategory.wardrobe) {
      const double legH = 10;
      final legPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawLine(flb, Offset(flb.dx, flb.dy + legH), legPaint);
      canvas.drawLine(frb, Offset(frb.dx, frb.dy + legH), legPaint);
      canvas.drawLine(blb, Offset(blb.dx, blb.dy + legH), legPaint);
    }
  }

  @override
  bool shouldRepaint(covariant IsometricUnitPainter oldDelegate) => true;
}