// ignore_for_file: file_names, deprecated_member_use
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import 'Basics/app_navigator.dart';
import 'Images/dark_image.dart';
import 'custom_alertbox.dart';
import 'custom_button.dart';
import 'custom_text.dart';

Future<void> customActionAlertBox(
  BuildContext context,
  String title,
  double height,
  VoidCallback onTapCamera,
  VoidCallback onTapGallery,
  String labelCamera,
  String labelGallery,
) {
  return showDialog(
    context: context,
    barrierDismissible: true,
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
                        label: title,
                        fontSize: 16.sp,
                        labelFontWeight: FontWeight.w600,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        child: SvgPicture.asset(
                          AppBasicIcons.close,
                          height: 22.sp,
                        ),
                        onTap: () {
                          AppNavigator.pop();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.sp),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.sp),
                  child: DottedDivider(
                    color: ThemeTextOneColor.getTextOneColor(context),
                  ),
                ),
                SizedBox(height: 20.sp),
                CustomText(
                  label: AppLocalizations.of(context)!.pleaseUpload,
                  align: TextAlign.center,
                  labelFontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                  fontColour: ThemeTextOneColor.getTextOneColor(context),
                ),
                SizedBox(height: 20.sp),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      width: 45.sp,
                      label: labelCamera,
                      onTap: () async => onTapCamera(),
                    ),

                    CustomButton(
                      width: 45.sp,

                      label: labelGallery,
                      onTap: () async => onTapGallery(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
