import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/unit_model.dart';

class IsometricUnitPainter extends CustomPainter {
  final ConfiguredUnit unit;

  IsometricUnitPainter({required this.unit});

  static const double _cos30 = 0.8660254;
  static const double _sin30 = 0.5;

  Offset _isoOffset(double depthCm, double scale) {
    final double dPx = (depthCm * scale * 0.62).clamp(16.0, 62.0);
    return Offset(dPx * _cos30, -dPx * _sin30);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double wVal = math.max(25.0, unit.width);
    final double w2Val = math.max(25.0, unit.width2);
    final double hVal = math.max(25.0, unit.height);
    final double dVal = math.max(20.0, unit.depth);
    final double d2Val = math.max(20.0, unit.depth2);

    final double maxDim = math.max(wVal, math.max(w2Val, math.max(hVal, math.max(dVal, d2Val))));
    final double scale = (math.min(size.width, size.height) * 0.40) / math.max(35.0, maxDim);

    final double bw = (wVal * scale).clamp(44.0, size.width * 0.45);
    final double bh = (hVal * scale).clamp(36.0, size.height * 0.50);
    final Offset isoD1 = _isoOffset(dVal, scale);
    final Offset isoD2 = _isoOffset(d2Val, scale);

    final double totalVisualW = bw + isoD1.dx.abs();
    final double startX = (size.width - totalVisualW) * 0.44;

    final bool isWallHanging = unit.preset.category == MainCategory.kitchenWall &&
        unit.preset.kind != UnitTemplateKind.applianceTower &&
        unit.preset.id != 'kw_tall';

    final double legH = isWallHanging || unit.preset.isOpenDesk
        ? 0.0
        : (size.height * 0.05).clamp(6.0, 12.0);

    final double bodyBottomY = size.height * 0.78 - legH;
    final double bodyTopY = bodyBottomY - bh;

    final Paint linePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final Paint accentPaint = Paint()
      ..color = const Color(0xFF0F766E)
      ..strokeWidth = 1.35
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

    final Paint cavityFill = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.24)
      ..style = PaintingStyle.fill;

    // أرجل الوحدات الأرضية غير المعلقة
    if (!isWallHanging && !unit.preset.isOpenDesk) {
      final List<Offset> footBases = [
        Offset(startX + 4, bodyBottomY),
        Offset(startX + bw - 4, bodyBottomY),
        Offset(startX + bw - 4 + isoD1.dx, bodyBottomY + isoD1.dy),
      ];
      for (final p in footBases) {
        canvas.drawLine(p, Offset(p.dx, p.dy + legH), linePaint);
      }
    }

