import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/referral_controller.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/Animation_pages/referral_badges.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../Animation_pages/robot_Animation.dart';

class ReferralRobotWidget extends StatelessWidget {
  final ReferralController controller;
  const ReferralRobotWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label:AppLocalizations.of(context)!.earnRobotRewardsContent,
          align: TextAlign.start,
          labelFontWeight: FontWeight.w300,
          fontColour: ThemeTextOneColor.getTextOneColor(context),
          lineSpacing: 1.5,
          fontSize: 15.sp,
        ),

        SizedBox(height: 15.sp),
        Container(
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            color: ThemeTextFormFillColor.getTextFormFillColor(context),
            borderRadius: BorderRadius.circular(15.sp),
            border: Border.all(
              color: ThemeOutLineColor.getOutLineColor(context),
              width: 5.sp,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildRobotCard(
                  context,
                  title: AppLocalizations.of(context)!.blueRobot,
                  isTick: controller.blueOpened == 1,
                  description: AppLocalizations.of(context)!.blueRobotDec,
                  robotPath: AppThemeIcons.referralBlueRobot(context),
                ),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: _buildRobotCard(
                  context,
                  title:  AppLocalizations.of(context)!.redRobot,
                  isTick: controller.redOpened == 1,
                  description:  AppLocalizations.of(context)!.redRobotDec,
                  robotPath: AppThemeIcons.referralRedRobot(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRobotCard(
    BuildContext context, {
    required String title,
    required String description,
    required bool isTick,
    required String robotPath,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: 22.h),
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: ThemeOutLineColor.getOutLineColor(context),
        borderRadius: BorderRadius.circular(16.sp),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isTick)
            Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: ReferralTickBadge(size: 22.sp),
                ),
                BouncingRobot(
                  glowColor: robotPath == AppThemeIcons.referralBlueRobot(context)
                      ? const Color(0xFF4699FF)
                      :  const Color(0xFFFF4C4C),
                  robotAsset: robotPath,
                  size: 34.sp,
                ),
                SizedBox(height: 12.sp),
                /// TITLE
                CustomText(
                  label: title,
                  align: TextAlign.center,
                  labelFontWeight: FontWeight.w600,
                  fontSize: 14.5.sp,
                ),
                SizedBox(height: 10.sp),
                /// DESCRIPTION
                CustomText(
                  label: description,
                  align: TextAlign.center,
                  lineSpacing: 5.sp,
                  fontSize: 13.sp,
                  fontColour: ThemeTextOneColor.getTextOneColor(context),
                ),
              ],
            ),
          if (!isTick)
            Column(
              children: [
                SvgPicture.asset(robotPath,height: 10.h,width: 10.w,),
                SizedBox(height: 12.sp),
                /// TITLE
                CustomText(
                  label: title,
                  align: TextAlign.center,
                  labelFontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
                SizedBox(height: 10.sp),
                /// DESCRIPTION
                CustomText(
                  label: description,
                  align: TextAlign.center,
                  lineSpacing: 4.sp,
                  fontSize: 15.sp,
                  fontColour: ThemeTextOneColor.getTextOneColor(context),
                ),
              ],
            )

        ],
      ),
    );
  }
}
