import 'dart:math' as math;
import 'package:flutter/material.dart';

class CabinetColorPickerPanel extends StatefulWidget {
  final String partLabel;
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onResetDefault;

  const CabinetColorPickerPanel({
    super.key,
    required this.partLabel,
    required this.currentColor,
    required this.onColorChanged,
    required this.onResetDefault,
  });

  @override
  State<CabinetColorPickerPanel> createState() => _CabinetColorPickerPanelState();
}

class _CabinetColorPickerPanelState extends State<CabinetColorPickerPanel> {
  int _tabIndex = 0; // 0 = ألوان جاهزة، 1 = عجلة وطيف ألوان كامل
  late double _hue;
  late double _sat;
  late double _light;

  final List<Color> _customColors = [];

  static const List<({String name, Color color})> _presets = [
    (name: "أبيض سوليد", color: Color(0xFFF1F5F9)),
    (name: "بلوط طبيعي", color: Color(0xFFD6A86C)),
    (name: "جوزي غامق", color: Color(0xFF7C4D2B)),
    (name: "جرافيت سوليد", color: Color(0xFF334155)),
    (name: "أزرق سماوي", color: Color(0xFF0EA5E9)),
    (name: "تيل مميز", color: Color(0xFF14B8A6)),
    (name: "كهرماني", color: Color(0xFFF59E0B)),
    (name: "رمادي ظهر", color: Color(0xFF64748B)),
    (name: "أخضر زيتوني", color: Color(0xFF65A30D)),
    (name: "أحمر عنبري", color: Color(0xFFDC2626)),
    (name: "بنفسجي", color: Color(0xFF9333EA)),
    (name: "وردي", color: Color(0xFFEC4899)),
    (name: "سماوي فاتح", color: Color(0xFF67E8F9)),
    (name: "أخضر داكن", color: Color(0xFF14532D)),
    (name: "بني خشبي", color: Color(0xFF713F12)),
    (name: "أسود مط", color: Color(0xFF0F172A)),
  ];

  @override
  void initState() {
    super.initState();
    _syncFromColor(widget.currentColor);
  }