    // 1. الركنة حرف L بأيزومترك هندسي نظيف ومتناسق
    if (unit.preset.kind == UnitTemplateKind.cornerL || unit.preset.isCornerL) {
      final double arm2W = (bw * 0.42).clamp(18.0, bw * 0.52);
      final double backDepthScale = (d2Val / math.max(20.0, dVal)).clamp(0.75, 1.3);
      final Offset backVec = Offset(isoD2.dx * backDepthScale, isoD2.dy * backDepthScale);

      // النقاط العلوية للركنة L
      final Offset pFrontLeft = Offset(startX, bodyTopY);
      final Offset pFrontRight = Offset(startX + bw, bodyTopY);
      final Offset pRightBack = pFrontRight + isoD1;
      final Offset pInnerCorner = Offset(startX + bw - arm2W, bodyTopY) + isoD1;
      final Offset pBackArmOuter = pInnerCorner + backVec;
      final Offset pBackArmLeft = Offset(startX, bodyTopY) + backVec;

      final Path lTop = Path()
        ..moveTo(pFrontLeft.dx, pFrontLeft.dy)
        ..lineTo(pFrontRight.dx, pFrontRight.dy)
        ..lineTo(pRightBack.dx, pRightBack.dy)
        ..lineTo(pInnerCorner.dx, pInnerCorner.dy)
        ..lineTo(pBackArmOuter.dx, pBackArmOuter.dy)
        ..lineTo(pBackArmLeft.dx, pBackArmLeft.dy)
        ..close();

      canvas.drawPath(lTop, fillTop);
      canvas.drawPath(lTop, linePaint);

      // الجنب الأيسر للذراع الخلفي
      final Path leftSide = Path()
        ..moveTo(pFrontLeft.dx, pFrontLeft.dy)
        ..lineTo(pBackArmLeft.dx, pBackArmLeft.dy)
        ..lineTo(pBackArmLeft.dx, pBackArmLeft.dy + bh)
        ..lineTo(pFrontLeft.dx, pFrontLeft.dy + bh)
        ..close();
      canvas.drawPath(leftSide, fillSide);
      canvas.drawPath(leftSide, linePaint);

      // الجنب الداخلي للذراع الخلفي
      final Path innerArmSide = Path()
        ..moveTo(pInnerCorner.dx, pInnerCorner.dy)
        ..lineTo(pBackArmOuter.dx, pBackArmOuter.dy)
        ..lineTo(pBackArmOuter.dx, pBackArmOuter.dy + bh)
        ..lineTo(pInnerCorner.dx, pInnerCorner.dy + bh)
        ..close();
      canvas.drawPath(innerArmSide, fillSide);
      canvas.drawPath(innerArmSide, linePaint);

      // الواجهة الأمامية
      final Rect frontRect = Rect.fromLTWH(startX, bodyTopY, bw, bh);
      canvas.drawRect(frontRect, fillFront);
      canvas.drawRect(frontRect, linePaint);

      // الجنب الأيمن للذراع الأمامي
      final Path rightSide = Path()
        ..moveTo(pFrontRight.dx, pFrontRight.dy)
        ..lineTo(pRightBack.dx, pRightBack.dy)
        ..lineTo(pRightBack.dx, pRightBack.dy + bh)
        ..lineTo(pFrontRight.dx, pFrontRight.dy + bh)
        ..close();
      canvas.drawPath(rightSide, fillSide);
      canvas.drawPath(rightSide, linePaint);

      // خط فاصل عمودي عند بداية الذراع الثاني
      final double splitX = startX + bw - arm2W;
      canvas.drawLine(Offset(splitX, bodyTopY), Offset(splitX, bodyBottomY), accentPaint);

      if (unit.preset.category == MainCategory.dressing) {
        final int shN = math.max(2, math.min(6, unit.shelvesCount));
        for (int i = 1; i <= shN; i++) {
          final double sy = bodyTopY + (bh / (shN + 1)) * i;
          canvas.drawLine(Offset(splitX + 2, sy), Offset(startX + bw - 2, sy), accentPaint);
        }
        final double rodY = bodyTopY + bh * 0.25;
        canvas.drawLine(Offset(startX + 5, rodY), Offset(splitX - 5, rodY), accentPaint);
      } else if (unit.doorsCount > 0) {
        final int dCount = math.max(1, unit.doorsCount);
        final double doorAreaW = (splitX - startX) / dCount;
        for (int i = 0; i < dCount; i++) {
          canvas.drawRect(
            Rect.fromLTWH(
              startX + i * doorAreaW + 2,
              bodyTopY + 3,
              math.max(4.0, doorAreaW - 4),
              math.max(6.0, bh - 6),
            ),
            linePaint,
          );
        }
      }
      return;
    }

