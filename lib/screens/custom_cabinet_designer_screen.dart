import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/custom_cabinet_node.dart';
import '../widgets/cabinet_color_picker_panel.dart';

class _ZoneHitBox {
  final CabinetZoneNode node;
  final Rect rect;
  final double realW;
  final double realH;

  _ZoneHitBox(this.node, this.rect, this.realW, this.realH);
}

class _DividerHitBox {
  final CabinetZoneNode parentNode;
  final Rect hitRect;
  final Rect parentRect;
  final double usableRealSize;
  final bool isVertical;

  _DividerHitBox({
    required this.parentNode,
    required this.hitRect,
    required this.parentRect,
    required this.usableRealSize,
    required this.isVertical,
  });
}

class _FreeBoardHitBox {
  final FreeBoardPiece board;
  final Rect rect;

  _FreeBoardHitBox(this.board, this.rect);
}

class _Box3D {
  final double x;
  final double y;
  final double z;
  final double w;
  final double h;
  final double d;
  final Color baseColor;
  final Color strokeColor;
  final String colorKey;
  final String partLabel;
  final int layerPriority; // 0: هيكل/ظهر، 1: داخلي/أرفف، 2: ضلف/أدراج، 3: قطع حرة
  final FreeBoardPiece? freeBoard;
  final String? interactiveKey;

  _Box3D({
    required this.x,
    required this.y,
    required this.z,
    required this.w,
    required this.h,
    required this.d,
    required this.baseColor,
    required this.strokeColor,
    required this.colorKey,
    required this.partLabel,
    this.layerPriority = 0,
    this.freeBoard,
    this.interactiveKey,
  });
}

class _Face3D {
  final List<Offset> points;
  final double depthFromCamera;
  final int layerPriority;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final String colorKey;
  final String partLabel;
  final FreeBoardPiece? freeBoard;
  final String? interactiveKey;

  _Face3D({
    required this.points,
    required this.depthFromCamera,
    required this.layerPriority,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.colorKey,
    required this.partLabel,
    this.freeBoard,
    this.interactiveKey,
  });
}

class _InteractiveHit3D {
  final String key;
  final String colorKey;
  final String partLabel;
  final FreeBoardPiece? freeBoard;
  final List<Offset> polygon;
  final double depthFromCamera;

  _InteractiveHit3D({
    required this.key,
    required this.colorKey,
    required this.partLabel,
    this.freeBoard,
    required this.polygon,
    required this.depthFromCamera,
  });
}

class CustomCabinetDesignerScreen extends StatefulWidget {
  const CustomCabinetDesignerScreen({super.key});

  @override
  State<CustomCabinetDesignerScreen> createState() =>
      _CustomCabinetDesignerScreenState();
}

