import 'dart:math' as math;

/// قطعة فردية جاهزة للرص على اللوح
class CutPiece {
  final String id;
  final String partName;
  final String material;
  final double length; // الطول (سم) - يتماشى مع اتجاه الثمرة لو hasGrain = true
  final double width; // العرض (سم)
  final bool hasGrain;
  final bool edgeL1;
  final bool edgeL2;
  final bool edgeW1;
  final bool edgeW2;

  // تُملأ بعد الرص على اللوح
  double x = 0;
  double y = 0;
  double placedLength = 0;
  double placedWidth = 0;
  bool rotated = false;

  CutPiece({
    required this.id,
    required this.partName,
    required this.material,
    required this.length,
    required this.width,
    this.hasGrain = true,
    this.edgeL1 = false,
    this.edgeL2 = false,
    this.edgeW1 = false,
    this.edgeW2 = false,
  });

  double get area => length * width;

  /// إجمالي أمتار القشاط لهذه القطعة (بالأمتار)
  double get edgeMeters {
    double cm = 0;
    if (edgeL1) cm += placedLength;
    if (edgeL2) cm += placedLength;
    if (edgeW1) cm += placedWidth;
    if (edgeW2) cm += placedWidth;
    return cm / 100.0;
  }
}

/// مستطيل حر متاح للرص داخل اللوح (MaxRects)
class FreeRect {
  final double x;
  final double y;
  final double width;
  final double height;

  const FreeRect(this.x, this.y, this.width, this.height);

  double get area => width * height;
}

/// لوح واحد بعد عملية التقطيع والرص
class NestingSheet {
  final int sheetNumber;
  final String material;
  final double sheetLength; // مثلاً 244 سم
  final double sheetWidth; // مثلاً 122 سم
  final List<CutPiece> placedPieces;

  NestingSheet({
    required this.sheetNumber,
    required this.material,
    required this.sheetLength,
    required this.sheetWidth,
    required this.placedPieces,
  });

  double get totalArea => sheetLength * sheetWidth;

  double get usedArea =>
      placedPieces.fold(0.0, (sum, p) => sum + (p.placedLength * p.placedWidth));

  double get wasteArea => math.max(0.0, totalArea - usedArea);

  double get utilizationPercent =>
      totalArea > 0 ? (usedArea / totalArea) * 100.0 : 0.0;

  double get wastePercent => math.max(0.0, 100.0 - utilizationPercent);

  double get totalEdgeMeters =>
      placedPieces.fold(0.0, (sum, p) => sum + p.edgeMeters);
}

/// نتيجة التقطيع الكاملة لمجموعة من القطع (مقسمة حسب الخامة)
class NestingResult {
  final Map<String, List<NestingSheet>> sheetsByMaterial;
  final List<CutPiece> oversizedPieces; // قطع أكبر من مقاس اللوح بالكامل

  NestingResult({
    required this.sheetsByMaterial,
    required this.oversizedPieces,
  });

  int get totalSheetsCount => sheetsByMaterial.values
      .fold(0, (sum, sheets) => sum + sheets.length);

  double get totalEdgeMeters => sheetsByMaterial.values.fold(
        0.0,
        (sum, sheets) =>
            sum + sheets.fold(0.0, (s, sh) => s + sh.totalEdgeMeters),
      );

  double get overallWastePercent {
    double totalBoardArea = 0;
    double totalUsedArea = 0;
    for (final sheets in sheetsByMaterial.values) {
      for (final sh in sheets) {
        totalBoardArea += sh.totalArea;
        totalUsedArea += sh.usedArea;
      }
    }
    if (totalBoardArea <= 0) return 0;
    return math.max(0.0, ((totalBoardArea - totalUsedArea) / totalBoardArea) * 100.0);
  }
}

/// محرك التقطيع الذكي (MaxRects Best-Short-Fit + Kerf)
class NestingEngine {
  final double sheetLength; // سم (الافتراضي 244)
  final double sheetWidth; // سم (الافتراضي 122)
  final double kerf; // سمك سلاح المنشار بالسم (الافتراضي 0.4 سم = 4 مم)
  final bool ignoreGrainRotation; // السماح بتدوير القطع حتى لو hasGrain = true

