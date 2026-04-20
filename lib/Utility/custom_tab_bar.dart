import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'Colors/custom_theme_change.dart';
import 'custom_text.dart';

class CustomTabView extends StatelessWidget {
  final TabController controller;
  final double? height;
  final List<Widget> tabs;
  final List<Widget> views;
  final VoidCallback? onTap;

  /// NEW: image used for the thin divider line
  final String dividerAsset;
  /// NEW: height of the divider image
  final double dividerHeight;
  final bool isFullWidth;

  const CustomTabView({
    super.key,
    required this.controller,
    required this.tabs,
    required this.views,
    this.height,
    this.onTap,
    this.dividerAsset = 'assets/images/tab_divider.png', // <- put your image here
    this.dividerHeight = 1.0,
    this.isFullWidth = false,
  }) : assert(tabs.length == views.length, 'tabs & views must have same length');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: height ?? 5.h,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Bottom divider as IMAGE
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: dividerHeight,
                child: SvgPicture.asset(
                  dividerAsset,
                  fit: BoxFit.fitWidth,      // stretch horizontally
                  alignment: Alignment.bottomLeft,
                ),
              ),

              // TabBar on top
              TabBar(
                controller: controller,
                isScrollable: true,
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.zero,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent, // we use our image instead
                labelColor: cs.onSurface,
                unselectedLabelColor: Theme.of(context).disabledColor,
                labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                unselectedLabelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
                indicator: _ShortPillUnderlineIndicator(
                  color: cs.primary,
                  thickness: 3,
                  pillWidth: isFullWidth == true ? 40.w : 40,
                  bottomInset: 0,
                  borderRadius: 3,
                  alignToLabelStart: isFullWidth == true ? false : true,
                ),
                onTap: (_) => onTap?.call(),
                tabs: tabs,
              ),
            ],
          ),
        ),

        // Tab contents
        AnimatedBuilder(
          animation: controller,
          builder: (_, __) => views[controller.index],
        ),
      ],
    );
  }
}

// --- same indicator classes you already had ---
class _ShortPillUnderlineIndicator extends Decoration {
  final Color color;
  final double thickness;
  final double pillWidth;
  final double bottomInset;
  final double borderRadius;
  final bool alignToLabelStart;

  const _ShortPillUnderlineIndicator({
    required this.color,
    required this.thickness,
    required this.pillWidth,
    this.bottomInset = 0,
    this.borderRadius = 2,
    this.alignToLabelStart = true,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _ShortPillUnderlinePainter(
      color: color,
      thickness: thickness,
      pillWidth: pillWidth,
      bottomInset: bottomInset,
      borderRadius: borderRadius,
      alignToLabelStart: alignToLabelStart,
    );
  }
}

class _ShortPillUnderlinePainter extends BoxPainter {
  final Color color;
  final double thickness;
  final double pillWidth;
  final double bottomInset;
  final double borderRadius;
  final bool alignToLabelStart;

  _ShortPillUnderlinePainter({
    required this.color,
    required this.thickness,
    required this.pillWidth,
    required this.bottomInset,
    required this.borderRadius,
    required this.alignToLabelStart,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    if (cfg.size == null) return;
    final rect = offset & cfg.size!;
    final w = math.min(pillWidth, rect.width);
    final y = rect.bottom - bottomInset - thickness;
    final double left = alignToLabelStart ? rect.left : rect.left + (rect.width - w) / 2;
    final rrect = RRect.fromLTRBR(left, y, left + w, y + thickness, Radius.circular(borderRadius));
    final paint = Paint()..color = color;
    canvas.drawRRect(rrect, paint);
  }
}



class TabView extends StatelessWidget {
  final double? height;
  final List<Widget> views;
  final List<String> Function(BuildContext context) tabs;
  final int selectedIndex;
  final void Function(int index) onTabChange;

  /// Divider image
  final double dividerHeight;

  const TabView({
    super.key,
    required this.tabs,
    required this.views,
    required this.selectedIndex,
    required this.onTabChange,
    this.height = 50,
    this.dividerHeight = 1,
  }) : assert(views.length > 0);

  @override
  Widget build(BuildContext context) {
    final tabList = tabs(context);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: Stack(
            children: [
            /*  /// Divider image
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: dividerHeight,
                child:   /// Dotted Divider
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.sp),
                  child: DottedDivider(
                    color: ThemeTextOneColor.getTextOneColor(context),
                  ),
                ),
              ),*/

              /// Tabs
              ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabList.length,
                padding: EdgeInsets.symmetric(horizontal: 12.sp),
                itemBuilder: (_, index) {
                  final bool selected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () => onTabChange(index),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.sp),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            label: tabList[index],
                            fontSize: 16.sp,
                            labelFontWeight: FontWeight.w600,
                            fontColour: selected
                                ? ThemeInversePrimaryColor
                                .getInversePrimaryColor(context)
                                : ThemeTextColor.getTextColor(context),
                          ),
                          SizedBox(height: 10.sp),

                          /// Animated underline
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            height: 2,
                            width: selected ? 55 : 0,
                            decoration: BoxDecoration(
                              color: ThemeInversePrimaryColor
                                  .getInversePrimaryColor(context),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        /// Views
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: views[selectedIndex],
        ),
      ],
    );
  }
}
