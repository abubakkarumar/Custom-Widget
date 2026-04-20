// ignore_for_file: file_names, use_build_context_synchronously, depend_on_referenced_packages, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_DataOfBirth.dart';
import 'package:zayroexchange/Utility/custom_actionbar.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/Views/Root/side_menu_usage.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import 'profile_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  // controller will be replaced by the Provider value inside build
  ProfileController controller = ProfileController();

  /// Date of Birth format and initial value of dateOfBirth
  DateTime dateOfBirth = DateTime.now();
  var birth;

  final profileKey = GlobalKey<FormState>();

  DateFormat dateValue = DateFormat('yyyy-MM-dd');

  DateTime selectedDate = DateTime.now();
  final int minAge = 18;

  @override
  void initState() {
    birth = dateValue.format(dateOfBirth);
    Future.delayed(const Duration(seconds: 0), () {
      controller.getProfile(context);
      controller.diableAutoValidate();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.diableAutoValidate();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, value, child) {
        controller = value;
        return Scaffold(
          body: Stack(
            children: [
              CustomTotalPageFormat(
                appBarTitle: AppLocalizations.of(context)!.profile,
                showBackButton: true,
                child: Form(
                  key: profileKey,
                  child: Column(
                    children: [
                      ProfileHeaderExact(
                        name: controller.userName,
                        uid: controller.profileUid,
                        avatarAsset: controller.profileImageUrl,
                        verified: controller.isVerified,
                        controller:
                            controller, // keep as-is (your header expects it)
                        onEdit: () => _showImagePicker(context, controller),
                      ),

                      SizedBox(height: 2.h),

                      Container(
                        decoration: BoxDecoration(
                          color: ThemeTextFormFillColor.getTextFormFillColor(
                            context,
                          ),
                          borderRadius: BorderRadius.circular(15.sp),
                          border: Border.all(
                            color: ThemeOutLineColor.getOutLineColor(context),
                            width: 5.sp,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 15.sp,
                                right: 15.sp,
                                top: 15.sp,
                                bottom: 10.sp,
                              ),
                              child: CustomText(
                                label: AppLocalizations.of(
                                  context,
                                )!.yourProfileDetails,
                                fontColour: ThemeTextColor.getTextColor(
                                  context,
                                ),
                                labelFontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(
                              color: ThemeOutLineColor.getOutLineColor(context),
                              thickness: 6.sp,
                              height: 5.sp,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 15.sp,
                                right: 15.sp,
                                top: 15.sp,
                                bottom: 10.sp,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.username,
                                        fontSize: 14.sp,
                                        fontColour:
                                            ThemeTextOneColor.getTextOneColor(
                                              context,
                                            ),
                                        labelFontWeight: FontWeight.w700,
                                      ),
                                      CustomText(
                                        label: controller.userName,
                                        fontSize: 14.5.sp,
                                        labelFontWeight: FontWeight.bold,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.sp),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.emailAddress,
                                        fontSize: 14.5.sp,
                                        fontColour:
                                            ThemeTextOneColor.getTextOneColor(
                                              context,
                                            ),
                                        labelFontWeight: FontWeight.w700,
                                      ),
                                      CustomText(
                                        label: controller.userEmail,
                                        fontSize: 14.5.sp,
                                        labelFontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.sp),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.bio,
                                        fontSize: 14.5.sp,
                                        fontColour:
                                            ThemeTextOneColor.getTextOneColor(
                                              context,
                                            ),
                                        labelFontWeight: FontWeight.w700,
                                      ),
                                      CustomText(
                                        label: controller.userBio,
                                        fontSize: 14.5.sp,
                                        labelFontWeight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 15.sp),

                      CustomTextFieldWidget(
                        hintText: AppLocalizations.of(context)!.nickNameHint,
                        line: 1,
                        label: AppLocalizations.of(context)!.nickName,
                        controller: controller.nickNameController,
                        node: controller.nickNameFocusNode,
                        autoValidateMode: controller.nickNameAutoValidate,
                        onValidate: (val) =>
                            AppValidations().nickName(context, val ?? ""),
                        readOnly: false,
                      ),

                      SizedBox(height: 15.sp),

                      /// Date of Birth
                      CustomDateSelect(
                        label: AppLocalizations.of(context)!.birthDate,
                        dateText: controller.dateOfBirthController,
                        hintText: AppLocalizations.of(
                          context,
                        )!.birthDateHintText,
                        onTap: () async {
                          final DateTime today = DateTime.now();

                          // compute maximum allowed date so user must be at least `minAge` years old
                          final DateTime maxAllowedDate = DateTime(
                            today.year - minAge,
                            today.month,
                            today.day,
                          );

                          // initial date: either current selected or the maxAllowedDate (so the picker opens to a valid value)
                          final DateTime initial =
                              controller.dateOfBirthController.text.isEmpty
                              ? maxAllowedDate
                              : controller.selectedDate;

                          // show date picker with lastDate = maxAllowedDate to prevent picking an invalid (too recent) date
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: initial,
                            firstDate: DateTime(1900),
                            lastDate: maxAllowedDate,
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
                                    onSurface:
                                        ThemeTextOneColor.getTextOneColor(
                                          context,
                                        ),
                                  ),
                                  textTheme: TextTheme(
                                    titleMedium: TextStyle(
                                      color: ThemeTextColor.getTextColor(
                                        context,
                                      ),
                                      fontSize: 16.sp,
                                    ),
                                    bodyLarge: TextStyle(
                                      color: ThemeTextColor.getTextColor(
                                        context,
                                      ),
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

                          // Remove any toast usage — validation messages are handled by validator
                          if (pickedDate != null) {
                            // pickedDate will always be <= maxAllowedDate because of lastDate
                            final formattedDate = DateFormat(
                              'yyyy-MM-dd',
                            ).format(pickedDate);

                            setState(() {
                              controller.selectedDate = pickedDate;
                              controller.dateOfBirthController.text =
                                  formattedDate;
                            });
                          }

                          // validate immediately so error border/message appears (if any)
                          // If you want to show errors only on submit, remove this call.
                          profileKey.currentState?.validate();
                        },
                        autoValidateMode: controller.dateOfBirthAutoValidate,
                        // validator returns localized strings which will be shown by the field's error UI/border
                        validator: (val) {
                          // Only run validation when autovalidate is enabled
                          if (controller.bioValidation !=
                              AutovalidateMode.disabled) {
                            // required check
                            if (val == null || val.trim().isEmpty) {
                              return "Date of birth is required";
                            }

                            // Try parse and validate age
                            try {
                              final picked = DateFormat(
                                'yyyy-MM-dd',
                              ).parseStrict(val.trim());
                              final age = calculateAge(picked);
                              if (age < minAge) {
                                return "${AppLocalizations.of(context)!.minimumAge} $minAge ${AppLocalizations.of(context)!.year}";
                              }
                            } catch (_) {
                              return "Invalid date format";
                            }
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 15.sp),

                      /// Bio
                      CustomTextFieldWidget(
                        line: 5,
                        filled: true,
                        label: AppLocalizations.of(context)!.bio,
                        labelTwo: "",
                        controller: controller.bioController,
                        node: controller.bioFocusNode,
                        autoValidateMode: controller.bioAutoValidate,
                        hintText: AppLocalizations.of(context)!.bioHintText,
                        onChanged: (val) {
                          controller.bioValidation =
                              AutovalidateMode.onUserInteraction;
                        },
                        onValidate: (val) =>
                            AppValidations().bioRequired(context, val ?? ""),
                        readOnly: false,
                      ),
                      SizedBox(height: 20.sp),
                      controller.isLoading
                          ? const CustomProgressDialog()
                          : CustomButton(
                              label: AppLocalizations.of(context)!.submit,
                              onTap: () async {
                                controller.enableAutoValidate();
                                if (profileKey.currentState!.validate()) {
                                  controller.doProfile(context);
                                }
                              },
                            ),
                    ],
                  ),
                ),
              ),

              // Loader overlay when controller.isLoading is true
              if (controller.isLoading)
                CustomLoader(isLoading: controller.isLoading),
            ],
          ),
        );
      },
    );
  }

  void _showImagePicker(BuildContext context, ProfileController controller) {
    customActionAlertBox(
      context,
      AppLocalizations.of(context)!.selectAction,
      18.h,
      () async {
        AppNavigator.pop();
        final picker = ImagePicker();
        final image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 20,
        );
        if (image != null) {
          controller.setProfilePicture(image);
          controller.updateProfilePicture(context);
        }
      },
      () async {
        AppNavigator.pop();
        final picker = ImagePicker();
        final image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 20,
        );
        if (image != null) {
          controller.setProfilePicture(image);
          controller.updateProfilePicture(context);
        }
      },
      AppLocalizations.of(context)!.camera,
      AppLocalizations.of(context)!.gallery,
    );
  }

  /// This is the function to calculate the age
  int calculateAge(DateTime birthDate) {
    DateTime now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
