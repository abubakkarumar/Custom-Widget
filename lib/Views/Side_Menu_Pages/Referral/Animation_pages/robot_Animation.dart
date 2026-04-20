import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─────────────────────────────────────────────
// 1. BOUNCE  — reduced height, slower, colored glow
// ─────────────────────────────────────────────
class BouncingRobot extends StatefulWidget {
  final String robotAsset;
  final double size;
  final Color glowColor;

  const BouncingRobot({
    super.key,
    required this.robotAsset,
    this.size = 80,
    this.glowColor = const Color(0xFF2E64C8), // default blue
  });

  @override
  State<BouncingRobot> createState() => _BouncingRobotState();
}

class _BouncingRobotState extends State<BouncingRobot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400), // slower (was 600ms)
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _controller.value;

        final sinVal = sin(phase * pi).abs();
        final translateY = -sinVal * 8.0; // reduced (was 22.0)

        // Subtle squash & stretch
        final scaleY = phase < 0.5
            ? 1.0 + 0.05 * sin(phase * pi)   // reduced (was 0.12)
            : 1.0 - 0.03 * sin((phase - 0.5) * pi); // reduced (was 0.08)
        final scaleX = 2.0 - scaleY;

        final glowOpacity = sinVal * 0.45;

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(
            scaleX: scaleX,
            scaleY: scaleY,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: widget.size * 1.25,
                  height: widget.size * 1.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.glowColor.withOpacity(glowOpacity),
                        blurRadius: widget.size * 0.5,
                        spreadRadius: widget.size * 0.05,
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  widget.robotAsset,
                  width: widget.size,
                  height: widget.size,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// 2. DANCE  — slower sway, colored glow
// ─────────────────────────────────────────────
class DancingRobot extends StatefulWidget {
  final String robotAsset;
  final double size;
  final Color glowColor;

  const DancingRobot({
    super.key,
    required this.robotAsset,
    this.size = 80,
    this.glowColor = const Color(0xFF2E64C8),
  });

  @override
  State<DancingRobot> createState() => _DancingRobotState();
}

class _DancingRobotState extends State<DancingRobot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800), // slower (was 800ms)
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _controller.value;
        final sinVal = sin(phase * 2 * pi);
        final translateX = sinVal * 8.0;             // reduced (was 12.0)
        final translateY = -sin(phase * 2 * pi).abs() * 3.0; // reduced (was 6.0)
        final rotateAngle = sinVal * (10.0 * pi / 180.0); // reduced (was 18°)
        final glowOpacity = sinVal.abs() * 0.40;

        return Transform.translate(
          offset: Offset(translateX, translateY),
          child: Transform.rotate(
            angle: rotateAngle,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: widget.size * 1.25,
                  height: widget.size * 1.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.glowColor.withOpacity(glowOpacity),
                        blurRadius: widget.size * 0.5,
                        spreadRadius: widget.size * 0.05,
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  widget.robotAsset,
                  width: widget.size,
                  height: widget.size,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// 3. WAVE & NOD  — slower float, colored glow
// ─────────────────────────────────────────────
class WavingRobot extends StatefulWidget {
  final String robotAsset;
  final double size;
  final Color glowColor;

  const WavingRobot({
    super.key,
    required this.robotAsset,
    this.size = 80,
    this.glowColor = const Color(0xFF2E64C8),
  });

  @override
  State<WavingRobot> createState() => _WavingRobotState();
}

class _WavingRobotState extends State<WavingRobot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // slower (was 2000ms)
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _controller.value;
        final translateY = sin(phase * 2 * pi) * 5.0;       // reduced (was 8.0)
        final rotateAngle = sin(phase * 4 * pi) * (5.0 * pi / 180.0); // reduced (was 8°)
        final scale = 0.96 + 0.04 * sin(phase * 2 * pi);   // reduced (was 0.92→1.0)
        final glowOpacity = 0.15 + 0.25 * ((sin(phase * 2 * pi) + 1) / 2);

        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.rotate(
            angle: rotateAngle,
            child: Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: widget.size * 1.25,
                    height: widget.size * 1.25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.glowColor.withOpacity(glowOpacity),
                          blurRadius: widget.size * 0.5,
                          spreadRadius: widget.size * 0.05,
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    widget.robotAsset,
                    width: widget.size,
                    height: widget.size,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// 4. SPIN & POP  — slower spin, colored glow
// ─────────────────────────────────────────────
class SpinningRobot extends StatefulWidget {
  final String robotAsset;
  final double size;
  final Color glowColor;

  const SpinningRobot({
    super.key,
    required this.robotAsset,
    this.size = 80,
    this.glowColor = const Color(0xFF2E64C8),
  });

  @override
  State<SpinningRobot> createState() => _SpinningRobotState();
}

class _SpinningRobotState extends State<SpinningRobot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400), // slower (was 1200ms)
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _controller.value;
        double rotateAngle;
        double scale;
        double glowOpacity;

        if (phase < 0.5) {
          final p = phase * 2;
          rotateAngle = p * 2 * pi;
          scale = 1.0 + 0.15 * sin(p * pi);       // reduced (was 0.25)
          glowOpacity = 0.6 * sin(p * pi);         // reduced (was 0.8)
        } else {
          final p = (phase - 0.5) * 2;
          rotateAngle = 0;
          scale = 1.0 + 0.06 * sin(p * pi);       // reduced (was 0.1)
          glowOpacity = 0.15 + 0.2 * sin(p * pi); // reduced (was 0.2+0.3)
        }

        return Transform.rotate(
          angle: rotateAngle,
          child: Transform.scale(
            scale: scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: widget.size * 1.25,
                  height: widget.size * 1.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.glowColor.withOpacity(glowOpacity),
                        blurRadius: widget.size * 0.5,
                        spreadRadius: widget.size * 0.05,
                      ),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  widget.robotAsset,
                  width: widget.size,
                  height: widget.size,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



// ─────────────────────────────────────────────
// SHARED — Bullet particle model
// ─────────────────────────────────────────────
class _Bullet {
  final double angle;
  final double radius;
  final double size;
  final double speed;
  final double phase;

  const _Bullet({
    required this.angle,
    required this.radius,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

// ─────────────────────────────────────────────
// BULLET BURST ROBOT
// ─────────────────────────────────────────────
class BulletBurstRobot extends StatefulWidget {
  final String robotAsset;
  final double size;
  final Color glowColor;
  final int bulletCount;

  const BulletBurstRobot({
    super.key,
    required this.robotAsset,
    this.size = 80,
    required this.glowColor ,
    this.bulletCount = 8,
  });

  @override
  State<BulletBurstRobot> createState() => _BulletBurstRobotState();
}

class _BulletBurstRobotState extends State<BulletBurstRobot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Bullet> _bullets;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // slower burst
    )..repeat();

    final rng = Random(55);
    _bullets = List.generate(widget.bulletCount, (i) {
      return _Bullet(
        angle: (i / widget.bulletCount) * 2 * pi,
        radius: widget.size * 0.55, // reduced orbit radius
        size: rng.nextDouble() * 3 + 2.5, // smaller bullets
        speed: 0.6 + rng.nextDouble() * 0.6,
        phase: i / widget.bulletCount,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Total canvas = robot + bullet travel room (compact)
    final double canvasSize = widget.size + (widget.size * 0.55 * 2) + 8;
    final double center = canvasSize / 2;

    return SizedBox(
      width: canvasSize,
      height: canvasSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final phase = _controller.value;

          // Robot gentle float — very small
          final floatY = sin(phase * 2 * pi) * 3.0;
          final robotScale = 0.97 + 0.03 * sin(phase * 2 * pi);
          final glowOpacity = 0.18 + 0.22 * sin(phase * 2 * pi).abs();

          return Stack(
            alignment: Alignment.center,
            children: [
              // ── Glow ring (tight, behind everything)
              Container(
                width: widget.size * 1.15,
                height: widget.size * 1.15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(glowOpacity),
                      blurRadius: widget.size * 0.35,
                      spreadRadius: widget.size * 0.04,
                    ),
                  ],
                ),
              ),

              // ── Burst bullets
              ..._bullets.map((b) {
                final t = (_controller.value + b.phase) % 1.0;
                final eased = Curves.easeOut.transform(t);
                final currentRadius = eased * b.radius;

                // Fade out in last 35%
                final opacity = t < 0.65
                    ? 1.0
                    : 1.0 - ((t - 0.65) / 0.35);

                final bx = cos(b.angle) * currentRadius;
                final by = sin(b.angle) * currentRadius;

                // Tail — slightly behind the main bullet
                final tailT = (t - 0.07).clamp(0.0, 1.0);
                final tailEased = Curves.easeOut.transform(tailT);
                final tailRadius = tailEased * b.radius;
                final tailOpacity = (opacity * 0.38).clamp(0.0, 1.0);
                final tailBx = cos(b.angle) * tailRadius;
                final tailBy = sin(b.angle) * tailRadius;

                return Stack(
                  children: [
                    // Tail dot
                    Positioned(
                      left: center + tailBx - (b.size * 0.5) / 2,
                      top: center + tailBy - (b.size * 0.5) / 2,
                      child: Opacity(
                        opacity: tailOpacity,
                        child: Container(
                          width: b.size * 0.5,
                          height: b.size * 0.5,
                          decoration: BoxDecoration(
                            color: widget.glowColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    // Main bullet
                    Positioned(
                      left: center + bx - b.size / 2,
                      top: center + by - b.size / 2,
                      child: Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Container(
                          width: b.size,
                          height: b.size,
                          decoration: BoxDecoration(
                            color: widget.glowColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.glowColor.withOpacity(0.55),
                                blurRadius: 3,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              // ── Robot SVG (floats gently on top)
              Transform.translate(
                offset: Offset(0, floatY),
                child: Transform.scale(
                  scale: robotScale,
                  child: SvgPicture.asset(
                    widget.robotAsset,
                    width: widget.size,
                    height: widget.size,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}