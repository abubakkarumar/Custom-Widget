import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/custom_text.dart';

class ReferralCircleBadge extends StatelessWidget {
  final double size;
  final double ringWidth;
  final Color innerColor;
  final Gradient gradient;
  final Widget child;
  final double margin;

  const ReferralCircleBadge({
    super.key,
    required this.child,
    this.size = 22,
    this.ringWidth = 2,
    this.innerColor = const Color(0xFF1A1C2E),
    this.margin = 2,
    this.gradient = const LinearGradient(
      colors: [Color(0xFF007FFF), Color(0xFF623EF8), Color(0xFFBF00FF)],
      stops: [0.0, 0.35, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(margin.sp),
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradient,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x552F39FF),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(ringWidth),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF007FFF),
                    Color(0xFF623EF8),
                    Color(0xFFBF00FF),
                  ],
                  stops: [0.0, 0.35, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class ReferralTickBadge extends StatelessWidget {
  final double size;
  final Color iconColor;

  const ReferralTickBadge({
    super.key,
    this.size = 20,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ReferralCircleBadge(
      size: size,
      ringWidth: 2.sp,
      child: Icon(
        Icons.check,
        size: size * 0.55,
        color: iconColor,
      ),
    );
  }
}

class ReferralCountBadge extends StatelessWidget {
  final String label;
  final double size;
  final double fontSize;

  const ReferralCountBadge({
    super.key,
    required this.label,
    this.size = 24,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ReferralCircleBadge(
      size: size,
      ringWidth: 2.sp,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: CustomText(
          label: label,
          fontSize: fontSize,
          labelFontWeight: FontWeight.w600,
          fontColour: Colors.white,
        ),
      ),
    );
  }
}
