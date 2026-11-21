// ignore_for_file: unnecessary_underscores, deprecated_member_use

import 'package:flutter/material.dart';
import '../models/unit_model.dart';
import '../widgets/isometric_unit_painter.dart';
import '../models/custom_cabinet_node.dart';
import 'custom_cabinet_designer_screen.dart';
import '../engine/nesting_engine.dart';
import 'cutting_results_screen.dart';

class ProjectHomeScreen extends StatefulWidget {
  const ProjectHomeScreen({super.key});

  @override
  State<ProjectHomeScreen> createState() => _ProjectHomeScreenState();
}

class _ProjectHomeScreenState extends State<ProjectHomeScreen> {
  MainCategory _selectedCategory = MainCategory.kitchenBase;
  final List<ConfiguredUnit> _projectUnits = [];
  final List<CustomCabinetDesign> _customDesigns = [];

  final TextEditingController _projectNameCtrl = TextEditingController(text: "مشروع جديد");
  final TextEditingController _clientNameCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _projectNameCtrl.dispose();
    _clientNameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _getCategoryTitle(MainCategory cat) {
    switch (cat) {
      case MainCategory.kitchenBase:
        return "وحدات أرضية";
      case MainCategory.kitchenWall:
        return "وحدات علوية ودواليب";
      case MainCategory.wardrobe:
        return "دواليب غرف";
      case MainCategory.dressing:
        return "دريسنج روم";
      case MainCategory.office:
        return "مكاتب ومكتبات";
      case MainCategory.bedroomAndLiving:
        return "غرف نوم وريسبشن";
    }
  }

  IconData _getCategoryIcon(MainCategory cat) {
    switch (cat) {
      case MainCategory.kitchenBase:
        return Icons.countertops_outlined;
      case MainCategory.kitchenWall:
        return Icons.kitchen_outlined;
      case MainCategory.wardrobe:
        return Icons.door_sliding_outlined;
      case MainCategory.dressing:
        return Icons.checkroom_outlined;
      case MainCategory.office:
        return Icons.desk_outlined;
      case MainCategory.bedroomAndLiving:
        return Icons.weekend_outlined;
    }
  }

