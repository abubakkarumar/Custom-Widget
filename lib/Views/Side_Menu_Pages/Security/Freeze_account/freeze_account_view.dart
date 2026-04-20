// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_otp_field.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_controller.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_view.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class FreezeAccountView extends StatefulWidget {
  const FreezeAccountView({super.key});

  @override
  State<FreezeAccountView> createState() => _FreezeAccountViewState();
}

class _FreezeAccountViewState extends State<FreezeAccountView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<SecurityController>(
        context,
        listen: false,
      );
      controller.isFreezeOrDeleteAccount = true;
      controller.conditionIdFunc(0);
      controller.checkBoxIdFunc(-1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
          body: Stack(
            alignment: Alignment.center,
            children: [
              CustomTotalPageFormat(
                appBarTitle: controller.freezeAccountStatus == 0
                    ? AppLocalizations.of(context)!.freezeAccount
                    : AppLocalizations.of(context)!.unFreezeAccount,
                showBackButton: true,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      controller.freezeAccountStatus == 0
                          ? Column(
                              children: [
                                CustomText(
                                  label:
                                      "${AppLocalizations.of(context)!.wantFreezeAccount} ${AppStorage.getUserEmail()}?",
                                  fontColour: ThemeTextOneColor.getTextOneColor(
                                    context,
                                  ),
                                ),
                                SizedBox(height: 12.sp),

                                CustomText(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.freezeAccountFollowingAutomatically,
                                ),
                                SizedBox(height: 15.sp),

                                /// TERMS BOX
                                _termsBox(context),

                                SizedBox(height: 15.sp),

                                /// REASONS
                                _reasonSelector(controller, context),

                                SizedBox(height: 15.sp),

                                /// AGREEMENT CHECKBOX
                                GestureDetector(
                                  onTap: () => controller.conditionIdFunc(
                                    controller.conditionId == 1 ? 0 : 1,
                                  ),
                                  child: Row(
                                    children: [
                                      CheckboxBox(
                                        isActive: controller.conditionId == 1,
                                      ),
                                      SizedBox(width: 12.sp),
                                      Expanded(
                                        child: CustomText(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.freezeAccountCheckBoxText,
                                          fontSize: 14.5.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : CustomText(
                              label: AppLocalizations.of(
                                context,
                              )!.unFreezeAccountFollowingAutomatically,
                            ),

                      SizedBox(height: 15.sp),

                      /// ACTION BUTTON
                      controller.isLoading
                          ? const CustomProgressDialog()
                          : CustomButton(
                              label: controller.freezeAccountStatus == 0
                                  ? AppLocalizations.of(context)!.freezeAccount
                                  : AppLocalizations.of(
                                      context,
                                    )!.unFreezeAccount,
                              onTap: () {
                                if (controller.freezeAccountStatus == 0) {
                                  if (controller.checkBoxId == -1) {
                                    CustomAnimationToast.show(
                                      message: AppLocalizations.of(
                                        context,
                                      )!.pleaseSelectReasonProceed,
                                      type: ToastType.error,
                                      context: context,
                                    );
                                    return;
                                  }

                                  if (controller.conditionId != 1) {
                                    CustomAnimationToast.show(
                                      message: AppLocalizations.of(
                                        context,
                                      )!.pleaseAcceptCondition,
                                      type: ToastType.error,
                                      context: context,
                                    );
                                    return;
                                  }
                                  String type =
                                      controller.freezeAccountStatus == 0
                                      ? AppLocalizations.of(context)!.enable
                                      : AppLocalizations.of(context)!.disable;
                                  freezeAlertBox(type);
                                } else {
                                  String type =
                                      controller.freezeAccountStatus == 0
                                      ? AppLocalizations.of(context)!.enable
                                      : AppLocalizations.of(context)!.disable;
                                  freezeAlertBox(type);
                                }
                              },
                            ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),

              /// LOADER OVERLAY
              CustomLoader(isLoading: controller.isLoading),
            ],
          ),
        );
      },
    );
  }

  /// TERMS BOX COMPONENT
  Widget _termsBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(context),
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 5.sp,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bullet(context, AppLocalizations.of(context)!.freezeAccountSubTwo),
          SizedBox(height: 10.sp),
          _bullet(context, AppLocalizations.of(context)!.freezeAccountSubThree),
          SizedBox(height: 10.sp),
          _bullet(context, AppLocalizations.of(context)!.freezeAccountSubFour),
          SizedBox(height: 10.sp),
          _bullet(context, AppLocalizations.of(context)!.freezeAccountSubFive),
          SizedBox(height: 10.sp),
          _bullet(context, AppLocalizations.of(context)!.freezeAccountSubSix),
          SizedBox(height: 10.sp),
          _bullet(context, AppLocalizations.of(context)!.freezeAccountSubSeven),
          SizedBox(height: 10.sp),
          _bullet(context, AppLocalizations.of(context)!.freezeAccountSubEight),
        ],
      ),
    );
  }

  /// BULLETED TEXT
  Widget _bullet(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label: "\u2022 ",
          fontSize: 15.sp,
          fontColour: ThemeTextOneColor.getTextOneColor(context),
        ),
        Expanded(
          child: CustomText(
            label: text,
            fontSize: 14.5.sp,
            fontColour: ThemeTextOneColor.getTextOneColor(context),
          ),
        ),
      ],
    );
  }

  /// REASON SELECTOR
  Widget _reasonSelector(SecurityController controller, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(context),
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 5.sp,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label: AppLocalizations.of(context)!.selectReasonFreezeAccount,
          ),
          SizedBox(height: 10.sp),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.freezeAccountReasonsList(context).length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => controller.checkBoxIdFunc(i),
              child: Padding(
                padding: EdgeInsets.only(bottom: 15.sp),
                child: Row(
                  children: [
                    CheckboxBox(isActive: controller.checkBoxId == i),
                    SizedBox(width: 15.sp),
                    Expanded(
                      child: CustomText(
                        label: controller.freezeAccountReasonsList(context)[i],
                        fontSize: 14.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// CONFIRM POPUP
  Future<void> freezeAlertBox(String type) async {
    await customAlert(
      context: context,
      title: AppLocalizations.of(context)!.confirm,
      widget: Consumer<SecurityController>(
        builder: (context, controller, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  CustomText(
                    label: type == "Enable"
                        ? AppLocalizations.of(context)!.wantToFreezeAccount
                        : AppLocalizations.of(
                            context,
                          )!.wantToDisableFreezeAccount,
                    fontSize: 14.5.sp,
                  ),
                  SizedBox(height: 18.sp),
                  Row(
                    children: [
                      Expanded(
                        child: CancelButton(
                          label: AppLocalizations.of(context)!.cancel,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 15.sp),
                      Expanded(
                        child: controller.isLoading
                            ? const CustomProgressDialog()
                            : CustomButton(
                                label: AppLocalizations.of(context)!.confirm,
                                onTap: () async {
                                  String type =
                                      controller.freezeAccountStatus == 0
                                      ? 'enable'
                                      : 'disable';

                                  await controller.sendOtpFreezeAccount(
                                    context,
                                    type,
                                  );

                                  if (!context.mounted) return;

                                  Navigator.pop(context);
                                  _freezeOtpPopup(context, type);
                                },
                              ),
                      ),
                    ],
                  ),
                ],
              ),
              CustomLoader(isLoading: controller.isLoading),
            ],
          );
        },
      ),
    );
  }

  void _freezeOtpPopup(BuildContext context, String type) {
    customAlert(
      context: context,
      title: type == "enable"
          ? AppLocalizations.of(context)!.freezeAccountVerification
          : AppLocalizations.of(context)!.unFreezeAccountVerification,
      widget: Consumer<SecurityController>(
        builder: (context, controller, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    label:
                        "${AppLocalizations.of(context)!.enterDigitOTPSentYourEmail} ${AppStorage.getUserEmail()}",
                    fontSize: 14.5.sp,
                  ),
                  SizedBox(height: 12.sp),

                  PinField(controller: controller.freezeAccountOtp),

                  SizedBox(height: 12.sp),

                  Align(
                    alignment: Alignment.center,
                    child: CustomLinkText(
                      showUnderline: false,
                      label: AppLocalizations.of(context)!.ifYouReceiveClick,
                      labelTwo: AppLocalizations.of(context)!.resend,
                      onTap: () =>
                          controller.sendOtpFreezeAccount(context, type),
                      textColour:
                          ThemeInversePrimaryColor.getInversePrimaryColor(
                            context,
                          ),
                      fontSize: 16.sp,
                      textColorOne: ThemeTextColor.getTextColor(context),
                      labelFontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Row(
                    children: [
                      Expanded(
                        child: CancelButton(
                          label: AppLocalizations.of(context)!.cancel,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(width: 15.sp),
                      Expanded(
                        child: controller.isLoading
                            ? const CustomProgressDialog()
                            : CustomButton(
                                label: AppLocalizations.of(context)!.submit,
                                onTap: () async {
                                  await controller.confirmFreezeAccount(
                                    context,
                                    type,
                                  );
                                  if (controller.isSuccess) {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SecurityView(),
                                      ),
                                    );
                                  }
                                },
                              ),
                      ),
                    ],
                  ),
                ],
              ),

              CustomLoader(isLoading: controller.isLoading),
            ],
          );
        },
      ),
    );
  }
}

/// CHECKBOX COMMON WIDGET
class CheckboxBox extends StatelessWidget {
  final bool isActive;
  const CheckboxBox({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: isActive
            ? null
            : Border.all(color: Colors.grey.shade500, width: 2),
        gradient: isActive
            ? const LinearGradient(
                colors: [Colors.blueAccent, Colors.deepPurpleAccent],
              )
            : null,
      ),
      child: isActive
          ? const Icon(Icons.check, size: 15, color: Colors.white)
          : null,
    );
  }
}
