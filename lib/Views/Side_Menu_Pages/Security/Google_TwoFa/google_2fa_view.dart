// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_otp_field.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class GoogleTwoFAView extends StatefulWidget {
  const GoogleTwoFAView({super.key});

  @override
  State<GoogleTwoFAView> createState() => _GoogleTwoFAViewState();
}

class _GoogleTwoFAViewState extends State<GoogleTwoFAView> {
  SecurityController controller = SecurityController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      controller.getGoogleSecretKey(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityController>(
      builder: (context, value, _) {
        controller = value;
        return SingleChildScrollView(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Form(
                key: controller.securityKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      label: AppLocalizations.of(
                        context,
                      )!.googleAuthenticatorDetailText,
                      fontColour: ThemeTextOneColor.getTextOneColor(context),
                      labelFontWeight: FontWeight.w400,
                    ),
                    SizedBox(height: 15.sp),

                    /// QR + Secret Box container
                    Container(
                      width: 100.w,
                      padding: EdgeInsets.all(15.sp),
                      decoration: BoxDecoration(
                        color: ThemeTextFormFillColor.getTextFormFillColor(
                          context,
                        ),
                        borderRadius: BorderRadius.circular(12.sp),
                        border: Border.all(
                          width: 5.sp,
                          color: ThemeOutLineColor.getOutLineColor(context),
                        ),
                      ),
                      child: Column(
                        children: [
                          controller.googleQRUrl.toString().isNotEmpty
                              ? Image.network(
                                  controller.googleQRUrl.toString(),
                                  height: 35.w,
                                  width: 35.w,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.qr_code,
                                    size: 35.sp,
                                    color: Colors.red,
                                  ),
                                )
                              : Icon(
                                  Icons.qr_code,
                                  size: 35.sp,
                                  color: Colors.red,
                                ),
                          SizedBox(height: 15.sp),

                          /// Secret Key Text Field
                          CustomTextFieldWidget(
                            label: AppLocalizations.of(context)!.secretKey,
                            controller: controller.googleSecretKeyController,
                            readOnly: true,
                            suffixIcon: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.sp,
                                vertical: 8.sp,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  if (controller.googleSecretKeyController.text
                                      .toString()
                                      .isNotEmpty) {
                                    CustomAnimationToast.show(
                                      message: AppLocalizations.of(
                                        context,
                                      )!.secretKeyCopy,
                                      context: context,
                                    );
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: controller
                                            .googleSecretKeyController
                                            .text
                                            .toString(),
                                      ),
                                    );
                                  }
                                },
                                child: SvgPicture.asset(
                                  AppBasicIcons.copy,
                                  width: 18.sp,
                                  height: 18.sp,
                                ),
                              ),
                            ),
                            hintText: AppLocalizations.of(
                              context,
                            )!.enterSecretKey,
                          ),
                          SizedBox(height: 15.sp),

                          /// NOTE Section
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "${AppLocalizations.of(context)!.note} ",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(
                                    context,
                                  )!.googleAuthenticatorNoteText,
                                  style: TextStyle(
                                    fontSize: 14.3.sp,
                                    fontWeight: FontWeight.w400,
                                    color: ThemeTextOneColor.getTextOneColor(
                                      context,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15.sp),
                    CustomText(
                      label: AppLocalizations.of(context)!.enterYourCode,
                      labelFontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                    SizedBox(height: 15.sp),

                    PinField(controller: controller.googleOTPController),
                    SizedBox(height: 15.sp),

                    /// Submit Button
                    controller.isLoading
                        ? const CustomProgressDialog()
                        : CustomButton(
                            label: AppLocalizations.of(context)!.submit,
                            onTap: () async {
                              if (controller.securityKey.currentState!
                                  .validate()) {
                                controller
                                    .doEnableGoogle2FA(context)
                                    .whenComplete(() {
                                      if (AppStorage.getTwofaStatus() == 1) {
                                        AppNavigator.pop();
                                      }
                                    });
                              }
                            },
                          ),
                  ],
                ),
              ),

              /// Loader
              CustomLoader(isLoading: controller.isLoading),
            ],
          ),
        );
      },
    );
  }
}