class _CustomCabinetDesignerScreenState
    extends State<CustomCabinetDesignerScreen> {
  CustomCabinetDesign _design = CustomCabinetDesign.wardrobePreset();
  late CabinetZoneNode _selectedNode;
  _DividerHitBox? _draggingDivider;

  // وضع العرض: 2D أو 3D وزوايا الدوران والتكبير والتحكم التفاعلي
  bool _is3DView = false;
  double _yawRad = 0.55;
  double _pitchRad = 0.36;
  double _zoom3D = 1.0;
  Offset? _last3DPanPos;
  Offset? _3DPanDownPos;
  final List<_InteractiveHit3D> _interactive3DHits = [];

  // حالة فتح/قفل الضلف والأدراج + ألوان الأجزاء المستقلة في الـ 3D
  final Set<String> _openedKeys = {};
  double _carcassDepthCm = 52.0;
  double _frontThicknessCm = 1.8;
  String _selected3DColorKey = 'carcass';
  String _selected3DPartLabel = 'الهيكل الخارجي والوزرة';

  late Map<String, Color> _partColors3D;

  // أوضاع الرسم الحر والسنترة والتحريك والمحاذاة الذكية
  bool _drawFreeMode = false;
  FreeBoardKind _newFreeKind = FreeBoardKind.shelf;
  Offset? _freeDrawStart;
  Offset? _freeDrawCurrent;

  FreeBoardPiece? _selectedFreeBoard;
  FreeBoardPiece? _draggingFreeBoard;
  Offset? _dragStartLocal;
  double _dragStartBoardX = 0;
  double _dragStartBoardY = 0;

  bool _snappedCenterX = false;
  bool _snappedCenterY = false;
  double? _snapGuideXCm;
  double? _snapGuideYCm;

  double _lastScale = 1.0;
  double _lastLeft = 0.0;
  double _lastTop = 0.0;

  final List<_ZoneHitBox> _zoneHitBoxes = [];
  final List<_DividerHitBox> _dividerHitBoxes = [];
  final List<_FreeBoardHitBox> _freeBoardHitBoxes = [];

  late TextEditingController _nameCtrl;
  late TextEditingController _wCtrl;
  late TextEditingController _hCtrl;
  late TextEditingController _dCtrl;
  late TextEditingController _plinthCtrl;
  late TextEditingController _carcassDepthCtrl;
  late TextEditingController _boardThickCtrl;
  late TextEditingController _frontThickCtrl;

  @override
  void initState() {
    super.initState();
    _selectedNode = _findFirstLeaf(_design.root);
    _carcassDepthCm = math.max(20.0, _design.depth - 8.0);
    _frontThicknessCm = _design.boardThickness;
    _partColors3D = _defaultColorsMap();
    _syncControllers();
  }

  Map<String, Color> _defaultColorsMap() {
    return {
      'carcass': const Color(0xFFE2E8F0),
      'interior': const Color(0xFFCBD5E1),
      'back': const Color(0xFF94A3B8),
      'front': const Color(0xFFD6A86C),
      'free_default': const Color(0xFFF59E0B),
    };
  }

  Color _colorForKey(String key) {
    return _partColors3D[key] ??
        (key.startsWith('free_')
            ? (_partColors3D['free_default'] ?? const Color(0xFFF59E0B))
            : const Color(0xFFE2E8F0));
  }

  void _syncControllers() {
    _nameCtrl = TextEditingController(text: _design.name);
    _wCtrl = TextEditingController(text: _design.width.toStringAsFixed(0));
    _hCtrl = TextEditingController(text: _design.height.toStringAsFixed(0));
    _dCtrl = TextEditingController(text: _design.depth.toStringAsFixed(0));
    _plinthCtrl =
        TextEditingController(text: _design.plinthHeight.toStringAsFixed(0));
    _carcassDepthCtrl =
        TextEditingController(text: _carcassDepthCm.toStringAsFixed(1));
    _boardThickCtrl =
        TextEditingController(text: _design.boardThickness.toStringAsFixed(1));
    _frontThickCtrl =
        TextEditingController(text: _frontThicknessCm.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _wCtrl.dispose();
    _hCtrl.dispose();
    _dCtrl.dispose();
    _plinthCtrl.dispose();
    _carcassDepthCtrl.dispose();
    _boardThickCtrl.dispose();
    _frontThickCtrl.dispose();
    super.dispose();
  }

  CabinetZoneNode _findFirstLeaf(CabinetZoneNode node) {
    if (node.isLeaf) return node;
    return _findFirstLeaf(node.firstChild!);
  }

  void _loadPreset(CustomCabinetDesign preset) {
    setState(() {
      _design = preset;
      _selectedNode = _findFirstLeaf(_design.root);
      _selectedFreeBoard = null;
      _openedKeys.clear();
      _selected3DColorKey = 'carcass';
      _selected3DPartLabel = 'الهيكل الخارجي والوزرة';
      _carcassDepthCm = math.max(20.0, _design.depth - 8.0);
      _syncControllers();
    });
  }

  CabinetZoneNode? _findParentOf(
      CabinetZoneNode current, CabinetZoneNode target) {
    if (current.isLeaf) return null;
    if (identical(current.firstChild, target) ||
        identical(current.secondChild, target)) {
      return current;
    }
    return _findParentOf(current.firstChild!, target) ??
        _findParentOf(current.secondChild!, target);
  }

  bool _pointInPolygon(Offset pt, List<Offset> poly) {
    if (poly.length < 3) return false;
    bool inside = false;
    for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final xi = poly[i].dx, yi = poly[i].dy;
      final xj = poly[j].dx, yj = poly[j].dy;
      final intersect = ((yi > pt.dy) != (yj > pt.dy)) &&
          (pt.dx <
              (xj - xi) *
                      (pt.dy - yi) /
                      ((yj - yi) == 0 ? 1e-9 : (yj - yi)) +
                  xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  _InteractiveHit3D? _hitTestInteractive3D(Offset pos) {
    final sorted = List<_InteractiveHit3D>.from(_interactive3DHits)
      ..sort((a, b) => b.depthFromCamera.compareTo(a.depthFromCamera));
    for (final item in sorted) {
      if (_pointInPolygon(pos, item.polygon)) {
        return item;
      }
    }
    return null;
  }

  void _toggleOpenCloseAll3D() {
    setState(() {
      if (_openedKeys.isNotEmpty) {
        _openedKeys.clear();
      } else {
        for (final hit in _interactive3DHits) {
          if (hit.key.startsWith("door_") || hit.key.startsWith("drawer_")) {
            _openedKeys.add(hit.key);
          }
        }
      }
    });
  }

  /// محاذاة ذكية مع إطار الوحدة ومنتصفها وحواف القطع الحرة الأخرى
  void _applySmartSnap(FreeBoardPiece board, double nextX, double nextY) {
    const double thresholdCm = 1.5;

    final List<double> candidateXs = [
      0.0,
      _design.width / 2.0,
      _design.width,
    ];
    for (final other in _design.freeBoards) {
      if (identical(other, board)) continue;
      candidateXs.addAll([
        other.x,
        other.x + other.width,
        other.x + (other.width / 2.0),
      ]);
    }

    final List<double> candidateYs = [
      0.0,
      _design.height / 2.0,
      _design.height,
    ];
    for (final other in _design.freeBoards) {
      if (identical(other, board)) continue;
      candidateYs.addAll([
        other.y,
        other.y + other.height,
        other.y + (other.height / 2.0),
      ]);
    }

    double snappedX = nextX;
    double snappedY = nextY;
    double? guideX;
    double? guideY;
    bool centerX = false;
    bool centerY = false;

    final double leftEdge = nextX;
    final double midX = nextX + (board.width / 2.0);
    final double rightEdge = nextX + board.width;

    for (final cx in candidateXs) {
      if ((leftEdge - cx).abs() < thresholdCm) {
        snappedX = cx;
        guideX = cx;
        break;
      }
      if ((rightEdge - cx).abs() < thresholdCm) {
        snappedX = cx - board.width;
        guideX = cx;
        break;
      }
      if ((midX - cx).abs() < thresholdCm) {
        snappedX = cx - (board.width / 2.0);
        guideX = cx;
        if ((cx - (_design.width / 2.0)).abs() < 0.01) centerX = true;
        break;
      }
    }

    final double topEdge = nextY;
    final double midY = nextY + (board.height / 2.0);
    final double bottomEdge = nextY + board.height;

    for (final cy in candidateYs) {
      if ((topEdge - cy).abs() < thresholdCm) {
        snappedY = cy;
        guideY = cy;
        break;
      }
      if ((bottomEdge - cy).abs() < thresholdCm) {
        snappedY = cy - board.height;
        guideY = cy;
        break;
      }
      if ((midY - cy).abs() < thresholdCm) {
        snappedY = cy - (board.height / 2.0);
        guideY = cy;
        if ((cy - (_design.height / 2.0)).abs() < 0.01) centerY = true;
        break;
      }
    }

    board.x = double.parse(snappedX.toStringAsFixed(1));
    board.y = double.parse(snappedY.toStringAsFixed(1));
    _snapGuideXCm = guideX;
    _snapGuideYCm = guideY;
    _snappedCenterX = centerX;
    _snappedCenterY = centerY;
  }

  /// رص وشوش أدراج يدوية متعددة تحت بعضها بالمللي مع الحفاظ على التخانة الثابتة
  void _openStackDrawerFrontsDialog() {
    final double initX = _selectedFreeBoard?.x ?? 10.0;
    final double initY = _selectedFreeBoard?.y ?? 10.0;
    final double initW = _selectedFreeBoard?.width ?? 45.0;
    final double initTotalH =
        (_selectedFreeBoard != null && _selectedFreeBoard!.height > 15.0)
            ? _selectedFreeBoard!.height
            : 48.0;

    final countCtrl = TextEditingController(text: "3");
    final wCtrl = TextEditingController(text: initW.toStringAsFixed(1));
    final totalHCtrl = TextEditingController(text: initTotalH.toStringAsFixed(1));
    final gapCtrl = TextEditingController(text: "0.3");
    final xCtrl = TextEditingController(text: initX.toStringAsFixed(1));
    final yCtrl = TextEditingController(text: initY.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("رص وشوش أدراج يدوي", style: TextStyle(fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: countCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _dialogInput("عدد الأدراج"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: gapCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dialogInput("خلوص بين الأدراج (سم)"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: wCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dialogInput("عرض وش الدرج (سم)"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: totalHCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dialogInput("الارتفاع الكلي للرصّة (سم)"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: xCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dialogInput("بداية X من اليسار (سم)"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: yCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dialogInput("بداية Y من الأعلى (سم)"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DD4BF)),
            onPressed: () {
              final int count = math.max(1, int.tryParse(countCtrl.text) ?? 3);
              final double gap =
                  math.max(0.0, double.tryParse(gapCtrl.text) ?? 0.3);
              final double w =
                  math.max(10.0, double.tryParse(wCtrl.text) ?? initW);
              final double totalH = math.max(
                  12.0, double.tryParse(totalHCtrl.text) ?? initTotalH);
              final double startX = double.tryParse(xCtrl.text) ?? initX;
              final double startY = double.tryParse(yCtrl.text) ?? initY;

              final double totalGaps = gap * (count - 1);
              final double eachH = math.max(4.0, (totalH - totalGaps) / count);

              FreeBoardPiece? lastCreated;
              setState(() {
                for (int i = 0; i < count; i++) {
                  final double pieceY = startY + (i * (eachH + gap));
                  final piece = FreeBoardPiece(
                    id: 'drw_${DateTime.now().microsecondsSinceEpoch}_$i',
                    name: 'وش درج يدوي ${i + 1}/$count',
                    kind: FreeBoardKind.drawerFront,
                    x: double.parse(startX.toStringAsFixed(1)),
                    y: double.parse(pieceY.toStringAsFixed(1)),
                    width: double.parse(w.toStringAsFixed(1)),
                    height: double.parse(eachH.toStringAsFixed(1)),
                    thickness: _frontThicknessCm,
                    hasGrain: true,
                    edgeL1: true,
                    edgeL2: true,
                    edgeW1: true,
                    edgeW2: true,
                  );
                  _design.freeBoards.add(piece);
                  lastCreated = piece;
                }
                _selectedFreeBoard = lastCreated;
              });
              Navigator.pop(ctx);
            },
            child: const Text("رص الأدراج",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _editZoneExactDimension(_ZoneHitBox hit) {
    final parent = _findParentOf(_design.root, hit.node);
    if (parent == null) return;

    final bool isFirst = identical(parent.firstChild, hit.node);
    final bool isVerticalSplit = parent.splitType == SplitType.vertical;
    final double currentVal = isVerticalSplit ? hit.realW : hit.realH;
    final ctrl = TextEditingController(text: currentVal.toStringAsFixed(1));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          isVerticalSplit
              ? "تحديد عرض الفتحة الصافي (سم)"
              : "تحديد ارتفاع الفتحة الصافي (سم)",
          style: const TextStyle(fontSize: 16),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            suffixText: "سم",
            filled: true,
            fillColor: Color(0xFF0F172A),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DD4BF)),
            onPressed: () {
              final double? target = double.tryParse(ctrl.text);
              if (target != null && target > 5) {
                final double totalSpan = isVerticalSplit
                    ? (hit.realW /
                        (isFirst
                            ? parent.splitRatio
                            : (1 - parent.splitRatio)))
                    : (hit.realH /
                        (isFirst
                            ? parent.splitRatio
                            : (1 - parent.splitRatio)));
                if (totalSpan > 10) {
                  final double newRatio = isFirst
                      ? (target / totalSpan)
                      : (1.0 - (target / totalSpan));
                  setState(() {
                    parent.splitRatio = newRatio.clamp(0.10, 0.90);
                  });
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text("تطبيق",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _editFreeBoardDialog(FreeBoardPiece board) {
    final xCtrl = TextEditingController(text: board.x.toStringAsFixed(1));
    final yCtrl = TextEditingController(text: board.y.toStringAsFixed(1));
    final wCtrl = TextEditingController(text: board.width.toStringAsFixed(1));
    final hCtrl = TextEditingController(text: board.height.toStringAsFixed(1));
    final tCtrl = TextEditingController(text: board.thickness.toStringAsFixed(1));
    final nameCtrl = TextEditingController(text: board.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("تعديل أبعاد وموضع القطعة / القرصة",
            style: TextStyle(fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: _dialogInput("اسم القطعة"),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: xCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dialogInput("الموضع X من اليسار (سم)"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: yCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dialogInput("الموضع Y من الأعلى (سم)"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: wCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dialogInput("العرض / الطول الأفقي (سم)"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: hCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dialogInput("الارتفاع الرأسي (سم)"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _dialogInput("تخانة اللوح الثابتة (سم)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DD4BF)),
            onPressed: () {
              setState(() {
                board.name = nameCtrl.text.trim().isEmpty
                    ? board.name
                    : nameCtrl.text.trim();
                board.x = double.tryParse(xCtrl.text) ?? board.x;
                board.y = double.tryParse(yCtrl.text) ?? board.y;
                board.width =
                    math.max(1.0, double.tryParse(wCtrl.text) ?? board.width);
                board.height =
                    math.max(1.0, double.tryParse(hCtrl.text) ?? board.height);
                board.thickness = math.max(
                    0.4, double.tryParse(tCtrl.text) ?? board.thickness);
              });
              Navigator.pop(ctx);
            },
            child: const Text("حفظ",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  InputDecoration _dialogInput(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFF0F172A),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }

  void _createFreeBoardFromDrag(Offset startPx, Offset endPx) {
    if (_lastScale <= 0) return;

    final double minXpx = math.min(startPx.dx, endPx.dx);
    final double maxXpx = math.max(startPx.dx, endPx.dx);
    final double minYpx = math.min(startPx.dy, endPx.dy);
    final double maxYpx = math.max(startPx.dy, endPx.dy);

    double xCm = (minXpx - _lastLeft) / _lastScale;
    double yCm = (minYpx - _lastTop) / _lastScale;
    double wCm = (maxXpx - minXpx) / _lastScale;
    double hCm = (maxYpx - minYpx) / _lastScale;

    if (wCm < 2.0 && hCm < 2.0) return;

    final double fixedT = _design.boardThickness;
    String boardName = "قطعة حرة";

    if (_newFreeKind == FreeBoardKind.shelf) {
      wCm = math.max(10.0, wCm);
      hCm = fixedT;
      boardName = "رف / قرصة حرة (${fixedT.toStringAsFixed(1)} سم)";
    } else if (_newFreeKind == FreeBoardKind.panel) {
      if (wCm >= hCm) {
        wCm = math.max(10.0, wCm);
        hCm = fixedT;
        boardName = "لوح أفقي حر (${fixedT.toStringAsFixed(1)} سم)";
      } else {
        wCm = fixedT;
        hCm = math.max(10.0, hCm);
        boardName = "قاطوع / جنب رأسي (${fixedT.toStringAsFixed(1)} سم)";
      }
    } else if (_newFreeKind == FreeBoardKind.drawerFront) {
      wCm = math.max(15.0, wCm);
      hCm = math.max(8.0, hCm);
      boardName = "وش درج حر";
    } else if (_newFreeKind == FreeBoardKind.door) {
      wCm = math.max(12.0, wCm);
      hCm = math.max(15.0, hCm);
      boardName = "ضلفة حرة / معلقة";
    }

    final newBoard = FreeBoardPiece(
      id: 'fb_${DateTime.now().microsecondsSinceEpoch}',
      name: boardName,
      kind: _newFreeKind,
      x: double.parse(xCm.toStringAsFixed(1)),
      y: double.parse(yCm.toStringAsFixed(1)),
      width: double.parse(wCm.toStringAsFixed(1)),
      height: double.parse(hCm.toStringAsFixed(1)),
      thickness: fixedT,
      hasGrain: true,
      edgeL1: true,
      edgeL2: _newFreeKind == FreeBoardKind.door ||
          _newFreeKind == FreeBoardKind.drawerFront,
      edgeW1: _newFreeKind == FreeBoardKind.door ||
          _newFreeKind == FreeBoardKind.drawerFront,
      edgeW2: _newFreeKind == FreeBoardKind.door ||
          _newFreeKind == FreeBoardKind.drawerFront,
    );

    setState(() {
      _design.freeBoards.add(newBoard);
      _selectedFreeBoard = newBoard;
      _selected3DColorKey = 'free_${newBoard.id}';
      _selected3DPartLabel = newBoard.name;
      _drawFreeMode = false;
      _freeDrawStart = null;
      _freeDrawCurrent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final generatedParts = _design.generateCutList(1);
    final activeColor = _colorForKey(_selected3DColorKey);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "مصمم الوحدات التفاعلي الذكي (2D / 3D سوليد + منع تداخل + عجلة ألوان)"),
        actions: [
          TextButton.icon(
            onPressed: () =>
                _loadPreset(CustomCabinetDesign.wardrobePreset()),
            icon: const Icon(Icons.door_sliding_outlined,
                color: Color(0xFF2DD4BF)),
            label: const Text("قالب دولاب مقسم",
                style: TextStyle(color: Colors.white)),
          ),
          TextButton.icon(
            onPressed: () =>
                _loadPreset(CustomCabinetDesign.openDeskPreset()),
            icon: const Icon(Icons.desk_outlined, color: Color(0xFF2DD4BF)),
            label: const Text("قالب مكتب مفتوح",
                style: TextStyle(color: Colors.white)),
          ),
          TextButton.icon(
            onPressed: () => _loadPreset(CustomCabinetDesign(
              name: "صندوق فارغ للتقسيم",
              width: 120,
              height: 200,
              depth: 60,
            )),
            icon: const Icon(Icons.crop_square, color: Colors.white70),
            label: const Text("صندوق فارغ",
                style: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, _design),
              icon: const Icon(Icons.check, color: Colors.black),
              label: const Text(
                "اعتماد وإضافة للمشروع",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DD4BF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // 1. اللوحة الجانبية
          Container(
            width: 355,
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(
                              child: Text("2D مخطط",
                                  style: TextStyle(fontSize: 12))),
                          selected: !_is3DView,
                          selectedColor: const Color(0xFF14B8A6),
                          onSelected: (_) => setState(() => _is3DView = false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(
                              child: Text("3D مجسم",
                                  style: TextStyle(fontSize: 12))),
                          selected: _is3DView,
                          selectedColor: Colors.amberAccent,
                          onSelected: (_) => setState(() => _is3DView = true),
                        ),
                      ),
                    ],
                  ),
                  if (_is3DView) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _yawRad = 0.55;
                            _pitchRad = 0.36;
                            _zoom3D = 1.0;
                          }),
                          icon: const Icon(Icons.refresh,
                              size: 15, color: Color(0xFF2DD4BF)),
                          label: const Text("إعادة ضبط 3D",
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xFF2DD4BF))),
                        ),
                        ElevatedButton.icon(
                          onPressed: _toggleOpenCloseAll3D,
                          icon: Icon(
                              _openedKeys.isNotEmpty
                                  ? Icons.door_back_door_outlined
                                  : Icons.sensor_door_outlined,
                              size: 15,
                              color: Colors.black),
                          label: Text(
                            _openedKeys.isNotEmpty
                                ? "قفل ضلف/أدراج"
                                : "فتح ضلف/أدراج",
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2DD4BF),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CabinetColorPickerPanel(
                      partLabel: _selected3DPartLabel,
                      currentColor: activeColor,
                      onColorChanged: (newCol) {
                        setState(() {
                          _partColors3D[_selected3DColorKey] = newCol;
                        });
                      },
                      onResetDefault: () {
                        setState(() {
                          _partColors3D = _defaultColorsMap();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _quickPartColorTag("الهيكل", "carcass"),
                        _quickPartColorTag("الجسم الداخلي", "interior"),
                        _quickPartColorTag("الظهر", "back"),
                        _quickPartColorTag("الضلف/أدراج", "front"),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "زوم البكرة: ${(_zoom3D * 100).toInt()}%  •  مفتوح: ${_openedKeys.length} عنصر",
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white60),
                    ),
                  ],

                  const Divider(height: 20, color: Colors.white12),
                  const Text("خيارات المقاسات والهيكل (Component Options)",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2DD4BF))),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameCtrl,
                    onChanged: (v) => _design.name = v,
                    decoration: _inputDeco("اسم الوحدة"),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _wCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(() => _design.width =
                              math.max(30,
                                  double.tryParse(v) ?? _design.width)),
                          decoration: _inputDeco("العرض (سم)"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _hCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(() => _design.height =
                              math.max(30,
                                  double.tryParse(v) ?? _design.height)),
                          decoration: _inputDeco("الارتفاع (سم)"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(() {
                            _design.depth = math.max(
                                20, double.tryParse(v) ?? _design.depth);
                            _carcassDepthCm = math.min(
                                _carcassDepthCm,
                                math.max(15.0, _design.depth - 2.0));
                            _carcassDepthCtrl.text =
                                _carcassDepthCm.toStringAsFixed(1);
                          }),
                          decoration: _inputDeco("العمق الكلي (سم)"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _carcassDepthCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (v) => setState(() {
                            _carcassDepthCm = (double.tryParse(v) ??
                                    _carcassDepthCm)
                                .clamp(15.0, math.max(20.0, _design.depth));
                          }),
                          decoration: _inputDeco("عمق الهيكل (سم)"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _plinthCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (v) => setState(() => _design.plinthHeight =
                              math.max(0, double.tryParse(v) ?? 0)),
                          decoration: _inputDeco("ارتفاع القاعدة/الوزرة"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _boardThickCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          onChanged: (v) => setState(() {
                            _design.boardThickness = math.max(
                                0.6,
                                double.tryParse(v) ??
                                    _design.boardThickness);
                          }),
                          decoration: _inputDeco("سماكة الهيكل (سم)"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _frontThickCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => setState(() {
                      _frontThicknessCm = math.max(
                          0.6, double.tryParse(v) ?? _frontThicknessCm);
                    }),
                    decoration: _inputDeco("سماكة الضلفة / الدرج (سم)"),
                  ),
                  SwitchListTile(
                    title: const Text("إضافة ظهر أبلكاش",
                        style: TextStyle(fontSize: 13)),
                    value: _design.hasBackPanel,
                    activeTrackColor: const Color(0xFF14B8A6),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _design.hasBackPanel = v),
                  ),

                  const Divider(height: 22, color: Colors.white12),
                  const Text("رسم حر ولوحات مستقلة",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _kindChip("رف / قرصة", FreeBoardKind.shelf),
                      _kindChip("لوح / قاطوع", FreeBoardKind.panel),
                      _kindChip("ضلفة معلقة", FreeBoardKind.door),
                      _kindChip("وش درج حر", FreeBoardKind.drawerFront),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _is3DView = false;
                          _drawFreeMode = !_drawFreeMode;
                          _freeDrawStart = null;
                          _freeDrawCurrent = null;
                        });
                      },
                      icon: Icon(
                          _drawFreeMode ? Icons.close : Icons.draw_outlined,
                          color: Colors.black,
                          size: 18),
                      label: Text(
                        _drawFreeMode
                            ? "إلغاء وضع الرسم الحر"
                            : "اسحب لترسم لوح / خط على الوحدة",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _drawFreeMode
                            ? Colors.orangeAccent
                            : Colors.amberAccent,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openStackDrawerFrontsDialog,
                      icon: const Icon(Icons.view_stream,
                          color: Color(0xFF2DD4BF), size: 17),
                      label: const Text("رص وشوش أدراج يدوي",
                          style: TextStyle(
                              color: Color(0xFF2DD4BF), fontSize: 12)),
                    ),
                  ),

                  if (_selectedFreeBoard != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF14B8A6), width: 0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "القطعة / القرصة: ${_selectedFreeBoard!.name}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF2DD4BF)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "المقاس: ${_selectedFreeBoard!.width.toStringAsFixed(1)} × ${_selectedFreeBoard!.height.toStringAsFixed(1)} سم  |  X: ${_selectedFreeBoard!.x.toStringAsFixed(1)}  Y: ${_selectedFreeBoard!.y.toStringAsFixed(1)}",
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() =>
                                      _design.centerFreeBoardHorizontally(
                                          _selectedFreeBoard!)),
                                  child: const Text("سنترة أفقية",
                                      style: TextStyle(fontSize: 11)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() =>
                                      _design.centerFreeBoardVertically(
                                          _selectedFreeBoard!)),
                                  child: const Text("سنترة رأسية",
                                      style: TextStyle(fontSize: 11)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedFreeBoard!.x = double.parse(
                                          (_selectedFreeBoard!.x - 10.0)
                                              .toStringAsFixed(1));
                                      _selectedFreeBoard!.width = double.parse(
                                          (_selectedFreeBoard!.width + 20.0)
                                              .toStringAsFixed(1));
                                    });
                                  },
                                  icon: const Icon(Icons.open_in_full,
                                      size: 14, color: Colors.amberAccent),
                                  label: const Text("قرصة +10 سم",
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.amberAccent)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                tooltip: "تعديل أبعاد وموضع القطعة",
                                icon: const Icon(Icons.edit,
                                    color: Color(0xFF2DD4BF), size: 18),
                                onPressed: () =>
                                    _editFreeBoardDialog(_selectedFreeBoard!),
                              ),
                              IconButton(
                                tooltip: "حذف القطعة",
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _design.freeBoards
                                        .remove(_selectedFreeBoard);
                                    _selectedFreeBoard = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Divider(height: 22, color: Colors.white12),
                  const Text("أدوات الفتحة المحددة على الرسم",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2DD4BF))),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedNode.split(SplitType.vertical);
                              _selectedNode = _selectedNode.firstChild!;
                            });
                          },
                          icon: const Icon(Icons.vertical_split, size: 18),
                          label: const Text("قاطوع رأسي",
                              style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedNode.split(SplitType.horizontal);
                              _selectedNode = _selectedNode.firstChild!;
                            });
                          },
                          icon: const Icon(Icons.horizontal_split, size: 18),
                          label: const Text("رف قاطع أفقي",
                              style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_findParentOf(_design.root, _selectedNode) != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final parent =
                              _findParentOf(_design.root, _selectedNode);
                          if (parent != null) {
                            setState(() {
                              parent.unsplit();
                              _selectedNode = parent;
                            });
                          }
                        },
                        icon: const Icon(Icons.delete_sweep,
                            color: Colors.redAccent, size: 18),
                        label: const Text("حذف آخر قاطوع ودمج الفتحتين",
                            style: TextStyle(
                                color: Colors.redAccent, fontSize: 12)),
                      ),
                    ),

                  const SizedBox(height: 14),
                  const Text("محتوى الفتحة المحددة:",
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _contentChip("فراغ / شماعة", ZoneContentType.empty, 0),
                      _contentChip("3 أرفف", ZoneContentType.shelves, 3),
                      _contentChip("4 أرفف", ZoneContentType.shelves, 4),
                      _contentChip("3 أدراج", ZoneContentType.drawers, 3),
                      _contentChip("4 أدراج", ZoneContentType.drawers, 4),
                      _contentChip("ضلفة", ZoneContentType.doors, 1),
                      _contentChip("ضلفتين", ZoneContentType.doors, 2),
                      _contentChip("فراغ مكتب (بدون قاعدة)",
                          ZoneContentType.openDeskSpace, 0),
                    ],
                  ),

                  if (_selectedNode.contentType == ZoneContentType.shelves ||
                      _selectedNode.contentType == ZoneContentType.drawers ||
                      _selectedNode.contentType == ZoneContentType.doors) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("تعديل العدد:",
                            style: TextStyle(fontSize: 13)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _selectedNode.itemCount > 1
                                  ? () => setState(
                                      () => _selectedNode.itemCount--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text("${_selectedNode.itemCount}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _selectedNode.itemCount++),
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Color(0xFF2DD4BF)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],

                  const Divider(height: 24, color: Colors.white12),
                  Text(
                    "ملخص التقطيع الحي: ${generatedParts.length} بند",
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // 2. لوحة الرسم الهندسي التفاعلية (2D / 3D)
          Expanded(
            child: Container(
              color: const Color(0xFF0B1120),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            _is3DView ? Icons.view_in_ar : Icons.touch_app,
                            color: const Color(0xFF2DD4BF),
                            size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _is3DView
                              ? "سوليد 100% ومنع تداخل صارم • اضغط لتحديد اللون • اسحب للدوران • بكرة الماوس للتكبير • ضغطتين لفتح/قفل"
                              : "محاذاة تلقائية مع الإطار والقطع الأخرى • سنترة في المنتصف • رص وشوش أدراج يدوي",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color:
                            _is3DView ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (_is3DView) {
                            return Listener(
                              onPointerSignal: (event) {
                                if (event is PointerScrollEvent) {
                                  final delta =
                                      event.scrollDelta.dy > 0 ? -0.08 : 0.08;
                                  setState(() {
                                    _zoom3D =
                                        (_zoom3D + delta).clamp(0.5, 2.2);
                                  });
                                }
                              },
                              child: GestureDetector(
                                onDoubleTapDown: (details) {
                                  final hit = _hitTestInteractive3D(
                                      details.localPosition);
                                  if (hit == null) return;
                                  setState(() {
                                    _selected3DColorKey = hit.colorKey;
                                    _selected3DPartLabel = hit.partLabel;
                                    if (hit.freeBoard != null) {
                                      _selectedFreeBoard = hit.freeBoard;
                                    }
                                    if (hit.key.startsWith("door_") ||
                                        hit.key.startsWith("drawer_")) {
                                      if (_openedKeys.contains(hit.key)) {
                                        _openedKeys.remove(hit.key);
                                      } else {
                                        _openedKeys.add(hit.key);
                                      }
                                    }
                                  });
                                  final board = hit.freeBoard;
                                  if (board != null &&
                                      !hit.key.startsWith("door_") &&
                                      !hit.key.startsWith("drawer_")) {
                                    _editFreeBoardDialog(board);
                                  }
                                },
                                onPanStart: (details) {
                                  _3DPanDownPos = details.localPosition;
                                  _last3DPanPos = details.localPosition;
                                },
                                onPanUpdate: (details) {
                                  if (_last3DPanPos == null) return;
                                  final dx = details.localPosition.dx -
                                      _last3DPanPos!.dx;
                                  final dy = details.localPosition.dy -
                                      _last3DPanPos!.dy;
                                  _last3DPanPos = details.localPosition;
                                  setState(() {
                                    _yawRad =
                                        (_yawRad + dx * 0.01).clamp(-1.5, 1.5);
                                    _pitchRad = (_pitchRad + dy * 0.01)
                                        .clamp(-1.2, 1.3);
                                  });
                                },
                                onPanEnd: (details) {
                                  final movedDist = (_3DPanDownPos != null)
                                      ? (details.localPosition -
                                              _3DPanDownPos!)
                                          .distance
                                      : 0.0;
                                  if (movedDist < 6.0) {
                                    final hit = _hitTestInteractive3D(
                                        details.localPosition);
                                    if (hit != null) {
                                      setState(() {
                                        _selected3DColorKey = hit.colorKey;
                                        _selected3DPartLabel = hit.partLabel;
                                        if (hit.freeBoard != null) {
                                          _selectedFreeBoard = hit.freeBoard;
                                        }
                                      });
                                    }
                                  }
                                  _last3DPanPos = null;
                                  _3DPanDownPos = null;
                                },
                                child: CustomPaint(
                                  size: Size(constraints.maxWidth,
                                      constraints.maxHeight),
                                  painter: _Cabinet3DPainter(
                                    design: _design,
                                    yaw: _yawRad,
                                    pitch: _pitchRad,
                                    zoom: _zoom3D,
                                    carcassDepthCm: _carcassDepthCm,
                                    frontThicknessCm: _frontThicknessCm,
                                    partColors: _partColors3D,
                                    selectedColorKey: _selected3DColorKey,
                                    openedKeys: _openedKeys,
                                    selectedFreeBoard: _selectedFreeBoard,
                                    outInteractiveHits: _interactive3DHits,
                                  ),
                                ),
                              ),
                            );
                          }

                          return GestureDetector(
                            onTapDown: (details) {
                              final pos = details.localPosition;
                              for (final fbHit in _freeBoardHitBoxes.reversed) {
                                if (fbHit.rect.contains(pos)) {
                                  setState(
                                      () => _selectedFreeBoard = fbHit.board);
                                  return;
                                }
                              }
                              for (final hit in _zoneHitBoxes) {
                                if (hit.rect.contains(pos)) {
                                  setState(() {
                                    _selectedNode = hit.node;
                                    _selectedFreeBoard = null;
                                  });
                                  break;
                                }
                              }
                            },
                            onDoubleTapDown: (details) {
                              final pos = details.localPosition;
                              for (final fbHit in _freeBoardHitBoxes.reversed) {
                                if (fbHit.rect.contains(pos)) {
                                  setState(
                                      () => _selectedFreeBoard = fbHit.board);
                                  _editFreeBoardDialog(fbHit.board);
                                  return;
                                }
                              }
                              for (final hit in _zoneHitBoxes) {
                                if (hit.rect.contains(pos)) {
                                  setState(() => _selectedNode = hit.node);
                                  _editZoneExactDimension(hit);
                                  break;
                                }
                              }
                            },
                            onPanStart: (details) {
                              final pos = details.localPosition;

                              if (_drawFreeMode) {
                                setState(() {
                                  _freeDrawStart = pos;
                                  _freeDrawCurrent = pos;
                                });
                                return;
                              }

                              for (final fbHit in _freeBoardHitBoxes.reversed) {
                                if (fbHit.rect.contains(pos)) {
                                  setState(() {
                                    _selectedFreeBoard = fbHit.board;
                                    _draggingFreeBoard = fbHit.board;
                                    _dragStartLocal = pos;
                                    _dragStartBoardX = fbHit.board.x;
                                    _dragStartBoardY = fbHit.board.y;
                                  });
                                  return;
                                }
                              }

                              for (final div in _dividerHitBoxes) {
                                if (div.hitRect.contains(pos)) {
                                  setState(() => _draggingDivider = div);
                                  break;
                                }
                              }
                            },
                            onPanUpdate: (details) {
                              final pos = details.localPosition;

                              if (_drawFreeMode && _freeDrawStart != null) {
                                setState(() => _freeDrawCurrent = pos);
                                return;
                              }

                              if (_draggingFreeBoard != null &&
                                  _dragStartLocal != null &&
                                  _lastScale > 0) {
                                final double dxCm =
                                    (pos.dx - _dragStartLocal!.dx) /
                                        _lastScale;
                                final double dyCm =
                                    (pos.dy - _dragStartLocal!.dy) /
                                        _lastScale;

                                final double nextX = _dragStartBoardX + dxCm;
                                final double nextY = _dragStartBoardY + dyCm;

                                setState(() {
                                  _applySmartSnap(
                                      _draggingFreeBoard!, nextX, nextY);
                                });
                                return;
                              }

                              final div = _draggingDivider;
                              if (div == null) return;
                              setState(() {
                                if (div.isVertical) {
                                  final double fromRight =
                                      div.parentRect.right - pos.dx;
                                  final double newRatio =
                                      fromRight / div.parentRect.width;
                                  div.parentNode.splitRatio =
                                      newRatio.clamp(0.12, 0.88);
                                } else {
                                  final double fromTop =
                                      pos.dy - div.parentRect.top;
                                  final double newRatio =
                                      fromTop / div.parentRect.height;
                                  div.parentNode.splitRatio =
                                      newRatio.clamp(0.12, 0.88);
                                }
                              });
                            },
                            onPanEnd: (_) {
                              if (_drawFreeMode &&
                                  _freeDrawStart != null &&
                                  _freeDrawCurrent != null) {
                                _createFreeBoardFromDrag(
                                    _freeDrawStart!, _freeDrawCurrent!);
                              }
                              setState(() {
                                _draggingDivider = null;
                                _draggingFreeBoard = null;
                                _dragStartLocal = null;
                                _snappedCenterX = false;
                                _snappedCenterY = false;
                                _snapGuideXCm = null;
                                _snapGuideYCm = null;
                              });
                            },
                            child: CustomPaint(
                              size: Size(constraints.maxWidth,
                                  constraints.maxHeight),
                              painter: _InteractiveCabinetPainter(
                                design: _design,
                                selectedNode: _selectedNode,
                                draggingNode: _draggingDivider?.parentNode,
                                selectedFreeBoard: _selectedFreeBoard,
                                snappedCenterX: _snappedCenterX,
                                snappedCenterY: _snappedCenterY,
                                snapGuideXCm: _snapGuideXCm,
                                snapGuideYCm: _snapGuideYCm,
                                drawStart: _freeDrawStart,
                                drawCurrent: _freeDrawCurrent,
                                zoneHitBoxes: _zoneHitBoxes,
                                dividerHitBoxes: _dividerHitBoxes,
                                freeBoardHitBoxes: _freeBoardHitBoxes,
                                onMetricsComputed: (scale, left, top) {
                                  _lastScale = scale;
                                  _lastLeft = left;
                                  _lastTop = top;
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickPartColorTag(String title, String key) {
    final isSel = _selected3DColorKey == key;
    return ChoiceChip(
      label: Text(title, style: const TextStyle(fontSize: 10.5)),
      selected: isSel,
      selectedColor: const Color(0xFF14B8A6),
      backgroundColor: const Color(0xFF0F172A),
      labelStyle: TextStyle(
        color: isSel ? Colors.black : Colors.white70,
        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        setState(() {
          _selected3DColorKey = key;
          _selected3DPartLabel = title;
        });
      },
    );
  }

  Widget _kindChip(String label, FreeBoardKind kind) {
    final bool selected = _newFreeKind == kind;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: selected,
      selectedColor: Colors.amberAccent,
      backgroundColor: const Color(0xFF1E293B),
      labelStyle: TextStyle(
        color: selected ? Colors.black : Colors.white,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _newFreeKind = kind),
    );
  }

  Widget _contentChip(String label, ZoneContentType type, int count) {
    final bool active = _selectedNode.contentType == type &&
        (_selectedNode.itemCount == count || count == 0);
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: active,
      selectedColor: const Color(0xFF14B8A6),
      backgroundColor: const Color(0xFF1E293B),
      labelStyle: TextStyle(
        color: active ? Colors.black : Colors.white,
        fontWeight: active ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        setState(() {
          _selectedNode.contentType = type;
          _selectedNode.itemCount = count;
        });
      },
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }
}
/// رسام 3D خام ومصمت (Raw Solid) مع منع تداخل هندسي صارم للخانات والأرفف والأدراج
class _Cabinet3DPainter extends CustomPainter {
  final CustomCabinetDesign design;
  final double yaw;
  final double pitch;
  final double zoom;
  final double carcassDepthCm;
  final double frontThicknessCm;
  final Map<String, Color> partColors;
  final String selectedColorKey;
  final Set<String> openedKeys;
  final FreeBoardPiece? selectedFreeBoard;
  final List<_InteractiveHit3D> outInteractiveHits;

  _Cabinet3DPainter({
    required this.design,
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.carcassDepthCm,
    required this.frontThicknessCm,
    required this.partColors,
    required this.selectedColorKey,
    required this.openedKeys,
    required this.selectedFreeBoard,
    required this.outInteractiveHits,
  });

  Color _colorFor(String key) {
    return partColors[key] ??
        (key.startsWith('free_')
            ? (partColors['free_default'] ?? const Color(0xFFD6A86C))
            : const Color(0xFFE2E8F0));
  }

  Color _rawSolidShade(Color c, double factor) {
    final r = (c.r * 255.0 * factor).clamp(18, 252).round();
    final g = (c.g * 255.0 * factor).clamp(18, 252).round();
    final b = (c.b * 255.0 * factor).clamp(18, 252).round();
    return Color.fromARGB(255, r, g, b);
  }

  @override
  void paint(Canvas canvas, Size size) {
    outInteractiveHits.clear();

    final List<_Box3D> boxes = [];
    final double t = design.boardThickness.clamp(0.6, 5.0);
    final double bodyH = math.max(10.0, design.height - design.plinthHeight);
    final double d = math.min(design.depth, math.max(15.0, carcassDepthCm));

    final carcassCol = _colorFor('carcass');
    final backCol = _colorFor('back');
    const rawLineColor = Color(0xFF0F172A);

    // 1. الجنب الأيمن والأيسر والسقف والوزرة (خام بدون تداخل)
    boxes.add(_Box3D(
      x: 0,
      y: 0,
      z: 0,
      w: t,
      h: bodyH,
      d: d,
      baseColor: carcassCol,
      strokeColor: rawLineColor,
      colorKey: 'carcass',
      partLabel: 'الهيكل الخارجي والوزرة',
      layerPriority: 0,
    ));

    boxes.add(_Box3D(
      x: math.max(t, design.width - t),
      y: 0,
      z: 0,
      w: t,
      h: bodyH,
      d: d,
      baseColor: carcassCol,
      strokeColor: rawLineColor,
      colorKey: 'carcass',
      partLabel: 'الهيكل الخارجي والوزرة',
      layerPriority: 0,
    ));

    final double innerSpanW = math.max(2.0, design.width - 2 * t);
    boxes.add(_Box3D(
      x: t,
      y: 0,
      z: 0,
      w: innerSpanW,
      h: t,
      d: d,
      baseColor: carcassCol,
      strokeColor: rawLineColor,
      colorKey: 'carcass',
      partLabel: 'الهيكل الخارجي والوزرة',
      layerPriority: 0,
    ));

    if (design.plinthHeight > 0) {
      boxes.add(_Box3D(
        x: t,
        y: bodyH,
        z: 1.5,
        w: innerSpanW,
        h: design.plinthHeight,
        d: math.max(4.0, d - 3.0),
        baseColor: carcassCol,
        strokeColor: rawLineColor,
        colorKey: 'carcass',
        partLabel: 'الهيكل الخارجي والوزرة',
        layerPriority: 0,
      ));
    }

    // 2. الظهر في الخلف تماماً (z = 0)
    final double innerSpanH = math.max(2.0, bodyH - 2 * t);
    const double backThick = 0.8;
    if (design.hasBackPanel) {
      boxes.add(_Box3D(
        x: t,
        y: t,
        z: 0,
        w: innerSpanW,
        h: innerSpanH,
        d: backThick,
        baseColor: backCol,
        strokeColor: rawLineColor,
        colorKey: 'back',
        partLabel: 'ظهر الوحدة',
        layerPriority: 0,
      ));
    }

    // 3. الخانات والقواطيع والأرفف والأدراج والضلف (كل جزء داخل حدود فتحته فقط)
    _collect3DNodeBoxes(
      node: design.root,
      pathId: "root",
      x: t,
      y: t,
      z: design.hasBackPanel ? backThick : 0.0,
      w: innerSpanW,
      h: innerSpanH,
      d: design.hasBackPanel ? math.max(8.0, d - backThick) : d,
      bottomBoardY: bodyH - t,
      outBoxes: boxes,
    );

    // 4. القطع الحرة / القرصة
    for (final fb in design.freeBoards) {
      final bool isSel = identical(selectedFreeBoard, fb);
      final fbKey = 'free_${fb.id}';
      final double fbDepth =
          (fb.kind == FreeBoardKind.shelf || fb.kind == FreeBoardKind.panel)
              ? d
              : math.max(fb.thickness, 2.0);
      final double fbZ =
          (fb.kind == FreeBoardKind.shelf || fb.kind == FreeBoardKind.panel)
              ? 0.0
              : math.max(0.0, d - fbDepth);

      boxes.add(_Box3D(
        x: fb.x,
        y: fb.y,
        z: fbZ,
        w: math.max(1.0, fb.width),
        h: math.max(1.0, fb.height),
        d: fbDepth,
        baseColor: isSel ? const Color(0xFF2DD4BF) : _colorFor(fbKey),
        strokeColor: rawLineColor,
        colorKey: fbKey,
        partLabel: fb.name,
        layerPriority: 3,
        freeBoard: fb,
        interactiveKey: fbKey,
      ));
    }

    final double maxDim = math.max(
        design.width, math.max(design.height, design.depth * 1.4));
    final double baseScale =
        (math.min(size.width, size.height) * 0.56 / math.max(40.0, maxDim)) *
            zoom;

    final Offset centerOffset = Offset(size.width * 0.5, size.height * 0.52);
    final double cxModel = design.width * 0.5;
    final double cyModel = design.height * 0.5;
    final double czModel = d * 0.5;

    final double cosY = math.cos(yaw);
    final double sinY = math.sin(yaw);
    final double cosP = math.cos(pitch);
    final double sinP = math.sin(pitch);

    final double camDirX = sinY * cosP;
    final double camDirY = -sinP;
    final double camDirZ = cosY * cosP;

    Offset project(double mx, double my, double mz) {
      final double dx = mx - cxModel;
      final double dy = my - cyModel;
      final double dz = mz - czModel;

      final double xRot = dx * cosY - dz * sinY;
      final double zRot = dx * sinY + dz * cosY;
      final double yRot = dy * cosP - zRot * sinP;

      return Offset(
        centerOffset.dx + xRot * baseScale,
        centerOffset.dy + yRot * baseScale,
      );
    }

    double faceDepth(List<List<double>> corners) {
      double sx = 0, sy = 0, sz = 0;
      for (final c in corners) {
        sx += c[0] - cxModel;
        sy += c[1] - cyModel;
        sz += c[2] - czModel;
      }
      final n = corners.length.toDouble();
      return (sx / n) * camDirX + (sy / n) * camDirY + (sz / n) * camDirZ;
    }

    final List<_Face3D> facesToDraw = [];

    for (final b in boxes) {
      final x0 = b.x, x1 = b.x + b.w;
      final y0 = b.y, y1 = b.y + b.h;
      final z0 = b.z, z1 = b.z + b.d;
      final isHighlightedKey = selectedColorKey == b.colorKey;

      final rawFaces = <({
        List<List<double>> c3d,
        double nx,
        double ny,
        double nz,
        double shade,
      })>[
        (
          c3d: [
            [x0, y0, z1],
            [x1, y0, z1],
            [x1, y1, z1],
            [x0, y1, z1],
          ],
          nx: 0,
          ny: 0,
          nz: 1,
          shade: 1.0,
        ),
        (
          c3d: [
            [x1, y0, z0],
            [x0, y0, z0],
            [x0, y1, z0],
            [x1, y1, z0],
          ],
          nx: 0,
          ny: 0,
          nz: -1,
          shade: 0.74,
        ),
        (
          c3d: [
            [x1, y0, z1],
            [x1, y0, z0],
            [x1, y1, z0],
            [x1, y1, z1],
          ],
          nx: 1,
          ny: 0,
          nz: 0,
          shade: 0.86,
        ),
        (
          c3d: [
            [x0, y0, z0],
            [x0, y0, z1],
            [x0, y1, z1],
            [x0, y1, z0],
          ],
          nx: -1,
          ny: 0,
          nz: 0,
          shade: 0.82,
        ),
        (
          c3d: [
            [x0, y0, z0],
            [x1, y0, z0],
            [x1, y0, z1],
            [x0, y0, z1],
          ],
          nx: 0,
          ny: -1,
          nz: 0,
          shade: 1.06,
        ),
        (
          c3d: [
            [x0, y1, z1],
            [x1, y1, z1],
            [x1, y1, z0],
            [x0, y1, z0],
          ],
          nx: 0,
          ny: 1,
          nz: 0,
          shade: 0.70,
        ),
      ];

      for (final rf in rawFaces) {
        final dot = rf.nx * camDirX + rf.ny * camDirY + rf.nz * camDirZ;
        if (dot <= 0.02) continue;

        final pts2d = rf.c3d.map((c) => project(c[0], c[1], c[2])).toList();
        final dep = faceDepth(rf.c3d);

        facesToDraw.add(_Face3D(
          points: pts2d,
          depthFromCamera: dep,
          layerPriority: b.layerPriority,
          fillColor: _rawSolidShade(b.baseColor, rf.shade),
          strokeColor:
              isHighlightedKey ? const Color(0xFFF59E0B) : b.strokeColor,
          strokeWidth: isHighlightedKey ? 1.6 : 1.15,
          colorKey: b.colorKey,
          partLabel: b.partLabel,
          freeBoard: b.freeBoard,
          interactiveKey: b.interactiveKey,
        ));

        outInteractiveHits.add(_InteractiveHit3D(
          key: b.interactiveKey ?? b.colorKey,
          colorKey: b.colorKey,
          partLabel: b.partLabel,
          freeBoard: b.freeBoard,
          polygon: pts2d,
          depthFromCamera: dep,
        ));
      }
    }

    facesToDraw.sort((a, b) {
      final dCmp = a.depthFromCamera.compareTo(b.depthFromCamera);
      if (dCmp.abs() > 0.35) return dCmp;
      return a.layerPriority.compareTo(b.layerPriority);
    });

    for (final f in facesToDraw) {
      if (f.points.isEmpty) continue;
      final path = Path()..moveTo(f.points.first.dx, f.points.first.dy);
      for (int i = 1; i < f.points.length; i++) {
        path.lineTo(f.points[i].dx, f.points[i].dy);
      }
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..color = f.fillColor
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = f.strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = f.strokeWidth
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  void _collect3DNodeBoxes({
    required CabinetZoneNode node,
    required String pathId,
    required double x,
    required double y,
    required double z,
    required double w,
    required double h,
    required double d,
    required double bottomBoardY,
    required List<_Box3D> outBoxes,
  }) {
    final double t = design.boardThickness.clamp(0.6, 5.0);
    final interiorCol = _colorFor('interior');
    final frontCol = _colorFor('front');
    const rawLineColor = Color(0xFF0F172A);

    if (node.splitType == SplitType.vertical) {
      final double usableW = math.max(1.0, w - t);
      final double w1 = usableW * node.splitRatio;
      final double w2 = math.max(0.5, usableW - w1);

      // قاطوع رأسي داخل حدود الخانة تماماً
      outBoxes.add(_Box3D(
        x: x + w1,
        y: y,
        z: z,
        w: t,
        h: h,
        d: d,
        baseColor: interiorCol,
        strokeColor: rawLineColor,
        colorKey: 'interior',
        partLabel: 'الجسم الداخلي والقواطيع',
        layerPriority: 1,
      ));

      _collect3DNodeBoxes(
        node: node.firstChild!,
        pathId: "${pathId}_1",
        x: x,
        y: y,
        z: z,
        w: w1,
        h: h,
        d: d,
        bottomBoardY: bottomBoardY,
        outBoxes: outBoxes,
      );
      _collect3DNodeBoxes(
        node: node.secondChild!,
        pathId: "${pathId}_2",
        x: x + w1 + t,
        y: y,
        z: z,
        w: w2,
        h: h,
        d: d,
        bottomBoardY: bottomBoardY,
        outBoxes: outBoxes,
      );
      return;
    }

    if (node.splitType == SplitType.horizontal) {
      final double usableH = math.max(1.0, h - t);
      final double h1 = usableH * node.splitRatio;
      final double h2 = math.max(0.5, usableH - h1);

      // قاطوع أفقي داخل حدود الخانة تماماً
      outBoxes.add(_Box3D(
        x: x,
        y: y + h1,
        z: z,
        w: w,
        h: t,
        d: d,
        baseColor: interiorCol,
        strokeColor: rawLineColor,
        colorKey: 'interior',
        partLabel: 'الجسم الداخلي والقواطيع',
        layerPriority: 1,
      ));

      _collect3DNodeBoxes(
        node: node.firstChild!,
        pathId: "${pathId}_h1",
        x: x,
        y: y,
        z: z,
        w: w,
        h: h1,
        d: d,
        bottomBoardY: bottomBoardY,
        outBoxes: outBoxes,
      );
      _collect3DNodeBoxes(
        node: node.secondChild!,
        pathId: "${pathId}_h2",
        x: x,
        y: y + h1 + t,
        z: z,
        w: w,
        h: h2,
        d: d,
        bottomBoardY: bottomBoardY,
        outBoxes: outBoxes,
      );
      return;
    }

    // أرضية الخانة السفلية (إن لم تكن فراغ مكتب مفتوح)
    if (((y + h) - bottomBoardY).abs() < 4.0 &&
        node.contentType != ZoneContentType.openDeskSpace) {
      outBoxes.add(_Box3D(
        x: x,
        y: bottomBoardY,
        z: z,
        w: w,
        h: t,
        d: d,
        baseColor: interiorCol,
        strokeColor: rawLineColor,
        colorKey: 'interior',
        partLabel: 'الجسم الداخلي والقواطيع',
        layerPriority: 1,
      ));
    }

    if (node.contentType == ZoneContentType.shelves && node.itemCount > 0) {
      final double step = h / (node.itemCount + 1);
      final double shelfH = math.min(t * 0.85, math.max(0.6, step * 0.35));
      // منع التداخل الجانبي: الرف يبقى داخل عرض الخانة الصافي (x .. x + w)
      final double shelfX = x + 0.15;
      final double shelfW = math.max(1.0, w - 0.3);

      for (int i = 1; i <= node.itemCount; i++) {
        final double rawY = y + step * i - shelfH * 0.5;
        final double safeY = rawY.clamp(y + 0.2, math.max(y + 0.2, y + h - shelfH - 0.2));
        outBoxes.add(_Box3D(
          x: shelfX,
          y: safeY,
          z: z,
          w: shelfW,
          h: shelfH,
          d: math.max(4.0, d - 1.2),
          baseColor: interiorCol,
          strokeColor: rawLineColor,
          colorKey: 'interior',
          partLabel: 'الجسم الداخلي والأرفف',
          layerPriority: 1,
        ));
      }
    } else if (node.contentType == ZoneContentType.drawers && node.itemCount > 0) {
      final double dH = h / node.itemCount;
      for (int i = 0; i < node.itemCount; i++) {
        final key = "drawer_${pathId}_$i";
        final bool isOpen = openedKeys.contains(key);
        final double maxSafeSlide = math.max(0.0, d - frontThicknessCm - 1.5);
        final double slideOut =
            isOpen ? math.min(maxSafeSlide * 0.5, 12.0) : 0.0;
        final double boxDepth = math.max(5.0, d - frontThicknessCm - 1.5);
        final double dy = (y + i * dH + 0.25).clamp(y, math.max(y, y + h - 1.0));
        final double dhClean =
            math.max(2.0, math.min(dH - 0.5, (y + h) - dy));

        if (isOpen) {
          outBoxes.add(_Box3D(
            x: x + 1.2,
            y: (dy + 0.8).clamp(y, math.max(y, y + h - 1.0)),
            z: z + math.max(0.5, d - boxDepth - frontThicknessCm) + slideOut,
            w: math.max(2.0, w - 2.4),
            h: math.max(1.5, dhClean - 1.6),
            d: boxDepth,
            baseColor: interiorCol,
            strokeColor: rawLineColor,
            colorKey: 'interior',
            partLabel: 'صندوق الدرج الداخلي',
            layerPriority: 1,
          ));
        }

        outBoxes.add(_Box3D(
          x: x + 0.25,
          y: dy,
          z: z + math.max(0.8, d - frontThicknessCm) + slideOut,
          w: math.max(2.0, w - 0.5),
          h: dhClean,
          d: frontThicknessCm,
          baseColor: frontCol,
          strokeColor: rawLineColor,
          colorKey: 'front',
          partLabel: 'وش الدرج (${i + 1})',
          layerPriority: 2,
          interactiveKey: key,
        ));
      }
    } else if (node.contentType == ZoneContentType.doors && node.itemCount > 0) {
      final double doorW = w / node.itemCount;
      for (int i = 0; i < node.itemCount; i++) {
        final key = "door_${pathId}_$i";
        final bool isOpen = openedKeys.contains(key);
        final double dx = x + i * doorW + 0.25;
        final double dwClean = math.max(2.0, doorW - 0.5);

        final bool hingeOnLeft = i < (node.itemCount / 2);
        final double safeOffset = math.min(dwClean * 0.2, 5.0);
        final double clampedX = isOpen
            ? (dx + (hingeOnLeft ? -safeOffset : safeOffset))
                .clamp(x + 0.2, math.max(x + 0.2, x + w - dwClean * 0.72))
            : dx;
        final double swingZ = isOpen ? math.min(dwClean * 0.28, 7.0) : 0.0;

        outBoxes.add(_Box3D(
          x: clampedX,
          y: y + 0.25,
          z: z + math.max(0.8, d - frontThicknessCm) + swingZ * 0.3,
          w: isOpen ? math.max(2.0, dwClean * 0.72) : dwClean,
          h: math.max(2.0, h - 0.5),
          d: isOpen
              ? math.max(frontThicknessCm, math.min(dwClean * 0.25, 5.5))
              : frontThicknessCm,
          baseColor: frontCol,
          strokeColor: rawLineColor,
          colorKey: 'front',
          partLabel: 'ضلفة (${i + 1})',
          layerPriority: 2,
          interactiveKey: key,
        ));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Cabinet3DPainter oldDelegate) => true;
}

class _InteractiveCabinetPainter extends CustomPainter {
  final CustomCabinetDesign design;
  final CabinetZoneNode selectedNode;
  final CabinetZoneNode? draggingNode;
  final FreeBoardPiece? selectedFreeBoard;
  final bool snappedCenterX;
  final bool snappedCenterY;
  final double? snapGuideXCm;
  final double? snapGuideYCm;
  final Offset? drawStart;
  final Offset? drawCurrent;
  final List<_ZoneHitBox> zoneHitBoxes;
  final List<_DividerHitBox> dividerHitBoxes;
  final List<_FreeBoardHitBox> freeBoardHitBoxes;
  final void Function(double scale, double left, double top) onMetricsComputed;

  _InteractiveCabinetPainter({
    required this.design,
    required this.selectedNode,
    required this.draggingNode,
    required this.selectedFreeBoard,
    required this.snappedCenterX,
    required this.snappedCenterY,
    required this.snapGuideXCm,
    required this.snapGuideYCm,
    required this.drawStart,
    required this.drawCurrent,
    required this.zoneHitBoxes,
    required this.dividerHitBoxes,
    required this.freeBoardHitBoxes,
    required this.onMetricsComputed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    zoneHitBoxes.clear();
    dividerHitBoxes.clear();
    freeBoardHitBoxes.clear();

    const double margin = 55.0;
    final double availW = math.max(100, size.width - (margin * 2));
    final double availH = math.max(100, size.height - (margin * 2));

    final double scale =
        math.min(availW / design.width, availH / design.height);
    final double drawW = design.width * scale;
    final double drawH = design.height * scale;

    final double left = (size.width - drawW) / 2;
    final double top = (size.height - drawH) / 2;
    onMetricsComputed(scale, left, top);

    final double tPx = math.max(3.0, design.boardThickness * scale);
    final double plinthPx = design.plinthHeight * scale;
    final double bodyH = drawH - plinthPx;

    final boardFill = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;
    final boardStroke = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rightSide = Rect.fromLTWH(left + drawW - tPx, top, tPx, bodyH);
    final leftSide = Rect.fromLTWH(left, top, tPx, bodyH);
    final topBoard = Rect.fromLTWH(left + tPx, top, drawW - (2 * tPx), tPx);

    for (final r in [rightSide, leftSide, topBoard]) {
      canvas.drawRect(r, boardFill);
      canvas.drawRect(r, boardStroke);
    }

    if (plinthPx > 0) {
      final plinthRect = Rect.fromLTWH(
          left + tPx, top + bodyH, drawW - (2 * tPx), plinthPx);
      canvas.drawRect(plinthRect, Paint()..color = const Color(0xFFCBD5E1));
      canvas.drawRect(plinthRect, boardStroke);
      _drawText(
        canvas,
        "وزرة ${design.plinthHeight.toInt()} سم",
        plinthRect.center,
        const TextStyle(color: Color(0xFF334155), fontSize: 10),
      );
    }

    final double innerRealW =
        math.max(5.0, design.width - (2 * design.boardThickness));
    final double innerRealH = math.max(
        5.0, (design.height - design.plinthHeight) - (2 * design.boardThickness));

    final Rect innerRect = Rect.fromLTWH(
      left + tPx,
      top + tPx,
      drawW - (2 * tPx),
      bodyH - (2 * tPx),
    );

    _drawNodeRecursive(
      canvas: canvas,
      node: design.root,
      rect: innerRect,
      realW: innerRealW,
      realH: innerRealH,
      tPx: tPx,
      bottomBoardY: top + bodyH - tPx,
      boardFill: boardFill,
      boardStroke: boardStroke,
    );

    for (final fb in design.freeBoards) {
      final Rect fbRect = Rect.fromLTWH(
        left + (fb.x * scale),
        top + (fb.y * scale),
        math.max(4.0, fb.width * scale),
        math.max(4.0, fb.height * scale),
      );
      freeBoardHitBoxes.add(_FreeBoardHitBox(fb, fbRect));

      final bool isFbSelected = identical(selectedFreeBoard, fb);
      canvas.drawRect(
        fbRect,
        Paint()
          ..color = isFbSelected
              ? const Color(0xFF2DD4BF).withValues(alpha: 0.55)
              : const Color(0xFFFDE68A).withValues(alpha: 0.85),
      );
      canvas.drawRect(
        fbRect,
        Paint()
          ..color = isFbSelected
              ? const Color(0xFF0F766E)
              : const Color(0xFFB45309)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isFbSelected ? 2.2 : 1.5,
      );

      if (fbRect.width > 36 && fbRect.height > 12) {
        _drawText(
          canvas,
          "${fb.width.toStringAsFixed(0)}×${fb.height.toStringAsFixed(0)} سم",
          fbRect.center,
          const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 9.5,
              fontWeight: FontWeight.bold),
        );
      }
    }

    final guidePaint = Paint()
      ..color = snappedCenterX || snappedCenterY
          ? const Color(0xFFEF4444)
          : const Color(0xFF0284C7)
      ..strokeWidth = 1.4;

    if (snapGuideXCm != null) {
      final double gx = left + (snapGuideXCm! * scale);
      canvas.drawLine(
        Offset(gx, top - 12),
        Offset(gx, top + drawH + 12),
        guidePaint,
      );
    }
    if (snapGuideYCm != null) {
      final double gy = top + (snapGuideYCm! * scale);
      canvas.drawLine(
        Offset(left - 12, gy),
        Offset(left + drawW + 12, gy),
        guidePaint,
      );
    }

    if (drawStart != null && drawCurrent != null) {
      final previewRect = Rect.fromPoints(drawStart!, drawCurrent!);
      canvas.drawRect(
        previewRect,
        Paint()..color = const Color(0xFF14B8A6).withValues(alpha: 0.25),
      );
      canvas.drawRect(
        previewRect,
        Paint()
          ..color = const Color(0xFF0D9488)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }

    _drawDimensionLine(
      canvas,
      Offset(left, top - 22),
      Offset(left + drawW, top - 22),
      "العرض الكلي: ${design.width.toStringAsFixed(0)} سم",
    );
    _drawDimensionLine(
      canvas,
      Offset(left + drawW + 24, top),
      Offset(left + drawW + 24, top + drawH),
      "${design.height.toStringAsFixed(0)} سم",
      vertical: true,
    );
  }

  void _drawNodeRecursive({
    required Canvas canvas,
    required CabinetZoneNode node,
    required Rect rect,
    required double realW,
    required double realH,
    required double tPx,
    required double bottomBoardY,
    required Paint boardFill,
    required Paint boardStroke,
  }) {
    final double t = design.boardThickness;

    if (node.splitType == SplitType.vertical) {
      final double usableRealW = math.max(1.0, realW - t);
      final double realW1 = usableRealW * node.splitRatio;
      final double realW2 = usableRealW - realW1;

      final double usablePxW = math.max(4.0, rect.width - tPx);
      final double pxW1 = usablePxW * node.splitRatio;
      final double pxW2 = usablePxW - pxW1;

      final Rect rect1 =
          Rect.fromLTWH(rect.right - pxW1, rect.top, pxW1, rect.height);
      final Rect divRect =
          Rect.fromLTWH(rect1.left - tPx, rect.top, tPx, rect.height);
      final Rect rect2 = Rect.fromLTWH(rect.left, rect.top, pxW2, rect.height);

      _drawNodeRecursive(
        canvas: canvas,
        node: node.firstChild!,
        rect: rect1,
        realW: realW1,
        realH: realH,
        tPx: tPx,
        bottomBoardY: bottomBoardY,
        boardFill: boardFill,
        boardStroke: boardStroke,
      );
      _drawNodeRecursive(
        canvas: canvas,
        node: node.secondChild!,
        rect: rect2,
        realW: realW2,
        realH: realH,
        tPx: tPx,
        bottomBoardY: bottomBoardY,
        boardFill: boardFill,
        boardStroke: boardStroke,
      );

      final bool isDragging = identical(draggingNode, node);
      canvas.drawRect(
        divRect,
        Paint()
          ..color = isDragging
              ? const Color(0xFF14B8A6)
              : const Color(0xFFCBD5E1),
      );
      canvas.drawRect(divRect, boardStroke);
      canvas.drawCircle(
        divRect.center,
        6,
        Paint()..color = const Color(0xFF0F766E),
      );

      dividerHitBoxes.add(_DividerHitBox(
        parentNode: node,
        hitRect: divRect.inflate(10),
        parentRect: rect,
        usableRealSize: usableRealW,
        isVertical: true,
      ));
      return;
    }

    if (node.splitType == SplitType.horizontal) {
      final double usableRealH = math.max(1.0, realH - t);
      final double realH1 = usableRealH * node.splitRatio;
      final double realH2 = usableRealH - realH1;

      final double usablePxH = math.max(4.0, rect.height - tPx);
      final double pxH1 = usablePxH * node.splitRatio;
      final double pxH2 = usablePxH - pxH1;

      final Rect rect1 = Rect.fromLTWH(rect.left, rect.top, rect.width, pxH1);
      final Rect divRect =
          Rect.fromLTWH(rect.left, rect1.bottom, rect.width, tPx);
      final Rect rect2 =
          Rect.fromLTWH(rect.left, divRect.bottom, rect.width, pxH2);

      _drawNodeRecursive(
        canvas: canvas,
        node: node.firstChild!,
        rect: rect1,
        realW: realW,
        realH: realH1,
        tPx: tPx,
        bottomBoardY: bottomBoardY,
        boardFill: boardFill,
        boardStroke: boardStroke,
      );
      _drawNodeRecursive(
        canvas: canvas,
        node: node.secondChild!,
        rect: rect2,
        realW: realW,
        realH: realH2,
        tPx: tPx,
        bottomBoardY: bottomBoardY,
        boardFill: boardFill,
        boardStroke: boardStroke,
      );

      final bool isDragging = identical(draggingNode, node);
      canvas.drawRect(
        divRect,
        Paint()
          ..color = isDragging
              ? const Color(0xFF14B8A6)
              : const Color(0xFFCBD5E1),
      );
      canvas.drawRect(divRect, boardStroke);
      canvas.drawCircle(
        divRect.center,
        6,
        Paint()..color = const Color(0xFF0F766E),
      );

      dividerHitBoxes.add(_DividerHitBox(
        parentNode: node,
        hitRect: divRect.inflate(10),
        parentRect: rect,
        usableRealSize: usableRealH,
        isVertical: false,
      ));
      return;
    }

    final bool isSelected =
        identical(selectedNode, node) && selectedFreeBoard == null;
    zoneHitBoxes.add(_ZoneHitBox(node, rect, realW, realH));

    if ((rect.bottom - bottomBoardY).abs() < 4.0 &&
        node.contentType != ZoneContentType.openDeskSpace) {
      final baseRect = Rect.fromLTWH(rect.left, bottomBoardY, rect.width, tPx);
      canvas.drawRect(baseRect, boardFill);
      canvas.drawRect(baseRect, boardStroke);
    }

    if (isSelected) {
      canvas.drawRect(
        rect.deflate(1.5),
        Paint()..color = const Color(0xFF14B8A6).withValues(alpha: 0.14),
      );
      canvas.drawRect(
        rect.deflate(1.5),
        Paint()
          ..color = const Color(0xFF0D9488)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    if (node.contentType == ZoneContentType.shelves && node.itemCount > 0) {
      final double step = rect.height / (node.itemCount + 1);
      for (int i = 1; i <= node.itemCount; i++) {
        final double y = rect.top + (step * i);
        final shelfR = Rect.fromLTWH(
            rect.left + 1, y - (tPx / 2), rect.width - 2, tPx * 0.85);
        canvas.drawRect(shelfR, boardFill);
        canvas.drawRect(shelfR, boardStroke);
      }
    } else if (node.contentType == ZoneContentType.drawers && node.itemCount > 0) {
      final double dH = rect.height / node.itemCount;
      for (int i = 0; i < node.itemCount; i++) {
        final dRect = Rect.fromLTWH(
            rect.left + 2, rect.top + (i * dH) + 2, rect.width - 4, dH - 4);
        canvas.drawRect(dRect, Paint()..color = const Color(0xFFF1F5F9));
        canvas.drawRect(dRect, boardStroke);
        canvas.drawLine(
          Offset(dRect.center.dx - 14, dRect.center.dy),
          Offset(dRect.center.dx + 14, dRect.center.dy),
          Paint()
            ..color = const Color(0xFF475569)
            ..strokeWidth = 2.5,
        );
      }
    } else if (node.contentType == ZoneContentType.doors && node.itemCount > 0) {
      final double doorW = rect.width / node.itemCount;
      for (int i = 0; i < node.itemCount; i++) {
        final dRect = Rect.fromLTWH(rect.left + (i * doorW) + 2, rect.top + 2,
            doorW - 4, rect.height - 4);
        canvas.drawRect(dRect,
            Paint()..color = const Color(0xFFE0F2FE).withValues(alpha: 0.6));
        canvas.drawRect(dRect, boardStroke);
      }
    } else if (node.contentType == ZoneContentType.openDeskSpace) {
      _drawText(
        canvas,
        "فراغ مكتب (مفتوح)",
        Offset(rect.center.dx, rect.center.dy + 16),
        const TextStyle(
            color: Color(0xFF0F766E),
            fontSize: 11,
            fontWeight: FontWeight.bold),
      );
    }

    final String dimText =
        "${realW.toStringAsFixed(1)} × ${realH.toStringAsFixed(1)} سم";
    final textPainter = TextPainter(
      text: TextSpan(
        text: dimText,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF334155),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();

    final pillRect = Rect.fromCenter(
      center: rect.center,
      width: textPainter.width + 12,
      height: textPainter.height + 6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, const Radius.circular(6)),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    textPainter.paint(
      canvas,
      Offset(rect.center.dx - textPainter.width / 2,
          rect.center.dy - textPainter.height / 2),
    );
  }

  void _drawDimensionLine(
      Canvas canvas, Offset p1, Offset p2, String label,
      {bool vertical = false}) {
    final paint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 1.3;
    canvas.drawLine(p1, p2, paint);
    final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    _drawText(
      canvas,
      label,
      Offset(mid.dx, vertical ? mid.dy : mid.dy - 10),
      const TextStyle(
          color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.bold),
    );
  }

    void _drawText(Canvas canvas, String text, Offset center, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _InteractiveCabinetPainter oldDelegate) => true;
}