    // 2. المكتب المفتوح والترابيزة الجانبية بعمق أيزومترك موحد بدون فجوات
    if (unit.preset.isOpenDesk) {
      final double topThick = math.max(5.0, (unit.boardThickness * scale * 1.4).clamp(5.0, 11.0));
      final double deskTopY = bodyTopY + bh * 0.16;
      final double legHeight = math.max(18.0, bodyBottomY - (deskTopY + topThick));

      // سطح المكتب العلوي
      final Path topSlab = Path()
        ..moveTo(startX, deskTopY)
        ..lineTo(startX + bw, deskTopY)
        ..lineTo(startX + bw + isoD1.dx, deskTopY + isoD1.dy)
        ..lineTo(startX + isoD1.dx, deskTopY + isoD1.dy)
        ..close();
      canvas.drawPath(topSlab, fillTop);
      canvas.drawPath(topSlab, linePaint);

      // سُمك السطح من الجنب الأيمن
      final Path slabRightEdge = Path()
        ..moveTo(startX + bw, deskTopY)
        ..lineTo(startX + bw + isoD1.dx, deskTopY + isoD1.dy)
        ..lineTo(startX + bw + isoD1.dx, deskTopY + isoD1.dy + topThick)
        ..lineTo(startX + bw, deskTopY + topThick)
        ..close();
      canvas.drawPath(slabRightEdge, fillSide);
      canvas.drawPath(slabRightEdge, linePaint);

      // واجهة السطح الأمامية
      final Rect slabFront = Rect.fromLTWH(startX, deskTopY, bw, topThick);
      canvas.drawRect(slabFront, fillFront);
      canvas.drawRect(slabFront, linePaint);

      // الجنب الأيسر بنفس العمق الأيزومترك isoD1
      final double legW = math.max(5.0, (unit.boardThickness * scale * 1.4).clamp(5.0, 11.0));
      final double legBottomY = deskTopY + topThick + legHeight;

      final Path leftLegSide = Path()
        ..moveTo(startX + 2, deskTopY + topThick)
        ..lineTo(startX + 2 + isoD1.dx, deskTopY + topThick + isoD1.dy)
        ..lineTo(startX + 2 + isoD1.dx, legBottomY + isoD1.dy)
        ..lineTo(startX + 2, legBottomY)
        ..close();
      canvas.drawPath(leftLegSide, fillSide);
      canvas.drawPath(leftLegSide, linePaint);

      final Rect leftLegFront = Rect.fromLTWH(startX + 2, deskTopY + topThick, legW, legHeight);
      canvas.drawRect(leftLegFront, fillFront);
      canvas.drawRect(leftLegFront, linePaint);

      if (unit.drawersCount > 0) {
        final double pedW = (bw * 0.34).clamp(24.0, bw * 0.44);
        final double pedX = startX + bw - pedW - 2;
        final double pedY = deskTopY + topThick;

        final Path pedSide = Path()
          ..moveTo(pedX + pedW, pedY)
          ..lineTo(pedX + pedW + isoD1.dx, pedY + isoD1.dy)
          ..lineTo(pedX + pedW + isoD1.dx, pedY + legHeight + isoD1.dy)
          ..lineTo(pedX + pedW, pedY + legHeight)
          ..close();
        canvas.drawPath(pedSide, fillSide);
        canvas.drawPath(pedSide, linePaint);

        final Rect pedFront = Rect.fromLTWH(pedX, pedY, pedW, legHeight);
        canvas.drawRect(pedFront, fillFront);
        canvas.drawRect(pedFront, linePaint);

        final int drwN = math.max(1, unit.drawersCount);
        final double eachH = (legHeight - 4) / drwN;
        for (int i = 0; i < drwN; i++) {
          canvas.drawRect(
            Rect.fromLTWH(pedX + 2, pedY + 2 + i * eachH, pedW - 4, math.max(4.0, eachH - 2)),
            accentPaint,
          );
        }
      } else {
        final double rightLegX = startX + bw - legW - 2;
        final Path rightLegSide = Path()
          ..moveTo(rightLegX + legW, deskTopY + topThick)
          ..lineTo(rightLegX + legW + isoD1.dx, deskTopY + topThick + isoD1.dy)
          ..lineTo(rightLegX + legW + isoD1.dx, legBottomY + isoD1.dy)
          ..lineTo(rightLegX + legW, legBottomY)
          ..close();
        canvas.drawPath(rightLegSide, fillSide);
        canvas.drawPath(rightLegSide, linePaint);

        final Rect rightLegFront = Rect.fromLTWH(rightLegX, deskTopY + topThick, legW, legHeight);
        canvas.drawRect(rightLegFront, fillFront);
        canvas.drawRect(rightLegFront, linePaint);
      }
      return;
    }

    // الكتلة الأيزومترية للوحدات القياسية / العلوية / الأجهزة / الأدراج / الدريسنج
    final Path topFace = Path()
      ..moveTo(startX, bodyTopY)
      ..lineTo(startX + bw, bodyTopY)
      ..lineTo(startX + bw + isoD1.dx, bodyTopY + isoD1.dy)
      ..lineTo(startX + isoD1.dx, bodyTopY + isoD1.dy)
      ..close();
    canvas.drawPath(topFace, fillTop);
    canvas.drawPath(topFace, linePaint);

    final Path sideFace = Path()
      ..moveTo(startX + bw, bodyTopY)
      ..lineTo(startX + bw + isoD1.dx, bodyTopY + isoD1.dy)
      ..lineTo(startX + bw + isoD1.dx, bodyBottomY + isoD1.dy)
      ..lineTo(startX + bw, bodyBottomY)
      ..close();
    canvas.drawPath(sideFace, fillSide);
    canvas.drawPath(sideFace, linePaint);

