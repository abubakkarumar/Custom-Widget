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
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewViewState();
}

class _ChangePasswordViewViewState extends State<ChangePasswordView> {
  SecurityController controller = SecurityController();

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityController>(
      builder: (context, value, child) {
        controller = value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                CustomText(
                  label: AppLocalizations.of(
                    context,
                  )!.changePasswordNoteSubText,
                  fontColour: ThemeTextOneColor.getTextOneColor(context),
                ),
                SizedBox(height: 15.sp),
                controller.isLoading
                    ? const CustomProgressDialog()
                    : Row(
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
                              label: AppLocalizations.of(context)!.confirm,
                              onTap: () async {
                                controller
                                    .getChangePasswordOtp(context)
                                    .whenComplete(() {
                                      AppNavigator.pop();
                                      changePassword();
                                    });
                              },
                            ),
                          ),
                        ],
                      ),
              ],
            ),
            if (controller.isLoading)
              CustomLoader(isLoading: controller.isLoading),
          ],
        );
      },
    );
  }

  changePassword() {
    return customAlert(
      context: context,
      title: AppLocalizations.of(context)!.changeLoginPassword,
      widget: Consumer<SecurityController>(
        builder: (context, value, child) {
          controller = value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Form(
                key: controller.changePasswordKey,
                child: Column(
                  children: [
                    noteContainer(context, controller),
                    SizedBox(height: 15.sp),
                    CustomText(
                      label:
                          "${AppLocalizations.of(context)!.enterDigitOTPSentYourEmail} ${AppStorage.getUserEmail() ?? ""}",
                      fontSize: 15.sp,
                      labelFontWeight: FontWeight.w400,
                      lineSpacing: 1.5,
                    ),
                    SizedBox(height: 15.sp),

                    PinField(controller: controller.changePasswordOtpCode),

                    SizedBox(height: 15.sp),
                    CustomTextFieldWidget(
                      hintText: AppLocalizations.of(
                        context,
                      )!.enterCurrentPassword,
                      readOnly: false,
                      line: 1,
                      label: AppLocalizations.of(context)!.currentPassword,
                      controller: controller.currentPassword,
                      node: controller.currentPasswordNode,
                      obscure: !controller.isCurrentPassword,
                      suffixIcon: CustomIconButton(
                        onTap: () {
                          controller.isCurrentPasswordFunc(
                            controller.isCurrentPassword,
                          );
                        },
                        child: IconButton(
                          onPressed: () {
                            controller.isCurrentPasswordFunc(
                              controller.isCurrentPassword,
                            );
                          },
                          icon: Icon(
                            controller.isCurrentPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20.sp,
                            color: ThemeTextOneColor.getTextOneColor(context),
                          ),
                        ),
                      ),
                      onValidate: (val) =>
                          AppValidations().newPassword(context, val ?? ""),
                    ),
                    SizedBox(height: 15.sp),
                    CustomTextFieldWidget(
                      readOnly: false,
                      hintText: AppLocalizations.of(context)!.enterNewPassword,
                      line: 1,
                      label: AppLocalizations.of(context)!.newPassword,
                      labelTwo: "",
                      controller: controller.newPassword,
                      node: controller.newPasswordNode,
                      obscure: !controller.isNewPassword,
                      suffixIcon: CustomIconButton(
                        onTap: () {
                          controller.isNewPasswordFunc();
                        },
                        child: IconButton(
                          onPressed: () {
                            controller.isNewPasswordFunc();
                          },
                          icon: Icon(
                            controller.isNewPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20.sp,
                            color: ThemeTextOneColor.getTextOneColor(context),
                          ),
                        ),
                      ),
                      onValidate: (val) =>
                          AppValidations().newPassword(context, val ?? ""),
                    ),
                    SizedBox(height: 10.sp),
                    // Info Icon
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {
                          controller.togglePasswordTooltip(
                            context,
                            AppLocalizations.of(context)!.passwordRequirements,
                          );
                        },
                        child: Icon(
                          Icons.info_outline,
                          color: ThemeTextOneColor.getTextOneColor(context),
                          size: 18.sp,
                        ),
                      ),
                    ),

                    CustomTextFieldWidget(
                      hintText: AppLocalizations.of(
                        context,
                      )!.enterConfirmPassword,
                      readOnly: false,
                      line: 1,
                      label: AppLocalizations.of(context)!.confirmPassword,
                      labelTwo: "",
                      controller: controller.confirmPassword,
                      node: controller.confirmPasswordNode,
                      obscure: !controller.isConfirmPassword,
                      suffixIcon: CustomIconButton(
                        onTap: () {
                          controller.isConfirmPasswordFunc();
                        },
                        child: IconButton(
                          onPressed: () {
                            controller.isConfirmPasswordFunc();
                          },
                          icon: Icon(
                            controller.isConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20.sp,
                            color: ThemeTextOneColor.getTextOneColor(context),
                          ),
                        ),
                      ),
                      onValidate: (val) => AppValidations().confirmPassword(
                        context,
                        controller.confirmPassword.text,
                        val ?? "",
                      ),
                    ),
                    SizedBox(height: 15.sp),
                    controller.isLoading
                        ? const CustomProgressDialog()
                        : Row(
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
                                  label: AppLocalizations.of(context)!.confirm,
                                  onTap: () async {
                                    if (controller
                                        .changePasswordKey
                                        .currentState!
                                        .validate()) {
                                      controller
                                          .doChangePassword(context)
                                          .whenComplete(() async {
                                            if (controller.isSuccess) {
                                              await GetStorage().erase();
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
              if (controller.isLoading)
                CustomLoader(isLoading: controller.isLoading),
            ],
          );
        },
      ),
    );
  }

  noteContainer(BuildContext context, SecurityController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: ThemeNoteColor.getNoteColorColor(context),
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: const Color(0xFF5d9cf7), width: 5.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label: AppLocalizations.of(context)!.note,
            labelFontWeight: FontWeight.bold,
            fontSize: 16.sp,
            fontColour: ThemeInversePrimaryColor.getInversePrimaryColor(
              context,
            ),
          ),
          SizedBox(height: 10.sp),
          CustomText(
            label: AppLocalizations.of(context)!.changePasswordNoteSubText,
            fontSize: 14.sp,
            labelFontWeight: FontWeight.w400,
            fontColour: ThemeTextOneColor.getTextOneColor(context),
          ),
        ],
      ),
    );
  }
}