  const NestingEngine({
    this.sheetLength = 244.0,
    this.sheetWidth = 122.0,
    this.kerf = 0.4,
    this.ignoreGrainRotation = false,
  });

  /// تحويل مخرجات generateCutList إلى قائمة CutPiece مفردة حسب العدد (count)
  static List<CutPiece> expandCutList(List<Map<String, dynamic>> rawCutList) {
    final List<CutPiece> expanded = [];
    int counter = 1;

    for (final item in rawCutList) {
      final int count = (item['count'] as int?) ?? 1;
      final double w = ((item['width'] as num?) ?? 0).toDouble();
      final double h = ((item['height'] as num?) ?? 0).toDouble();
      // نجعل الطول هو البعد الأكبر عادةً مع الحفاظ على اتجاه الثمرة
      final double len = math.max(w, h);
      final double wid = math.min(w, h);

      for (int i = 0; i < count; i++) {
        expanded.add(
          CutPiece(
            id: 'P-${counter++}',
            partName: (item['partName'] as String?) ?? 'قطعة',
            material: (item['material'] as String?) ?? 'عام',
            length: len,
            width: wid,
            hasGrain: (item['hasGrain'] as bool?) ?? true,
            edgeL1: (item['edgeL1'] as bool?) ?? false,
            edgeL2: (item['edgeL2'] as bool?) ?? false,
            edgeW1: (item['edgeW1'] as bool?) ?? false,
            edgeW2: (item['edgeW2'] as bool?) ?? false,
          ),
        );
      }
    }
    return expanded;
  }

  NestingResult optimize(List<CutPiece> pieces) {
    final Map<String, List<CutPiece>> grouped = {};
    final List<CutPiece> oversized = [];

    for (final p in pieces) {
      final bool fitsNormal = p.length <= sheetLength && p.width <= sheetWidth;
      final bool canRotate = ignoreGrainRotation || !p.hasGrain;
      final bool fitsRotated =
          canRotate && (p.width <= sheetLength && p.length <= sheetWidth);

      if (!fitsNormal && !fitsRotated) {
        oversized.add(p);
        continue;
      }
      grouped.putIfAbsent(p.material, () => []).add(p);
    }

    final Map<String, List<NestingSheet>> resultSheets = {};

    grouped.forEach((material, matPieces) {
      // ترتيب القطع تنازلياً حسب المساحة ثم الطول الأكبر لتقليل الهالك
      final sorted = List<CutPiece>.from(matPieces)
        ..sort((a, b) {
          final areaCmp = b.area.compareTo(a.area);
          if (areaCmp != 0) return areaCmp;
          return math.max(b.length, b.width).compareTo(math.max(a.length, a.width));
        });

      final List<_ActiveBin> bins = [];

      for (final piece in sorted) {
        bool placed = false;

        for (final bin in bins) {
          if (bin.tryPlace(piece, kerf, ignoreGrainRotation)) {
            placed = true;
            break;
          }
        }

        if (!placed) {
          final newBin = _ActiveBin(
            sheetNumber: bins.length + 1,
            material: material,
            length: sheetLength,
            width: sheetWidth,
          );
          if (newBin.tryPlace(piece, kerf, ignoreGrainRotation)) {
            bins.add(newBin);
          } else {
            oversized.add(piece);
          }
        }
      }

      resultSheets[material] = bins.map((b) => b.toSheet()).toList();
    });

    return NestingResult(
      sheetsByMaterial: resultSheets,
      oversizedPieces: oversized,
    );
  }
}

class _ActiveBin {
  final int sheetNumber;
  final String material;
  final double length;
  final double width;
  final List<CutPiece> placed = [];
  final List<FreeRect> freeRects;

  _ActiveBin({
    required this.sheetNumber,
    required this.material,
    required this.length,
    required this.width,
  }) : freeRects = [FreeRect(0, 0, length, width)];

