import 'dart:math' as math;

enum SplitType { none, vertical, horizontal }

enum ZoneContentType {
  empty, // فتحة فارغة (شماعة أو فراغ)
  shelves, // أرفف متساوية
  drawers, // أدراج
  doors, // ضلف
  openDeskSpace, // فراغ مكتب مفتوح من الأسفل (بدون قاعدة)
}

enum FreeBoardKind {
  panel, // لوح / قاطع / قرصة خارجية
  shelf, // رف حر أو معلق
  drawerFront, // وش درج حر
  door, // ضلفة حرة أو معلقة
}

/// قطعة مرسومة حراً بالإحداثيات (بالـ سم) مع الحفاظ على تخانة اللوح الثابتة
class FreeBoardPiece {
  String id;
  String name;
  FreeBoardKind kind;

  /// إحداثيات الزاوية العلوية اليسرى بالـ سم نسبة لصندوق الوحدة الكلي
  double x;
  double y;
  double width;
  double height;
  double thickness; // الافتراضي 1.8 سم

  bool hasGrain;
  bool edgeL1;
  bool edgeL2;
  bool edgeW1;
  bool edgeW2;

  FreeBoardPiece({
    required this.id,
    required this.name,
    this.kind = FreeBoardKind.panel,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.thickness = 1.8,
    this.hasGrain = true,
    this.edgeL1 = true,
    this.edgeL2 = false,
    this.edgeW1 = false,
    this.edgeW2 = false,
  });

  FreeBoardPiece copyWith({
    String? name,
    FreeBoardKind? kind,
    double? x,
    double? y,
    double? width,
    double? height,
    double? thickness,
    bool? hasGrain,
    bool? edgeL1,
    bool? edgeL2,
    bool? edgeW1,
    bool? edgeW2,
  }) {
    return FreeBoardPiece(
      id: id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      thickness: thickness ?? this.thickness,
      hasGrain: hasGrain ?? this.hasGrain,
      edgeL1: edgeL1 ?? this.edgeL1,
      edgeL2: edgeL2 ?? this.edgeL2,
      edgeW1: edgeW1 ?? this.edgeW1,
      edgeW2: edgeW2 ?? this.edgeW2,
    );
  }
}

class CabinetZoneNode {
  String id;
  SplitType splitType;
  double splitRatio; // من 0.12 إلى 0.88 (نسبة الجزء الأول: اليمين أو العلوي)
  CabinetZoneNode? firstChild; // يمين (في الرأسي) أو أعلى (في الأفقي)
  CabinetZoneNode? secondChild; // شمال (في الرأسي) أو أسفل (في الأفقي)

  // خصائص الفتحة لو مش مقسومة (Leaf)
  ZoneContentType contentType;
  int itemCount; // عدد الأرفف أو الأدراج أو الضلف

  CabinetZoneNode({
    required this.id,
    this.splitType = SplitType.none,
    this.splitRatio = 0.5,
    this.firstChild,
    this.secondChild,
    this.contentType = ZoneContentType.empty,
    this.itemCount = 0,
  });

  bool get isLeaf => splitType == SplitType.none;

  /// تقسيم الفتحة إلى فتحتين بقاطوع رأسي أو رف أفقي
  void split(SplitType type, {double ratio = 0.5}) {
    splitType = type;
    splitRatio = ratio.clamp(0.12, 0.88);
    firstChild = CabinetZoneNode(id: '${id}_1');
    secondChild = CabinetZoneNode(id: '${id}_2');
    contentType = ZoneContentType.empty;
    itemCount = 0;
  }

  /// دمج / حذف التقسيم والعودة لفتحة واحدة
  void unsplit() {
    splitType = SplitType.none;
    firstChild = null;
    secondChild = null;
    contentType = ZoneContentType.empty;
    itemCount = 0;
  }
}

class CustomCabinetDesign {
  String name;
  double width; // العرض الكلي (سم)
  double height; // الارتفاع الكلي (سم)
  double depth; // العمق الكلي (سم)
  double plinthHeight; // ارتفاع الوزرة / الرجول السفلية (سم)
  double boardThickness; // تخانة الخشب (سم) - الافتراضي 1.8
  bool hasBackPanel;
  String carcassMaterial;
  String shelfMaterial;
  String doorMaterial;
  String backMaterial;
  CabinetZoneNode root;
  final List<FreeBoardPiece> freeBoards;

