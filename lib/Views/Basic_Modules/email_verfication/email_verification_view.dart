import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_otp_field.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Basic_Modules/segmentedToggle/login_register.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'email_verification_controller.dart';

class EmailVerification extends StatefulWidget {

  const EmailVerification({super.key, });

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  EmailVerificationController controller = EmailVerificationController();
  final verificationTwoFaKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).whenComplete(() async {
      controller.clearAllInputs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmailVerificationController>(
      builder: (context, value, child) {
        controller = value;
        return Scaffold(
          body: Stack(
            children: [
              CustomTotalPageFormat(
                appBarTitle: AppLocalizations.of(
                  context,
                )!.emailVerification,
                showBackButton: true,
                child: Form(
                  key: verificationTwoFaKey,
                  child: Column(
                    children: [
                      CustomLinkText(
                        showUnderline: false,
                        label: AppLocalizations.of(
                          context,
                        )!.pleaseEnterDigitVerificationCode,
                        labelTwo:
                            AppStorage.getUserEmail() ??
                            AppLocalizations.of(context)!.registeredEmail,
                        onTap: () {},
                        textColour:
                            ThemeInversePrimaryColor.getInversePrimaryColor(
                              context,
                            ),
                        fontSize: 16.sp,
                        textColorOne: ThemeTextColor.getTextColor(context),
                        labelFontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 15.sp),
                      PinField(controller: controller.otpController),
                      SizedBox(height: 20.sp),
                      CustomButton(
                        label: AppLocalizations.of(context)!.submit,
                        onTap: () async {
                          if (verificationTwoFaKey.currentState!
                              .validate()) {
                            setState(() {
                              controller.doEmailVerification(context).whenComplete(() {
                                    if (controller.isSuccess) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>  SegmentedToggleView(
                                            appBarTitle: AppLocalizations.of(context)!.login,
                                          ),
                                        ),
                                      );
                                    }
                                  });
                            });
                          }
                        },
                      ),
                      SizedBox(height: 15.sp),
                      Align(
                        alignment: Alignment.center,
                        child: CustomLinkText(
                          showUnderline: false,
                          label: AppLocalizations.of(
                            context,
                          )!.ifYouReceiveClick,
                          labelTwo: AppLocalizations.of(context)!.resend,
                          onTap: () {
                            controller.doResendCode(context);
                          },
                          textColour:
                              ThemeInversePrimaryColor.getInversePrimaryColor(
                                context,
                              ),
                          fontSize: 16.sp,
                          textColorOne: ThemeTextColor.getTextColor(
                            context,
                          ),
                          labelFontWeight: FontWeight.w500,
                        ),
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
