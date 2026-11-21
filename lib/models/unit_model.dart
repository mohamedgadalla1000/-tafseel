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
  cornerL,
  drawersLower,
  applianceTower,
  wallUpper,
  dishRack,
}

class UnitPreset {
  final String id;
  final String name;
  final MainCategory category;
  final UnitTemplateKind kind;
  final double defaultW;
  final double defaultW2;
  final double defaultH;
  final double defaultD;
  final double defaultD2;
  final int defaultShelves;
  final int defaultDoors;
  final int defaultDrawers;
  final double defaultDrawerH;
  final int defaultInnerDrawers;
  final double defaultInnerDrawerH;
  final double defaultLowerDoorH;
  final double defaultOvenH;
  final double defaultMicrowaveH;
  final double defaultHoodH;
  final bool isSinkUnit;
  final bool isCornerL;
  final bool isOpenDesk;
  final bool isWallLibrary;

  const UnitPreset({
    required this.id,
    required this.name,
    required this.category,
    this.kind = UnitTemplateKind.standard,
    this.defaultW = 80,
    this.defaultW2 = 80,
    this.defaultH = 85,
    this.defaultD = 56,
    this.defaultD2 = 56,
    this.defaultShelves = 1,
    this.defaultDoors = 2,
    this.defaultDrawers = 0,
    this.defaultDrawerH = 18,
    this.defaultInnerDrawers = 0,
    this.defaultInnerDrawerH = 12,
    this.defaultLowerDoorH = 60,
    this.defaultOvenH = 60,
    this.defaultMicrowaveH = 38,
    this.defaultHoodH = 45,
    this.isSinkUnit = false,
    this.isCornerL = false,
    this.isOpenDesk = false,
    this.isWallLibrary = false,
  });
}

