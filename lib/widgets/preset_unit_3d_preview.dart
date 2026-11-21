import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PresetUnit3DPreview extends StatefulWidget {
  final double widthCm;
  final double heightCm;
  final double depthCm;
  final int doorsCount;
  final int shelvesCount;
  final int drawersCount;
  final bool hasGlassDoors;
  final bool hasGlassShelves;
  final Color carcassColor;
  final Color frontColor;

  const PresetUnit3DPreview({
    super.key,
    required this.widthCm,
    required this.heightCm,
    required this.depthCm,
    required this.doorsCount,
    required this.shelvesCount,
    required this.drawersCount,
    this.hasGlassDoors = false,
    this.hasGlassShelves = false,
    this.carcassColor = const Color(0xFFE2E8F0),
    this.frontColor = const Color(0xFFD6A86C),
  });

  @override
  State<PresetUnit3DPreview> createState() => _PresetUnit3DPreviewState();
}

class _PresetUnit3DPreviewState extends State<PresetUnit3DPreview> {
  double _yaw = 0.58;
  double _pitch = 0.34;
  double _zoom = 1.0;
  bool _isOpen = false;
  Offset? _lastPanPos;

  void _toggleOpen() {
    setState(() => _isOpen = !_isOpen);
  }

  void _resetView() {
    setState(() {
      _yaw = 0.58;
      _pitch = 0.34;
      _zoom = 1.0;
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.view_in_ar,
                    size: 16, color: Color(0xFF2DD4BF)),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    "اسحب للدوران • بكرة الماوس للتكبير • ضغطتين لفتح/قفل",
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleOpen,
                  icon: Icon(
                    _isOpen
                        ? Icons.door_back_door_outlined
                        : Icons.sensor_door_outlined,
                    size: 14,
                    color: Colors.black,
                  ),
                  label: Text(
                    _isOpen ? "قفل الضلف/الأدراج" : "فتح الضلف/الأدراج",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DD4BF),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: "إعادة ضبط الزاوية",
                  onPressed: _resetView,
                  icon: const Icon(Icons.refresh,
                      size: 16, color: Colors.amberAccent),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Listener(
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      final delta = event.scrollDelta.dy > 0 ? -0.08 : 0.08;
                      setState(() {
                        _zoom = (_zoom + delta).clamp(0.6, 1.9);
                      });
                    }
                  },
                  child: GestureDetector(
                    onDoubleTap: _toggleOpen,
                    onPanStart: (details) => _lastPanPos = details.localPosition,
                    onPanUpdate: (details) {
                      if (_lastPanPos == null) return;
                      final dx = details.localPosition.dx - _lastPanPos!.dx;
                      final dy = details.localPosition.dy - _lastPanPos!.dy;
                      _lastPanPos = details.localPosition;
                      setState(() {
                        _yaw = (_yaw + dx * 0.01).clamp(-1.5, 1.5);
                        _pitch = (_pitch + dy * 0.01).clamp(-1.15, 1.25);
                      });
                    },
                    onPanEnd: (_) => _lastPanPos = null,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _SolidPreset3DPainter(
                        widthCm: math.max(20, widget.widthCm),
                        heightCm: math.max(20, widget.heightCm),
                        depthCm: math.max(15, widget.depthCm),
                        doorsCount: math.max(0, widget.doorsCount),
                        shelvesCount: math.max(0, widget.shelvesCount),
                        drawersCount: math.max(0, widget.drawersCount),
                        hasGlassDoors: widget.hasGlassDoors,
                        hasGlassShelves: widget.hasGlassShelves,
                        carcassColor: widget.carcassColor,
                        frontColor: widget.frontColor,
                        yaw: _yaw,
                        pitch: _pitch,
                        zoom: _zoom,
                        isOpen: _isOpen,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SolidBox {
  final double x, y, z, w, h, d;
  final Color baseColor;
  final int priority;

  _SolidBox({
    required this.x,
    required this.y,
    required this.z,
    required this.w,
    required this.h,
    required this.d,
    required this.baseColor,
    this.priority = 0,
  });
}

class _SolidFace {
  final List<Offset> pts;
  final double depth;
  final int priority;
  final Color fill;

  _SolidFace({
    required this.pts,
    required this.depth,
    required this.priority,
    required this.fill,
  });
}

class _SolidPreset3DPainter extends CustomPainter {
  final double widthCm;
  final double heightCm;
  final double depthCm;
  final int doorsCount;
  final int shelvesCount;
  final int drawersCount;
  final bool hasGlassDoors;
  final bool hasGlassShelves;
  final Color carcassColor;
  final Color frontColor;
  final double yaw;
  final double pitch;
  final double zoom;
  final bool isOpen;

  _SolidPreset3DPainter({
    required this.widthCm,
    required this.heightCm,
    required this.depthCm,
    required this.doorsCount,
    required this.shelvesCount,
    required this.drawersCount,
    required this.hasGlassDoors,
    required this.hasGlassShelves,
    required this.carcassColor,
    required this.frontColor,
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.isOpen,
  });

  Color _opaqueShade(Color c, double factor) {
    final r = (c.r * 255.0 * factor).clamp(20, 250).round();
    final g = (c.g * 255.0 * factor).clamp(20, 250).round();
    final b = (c.b * 255.0 * factor).clamp(20, 250).round();
    return Color.fromARGB(255, r, g, b);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double t = 1.8;
    final double w = widthCm;
    final double h = heightCm;
    final double d = depthCm;
    final double innerW = math.max(4.0, w - 2 * t);
    final double innerH = math.max(4.0, h - 2 * t);
    final double innerD = math.max(6.0, d - t);

    final shelfCol = hasGlassShelves
        ? const Color(0xFF93C5FD)
        : _opaqueShade(carcassColor, 0.92);
    final doorCol = hasGlassDoors ? const Color(0xFFBAE6FD) : frontColor;

    final boxes = <_SolidBox>[
      _SolidBox(
          x: 0, y: 0, z: 0, w: t, h: h, d: d, baseColor: carcassColor, priority: 0),
      _SolidBox(
          x: w - t, y: 0, z: 0, w: t, h: h, d: d, baseColor: carcassColor, priority: 0),
      _SolidBox(
          x: t, y: 0, z: 0, w: innerW, h: t, d: d, baseColor: carcassColor, priority: 0),
      _SolidBox(
          x: t, y: h - t, z: 0, w: innerW, h: t, d: d, baseColor: carcassColor, priority: 0),
      _SolidBox(
          x: t,
          y: t,
          z: 0,
          w: innerW,
          h: innerH,
          d: 0.8,
          baseColor: _opaqueShade(carcassColor, 0.85),
          priority: 0),
    ];

    if (shelvesCount > 0) {
      final step = innerH / (shelvesCount + 1);
      for (int i = 1; i <= shelvesCount; i++) {
        boxes.add(_SolidBox(
          x: t + 0.2,
          y: t + step * i - t * 0.4,
          z: 0.8,
          w: math.max(2.0, innerW - 0.4),
          h: t * 0.8,
          d: math.max(4.0, innerD - 1.5),
          baseColor: shelfCol,
          priority: 1,
        ));
      }
    }

    final double drawersBandH =
        drawersCount > 0 ? math.min(innerH * 0.42, drawersCount * 16.0) : 0.0;
    if (drawersCount > 0) {
      final eachDH = drawersBandH / drawersCount;
      final startY = t + innerH - drawersBandH;
      for (int i = 0; i < drawersCount; i++) {
        final slideOut = isOpen ? math.min(innerD * 0.45, 12.0) : 0.0;
        final dy = startY + i * eachDH + 0.3;
        final dh = math.max(2.0, eachDH - 0.6);

        if (isOpen) {
          boxes.add(_SolidBox(
            x: t + 1.4,
            y: dy + 1.0,
            z: math.max(1.0, d - innerD) + slideOut * 0.7,
            w: math.max(2.0, innerW - 2.8),
            h: math.max(1.5, dh - 2.0),
            d: math.max(5.0, innerD - t - 1.5),
            baseColor: _opaqueShade(carcassColor, 0.88),
            priority: 1,
          ));
        }

        boxes.add(_SolidBox(
          x: t + 0.3,
          y: dy,
          z: math.max(1.0, d - t) + slideOut,
          w: math.max(2.0, innerW - 0.6),
          h: dh,
          d: t,
          baseColor: frontColor,
          priority: 2,
        ));
      }
    }

    if (doorsCount > 0) {
      final doorAreaH = math.max(8.0, innerH - drawersBandH);
      final eachDoorW = innerW / doorsCount;
      for (int i = 0; i < doorsCount; i++) {
        final dx = t + i * eachDoorW + 0.3;
        final dw = math.max(2.0, eachDoorW - 0.6);
        final hingeLeft = i < (doorsCount / 2);
        final shiftX = isOpen
            ? (hingeLeft ? -math.min(dw * 0.2, 5.0) : math.min(dw * 0.2, 5.0))
            : 0.0;
        final shiftZ = isOpen ? math.min(dw * 0.25, 6.5) : 0.0;

        boxes.add(_SolidBox(
          x: (dx + shiftX).clamp(t + 0.2, math.max(t + 0.2, t + innerW - dw * 0.75)),
          y: t + 0.3,
          z: math.max(1.0, d - t) + shiftZ,
          w: isOpen ? math.max(2.0, dw * 0.75) : dw,
          h: math.max(2.0, doorAreaH - 0.6),
          d: t,
          baseColor: doorCol,
          priority: 2,
        ));
      }
    }

    final maxDim = math.max(w, math.max(h, d * 1.4));
    final scale =
        (math.min(size.width, size.height) * 0.62 / math.max(30.0, maxDim)) *
            zoom;
    final center = Offset(size.width * 0.5, size.height * 0.53);
    final cx = w * 0.5, cy = h * 0.5, cz = d * 0.5;

    final cosY = math.cos(yaw), sinY = math.sin(yaw);
    final cosP = math.cos(pitch), sinP = math.sin(pitch);

    final camX = sinY * cosP;
    final camY = -sinP;
    final camZ = cosY * cosP;

    Offset proj(double mx, double my, double mz) {
      final dx = mx - cx, dy = my - cy, dz = mz - cz;
      final xr = dx * cosY - dz * sinY;
      final zr = dx * sinY + dz * cosY;
      final yr = dy * cosP - zr * sinP;
      return Offset(center.dx + xr * scale, center.dy + yr * scale);
    }

    double fDepth(List<List<double>> cList) {
      double sx = 0, sy = 0, sz = 0;
      for (final c in cList) {
        sx += c[0] - cx;
        sy += c[1] - cy;
        sz += c[2] - cz;
      }
      final n = cList.length.toDouble();
      return (sx / n) * camX + (sy / n) * camY + (sz / n) * camZ;
    }

    final faces = <_SolidFace>[];
    for (final b in boxes) {
      final x0 = b.x, x1 = b.x + b.w;
      final y0 = b.y, y1 = b.y + b.h;
      final z0 = b.z, z1 = b.z + b.d;

      final defs = <({List<List<double>> c, double nx, double ny, double nz, double sh})>[
        (c: [[x0, y0, z1], [x1, y0, z1], [x1, y1, z1], [x0, y1, z1]], nx: 0, ny: 0, nz: 1, sh: 1.0),
        (c: [[x1, y0, z0], [x0, y0, z0], [x0, y1, z0], [x1, y1, z0]], nx: 0, ny: 0, nz: -1, sh: 0.74),
        (c: [[x1, y0, z1], [x1, y0, z0], [x1, y1, z0], [x1, y1, z1]], nx: 1, ny: 0, nz: 0, sh: 0.86),
        (c: [[x0, y0, z0], [x0, y0, z1], [x0, y1, z1], [x0, y1, z0]], nx: -1, ny: 0, nz: 0, sh: 0.82),
        (c: [[x0, y0, z0], [x1, y0, z0], [x1, y0, z1], [x0, y0, z1]], nx: 0, ny: -1, nz: 0, sh: 1.06),
        (c: [[x0, y1, z1], [x1, y1, z1], [x1, y1, z0], [x0, y1, z0]], nx: 0, ny: 1, nz: 0, sh: 0.70),
      ];

      for (final fd in defs) {
        if (fd.nx * camX + fd.ny * camY + fd.nz * camZ <= 0.02) continue;
        faces.add(_SolidFace(
          pts: fd.c.map((pt) => proj(pt[0], pt[1], pt[2])).toList(),
          depth: fDepth(fd.c),
          priority: b.priority,
          fill: _opaqueShade(b.baseColor, fd.sh),
        ));
      }
    }

    faces.sort((a, b) {
      final cmp = a.depth.compareTo(b.depth);
      if (cmp.abs() > 0.35) return cmp;
      return a.priority.compareTo(b.priority);
    });

    final borderPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeJoin = StrokeJoin.round;

    for (final f in faces) {
      if (f.pts.isEmpty) continue;
      final path = Path()..moveTo(f.pts.first.dx, f.pts.first.dy);
      for (int i = 1; i < f.pts.length; i++) {
        path.lineTo(f.pts[i].dx, f.pts[i].dy);
      }
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..color = f.fill
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SolidPreset3DPainter oldDelegate) => true;
}