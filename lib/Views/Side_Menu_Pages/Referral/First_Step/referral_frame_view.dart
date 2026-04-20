import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/Animation_pages/referral_frame_animation.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/Animation_pages/referral_badges.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/referral_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class ReferralFrameWidget extends StatelessWidget {
  final ReferralController controller;
  const ReferralFrameWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label:AppLocalizations.of(context)!.earnFrameRewardsContent,
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
                child: _buildFrameCard(
                  context,
                  title: AppLocalizations.of(context)!.blueFrame,
                  isTick: controller.blueOpened == 1,
                  description: AppLocalizations.of(context)!.blueFrameDec,
                  framePath: AppThemeIcons.referralBlueFrame(context),
                ),
              ),
              SizedBox(width: 10.sp),

              Expanded(
                child: _buildFrameCard(
                  context,
                  title: AppLocalizations.of(context)!.redFrame,
                  description: AppLocalizations.of(context)!.redFrameDec,
                  isTick: controller.redOpened == 1,
                  framePath: AppThemeIcons.referralRedFrame(context),
                ),
              ),
              SizedBox(width: 10.sp),

              Expanded(
                child: _buildFrameCard(
                  context,
                  title: AppLocalizations.of(context)!.goldFrame,
                  description: AppLocalizations.of(context)!.goldFrameDec,
                  isTick: controller.goldOpened == 1,
                  framePath: AppThemeIcons.referralGoldFrame(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrameCard(
    BuildContext context, {
    required String title,
    required String description,

    required bool isTick,
    required String framePath,
  }) {
    final Color baseAccent =
        framePath == AppThemeIcons.referralBlueFrame(context)
        ? ThemePrimaryColor.getPrimaryColor(context)
        : framePath == AppThemeIcons.referralRedFrame(context)
        ? Color(0xFFFF4C4C)
        : Color(0xFFE2AA32);
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
                PowerBounceFrame(
                  framePath: framePath,
                  size: 35.sp,
                  glowColor: accent,
                ),
                SizedBox(height: 10.sp),

                /// TITLE
                CustomText(
                  label: title,
                  align: TextAlign.center,
                  labelFontWeight: FontWeight.w600,
                  fontSize: 13.8.sp,
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
                SvgPicture.asset(framePath, height: 10.h, width: 10.w),
                SizedBox(height: 10.sp),

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
            ),
        ],
      ),
    );
  }
}
