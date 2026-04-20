// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';


class CustomDateSelect extends StatelessWidget {
  final TextEditingController? dateText;
  final double? height;
  final bool? isDisabled;
  final String? hintText;
  final AutovalidateMode? autoValidateMode;
  final BoxDecoration? decoration;
  final String label;
  final void Function()? onTap;
  final void Function(String)? onChange;
  final String? Function(String?)? validator;

  const CustomDateSelect({
    super.key,
    this.dateText,
    this.height,
    this.hintText,
    this.decoration,
    this.onTap,
    this.onChange,
    this.validator,
    required this.label, this.autoValidateMode, this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 6.sp),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.5.sp,
                color: ThemeTextColor.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Container(
         // height: height ?? 6.h,
          decoration: decoration,
          child: TextFormField(
            controller: dateText,
            readOnly: true,
            onTap: (isDisabled ?? false) ? null : () {
              HapticFeedback.lightImpact();
              if (onTap != null) {
                onTap!();
              }
            },
            onChanged: onChange,
            validator: validator,
            style: TextStyle(
              fontSize: 15.5.sp,
              color: ThemeTextColor.getTextColor(context),
              fontWeight: FontWeight.w400,
            ),
            autovalidateMode: autoValidateMode,
            decoration: InputDecoration(
              counterText: "",
              suffixIcon: Icon(
                Icons.calendar_month,
                size: 20.sp,
                color: ThemeTextOneColor.getTextOneColor(context),
              ),
              filled: true,
              fillColor: ThemeTextFormFillColor.getTextFormFillColor(context),
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 15.5.sp,
                color: ThemeTextOneColor.getTextOneColor(context),
                fontWeight: FontWeight.w400,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 4.sp,
                  color: ThemeOutLineColor.getOutLineColor(context),
                ),
                borderRadius: BorderRadius.circular(15.sp),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 4.sp,
                  color: ThemeOutLineColor.getOutLineColor(context),
                ),
                borderRadius: BorderRadius.circular(15.sp),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 4.sp,
                  color: Theme.of(context).colorScheme.error,
                ),
                borderRadius: BorderRadius.circular(15.sp),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 4.sp,
                  color: Theme.of(context).colorScheme.error,
                ),
                borderRadius: BorderRadius.circular(12.sp),
              ),
              contentPadding: EdgeInsets.only(top: 10.sp, left: 15.sp),
            ),
          ),
        ),
      ],
    );
  }
}
