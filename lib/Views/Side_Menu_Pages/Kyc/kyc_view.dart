import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_image_picker.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Kyc/kyc_controller.dart';
import 'package:intl/intl.dart';
import 'package:zayroexchange/Utility/custom_DataOfBirth.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class KycView extends StatefulWidget {
  const KycView({super.key});

  @override
  State<KycView> createState() => _KycViewState();
}

class _KycViewState extends State<KycView> {
  KycController controller = KycController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).whenComplete(() {
      controller.getKYCDetails(context).whenComplete(() {
        if (AppStorage.getKYCStatus() == 0) {
          CustomAnimationToast.show(
            message: AppLocalizations.of(context)!.kycWaitingAdminApproval,
            context: context,
            type: ToastType.success,
          );
        }
      });
      if (AppStorage.getKYCStatus() == 3 || AppStorage.getKYCStatus() == 2) {
        controller.getCountryList(context);
      }
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    controller.clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KycController>(
      builder: (context, value, child) {
        controller = value;
        return Stack(
          children: [
            CustomTotalPageFormat(
              appBarTitle: AppLocalizations.of(context)!.verifyIdentity,
              showBackButton: true,
              child: Form(
                key: controller.kycFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppStorage.getLanguage() == 'cn'
                        ? Image.asset(AppBasicIcons.kycZhContent)
                        : Image.asset(AppBasicIcons.kycContent),

                    SizedBox(height: 15.sp),
                    CustomText(
                      label: AppLocalizations.of(
                        context,
                      )!.normalKycVerification,
                    ),
                    SizedBox(height: 15.sp),
                    CustomTextFieldWidget(
                      line: 1,
                      label: AppLocalizations.of(context)!.firstName,
                      labelTwo: "",
                      isDisabled:
                          AppStorage.getKYCStatus() != 2 &&
                          AppStorage.getKYCStatus() != 3,
                      controller: controller.firstNameController,
                      hintText: AppLocalizations.of(context)!.enterFirstName,
                      autoValidateMode: controller.firstNameAutoValidate,
                      onValidate: (val) =>
                          AppValidations().firstName(context, val ?? ""),
                      readOnly: false,
                      filled: true,
                    ),
                    SizedBox(height: 15.sp),
                    CustomTextFieldWidget(
                      line: 1,
                      label: AppLocalizations.of(context)!.lastName,
                      labelTwo: "",
                      controller: controller.lastNameController,
                      isDisabled:
                          AppStorage.getKYCStatus() != 2 &&
                          AppStorage.getKYCStatus() != 3,
                      hintText: AppLocalizations.of(context)!.enterLastName,
                      autoValidateMode: controller.lastNameAutoValidate,
                      onValidate: (val) =>
                          AppValidations().lastName(context, val ?? ""),
                      readOnly: false,
                      filled: true,
                    ),
                    SizedBox(height: 15.sp),
                    CustomTextFieldWidget(
                      isDisabled:
                          AppStorage.getKYCStatus() != 2 &&
                          AppStorage.getKYCStatus() != 3,
                      line: 1,
                      label: AppLocalizations.of(context)!.country,
                      controller: controller.countryController,
                      hintText: AppLocalizations.of(context)!.selectCountry,
                      readOnly: true,
                      filled: true,
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 15.sp),
                        child: SvgPicture.asset(
                          AppThemeIcons.arrowDown(context),
                          width: 10.sp,
                          height: 10.sp,
                        ),
                      ),
                      onTap: () async {
                        if (controller.countryList.isEmpty) {
                          await controller.getCountryList(context);
                        }
                        showCountryBottomSheet(context, controller);
                      },
                    ),
                    SizedBox(height: 15.sp),
                    CustomTextFieldWidget(
                      line: 1,
                      isDisabled:
                          AppStorage.getKYCStatus() != 2 &&
                          AppStorage.getKYCStatus() != 3,
                      label: AppLocalizations.of(context)!.documentType,
                      controller: controller.documentTypeController,
                      hintText: AppLocalizations.of(
                        context,
                      )!.selectDocumentType,
                      readOnly: true,
                      filled: true,
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 15.sp),
                        child: SvgPicture.asset(
                          AppThemeIcons.arrowDown(context),
                          width: 10.sp,
                          height: 10.sp,
                        ),
                      ),
                      onTap: () {
                        showDocumentTypeBottomSheet(context, controller);
                      },
                    ),
                    SizedBox(height: 15.sp),
                    CustomTextFieldWidget(
                      line: 1,
                      isDisabled:
                          AppStorage.getKYCStatus() != 2 &&
                          AppStorage.getKYCStatus() != 3,
                      label: AppLocalizations.of(context)!.documentNumber,
                      labelTwo: "",
                      controller: controller.documentNumberController,
                      hintText: AppLocalizations.of(
                        context,
                      )!.enterDocumentNumber,
                      autoValidateMode: controller.documentNumberAutoValidate,
                      onValidate: (val) =>
                          AppValidations().documentNumber(context, val ?? ""),
                      readOnly: false,
                      filled: true,
                    ),
                    SizedBox(height: 15.sp),
                    CustomDateSelect(
                      isDisabled:
                          AppStorage.getKYCStatus() != 2 &&
                          AppStorage.getKYCStatus() != 3,
                      label: AppLocalizations.of(context)!.expiryDate,
                      dateText: controller.expiryDateController,
                      hintText: AppLocalizations.of(
                        context,
                      )!.expiryDateHintText,
                      onTap: () async {
                        final DateTime today = DateTime.now();

                        // Initial date: today or previously selected expiry date
                        final DateTime initial =
                            controller.expiryDateController.text.isEmpty
                            ? today
                            : controller.selectedExpiryDate;

                        // Show date picker
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initial,
                          firstDate: today, // Expiry must be today or future
                          lastDate: DateTime(
                            today.year + 50,
                          ), // Reasonable future limit
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary:
                                      ThemeBackgroundColor.getBackgroundColor(
                                        context,
                                      ),
                                  surface:
                                      ThemeBackgroundColor.getBackgroundColor(
                                        context,
                                      ),
                                  onPrimary: ThemeTextColor.getTextColor(
                                    context,
                                  ),
                                  onSurface: ThemeTextOneColor.getTextOneColor(
                                    context,
                                  ),
                                ),
                                textTheme: TextTheme(
                                  titleMedium: TextStyle(
                                    color: ThemeTextColor.getTextColor(context),
                                    fontSize: 16.sp,
                                  ),
                                  bodyLarge: TextStyle(
                                    color: ThemeTextColor.getTextColor(context),
                                    fontSize: 14.sp,
                                  ),
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        ThemeTextColor.getTextColor(context),
                                    textStyle: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedDate != null) {
                          final formattedDate = DateFormat(
                            AppLocalizations.of(context)!.yyyyMmDd,
                          ).format(pickedDate);

                          setState(() {
                            controller.selectedExpiryDate = pickedDate;
                            controller.expiryDateController.text =
                                formattedDate;
                          });
                        }
                      },
                      autoValidateMode: controller.expiryDateAutoValidate,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.expiryDateRequired;
                        }

                        try {
                          final picked = DateFormat(
                            AppLocalizations.of(context)!.yyyyMmDd,
                          ).parseStrict(val.trim());

                          if (picked.isBefore(
                            DateTime.now().subtract(const Duration(days: 1)),
                          )) {
                            return AppLocalizations.of(
                              context,
                            )!.expiryDateMustBeFuture;
                          }
                        } catch (_) {
                          return AppLocalizations.of(
                            context,
                          )!.invalidDateFormat;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.sp),
                    CustomText(
                      label: AppLocalizations.of(context)!.idDocumentFront,
                      labelFontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                    SizedBox(height: 10.sp),
                    CustomGestureButton(
                      onTap: () async {
                        customImagePicker(
                          context: context,
                          showViewOption:
                              controller.docFrontImageURL.isNotEmpty,
                          imageURL: controller.docFrontImageURL,
                          showPickerOption: controller.docFrontImageURL.isEmpty,
                          onImagePicked: (image) {
                            setState(() {
                              controller.setDocFrontImage(image);
                            });
                          },
                        );

                        // }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 15.h,
                        padding: EdgeInsets.all(15.sp),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: ThemeTextFormFillColor.getTextFormFillColor(
                            context,
                          ),
                        ),
                        child: controller.docFrontImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12.sp),
                                child: Image.file(
                                  File(controller.docFrontImage!.path),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      controller.docFrontImageURL.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.sp),
                                              child: Image.network(
                                                controller.docFrontImageURL,
                                                height: 8.h,
                                              ),
                                            )
                                          : SvgPicture.asset(
                                              SupportDarkIcon.imageUpload,
                                              height: 4.5.h,
                                            ),
                                      SizedBox(width: 12.sp),
                                      AppStorage.getKYCStatus() == 2 ||
                                              AppStorage.getKYCStatus() == 3
                                          ? CustomText(
                                              label: AppLocalizations.of(
                                                context,
                                              )!.clickChooseFiles,
                                              fontColour:
                                                  ThemeTextOneColor.getTextOneColor(
                                                    context,
                                                  ),
                                              labelFontWeight: FontWeight.w400,
                                              fontSize: 14.5.sp,
                                            )
                                          : CustomText(
                                              label: AppLocalizations.of(
                                                context,
                                              )!.clickViewFiles,
                                              fontColour:
                                                  ThemeTextOneColor.getTextOneColor(
                                                    context,
                                                  ),
                                              labelFontWeight: FontWeight.w400,
                                              fontSize: 14.5.sp,
                                            ),
                                    ],
                                  ),

                                  SizedBox(height: 12.sp),
                                  AppStorage.getKYCStatus() == 2 ||
                                          AppStorage.getKYCStatus() == 3
                                      ? CustomText(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.maximumUploadMB,
                                          fontSize: 13.5.sp,
                                          fontColour: Colors.red,
                                          labelFontWeight: FontWeight.w500,
                                        )
                                      : SizedBox(),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 15.sp),
                    CustomText(
                      label: AppLocalizations.of(context)!.idDocumentBack,
                      labelFontWeight: FontWeight.w500,
                      fontSize: 15.sp,
                    ),
                    SizedBox(height: 10.sp),
                    CustomGestureButton(
                      onTap: () async {
                        customImagePicker(
                          context: context,
                          showViewOption: controller.docBackImageURL.isNotEmpty,
                          imageURL: controller.docBackImageURL,
                          showPickerOption: controller.docBackImageURL.isEmpty,
                          onImagePicked: (image) {
                            setState(() {
                              controller.setDocBackImage(image);
                            });
                          },
                        );

                        // }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 15.h,
                        padding: EdgeInsets.all(15.sp),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: ThemeTextFormFillColor.getTextFormFillColor(
                            context,
                          ),
                        ),
                        child: controller.docBackImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12.sp),
                                child: Image.file(
                                  File(controller.docBackImage!.path),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      controller.docBackImageURL.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.sp),
                                              child: Image.network(
                                                controller.docBackImageURL,
                                                height: 8.h,
                                              ),
                                            )
                                          : SvgPicture.asset(
                                              SupportDarkIcon.imageUpload,
                                              height: 4.5.h,
                                            ),
                                      SizedBox(width: 12.sp),
                                      AppStorage.getKYCStatus() == 2 ||
                                              AppStorage.getKYCStatus() == 3
                                          ? CustomText(
                                              label: AppLocalizations.of(
                                                context,
                                              )!.clickChooseFiles,
                                              fontColour:
                                                  ThemeTextOneColor.getTextOneColor(
                                                    context,
                                                  ),
                                              labelFontWeight: FontWeight.w400,
                                              fontSize: 14.5.sp,
                                            )
                                          : CustomText(
                                              label: AppLocalizations.of(
                                                context,
                                              )!.clickViewFiles,
                                              fontColour:
                                                  ThemeTextOneColor.getTextOneColor(
                                                    context,
                                                  ),
                                              labelFontWeight: FontWeight.w400,
                                              fontSize: 14.5.sp,
                                            ),
                                    ],
                                  ),

                                  SizedBox(height: 12.sp),
                                  AppStorage.getKYCStatus() == 2 ||
                                          AppStorage.getKYCStatus() == 3
                                      ? CustomText(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.maximumUploadMB,
                                          fontSize: 13.5.sp,
                                          fontColour: Colors.red,
                                          labelFontWeight: FontWeight.w500,
                                        )
                                      : SizedBox(),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 15.sp),
                    AppStorage.getKYCStatus() == 2 ||
                            AppStorage.getKYCStatus() == 3
                        ? CustomButton(
                            label: AppLocalizations.of(context)!.submit,
                            onTap: () {
                              if (controller.kycFormKey.currentState!
                                  .validate()) {
                                if (controller.docFrontImage == null ||
                                    controller.docBackImage == null) {
                                  CustomAnimationToast.show(
                                    message: AppLocalizations.of(
                                      context,
                                    )!.uploadRelevantDocumentsContinue,
                                    context: context,
                                    type: ToastType.error,
                                  );
                                } else {
                                  controller.doUpdateKYCDetails(context).then((
                                    value,
                                  ) {
                                    if (controller.isSuccess) {
                                      AppNavigator.pop();
                                    }
                                  });
                                }
                              }
                            },
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ),

            if (controller.isLoading)
              CustomLoader(isLoading: controller.isLoading),
          ],
        );
      },
    );
  }

  void showCountryBottomSheet(BuildContext context, KycController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: ThemeBackgroundColor.getBackgroundColor(context),
            border: Border.all(
              color: ThemeOutLineColor.getOutLineColor(context),
              width: 5.sp,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.sp),
              topRight: Radius.circular(20.sp),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 15.sp),

                /// 🔹 Header
                Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        label: AppLocalizations.of(context)!.selectCountry,
                        labelFontWeight: FontWeight.bold,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: SvgPicture.asset(
                          AppBasicIcons.close,
                          height: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.sp),
                Divider(
                  color: ThemeOutLineColor.getOutLineColor(context),
                  thickness: 6.sp,
                  height: 5.sp,
                ),

                /// 🔹 Country List
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          padding: EdgeInsets.only(
                            left: 13.sp,
                            right: 13.sp,
                            top: 13.sp,
                            bottom: 10.sp,
                          ),
                          itemCount: controller.countryList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (_, index) {
                            final country = controller.countryList[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                controller.selectCountry(country);
                                Navigator.pop(context);
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Flag
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      country.imageUrl,
                                      width: 36,
                                      height: 24,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.flag, size: 24),
                                    ),
                                  ),
                                  SizedBox(width: 20.sp),

                                  /// Country Name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          country.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          country.dialCode,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDocumentTypeBottomSheet(
    BuildContext context,
    KycController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: BoxDecoration(
            color: ThemeBackgroundColor.getBackgroundColor(context),
            border: Border.all(
              color: ThemeOutLineColor.getOutLineColor(context),
              width: 5.sp,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.sp),
              topRight: Radius.circular(20.sp),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 15.sp),

                /// 🔹 Header
                Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        label: AppLocalizations.of(context)!.selectDocumentType,
                        labelFontWeight: FontWeight.bold,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: SvgPicture.asset(
                          AppBasicIcons.close,
                          height: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.sp),
                Divider(
                  color: ThemeOutLineColor.getOutLineColor(context),
                  thickness: 6.sp,
                  height: 5.sp,
                ),

                /// ✅ THIS FIXES THE ERROR
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.documentTypeList(context).length,
                    itemBuilder: (context, i) {
                      final item = controller.documentTypeList(context)[i];

                      return CustomGestureButton(
                        onTap: () {
                          controller.setDocTypeDetails(
                            id: i,
                            type: item.toString(),
                          );
                          AppNavigator.pop();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(14.sp),
                          child: CustomText(
                            label: item.toString(),
                            labelFontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                            align: TextAlign.start,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
