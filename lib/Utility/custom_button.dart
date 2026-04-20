import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'Colors/custom_theme_change.dart';
import 'custom_text.dart';


class CustomButton extends StatefulWidget {
  final void Function() onTap;
  final bool isLoading; // <--- externally controlled
  final double? height;
  final double? width;
  final BorderRadiusGeometry? borderRadius;
  final Gradient? gradient;
  final bool useDefaultGradient;
  final Color? backgroundColor;
  final String label;
  final Color? labelColor;
  final FontWeight? labelFontWeight;
  final BoxBorder? border;
  final double? labelFontSize;
  final bool isEnabled;

  const CustomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false, // <--- default
    this.height,
    this.width,
    this.borderRadius,
    this.gradient,
    this.useDefaultGradient = true,
    this.backgroundColor,
    this.isEnabled = true,
    this.labelColor,
    this.labelFontWeight,
    this.border,
    this.labelFontSize,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  double opacity = 1.0;

  void handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() {
      opacity = 0.2;
    });
  }

  void handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() {
      opacity = 1.0;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
      widget.onTap();
    });
  }

  void handleTapCancel() {
    if (!widget.isEnabled) return;
    setState(() {
      opacity = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = widget.borderRadius ?? BorderRadius.circular(22.sp);

    final Gradient? resolvedGradient =
        widget.gradient ??
        (widget.useDefaultGradient
            ? LinearGradient(
                colors: [
                  Color(0xFF007FFF),
                  Color(0xFF623EF8),
                  Color(0xFFBF00FF),
                ],
                stops: [0.0, 0.35, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null);

    return GestureDetector(
      onTapDown: handleTapDown,
      onTapUp: handleTapUp,
      onTapCancel: handleTapCancel,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: opacity,
        child: Semantics(
          label: widget.label,
          child: Container(
            height: widget.height ?? 5.h,
            width: widget.width ?? double.infinity,
            decoration: BoxDecoration(
              borderRadius: resolvedRadius,
              gradient: resolvedGradient,
              color: resolvedGradient == null
                  ? (widget.backgroundColor ??
                        ThemePrimaryColor.getPrimaryColor(context))
                  : null,
              border: widget.border,
            ),
            alignment: Alignment.center,
            child: CustomText(
              label: widget.label,
              fontSize: widget.labelFontSize ?? 16.sp,
              labelFontWeight: widget.labelFontWeight ?? FontWeight.bold,
              fontColour:
                  widget.labelColor ??
                  ThemeButtonTextColor.getButtonTextColor(context),
            ),
          ),
        ),
      ),
    );
  }
}





class CancelButton extends StatelessWidget {
  final void Function() onTap;
  final String label;

  const CancelButton({super.key, required this.onTap, this.label = "Cancel"});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: label,
      onTap: onTap,
      useDefaultGradient: false, // disable gradient
      backgroundColor: ThemeOutLineColor.getOutLineColor(context),
      borderRadius: BorderRadius.circular(30.sp),
      width: 35.w,
      height: 5.h,
      labelColor: ThemeTextColor.getTextColor(context),
      labelFontWeight: FontWeight.w600,
    );
  }
}

class CustomGestureButton extends StatefulWidget {
  final void Function() onTap;
  final Widget child;
  final bool isEnabled;

  const CustomGestureButton({
    super.key,
    required this.onTap,
    required this.child,
    this.isEnabled = true,
  });

  @override
  State<CustomGestureButton> createState() => _CustomGestureButtonState();
}

class _CustomGestureButtonState extends State<CustomGestureButton> {
  double opacity = 1.0;

  void handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() {
      opacity = 0.2;
    });
  }

  void handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() {
      opacity = 1.0;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
      widget.onTap();
    });
  }

  void handleTapCancel() {
    if (!widget.isEnabled) return;
    setState(() {
      opacity = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: handleTapDown,
      onTapUp: handleTapUp,
      onTapCancel: handleTapCancel,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: opacity,
        child: widget.child,
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final void Function() onTap;
  final Widget child;

  const CustomIconButton({super.key, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomGestureButton(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: child,
      ),
    );
  }
}
