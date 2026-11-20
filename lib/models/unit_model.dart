import 'dart:math' as math;

enum MainCategory {
  kitchenBase,
  kitchenWall,
  wardrobe,
  dressing,
  office,
  bedroomAndLiving,
}

enum HandleType { builtIn, external, pushToOpen }

enum DummySide { none, left, right, both }

enum BackMaterial { sameAsCarcass, plywoodGrooved, none }

class UnitPreset {
  final String id;
  final String name;
  final MainCategory category;
  final double defaultW;
  final double defaultH;
  final double defaultD;
  final int defaultShelves;
  final int defaultDoors;
  final int defaultDrawers;
  final bool isSinkUnit;
  final bool isCornerL;
  final bool isOpenDesk;
  final bool isWallLibrary;

  const UnitPreset({
    required this.id,
    required this.name,
    required this.category,
    this.defaultW = 80,
    this.defaultH = 85,
    this.defaultD = 56,
    this.defaultShelves = 1,
    this.defaultDoors = 2,
    this.defaultDrawers = 0,
    this.isSinkUnit = false,
    this.isCornerL = false,
    this.isOpenDesk = false,
    this.isWallLibrary = false,
  });
}

class FurnitureCatalog {
  static const List<UnitPreset> allPresets = [
    // --- وحدات مطبخ أرضية ---
    UnitPreset(id: 'kb_base', name: 'خزانة سفلية قياسية', category: MainCategory.kitchenBase, defaultW: 80, defaultH: 72, defaultD: 56, defaultShelves: 1, defaultDoors: 2),
    UnitPreset(id: 'kb_sink', name: 'وحدة حوض (بدون سقف)', category: MainCategory.kitchenBase, defaultW: 90, defaultH: 72, defaultD: 56, defaultShelves: 0, defaultDoors: 2, isSinkUnit: true),
    UnitPreset(id: 'kb_drawers_3', name: 'وحدة 3 أدراج', category: MainCategory.kitchenBase, defaultW: 60, defaultH: 72, defaultD: 56, defaultShelves: 0, defaultDoors: 0, defaultDrawers: 3),
    UnitPreset(id: 'kb_drawers_4', name: 'وحدة 4 أدراج عميقة', category: MainCategory.kitchenBase, defaultW: 60, defaultH: 72, defaultD: 56, defaultShelves: 0, defaultDoors: 0, defaultDrawers: 4),
    UnitPreset(id: 'kb_drawer_doors', name: 'وحدة درج علوي + ضلفتين', category: MainCategory.kitchenBase, defaultW: 80, defaultH: 72, defaultD: 56, defaultShelves: 1, defaultDoors: 2, defaultDrawers: 1),
    UnitPreset(id: 'kb_3doors', name: 'أرضي بقاطوع و 3 ضلف', category: MainCategory.kitchenBase, defaultW: 120, defaultH: 72, defaultD: 56, defaultShelves: 1, defaultDoors: 3),
    UnitPreset(id: 'kb_corner', name: 'وحدة ركنة L سفلية', category: MainCategory.kitchenBase, defaultW: 90, defaultH: 72, defaultD: 90, defaultShelves: 1, defaultDoors: 2, isCornerL: true),
    UnitPreset(id: 'kb_oven', name: 'وحدة فرن بلت إن + درج سفلي', category: MainCategory.kitchenBase, defaultW: 60, defaultH: 72, defaultD: 56, defaultShelves: 0, defaultDoors: 0, defaultDrawers: 1),
    UnitPreset(id: 'kb_island', name: 'وحدة جزيرة مطبخ (Island)', category: MainCategory.kitchenBase, defaultW: 180, defaultH: 85, defaultD: 80, defaultShelves: 2, defaultDoors: 4, defaultDrawers: 2),

    // --- وحدات مطبخ علوية ودواليب ---
    UnitPreset(id: 'kw_wall', name: 'وحدة علوية ضلفتين', category: MainCategory.kitchenWall, defaultW: 80, defaultH: 70, defaultD: 32, defaultShelves: 1, defaultDoors: 2),
    UnitPreset(id: 'kw_wall_1door', name: 'وحدة علوية ضلفة واحدة', category: MainCategory.kitchenWall, defaultW: 45, defaultH: 70, defaultD: 32, defaultShelves: 1, defaultDoors: 1),
    UnitPreset(id: 'kw_dish', name: 'وحدة مطبقية', category: MainCategory.kitchenWall, defaultW: 80, defaultH: 70, defaultD: 32, defaultShelves: 0, defaultDoors: 2),
    UnitPreset(id: 'kw_hood', name: 'وحدة شفاط / شواية', category: MainCategory.kitchenWall, defaultW: 60, defaultH: 50, defaultD: 32, defaultShelves: 0, defaultDoors: 2),
    UnitPreset(id: 'kw_microwave', name: 'وحدة ميكروويف علوية', category: MainCategory.kitchenWall, defaultW: 60, defaultH: 45, defaultD: 35, defaultShelves: 0, defaultDoors: 1),
    UnitPreset(id: 'kw_tall', name: 'دولاب خزين / بانتري طويل', category: MainCategory.kitchenWall, defaultW: 60, defaultH: 210, defaultD: 58, defaultShelves: 4, defaultDoors: 2),
    UnitPreset(id: 'kw_fridge_top', name: 'وحدة أعلى الثلاجة', category: MainCategory.kitchenWall, defaultW: 90, defaultH: 45, defaultD: 58, defaultShelves: 0, defaultDoors: 2),

    // --- دواليب غرف ---
    UnitPreset(id: 'wd_2doors', name: 'دولاب 2 ضلفة مفصلية', category: MainCategory.wardrobe, defaultW: 100, defaultH: 220, defaultD: 60, defaultShelves: 2, defaultDoors: 2),
    UnitPreset(id: 'wd_3doors', name: 'دولاب 3 ضلف (قاطوع داخلي)', category: MainCategory.wardrobe, defaultW: 150, defaultH: 220, defaultD: 60, defaultShelves: 3, defaultDoors: 3),
    UnitPreset(id: 'wd_4doors', name: 'دولاب 4 ضلف مفصلية', category: MainCategory.wardrobe, defaultW: 200, defaultH: 220, defaultD: 60, defaultShelves: 4, defaultDoors: 4),
    UnitPreset(id: 'wd_sliding', name: 'دولاب جرار 2 ضلفة', category: MainCategory.wardrobe, defaultW: 180, defaultH: 220, defaultD: 65, defaultShelves: 4, defaultDoors: 2),
    UnitPreset(id: 'wd_corner', name: 'دولاب ركنة غرفة L', category: MainCategory.wardrobe, defaultW: 100, defaultH: 220, defaultD: 100, defaultShelves: 3, defaultDoors: 2, isCornerL: true),

    // --- دريسنج روم ---
    UnitPreset(id: 'dr_shelves', name: 'وحدة أرفف دريسنج مفتوحة', category: MainCategory.dressing, defaultW: 80, defaultH: 220, defaultD: 50, defaultShelves: 5, defaultDoors: 0),
    UnitPreset(id: 'dr_drawers', name: 'وحدة دريسنج بأدراج سفلية', category: MainCategory.dressing, defaultW: 80, defaultH: 220, defaultD: 50, defaultShelves: 3, defaultDoors: 0, defaultDrawers: 3),
    UnitPreset(id: 'dr_hanger', name: 'وحدة شماعات مزدوجة', category: MainCategory.dressing, defaultW: 90, defaultH: 220, defaultD: 55, defaultShelves: 1, defaultDoors: 0),
    UnitPreset(id: 'dr_island', name: 'جزيرة دريسنج بأدراج علوية', category: MainCategory.dressing, defaultW: 120, defaultH: 85, defaultD: 55, defaultShelves: 1, defaultDoors: 0, defaultDrawers: 4),

    // --- مكاتب ومكتبات ---
    UnitPreset(id: 'of_open_desk_pedestal', name: 'مكتب مفتوح بوحدة أدراج جانبية', category: MainCategory.office, defaultW: 140, defaultH: 75, defaultD: 65, defaultShelves: 0, defaultDoors: 0, defaultDrawers: 3, isOpenDesk: true),
    UnitPreset(id: 'of_desk', name: 'مكتب عمل بوحدة أدراج', category: MainCategory.office, defaultW: 140, defaultH: 75, defaultD: 65, defaultShelves: 0, defaultDoors: 0, defaultDrawers: 3),
    UnitPreset(id: 'of_study_desk', name: 'مكتب دراسة / كمبيوتر بسيط', category: MainCategory.office, defaultW: 120, defaultH: 75, defaultD: 60, defaultShelves: 0, defaultDoors: 0, defaultDrawers: 1, isOpenDesk: true),
    UnitPreset(id: 'of_wall_library', name: 'مكتبة حائط كاملة (أرفف + ضلف)', category: MainCategory.office, defaultW: 260, defaultH: 240, defaultD: 38, defaultShelves: 4, defaultDoors: 4, isWallLibrary: true),
    UnitPreset(id: 'of_bookcase', name: 'مكتبة ملفات وأرفف', category: MainCategory.office, defaultW: 80, defaultH: 180, defaultD: 35, defaultShelves: 4, defaultDoors: 2),
    UnitPreset(id: 'of_open_shelf', name: 'وحدة أرفف مفتوحة (كلاسيك / مودرن)', category: MainCategory.office, defaultW: 90, defaultH: 200, defaultD: 35, defaultShelves: 5, defaultDoors: 0),
    UnitPreset(id: 'of_filing', name: 'وحدة أرشيف وملفات', category: MainCategory.office, defaultW: 80, defaultH: 110, defaultD: 45, defaultShelves: 1, defaultDoors: 2),

    // --- غرف نوم، ريسبشن، ووحدات متنوعة ---
    UnitPreset(id: 'bl_tv', name: 'مكتبة تليفزيون مودرن', category: MainCategory.bedroomAndLiving, defaultW: 160, defaultH: 45, defaultD: 40, defaultShelves: 1, defaultDoors: 2),
    UnitPreset(id: 'bl_tv_wall', name: 'وحدة تليفزيون كاملة بأرفف جانبية', category: MainCategory.bedroomAndLiving, defaultW: 220, defaultH: 200, defaultD: 38, defaultShelves: 4, defaultDoors: 3, isWallLibrary: true),
    UnitPreset(id: 'bl_nightstand', name: 'كومودينو غرفة نوم', category: MainCategory.bedroomAndLiving, defaultW: 50, defaultH: 50, defaultD: 40, defaultShelves: 0, defaultDoors: 0, defaultDrawers: 2),
    UnitPreset(id: 'bl_dresser', name: 'تسريحة بأدراج', category: MainCategory.bedroomAndLiving, defaultW: 110, defaultH: 75, defaultD: 45, defaultShelves: 0, defaultDoors: 0, defaultDrawers: 4),
    UnitPreset(id: 'bl_shoe_rack', name: 'جزامة مدخل / أحذية', category: MainCategory.bedroomAndLiving, defaultW: 90, defaultH: 100, defaultD: 35, defaultShelves: 3, defaultDoors: 2),
    UnitPreset(id: 'bl_console', name: 'كونسول مدخل (Console)', category: MainCategory.bedroomAndLiving, defaultW: 120, defaultH: 80, defaultD: 35, defaultShelves: 1, defaultDoors: 0, defaultDrawers: 2),
    UnitPreset(id: 'bl_side_table', name: 'ترابيزة جانبية (Side Table)', category: MainCategory.bedroomAndLiving, defaultW: 45, defaultH: 50, defaultD: 45, defaultShelves: 1, defaultDoors: 0, isOpenDesk: true),
  ];
}

