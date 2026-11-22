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

enum FrontMountType { fullOverlay, inset }

enum UnitTemplateKind {
  standard,
  drawersMixedSmallTop,
  drawersMixedLargeTop,
  dishRack,
}

class UnitPreset {
  final String id;
  final String name;
  final MainCategory category;
  final UnitTemplateKind kind;
  final double defaultW;
  final double defaultH;
  final double defaultD;
  final int defaultShelves;
  final int defaultDoors;
  final int defaultDrawers;
  final bool isSinkUnit;
  final bool isOpenDesk;
  final bool isWallLibrary;

  const UnitPreset({
    required this.id,
    required this.name,
    required this.category,
    this.kind = UnitTemplateKind.standard,
    this.defaultW = 80,
    this.defaultH = 85,
    this.defaultD = 56,
    this.defaultShelves = 1,
    this.defaultDoors = 2,
    this.defaultDrawers = 0,
    this.isSinkUnit = false,
    this.isOpenDesk = false,
    this.isWallLibrary = false,
  });
}

class FurnitureCatalog {
  static const List<UnitPreset> allPresets = [
    // --- وحدات مطبخ أرضية ---
    UnitPreset(
      id: 'kb_base',
      name: 'خزانة سفلية قياسية',
      category: MainCategory.kitchenBase,
      defaultW: 80,
      defaultH: 72,
      defaultD: 56,
      defaultShelves: 1,
      defaultDoors: 2,
    ),
    UnitPreset(
      id: 'kb_sink',
      name: 'وحدة حوض (بدون سقف)',
      category: MainCategory.kitchenBase,
      defaultW: 90,
      defaultH: 72,
      defaultD: 56,
      defaultShelves: 0,
      defaultDoors: 2,
      isSinkUnit: true,
    ),
    UnitPreset(
      id: 'kb_drawers_3',
      name: 'وحدة 3 أدراج',
      category: MainCategory.kitchenBase,
      defaultW: 60,
      defaultH: 72,
      defaultD: 56,
      defaultShelves: 0,
      defaultDoors: 0,
      defaultDrawers: 3,
    ),
    UnitPreset(
      id: 'kb_2big_1small',
      name: 'وحدة درجين كبار + درج صغير',
      category: MainCategory.kitchenBase,
      kind: UnitTemplateKind.drawersMixedSmallTop,
      defaultW: 60,
      defaultH: 72,
      defaultD: 56,
      defaultShelves: 0,
      defaultDoors: 0,
      defaultDrawers: 3,
    ),
    UnitPreset(
      id: 'kb_1big_2small',
      name: 'وحدة درج كبير + درجين صغيرين',
      category: MainCategory.kitchenBase,
      kind: UnitTemplateKind.drawersMixedLargeTop,
      defaultW: 60,
      defaultH: 72,
      defaultD: 56,
      defaultShelves: 0,
      defaultDoors: 0,
      defaultDrawers: 3,
    ),
    UnitPreset(
      id: 'kb_drawers_4',
      name: 'وحدة 4 أدراج عميقة',
      category: MainCategory.kitchenBase,
      defaultW: 60,
      defaultH: 72,
      defaultD: 56,
      defaultShelves: 0,
      defaultDoors: 0,
      defaultDrawers: 4,
    ),
    UnitPreset(
      id: 'kb_drawer_doors',
      name: 'وحدة درج علوي + ضلفتين',
      category: MainCategory.kitchenBase,
      defaultW: 80,
      defaultH: 72,
      defaultD: 56,
      defaultShelves: 1,
      defaultDoors: 2,
      defaultDrawers: 1,
    ),
    UnitPreset(
      id: 'kb_3doors',
      name: 'أرضي بقاطوع و 3 ضلف',
      category: MainCategory.kitchenBase,
      defaultW: 120,
      defaultH: 72,
      defaultD: 56,
      defaultShelves: 1,
      defaultDoors: 3,
    ),
    UnitPreset(
      id: 'kb_oven',
      name: 'وحدة فرن بلت إن + درج سفلي',
      category: MainCategory.kitchenBase,
      defaultW: 60,
      defaultH: 85,
      defaultD: 58,
      defaultShelves: 1,
      defaultDoors: 0,
      defaultDrawers: 1,
    ),
    UnitPreset(
      id: 'kb_island',
      name: 'وحدة جزيرة مطبخ (Island)',
      category: MainCategory.kitchenBase,
      defaultW: 180,
      defaultH: 85,
      defaultD: 80,
      defaultShelves: 2,
      defaultDoors: 4,
      defaultDrawers: 2,
    ),

    // --- وحدات مطبخ علوية ودواليب ---
    UnitPreset(
      id: 'kw_dish_rack',
      name: 'صفاية / مطبقية',
      category: MainCategory.kitchenWall,
      kind: UnitTemplateKind.dishRack,
      defaultW: 80,
      defaultH: 70,
      defaultD: 32,
      defaultShelves: 2,
      defaultDoors: 2,
    ),
    UnitPreset(
      id: 'kw_wall',
      name: 'وحدة علوية ضلفتين',
      category: MainCategory.kitchenWall,
      defaultW: 80,
      defaultH: 70,
      defaultD: 32,
      defaultShelves: 1,
      defaultDoors: 2,
    ),
    UnitPreset(
      id: 'kw_wall_1door',
      name: 'وحدة علوية ضلفة واحدة',
      category: MainCategory.kitchenWall,
      defaultW: 45,
      defaultH: 70,
      defaultD: 32,
      defaultShelves: 1,
      defaultDoors: 1,
    ),
    UnitPreset(
      id: 'kw_hood',
      name: 'وحدة شفاط / شواية',
      category: MainCategory.kitchenWall,
      defaultW: 60,
      defaultH: 55,
      defaultD: 34,
      defaultShelves: 0,
      defaultDoors: 1,
    ),
    UnitPreset(
      id: 'kw_microwave',
      name: 'وحدة ميكروويف علوية',
      category: MainCategory.kitchenWall,
      defaultW: 60,
      defaultH: 50,
      defaultD: 36,
      defaultShelves: 1,
      defaultDoors: 1,
    ),
    UnitPreset(
      id: 'kw_tall',
      name: 'دولاب خزين / بانتري طويل',
      category: MainCategory.kitchenWall,
      defaultW: 60,
      defaultH: 210,
      defaultD: 58,
      defaultShelves: 4,
      defaultDoors: 2,
    ),
    UnitPreset(
      id: 'kw_fridge_top',
      name: 'وحدة أعلى الثلاجة',
      category: MainCategory.kitchenWall,
      defaultW: 90,
      defaultH: 45,
      defaultD: 58,
      defaultShelves: 0,
      defaultDoors: 2,
    ),

    // --- دواليب غرف ---
    UnitPreset(id: 'wd_2doors', name: 'دولاب 2 ضلفة مفصلية', category: MainCategory.wardrobe, defaultW: 100, defaultH: 220, defaultD: 60, defaultShelves: 2, defaultDoors: 2),
    UnitPreset(id: 'wd_3doors', name: 'دولاب 3 ضلف (قاطوع داخلي)', category: MainCategory.wardrobe, defaultW: 150, defaultH: 220, defaultD: 60, defaultShelves: 3, defaultDoors: 3),
    UnitPreset(id: 'wd_4doors', name: 'دولاب 4 ضلف مفصلية', category: MainCategory.wardrobe, defaultW: 200, defaultH: 220, defaultD: 60, defaultShelves: 4, defaultDoors: 4),
    UnitPreset(id: 'wd_sliding', name: 'دولاب جرار 2 ضلفة', category: MainCategory.wardrobe, defaultW: 180, defaultH: 220, defaultD: 65, defaultShelves: 4, defaultDoors: 2),
    UnitPreset(id: 'wd_corner', name: 'دولاب زاوية غرفة', category: MainCategory.wardrobe, defaultW: 100, defaultH: 220, defaultD: 60, defaultShelves: 3, defaultDoors: 2),

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
  FrontMountType frontMount;
  String carcassMaterial;
  String doorMaterial;
  DummySide dummySide;
  BackMaterial backMaterial;
  bool glassDoors;
  bool glassShelves;
  double boardThickness;
  double clearanceCm;
  double gProfileDeductCm;
  double shelfSetbackCm;
  double backGrooveAddCm;

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
    this.frontMount = FrontMountType.fullOverlay,
    this.carcassMaterial = "شاسيه أبيض",
    this.doorMaterial = "لون الضلفة الأساسي",
    this.dummySide = DummySide.none,
    this.backMaterial = BackMaterial.plywoodGrooved,
    this.glassDoors = false,
    this.glassShelves = false,
    this.boardThickness = 1.8,
    this.clearanceCm = 0.3,
    this.gProfileDeductCm = 3.5,
    this.shelfSetbackCm = 2.5,
    this.backGrooveAddCm = 1.7,
  });

  String _fmt(double v) => v.toStringAsFixed(1);

  List<Map<String, dynamic>> generateCutList(int unitNumber) {
    final List<Map<String, dynamic>> parts = [];
    final double t = boardThickness;
    final double innerW = math.max(0.0, width - (2 * t));
    final double innerH = math.max(0.0, height - (2 * t));
    final bool isInset = frontMount == FrontMountType.inset;
    final double gap = math.max(0.0, clearanceCm);

    if (preset.isOpenDesk) {
      final double topW = math.max(0.0, depth);
      final double topH = math.max(0.0, width);
      parts.add({
        'partName': 'سطح مكتب (#$unitNumber - ${preset.name})',
        'material': doorMaterial,
        'width': double.parse(_fmt(topW)),
        'height': double.parse(_fmt(topH)),
        'count': 1 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': true,
        'edgeW1': true,
        'edgeW2': true,
        'formula': 'البعد الأول (عمق): ${_fmt(topW)} سم | البعد الثاني (عرض): ${_fmt(topH)} سم',
      });

      final double legW = math.max(0.0, depth - 2.0);
      final double legH = math.max(0.0, height - t);
      parts.add({
        'partName': 'جنب داعم للمكتب (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(legW)),
        'height': double.parse(_fmt(legH)),
        'count': 1 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق (${_fmt(depth)} - 2.0 = ${_fmt(legW)}) × ارتفاع (${_fmt(height)} - تخانة ${_fmt(t)} = ${_fmt(legH)})',
      });

      if (drawersCount > 0) {
        const double pedW = 42.0;
        final double pedH = math.max(0.0, height - t);
        parts.add({
          'partName': 'جنب وحدة أدراج المكتب (#$unitNumber)',
          'material': carcassMaterial,
          'width': double.parse(_fmt(legW)),
          'height': double.parse(_fmt(pedH)),
          'count': 2 * quantity,
          'hasGrain': true,
          'edgeL1': true,
          'edgeL2': false,
          'edgeW1': false,
          'edgeW2': false,
          'formula': 'عمق (${_fmt(legW)} سم) × ارتفاع (${_fmt(pedH)} سم)',
        });

        final double effectivePedW = isInset ? math.max(0.0, pedW - 2 * t) : pedW;
        final double frontH = math.max(0.0, (pedH / drawersCount) - gap);
        final double frontW = math.max(0.0, effectivePedW - gap);
        parts.add({
          'partName': 'وش درج مكتب (#$unitNumber)',
          'material': doorMaterial,
          'width': double.parse(_fmt(frontW)),
          'height': double.parse(_fmt(frontH)),
          'count': drawersCount * quantity,
          'hasGrain': true,
          'edgeL1': true,
          'edgeL2': true,
          'edgeW1': true,
          'edgeW2': true,
          'formula': 'عرض (${_fmt(frontW)} سم) × ارتفاع (${_fmt(frontH)} سم)',
        });
      }
      return parts;
    }

    final double sideW = math.max(0.0, depth);
    final double sideH = math.max(0.0, height);
    parts.add({
      'partName': 'جنب وحدة (#$unitNumber - ${preset.name})',
      'material': carcassMaterial,
      'width': double.parse(_fmt(sideW)),
      'height': double.parse(_fmt(sideH)),
      'count': 2 * quantity,
      'hasGrain': true,
      'edgeL1': true,
      'edgeL2': false,
      'edgeW1': false,
      'edgeW2': false,
      'formula': 'البعد الأول (عمق): ${_fmt(sideW)} سم | البعد الثاني (ارتفاع): ${_fmt(sideH)} سم',
    });

    if (preset.isSinkUnit) {
      parts.add({
        'partName': 'قاعدة حوض (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(sideW)),
        'height': double.parse(_fmt(innerW)),
        'count': 1 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق (${_fmt(sideW)} سم) × صافي عرض (${_fmt(width)} - 2×${_fmt(t)} = ${_fmt(innerW)} سم)',
      });
      parts.add({
        'partName': 'عارضة تجميع حوض (#$unitNumber)',
        'material': carcassMaterial,
        'width': 10.0,
        'height': double.parse(_fmt(innerW)),
        'count': 2 * quantity,
        'hasGrain': false,
        'edgeL1': true,
        'edgeL2': true,
        'edgeW1': false,
        'edgeW2': false,
        'formula': '10.0 سم × صافي عرض (${_fmt(innerW)} سم)',
      });
    } else {
      parts.add({
        'partName': 'قاعدة وسقف (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(sideW)),
        'height': double.parse(_fmt(innerW)),
        'count': 2 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق (${_fmt(sideW)} سم) × صافي عرض (${_fmt(width)} - 2×${_fmt(t)} = ${_fmt(innerW)} سم)',
      });
    }

    int dividersCount = 0;
    if (preset.isWallLibrary) {
      dividersCount = math.max(1, (width / 75.0).floor() - 1);
    } else if (doorsCount == 3 || width >= 110) {
      dividersCount = 1;
    }

    if (dividersCount > 0) {
      final double divW = math.max(0.0, depth - 2.0);
      parts.add({
        'partName': 'قاطوع رأسي (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(divW)),
        'height': double.parse(_fmt(innerH)),
        'count': dividersCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق (${_fmt(depth)} - 2.0 = ${_fmt(divW)}) × صافي ارتفاع (${_fmt(height)} - 2×${_fmt(t)} = ${_fmt(innerH)})',
      });
    }

    if (shelvesCount > 0 && !glassShelves) {
      final double setback = math.max(0.0, shelfSetbackCm);
      final double shelfW = math.max(0.0, depth - setback);
      final double sectionW = dividersCount > 0
          ? (innerW - (dividersCount * t)) / (dividersCount + 1)
          : innerW;
      final double shelfH = math.max(0.0, sectionW - 0.2);
      parts.add({
        'partName': 'رف داخلي (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(shelfW)),
        'height': double.parse(_fmt(shelfH)),
        'count': shelvesCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق (${_fmt(depth)} - خصم الرف ${_fmt(setback)} = ${_fmt(shelfW)}) × فتحة (${_fmt(sectionW)} - 0.2 = ${_fmt(shelfH)})',
      });
    }

    final double frontSpanW = isInset ? innerW : width;
    final double frontSpanH = isInset ? innerH : height;

    if (doorsCount > 0 && !glassDoors) {
      final double handleDeduct =
          (handleType == HandleType.builtIn) ? math.max(0.0, gProfileDeductCm) : 0.0;
      final double drawersHeightOccupied =
          (drawersCount > 0 && doorsCount > 0) ? (frontSpanH * 0.25) : 0.0;
      final double doorH = preset.isWallLibrary
          ? math.max(0.0, (frontSpanH * 0.35) - gap)
          : math.max(0.0, frontSpanH - drawersHeightOccupied - handleDeduct - gap);
      final double doorW = math.max(0.0, (frontSpanW / doorsCount) - gap);

      final String hSource = isInset
          ? 'صافي ارتفاع (${_fmt(height)} - 2×${_fmt(t)} = ${_fmt(innerH)})'
          : 'ارتفاع الوحدة (${_fmt(height)})';
      final String wSource = isInset
          ? 'صافي عرض (${_fmt(width)} - 2×${_fmt(t)} = ${_fmt(innerW)})'
          : 'عرض الوحدة (${_fmt(width)})';

      parts.add({
        'partName': 'ضلفة (#$unitNumber)',
        'material': doorMaterial,
        'width': double.parse(_fmt(doorH)),
        'height': double.parse(_fmt(doorW)),
        'count': doorsCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': true,
        'edgeW1': true,
        'edgeW2': true,
        'formula': 'الضلفة (${isInset ? "غاطس" : "لطش"}): ارتفاع = $hSource${handleDeduct > 0 ? " - بيلت إن ${_fmt(handleDeduct)}" : ""} - خلوص ${_fmt(gap)} = ${_fmt(doorH)} سم | عرض = ($wSource ÷ $doorsCount) - خلوص ${_fmt(gap)} = ${_fmt(doorW)} سم',
      });
    }

    if (drawersCount > 0) {
      final double totalDrawerZoneH =
          (doorsCount > 0) ? (frontSpanH * 0.25) : frontSpanH;
      final double drawerFrontH =
          math.max(0.0, (totalDrawerZoneH / drawersCount) - gap);
      final double drawerFrontW = math.max(0.0, frontSpanW - gap);

      parts.add({
        'partName': 'وش درج (#$unitNumber)',
        'material': doorMaterial,
        'width': double.parse(_fmt(drawerFrontH)),
        'height': double.parse(_fmt(drawerFrontW)),
        'count': drawersCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': true,
        'edgeW1': true,
        'edgeW2': true,
        'formula': 'ارتفاع = (${_fmt(totalDrawerZoneH)} ÷ $drawersCount) - خلوص ${_fmt(gap)} = ${_fmt(drawerFrontH)} سم | عرض = ${_fmt(frontSpanW)} - خلوص ${_fmt(gap)} = ${_fmt(drawerFrontW)} سم',
      });

      final double boxH = math.max(10.0, drawerFrontH - 4.0);
      final double boxD = math.max(0.0, depth - 5.0);
      parts.add({
        'partName': 'جنب علبة درج (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(boxD)),
        'height': double.parse(_fmt(boxH)),
        'count': (drawersCount * 2) * quantity,
        'hasGrain': false,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق (${_fmt(depth)} - 5.0 = ${_fmt(boxD)}) × ارتفاع (${_fmt(drawerFrontH)} - 4.0 = ${_fmt(boxH)})',
      });

      final double boxInnerW = math.max(0.0, innerW - 2.6 - (2 * t));
      parts.add({
        'partName': 'عرض علبة درج (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(boxInnerW)),
        'height': double.parse(_fmt(boxH)),
        'count': (drawersCount * 2) * quantity,
        'hasGrain': false,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'صافي (${_fmt(innerW)} - 2.6 - 2×${_fmt(t)} = ${_fmt(boxInnerW)}) × ارتفاع (${_fmt(boxH)})',
      });
    }

    if (dummySide != DummySide.none) {
      final int dummyCount = (dummySide == DummySide.both) ? 2 : 1;
      final double dumW = math.max(0.0, depth + t);
      parts.add({
        'partName': 'جنب عيرة ديكور (#$unitNumber)',
        'material': doorMaterial,
        'width': double.parse(_fmt(dumW)),
        'height': double.parse(_fmt(height)),
        'count': dummyCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': true,
        'edgeW1': true,
        'edgeW2': true,
        'formula': 'عمق (${_fmt(depth)} + تخانة ${_fmt(t)} = ${_fmt(dumW)}) × ارتفاع (${_fmt(height)})',
      });
    }

    if (backMaterial != BackMaterial.none) {
      final bool isGrooved = backMaterial == BackMaterial.plywoodGrooved;
      final double grooveAdd = isGrooved ? math.max(0.0, backGrooveAddCm) : 0.0;
      final double backW = innerW + grooveAdd;
      final double backH = innerH + grooveAdd;
      final String backMatName = isGrooved ? "أبلكاش مفحار (4 مم)" : carcassMaterial;

      parts.add({
        'partName': 'ظهر وحدة (#$unitNumber)',
        'material': backMatName,
        'width': double.parse(_fmt(backW)),
        'height': double.parse(_fmt(backH)),
        'count': 1 * quantity,
        'hasGrain': !isGrooved,
        'edgeL1': false,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': isGrooved
            ? 'عرض = صافي (${_fmt(innerW)}) + مفحار (${_fmt(grooveAdd)}) = ${_fmt(backW)} سم | ارتفاع = صافي (${_fmt(innerH)}) + مفحار (${_fmt(grooveAdd)}) = ${_fmt(backH)} سم'
            : 'صافي عرض (${_fmt(innerW)} سم) × صافي ارتفاع (${_fmt(innerH)} سم)',
      });
    }

    return parts;
  }
}