  @override
  void didUpdateWidget(covariant CabinetColorPickerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentColor.toARGB32() != widget.currentColor.toARGB32()) {
      _syncFromColor(widget.currentColor);
    }
  }

  void _syncFromColor(Color c) {
    final hsl = HSLColor.fromColor(c);
    _hue = hsl.hue;
    _sat = hsl.saturation.clamp(0.0, 1.0);
    _light = hsl.lightness.clamp(0.05, 0.96);
  }

  Color _buildHslColor() {
    return HSLColor.fromAHSL(
      1.0,
      _hue.clamp(0.0, 360.0),
      _sat.clamp(0.0, 1.0),
      _light.clamp(0.05, 0.96),
    ).toColor();
  }

  void _updateHsl(double h, double s, double l) {
    setState(() {
      _hue = h.clamp(0.0, 360.0);
      _sat = s.clamp(0.0, 1.0);
      _light = l.clamp(0.05, 0.96);
    });
    widget.onColorChanged(_buildHslColor());
  }

  @override
  Widget build(BuildContext context) {
    final col = widget.currentColor;
    final r = (col.r * 255.0).round();
    final g = (col.g * 255.0).round();
    final b = (col.b * 255.0).round();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amberAccent, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: col,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white38),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "الجزء: ${widget.partLabel}",
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent,
                  ),
                ),
              ),
              InkWell(
                onTap: widget.onResetDefault,
                child: const Text(
                  "افتراضي",
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF2DD4BF)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _tabBtn("ألوان جاهزة", 0, Icons.grid_view)),
              const SizedBox(width: 6),
              Expanded(child: _tabBtn("عجلة الألوان", 1, Icons.color_lens)),
            ],
          ),
          const SizedBox(height: 8),
          if (_tabIndex == 0)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _presets.map((p) {
                final active = col.toARGB32() == p.color.toARGB32();
                return Tooltip(
                  message: p.name,
                  child: InkWell(
                    onTap: () {
                      _syncFromColor(p.color);
                      widget.onColorChanged(p.color);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: p.color,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: active ? Colors.white : Colors.black54,
                          width: active ? 2.3 : 1.0,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          else ...[
            Center(
              child: GestureDetector(
                onPanDown: (d) => _handleWheelPointer(d.localPosition, 168),
                onPanUpdate: (d) => _handleWheelPointer(d.localPosition, 168),
                child: CustomPaint(
                  size: const Size(168, 168),
                  painter: _ColorWheelPainter(
                    hue: _hue,
                    sat: _sat,
                    light: _light,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniChannelBox("R", "$r"),
                _miniChannelBox("G", "$g"),
                _miniChannelBox("B", "$b"),
                _miniChannelBox("H", "${_hue.round()}°"),
                _miniChannelBox("S", "${(_sat * 100).round()}%"),
                _miniChannelBox("L", "${(_light * 100).round()}%"),
              ],
            ),
            const SizedBox(height: 6),
            const Text("الإضاءة / السطوع (Lightness)",
                style: TextStyle(fontSize: 10, color: Colors.white70)),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 5,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6.5),
              ),
              child: Slider(
                value: _light,
                min: 0.05,
                max: 0.96,
                activeColor: Colors.amberAccent,
                onChanged: (v) => _updateHsl(_hue, _sat, v),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    if (_customColors.length >= 12) {
                      _customColors.removeAt(0);
                    }
                    _customColors.add(col);
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  side: const BorderSide(color: Colors.white24),
                ),
                child: const Text("حفظ في الألوان المخصصة",
                    style: TextStyle(fontSize: 10.5, color: Colors.white70)),
              ),
            ),
            if (_customColors.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: _customColors.map((cc) {
                  return InkWell(
                    onTap: () {
                      _syncFromColor(cc);
                      widget.onColorChanged(cc);
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: cc,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white38),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _handleWheelPointer(Offset pos, double sizePx) {
    final center = Offset(sizePx / 2, sizePx / 2);
    final dx = pos.dx - center.dx;
    final dy = pos.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final outerR = sizePx / 2 - 4;
    final innerR = outerR * 0.74;
    final sqHalf = innerR * 0.68;

    if (dist >= innerR * 0.92) {
      double angleDeg = (math.atan2(dy, dx) * 180 / math.pi) % 360;
      if (angleDeg < 0) angleDeg += 360;
      _updateHsl(angleDeg, _sat, _light);
    } else {
      final nx = ((dx + sqHalf) / (sqHalf * 2)).clamp(0.0, 1.0);
      final ny = ((dy + sqHalf) / (sqHalf * 2)).clamp(0.0, 1.0);
      _updateHsl(_hue, nx, (1.0 - ny) * 0.88 + 0.08);
    }
  }

  Widget _miniChannelBox(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "$label:$val",
        style: const TextStyle(fontSize: 9.5, color: Colors.white70),
      ),
    );
  }

  Widget _tabBtn(String label, int index, IconData icon) {
    final active = _tabIndex == index;
    return InkWell(
      onTap: () => setState(() => _tabIndex = index),
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF14B8A6) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 13, color: active ? Colors.black : Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: active ? Colors.black : Colors.white70,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorWheelPainter extends CustomPainter {
  final double hue;
  final double sat;
  final double light;

  _ColorWheelPainter({
    required this.hue,
    required this.sat,
    required this.light,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2 - 4;
    final innerR = outerR * 0.74;

    const int steps = 72;
    for (int i = 0; i < steps; i++) {
      final a0 = (i * 2 * math.pi) / steps;
      final a1 = ((i + 1) * 2 * math.pi) / steps;
      final midDeg = ((i + 0.5) * 360.0) / steps;
      final c = HSLColor.fromAHSL(1.0, midDeg, 1.0, 0.5).toColor();

      final p0Out = Offset(center.dx + outerR * math.cos(a0),
          center.dy + outerR * math.sin(a0));
      final p1Out = Offset(center.dx + outerR * math.cos(a1),
          center.dy + outerR * math.sin(a1));
      final p1In = Offset(center.dx + innerR * math.cos(a1),
          center.dy + innerR * math.sin(a1));
      final p0In = Offset(center.dx + innerR * math.cos(a0),
          center.dy + innerR * math.sin(a0));

      final seg = Path()
        ..moveTo(p0Out.dx, p0Out.dy)
        ..lineTo(p1Out.dx, p1Out.dy)
        ..lineTo(p1In.dx, p1In.dy)
        ..lineTo(p0In.dx, p0In.dy)
        ..close();

      canvas.drawPath(seg, Paint()..color = c);
    }

    final sqHalf = innerR * 0.68;
    final sqRect = Rect.fromCenter(
      center: center,
      width: sqHalf * 2,
      height: sqHalf * 2,
    );
    final pureHue = HSLColor.fromAHSL(1.0, hue, 1.0, 0.5).toColor();

    canvas.drawRect(
      sqRect,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, pureHue],
        ).createShader(sqRect),
    );
    canvas.drawRect(
      sqRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black],
        ).createShader(sqRect),
    );
    canvas.drawRect(
      sqRect,
      Paint()
        ..color = Colors.white54
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final hueRad = hue * math.pi / 180;
    final ringMid = (outerR + innerR) / 2;
    final huePos = Offset(
      center.dx + ringMid * math.cos(hueRad),
      center.dy + ringMid * math.sin(hueRad),
    );
    canvas.drawCircle(
      huePos,
      6,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    final normY = (1.0 - ((light - 0.08) / 0.88)).clamp(0.0, 1.0);
    final slPos = Offset(
      sqRect.left + sat * sqRect.width,
      sqRect.top + normY * sqRect.height,
    );
    canvas.drawCircle(
      slPos,
      5.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant _ColorWheelPainter oldDelegate) => true;
}