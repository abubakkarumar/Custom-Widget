// ignore_for_file: unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import 'Basics/validation.dart';
import 'Colors/custom_theme_change.dart';

class PinField extends StatelessWidget {
  final int? length;
  final TextEditingController controller;
  final FocusNode? node;
  final bool? isShowCursor;
  final FormFieldValidator<String>? validator;

  const PinField({
    super.key,
    required this.controller,
    this.length,
    this.node,
    this.isShowCursor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: length ?? 6,
      controller: controller,
      focusNode: node,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
      inputFormatters: [NumericTextInputFormatter()],
      keyboardType: TextInputType.number,

      showCursor: true, // <-- FIXED

      cursor: Container(
        width: 2.sp,
        height: 18.sp,
        color: ThemeTextColor.getTextColor(context),
      ),

      errorTextStyle: TextStyle(
        fontSize: 15.sp,
        color: Theme.of(context).colorScheme.error,
        fontWeight: FontWeight.w400,
      ),

      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),

      validator:
          validator ??
          (val) {
            if (val!.isEmpty)
              return AppLocalizations.of(
                context,
              )!.enterVerificationCodeRequired;
            if (val.length != 6)
              return AppLocalizations.of(context)!.enterVerificationCodeFormat;
            return null;
          },
      separatorBuilder: (index) => SizedBox(width: 4.w),

      defaultPinTheme: PinTheme(
        width: 12.w,
        height: 12.w,
        textStyle: TextStyle(
          color: ThemeTextColor.getTextColor(context),
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.sp),
          border: Border.all(
            color: ThemeOutLineColor.getOutLineColor(context),
            width: 5.sp,
          ),
        ),
      ),

      /// Focus theme for active field
      focusedPinTheme: PinTheme(
        width: 12.w,
        height: 12.w,
        textStyle: TextStyle(
          color: ThemeTextColor.getTextColor(context),
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.sp),
          border: Border.all(
            color: ThemeOutLineColor.getOutLineColor(context),
            width: 5.sp,
          ),
        ),
      ),
    );
  }
}
