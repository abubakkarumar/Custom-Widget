import 'package:flutter/material.dart';

import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import 'custom_text.dart';

OverlayEntry? _overlayEntry;
AnimationController? _controller;

void showPasswordTooltip(BuildContext context, String title) {
  // Remove old tooltip if open
  removePasswordTooltip();

  final overlayState = Overlay.of(context);

  _controller = AnimationController(
    vsync: Navigator.of(context),
    duration: const Duration(milliseconds: 300),
  );

  final slideAnimation = Tween<Offset>(
    begin: const Offset(0, -0.1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeOut));

  final fadeAnimation = CurvedAnimation(
    parent: _controller!,
    curve: Curves.easeInOut,
  );

  _overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        // Background to dismiss
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _controller?.reverse().then((_) {
                _controller?.dispose();
                _controller = null;
                removePasswordTooltip();
              });
            },
            child: Container(color: Colors.black54),
          ),
        ),

        // Tooltip content
        Center(
          child: SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 95.w,
                  padding: EdgeInsets.all(14.sp),
                  decoration: BoxDecoration(
                    color: ThemeBackgroundColor.getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(14.sp),
                    border: Border.all(
                      color: ThemeOutLineColor.getOutLineColor(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.sp,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            label: title,
                            fontSize: 15.sp,
                            labelFontWeight: FontWeight.bold,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                _controller?.reverse().then((_) {
                                  _controller?.dispose();
                                  _controller = null;
                                  removePasswordTooltip();
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.sp),
                      CustomText(
                        label: AppLocalizations.of(context)!.passwordLength,
                        fontSize: 14.sp,
                        fontColour: ThemeTextColor.getTextColor(context),
                      ),
                      SizedBox(height: 10.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            label: AppLocalizations.of(context)!.atLeastOneUppercase,
                            labelFontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            fontColour: ThemeTextColor.getTextColor(context),
                          ),
                          CustomText(
                            label: AppLocalizations.of(context)!.atLeastOneUppercaseEg,
                            fontSize: 14.sp,
                            labelFontWeight: FontWeight.w500,
                            fontColour: ThemeTextColor.getTextColor(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            label: AppLocalizations.of(context)!.atLeastOneLowercase,
                            labelFontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            fontColour: ThemeTextColor.getTextColor(context),
                          ),
                          CustomText(
                            label: AppLocalizations.of(context)!.atLeastOneLowercaseEg,
                            fontSize: 14.sp,
                            labelFontWeight: FontWeight.w500,

                            fontColour: ThemeTextColor.getTextColor(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            label: AppLocalizations.of(context)!.atLeastNumericDigit,
                            fontSize: 14.sp,
                            labelFontWeight: FontWeight.w600,

                            fontColour: ThemeTextColor.getTextColor(context),
                          ),
                          CustomText(
                            label: AppLocalizations.of(context)!.atLeastNumericDigitEg,
                            fontSize: 14.sp,
                            labelFontWeight: FontWeight.w500,

                            fontColour: ThemeTextColor.getTextColor(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            label: AppLocalizations.of(context)!.atLeastOneSpecialCharacter,
                            labelFontWeight: FontWeight.w600,

                            fontSize: 14.sp,
                            fontColour: ThemeTextColor.getTextColor(context),
                          ),
                          CustomText(
                            label: AppLocalizations.of(context)!.atLeastOneSpecialCharacterEg,
                            labelFontWeight: FontWeight.w500,

                            fontSize: 14.sp,
                            fontColour: ThemeTextColor.getTextColor(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  overlayState.insert(_overlayEntry!);
  _controller?.forward();
}

void removePasswordTooltip() {
  _overlayEntry?.remove();
  _overlayEntry = null;
}
