// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_otp_field.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class MPinView extends StatefulWidget {
  const MPinView({super.key});

  @override
  State<MPinView> createState() => _MPinViewState();
}

class _MPinViewState extends State<MPinView> {
  SecurityController controller = SecurityController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).whenComplete(() async {
      controller.resetData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityController>(
      builder: (context, value, _) {
        controller = value;
        return Stack(
          alignment: Alignment.center,
          children: [
            CustomTotalPageFormat(
              appBarTitle: AppStorage.getMPINStatus() == 0
                  ? AppLocalizations.of(context)!.createMPIN
                  : AppLocalizations.of(context)!.changeMPIN,
              child:
                  /// MAIN UI
                  SingleChildScrollView(
                    child: Form(
                      key: controller.mPinKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (AppStorage.getMPINStatus() != 0)
                            CustomText(
                              label: AppLocalizations.of(context)!.currentMPin,
                              fontSize: 15.sp,
                            ),
                          if (AppStorage.getMPINStatus() != 0)
                            SizedBox(height: 10.sp),
                          if (AppStorage.getMPINStatus() != 0)
                            PinField(
                              controller: controller.currentMPinController,
                              validator: (val) => AppValidations()
                                  .validateCurrentMpin(context, val ?? ""),
                            ),
                          if (AppStorage.getMPINStatus() != 0)
                            SizedBox(height: 15.sp),

                          CustomText(
                            label: AppLocalizations.of(context)!.newMPin,
                            fontSize: 15.sp,
                          ),
                          SizedBox(height: 10.sp),
                          PinField(
                            controller: controller.newMPinController,
                            validator: (val) => AppValidations()
                                .validateNewMPIN(context, val ?? ""),
                          ),
                          SizedBox(height: 15.sp),

                          CustomText(
                            label: AppLocalizations.of(context)!.confirmMPin,
                            fontSize: 15.sp,
                          ),
                          SizedBox(height: 10.sp),
                          PinField(
                            controller: controller.confirmMPinController,
                            validator: (val) =>
                                AppValidations().validateConfirmMPIN(
                                  context,
                                  val ?? '',
                                  controller.newMPinController.text,
                                ),
                          ),
                          SizedBox(height: 20.sp),

                          /// BUTTON ROW
                          controller.isLoading
                              ? const CustomProgressDialog()
                              : Row(
                                  children: [
                                    Expanded(
                                      child: CancelButton(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.cancel,
                                        onTap: () => AppNavigator.pop(),
                                      ),
                                    ),
                                    SizedBox(width: 15.sp),
                                    Expanded(
                                      child: CustomButton(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.confirm,
                                        onTap: () async {
                                          if (controller.mPinKey.currentState!
                                              .validate()) {
                                            if (AppStorage.getMPINStatus() ==
                                                0) {
                                              await controller
                                                  .createMPin(context)
                                                  .whenComplete(() {
                                                    if (controller.isSuccess) {
                                                      Future.delayed(
                                                        const Duration(
                                                          seconds: 3,
                                                        ),
                                                        () =>
                                                            AppNavigator.pop(),
                                                      );
                                                    }
                                                  });
                                            } else {
                                              await controller
                                                  .updateMPin(context)
                                                  .whenComplete(() {
                                                    if (controller.isSuccess) {
                                                      AppNavigator.pop();
                                                    }
                                                  });
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
            ),

            /// FULLSCREEN OVERLAY LOADER CENTERED
            if (controller.isLoading) CustomLoader(isLoading: true),

            /// VERIFIED ANIMATION CENTERED
            if (controller.isMPinVerified)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Center(
                    child: AppStorage.getLanguage() == 'cn'
                        ? SvgPicture.asset(
                            AppThemeIcons.mPinVerifiedCh(context),
                            height: 18.h,
                          )
                        : SvgPicture.asset(
                            AppThemeIcons.mPinVerified(context),
                            height: 18.h,
                          ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
