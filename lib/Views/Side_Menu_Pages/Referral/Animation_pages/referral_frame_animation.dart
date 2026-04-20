import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class _Particle {
  final double angle, radius, size, speed, phase;
  const _Particle({required this.angle, required this.radius,
    required this.size, required this.speed, required this.phase});
}


//////////////////////////// 1 //////////////////////////////////////////////
class BulletBurstFrame extends StatefulWidget {
  final String framePath;
  final double size;
  final Color glowColor;
  final int bulletCount;

  const BulletBurstFrame({
    super.key, required this.framePath,
    this.size = 90, required this.glowColor, this.bulletCount = 10,
  });
  @override State<BulletBurstFrame> createState() => _BulletBurstFrameState();
}

class _BulletBurstFrameState extends State<BulletBurstFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2000))..repeat();
    final rng = Random(42);
    _particles = List.generate(widget.bulletCount, (i) => _Particle(
      angle:  (i / widget.bulletCount) * 2 * pi,
      radius: widget.size * 0.62,
      size:   rng.nextDouble() * 3 + 2.5,
      speed:  0.6 + rng.nextDouble() * 0.5,
      phase:  i / widget.bulletCount,
    ));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final double canvasSize = widget.size * 1;
    final double center = canvasSize / 2;

    return SizedBox(
      width: canvasSize, height: canvasSize,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          final t = _ctrl.value;
          final floatY = sin(t * 2 * pi) * 3.5;
          final glowOp = 0.18 + 0.22 * sin(t * 2 * pi).abs();

          return Stack(
            alignment: Alignment.center,
            children: [
              // Glow ring
              Container(
                width: widget.size * 1.15, height: widget.size * 1.15,
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(color: widget.glowColor.withOpacity(glowOp),
                      blurRadius: widget.size * 0.4, spreadRadius: 2),
                ]),
              ),

              // Bullet particles
              ..._particles.map((p) {
                final phase = (_ctrl.value + p.phase) % 1.0;
                final eased = Curves.easeOut.transform(phase);
                final r = eased * p.radius;
                final opacity = phase < 0.65 ? 1.0
                    : 1.0 - (phase - 0.65) / 0.35;
                final bx = cos(p.angle) * r;
                final by = sin(p.angle) * r;

                // Tail
                final tPhase = max(0.0, phase - 0.08);
                final tR = Curves.easeOut.transform(tPhase) * p.radius;
                final tailOp = (opacity * 0.38).clamp(0.0, 1.0);

                return Stack(children: [
                  // Tail dot
                  Positioned(
                    left: center + cos(p.angle)*tR - p.size*0.4,
                    top:  center + sin(p.angle)*tR - p.size*0.4,
                    child: Opacity(opacity: tailOp,
                        child: Container(width: p.size*0.8, height: p.size*0.8,
                            decoration: BoxDecoration(
                                color: widget.glowColor, shape: BoxShape.circle))),
                  ),
                  // Bullet
                  Positioned(
                    left: center + bx - p.size / 2,
                    top:  center + by - p.size / 2,
                    child: Opacity(opacity: opacity.clamp(0.0, 1.0),
                        child: Container(
                          width: p.size, height: p.size,
                          decoration: BoxDecoration(
                            color: widget.glowColor, shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                                color: widget.glowColor.withOpacity(0.6),
                                blurRadius: 4, spreadRadius: 0.5)],
                          ),
                        )),
                  ),
                ]);
              }),

              // Frame
              Transform.translate(
                offset: Offset(0, floatY),
                child: SvgPicture.asset(widget.framePath,
                    width: widget.size, height: widget.size),
              ),
            ],
          );
        },
      ),
    );
  }
}


//////////////////////////// 2 //////////////////////////////////////////////
class WarDanceFrame extends StatefulWidget {
  final String framePath;
  final double size;
  final Color glowColor;

  const WarDanceFrame({super.key, required this.framePath,
    this.size = 90, required this.glowColor});
  @override State<WarDanceFrame> createState() => _WarDanceFrameState();
}

