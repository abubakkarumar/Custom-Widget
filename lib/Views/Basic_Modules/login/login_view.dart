// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Views/Basic_Modules/email_verfication/email_verification_view.dart';
import 'package:zayroexchange/Views/Basic_Modules/forgot_password/forgot_password_firststep.dart';
import 'package:zayroexchange/Views/Basic_Modules/two_fa/twofa_controller.dart';
import 'package:zayroexchange/Views/Basic_Modules/two_fa/twofa_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/Views/Root/new_root/root_page.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import 'login_controller.dart';
import 'mpin_login/mpin_login_view.dart'; // keep your controller

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Keep a reference here; Consumer will update it in build.
  LoginController controller = LoginController();
  TwoFAController twoFAController = TwoFAController();
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // preserve original behavior
    Future.delayed(Duration.zero).whenComplete(() async {
      controller.diableAutoValidate();
      controller.isSuccess = false;
      controller.restoreCredentials();
      await _initDeviceId();
    });
  }

  Future<void> _initDeviceId() async {
    final deviceId = await controller.getDeviceId();
    AppStorage.storeDeviceID(deviceId);
  }

  @override
  void dispose() {
    super.dispose();
    controller.diableAutoValidate();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LoginController, TwoFAController>(
      builder: (context, value, value1, child) {
        controller = value;
        twoFAController = value1;
        return Form(
          key: loginFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextFieldWidget(
                  label: AppLocalizations.of(context)!.emailAddress,
                  line: 1,
                  controller: controller.emailController,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: SvgPicture.asset(AppThemeIcons.email(context)),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    FilteringTextInputFormatter.deny(RegExp(r'[A-Z]')),
                  ],
                  autoValidateMode: controller.emailAutoValidate,
                  hintText: AppLocalizations.of(context)!.emailAddressHintText,
                  readOnly: false,
                  onValidate: (val) =>
                      AppValidations().email(context, val ?? ""),
                ),
                SizedBox(height: 2.h),
                CustomTextFieldWidget(
                  label: AppLocalizations.of(context)!.password,
                  line: 1,
                  controller: controller.passwordController,
                  obscure: !controller.isPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: ThemeTextOneColor.getTextOneColor(context),
                      size: 18.sp,
                    ),
                    onPressed: () {
                      controller.isPasswordFunc();
                    },
                  ),
                  autoValidateMode: controller.passwordAutoValidate,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: SvgPicture.asset(AppThemeIcons.password(context)),
                  ),
                  hintText: AppLocalizations.of(context)!.passwordHintText,
                  readOnly: false,
                  onValidate: (val) =>
                      AppValidations().newPassword(context, val ?? ""),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        controller.diableAutoValidate();
                        controller.resetData();
                        AppNavigator.pushTo(const ForgotPasswordOne());
                      },
                      child: CustomText(
                        label: AppLocalizations.of(context)!.forgotPassword,
                        fontSize: 14.sp,
                        fontColour:
                            ThemeInversePrimaryColor.getInversePrimaryColor(
                              context,
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                controller.isLoading == true
                    ? CustomProgressDialog():
                CustomButton(
                  label: AppLocalizations.of(context)!.login,
                  onTap: () {
                    // <-- MUST BE async
                    controller.enableAutoValidate();
                    if (loginFormKey.currentState!.validate()) {
                      controller.doLogin(context).whenComplete(() async {
                        if (controller.isSuccess) {
                          if (AppStorage.getTwofaStatus() == 0) {
                            AppNavigator.pushTo(const RootScreen());
                          } else {
                            custom2FAVerification(
                              context: context,
                              isEmailOrGoogle: AppStorage.getTwofaStatus() == 2
                                  ? true
                                  : false,
                              isResendCodeNeeded: false,
                              onDismiss: () {
                                controller.resetData();
                              },
                              onResend: () async {
                                twoFAController.setLoader(true);
                                await controller.doResendEmailTwoFACode(
                                  context: context,
                                );
                                twoFAController.setLoader(false);
                              },
                              onSubmit: () async {
                                twoFAController.setLoader(true);
                                await controller
                                    .doVerifyTwoFA(
                                      context: context,
                                      code:
                                          twoFAController.verificationCode.text,
                                    )
                                    .whenComplete(() {
                                      twoFAController.setLoader(false);
                                      if (controller.isSuccess) {
                                        AppNavigator.pop();
                                        AppNavigator.pushTo(const RootScreen());
                                      }
                                    });
                              },
                            );
                          }
                        } else {
                          await controller
                              .getEmailVerificationStatus(context)
                              .whenComplete(() {
                                if (controller.emailVerifiedStatus == 2) {
                                  AppNavigator.pushTo(EmailVerification());
                                }
                              });
                        }
                      });
                    }
                  },
                ),
                SizedBox(height: 2.h),
                if (AppStorage.getBiometricStatus() == 1 ||
                    AppStorage.getMPINStatus() == 1)
                  CustomText(
                    align: TextAlign.center,
                    label: AppLocalizations.of(context)!.or,
                  ),
                if (AppStorage.getBiometricStatus() == 1 ||
                    AppStorage.getMPINStatus() == 1)
                  SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (AppStorage.getBiometricStatus() == 1)
                      CustomGestureButton(
                        onTap: () {
                          controller
                              .authenticateBiometric(context)
                              .whenComplete(() {
                                if (controller.isSuccess) {
                                  controller
                                      .doBiometricLogin(context)
                                      .whenComplete(() {
                                        if (controller.isSuccess) {
                                          AppNavigator.pushTo(
                                            const RootScreen(),
                                          );
                                        }
                                      });
                                }
                              });
                        },
                        child: Container(
                          height: 6.h,
                          width: 42.w,
                          padding: EdgeInsets.all(5.sp),
                          decoration: BoxDecoration(
                            color: ThemeTextFormFillColor.getTextFormFillColor(
                              context,
                            ),
                            borderRadius: BorderRadius.circular(30.sp),
                          ),
                          child: Center(
                            child: CustomText(
                              label: Platform.isAndroid
                                  ? AppLocalizations.of(
                                      context,
                                    )!.loginWithFingerprint
                                  : AppLocalizations.of(context)!.loginWithFace,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ),
                    if (AppStorage.getMPINStatus() == 1) SizedBox(width: 15.sp),
                    if (AppStorage.getMPINStatus() == 1)
                      CustomGestureButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MPINLoginView(),
                            ),
                          );
                        },
                        child: Container(
                          height: 6.h,
                          width: 42.w,
                          padding: EdgeInsets.all(5.sp),
                          decoration: BoxDecoration(
                            color: ThemeTextFormFillColor.getTextFormFillColor(
                              context,
                            ),
                            borderRadius: BorderRadius.circular(30.sp),
                          ),
                          child: Center(
                            child: CustomText(
                              label: AppLocalizations.of(
                                context,
                              )!.loginWithMPIN,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