  Widget _buildUnitPreviewBox(ConfiguredUnit unit, {required double height}) {
    final bool isWallHanging = unit.preset.category == MainCategory.kitchenWall &&
        unit.preset.kind != UnitTemplateKind.applianceTower &&
        unit.preset.id != 'kw_tall';

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size(double.infinity, height),
            painter: IsometricUnitPainter(unit: unit),
          ),
          if (isWallHanging)
            const Positioned(
              top: 8,
              left: 12,
              child: Text(
                "وحدة معلقة على الحائط",
                style: TextStyle(
                  color: Color(0xFF0F766E),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Positioned(
            bottom: 8,
            right: 12,
            child: Text(
              "معاينة هندسية حية (3D)",
              style: TextStyle(
                color: Color(0xFF14B8A6),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openUnitConfigurator(UnitPreset preset) {
    int qty = 1;
    double w = preset.defaultW;
    double w2 = preset.defaultW2;
    double h = preset.defaultH;
    double d = preset.defaultD;
    double d2 = preset.defaultD2;
    int shelves = preset.defaultShelves;
    int doors = preset.defaultDoors;
    int drawers = preset.defaultDrawers;
    double drawerH = preset.defaultDrawerH;
    int innerDrawers = preset.defaultInnerDrawers;
    double innerDrawerH = preset.defaultInnerDrawerH;
    double lowerDoorH = preset.defaultLowerDoorH;
    double ovenH = preset.defaultOvenH;
    double microwaveH = preset.defaultMicrowaveH;
    double hoodH = preset.defaultHoodH;

    HandleType handle = HandleType.builtIn;
    FrontMountType frontMount = FrontMountType.fullOverlay;
    DummySide dummy = DummySide.none;
    BackMaterial backMat = BackMaterial.plywoodGrooved;
    bool glassDoors = false;
    bool glassShelves = false;
    double boardThickness = 1.8;
    double clearance = 0.3;
    double gProfileDeduct = 3.5;
    const String carcassMat = "شاسيه أبيض";
    const String doorMat = "لون الضلفة الأساسي";

    final wCtrl = TextEditingController(text: w.toStringAsFixed(0));
    final w2Ctrl = TextEditingController(text: w2.toStringAsFixed(0));
    final hCtrl = TextEditingController(text: h.toStringAsFixed(0));
    final dCtrl = TextEditingController(text: d.toStringAsFixed(0));
    final d2Ctrl = TextEditingController(text: d2.toStringAsFixed(0));
    final drawerHCtrl = TextEditingController(text: drawerH.toStringAsFixed(0));
    final innerDrawersCtrl = TextEditingController(text: innerDrawers.toString());
    final innerDrawerHCtrl = TextEditingController(text: innerDrawerH.toStringAsFixed(0));
    final lowerDoorHCtrl = TextEditingController(text: lowerDoorH.toStringAsFixed(0));
    final ovenHCtrl = TextEditingController(text: ovenH.toStringAsFixed(0));
    final microwaveHCtrl = TextEditingController(text: microwaveH.toStringAsFixed(0));
    final hoodHCtrl = TextEditingController(text: hoodH.toStringAsFixed(0));
    final thickCtrl = TextEditingController(text: boardThickness.toString());
    final clearanceCtrl = TextEditingController(text: clearance.toString());
    final gProfileCtrl = TextEditingController(text: gProfileDeduct.toString());

    void disposeDialogCtrls() {
      for (final c in [
        wCtrl,
        w2Ctrl,
        hCtrl,
        dCtrl,
        d2Ctrl,
        drawerHCtrl,
        innerDrawersCtrl,
        innerDrawerHCtrl,
        lowerDoorHCtrl,
        ovenHCtrl,
        microwaveHCtrl,
        hoodHCtrl,
        thickCtrl,
        clearanceCtrl,
        gProfileCtrl,
      ]) {
        c.dispose();
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final previewUnit = ConfiguredUnit(
            preset: preset,
            quantity: qty,
            width: w,
            width2: w2,
            height: h,
            depth: d,
            depth2: d2,
            shelvesCount: shelves,
            doorsCount: doors,
            drawersCount: drawers,
            drawerHeightCm: drawerH,
            innerDrawersCount: innerDrawers,
            innerDrawerHeightCm: innerDrawerH,
            lowerDoorHeightCm: lowerDoorH,
            ovenHeightCm: ovenH,
            microwaveHeightCm: microwaveH,
            hoodHeightCm: hoodH,
            handleType: handle,
            frontMount: frontMount,
            carcassMaterial: carcassMat,
            doorMaterial: doorMat,
            dummySide: dummy,
            backMaterial: backMat,
            glassDoors: glassDoors,
            glassShelves: glassShelves,
            boardThickness: boardThickness,
            clearanceCm: clearance,
            gProfileDeductCm: gProfileDeduct,
          );

          final bool isCorner = preset.kind == UnitTemplateKind.cornerL || preset.isCornerL;
          final bool isDrawers = preset.kind == UnitTemplateKind.drawersLower;
          final bool isAppliance = preset.kind == UnitTemplateKind.applianceTower;

          return Dialog(
            backgroundColor: const Color(0xFF161F30),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 680,
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "إنشاء وحدة: ${preset.name}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () {
                          disposeDialogCtrls();
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUnitPreviewBox(previewUnit, height: 210),
                          const SizedBox(height: 16),
                          if (isCorner) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNumberInput("العرض 1 (سم)", wCtrl, (val) {
                                    setDialogState(() => w = double.tryParse(val) ?? w);
                                  }),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildNumberInput("العرض 2 (سم)", w2Ctrl, (val) {
                                    setDialogState(() => w2 = double.tryParse(val) ?? w2);
                                  }),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildNumberInput("الارتفاع (سم)", hCtrl, (val) {
                                    setDialogState(() => h = double.tryParse(val) ?? h);
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNumberInput("العمق 1 (سم)", dCtrl, (val) {
                                    setDialogState(() => d = double.tryParse(val) ?? d);
                                  }),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildNumberInput("العمق 2 (سم - اختياري)", d2Ctrl, (val) {
                                    setDialogState(() => d2 = double.tryParse(val) ?? d2);
                                  }),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNumberInput("العرض (سم)", wCtrl, (val) {
                                    setDialogState(() => w = double.tryParse(val) ?? w);
                                  }),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildNumberInput("الارتفاع (سم)", hCtrl, (val) {
                                    setDialogState(() => h = double.tryParse(val) ?? h);
                                  }),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildNumberInput("العمق (سم)", dCtrl, (val) {
                                    setDialogState(() => d = double.tryParse(val) ?? d);
                                  }),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildCounter("الكمية", qty, (v) => setDialogState(() => qty = v), min: 1)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildCounter("الأرفف", shelves, (v) => setDialogState(() => shelves = v))),
                              const SizedBox(width: 8),
                              Expanded(child: _buildCounter("الضلف", doors, (v) => setDialogState(() => doors = v))),
                              const SizedBox(width: 8),
                              Expanded(child: _buildCounter("الأدراج", drawers, (v) => setDialogState(() => drawers = v))),
                            ],
                          ),
                          if (isDrawers) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNumberInput("ارتفاع الدرج (سم)", drawerHCtrl, (val) {
                                    setDialogState(() => drawerH = double.tryParse(val) ?? drawerH);
                                  }),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildNumberInput("عدد الأدراج المخفية", innerDrawersCtrl, (val) {
                                    setDialogState(() => innerDrawers = int.tryParse(val) ?? innerDrawers);
                                  }),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildNumberInput("ارتفاع الدرج المخفي (سم)", innerDrawerHCtrl, (val) {
                                    setDialogState(() => innerDrawerH = double.tryParse(val) ?? innerDrawerH);
                                  }),
                                ),
                              ],
                            ),
                          ],
                          if (isAppliance) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNumberInput("ارتفاع الضلفة السفلية (سم)", lowerDoorHCtrl, (val) {
                                    setDialogState(() => lowerDoorH = double.tryParse(val) ?? lowerDoorH);
                                  }),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildNumberInput("ارتفاع الفرن (سم)", ovenHCtrl, (val) {
                                    setDialogState(() => ovenH = double.tryParse(val) ?? ovenH);
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNumberInput("ارتفاع الميكروويف (سم)", microwaveHCtrl, (val) {
                                    setDialogState(() => microwaveH = double.tryParse(val) ?? microwaveH);
                                  }),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildNumberInput("ارتفاع الشفاط (سم)", hoodHCtrl, (val) {
                                    setDialogState(() => hoodH = double.tryParse(val) ?? hoodH);
                                  }),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown<HandleType>(
                                  label: "نوع المقبض",
                                  value: handle,
                                  items: const [
                                    DropdownMenuItem(value: HandleType.builtIn, child: Text("مقبض بيلت إن (G-Profile)")),
                                    DropdownMenuItem(value: HandleType.external, child: Text("مقبض خارجي (لطش)")),
                                    DropdownMenuItem(value: HandleType.pushToOpen, child: Text("تاتش (بدون مقبض)")),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) setDialogState(() => handle = v);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDropdown<DummySide>(
                                  label: "جنب عيرة (Dummy Side)",
                                  value: dummy,
                                  items: const [
                                    DropdownMenuItem(value: DummySide.none, child: Text("بدون جنب عيرة")),
                                    DropdownMenuItem(value: DummySide.right, child: Text("جنب يمين")),
                                    DropdownMenuItem(value: DummySide.left, child: Text("جنب شمال")),
                                    DropdownMenuItem(value: DummySide.both, child: Text("الجانبين (يمين وشمال)")),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) setDialogState(() => dummy = v);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown<BackMaterial>(
                                  label: "خامة الظهر",
                                  value: backMat,
                                  items: const [
                                    DropdownMenuItem(
                                        value: BackMaterial.plywoodGrooved, child: Text("أبلكاش مفحار (4 مم)")),
                                    DropdownMenuItem(
                                        value: BackMaterial.sameAsCarcass, child: Text("نفس خامة الشاسيه")),
                                    DropdownMenuItem(value: BackMaterial.none, child: Text("بدون ظهر")),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) setDialogState(() => backMat = v);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildNumberInput("تخانة اللوح (سم - مثلاً 1.8 أو 2)", thickCtrl, (val) {
                                  final parsed = double.tryParse(val);
                                  if (parsed != null && parsed > 0) {
                                    setDialogState(() => boardThickness = parsed);
                                  }
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDropdown<FrontMountType>(
                            label: "نظام تركيب الضلف ووشوش الأدراج",
                            value: frontMount,
                            items: const [
                              DropdownMenuItem(
                                value: FrontMountType.fullOverlay,
                                child: Text("لطش خارجي (يغطي تخانة الجنبين - عرض كامل)"),
                              ),
                              DropdownMenuItem(
                                value: FrontMountType.inset,
                                child: Text("غاطس داخلي (بين الجنبين - يخصم تخانة الجنبين)"),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) setDialogState(() => frontMount = v);
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildNumberInput("الخلوص (سم - 0 أو رقم)", clearanceCtrl, (val) {
                                  setDialogState(() {
                                    clearance = double.tryParse(val) ?? clearance;
                                  });
                                }),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildNumberInput("خصم عود البيلت إن (سم)", gProfileCtrl, (val) {
                                  setDialogState(() {
                                    gProfileDeduct = double.tryParse(val) ?? gProfileDeduct;
                                  });
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SwitchListTile(
                                  title: const Text("ضلف زجاج", style: TextStyle(fontSize: 13)),
                                  value: glassDoors,
                                  activeTrackColor: const Color(0xFF14B8A6),
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (v) => setDialogState(() => glassDoors = v),
                                ),
                              ),
                              Expanded(
                                child: SwitchListTile(
                                  title: const Text("أرفف زجاج", style: TextStyle(fontSize: 13)),
                                  value: glassShelves,
                                  activeTrackColor: const Color(0xFF14B8A6),
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (v) => setDialogState(() => glassShelves = v),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _projectUnits.add(previewUnit);
                            });
                            disposeDialogCtrls();
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.check_circle_outline, color: Colors.black),
                          label: const Text(
                            "إضافة الوحدة للمشروع",
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2DD4BF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            disposeDialogCtrls();
                            Navigator.pop(ctx);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("إلغاء", style: TextStyle(color: Colors.white70)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String query = _searchQuery.trim().toLowerCase();
    final List<UnitPreset> filteredPresets = query.isNotEmpty
        ? FurnitureCatalog.allPresets.where((p) {
            final catTitle = _getCategoryTitle(p.category).toLowerCase();
            return p.name.toLowerCase().contains(query) || catTitle.contains(query);
          }).toList()
        : FurnitureCatalog.allPresets.where((p) => p.category == _selectedCategory).toList();

    final int totalItemsCount = _projectUnits.length + _customDesigns.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("شركة الإسراء - مصمم الوحدات والتقطيع الذكي"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<CustomCabinetDesign>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomCabinetDesignerScreen(),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _customDesigns.add(result);
                  });
                }
              },
              icon: const Icon(Icons.dashboard_customize, color: Color(0xFF2DD4BF), size: 18),
              label: const Text(
                "مصمم حر (تفاعلي)",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF14B8A6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          if (totalItemsCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _showCutListPreview,
                icon: const Icon(Icons.table_chart_outlined, color: Colors.black, size: 18),
                label: Text(
                  "توليد الـ Cut List ($totalItemsCount وحدات)",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DD4BF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 260,
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("بيانات المشروع", style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: _projectNameCtrl,
                  decoration: InputDecoration(
                    labelText: "اسم المشروع",
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _clientNameCtrl,
                  decoration: InputDecoration(
                    labelText: "اسم العميل",
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const Divider(height: 24, color: Colors.white12),
                const Text("اختر نوع الأثاث", style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: MainCategory.values.map((cat) {
                      final bool isSelected = query.isEmpty && _selectedCategory == cat;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF14B8A6).withValues(alpha: 0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF14B8A6) : Colors.transparent,
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            _getCategoryIcon(cat),
                            color: isSelected ? const Color(0xFF2DD4BF) : Colors.white60,
                          ),
                          title: Text(
                            _getCategoryTitle(cat),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _searchCtrl.clear();
                              _searchQuery = "";
                              _selectedCategory = cat;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          query.isNotEmpty
                              ? "نتائج البحث عن: \"$_searchQuery\" (${filteredPresets.length})"
                              : "اختر تصميم الوحدة - ${_getCategoryTitle(_selectedCategory)} (${filteredPresets.length})",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 280,
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: "ابحث عن أي وحدة (ركنة، أجهزة، صفاية...)",
                            hintStyle: const TextStyle(fontSize: 12, color: Colors.white38),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF2DD4BF), size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() => _searchQuery = "");
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFF1E293B),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredPresets.isEmpty
                        ? const Center(
                            child: Text(
                              "لا توجد وحدات مطابقة للبحث",
                              style: TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 250,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: filteredPresets.length,
                            itemBuilder: (context, index) {
                              final preset = filteredPresets[index];
                              final sampleUnit = ConfiguredUnit(
                                preset: preset,
                                width: preset.defaultW,
                                height: preset.defaultH,
                                depth: preset.defaultD,
                                shelvesCount: preset.defaultShelves,
                                doorsCount: preset.defaultDoors,
                                drawersCount: preset.defaultDrawers,
                              );

                              return InkWell(
                                onTap: () => _openUnitConfigurator(preset),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.all(10),
                                          child: _buildUnitPreviewBox(sampleUnit, height: double.infinity),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                                        child: Column(
                                          children: [
                                            Text(
                                              preset.name,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              (preset.kind == UnitTemplateKind.cornerL || preset.isCornerL)
                                                  ? "${preset.defaultW.toInt()}×${preset.defaultW2.toInt()}×${preset.defaultH.toInt()} سم"
                                                  : "${preset.defaultW.toInt()} × ${preset.defaultH.toInt()} × ${preset.defaultD.toInt()} سم",
                                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 300,
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("وحدات المشروع", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: const Color(0xFF14B8A6),
                      child: Text(
                        "$totalItemsCount",
                        style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Colors.white12),
                Expanded(
                  child: totalItemsCount == 0
                      ? const Center(
                          child: Text(
                            "اضغط على أي وحدة لإضافتها\nأو استخدم المصمم الحر التفاعلي",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white38, fontSize: 13),
                          ),
                        )
                      : ListView(
                          children: [
                            ...List.generate(_projectUnits.length, (index) {
                              final u = _projectUnits[index];
                              return Card(
                                color: const Color(0xFF1E293B),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  onTap: () => _showConfiguredUnitDetails(u, index + 1),
                                  title: Text(
                                    "#${index + 1} ${u.preset.name}",
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    "مقاس: ${u.width.toInt()}×${u.height.toInt()}×${u.depth.toInt()} | عدد: ${u.quantity}",
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF2DD4BF)),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () => setState(() => _projectUnits.removeAt(index)),
                                  ),
                                ),
                              );
                            }),
                            ...List.generate(_customDesigns.length, (index) {
                              final custom = _customDesigns[index];
                              final displayNum = _projectUnits.length + index + 1;
                              return Card(
                                color: const Color(0xFF1E293B),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Color(0xFF14B8A6), width: 0.7),
                                ),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  onTap: () => _showCustomDesignDetails(custom, displayNum),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "#$displayNum ${custom.name}",
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF14B8A6).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          "تصميم حر",
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF2DD4BF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    "مقاس: ${custom.width.toInt()}×${custom.height.toInt()}×${custom.depth.toInt()} سم",
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF2DD4BF)),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () => setState(() => _customDesigns.removeAt(index)),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCutListPreview() {
    String carcassMat = "كونتر ساندوتش 18 مم";
    String shelfMat = "كونتر ساندوتش 18 مم";
    String doorMat = "HPL ضلف 18 مم";
    String backMat = "أبلكاش مفحار (4 مم)";
    final sheetLCtrl = TextEditingController(text: "244");
    final sheetWCtrl = TextEditingController(text: "122");
    final kerfCtrl = TextEditingController(text: "0.4");
    bool ignoreGrain = false;

    void disposeCutCtrls() {
      sheetLCtrl.dispose();
      sheetWCtrl.dispose();
      kerfCtrl.dispose();
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161F30),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.layers, color: Color(0xFF2DD4BF)),
                SizedBox(width: 8),
                Text(
                  "تحديد خامات المشروع ومقاس اللوح قبل التقطيع",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDropdown<String>(
                      label: "خامة الشاسيه (الأجناب والقاعدة والسقف والقواطيع)",
                      value: carcassMat,
                      items: const [
                        DropdownMenuItem(value: "كونتر ساندوتش 18 مم", child: Text("كونتر ساندوتش 18 مم")),
                        DropdownMenuItem(value: "MDF أبيض 18 مم", child: Text("MDF أبيض 18 مم")),
                        DropdownMenuItem(value: "خشب كونتر طبيعي 18 مم", child: Text("خشب كونتر طبيعي 18 مم")),
                      ],
                      onChanged: (v) {
                        if (v != null) setDlgState(() => carcassMat = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDropdown<String>(
                      label: "خامة الأرفف الداخلية",
                      value: shelfMat,
                      items: const [
                        DropdownMenuItem(value: "كونتر ساندوتش 18 مم", child: Text("كونتر ساندوتش 18 مم")),
                        DropdownMenuItem(value: "MDF أبيض 18 مم", child: Text("MDF أبيض 18 مم")),
                        DropdownMenuItem(value: "HPL أرفف 18 مم", child: Text("HPL أرفف 18 مم")),
                      ],
                      onChanged: (v) {
                        if (v != null) setDlgState(() => shelfMat = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDropdown<String>(
                      label: "خامة الضلف ووشوش الأدراج",
                      value: doorMat,
                      items: const [
                        DropdownMenuItem(value: "HPL ضلف 18 مم", child: Text("HPL ضلف 18 مم")),
                        DropdownMenuItem(value: "بولي لاك / أكريليك 18 مم", child: Text("بولي لاك / أكريليك 18 مم")),
                        DropdownMenuItem(value: "قشرة أرو / زان 18 مم", child: Text("قشرة أرو / زان 18 مم")),
                        DropdownMenuItem(value: "كونتر ساندوتش 18 مم", child: Text("نفس خامة الكونتر الساندوتش")),
                      ],
                      onChanged: (v) {
                        if (v != null) setDlgState(() => doorMat = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildDropdown<String>(
                      label: "خامة الظهر (المفحار)",
                      value: backMat,
                      items: const [
                        DropdownMenuItem(
                            value: "أبلكاش مفحار (4 مم)", child: Text("أبلكاش مفحار (4 مم) - لوح مستقل")),
                        DropdownMenuItem(value: "MDF ظهر 6 مم", child: Text("MDF ظهر 6 مم - لوح مستقل")),
                      ],
                      onChanged: (v) {
                        if (v != null) setDlgState(() => backMat = v);
                      },
                    ),
                    const Divider(height: 24, color: Colors.white12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberInput("طول اللوح (سم)", sheetLCtrl, (_) {}),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildNumberInput("عرض اللوح (سم)", sheetWCtrl, (_) {}),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildNumberInput("سلاح المنشار (سم)", kerfCtrl, (_) {}),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text(
                        "السماح بتدوير القطع لتقليل الهالك (تجاهل اتجاه الثمرة)",
                        style: TextStyle(fontSize: 12),
                      ),
                      value: ignoreGrain,
                      activeTrackColor: const Color(0xFF14B8A6),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setDlgState(() => ignoreGrain = v),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  disposeCutCtrls();
                  Navigator.pop(ctx);
                },
                child: const Text("إلغاء", style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DD4BF),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                onPressed: () {
                  final List<Map<String, dynamic>> rawCutList = [];
                  int unitIndex = 1;

                  for (final u in _projectUnits) {
                    final oldCarcass = u.carcassMaterial;
                    final oldDoor = u.doorMaterial;
                    u.carcassMaterial = carcassMat;
                    u.doorMaterial = doorMat;

                    final parts = u.generateCutList(unitIndex++);
                    for (final p in parts) {
                      final pName = p['partName'] as String;
                      if (pName.startsWith('رف داخلي') || pName.startsWith('رف / فاصل')) {
                        p['material'] = shelfMat;
                      } else if (pName.startsWith('ظهر')) {
                        p['material'] = backMat;
                      }
                    }
                    rawCutList.addAll(parts);

                    u.carcassMaterial = oldCarcass;
                    u.doorMaterial = oldDoor;
                  }

                  for (final custom in _customDesigns) {
                    custom.carcassMaterial = carcassMat;
                    custom.shelfMaterial = shelfMat;
                    custom.doorMaterial = doorMat;
                    final parts = custom.generateCutList(unitIndex++);
                    for (final p in parts) {
                      if ((p['partName'] as String).startsWith('ظهر')) {
                        p['material'] = backMat;
                      }
                    }
                    rawCutList.addAll(parts);
                  }

                  final engine = NestingEngine(
                    sheetLength: double.tryParse(sheetLCtrl.text) ?? 244.0,
                    sheetWidth: double.tryParse(sheetWCtrl.text) ?? 122.0,
                    kerf: double.tryParse(kerfCtrl.text) ?? 0.4,
                    ignoreGrainRotation: ignoreGrain,
                  );

                  final pieces = NestingEngine.expandCutList(rawCutList);
                  final nestingResult = engine.optimize(pieces);

                  disposeCutCtrls();
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CuttingResultsScreen(
                        projectName: _projectNameCtrl.text.trim().isEmpty
                            ? "مشروع جديد"
                            : _projectNameCtrl.text.trim(),
                        clientName: _clientNameCtrl.text.trim(),
                        result: nestingResult,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome, color: Colors.black),
                label: const Text(
                  "توليد الألواح والـ Cut List",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNumberInput(String label, TextEditingController ctrl, Function(String) onChanged) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildCounter(String label, int val, Function(int) onChanged, {int min = 0}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: val > min ? () => onChanged(val - 1) : null,
                child: Icon(Icons.remove_circle_outline, size: 20, color: val > min ? Colors.white : Colors.white24),
              ),
              Text("$val", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              InkWell(
                onTap: () => onChanged(val + 1),
                child: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF2DD4BF)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFF0F172A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }

  void _showConfiguredUnitDetails(ConfiguredUnit unit, int unitNumber) {
    final thickEditCtrl = TextEditingController(text: unit.boardThickness.toString());
    int? expandedPartIndex;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final currentParts = unit.generateCutList(unitNumber);
          return Dialog(
            backgroundColor: const Color(0xFF161F30),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: 720,
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "تفاصيل الوحدة #$unitNumber: ${unit.preset.name}",
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () {
                          thickEditCtrl.dispose();
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _infoPill("الأبعاد: ${unit.width.toStringAsFixed(0)} × ${unit.height.toStringAsFixed(0)} × ${unit.depth.toStringAsFixed(0)} سم"),
                      _infoPill("التخانة: ${unit.boardThickness} سم"),
                      _infoPill("الأرفف: ${unit.shelvesCount} | الضلف: ${unit.doorsCount} | الأدراج: ${unit.drawersCount}"),
                      _infoPill("إجمالي البنود: ${currentParts.length}"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("عدد الوحدات (الكمية):", style: TextStyle(fontSize: 13, color: Colors.white70)),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: unit.quantity > 1
                            ? () {
                                setDlgState(() => unit.quantity--);
                                setState(() {});
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text("${unit.quantity}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                        onPressed: () {
                          setDlgState(() => unit.quantity++);
                          setState(() {});
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2DD4BF)),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 195,
                        child: _buildNumberInput("تعديل التخانة لحظياً (سم)", thickEditCtrl, (val) {
                          final parsed = double.tryParse(val);
                          if (parsed != null && parsed > 0) {
                            setDlgState(() => unit.boardThickness = parsed);
                            setState(() {});
                          }
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "قطع التقطيع الخاصة بهذه الوحدة (اضغط على أي مقاس لعرض طريقة حسابه):",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2DD4BF), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: currentParts.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
                      itemBuilder: (_, idx) {
                        final isExpanded = expandedPartIndex == idx;
                        return _buildPartDetailTile(
                          currentParts[idx],
                          isExpanded: isExpanded,
                          onTap: () {
                            setDlgState(() {
                              expandedPartIndex = isExpanded ? null : idx;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCustomDesignDetails(CustomCabinetDesign custom, int unitNumber) {
    final parts = custom.generateCutList(unitNumber);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF161F30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 680,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "تفاصيل الوحدة #$unitNumber (تصميم حر): ${custom.name}",
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _infoPill("الأبعاد: ${custom.width.toStringAsFixed(0)} × ${custom.height.toStringAsFixed(0)} × ${custom.depth.toStringAsFixed(0)} سم"),
                  _infoPill("الوزرة: ${custom.plinthHeight.toStringAsFixed(0)} سم | التخانه: ${custom.boardThickness} سم"),
                  _infoPill("الظهر: ${custom.hasBackPanel ? 'مفحار 4 مم' : 'بدون ظهر'}"),
                  _infoPill("إجمالي البنود: ${parts.length}"),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                "قطع التقطيع الخاصة بهذه الوحدة:",
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2DD4BF), fontSize: 14),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: parts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
                  itemBuilder: (_, idx) => _buildPartDetailTile(parts[idx]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70)),
    );
  }

  Widget _buildPartDetailTile(
    Map<String, dynamic> p, {
    bool isExpanded = false,
    VoidCallback? onTap,
  }) {
    final edges = [
      if (p['edgeL1'] == true) 'طول 1',
      if (p['edgeL2'] == true) 'طول 2',
      if (p['edgeW1'] == true) 'عرض 1',
      if (p['edgeW2'] == true) 'عرض 2',
    ];
    final edgeStr = edges.isEmpty ? 'بدون قشاط' : 'قشاط: ${edges.join(' • ')}';
    final grainStr = (p['hasGrain'] == true) ? 'مع الثمرة' : 'بدون ثمرة';
    final formulaStr = p['formula'] as String?;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${p['partName']}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$edgeStr  |  $grainStr",
                        style: const TextStyle(fontSize: 11, color: Colors.orangeAccent),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${p['width']} × ${p['height']} سم",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2DD4BF), fontSize: 13),
                    ),
                    Text(
                      "العدد: ${p['count']}",
                      style: const TextStyle(fontSize: 11, color: Colors.white60),
                    ),
                  ],
                ),
              ],
            ),
            if (isExpanded && formulaStr != null) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF14B8A6).withValues(alpha: 0.4)),
                ),
                child: Text(
                  "طريقة الحساب: $formulaStr",
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF99F6E4)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}