class ConfiguredUnit {
  final UnitPreset preset;
  int quantity;
  double width;
  double height;
  double depth;
  int shelvesCount;
  int doorsCount;
  int drawersCount;
  HandleType handleType;
  String carcassMaterial;
  String doorMaterial;
  DummySide dummySide;
  BackMaterial backMaterial;
  bool glassDoors;
  bool glassShelves;
  double boardThickness;

  ConfiguredUnit({
    required this.preset,
    this.quantity = 1,
    required this.width,
    required this.height,
    required this.depth,
    required this.shelvesCount,
    required this.doorsCount,
    required this.drawersCount,
    this.handleType = HandleType.builtIn,
    this.carcassMaterial = "شاسيه أبيض",
    this.doorMaterial = "لون الضلفة الأساسي",
    this.dummySide = DummySide.none,
    this.backMaterial = BackMaterial.plywoodGrooved,
    this.glassDoors = false,
    this.glassShelves = false,
    this.boardThickness = 1.8,
  });

  List<Map<String, dynamic>> generateCutList(int unitNumber) {
    final List<Map<String, dynamic>> parts = [];
    final double t = boardThickness;
    final double innerW = math.max(0.0, width - (2 * t));
    final double innerH = math.max(0.0, height - (2 * t));

    if (preset.isOpenDesk) {
      // سطح المكتب العلوي
      parts.add({
        'partName': 'سطح مكتب (#$unitNumber - ${preset.name})',
        'material': doorMaterial,
        'width': math.max(0.0, depth),
        'height': math.max(0.0, width),
        'count': 1 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': true,
        'edgeW1': true,
        'edgeW2': true,
      });

      // جنب داعم للمكتب
      parts.add({
        'partName': 'جنب داعم للمكتب (#$unitNumber)',
        'material': carcassMaterial,
        'width': math.max(0.0, depth - 2.0),
        'height': math.max(0.0, height - t),
        'count': 1 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });

      // لو فيه أدراج، نضيف وحدة الأدراج الجانبية
      if (drawersCount > 0) {
        const double pedW = 42.0;
        final double pedH = math.max(0.0, height - t);
        parts.add({
          'partName': 'جنب وحدة أدراج المكتب (#$unitNumber)',
          'material': carcassMaterial,
          'width': math.max(0.0, depth - 2.0),
          'height': pedH,
          'count': 2 * quantity,
          'hasGrain': true,
          'edgeL1': true,
          'edgeL2': false,
          'edgeW1': false,
          'edgeW2': false,
        });

        final double frontH = math.max(0.0, (pedH / drawersCount) - 0.4);
        final double frontW = math.max(0.0, pedW - 0.4);
        parts.add({
          'partName': 'وش درج مكتب (#$unitNumber)',
          'material': doorMaterial,
          'width': double.parse(frontW.toStringAsFixed(1)),
          'height': double.parse(frontH.toStringAsFixed(1)),
          'count': drawersCount * quantity,
          'hasGrain': true,
          'edgeL1': true,
          'edgeL2': true,
          'edgeW1': true,
          'edgeW2': true,
        });
      }
      return parts;
    }

    // الوحدات الصندوقية القياسية والمكتبات
    parts.add({
      'partName': 'جنب وحدة (#$unitNumber - ${preset.name})',
      'material': carcassMaterial,
      'width': math.max(0.0, depth),
      'height': math.max(0.0, height),
      'count': 2 * quantity,
      'hasGrain': true,
      'edgeL1': true,
      'edgeL2': false,
      'edgeW1': false,
      'edgeW2': false,
    });

    if (preset.isSinkUnit) {
      parts.add({
        'partName': 'قاعدة حوض (#$unitNumber)',
        'material': carcassMaterial,
        'width': math.max(0.0, depth),
        'height': innerW,
        'count': 1 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });
      parts.add({
        'partName': 'عارضة تجميع حوض (#$unitNumber)',
        'material': carcassMaterial,
        'width': 10.0,
        'height': innerW,
        'count': 2 * quantity,
        'hasGrain': false,
        'edgeL1': true,
        'edgeL2': true,
        'edgeW1': false,
        'edgeW2': false,
      });
    } else {
      parts.add({
        'partName': 'قاعدة وسقف (#$unitNumber)',
        'material': carcassMaterial,
        'width': math.max(0.0, depth),
        'height': innerW,
        'count': 2 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });
    }

    int dividersCount = 0;
    if (preset.isWallLibrary) {
      dividersCount = math.max(1, (width / 75.0).floor() - 1);
    } else if (doorsCount == 3 || width >= 110) {
      dividersCount = 1;
    }

    if (dividersCount > 0) {
      parts.add({
        'partName': 'قاطوع رأسي (#$unitNumber)',
        'material': carcassMaterial,
        'width': math.max(0.0, depth - 2.0),
        'height': innerH,
        'count': dividersCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });
    }

    if (shelvesCount > 0 && !glassShelves) {
      final double sectionW = dividersCount > 0
          ? (innerW - (dividersCount * t)) / (dividersCount + 1)
          : innerW;
      parts.add({
        'partName': 'رف داخلي (#$unitNumber)',
        'material': carcassMaterial,
        'width': math.max(0.0, depth - 2.5),
        'height': math.max(0.0, sectionW - 0.2),
        'count': shelvesCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });
    }

    if (doorsCount > 0 && !glassDoors) {
      final double handleDeduct = (handleType == HandleType.builtIn) ? 3.5 : 0.0;
      final double drawersHeightOccupied = (drawersCount > 0 && doorsCount > 0) ? (height * 0.25) : 0.0;
      final double doorH = preset.isWallLibrary
          ? math.max(0.0, (height * 0.35) - 0.4)
          : math.max(0.0, height - drawersHeightOccupied - handleDeduct - 0.4);
      final double doorW = math.max(0.0, (width / doorsCount) - 0.3);

      parts.add({
        'partName': 'ضلفة (#$unitNumber)',
        'material': doorMaterial,
        'width': double.parse(doorW.toStringAsFixed(1)),
        'height': double.parse(doorH.toStringAsFixed(1)),
        'count': doorsCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': true,
        'edgeW1': true,
        'edgeW2': true,
      });
    }

    if (drawersCount > 0) {
      final double totalDrawerZoneH = (doorsCount > 0) ? (height * 0.25) : height;
      final double drawerFrontH = math.max(0.0, (totalDrawerZoneH / drawersCount) - 0.4);
      final double drawerFrontW = math.max(0.0, width - 0.4);

      parts.add({
        'partName': 'وش درج (#$unitNumber)',
        'material': doorMaterial,
        'width': double.parse(drawerFrontW.toStringAsFixed(1)),
        'height': double.parse(drawerFrontH.toStringAsFixed(1)),
        'count': drawersCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': true,
        'edgeW1': true,
        'edgeW2': true,
      });

      final double boxH = math.max(10.0, drawerFrontH - 4.0);
      final double boxD = math.max(0.0, depth - 5.0);
      parts.add({
        'partName': 'جنب علبة درج (#$unitNumber)',
        'material': carcassMaterial,
        'width': boxD,
        'height': double.parse(boxH.toStringAsFixed(1)),
        'count': (drawersCount * 2) * quantity,
        'hasGrain': false,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });

      final double boxInnerW = math.max(0.0, innerW - 2.6 - (2 * t));
      parts.add({
        'partName': 'عرض علبة درج (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(boxInnerW.toStringAsFixed(1)),
        'height': double.parse(boxH.toStringAsFixed(1)),
        'count': (drawersCount * 2) * quantity,
        'hasGrain': false,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });
    }

    if (dummySide != DummySide.none) {
      final int dummyCount = (dummySide == DummySide.both) ? 2 : 1;
      parts.add({
        'partName': 'جنب عيرة ديكور (#$unitNumber)',
        'material': doorMaterial,
        'width': math.max(0.0, depth + t),
        'height': math.max(0.0, height),
        'count': dummyCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': true,
        'edgeW1': true,
        'edgeW2': true,
      });
    }

    if (backMaterial != BackMaterial.none) {
      final String backMatName = backMaterial == BackMaterial.plywoodGrooved
          ? "أبلكاش مفحار (4 مم)"
          : carcassMaterial;
      final bool isGrooved = backMaterial == BackMaterial.plywoodGrooved;
      parts.add({
        'partName': 'ظهر وحدة (#$unitNumber)',
        'material': backMatName,
        'width': isGrooved ? (innerW + 1.4) : innerW,
        'height': isGrooved ? (innerH + 1.4) : innerH,
        'count': 1 * quantity,
        'hasGrain': !isGrooved,
        'edgeL1': false,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });
    }

    if (preset.isCornerL) {
      parts.add({
        'partName': 'جنب ركنة داخلي (#$unitNumber)',
        'material': carcassMaterial,
        'width': math.max(20.0, depth - t),
        'height': innerH,
        'count': 1 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
      });
    }

    return parts;
  }
}