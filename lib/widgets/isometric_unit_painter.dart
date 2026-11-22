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
        unit.preset.id != 'kw_tall';

    final double legH = isWallHanging ? 0.0 : (size.height * 0.05).clamp(6.0, 12.0);
    final double bodyBottomY = size.height * 0.78 - legH;
    final double bodyTopY = bodyBottomY - bh;

    final Paint linePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final Paint handlePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint fillFront = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    final Paint fillSide = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final Paint fillTop = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;

    final Paint glassFill = Paint()
      ..color = const Color(0xFF7DD3FC).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final Paint glassBorder = Paint()
      ..color = const Color(0xFF0284C7)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final Paint glassShine = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

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

    // السطح العلوي
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

    final double innerX = startX + 3;
    final double innerW = math.max(10.0, bw - 6);
    double curY = bodyTopY + 3;
    double availH = math.max(10.0, bh - 6);

    // مطبقية / صفاية
    if (unit.preset.kind == UnitTemplateKind.dishRack) {
      final Rect rackBox = Rect.fromLTWH(innerX, curY, innerW, availH);
      canvas.drawRect(rackBox, glassFill);
      canvas.drawRect(rackBox, linePaint);
      final int slots = math.max(3, math.min(8, unit.shelvesCount + 3));
      final double step = availH / (slots + 1);
      for (int i = 1; i <= slots; i++) {
        final double ry = curY + i * step;
        canvas.drawLine(Offset(innerX + 3, ry), Offset(innerX + innerW - 3, ry), linePaint);
      }
      return;
    }

    // أدراج مختلطة (درجين كبار + درج صغير أو درج كبير + درجين صغيرين)
    if (unit.preset.kind == UnitTemplateKind.drawersMixedSmallTop ||
        unit.preset.kind == UnitTemplateKind.drawersMixedLargeTop) {
      final bool smallOnTop = unit.preset.kind == UnitTemplateKind.drawersMixedSmallTop;
      final double smallH = math.max(8.0, availH * 0.20);
      final double bigH = math.max(10.0, (availH - smallH) / 2.0);

      final List<double> heights = smallOnTop
          ? [smallH, bigH, bigH]
          : [bigH, smallH, smallH];

      double y = curY;
      for (int i = 0; i < heights.length; i++) {
        final Rect dr = Rect.fromLTWH(innerX, y, innerW, math.max(5.0, heights[i] - 1.5));
        canvas.drawRect(dr, linePaint);
        if (unit.handleType == HandleType.external) {
          final double hx = dr.left + dr.width * 0.5;
          final double hy = dr.top + dr.height * 0.5;
          canvas.drawLine(Offset(hx - 6, hy), Offset(hx + 6, hy), handlePaint);
        }
        y += heights[i];
      }
      return;
    }

    // وحدات الأدراج القياسية
    if (unit.drawersCount > 0 && unit.doorsCount == 0) {
      final int drwN = math.max(1, unit.drawersCount);
      final double dH = availH / drwN;
      for (int i = 0; i < drwN; i++) {
        final Rect dr = Rect.fromLTWH(innerX, curY + i * dH, innerW, math.max(5.0, dH - 1.5));
        canvas.drawRect(dr, linePaint);
        if (unit.handleType == HandleType.external) {
          final double hx = dr.left + dr.width * 0.5;
          final double hy = dr.top + dr.height * 0.5;
          canvas.drawLine(Offset(hx - 6, hy), Offset(hx + 6, hy), handlePaint);
        }
      }
      return;
    }

    // درج علوي مع ضلف
    if (unit.drawersCount > 0) {
      final double drwZoneH = availH * 0.24;
      final Rect drwRect = Rect.fromLTWH(innerX, curY, innerW, drwZoneH - 1.5);
      canvas.drawRect(drwRect, linePaint);
      if (unit.handleType == HandleType.external) {
        final double hx = drwRect.left + drwRect.width * 0.5;
        final double hy = drwRect.top + drwRect.height * 0.5;
        canvas.drawLine(Offset(hx - 6, hy), Offset(hx + 6, hy), handlePaint);
      }
      curY += drwZoneH;
      availH -= drwZoneH;
    }

    // الضلف (عادية أو زجاج شفاف + مقابض خارجية)
    if (unit.doorsCount > 0) {
      final int dCount = math.max(1, unit.doorsCount);
      final double singleDoorW = innerW / dCount;
      for (int i = 0; i < dCount; i++) {
        final Rect dRect = Rect.fromLTWH(
          innerX + i * singleDoorW + 1,
          curY,
          math.max(4.0, singleDoorW - 2),
          math.max(6.0, availH),
        );
        if (unit.glassDoors) {
          canvas.drawRect(dRect, glassFill);
          canvas.drawRect(dRect, glassBorder);
          // خط انعكاس زجاجي
          canvas.drawLine(
            Offset(dRect.left + 4, dRect.bottom - 4),
            Offset(dRect.right - 4, dRect.top + 4),
            glassShine,
          );
          // رف داخلي يظهر من خلف الزجاج
          if (unit.shelvesCount > 0) {
            final double sy = dRect.top + dRect.height * 0.5;
            canvas.drawLine(Offset(dRect.left + 2, sy), Offset(dRect.right - 2, sy), linePaint);
          }
        } else {
          canvas.drawRect(dRect, linePaint);
        }

        if (unit.handleType == HandleType.external) {
          final bool isLeftDoor = i < dCount / 2;
          final double hx = isLeftDoor ? dRect.right - 4 : dRect.left + 4;
          final double hy = dRect.top + dRect.height * 0.45;
          canvas.drawLine(Offset(hx, hy - 7), Offset(hx, hy + 7), handlePaint);
        }
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
        oldDelegate.unit.glassDoors != unit.glassDoors ||
        oldDelegate.unit.handleType != unit.handleType ||
        oldDelegate.unit.preset.id != unit.preset.id;
  }
}