class _WarDanceFrameState extends State<WarDanceFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1800))..repeat();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final t = _ctrl.value;
        final sinV = sin(t * 2 * pi);
        final tx = sinV * 10.0;
        final ty = -sinV.abs() * 4.0;
        final angle = sinV * (14.0 * pi / 180.0);
        final glowOp = sinV.abs() * 0.45;

        return SizedBox(
          width: widget.size * 2.2, height: widget.size * 2.2,
          child: Stack(alignment: Alignment.center, children: [
            // Glow
            Container(
              width: widget.size * 1.2, height: widget.size * 1.2,
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                BoxShadow(color: widget.glowColor.withOpacity(glowOp),
                    blurRadius: widget.size * 0.5, spreadRadius: 3),
              ]),
            ),

            // Ghost trails (3 behind)
            for (int i = 3; i >= 1; i--)
                  () {
                final trailT = (t - i * 0.055 + 1.0) % 1.0;
                final trailSin = sin(trailT * 2 * pi);
                final ttx = trailSin * 10.0;
                final tty = -trailSin.abs() * 4.0;
                final trailAngle = trailSin * (14.0 * pi / 180.0);
                final trailOp = (0.25 - i * 0.06) * sinV.abs();
                return Transform.translate(
                  offset: Offset(ttx, tty),
                  child: Transform.rotate(
                    angle: trailAngle,
                    child: Opacity(
                      opacity: trailOp.clamp(0.0, 1.0),
                      child: SvgPicture.asset(widget.framePath,
                          width: widget.size, height: widget.size,
                          colorFilter: ColorFilter.mode(
                              widget.glowColor, BlendMode.srcATop)),
                    ),
                  ),
                );
              }(),

            // Main frame
            Transform.translate(
              offset: Offset(tx, ty),
              child: Transform.rotate(
                angle: angle,
                child: child!,
              ),
            ),
          ]),
        );
      },
      child: SvgPicture.asset(widget.framePath,
          width: widget.size, height: widget.size),
    );
  }
}


//////////////////////////// 3 //////////////////////////////////////////////

class SpinPopFrame extends StatefulWidget {
  final String framePath;
  final double size;
  final Color glowColor;

  const SpinPopFrame({super.key, required this.framePath,
    this.size = 90, required this.glowColor});
  @override State<SpinPopFrame> createState() => _SpinPopFrameState();
}

class _SpinPopFrameState extends State<SpinPopFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2400))..repeat();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final t = _ctrl.value;
        double rotAngle, scale, glowOp;

        if (t < 0.5) {
          final p = t * 2;
          rotAngle = p * 2 * pi;
          scale    = 1.0 + 0.15 * sin(p * pi);
          glowOp   = 0.6 * sin(p * pi);
        } else {
          final p = (t - 0.5) * 2;
          rotAngle = 0;
          scale    = 1.0 + 0.06 * sin(p * pi);
          glowOp   = 0.15 + 0.2 * sin(p * pi);
        }

        return SizedBox(
          width: widget.size * 2.2, height: widget.size * 2.2,
          child: Stack(alignment: Alignment.center, children: [
            // Pop sparks at landing moment
            if (t > 0.5 && t < 0.65)
              CustomPaint(
                size: Size(widget.size * 2.2, widget.size * 2.2),
                painter: _SparkBurstPainter(
                  progress: (t - 0.5) / 0.15,
                  color: widget.glowColor,
                  radius: widget.size * 0.5,
                ),
              ),

            // Glow
            Container(
              width: widget.size * 1.2 * scale,
              height: widget.size * 1.2 * scale,
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                BoxShadow(color: widget.glowColor.withOpacity(glowOp),
                    blurRadius: widget.size * 0.5, spreadRadius: 3),
              ]),
            ),

            // Frame
            Transform.rotate(
              angle: rotAngle,
              child: Transform.scale(scale: scale, child: child!),
            ),
          ]),
        );
      },
      child: SvgPicture.asset(widget.framePath,
          width: widget.size, height: widget.size),
    );
  }
}