    final Rect frontBox = Rect.fromLTWH(startX, bodyTopY, bw, bh);
    canvas.drawRect(frontBox, fillFront);
    canvas.drawRect(frontBox, linePaint);

    // 3. الدريسنج المفتوح
    if (unit.preset.category == MainCategory.dressing) {
      final double frameT = math.max(3.5, (unit.boardThickness * scale * 1.2).clamp(3.5, 7.5));
      final Rect innerCavity = Rect.fromLTWH(
        startX + frameT,
        bodyTopY + frameT,
        math.max(10.0, bw - frameT * 2),
        math.max(10.0, bh - frameT * 2),
      );
      canvas.drawRect(innerCavity, cavityFill);
      canvas.drawRect(innerCavity, linePaint);

      if (unit.preset.id == 'dr_hanger') {
        final double rodY = innerCavity.top + innerCavity.height * 0.22;
        canvas.drawLine(Offset(innerCavity.left + 4, rodY), Offset(innerCavity.right - 4, rodY), accentPaint);
      } else {
        final int shN = math.max(2, math.min(7, unit.shelvesCount));
        for (int i = 1; i <= shN; i++) {
          final double sy = innerCavity.top + (innerCavity.height / (shN + 1)) * i;
          canvas.drawLine(Offset(innerCavity.left + 2, sy), Offset(innerCavity.right - 2, sy), accentPaint);
        }
      }

      if (unit.drawersCount > 0) {
        final int dN = math.max(1, unit.drawersCount);
        final double zoneH = innerCavity.height * 0.28;
        final double dH = zoneH / dN;
        for (int i = 0; i < dN; i++) {
          final Rect dr = Rect.fromLTWH(
            innerCavity.left + 2,
            innerCavity.bottom - zoneH + i * dH,
            math.max(6.0, innerCavity.width - 4),
            math.max(4.0, dH - 1.5),
          );
          canvas.drawRect(dr, fillFront);
          canvas.drawRect(dr, linePaint);
        }
      }
      return;
    }

    // 4. وحدة الأجهزة
    if (unit.preset.kind == UnitTemplateKind.applianceTower) {
      final double totalH = math.max(1.0, unit.height);
      double curY = bodyTopY + 3;
      final double innerLeft = startX + 3;
      final double innerWidth = math.max(10.0, bw - 6);

      if (unit.microwaveHeightCm > 0) {
        final double mh = ((unit.microwaveHeightCm / totalH) * (bh - 6)).clamp(10.0, bh * 0.35);
        final Rect mwRect = Rect.fromLTWH(innerLeft, curY, innerWidth, mh);
        canvas.drawRect(mwRect, cavityFill);
        canvas.drawRect(mwRect, accentPaint);
        curY += mh + 2;
      }

      if (unit.ovenHeightCm > 0) {
        final double oh = ((unit.ovenHeightCm / totalH) * (bh - 6)).clamp(12.0, bh * 0.45);
        final Rect ovRect = Rect.fromLTWH(innerLeft, curY, innerWidth, oh);
        canvas.drawRect(ovRect, cavityFill);
        canvas.drawRect(ovRect, linePaint);
        canvas.drawRect(
          Rect.fromLTWH(
            innerLeft + 3,
            curY + oh * 0.3,
            math.max(6.0, innerWidth - 6),
            math.max(5.0, oh * 0.55),
          ),
          accentPaint,
        );
        curY += oh + 2;
      }

      if (unit.hoodHeightCm > 0) {
        final double hh = ((unit.hoodHeightCm / totalH) * (bh - 6)).clamp(10.0, bh * 0.35);
        final Rect hdRect = Rect.fromLTWH(innerLeft, curY, innerWidth, hh);
        canvas.drawRect(hdRect, cavityFill);
        canvas.drawRect(hdRect, accentPaint);
        curY += hh + 2;
      }

      final double remH = (bodyTopY + bh - 3) - curY;
      if (remH > 6.0) {
        canvas.drawRect(Rect.fromLTWH(innerLeft, curY, innerWidth, remH), linePaint);
      }
      return;
    }

