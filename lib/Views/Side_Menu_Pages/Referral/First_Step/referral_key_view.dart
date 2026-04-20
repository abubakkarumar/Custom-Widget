import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/Animation_pages/robot_Animation.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/referral_controller.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/Animation_pages/referral_badges.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class ReferralKeysWidget extends StatelessWidget {
  final ReferralController controller;
  const ReferralKeysWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label:AppLocalizations.of(context)!.earnKeysRewardsContent,
          align: TextAlign.start,
          labelFontWeight: FontWeight.w300,
          fontColour: ThemeTextOneColor.getTextOneColor(context),
          lineSpacing: 1.5,
          fontSize: 15.sp,
        ),

        SizedBox(height: 15.sp),
        Container(
          padding: EdgeInsets.all(12.sp),
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
                child: _buildKeyCard(
                  context,
                  title:AppLocalizations.of(context)!.blueKey,
                  isTick: controller.blueOpened == 1 ? true : false,
                  description: AppLocalizations.of(context)!.blueKeyDec,
                  framePath: AppThemeIcons.referralBlueKey(context),

                  // iconWidget: BouncingRobot(
                  //   glowColor: const Color(0xFF4699FF),
                  //   robotAsset: AppThemeIcons.referralBlueKey(context),
                  //   size: 34.sp,
                  // ),
                ),
              ),
              SizedBox(width: 10.sp),

              Expanded(
                child: _buildKeyCard(
                  context,
                  title:  AppLocalizations.of(context)!.redKey,
                  isTick: controller.redOpened == 1 ? true : false,
                  description:  AppLocalizations.of(context)!.redKeyDec,
                  framePath: AppThemeIcons.referralRedKey(context),
                  // iconWidget: BouncingRobot(
                  //   glowColor: const Color(0xFFFF4C4C),
                  //   robotAsset: AppThemeIcons.referralRedKey(context),
                  //   size: 34.sp,
                  // ),
                ),
              ),
              SizedBox(width: 10.sp),

              Expanded(
                child: _buildKeyCard(
                  context,
                  title:  AppLocalizations.of(context)!.goldKey,
                  isTick: controller.goldOpened == 1 ? true : false,
                  description: AppLocalizations.of(context)!.goldKeyDec,
                  framePath: AppThemeIcons.referralGoldKey(context),

                  // iconWidget: BouncingRobot(
                  //   robotAsset: AppThemeIcons.referralGoldKey(context),
                  //   glowColor: const Color(0xFFE2AA32),
                  //   size: 34.sp,
                  // ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyCard(
    BuildContext context, {
    required String title,
    required String description,
    required bool isTick,
    required String framePath,
  }) {
    final Color baseAccent = framePath == AppThemeIcons.referralBlueKey(context)
        ? ThemePrimaryColor.getPrimaryColor(context)
        : framePath == AppThemeIcons.referralRedKey(context)
        ? const Color(0xFFFF4C4C)
        : const Color(0xFFE2AA32);
    final Color accent = isTick ? baseAccent : baseAccent.withOpacity(0.4);

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
                  child: ReferralTickBadge(size: 20.sp),
                ),

                /// ICON
                BouncingRobot(
                  robotAsset: framePath,
                  size: 34.sp,
                  glowColor: accent,
                ),

                SizedBox(height: 10.sp),

                /// TITLE
                CustomText(
                  label: title,
                  fontSize: 13.8.sp,
                  align: TextAlign.center,
                  labelFontWeight: FontWeight.w600,
                ),

                SizedBox(height: 8.sp),

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
                SvgPicture.asset(framePath, height: 34.sp, width: 34.sp),
                SizedBox(height: 10.sp),

                /// TITLE
                CustomText(
                  label: title,
                  fontSize: 15.sp,
                  align: TextAlign.center,
                  labelFontWeight: FontWeight.w600,
                ),

                SizedBox(height: 10.sp),

                /// DESCRIPTION
                CustomText(
                  label: description,
                  align: TextAlign.center,
                  lineSpacing: 4.sp,
                  fontSize: 14.sp,
                  fontColour: ThemeTextOneColor.getTextOneColor(context),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
