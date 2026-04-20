import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_otp_field.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'twofa_controller.dart';

custom2FAVerification({
  required BuildContext context,
  String? title,
  bool? isEmailOrGoogle,
  bool? isResendCodeNeeded,
  required void Function() onSubmit,
  void Function()? onDismiss,
  void Function()? onInit,
  void Function()? onResend,
}) {
  return customAlert(
    context: context,
    title: title ?? AppLocalizations.of(context)!.securityVerification,
    onTapBack: () {
      AppNavigator.pop();
    },
    widget: TwoFAVerification(
      isEmailOrGoogle: isEmailOrGoogle,
      isResendCodeNeeded: isResendCodeNeeded,
      onSubmit: onSubmit,
      onResend: onResend,
      onInit: onInit,
    ),
    onDismiss: onDismiss,
  );
}

class TwoFAVerification extends StatefulWidget {
  final bool? isEmailOrGoogle;
  final bool? isResendCodeNeeded;
  final void Function() onSubmit;
  final void Function()? onResend;
  final void Function()? onInit;

  const TwoFAVerification({
    super.key,
    this.isEmailOrGoogle,
    this.isResendCodeNeeded,
    required this.onSubmit,
    this.onResend,
    this.onInit,
  });

  @override
  State<TwoFAVerification> createState() => _TwoFAVerificationState();
}

class _TwoFAVerificationState extends State<TwoFAVerification> {
  TwoFAController controller = TwoFAController();

  @override
  void initState() {
    super.initState();
    controller.verificationCode.clear();

    Future.delayed(Duration.zero, () {
      if (widget.onInit != null) {
        widget.onInit!();
      }
    });
  }

  @override
  void dispose() {
    controller.verificationCode.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TwoFAController>(
      builder: (context, value, child) {
        controller = value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(
                    label: widget.isEmailOrGoogle == true
                        ? "${AppLocalizations.of(context)!.pleaseEnterDigitVerificationCode} ${AppStorage.getUserEmail() ?? ""}"
                        : AppLocalizations.of(
                            context,
                          )!.pleaseEnterGoogleDigitVerificationCode,
                    fontSize: 15.sp,
                    labelFontWeight: FontWeight.w200,
                    lineSpacing: 1.5,
                  ),
                  SizedBox(height: 15.sp),
                  PinField(controller: controller.verificationCode),

                  SizedBox(height: 15.sp),
                  widget.isResendCodeNeeded == true
                      ? Column(
                          children: [
                            Row(
                              children: [
                                CustomText(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.ifYouReceiveClick,
                                  labelFontWeight: FontWeight.w200,
                                ),
                                GestureDetector(
                                  onTap: widget.onResend ?? () {},
                                  child: CustomText(
                                    label: AppLocalizations.of(context)!.resend,
                                    fontSize: 15.sp,
                                    labelFontWeight: FontWeight.w600,
                                    fontColour:
                                        ThemeInversePrimaryColor.getInversePrimaryColor(
                                          context,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.5.h),
                          ],
                        )
                      : const SizedBox.shrink(),
                  controller.isLoading == true
                      ? CustomProgressDialog():
                  Row(
                    children: [
                      Expanded(
                        child: CancelButton(
                          label: AppLocalizations.of(context)!.cancel,
                          onTap: () async {
                            AppNavigator.pop();
                          },
                        ),
                      ),
                      SizedBox(width: 15.sp),
                      Expanded(
                        child: CustomButton(
                          label: AppLocalizations.of(context)!.submit,
                          onTap: () async {
                            if (controller.formKey.currentState!.validate()) {
                              widget.onSubmit();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (controller.isLoading)
              CustomLoader(isLoading: controller.isLoading),
          ],
        );
      },
    );
  }
}
