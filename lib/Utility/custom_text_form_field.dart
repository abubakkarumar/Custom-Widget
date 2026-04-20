import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';

class CustomTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? suffixText;
  final String? prefixText;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final Widget? suffixIcon;
  final Color? fillColor;
  final bool? filled, obscure;
  final int? length;
  final double? height;
  final double? width;
  final bool readOnly;
  final FocusNode? node;
  final Color? cursorColor;
  final int? line;
  final TextInputType? keyboardType;
  final AutovalidateMode? autoValidateMode;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? onValidate;
  final BorderRadius? borderRadius;
  final String? label;
  final Widget? prefixIcon;
  final String? labelTwo;
  final Color? labelTwoColour;
  final bool? isDisabled;
  final void Function(String)? onSubmit;

  const CustomTextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.suffixText,
    this.onChanged,
    this.obscure = false,
    this.onValidate,
    this.length,
    this.width,
    this.height,
    this.keyboardType,
    this.inputFormatters,
    this.suffixIcon,
    this.fillColor,
    this.filled,
    required this.readOnly,
    this.autoValidateMode,
    this.borderRadius,
    this.node,
    this.line,
    this.cursorColor,
    this.prefixText,
    this.label,
    this.labelTwo,
    this.labelTwoColour,
    this.prefixIcon,
    this.onSubmit,
    this.onTap, this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          width: width,
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              label == null
                  ? const SizedBox.shrink()
                  : Text.rich(
                      TextSpan(
                        text: "$label ", // 👈 added space here
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          color:ThemeTextColor.getTextColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                        children: <InlineSpan>[
                          TextSpan(
                            text: labelTwo ?? "",
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              color: labelTwoColour ??Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

              label == null ? const SizedBox.shrink() : SizedBox(height: 10.sp),
              TextFormField(
                onTap: (isDisabled ?? false) ? null : () {
                  HapticFeedback.lightImpact();
                  if (onTap != null) {
                    onTap!();
                  }
                },
                focusNode: node,
                readOnly: (isDisabled ?? false) ? true : readOnly,
                keyboardType: keyboardType,
                onChanged: onChanged,
                onFieldSubmitted: onSubmit,
                autovalidateMode: autoValidateMode,
                inputFormatters: inputFormatters,
                maxLines: line,
                maxLength: length,
                onTapOutside: (_) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                style: TextStyle(
                  fontSize: 14.5.sp,
                  color: ThemeTextColor.getTextColor(context),
                  fontWeight: FontWeight.w400,
                ),
                cursorColor: ThemeTextColor.getTextColor(context),
                validator: (isDisabled ?? false) ? null : onValidate,
                obscureText: obscure!,
                controller: controller,
                decoration: InputDecoration(
                  counterText: "",
                  suffixIconConstraints: BoxConstraints(
                    minWidth: 20.sp,
                    minHeight: 20.sp,
                  ),
                  suffixIcon: Padding(
                    padding: EdgeInsets.only(right: 10.sp,left: 10
                    .sp),
                    child: suffixIcon,
                  ),

                  suffixText: suffixText,
                  suffixStyle: TextStyle(
                    fontSize: 14.5.sp,
                    color: ThemeTextColor.getTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                  prefixText: prefixText,
                  prefixIcon: prefixIcon,
                  filled: true,
                  fillColor: ThemeTextFormFillColor.getTextFormFillColor(
                    context,
                  ),
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontSize: 14.5.sp,
                    color: ThemeTextOneColor.getTextOneColor(context),
                    fontWeight: FontWeight.w400,
                  ),
                  errorStyle: TextStyle(
                    fontSize: 15.sp,
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 5.sp,
                      color: ThemeOutLineColor.getOutLineColor(context),
                    ),
                    borderRadius: BorderRadius.circular(15.sp),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 5.sp,
                      color: ThemeOutLineColor.getOutLineColor(context),
                    ),
                    borderRadius: BorderRadius.circular(15.sp),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 5.sp,
                      color: ThemeOutLineColor.getOutLineColor(context),
                    ),
                    borderRadius: BorderRadius.circular(15.sp),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 5.sp,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    borderRadius: BorderRadius.circular(15.sp),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 5.sp,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  contentPadding: EdgeInsets.only(top: 10.sp, left: 15.sp),
                ),
              ),
            ],
          ),
        );

  }
}
