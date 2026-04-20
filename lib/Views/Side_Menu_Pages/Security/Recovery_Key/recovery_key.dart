import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class RecoveryKeyView extends StatefulWidget {
  const RecoveryKeyView({super.key});

  @override
  State<RecoveryKeyView> createState() => _RecoveryKeyViewState();
}

class _RecoveryKeyViewState extends State<RecoveryKeyView> {
  SecurityController controller = SecurityController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).whenComplete(() {
      controller.getRecoveryKeyPhrase(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityController>(
      builder: (context, value, child) {
        controller = value;
        return Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              child: Form(
                key: controller.securityKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    noteContainer(context, controller),
                    SizedBox(height: 15.sp),
                    Container(
                      padding: EdgeInsets.all(15.sp),
                      decoration: BoxDecoration(
                        color: ThemeTextFormFillColor.getTextFormFillColor(
                          context,
                        ),
                        borderRadius: BorderRadius.circular(10.sp),
                        border: Border.all(
                          width: 5.sp,
                          color: ThemeOutLineColor.getOutLineColor(context),
                        ),
                      ),
                      child: SizedBox(
                        height: 19.5.h,
                        child: Column(
                          children: [
                            GridView.builder(
                              itemCount: controller.recoveryPhraseList.length,
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 3.1,
                                    crossAxisSpacing: 0.sp,
                                    mainAxisSpacing: 0.sp,
                                  ),
                              itemBuilder: (context, index) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: CustomText(
                                    label:
                                        "${index + 1}. ${controller.recoveryPhraseList[index]}",
                                    align: TextAlign.start,
                                    fontSize: 15.sp,
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10.sp),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.sp),
                              child: DottedDivider(
                                color: ThemeTextOneColor.getTextOneColor(
                                  context,
                                ),
                              ),
                            ),
                            SizedBox(height: 15.sp),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (controller
                                        .recoveryPhraseList
                                        .isNotEmpty) {
                                      var recoveryKeys = controller
                                          .recoveryPhraseList
                                          .join(", ");

                                      CustomAnimationToast.show(
                                        message: AppLocalizations.of(
                                          context,
                                        )!.recoveryKeysCopied,
                                        context: context,
                                      );
                                      Clipboard.setData(
                                        ClipboardData(text: recoveryKeys),
                                      );
                                    } else {
                                      CustomAnimationToast.show(
                                        message: AppLocalizations.of(
                                          context,
                                        )!.noRecoveryKeysFound,
                                        context: context,
                                      );
                                    }
                                  },
                                  child: SizedBox(
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          AppBasicIcons.copy,
                                          width: 16.sp,
                                          height: 16.sp,
                                        ),
                                        SizedBox(width: 15.sp),
                                        CustomText(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.copy,
                                          fontSize: 15.sp,
                                          fontColour:
                                              ThemeTextOneColor.getTextOneColor(
                                                context,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15.sp),
                    CustomText(
                      label: AppLocalizations.of(context)!.recoveryKeysSubText,
                      fontColour: ThemeTextOneColor.getTextOneColor(context),
                    ),
                    SizedBox(height: 15.sp),
                    GestureDetector(
                      onTap: () {
                        controller.toggleTermsAccepted();
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20.0,
                            height: 20.0,
                            decoration: BoxDecoration(
                              color: controller.isRecoveryCheckBox
                                  ? ThemePrimaryColor.getPrimaryColor(context)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: controller.isRecoveryCheckBox
                                    ? ThemeOutLineColor.getOutLineColor(context)
                                    : Colors.grey.shade500,
                                width: 2.5.sp,
                              ),
                            ),
                            child: controller.isRecoveryCheckBox
                                ? Icon(
                                    Icons.check,
                                    size: 20.0 - 6,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: ThemeTextOneColor.getTextOneColor(
                                    context,
                                  ),
                                  fontSize: 15.sp,
                                ),
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.iAcceptTheDeal,
                                    style: TextStyle(
                                      color: ThemeTextColor.getTextColor(
                                        context,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.sp),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          label:
                              "${AppLocalizations.of(context)!.enterPassphraseNo} ${controller.recoveryKeyPosition}",
                          fontSize: 16.sp,
                        ),
                        SizedBox(height: 12.sp),
                        CustomTextFieldWidget(
                          line: 1,
                          controller: controller.recoveryKeyPhraseController,
                          hintText: AppLocalizations.of(
                            context,
                          )!.enterRecoveryKey,
                          onValidate: (val) =>
                              AppValidations().validateRecoveryKey(
                                context,
                                val ?? '',
                                controller
                                    .recoveryPhraseList[controller
                                            .recoveryKeyPosition -
                                        1]
                                    .toString(),
                              ),

                          readOnly: false,
                        ),
                        SizedBox(height: 2.h),
                        controller.isLoading
                            ? const CustomProgressDialog()
                            : Row(
                                children: [
                                  Expanded(
                                    child: CancelButton(
                                      label: AppLocalizations.of(
                                        context,
                                      )!.cancel,

                                      onTap: () {
                                        Navigator.pop(context);
                                        controller.recoveryKeyPhraseController
                                            .clear();
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12.sp),
                                  Expanded(
                                    child: CustomButton(
                                      label: AppLocalizations.of(
                                        context,
                                      )!.submit,
                                      onTap: () {
                                        if (controller.isRecoveryCheckBox) {
                                          if (controller
                                              .securityKey
                                              .currentState!
                                              .validate()) {
                                            controller
                                                .doRecoveryKeyPhrase(context)
                                                .whenComplete(() {
                                                  if (controller.isSuccess) {
                                                    Navigator.pop(context);
                                                  }
                                                });
                                          }
                                        } else {
                                          CustomAnimationToast.show(
                                            message: AppLocalizations.of(
                                              context,
                                            )!.pleaseAcceptDeal,
                                            type: ToastType.error,
                                            context: context,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            /// Loader
            CustomLoader(isLoading: controller.isLoading),
          ],
        );
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
            label: AppLocalizations.of(context)!.recoveryKeysSubText,
            fontSize: 14.sp,
            labelFontWeight: FontWeight.w400,
            fontColour: ThemeTextOneColor.getTextOneColor(context),
          ),
        ],
      ),
    );
  }
}
