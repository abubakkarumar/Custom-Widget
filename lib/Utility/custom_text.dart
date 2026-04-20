import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'Colors/custom_theme_change.dart';

class CustomText extends StatelessWidget {
  final String label;
  final double? fontSize;
  final Color? fontColour;
  final FontWeight? labelFontWeight;
  final TextAlign? align;
  final double? lineSpacing;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const CustomText({
    super.key,
    required this.label,
    this.fontSize,
    this.fontColour,
    this.labelFontWeight,
    this.align,
    this.lineSpacing,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: align ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap ?? true,
      style: TextStyle(
        height: lineSpacing ?? 1.2,
        fontSize: fontSize ?? 15.sp,
        color: fontColour ?? ThemeTextColor.getTextColor(context),
        fontWeight: labelFontWeight ?? FontWeight.w600,
      ),
    );
  }
}

class CustomLinkText extends StatelessWidget {
  final String? label;
  final String? labelTwo;
  final double? fontSize;
  final Color? textColour;
  final Color? textColorOne;
  final FontWeight? labelFontWeight;
  final FontWeight? labelFontWeightTwo;
  final TextAlign? align;
  final void Function()? onTap;
  final bool showUnderline;

  const CustomLinkText({
    super.key,
    this.label,
    this.labelTwo,
    this.fontSize,
    this.textColour,
    this.textColorOne,
    this.labelFontWeight,
    this.labelFontWeightTwo,
    this.align,
    required this.onTap,
    this.showUnderline = true,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: align ?? TextAlign.start,
      text: TextSpan(
        text: label ?? '',
        style: TextStyle(
          fontSize: fontSize ?? 15.sp,
          fontWeight: labelFontWeight ?? FontWeight.w500,
          color: textColorOne ?? Theme.of(context).textTheme.bodyMedium?.color,
        ),
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.only(bottom: 1), // tweak line spacing
                decoration: showUnderline
                    ? BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: textColour ?? Theme.of(context).primaryColor,
                            width: 1,
                          ),
                        ),
                      )
                    : null,
                child: Text(
                  labelTwo ?? '',
                  style: TextStyle(
                    fontSize: fontSize ?? 15.sp,
                    fontWeight: labelFontWeightTwo ?? FontWeight.bold,
                    color: textColour ?? Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


