import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import 'Basics/app_navigator.dart';

enum ToastType { success, error }

class CustomAnimationToast {
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 2),
    Alignment alignment = Alignment.topCenter,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ToastOverlay(
        message: message,
        type: type,
        alignment: alignment,
        duration: duration,
        onClosed: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _ToastOverlay extends StatefulWidget {
  final String message;
  final ToastType type;
  final Alignment alignment;
  final Duration duration;
  final VoidCallback onClosed;

  const _ToastOverlay({
    required this.message,
    required this.type,
    required this.alignment,
    required this.duration,
    required this.onClosed,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _inOut = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );
  late final AnimationController _iconProgress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  Timer? _autoClose;

  @override
  void initState() {
    super.initState();
    HapticFeedback.lightImpact();
    _inOut.forward();
    _iconProgress.forward();
    _autoClose = Timer(widget.duration, _close);
  }

  void _close() async {
    if (!mounted) return;
    await _inOut.reverse();
    if (mounted) widget.onClosed();
  }

  @override
  void dispose() {
    _autoClose?.cancel();
    _inOut.dispose();
    _iconProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.type == ToastType.success
        ? Color(0xFF2EBD85)
        : Color(0xFFF6465D);

    // Slide from offscreen based on alignment
    final isTop = widget.alignment.y < 0;
    final isBottom = widget.alignment.y > 0;
    final beginOffset = isTop
        ? const Offset(0, -0.15)
        : isBottom
        ? const Offset(0, 0.15)
        : const Offset(0, 0);

    final slide = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_inOut);

    final scale = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeOutBack)).animate(_inOut);

    final scrim = Tween<double>(
      begin: 0,
      end: 1,
    ).chain(CurveTween(curve: Curves.easeOut)).animate(_inOut);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Tap-to-dismiss + subtle dim
          FadeTransition(
            opacity: scrim,
            child: GestureDetector(
              onTap: _close,
              child: Container(color: Colors.transparent),
            ),
          ),

          // Toast
          Align(
            alignment: widget.alignment,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: SlideTransition(
                position: slide,
                child: ScaleTransition(
                  scale: scale,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeBackgroundColor.getBackgroundColor(
                            context,
                          ),
                          borderRadius: BorderRadius.circular(20.sp),
                          border: Border.all(
                            color: ThemeOutLineColor.getOutLineColor(context),
                            width: 5.sp,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _IconBubble(
                              color: borderColor, // <- no opacity on icon color
                              type: widget.type,
                              progress: CurvedAnimation(
                                parent: _iconProgress,
                                curve: Curves.easeOutCubic,
                              ),
                              size: 22.sp,
                            ),
                            SizedBox(width: 15.sp),
                            Flexible(
                              child: CustomText(
                                label: widget.message,
                                fontSize: 16.sp,
                                align: TextAlign.center,
                                labelFontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 10.sp),
                            InkWell(
                              onTap: _close,
                              child: Padding(
                                padding: EdgeInsets.all(10.sp),
                                child: Icon(Icons.close_rounded, size: 20.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small animated bubble: solid circle + animated check/cross
class _IconBubble extends StatelessWidget {
  final Animation<double> progress;
  final Color color;
  final double size;
  final ToastType type;

  const _IconBubble({
    required this.progress,
    required this.color,
    required this.type,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    // pick the icon you like — either error_rounded or cancel_rounded
    final IconData data = type == ToastType.success
        ? Icons.check_circle_rounded
        : Icons.error_rounded; // or: Icons.cancel_rounded

    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) {
        final t = progress.value.clamp(0.0, 1.0);
        // ease curves
        final scale = _easeOutBack(t, 0.8, 1.0); // pop in
        final angle = _easeOut(t, -0.25, 0.0); // tiny settle wobble (radians)

        return Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: scale,
            child: Icon(
              data,
              color: color, // solid green/red
              size: size,
            ),
          ),
        );
      },
    );
  }

  // helpers
  double _easeOutBack(double t, double a, double b) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    final u = t - 1;
    final eased = 1 + c3 * (u * u * u) + c1 * (u * u);
    return a + (b - a) * eased;
  }

  double _easeOut(double t, double a, double b) {
    final eased = 1 - (1 - t) * (1 - t); // quad easeOut
    return a + (b - a) * eased;
  }
}

customAlert({
  required BuildContext context,
  String? title,
  double? titleSize,
  Function()? onTapBack,
  Function()? onDismiss,
  Widget? widget,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.all(16.sp),
        backgroundColor: Colors.transparent,
        content: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
          child: Container(
            decoration: BoxDecoration(
              color: ThemeBackgroundColor.getBackgroundColor(context),
              border: Border.all(
                width: 5.sp,
                color: ThemeOutLineColor.getOutLineColor(context),
              ),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            width: 100.w,
            constraints: BoxConstraints(maxHeight: 80.h),
            padding: EdgeInsets.all(15.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        label: title ?? AppLocalizations.of(context)!.alert,
                        fontSize: titleSize ?? 16.sp,
                        labelFontWeight: FontWeight.w600,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: onTapBack ?? () => AppNavigator.pop(),
                        child: SvgPicture.asset(
                          AppBasicIcons.close,
                          height: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.sp),

                /// Dotted Divider
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.sp),
                  child: DottedDivider(
                    color: ThemeTextOneColor.getTextOneColor(context),
                  ),
                ),

                SizedBox(height: 15.sp),

                /// Scrollable widget content
                if (widget != null)
                  Flexible(child: SingleChildScrollView(child: widget)),
              ],
            ),
          ),
        ),
      );
    },
  ).then((val) {
    onDismiss?.call();
  });
}

class DottedDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double dashWidth;
  final double space;

  const DottedDivider({
    super.key,
    this.color = const Color(0xFF555555),
    this.height = 1,
    this.dashWidth = 4,
    this.space = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + space)).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
