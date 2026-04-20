// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';

import 'Basics/app_navigator.dart';
import 'custom_text.dart';

class CustomTotalPageFormat extends StatelessWidget {
  final Widget? child;
  final String? appBarTitle;
  final VoidCallback? appBarOnTap;
  final bool showBackButton;

  const CustomTotalPageFormat({
    super.key,
    this.child,
    this.appBarTitle,
    this.appBarOnTap,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),

      appBar: AppBar(
        backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0, // <<< important
        surfaceTintColor: Colors.transparent, // <<< prevent color changes
        automaticallyImplyLeading: false,

        title: CustomText(
          label: appBarTitle ?? "",
          fontSize: 17.sp,
          fontColour: ThemeTextColor.getTextColor(context),
          labelFontWeight: FontWeight.bold,
        ),
        leading: showBackButton
            ? GestureDetector(
                onTap: appBarOnTap ?? () => AppNavigator.pop(),
                child: Padding(
                  padding: EdgeInsets.only(left: 18.sp),
                  child: SvgPicture.asset(
                    AppThemeIcons.backArrow(context),
                    width: 20.sp,
                    height: 20.sp,
                  ),
                ),
              )
            : null,
      ),

      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 13.sp,
          right: 13.sp,
          bottom: MediaQuery.of(context).padding.bottom + 15.sp,
        ),
        // padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
        child: child ?? const SizedBox(),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final String appBarTitle;
  final void Function()? appBarOnTap;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.appBarTitle,
    this.appBarOnTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),

      alignment: Alignment.centerLeft,
      color: ThemeBackgroundColor.getBackgroundColor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading ??
              GestureDetector(
                onTap: appBarOnTap ?? () => AppNavigator.pop(),
                child: SvgPicture.asset(
                  AppThemeIcons.backArrow(context),
                  width: 18.sp,
                  height: 18.sp,
                ),
              ),
          SizedBox(height: 15.sp),
          CustomText(
            label: appBarTitle,
            labelFontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ],
      ),
    );
  }
}