  CustomCabinetDesign({
    this.name = "وحدة مخصصة",
    this.width = 120,
    this.height = 170,
    this.depth = 55,
    this.plinthHeight = 8,
    this.boardThickness = 1.8,
    this.hasBackPanel = true,
    this.carcassMaterial = "كونتر ساندوتش 18 مم",
    this.shelfMaterial = "كونتر ساندوتش 18 مم",
    this.doorMaterial = "HPL ضلف 18 مم",
    this.backMaterial = "أبلكاش مفحار (4 مم)",
    CabinetZoneNode? root,
    List<FreeBoardPiece>? freeBoards,
  })  : root = root ?? CabinetZoneNode(id: 'root'),
        freeBoards = freeBoards ?? [];

  /// قالب جاهز سريع: دولاب تقسيم داخلي مخصص (120×170)
  factory CustomCabinetDesign.wardrobePreset() {
    final root = CabinetZoneNode(id: 'root');
    root.split(SplitType.vertical, ratio: 0.5);
    root.firstChild!.split(SplitType.horizontal, ratio: 0.38);
    root.secondChild!.split(SplitType.horizontal, ratio: 0.24);
    root.secondChild!.secondChild!.split(SplitType.vertical, ratio: 0.5);
    root.secondChild!.secondChild!.firstChild!
      ..contentType = ZoneContentType.shelves
      ..itemCount = 4;
    root.secondChild!.secondChild!.secondChild!
      ..contentType = ZoneContentType.shelves
      ..itemCount = 4;

    return CustomCabinetDesign(
      name: "دولاب تقسيم داخلي مخصص",
      width: 120,
      height: 170,
      depth: 55,
      plinthHeight: 8,
      root: root,
    );
  }

  /// قالب جاهز سريع: مكتب مفتوح من تحت + وحدة أدراج جانبية
  factory CustomCabinetDesign.openDeskPreset() {
    final root = CabinetZoneNode(id: 'root');
    root.split(SplitType.vertical, ratio: 0.68);
    root.firstChild!.contentType = ZoneContentType.openDeskSpace;
    root.secondChild!
      ..contentType = ZoneContentType.drawers
      ..itemCount = 3;

    return CustomCabinetDesign(
      name: "مكتب مفتوح بوحدة أدراج",
      width: 140,
      height: 75,
      depth: 60,
      plinthHeight: 0,
      hasBackPanel: false,
      root: root,
    );
  }

  /// سنترة قطعة حرة أفقياً داخل نطاق محدد (الافتراضي عرض الوحدة الكلي)
  void centerFreeBoardHorizontally(
    FreeBoardPiece board, {
    double? spanStartX,
    double? spanWidth,
  }) {
    final double startX = spanStartX ?? 0.0;
    final double spanW = spanWidth ?? width;
    board.x = double.parse((startX + (spanW - board.width) / 2.0).toStringAsFixed(1));
  }

  /// سنترة قطعة حرة رأسياً داخل نطاق محدد (الافتراضي ارتفاع الوحدة الكلي)
  void centerFreeBoardVertically(
    FreeBoardPiece board, {
    double? spanStartY,
    double? spanHeight,
  }) {
    final double startY = spanStartY ?? 0.0;
    final double spanH = spanHeight ?? height;
    board.y = double.parse((startY + (spanH - board.height) / 2.0).toStringAsFixed(1));
  }