class _SparkBurstPainter extends CustomPainter {
  final double progress, radius;
  final Color color;
  _SparkBurstPainter({required this.progress, required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 8; i++) {
      final angle = (pi * 2 / 8) * i;
      final r0 = radius;
      final r1 = radius + progress * 22;
      canvas.drawLine(
        Offset(c.dx + r0 * cos(angle), c.dy + r0 * sin(angle)),
        Offset(c.dx + r1 * cos(angle), c.dy + r1 * sin(angle)),
        Paint()
          ..color = color.withOpacity((1 - progress) * 0.9)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawCircle(
        Offset(c.dx + r1 * cos(angle), c.dy + r1 * sin(angle)), 3,
        Paint()..color = color.withOpacity((1 - progress) * 0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }
  @override bool shouldRepaint(_SparkBurstPainter o) => o.progress != progress;
}



//////////////////////////// 4 //////////////////////////////////////////////
class ShockwaveFrame extends StatefulWidget {
  final String framePath;
  final double size;
  final Color glowColor;

  const ShockwaveFrame({super.key, required this.framePath,
    this.size = 90, required this.glowColor});
  @override State<ShockwaveFrame> createState() => _ShockwaveFrameState();
}

class _ShockwaveFrameState extends State<ShockwaveFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2200))..repeat();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final t = _ctrl.value;
        final floatY = sin(t * 2 * pi) * 5.0;
        final tilt   = sin(t * 4 * pi) * (5.0 * pi / 180.0);
        final glowOp = 0.15 + 0.22 * ((sin(t * 2 * pi) + 1) / 2);

        return SizedBox(
          width: widget.size * 2.4, height: widget.size * 2.4,
          child: Stack(alignment: Alignment.center, children: [
            // Shockwave rings (3, staggered)
            for (int w = 0; w < 3; w++)
              CustomPaint(
                size: Size(widget.size * 2.4, widget.size * 2.4),
                painter: _ShockwaveRingPainter(
                  t: (t * 2.5 + w / 3) % 1.0,
                  color: widget.glowColor,
                  baseRadius: widget.size * 0.48,
                  offsetY: floatY,
                ),
              ),

            // Glow
            Transform.translate(
              offset: Offset(0, floatY),
              child: Container(
                width: widget.size * 1.15, height: widget.size * 1.15,
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(color: widget.glowColor.withOpacity(glowOp),
                      blurRadius: widget.size * 0.45, spreadRadius: 2),
                ]),
              ),
            ),

            // Frame
            Transform.translate(
              offset: Offset(0, floatY),
              child: Transform.rotate(angle: tilt, child: child!),
            ),
          ]),
        );
      },
      child: SvgPicture.asset(widget.framePath,
          width: widget.size, height: widget.size),
    );
  }
}

class _ShockwaveRingPainter extends CustomPainter {
  final double t, baseRadius, offsetY;
  final Color color;
  _ShockwaveRingPainter({required this.t, required this.color,
    required this.baseRadius, required this.offsetY});

  @override
  void paint(Canvas canvas, Size size) {
    final ease = 1.0 - pow(1.0 - t, 3).toDouble();
    final center = Offset(size.width / 2, size.height / 2 + offsetY);
    final r = baseRadius + ease * 50;
    final op = (1 - t) * 0.65;
    canvas.drawCircle(center, r, Paint()
      ..color = color.withOpacity(op)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8 * (1 - ease * 0.75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
  }
  @override bool shouldRepaint(_ShockwaveRingPainter o) => o.t != t;
}

//////////////////////////// 5 //////////////////////////////////////////////
class PowerBounceFrame extends StatefulWidget {
  final String framePath;
  final double size;
  final Color glowColor;

  const PowerBounceFrame({super.key, required this.framePath,
    this.size = 90, required this.glowColor});
  @override State<PowerBounceFrame> createState() => _PowerBounceFrameState();
}

class _PowerBounceFrameState extends State<PowerBounceFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1400))..repeat();
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final t = _ctrl.value;
        final sinV = sin(t * pi).abs();
        final ty   = -sinV * 14.0;
        final scaleY = t < 0.5
            ? 1.0 + 0.07 * sin(t * pi)
            : 1.0 - 0.04 * sin((t - 0.5) * pi);
        final scaleX = 2.0 - scaleY;
        final glowOp = sinV * 0.5;

        return SizedBox(
          width: widget.size * 2.2, height: widget.size * 1.5,
          child: Stack(alignment: Alignment.center, children: [
            // Ground shadow (shrinks when frame is high)
            Positioned(
              bottom: widget.size * 0.1,
              child: Transform.scale(
                scaleX: 1.0 - sinV * 0.55,
                scaleY: 0.22 * (1 - sinV * 0.5),
                child: Container(
                  width: widget.size * 0.95,
                  height: widget.size * 0.95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.glowColor.withOpacity(0.18 * (1 - sinV)),
                  ),
                ),
              ),
            ),

            // Glow
            Transform.translate(
              offset: Offset(0, ty),
              child: Container(
                width: widget.size * 1.2, height: widget.size * 1.2,
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(color: widget.glowColor.withOpacity(glowOp),
                      blurRadius: widget.size * 0.45, spreadRadius: 3),
                ]),
              ),
            ),

            // Frame with squash/stretch
            Transform.translate(
              offset: Offset(0, ty),
              child: Transform.scale(
                scaleX: scaleX, scaleY: scaleY,
                child: child!,
              ),
            ),
          ]),
        );
      },
      child: SvgPicture.asset(widget.framePath,
          width: widget.size, height: widget.size),
    );
  }
}