class FurnitureCatalog {
  static const List<UnitPreset> allPresets = [
    // --- وحدات مطبخ أرضية ---
    UnitPreset(
      id: 'kb_corner_l',
      name: 'أرضي L ركنة',
      category: MainCategory.kitchenBase,
      kind: UnitTemplateKind.cornerL,
      defaultW: 90,
      defaultW2: 90,
      defaultH: 72,
      defaultD: 56,
      defaultD2: 56,
      defaultShelves: 1,
      defaultDoors: 2,
      defaultDrawers: 0,
      isCornerL: true,
    ),
    UnitPreset(
      id: 'kb_drawers_lower',
      name: 'أدراج سفلية',
      category: MainCategory.kitchenBase,
      kind: UnitTemplateKind.drawersLower,
      defaultW: 60,
      defaultH: 72,
      defaultD: 56,
      defaultShelves: 0,
      defaultDoors: 0,
      defaultDrawers: 3,
      defaultDrawerH: 18,
      defaultInnerDrawers: 1,
      defaultInnerDrawerH: 12,
    ),
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
      kind: UnitTemplateKind.drawersLower,
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
      kind: UnitTemplateKind.drawersLower,
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
      kind: UnitTemplateKind.applianceTower,
      defaultW: 60,
      defaultH: 85,
      defaultD: 58,
      defaultShelves: 1,
      defaultDoors: 0,
      defaultDrawers: 1,
      defaultLowerDoorH: 20,
      defaultOvenH: 60,
      defaultMicrowaveH: 0,
      defaultHoodH: 0,
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
      id: 'kw_wall_doors',
      name: 'علوي ضلف',
      category: MainCategory.kitchenWall,
      kind: UnitTemplateKind.wallUpper,
      defaultW: 80,
      defaultH: 70,
      defaultD: 32,
      defaultShelves: 1,
      defaultDoors: 2,
    ),
    UnitPreset(
      id: 'kw_dish_rack',
      name: 'صفاية / مطبقية',
      category: MainCategory.kitchenWall,
      kind: UnitTemplateKind.dishRack,
      defaultW: 80,
      defaultH: 70,
      defaultD: 32,
      defaultShelves: 1,
      defaultDoors: 2,
    ),
    UnitPreset(
      id: 'kw_appliance_tower',
      name: 'دولاب ضلف + أجهزة',
      category: MainCategory.kitchenWall,
      kind: UnitTemplateKind.applianceTower,
      defaultW: 60,
      defaultH: 210,
      defaultD: 58,
      defaultShelves: 2,
      defaultDoors: 2,
      defaultDrawers: 0,
      defaultLowerDoorH: 55,
      defaultOvenH: 60,
      defaultMicrowaveH: 38,
      defaultHoodH: 0,
    ),
    UnitPreset(
      id: 'kw_wall',
      name: 'وحدة علوية ضلفتين',
      category: MainCategory.kitchenWall,
      kind: UnitTemplateKind.wallUpper,
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
      kind: UnitTemplateKind.wallUpper,
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
      kind: UnitTemplateKind.applianceTower,
      defaultW: 60,
      defaultH: 55,
      defaultD: 34,
      defaultShelves: 0,
      defaultDoors: 1,
      defaultLowerDoorH: 0,
      defaultOvenH: 0,
      defaultMicrowaveH: 0,
      defaultHoodH: 45,
    ),
    UnitPreset(
      id: 'kw_microwave',
      name: 'وحدة ميكروويف علوية',
      category: MainCategory.kitchenWall,
      kind: UnitTemplateKind.applianceTower,
      defaultW: 60,
      defaultH: 50,
      defaultD: 36,
      defaultShelves: 0,
      defaultDoors: 1,
      defaultLowerDoorH: 0,
      defaultOvenH: 0,
      defaultMicrowaveH: 38,
      defaultHoodH: 0,
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
      kind: UnitTemplateKind.wallUpper,
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
    UnitPreset(
      id: 'wd_corner',
      name: 'دولاب ركنة غرفة L',
      category: MainCategory.wardrobe,
      kind: UnitTemplateKind.cornerL,
      defaultW: 100,
      defaultW2: 100,
      defaultH: 220,
      defaultD: 60,
      defaultD2: 60,
      defaultShelves: 3,
      defaultDoors: 2,
      isCornerL: true,
    ),

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
  double width2;
  double height;
  double depth;
  double depth2;
  int shelvesCount;
  int doorsCount;
  int drawersCount;
  double drawerHeightCm;
  int innerDrawersCount;
  double innerDrawerHeightCm;
  double lowerDoorHeightCm;
  double ovenHeightCm;
  double microwaveHeightCm;
  double hoodHeightCm;
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

  ConfiguredUnit({
    required this.preset,
    this.quantity = 1,
    required this.width,
    double? width2,
    required this.height,
    required this.depth,
    double? depth2,
    required this.shelvesCount,
    required this.doorsCount,
    required this.drawersCount,
    double? drawerHeightCm,
    int? innerDrawersCount,
    double? innerDrawerHeightCm,
    double? lowerDoorHeightCm,
    double? ovenHeightCm,
    double? microwaveHeightCm,
    double? hoodHeightCm,
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
  })  : width2 = width2 ?? preset.defaultW2,
        depth2 = depth2 ?? preset.defaultD2,
        drawerHeightCm = drawerHeightCm ?? preset.defaultDrawerH,
        innerDrawersCount = innerDrawersCount ?? preset.defaultInnerDrawers,
        innerDrawerHeightCm = innerDrawerHeightCm ?? preset.defaultInnerDrawerH,
        lowerDoorHeightCm = lowerDoorHeightCm ?? preset.defaultLowerDoorH,
        ovenHeightCm = ovenHeightCm ?? preset.defaultOvenH,
        microwaveHeightCm = microwaveHeightCm ?? preset.defaultMicrowaveH,
        hoodHeightCm = hoodHeightCm ?? preset.defaultHoodH;

  String _fmt(double v) => v.toStringAsFixed(1);

  List<Map<String, dynamic>> generateCutList(int unitNumber) {
    final List<Map<String, dynamic>> parts = [];
    final double t = boardThickness;
    final double innerW = math.max(0.0, width - (2 * t));
    final double innerH = math.max(0.0, height - (2 * t));
    final bool isInset = frontMount == FrontMountType.inset;
    final double gap = math.max(0.0, clearanceCm);

    // 1. وحدة ركنة حرف L بأبعاد وعمقين مختلفين
    if (preset.kind == UnitTemplateKind.cornerL || preset.isCornerL) {
      final double d1 = math.max(20.0, depth);
      final double d2 = math.max(20.0, depth2);
      final double w1 = math.max(30.0, width);
      final double w2 = math.max(30.0, width2);
      final double leg1Inner = math.max(0.0, w1 - d2 - t);
      final double leg2Inner = math.max(0.0, w2 - t);

      parts.add({
        'partName': 'جنب ركنة خارجي 1 (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(d1)),
        'height': double.parse(_fmt(height)),
        'count': 1 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق 1 (${_fmt(d1)} سم) × ارتفاع (${_fmt(height)} سم)',
      });

      parts.add({
        'partName': 'جنب ركنة خارجي 2 (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(d2)),
        'height': double.parse(_fmt(height)),
        'count': 1 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق 2 (${_fmt(d2)} سم) × ارتفاع (${_fmt(height)} سم)',
      });

      parts.add({
        'partName': 'قاعدة وسقف ركنة L (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(math.max(d1, d2))),
        'height': double.parse(_fmt(math.max(w1, w2))),
        'count': 2 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'أقصى عمق (${_fmt(math.max(d1, d2))} سم) × أقصى عرض (${_fmt(math.max(w1, w2))} سم)',
      });

      if (shelvesCount > 0 && !glassShelves) {
        parts.add({
          'partName': 'رف داخلي ركنة L (#$unitNumber)',
          'material': carcassMaterial,
          'width': double.parse(_fmt(math.max(15.0, d1 - 2.5))),
          'height': double.parse(_fmt(math.max(15.0, leg1Inner))),
          'count': shelvesCount * quantity,
          'hasGrain': true,
          'edgeL1': true,
          'edgeL2': false,
          'edgeW1': false,
          'edgeW2': false,
          'formula': 'عمق 1 (${_fmt(d1)} - 2.5) × فتحة داخلية (${_fmt(leg1Inner)} سم)',
        });
      }

      if (doorsCount > 0 && !glassDoors) {
        final double handleDeduct =
            (handleType == HandleType.builtIn) ? math.max(0.0, gProfileDeductCm) : 0.0;
        final double doorH = math.max(0.0, (isInset ? innerH : height) - handleDeduct - gap);
        final double doorW = math.max(0.0, ((isInset ? leg2Inner : w2) / doorsCount) - gap);
        parts.add({
          'partName': 'ضلفة ركنة L (#$unitNumber)',
          'material': doorMaterial,
          'width': double.parse(_fmt(doorH)),
          'height': double.parse(_fmt(doorW)),
          'count': doorsCount * quantity,
          'hasGrain': true,
          'edgeL1': true,
          'edgeL2': true,
          'edgeW1': true,
          'edgeW2': true,
          'formula': 'ارتفاع (${_fmt(doorH)} سم) × عرض الضلفة (${_fmt(doorW)} سم) بعد خلوص ${_fmt(gap)} سم',
        });
      }

      if (backMaterial != BackMaterial.none) {
        final String backMatName = backMaterial == BackMaterial.plywoodGrooved
            ? "أبلكاش مفحار (4 مم)"
            : carcassMaterial;
        parts.add({
          'partName': 'ظهر ركنة L (#$unitNumber)',
          'material': backMatName,
          'width': double.parse(_fmt(math.max(10.0, leg1Inner))),
          'height': double.parse(_fmt(innerH)),
          'count': 1 * quantity,
          'hasGrain': backMaterial != BackMaterial.plywoodGrooved,
          'edgeL1': false,
          'edgeL2': false,
          'edgeW1': false,
          'edgeW2': false,
          'formula': 'عرض صافي (${_fmt(leg1Inner)} سم) × ارتفاع صافي (${_fmt(innerH)} سم)',
        });
      }
      return parts;
    }

    // 2. وحدة أدراج سفلية مع ارتفاع الدرج والأدراج المخفية
    if (preset.kind == UnitTemplateKind.drawersLower) {
      parts.add({
        'partName': 'جنب وحدة أدراج (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(depth)),
        'height': double.parse(_fmt(height)),
        'count': 2 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق (${_fmt(depth)} سم) × ارتفاع (${_fmt(height)} سم)',
      });

      parts.add({
        'partName': 'قاعدة وسقف وحدة أدراج (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(depth)),
        'height': double.parse(_fmt(innerW)),
        'count': 2 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق (${_fmt(depth)} سم) × صافي عرض (${_fmt(innerW)} سم)',
      });

      final double frontW = math.max(0.0, (isInset ? innerW : width) - gap);
      final double effectiveDrawerH = drawerHeightCm > 0
          ? math.max(6.0, drawerHeightCm - gap)
          : math.max(6.0, ((isInset ? innerH : height) / math.max(1, drawersCount)) - gap);

      if (drawersCount > 0) {
        parts.add({
          'partName': 'وش درج سفلي (#$unitNumber)',
          'material': doorMaterial,
          'width': double.parse(_fmt(effectiveDrawerH)),
          'height': double.parse(_fmt(frontW)),
          'count': drawersCount * quantity,
          'hasGrain': true,
          'edgeL1': true,
          'edgeL2': true,
          'edgeW1': true,
          'edgeW2': true,
          'formula': 'ارتفاع الدرج (${_fmt(drawerHeightCm)} - خلوص ${_fmt(gap)} = ${_fmt(effectiveDrawerH)} سم) × عرض (${_fmt(frontW)} سم)',
        });
      }

      if (innerDrawersCount > 0) {
        final double inDrwH = math.max(5.0, innerDrawerHeightCm - gap);
        final double inDrwW = math.max(0.0, innerW - (2 * t) - gap);
        parts.add({
          'partName': 'درج مخفي داخلي (#$unitNumber)',
          'material': carcassMaterial,
          'width': double.parse(_fmt(inDrwH)),
          'height': double.parse(_fmt(inDrwW)),
          'count': innerDrawersCount * quantity,
          'hasGrain': false,
          'edgeL1': true,
          'edgeL2': false,
          'edgeW1': false,
          'edgeW2': false,
          'formula': 'ارتفاع درج مخفي (${_fmt(innerDrawerHeightCm)} - خلوص ${_fmt(gap)} = ${_fmt(inDrwH)} سم) × عرض داخلي (${_fmt(inDrwW)} سم)',
        });
      }

      if (backMaterial != BackMaterial.none) {
        final String backMatName = backMaterial == BackMaterial.plywoodGrooved
            ? "أبلكاش مفحار (4 مم)"
            : carcassMaterial;
        parts.add({
          'partName': 'ظهر وحدة أدراج (#$unitNumber)',
          'material': backMatName,
          'width': double.parse(_fmt(innerW)),
          'height': double.parse(_fmt(innerH)),
          'count': 1 * quantity,
          'hasGrain': backMaterial != BackMaterial.plywoodGrooved,
          'edgeL1': false,
          'edgeL2': false,
          'edgeW1': false,
          'edgeW2': false,
          'formula': 'صافي عرض (${_fmt(innerW)} سم) × صافي ارتفاع (${_fmt(innerH)} سم)',
        });
      }
      return parts;
    }

    // 3. وحدة أجهزة (فرن / ميكروويف / شفاط / ضلفة سفلية)
    if (preset.kind == UnitTemplateKind.applianceTower) {
      parts.add({
        'partName': 'جنب وحدة أجهزة (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(depth)),
        'height': double.parse(_fmt(height)),
        'count': 2 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق (${_fmt(depth)} سم) × ارتفاع (${_fmt(height)} سم)',
      });

      parts.add({
        'partName': 'قاعدة وسقف وحدة أجهزة (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(depth)),
        'height': double.parse(_fmt(innerW)),
        'count': 2 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق (${_fmt(depth)} سم) × صافي عرض (${_fmt(innerW)} سم)',
      });

      final double usedAppliancesH =
          (ovenHeightCm > 0 ? ovenHeightCm + t : 0.0) +
          (microwaveHeightCm > 0 ? microwaveHeightCm + t : 0.0) +
          (hoodHeightCm > 0 ? hoodHeightCm + t : 0.0) +
          (lowerDoorHeightCm > 0 ? lowerDoorHeightCm + t : 0.0);

      final int dividerShelves = math.max(
        shelvesCount,
        (ovenHeightCm > 0 ? 1 : 0) + (microwaveHeightCm > 0 ? 1 : 0) + (hoodHeightCm > 0 ? 1 : 0),
      );

      if (dividerShelves > 0) {
        parts.add({
          'partName': 'رف / فاصل جهاز (#$unitNumber)',
          'material': carcassMaterial,
          'width': double.parse(_fmt(math.max(15.0, depth - 2.0))),
          'height': double.parse(_fmt(innerW)),
          'count': dividerShelves * quantity,
          'hasGrain': true,
          'edgeL1': true,
          'edgeL2': false,
          'edgeW1': false,
          'edgeW2': false,
          'formula': 'عمق (${_fmt(depth)} - 2.0) × صافي عرض (${_fmt(innerW)} سم) | إجمالي ارتفاع الأجهزة/الضلف: ${_fmt(usedAppliancesH)} سم',
        });
      }

      if (lowerDoorHeightCm > 0 && !glassDoors) {
        final double handleDeduct =
            (handleType == HandleType.builtIn) ? math.max(0.0, gProfileDeductCm) : 0.0;
        final double lDoorH = math.max(5.0, lowerDoorHeightCm - handleDeduct - gap);
        final double lDoorW = math.max(5.0, ((isInset ? innerW : width) / math.max(1, doorsCount)) - gap);
        parts.add({
          'partName': 'ضلفة سفلية (#$unitNumber)',
          'material': doorMaterial,
          'width': double.parse(_fmt(lDoorH)),
          'height': double.parse(_fmt(lDoorW)),
          'count': math.max(1, doorsCount) * quantity,
          'hasGrain': true,
          'edgeL1': true,
          'edgeL2': true,
          'edgeW1': true,
          'edgeW2': true,
          'formula': 'ارتفاع الضلفة السفلية (${_fmt(lowerDoorHeightCm)}) - خصم (${_fmt(handleDeduct + gap)}) = ${_fmt(lDoorH)} سم × عرض (${_fmt(lDoorW)} سم)',
        });
      }

      final double remainingTopH = math.max(0.0, innerH - usedAppliancesH);
      if (remainingTopH > 12.0 && doorsCount > 0 && !glassDoors) {
        final double uDoorH = math.max(5.0, remainingTopH - gap);
        final double uDoorW = math.max(5.0, ((isInset ? innerW : width) / math.max(1, doorsCount)) - gap);
        parts.add({
          'partName': 'ضلفة علوية فوق الأجهزة (#$unitNumber)',
          'material': doorMaterial,
          'width': double.parse(_fmt(uDoorH)),
          'height': double.parse(_fmt(uDoorW)),
          'count': math.max(1, doorsCount) * quantity,
          'hasGrain': true,
          'edgeL1': true,
          'edgeL2': true,
          'edgeW1': true,
          'edgeW2': true,
          'formula': 'المتبقي من الارتفاع (${_fmt(remainingTopH)}) - خلوص (${_fmt(gap)}) = ${_fmt(uDoorH)} سم × عرض (${_fmt(uDoorW)} سم)',
        });
      }

      if (backMaterial != BackMaterial.none) {
        final String backMatName = backMaterial == BackMaterial.plywoodGrooved
            ? "أبلكاش مفحار (4 مم)"
            : carcassMaterial;
        parts.add({
          'partName': 'ظهر وحدة أجهزة (#$unitNumber)',
          'material': backMatName,
          'width': double.parse(_fmt(innerW)),
          'height': double.parse(_fmt(innerH)),
          'count': 1 * quantity,
          'hasGrain': backMaterial != BackMaterial.plywoodGrooved,
          'edgeL1': false,
          'edgeL2': false,
          'edgeW1': false,
          'edgeW2': false,
          'formula': 'صافي عرض (${_fmt(innerW)} سم) × صافي ارتفاع (${_fmt(innerH)} سم)',
        });
      }
      return parts;
    }

    // 4. صفاية / مطبقية
    if (preset.kind == UnitTemplateKind.dishRack) {
      parts.add({
        'partName': 'جنب صفاية / مطبقية (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(depth)),
        'height': double.parse(_fmt(height)),
        'count': 2 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق (${_fmt(depth)} سم) × ارتفاع (${_fmt(height)} سم)',
      });

      parts.add({
        'partName': 'قاعدة وسقف صفاية (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(depth)),
        'height': double.parse(_fmt(innerW)),
        'count': 2 * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق (${_fmt(depth)} سم) × صافي عرض (${_fmt(innerW)} سم)',
      });

      final int rackCount = math.max(1, shelvesCount);
      parts.add({
        'partName': 'رف / فاصل مطبقية (#$unitNumber)',
        'material': carcassMaterial,
        'width': double.parse(_fmt(math.max(10.0, depth - 3.0))),
        'height': double.parse(_fmt(math.max(5.0, innerW - 0.4))),
        'count': rackCount * quantity,
        'hasGrain': true,
        'edgeL1': true,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'عمق (${_fmt(depth)} - 3.0) × صافي عرض (${_fmt(innerW)} - 0.4)',
      });

      if (doorsCount > 0 && !glassDoors) {
        final double handleDeduct =
            (handleType == HandleType.builtIn) ? math.max(0.0, gProfileDeductCm) : 0.0;
        final double doorH = math.max(5.0, (isInset ? innerH : height) - handleDeduct - gap);
        final double doorW = math.max(5.0, ((isInset ? innerW : width) / doorsCount) - gap);
        parts.add({
          'partName': 'ضلفة صفاية (#$unitNumber)',
          'material': doorMaterial,
          'width': double.parse(_fmt(doorH)),
          'height': double.parse(_fmt(doorW)),
          'count': doorsCount * quantity,
          'hasGrain': true,
          'edgeL1': true,
          'edgeL2': true,
          'edgeW1': true,
          'edgeW2': true,
          'formula': 'ارتفاع (${_fmt(doorH)} سم) × عرض (${_fmt(doorW)} سم)',
        });
      }
      return parts;
    }

    // 5. مكتب مفتوح
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

    // 6. الوحدات القياسية والعلوية (بما فيها علوي ضلف)
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
      final double shelfW = math.max(0.0, depth - 2.5);
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
        'formula': 'عمق (${_fmt(depth)} - 2.5 = ${_fmt(shelfW)}) × فتحة (${_fmt(sectionW)} - 0.2 = ${_fmt(shelfH)})',
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
      final String backMatName = backMaterial == BackMaterial.plywoodGrooved
          ? "أبلكاش مفحار (4 مم)"
          : carcassMaterial;
      parts.add({
        'partName': 'ظهر وحدة (#$unitNumber)',
        'material': backMatName,
        'width': double.parse(_fmt(innerW)),
        'height': double.parse(_fmt(innerH)),
        'count': 1 * quantity,
        'hasGrain': backMaterial != BackMaterial.plywoodGrooved,
        'edgeL1': false,
        'edgeL2': false,
        'edgeW1': false,
        'edgeW2': false,
        'formula': 'صافي عرض (${_fmt(innerW)} سم) × صافي ارتفاع (${_fmt(innerH)} سم)',
      });
    }

    return parts;
  }
}