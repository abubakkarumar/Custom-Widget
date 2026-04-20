import 'package:flutter/material.dart';
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

class AntiPhishingCodeView extends StatefulWidget {
  BuildContext parentContext;
  AntiPhishingCodeView({super.key, required this.parentContext});

  @override
  State<AntiPhishingCodeView> createState() => _AntiPhishingCodeViewState();
}

class _AntiPhishingCodeViewState extends State<AntiPhishingCodeView> {
  SecurityController controller = SecurityController();

  @override
  void initState() {
    Future.delayed(Duration.zero).whenComplete(() async {
      controller.antiPhishingCodeController.clear();
      controller.antiPhishingCodeOtpCode.clear();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityController>(
      builder: (context, value, child) {
        controller = value;
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        label: AppLocalizations.of(
                          context,
                        )!.whatAntiPhishingCode,
                        fontSize: 15.sp,
                      ),
                      SizedBox(height: 10.sp),
                      CustomText(
                        label: AppLocalizations.of(
                          context,
                        )!.whatAntiPhishingCodeSubText,
                        fontColour: ThemeTextOneColor.getTextOneColor(context),
                        fontSize: 14.5.sp,
                      ),
                      SizedBox(height: 15.sp),
                      CustomText(
                        label: AppLocalizations.of(context)!.howDoesItWorks,
                        fontSize: 15.sp,
                      ),
                      SizedBox(height: 10.sp),
                      CustomText(
                        label: AppLocalizations.of(
                          context,
                        )!.howDoesItWorksSubText,
                        fontColour: ThemeTextOneColor.getTextOneColor(context),
                        fontSize: 14.5.sp,
                      ),
                      SizedBox(height: 15.sp),
                      noteContainer(context, controller),

                      controller.antiPhishingCode.isNotEmpty
                          ? SizedBox(height: 15.sp)
                          : SizedBox(height: 0.sp),
                      controller.antiPhishingCode.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.yourAntiPhishingCode,
                                  fontSize: 15.sp,
                                ),
                                SizedBox(height: 6.sp),
                                CustomText(
                                  label: controller.antiPhishingCode,
                                  fontSize: 16.sp,
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                      SizedBox(height: 15.sp),
                      controller.isLoading
                          ? const CustomProgressDialog()
                          : CustomButton(
                              label: AppStorage.getAntiPhishingCodeStatus() == 0
                                  ? AppLocalizations.of(
                                      context,
                                    )!.createAntiPhishingCode
                                  : AppLocalizations.of(
                                      context,
                                    )!.regenerateAntiPhishingCode,
                              onTap: () {
                                Navigator.pop(widget.parentContext);
                                controller
                                    .getAntiPhishingCodeOtp(
                                      widget.parentContext,
                                    )
                                    .whenComplete(() {
                                      createAntiPhishingCode(
                                        widget.parentContext,
                                        controller,
                                      );
                                    });
                              },
                            ),
                    ],
                  ),
                ],
              ),
            ),
            CustomLoader(isLoading: controller.isLoading),
          ],
        );
      },
    );
  }

  createAntiPhishingCode(BuildContext context, SecurityController controller) {
    return customAlert(
      context: context,
      title: AppLocalizations.of(context)!.antiPhishingCode,
      onTapBack: () {
        Navigator.pop(context);
        controller.antiPhishingCodeController.clear();
      },
      widget: Consumer<SecurityController>(
        builder: (context, value, child) {
          controller = value;
          return Form(
            key: controller.antiPhishingCodeKey,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    noteContainer(context, controller),
                    SizedBox(height: 15.sp),
                    CustomText(
                      label:
                          "${AppLocalizations.of(context)!.enterDigitOTPSentYourEmail} ${AppStorage.getUserEmail() ?? ""}",
                      fontSize: 14.5.sp,
                      labelFontWeight: FontWeight.w500,
                      lineSpacing: 1.5,
                    ),
                    SizedBox(height: 15.sp),

                    PinField(controller: controller.antiPhishingCodeOtpCode),
                    SizedBox(height: 15.sp),

                    CustomTextFieldWidget(
                      line: 1,
                      label: AppLocalizations.of(context)!.enterYourCode,
                      controller: controller.antiPhishingCodeController,
                      hintText: "",
                      keyboardType: TextInputType.text,
                      obscure: !controller.isAntiPhishingCode,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isAntiPhishingCode
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: ThemeTextOneColor.getTextOneColor(context),
                          size: 20.sp,
                        ),
                        onPressed: () {
                          controller.isAntiPhishingCodeFunc(
                            controller.isAntiPhishingCode,
                          );
                        },
                      ),
                      onValidate: (val) =>
                          AppValidations().validateCode(context, val ?? ""),
                      readOnly: false,
                    ),
                    SizedBox(height: 15.sp),
                    CustomText(
                      label: AppLocalizations.of(
                        context,
                      )!.pleaseEnterCharacters,
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
                                  onTap: () {
                                    Navigator.pop(context);
                                    controller.antiPhishingCodeController
                                        .clear();
                                  },
                                ),
                              ),
                              SizedBox(width: 12.sp),
                              Expanded(
                                child: CustomButton(
                                  label: AppLocalizations.of(context)!.submit,
                                  onTap: () {
                                    if (controller
                                        .antiPhishingCodeKey
                                        .currentState!
                                        .validate()) {
                                      controller
                                          .enableUpdateAntiPhishingCode(context)
                                          .whenComplete(() {
                                            if (controller.isSuccess) {
                                              AppNavigator.pop();
                                              AppNavigator.pop();
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
                CustomLoader(isLoading: controller.isLoading),
              ],
            ),
          );
        },
      ),
      onDismiss: () {
        controller.antiPhishingCodeController.clear();
      },
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
            label: AppLocalizations.of(
              context,
            )!.antiPhishingCodeAfterEnablingIncluded,
            fontSize: 14.sp,
            labelFontWeight: FontWeight.w400,
            fontColour: ThemeTextOneColor.getTextOneColor(context),
          ),
        ],
      ),
    );
  }
}