  /// توليد قائمة التقطيع الكاملة (Cut List) من الشجرة التفاعلية والقطع الحرة بدقة المللي
  List<Map<String, dynamic>> generateCutList(int unitNumber, {int quantity = 1}) {
    final List<Map<String, dynamic>> parts = [];
    final double t = boardThickness;
    final double bodyH = math.max(10.0, height - plinthHeight);
    final double innerW = math.max(5.0, width - (2 * t));
    final double innerH = math.max(5.0, bodyH - (2 * t));

    // 1. الأجناب الخارجية (يمين وشمال)
    parts.add({
      'partName': 'جنب خارجي (#$unitNumber - $name)',
      'material': carcassMaterial,
      'width': depth,
      'height': bodyH,
      'count': 2 * quantity,
      'hasGrain': true,
      'edgeL1': true,
      'edgeL2': false,
      'edgeW1': false,
      'edgeW2': false,
    });

    // 2. السقف الكلي
    parts.add({
      'partName': 'سقف / قرصة علوية (#$unitNumber)',
      'material': carcassMaterial,
      'width': depth,
      'height': innerW,
      'count': 1 * quantity,
      'hasGrain': true,
      'edgeL1': true,
      'edgeL2': false,
      'edgeW1': false,
      'edgeW2': false,
    });

    // 3. القاعدة السفلية (نحسبها حسب الفتحات المفتوحة من تحت زي المكتب)
    _collectBottomBases(
      root,
      innerW,
      parts,
      unitNumber: unitNumber,
      quantity: quantity,
    );

    // 4. الوزرة السفلية (لو موجودة)
    if (plinthHeight > 0) {
      parts.add({
        'partName': 'وزرة سفلية (#$unitNumber)',
        'material': carcassMaterial,
        'width': plinthHeight,
        'height': innerW,
        'count': 2 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });
    }

    // 5. توليد كل القواطيع والأرفف والأدراج والضلف من الشجرة بالترتيب
    _collectNodeParts(root, innerW, innerH, parts, unitNumber, quantity);

    // 6. الظهر
    if (hasBackPanel) {
      parts.add({
        'partName': 'ظهر أبلكاش مفحار (#$unitNumber)',
        'material': backMaterial,
        'width': double.parse((innerW + 1.4).toStringAsFixed(1)),
        'height': double.parse((innerH + 1.4).toStringAsFixed(1)),
        'count': 1 * quantity,
        'hasGrain': false,
        'edgeL1': false,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });
    }

    // 7. القطع المرسومة حراً (قرص خارجية / وحدات معلقة / أرفف وأدراج حرة)
    for (final fb in freeBoards) {
      String mat = carcassMaterial;
      if (fb.kind == FreeBoardKind.shelf) {
        mat = shelfMaterial;
      } else if (fb.kind == FreeBoardKind.door || fb.kind == FreeBoardKind.drawerFront) {
        mat = doorMaterial;
      }

      final double shortDim = math.min(fb.width, fb.height);
      final double longDim = math.max(fb.width, fb.height);

      parts.add({
        'partName': '${fb.name} (#$unitNumber)',
        'material': mat,
        'width': double.parse(shortDim.toStringAsFixed(1)),
        'height': double.parse(longDim.toStringAsFixed(1)),
        'count': 1 * quantity,
        'hasGrain': fb.hasGrain,
        'edgeL1': fb.edgeL1,
        'edgeL2': fb.edgeL2,
        'edgeW1': fb.edgeW1,
        'edgeW2': fb.edgeW2,
      });
    }

    return parts;
  }

  void _collectBottomBases(
    CabinetZoneNode node,
    double zoneW,
    List<Map<String, dynamic>> parts, {
    required int unitNumber,
    required int quantity,
  }) {
    final double t = boardThickness;
    if (node.isLeaf) {
      if (node.contentType != ZoneContentType.openDeskSpace && zoneW > 1.0) {
        parts.add({
          'partName': 'قاعدة سفلية (#$unitNumber)',
          'material': carcassMaterial,
          'width': depth,
          'height': double.parse(zoneW.toStringAsFixed(1)),
          'count': 1 * quantity,
          'hasGrain': true,
          'edgeL1': true,
          'edgeL2': false,
          'edgeW1': false,
          'edgeW2': false,
        });
      }
      return;
    }

    if (node.splitType == SplitType.vertical) {
      final double usableW = math.max(0.0, zoneW - t);
      final double w1 = usableW * node.splitRatio;
      final double w2 = usableW - w1;
      _collectBottomBases(node.firstChild!, w1, parts,
          unitNumber: unitNumber, quantity: quantity);
      _collectBottomBases(node.secondChild!, w2, parts,
          unitNumber: unitNumber, quantity: quantity);
    } else {
      _collectBottomBases(node.secondChild!, zoneW, parts,
          unitNumber: unitNumber, quantity: quantity);
    }
  }

