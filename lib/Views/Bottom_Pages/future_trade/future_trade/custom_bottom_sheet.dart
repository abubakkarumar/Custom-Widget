// ignore_for_file: file_names

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_text.dart';

customBottomSheet({
  required BuildContext context,
  required double height,
  required String title,
  required Widget child,
  void Function()? onTapBack,
  void Function()? onDismiss,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
    ),
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: BoxDecoration(
          color: ThemeBackgroundColor.getBackgroundColor(context),
          border: Border.all(
            color: ThemeOutLineColor.getOutLineColor(context),
            width: 5.sp,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.sp),
            topRight: Radius.circular(20.sp),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15.sp),

              Padding(
                padding: EdgeInsets.all(12.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(label: title, labelFontWeight: FontWeight.bold),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: SvgPicture.asset(
                        AppBasicIcons.close,
                        height: 20.sp,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.sp),
              Divider(
                color: ThemeOutLineColor.getOutLineColor(context),
                thickness: 6.sp,
                height: 5.sp,
              ),

              Expanded(child: child),
            ],
          ),
        ),
      );
    },
  ).then((val) {
    onDismiss?.call();
  });
}
