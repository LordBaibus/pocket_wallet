import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'theme.dart';

/// Ring of dots with an orange "comet" that circles it (device-overview look).
class DotRing extends StatefulWidget {
  const DotRing({
    super.key,
    this.size = 120,
    this.dots = 56,
    this.child,
    this.animate = true,
  });

  final double size;
  final int dots;
  final Widget? child;
  final bool animate;

  @override
  State<DotRing> createState() => _DotRingState();
}

class _DotRingState extends State<DotRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => CustomPaint(
          painter: _RingPainter(t: _c.value, dots: widget.dots),
          child: Center(child: child),
        ),
        child: widget.child,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.t, required this.dots});
  final double t;
  final int dots;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 3;
    final base = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < dots; i++) {
      final f = i / dots;
      final a = -math.pi / 2 + 2 * math.pi * f;
      // distance behind the comet head, 0..1
      var behind = (t - f) % 1.0;
      if (behind < 0) behind += 1;
      final hot = behind < 0.22;
      final k = hot ? 1 - behind / 0.22 : 0.0;
      base.color = hot
          ? kAccent.withValues(alpha: 0.35 + 0.65 * k)
          : const Color(0xFFFFFFFF).withValues(alpha: 0.38);
      final rad = hot ? 1.6 + 1.0 * k : 1.5;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r, rad, base);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.t != t || old.dots != dots;
}

/// Bottom-aligned dot columns, like the token chart. Last columns are orange.
class DotWave extends StatelessWidget {
  const DotWave({
    super.key,
    this.height = 56,
    this.columns = 28,
    this.hotColumns = 4,
    this.seed = 0,
  });

  final double height;
  final int columns;
  final int hotColumns;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _WavePainter(columns, hotColumns, seed),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.columns, this.hot, this.seed);
  final int columns;
  final int hot;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 6.0;
    final rows = (size.height / gap).floor();
    final colW = size.width / columns;
    final p = Paint();
    for (var i = 0; i < columns; i++) {
      final s = (math.sin((i + seed) * 0.7) * math.cos((i + seed) * 0.29)).abs();
      final h = (0.2 + 0.8 * s) * rows;
      final isHot = i >= columns - hot;
      for (var j = 0; j < h.round(); j++) {
        p.color = isHot
            ? kAccent
            : const Color(0xFFFFFFFF).withValues(alpha: 0.28 + 0.3 * (j / rows));
        canvas.drawCircle(
          Offset(colW * i + colW / 2, size.height - gap / 2 - j * gap),
          1.5,
          p,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => false;
}

/// One horizontal row of dots with a thin pulse: "—·|||·—" waveform.
class DotLine extends StatelessWidget {
  const DotLine({super.key, this.height = 28});
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _LinePainter()),
      );
}

class _LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    final mid = size.height / 2;
    const step = 5.0;
    final n = (size.width / step).floor();
    for (var i = 0; i < n; i++) {
      final x = i * step + step / 2;
      final f = i / n;
      final burst = math.exp(-math.pow((f - 0.42) * 7, 2)) +
          0.7 * math.exp(-math.pow((f - 0.72) * 9, 2));
      final amp = burst * (size.height / 2 - 2) * (0.5 + 0.5 * math.sin(i * 1.7).abs());
      final hot = f > 0.36 && f < 0.5;
      p.color = hot ? kAccent : const Color(0xFFFFFFFF).withValues(alpha: 0.5);
      canvas.drawCircle(Offset(x, mid), 1.2, p);
      for (var k = 1; k * 4 < amp; k++) {
        canvas.drawCircle(Offset(x, mid - k * 4), 1.2, p);
        canvas.drawCircle(Offset(x, mid + k * 4), 1.2, p);
      }
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => false;
}
