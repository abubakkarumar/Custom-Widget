import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_otp_field.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Basic_Modules/segmentedToggle/login_register.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'mpin_login_controller.dart';

class MPinForgotView extends StatefulWidget {
  const MPinForgotView({super.key});

  @override
  State<MPinForgotView> createState() => _MPinForgotViewState();
}

class _MPinForgotViewState extends State<MPinForgotView> {
  MPINLoginController controller = MPINLoginController();
  final mPinForgotKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).whenComplete(() async {
      controller.getForgotMPinOtp(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MPINLoginController>(
      builder: (context, value, child) {
        controller = value;

        return Stack(
          children: [
            CustomTotalPageFormat(
              appBarTitle:AppLocalizations.of(context)!.forgotMPIN,
              showBackButton: true,
              child: Form(
                key: mPinForgotKey,
                child: Center(child: uI(context, controller)),
              ),
            ),

            // Loader Layer
            CustomLoader(isLoading: controller.isLoading),
          ],
        );
      },
    );
  }

  uI(BuildContext context, MPINLoginController controller) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label: AppLocalizations.of(context)!.enterVerificationCode,
            fontSize: 15.sp,
            labelFontWeight: FontWeight.bold,
          ),
          SizedBox(height: 12.sp),
          PinField(
            controller: controller.otpController,
            validator: (val) =>
                AppValidations().validateCode(context, val ?? ""),
          ),
          SizedBox(height: 15.sp),
          CustomText(
            label: AppLocalizations.of(context)!.newMPin,
            fontSize: 15.sp,
            labelFontWeight: FontWeight.bold,
          ),
          SizedBox(height: 12.sp),
          PinField(
            controller: controller.newMPinController,
            validator: (val) =>
                AppValidations().validateForgotNewMPIN(context, val ?? ""),
          ),
          SizedBox(height: 15.sp),
          CustomText(
            label: AppLocalizations.of(context)!.confirmMPin,
            fontSize: 15.sp,
            labelFontWeight: FontWeight.bold,
          ),
          SizedBox(height: 12.sp),
          PinField(
            controller: controller.confirmMPinController,
            validator: (val) => AppValidations().validateForgotConfirmMPIN(
                  context,
                  val ?? '',
                  controller.newMPinController.text,
                ),
          ),
          SizedBox(height: 15.sp,),
          Align(
            alignment: Alignment.center,
            child: CustomLinkText(
              showUnderline: false,
              label: AppLocalizations.of(context)!.ifYouReceiveClick,
              labelTwo: AppLocalizations.of(context)!.resend,
              onTap: () => controller.getForgotMPinOtp(context),
              textColour: ThemeInversePrimaryColor.getInversePrimaryColor(
                context,
              ),
              fontSize: 16.sp,
              textColorOne: ThemeTextColor.getTextColor(context),
              labelFontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20.sp),
          CustomButton(
            label:AppLocalizations.of(context)!.submit,
            onTap: () async {
              if (mPinForgotKey.currentState!.validate()) {
                controller.updateForgotMPin(context).whenComplete(() {
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
              }
            },
          ),
        ],
      ),
    );
  }
}