    // 5. الصفاية / المطبقية
    if (unit.preset.kind == UnitTemplateKind.dishRack) {
      final Rect innerRack = Rect.fromLTWH(startX + 4, bodyTopY + 4, math.max(8.0, bw - 8), math.max(8.0, bh - 8));
      canvas.drawRect(innerRack, cavityFill);
      canvas.drawRect(innerRack, accentPaint);

      final int slots = math.max(3, math.min(9, unit.shelvesCount + 4));
      final double step = innerRack.height / (slots + 1);
      for (int i = 1; i <= slots; i++) {
        final double ry = innerRack.top + i * step;
        canvas.drawLine(Offset(innerRack.left + 2, ry), Offset(innerRack.right - 2, ry), linePaint);
      }
      return;
    }

    // 6. وحدات الأدراج
    if (unit.preset.kind == UnitTemplateKind.drawersLower ||
        (unit.drawersCount > 0 && unit.doorsCount == 0)) {
      final int totalDrw = math.max(1, unit.drawersCount + unit.innerDrawersCount);
      final double totalH = math.max(1.0, unit.height);
      double curY = bodyTopY + 3;
      final double availH = math.max(12.0, bh - 6);
      final double innerX = startX + 3;
      final double innerW = math.max(10.0, bw - 6);

      if (unit.innerDrawersCount > 0 && unit.innerDrawerHeightCm > 0) {
        final double smallH = ((unit.innerDrawerHeightCm / totalH) * availH).clamp(7.0, availH * 0.45);
        for (int s = 0; s < unit.innerDrawersCount && curY < bodyTopY + bh - 5; s++) {
          final double hDraw = math.min(smallH, (bodyTopY + bh - 3) - curY);
          final Rect sr = Rect.fromLTWH(innerX, curY, innerW, math.max(5.0, hDraw - 1.5));
          canvas.drawRect(sr, cavityFill);
          canvas.drawRect(sr, accentPaint);
          curY += hDraw;
        }
      }

      final int bigCount = math.max(1, totalDrw - unit.innerDrawersCount);
      final double remAvail = math.max(8.0, (bodyTopY + bh - 3) - curY);
      final double bigH = remAvail / bigCount;
      for (int b = 0; b < bigCount; b++) {
        canvas.drawRect(
          Rect.fromLTWH(innerX, curY + b * bigH, innerW, math.max(6.0, bigH - 1.5)),
          linePaint,
        );
      }
      return;
    }

    // 7. الضلف والأدراج العلوية للوحدات القياسية والعلوية
    final double innerX = startX + 3;
    final double innerW = math.max(10.0, bw - 6);
    double doorTop = bodyTopY + 3;
    double doorAvailH = math.max(10.0, bh - 6);

    if (unit.drawersCount > 0) {
      final double drwZoneH = doorAvailH * 0.24;
      canvas.drawRect(Rect.fromLTWH(innerX, doorTop, innerW, drwZoneH - 1.5), linePaint);
      doorTop += drwZoneH;
      doorAvailH -= drwZoneH;
    }

    final int dCount = math.max(1, unit.doorsCount);
    final double singleDoorW = innerW / dCount;
    for (int i = 0; i < dCount; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          innerX + i * singleDoorW + 1,
          doorTop,
          math.max(4.0, singleDoorW - 2),
          math.max(6.0, doorAvailH),
        ),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant IsometricUnitPainter oldDelegate) {
    return oldDelegate.unit.width != unit.width ||
        oldDelegate.unit.width2 != unit.width2 ||
        oldDelegate.unit.height != unit.height ||
        oldDelegate.unit.depth != unit.depth ||
        oldDelegate.unit.depth2 != unit.depth2 ||
        oldDelegate.unit.shelvesCount != unit.shelvesCount ||
        oldDelegate.unit.doorsCount != unit.doorsCount ||
        oldDelegate.unit.drawersCount != unit.drawersCount ||
        oldDelegate.unit.drawerHeightCm != unit.drawerHeightCm ||
        oldDelegate.unit.innerDrawersCount != unit.innerDrawersCount ||
        oldDelegate.unit.innerDrawerHeightCm != unit.innerDrawerHeightCm ||
        oldDelegate.unit.lowerDoorHeightCm != unit.lowerDoorHeightCm ||
        oldDelegate.unit.ovenHeightCm != unit.ovenHeightCm ||
        oldDelegate.unit.microwaveHeightCm != unit.microwaveHeightCm ||
        oldDelegate.unit.hoodHeightCm != unit.hoodHeightCm ||
        oldDelegate.unit.boardThickness != unit.boardThickness ||
        oldDelegate.unit.preset.id != unit.preset.id;
  }
}