import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_otp_field.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Utility/custom_tooltip.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import 'forgot_password_controller.dart';

class ForgotPasswordTwo extends StatefulWidget {
  const ForgotPasswordTwo({super.key});

  @override
  State<ForgotPasswordTwo> createState() => _ForgotPasswordTwoState();
}

class _ForgotPasswordTwoState extends State<ForgotPasswordTwo> {
  final forgotPasswordSecondKey = GlobalKey<FormState>();

  ForgotPasswordController controller = ForgotPasswordController();



  @override
  void dispose() {
    super.dispose();
    controller.diableAutoValidate();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgotPasswordController>(
      builder: (context, value, child) {
        controller = value;
        return Scaffold(
          backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
          body: Stack(
            children: [
              CustomTotalPageFormat(
                appBarTitle: AppLocalizations.of(context)!.forgotPasswordTitle,
                showBackButton: true,
                child: Form(
                  key: forgotPasswordSecondKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ------------------------
                      // OTP FIELD
                      // ------------------------
                      CustomText(
                        label: AppLocalizations.of(
                          context,
                        )!.enterVerificationCode,
                        fontSize: 14.5.sp,
                        labelFontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 12.sp),
                      PinField(
                        controller: controller.codeController,
                        validator: (val) =>
                            AppValidations().validateOtp(context, val ?? ""),
                      ),
                      SizedBox(height: 18.sp),

                      // ------------------------
                      // NEW PASSWORD
                      // ------------------------
                      CustomTextFieldWidget(
                        line: 1,
                        label: AppLocalizations.of(context)!.newPassword,
                        labelTwo: "",
                        controller: controller.newPasswordController,
                        hintText: AppLocalizations.of(
                          context,
                        )!.newPasswordHintText,
                        obscure: !controller.isNewPasswordVisible,
                        autoValidateMode: controller.newPasswordAutoValidate,

                        prefixIcon: Padding(
                          padding: EdgeInsets.all(15.sp),
                          child: SvgPicture.asset(
                            AppThemeIcons.password(context),
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            controller.toggleNewPasswordVisibility(
                              controller.isNewPasswordVisible,
                            );
                          },
                          icon: Icon(
                            controller.isNewPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20.sp,
                            color: ThemeTextOneColor.getTextOneColor(context),
                          ),
                        ),
                        onValidate: (val) => AppValidations()
                            .validateNewPassword(context, val ?? ""),
                        readOnly: false,
                        filled: true,
                      ),

                      SizedBox(height: 10.sp),

                      // Info Icon
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            controller.isPasswordTooltipOpen =
                                !controller.isPasswordTooltipOpen;

                            if (controller.isPasswordTooltipOpen) {
                              showPasswordTooltip(
                                context,
                                AppLocalizations.of(
                                  context,
                                )!.passwordRequirements,
                              );
                            } else {
                              removePasswordTooltip();
                            }

                            setState(() {});
                          },
                          child: Icon(
                            Icons.info_outline,
                            color: ThemeTextOneColor.getTextOneColor(context),
                            size: 18.sp,
                          ),
                        ),
                      ),

                      // ------------------------
                      // CONFIRM PASSWORD
                      // ------------------------
                      CustomTextFieldWidget(
                        line: 1,
                        label: AppLocalizations.of(context)!.confirmPassword,
                        labelTwo: "",
                        autoValidateMode:
                            controller.confirmPasswordAutoValidate,

                        controller: controller.confirmPasswordController,
                        hintText: AppLocalizations.of(
                          context,
                        )!.enterConfirmPassword,
                        obscure: !controller.isConfirmPasswordVisible,
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(15.sp),
                          child: SvgPicture.asset(
                            AppThemeIcons.password(context),
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            controller.toggleConfirmPasswordVisibility(
                              controller.isConfirmPasswordVisible,
                            );
                          },
                          icon: Icon(
                            controller.isConfirmPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20.sp,
                            color: ThemeTextOneColor.getTextOneColor(context),
                          ),
                        ),
                        onValidate: (val) => AppValidations().confirmPassword(
                          context,
                          controller.confirmPasswordController.text,
                          val ?? "",
                        ),
                        readOnly: false,
                        filled: true,
                      ),

                      SizedBox(height: 15.sp),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: ThemeTextOneColor.getTextOneColor(context),
                              fontSize: 15.sp,
                            ),
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(
                                  context,
                                )!.ifYouReceiveClick,
                              ),
                              TextSpan(
                                text: AppLocalizations.of(context)!.resend,
                                style: TextStyle(
                                  color:
                                      ThemeInversePrimaryColor.getInversePrimaryColor(
                                        context,
                                      ),
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    controller.requestForgotPassword(context);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.sp),

                      // ------------------------
                      // SUBMIT BUTTON
                      // ------------------------
                      controller.isLoading == true
                          ? CustomProgressDialog():
                      CustomButton(
                        label: AppLocalizations.of(context)!.updatePassword,
                        onTap: () async {
                          controller.enableAutoValidate();
                          if (forgotPasswordSecondKey.currentState!.validate()) {
                            print("dsfasdfasdf");
                            controller.updateForgotPassword(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Loader Layer
              CustomLoader(isLoading: controller.isLoading),
            ],
          ),
        );
      },
    );
  }
}