  bool tryPlace(CutPiece piece, double kerf, bool ignoreGrainRotation) {
    _PlacementCandidate? best;

    for (final rect in freeRects) {
      // 1. الوضع الأصلي (بدون تدوير)
      final double reqL0 = piece.length + kerf;
      final double reqW0 = piece.width + kerf;
      if (piece.length <= rect.width &&
          piece.width <= rect.height &&
          reqL0 <= rect.width + 1e-6 &&
          reqW0 <= rect.height + 1e-6) {
        final double leftoverW = (rect.width - piece.length).abs();
        final double leftoverH = (rect.height - piece.width).abs();
        final double shortSide = math.min(leftoverW, leftoverH);
        if (best == null || shortSide < best.score) {
          best = _PlacementCandidate(
            rect: rect,
            x: rect.x,
            y: rect.y,
            w: piece.length,
            h: piece.width,
            rotated: false,
            score: shortSide,
          );
        }
      }

      // 2. الوضع المدور (90 درجة) إذا مسموح
      final bool canRotate = ignoreGrainRotation || !piece.hasGrain;
      if (canRotate) {
        final double reqL1 = piece.width + kerf;
        final double reqW1 = piece.length + kerf;
        if (piece.width <= rect.width &&
            piece.length <= rect.height &&
            reqL1 <= rect.width + 1e-6 &&
            reqW1 <= rect.height + 1e-6) {
          final double leftoverW = (rect.width - piece.width).abs();
          final double leftoverH = (rect.height - piece.length).abs();
          final double shortSide = math.min(leftoverW, leftoverH);
          if (best == null || shortSide < best.score) {
            best = _PlacementCandidate(
              rect: rect,
              x: rect.x,
              y: rect.y,
              w: piece.width,
              h: piece.length,
              rotated: true,
              score: shortSide,
            );
          }
        }
      }
    }

    if (best == null) return false;

    piece.x = best.x;
    piece.y = best.y;
    piece.placedLength = best.w;
    piece.placedWidth = best.h;
    piece.rotated = best.rotated;
    placed.add(piece);

    // تقسيم المستطيلات الحرة المتقاطعة مع القطعة المضافة (مع مراعاة Kerf)
    final double occupiedW = math.min(freeRects.firstWhere((r) => identical(r, best!.rect)).width, best.w + kerf);
    final double occupiedH = math.min(best.rect.height, best.h + kerf);

    final List<FreeRect> nextFree = [];
    for (final r in freeRects) {
      if (!_intersects(r.x, r.y, r.width, r.height, best.x, best.y, occupiedW, occupiedH)) {
        nextFree.add(r);
      } else {
        // يمين القطعة
        final double rightX = best.x + occupiedW;
        if (rightX < r.x + r.width - 1e-6) {
          nextFree.add(FreeRect(rightX, r.y, (r.x + r.width) - rightX, r.height));
        }
        // أسفل القطعة
        final double bottomY = best.y + occupiedH;
        if (bottomY < r.y + r.height - 1e-6) {
          nextFree.add(FreeRect(r.x, bottomY, r.width, (r.y + r.height) - bottomY));
        }
      }
    }

    // إزالة المستطيلات المحتواة بالكامل داخل مستطيل آخر
    nextFree.removeWhere((a) => nextFree.any((b) =>
        !identical(a, b) &&
        a.x >= b.x - 1e-6 &&
        a.y >= b.y - 1e-6 &&
        a.x + a.width <= b.x + b.width + 1e-6 &&
        a.y + a.height <= b.y + b.height + 1e-6));

    freeRects
      ..clear()
      ..addAll(nextFree);

    return true;
  }

  bool _intersects(
    double ax, double ay, double aw, double ah,
    double bx, double by, double bw, double bh,
  ) {
    return ax < bx + bw - 1e-6 &&
        ax + aw > bx + 1e-6 &&
        ay < by + bh - 1e-6 &&
        ay + ah > by + 1e-6;
  }

  NestingSheet toSheet() {
    return NestingSheet(
      sheetNumber: sheetNumber,
      material: material,
      sheetLength: length,
      sheetWidth: width,
      placedPieces: List<CutPiece>.from(placed),
    );
  }
}

class _PlacementCandidate {
  final FreeRect rect;
  final double x;
  final double y;
  final double w;
  final double h;
  final bool rotated;
  final double score;

  _PlacementCandidate({
    required this.rect,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.rotated,
    required this.score,
  });
}