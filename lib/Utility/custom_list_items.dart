import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'custom_text.dart';

customListItems({
  BuildContext? context,
  String? leadingKey,
  String? leadingValue,
  Color? leadingValueColor,
  String? trailingKey,
  String? trailingValue,
  Color? trailingValueColor,
  bool? isLeadingIcon,
  bool? isTrailingIcon,
  Widget? leadingIcon,
  Widget? trailingIcon,
  void Function()? onTapLeadingIcon,
  void Function()? onTapTrailingIcon,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Padding(
          padding: EdgeInsets.only(
            left: 10.sp,
            right: 10.sp,
            top: 13.sp,
            bottom: 0.sp,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomText(
                label: leadingKey ?? "",
                fontSize: 14.5.sp,
                labelFontWeight: FontWeight.w500,
                fontColour: ThemeTextOneColor.getTextOneColor(context!),
              ),
               SizedBox(height: 10.sp,),
               Row(
                children: [
                  Expanded(
                    child: CustomText(
                      label: leadingValue ?? "",
                      fontSize: 14.sp,
                      align: TextAlign.start,
                      labelFontWeight: FontWeight.bold,
                      softWrap: false,
                    ),
                  ),
                  if (isLeadingIcon ?? false) SizedBox(width: 8.sp),
                  if (isLeadingIcon ?? false)
                    GestureDetector(
                      onTap: onTapLeadingIcon ?? () {},
                      child:
                          leadingIcon ??
                          SvgPicture.asset(AppBasicIcons.copy, height: 20.sp),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),

      if (trailingKey != null && trailingValue != null)
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText(
                label: trailingKey,
                fontSize: 15.sp,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
              ),
              SizedBox(height: 6.sp),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: CustomText(
                      label: trailingValue,
                      fontSize: 15.sp,
                      align: TextAlign.end,
                      fontColour:
                          trailingValueColor ??
                          ThemeTextColor.getTextColor(context),
                      // overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                  if (isTrailingIcon ?? false) SizedBox(width: 8.sp),
                  if (isTrailingIcon ?? false)
                    GestureDetector(
                      onTap: onTapTrailingIcon ?? () {},
                      child:
                          trailingIcon ??
                          SvgPicture.asset(AppBasicIcons.copy, height: 20.sp),
                    ),
                ],
              ),
            ],
          ),
        ),
    ],
  );
}

customLinearListItems({
  required BuildContext context,
  required String key,
  required String value,
  bool useFlexible = true,
  Color? keyColor,
  Color? valueColor,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      CustomText(label: key,fontSize: 14.5.sp,
        labelFontWeight: FontWeight.bold,),
      useFlexible
          ? Expanded(
              child: CustomText(
                label: value,
                fontSize: 14.sp,
                labelFontWeight: FontWeight.w400,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
                softWrap: true,
                align: TextAlign.end,
              ),
            )
          : Expanded(
              flex: 3,
              child: CustomText(
                label: value,
                fontSize: 14.sp,
                labelFontWeight: FontWeight.w400,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                align: TextAlign.end,
              ),
            ),
    ],
  );
}
