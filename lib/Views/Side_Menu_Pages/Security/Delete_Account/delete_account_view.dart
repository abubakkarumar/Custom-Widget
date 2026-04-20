// ignore_for_file: use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_otp_field.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class DeleteAccountView extends StatefulWidget {
  const DeleteAccountView({super.key});

  @override
  State<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends State<DeleteAccountView> {
  int selectedReasonIndex = -1; // -1 means nothing selected
  bool isAgreementChecked = false;

  final deleteAccountOtpKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Ensure UI starts with nothing selected.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        selectedReasonIndex = -1;
        isAgreementChecked = false;
      });
      // Also try to reset controller-side fields if the controller exposes them.
      try {
        final controller = Provider.of<SecurityController>(
          context,
          listen: false,
        );
        controller.checkBoxId = -1; // best-effort; safe if property exists
        controller.conditionId = 0;
      } catch (_) {}
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
                appBarTitle: AppLocalizations.of(context)!.deleteAccount,
                showBackButton: true,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _noteBox(context),
                        SizedBox(height: 2.h),

                        CustomText(
                          label: AppLocalizations.of(
                            context,
                          )!.deleteAccountSubOne,
                          fontSize: 15.5.sp,
                        ),
                        SizedBox(height: 15.sp),

                        _termPoint(
                          context,
                          AppLocalizations.of(context)!.deleteAccountSubTwo,
                        ),
                        _termPoint(
                          context,
                          AppLocalizations.of(context)!.deleteAccountSubThree,
                        ),
                        _termPoint(
                          context,
                          AppLocalizations.of(context)!.deleteAccountSubFour,
                        ),
                        _termPoint(
                          context,
                          AppLocalizations.of(context)!.deleteAccountSubFive,
                        ),
                        _termPoint(
                          context,
                          AppLocalizations.of(context)!.deleteAccountSubSix,
                        ),

                        SizedBox(height: 15.sp),
                        _accountInfoBox(context),
                        SizedBox(height: 15.sp),

                        _reasonSelector(controller, context),
                        SizedBox(height: 10.sp),

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
                              Flexible(
                                child: CustomText(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.deleteAccountUnderstandAgree,
                                  fontSize: 14.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 18.sp),
                        controller.isLoading
                            ? const CustomProgressDialog()
                            : CustomButton(
                                label: AppLocalizations.of(
                                  context,
                                )!.deleteAccount,
                                onTap: () {
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

                                  if (controller.conditionId == 0) {
                                    CustomAnimationToast.show(
                                      message: AppLocalizations.of(
                                        context,
                                      )!.pleaseAcceptCondition,
                                      type: ToastType.error,
                                      context: context,
                                    );
                                    return;
                                  }
                                  deleteAlertBox();
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ),

              CustomLoader(isLoading: controller.isLoading),
            ],
          ),
        );
      },
    );
  }

  Widget deleteAlertBox() {
    return customAlert(
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
                    label: AppLocalizations.of(context)!.deleteAccountSubText,
                    fontSize: 14.5.sp,
                  ),
                  SizedBox(height: 18.sp),
                  controller.isLoading
                      ? const CustomProgressDialog()
                      : Row(
                          children: [
                            Expanded(
                              child: CancelButton(
                                label: AppLocalizations.of(context)!.cancel,
                                onTap: () => AppNavigator.pop(),
                              ),
                            ),
                            SizedBox(width: 15.sp),
                            Expanded(
                              child: CustomButton(
                                label: AppLocalizations.of(context)!.confirm,
                                onTap: () async {
                                  await controller.getDeleteOtp(context);

                                  customAlert(
                                    context: context,
                                    title: AppLocalizations.of(
                                      context,
                                    )!.securityVerification,
                                    widget: Consumer<SecurityController>(
                                      builder: (context, controller, _) {
                                        return Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Form(
                                              key: deleteAccountOtpKey,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    label:
                                                        "${AppLocalizations.of(context)!.pleaseEnterDigitVerificationCode} ${AppStorage.getUserEmail() ?? ""}",
                                                    fontSize: 14.5.sp,
                                                  ),
                                                  SizedBox(height: 12.sp),

                                                  PinField(
                                                    controller: controller
                                                        .deleteAccountOtp,
                                                    validator: (val) =>
                                                        AppValidations()
                                                            .validateCode(
                                                              context,
                                                              val ?? "",
                                                            ),
                                                  ),

                                                  SizedBox(height: 12.sp),
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: CustomLinkText(
                                                      showUnderline: false,
                                                      label:
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.ifYouReceiveClick,
                                                      labelTwo:
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.resend,
                                                      onTap: () {
                                                        controller.getDeleteOtp(
                                                          context,
                                                        );
                                                      },
                                                      textColour:
                                                          ThemeInversePrimaryColor.getInversePrimaryColor(
                                                            context,
                                                          ),
                                                      fontSize: 16.sp,
                                                      textColorOne:
                                                          ThemeTextColor.getTextColor(
                                                            context,
                                                          ),
                                                      labelFontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(height: 3.h),
                                                  controller.isLoading
                                                      ? const CustomProgressDialog()
                                                      : Row(
                                                          children: [
                                                            Expanded(
                                                              child: CancelButton(
                                                                label:
                                                                    AppLocalizations.of(
                                                                      context,
                                                                    )!.cancel,
                                                                onTap: () {
                                                                  controller
                                                                      .deleteAccountOtp
                                                                      .clear();
                                                                  AppNavigator.pop();
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 15.sp,
                                                            ),
                                                            Expanded(
                                                              child: CustomButton(
                                                                label:
                                                                    AppLocalizations.of(
                                                                      context,
                                                                    )!.submit,
                                                                onTap: () async {
                                                                  if (deleteAccountOtpKey
                                                                      .currentState!
                                                                      .validate()) {
                                                                    controller.doDeleteAccount(context).whenComplete(() async {
                                                                      if (controller
                                                                          .isSuccess) {
                                                                        AppNavigator.pop();
                                                                        controller
                                                                            .deleteAccountOtp
                                                                            .clear();
                                                                        await GetStorage()
                                                                            .erase();
                                                                        AppNavigator.popToRoot();
                                                                      }
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                ],
                                              ),
                                            ),

                                            /// Loader overlay here
                                            CustomLoader(
                                              isLoading: controller.isLoading,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ],
              ),

              /// Loader overlay for first confirm alert
              CustomLoader(isLoading: controller.isLoading),
            ],
          );
        },
      ),
    );
  }

  /// NOTE BOX
  Widget _noteBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: ThemeNoteColor.getNoteColorColor(context),
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: const Color(0xFF5d9cf7), width: 4.sp),
      ),
      child: CustomText(
        label: AppLocalizations.of(context)!.deleteAccountNote,
        fontSize: 14.sp,
      ),
    );
  }

  Widget _termPoint(BuildContext context, String text) => Padding(
    padding: EdgeInsets.only(bottom: 10.sp),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(label: "\u2022 ", fontSize: 15.sp),
        Expanded(
          child: CustomText(label: text, fontSize: 14.5.sp),
        ),
      ],
    ),
  );

  /// ACCOUNT INFO BOX
  Widget _accountInfoBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(context),
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 4.sp,
        ),
      ),
      child: Column(
        children: [
          _bulletedText(
            "1.",
            AppLocalizations.of(context)!.deleteAccountStepOne,
          ),
          SizedBox(height: 12.sp),
          _bulletedText(
            "2.",
            AppLocalizations.of(context)!.deleteAccountStepTwo,
          ),
          SizedBox(height: 12.sp),
          _bulletedText(
            "3.",
            AppLocalizations.of(context)!.deleteAccountStepThree,
          ),
        ],
      ),
    );
  }

  Widget _bulletedText(String num, String text) => Row(
    children: [
      CustomText(label: "$num ", fontSize: 15.sp),
      Expanded(
        child: CustomText(label: text, fontSize: 14.5.sp),
      ),
    ],
  );

  /// Reason selector
  Widget _reasonSelector(SecurityController controller, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(context),
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 4.sp,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label: AppLocalizations.of(context)!.deleteAccountDisabled,
            fontSize: 16.sp,
          ),
          SizedBox(height: 12.sp),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.deleteAccountReasonsList(context).length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => controller.checkBoxIdFunc(i),
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.sp),
                child: Row(
                  children: [
                    CheckboxBox(isActive: controller.checkBoxId == i),
                    SizedBox(width: 15.sp),
                    Expanded(
                      child: CustomText(
                        label: controller.deleteAccountReasonsList(context)[i],
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
}

/// Checkbox UI
class CheckboxBox extends StatelessWidget {
  final bool isActive;
  const CheckboxBox({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: isActive
            ? null
            : Border.all(
                color: ThemeTextOneColor.getTextOneColor(context),
                width: 2,
              ),
        gradient: isActive
            ? LinearGradient(
                colors: [
                  Color(0xFF007FFF),
                  Color(0xFF623EF8),
                  Color(0xFFBF00FF),
                ],
                stops: [0.0, 0.35, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
      ),
      child: isActive ? Icon(Icons.check, size: 15, color: Colors.white) : null,
    );
  }
}