  void _collectNodeParts(
    CabinetZoneNode node,
    double zoneW,
    double zoneH,
    List<Map<String, dynamic>> parts,
    int unitNumber,
    int quantity,
  ) {
    final double t = boardThickness;

    if (node.splitType == SplitType.vertical) {
      parts.add({
        'partName': 'قاطوع رأسي (#$unitNumber)',
        'material': carcassMaterial,
        'width': math.max(5.0, depth - 1.5),
        'height': double.parse(zoneH.toStringAsFixed(1)),
        'count': 1 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });

      final double usableW = math.max(0.0, zoneW - t);
      final double w1 = usableW * node.splitRatio;
      final double w2 = usableW - w1;
      _collectNodeParts(node.firstChild!, w1, zoneH, parts, unitNumber, quantity);
      _collectNodeParts(node.secondChild!, w2, zoneH, parts, unitNumber, quantity);
      return;
    }

    if (node.splitType == SplitType.horizontal) {
      parts.add({
        'partName': 'رف قاطع أفقي (#$unitNumber)',
        'material': shelfMaterial,
        'width': math.max(5.0, depth - 1.5),
        'height': double.parse(zoneW.toStringAsFixed(1)),
        'count': 1 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });

      final double usableH = math.max(0.0, zoneH - t);
      final double h1 = usableH * node.splitRatio;
      final double h2 = usableH - h1;
      _collectNodeParts(node.firstChild!, zoneW, h1, parts, unitNumber, quantity);
      _collectNodeParts(node.secondChild!, zoneW, h2, parts, unitNumber, quantity);
      return;
    }

    if (node.contentType == ZoneContentType.shelves && node.itemCount > 0) {
      parts.add({
        'partName': 'رف داخلي (#$unitNumber)',
        'material': shelfMaterial,
        'width': math.max(5.0, depth - 2.5),
        'height': double.parse((zoneW - 0.2).toStringAsFixed(1)),
        'count': node.itemCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });
    } else if (node.contentType == ZoneContentType.drawers && node.itemCount > 0) {
      final double frontH = math.max(8.0, (zoneH / node.itemCount) - 0.4);
      final double frontW = math.max(10.0, zoneW + t - 0.4);
      parts.add({
        'partName': 'وش درج مخصص (#$unitNumber)',
        'material': doorMaterial,
        'width': double.parse(frontW.toStringAsFixed(1)),
        'height': double.parse(frontH.toStringAsFixed(1)),
        'count': node.itemCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': true,
        'edgeW1': true,
        'edgeW2': true,
      });

      final double boxH = math.max(8.0, frontH - 4.0);
      final double boxD = math.max(10.0, depth - 5.0);
      parts.add({
        'partName': 'جنب علبة درج (#$unitNumber)',
        'material': carcassMaterial,
        'width': boxD,
        'height': double.parse(boxH.toStringAsFixed(1)),
        'count': (node.itemCount * 2) * quantity,
        'hasGrain': false,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });

      final double boxInnerW = math.max(5.0, zoneW - 2.6 - (2 * t));
      parts.add({
        'partName': 'عرض علبة درج (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(boxInnerW.toStringAsFixed(1)),
        'height': double.parse(boxH.toStringAsFixed(1)),
        'count': (node.itemCount * 2) * quantity,
        'hasGrain': false,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });
    } else if (node.contentType == ZoneContentType.doors && node.itemCount > 0) {
      final double doorH = math.max(10.0, zoneH + t - 0.4);
      final double doorW = math.max(10.0, ((zoneW + t) / node.itemCount) - 0.3);
      parts.add({
        'partName': 'ضلفة مخصصة (#$unitNumber)',
        'material': doorMaterial,
        'width': double.parse(doorW.toStringAsFixed(1)),
        'height': double.parse(doorH.toStringAsFixed(1)),
        'count': node.itemCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': true,
        'edgeW1': true,
        'edgeW2': true,
      });
    }
  }
}