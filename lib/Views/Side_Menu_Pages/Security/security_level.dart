import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import 'Google_TwoFa/google_2fa_view.dart';

class SecurityOptionTile extends StatefulWidget {
  final String title;
  final String description;
  final String buttonText;
  final String image;
  final bool isToggleType;
  final bool initialToggleValue; // <-- status from backend
  final Future<void> Function()? onTap; // VIEW / Settings button
  final Future<void> Function(bool enabled)? onToggle; // Toggle callback
  final Color? buttonColor;
  final Color? buttonTextColor;

  const SecurityOptionTile({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.buttonText,
    this.isToggleType = true,
    this.initialToggleValue = false,
    this.onTap,
    this.onToggle,
    this.buttonColor,
    this.buttonTextColor
  });

  @override
  State<SecurityOptionTile> createState() => _SecurityOptionTileState();
}

class _SecurityOptionTileState extends State<SecurityOptionTile> {
  bool isEnabled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isEnabled = widget.initialToggleValue; // set initial value
  }

  Future<void> _handleToggle() async {
    if (widget.onToggle == null) return;

    setState(() => isLoading = true);

    await widget.onToggle!(isEnabled).whenComplete(() {
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(context),
        borderRadius: BorderRadius.circular(15.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 4.sp,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT: ICON, TITLE, DESCRIPTION
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(widget.image, width: 24.sp, height: 24.sp),
                SizedBox(width: 15.sp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        label: widget.title,
                        labelFontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 10.sp),
                      CustomText(
                        label: widget.description,
                        fontSize: 14.sp,
                        fontColour: ThemeTextOneColor.getTextOneColor(context),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 15.sp),

          widget.isToggleType ? _buildToggleButton() : _buildViewButton(),
        ],
      ),
    );
  }

  /// TOGGLE BUTTON
  Widget _buildToggleButton() {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () async {
              setState(() => isEnabled = !isEnabled);
              await _handleToggle();
            },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: isEnabled
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: isLoading
            ? SizedBox(
                height: 18.sp,
                width: 18.sp,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : CustomText(
                label: isEnabled
                    ? AppLocalizations.of(context)!.disable
                    : AppLocalizations.of(context)!.enable,
                fontColour: Colors.white,
                fontSize: 15.sp,
                labelFontWeight: FontWeight.w400,
              ),
      ),
    );
  }

  /// VIEW / SETTINGS BUTTON
  Widget _buildViewButton() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 10.sp),
        decoration: BoxDecoration(
          color:widget.buttonColor ?? ThemeOutLineColor.getOutLineColor(context),
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: CustomText(
          label: widget.buttonText,
          fontSize: 15.sp,
          labelFontWeight: FontWeight.w400,
          fontColour: widget.buttonTextColor,
        ),
      ),
    );
  }
}

noteContainer(BuildContext context, SecurityController controller) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(12.sp),
    decoration: BoxDecoration(
      color: ThemeNoteColor.getNoteColorColor(context),
      borderRadius: BorderRadius.circular(12.sp),
      border: Border.all(color: const Color(0xFF5d9cf7), width: 4.sp),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label: AppLocalizations.of(context)!.note,
          labelFontWeight: FontWeight.bold,
          fontSize: 15.sp,
          fontColour: ThemeInversePrimaryColor.getInversePrimaryColor(context),
        ),
        SizedBox(height: 10.sp),
        CustomText(
          label: AppLocalizations.of(context)!.noteSubText,
          fontSize: 14.5.sp,
          labelFontWeight: FontWeight.w400,
          fontColour: ThemeTextOneColor.getTextOneColor(context),
        ),
      ],
    ),
  );
}

items({
  required BuildContext context,
  required String title,
  required String subTitle,
  required String leadingImage,
  required String buttonLabel,
  required bool color,
  required Future<void> Function()? onTap,
}) {
  return Container(
    padding: EdgeInsets.only(
      left: 13.sp,
      right: 13.sp,
      top: 13.sp,
      bottom: 10.sp,
    ),
    decoration: BoxDecoration(
      color: ThemeTextFormFillColor.getTextFormFillColor(context),
      borderRadius: BorderRadius.circular(15.sp),
      border: Border.all(
        color: ThemeOutLineColor.getOutLineColor(context),
        width: 5.sp,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(leadingImage, width: 22.5.sp, height: 22.5.sp),
              SizedBox(width: 12.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(label: title, labelFontWeight: FontWeight.w600),
                    SizedBox(height: 10.sp),
                    CustomText(
                      label: subTitle,
                      fontSize: 14.sp,
                      fontColour: ThemeTextOneColor.getTextOneColor(context),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 15.sp),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 13.sp, vertical: 8.sp),
            decoration: BoxDecoration(
              color: color
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: CustomText(
              label: buttonLabel,
              fontColour: Colors.white,
              fontSize: 15.sp,
              labelFontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}

protectYourFundsAlert(BuildContext context, SecurityController controller) {
  return customAlert(
    context: context,
    title: AppLocalizations.of(context)!.protectYourFunds,
    onTapBack: () {
      AppNavigator.pop();
      controller.resetChangePasswordData();
    },
    widget: Column(
      children: [
        CustomText(
          label: AppLocalizations.of(context)!.protectYourFundsSubText,
          labelFontWeight: FontWeight.w500,
        ),
        SizedBox(height: 15.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  AppThemeIcons.securityGoogleAuthAlert(context),
                  height: 4.h,
                ),
                SizedBox(width: 15.sp),
                CustomText(
                  label: AppLocalizations.of(
                    context,
                  )!.authenticatorAppRecommended,
                  fontSize: 15.sp,
                  labelFontWeight: FontWeight.bold,
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                AppNavigator.pop();
                customAlert(
                  context: context,
                  title: AppLocalizations.of(
                    context,
                  )!.enableGoogleAuthentication,
                  onTapBack: () {
                    AppNavigator.pop();
                    controller.googleOTPController.clear();
                  },
                  widget: const SingleChildScrollView(child: GoogleTwoFAView()),
                  onDismiss: () {
                    controller.googleOTPController.clear();
                  },
                );
              },
              child: SvgPicture.asset(
                AppBasicIcons.securityArrow,
                height: 20.sp,
              ),
            ),
          ],
        ),
      ],
    ),
    onDismiss: () {},
  );
}
