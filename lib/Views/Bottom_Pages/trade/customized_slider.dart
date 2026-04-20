import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';

import '../../../Utility/Colors/custom_theme_change.dart';

class TradePercentSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const TradePercentSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TradePercentSlider> createState() => _TradePercentSliderState();
}

class _TradePercentSliderState extends State<TradePercentSlider>
    with SingleTickerProviderStateMixin {
  double localValue = 0;
  bool showTooltip = false;
  Timer? hideTooltipTimer;
  int _lastSliderResetTrigger = -1;

  @override
  void initState() {
    super.initState();
    // widget.value is provided from the controller as a percentage (0..100)
    // while this slider works with fraction (0..1). Accept either form.
    localValue = (widget.value > 1) ? (widget.value / 100) : widget.value;
  }

  @override
  void dispose() {
    hideTooltipTimer?.cancel();
    super.dispose();
  }

  void _showTooltipTemporarily() {
    hideTooltipTimer?.cancel();
    setState(() => showTooltip = true);
    hideTooltipTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => showTooltip = false);
    });
  }

  @override
  void didUpdateWidget(covariant TradePercentSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update localValue when parent (controller) changes the passed value.
    final newLocal = (widget.value > 1) ? (widget.value / 100) : widget.value;
    if (newLocal != localValue) {
      setState(() => localValue = newLocal.clamp(0.0, 1.0));
      // show tooltip briefly when external value changes
      _showTooltipTemporarily();
    }
  }

  void _updatePosition(Offset localPos, double width) {
    double percent = (localPos.dx / width).clamp(0.0, 1.0);
    setState(() => localValue = percent);
    widget.onChanged(percent);
    // show tooltip while updating
    _showTooltipTemporarily();
  }

  @override
  Widget build(BuildContext context) {
    const thumbSize = 16.0;
    const radius = thumbSize / 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final thumbX = (width * localValue).clamp(radius, width - radius);

        return Consumer<SpotTradeController>(
          builder: (context, value, child) {
            // detect external reset trigger even if slider numeric value unchanged
            if (value.sliderResetTrigger != _lastSliderResetTrigger) {
              _lastSliderResetTrigger = value.sliderResetTrigger;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                final newLocal = (value.sliderValue > 1)
                    ? (value.sliderValue / 100)
                    : value.sliderValue;
                setState(() {
                  localValue = newLocal.clamp(0.0, 1.0);
                });
                _showTooltipTemporarily();
              });
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) => setState(() => showTooltip = true),
              onHorizontalDragEnd: (_) => setState(() => showTooltip = false),
              onHorizontalDragUpdate: (d) =>
                  _updatePosition(d.localPosition, width),
              onTapDown: (d) {
                _updatePosition(d.localPosition, width);
                _showTooltipTemporarily();
              },

              child: SizedBox(
                height: 36,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    // TOOLTIP
                    if (showTooltip)
                      Positioned(
                        top: -30,
                        left: double.parse((thumbX - 20).clamp(0.0, width - 40.0).toString()),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${(localValue * 100).round()}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    // add a small caret under tooltip to point to thumb (optional)
                    // if (showTooltip)
                    //   Positioned(
                    //     top: -14,
                    //     left: double.parse((thumbX - 6).clamp(0.0, width - 12.0).toString()),
                    //     child: Transform.rotate(
                    //       angle: 0.785398, // 45deg to make a diamond as caret
                    //       child: Container(
                    //         width: 8,
                    //         height: 8,
                    //         color: Colors.red,
                    //       ),
                    //     ),
                    //   ),

                    // Small in-track percentage label (fallback if tooltip is clipped)
                    // if (showTooltip)
                      // Positioned(
                      //   top: 0,
                      //   left: double.parse((thumbX + 8).clamp(0.0, width - 36.0).toString()),
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      //     decoration: BoxDecoration(
                      //       color: Colors.black.withOpacity(0.85),
                      //       borderRadius: BorderRadius.circular(4),
                      //     ),
                      //     child: Text(
                      //       "${(localValue * 100).round()}%",
                      //       style: const TextStyle(
                      //         color: Colors.red,
                      //         fontSize: 11,
                      //         fontWeight: FontWeight.w600,
                      //       ),
                      //     ),
                      //   ),
                      // ),

                    /// BACKGROUND
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    /// FILLED
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      height: 3,
                      width: thumbX,
                      decoration: BoxDecoration(
                        color: value.buySellTab == 1 ? const Color(0xffF6465D) : const Color(0xff2EBD85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),

                    /// DIVIDERS (0 25 50 75 100)
                    ...List.generate(5, (i) {
                      final markerSize = 10.sp;
                      final markerRadius = markerSize / 2;

                      double dx = width * (i / 4);

                      // keep fully inside track
                      dx = dx.clamp(markerRadius, width - markerRadius);

                      return Positioned(
                        left: dx - markerRadius,
                        child: GestureDetector(
                          onTap: (){
                            switch(i){
                              case 0:
                                value.percentageBasedAmountAndTotalAmount(value: 0.0, c: context);
                              case 1:
                                value.percentageBasedAmountAndTotalAmount(value: 0.25, c: context);
                              case 2:
                                value.percentageBasedAmountAndTotalAmount(value: 0.50, c: context);
                              case 3:
                                value.percentageBasedAmountAndTotalAmount(value: 0.75, c: context);
                              case 4:
                                value.percentageBasedAmountAndTotalAmount(value: 1.0, c: context);
                            }
                            if(i == 0){

                            }else if(i == 1){

                            }
                          },
                          child: Container(
                            width: markerSize,
                            height: markerSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.sp),
                              color: ThemeTextColor.getTextColor(context),
                            ),
                          ),
                        ),
                      );
                    }),


                    /// THUMB
                    Positioned(
                      left: thumbX - radius,
                      child: Container(
                        width: thumbSize,
                        height: thumbSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.35),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
}
