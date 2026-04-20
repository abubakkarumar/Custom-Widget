import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_image_picker.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Support/support_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class CreateTicketView extends StatefulWidget {
  const CreateTicketView({super.key});

  @override
  State<CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<CreateTicketView> {
  SupportController controller = SupportController();

  @override
  Widget build(BuildContext context) {
    return Consumer<SupportController>(
      builder: (context, value, _) {
        controller = value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Form(
              key: controller.supportFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  CustomTextFieldWidget(
                    label: AppLocalizations.of(context)!.title,
                    controller: controller.titleController,
                    readOnly: false,
                    onValidate: (val) =>
                        AppValidations().ticketTitle(context, val ?? ""),
                    hintText: AppLocalizations.of(context)!.enterYourTitle,
                  ),
                  SizedBox(height: 2.h),

                  /// Message
                  CustomTextFieldWidget(
                    label: AppLocalizations.of(context)!.message,
                    controller: controller.messageController,
                    readOnly: false,
                    line: 5,
                    onValidate: (val) =>
                        AppValidations().ticketMessage(context, val ?? ""),
                    hintText: AppLocalizations.of(context)!.enterYourMessage,
                  ),

                  SizedBox(height: 2.h),

                  /// Document Upload
                  CustomText(label: AppLocalizations.of(context)!.idDocument),
                  SizedBox(height: .5.h),
                  CustomGestureButton(
                    onTap: () async {
                      customImagePicker(
                        context: context,
                        onImagePicked: (image) {
                          setState(() {
                            controller.setTicketUploadImage(image);
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
                      child: controller.ticketUploadImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.sp),
                              child: Image.file(
                                File(controller.ticketUploadImage!.path),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      SupportDarkIcon.imageUpload,
                                      height: 4.5.h,
                                    ),
                                    SizedBox(width: 12.sp),
                                    CustomText(
                                      label:AppLocalizations.of(context)!.clickChooseFiles,
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
                                CustomText(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.maximumUploadMB,
                                  fontSize: 13.5.sp,
                                  fontColour: Colors.red,
                                  labelFontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: 3.h),

                  /// Submit
                  controller.isLoading
                      ? const CustomProgressDialog()
                      :
                  CustomButton(
                    label: AppLocalizations.of(context)!.submit,
                    onTap: () {
                      if (controller.supportFormKey.currentState!.validate()) {
                        controller.doCreateSupportTicket(context).whenComplete(
                          () async {
                            Navigator.pop(context);
                            if (controller.isSuccess) {
                              if (!context.mounted) return;
                              await controller.getSupportTickets(context);
                            }
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            if (controller.isLoading)
              CustomLoader(isLoading: controller.isLoading),
          ],
        );
      },
    );
  }
}
