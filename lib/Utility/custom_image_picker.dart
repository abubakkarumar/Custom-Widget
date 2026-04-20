import 'dart:io';
import 'dart:ui';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'Basics/app_navigator.dart';
import 'Colors/custom_theme_change.dart';
import 'Images/dark_image.dart';
import 'custom_alertbox.dart';
import 'custom_button.dart';
import 'custom_text.dart';

Future<void> customImagePicker({
  required BuildContext context,
  bool? showViewOption,
  bool? showPickerOption = true,
  String? imageURL,
  required Function(XFile image) onImagePicked,
  double maxSize = 12,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.all(16.sp),
        backgroundColor: Colors.transparent,
        content: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 100.w,
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: ThemeBackgroundColor.getBackgroundColor(context),
              border: Border.all(
                width: 5.sp,
                color: ThemeOutLineColor.getOutLineColor(context),
              ),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔹 Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      label: AppLocalizations.of(context)!.selectAction,
                      fontSize: 16.sp,
                      labelFontWeight: FontWeight.w600,
                    ),
                    GestureDetector(
                      onTap: () => AppNavigator.pop(),
                      child: SvgPicture.asset(
                        AppBasicIcons.close,
                        height: 22.sp,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.sp),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.sp),
                  child: DottedDivider(
                    color: ThemeTextOneColor.getTextOneColor(context),
                  ),
                ),
                SizedBox(height: 20.sp),

                /// 🔹 Description
                CustomText(
                  label: showPickerOption == false
                      ? AppLocalizations.of(context)!.tapBelowViewImage
                      : "${AppLocalizations.of(context)!.pleaseSelectUpload} "
                            "${showViewOption == true ? "${AppLocalizations.of(context)!.orView} " : ""}"
                            "${AppLocalizations.of(context)!.theImage}",
                  align: TextAlign.center,
                  fontSize: 15.sp,
                  labelFontWeight: FontWeight.w400,
                ),

                SizedBox(height: 25.sp),

                /// 🔹 Buttons Row
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12.sp,
                  runSpacing: 12.sp,
                  children: [
                    /// VIEW BUTTON
                    if (imageURL != null &&
                        (showViewOption == true || showPickerOption == false))
                      CustomButton(
                        width: 45.sp,
                        label: AppLocalizations.of(context)!.view,
                        onTap: () {
                          AppNavigator.pop();
                          if (Uri.tryParse(imageURL)?.hasAbsolutePath ??
                              false) {
                            Future.delayed(
                              const Duration(milliseconds: 150),
                              () {
                                showImageViewer(
                                  context,
                                  Image.network(imageURL).image,
                                  doubleTapZoomable: true,
                                  useSafeArea: true,
                                  swipeDismissible: true,
                                );
                              },
                            );
                          }
                        },
                      ),

                    /// CAMERA BUTTON
                    if (showPickerOption == true)
                      CustomButton(
                        width: 45.sp,
                        label: AppLocalizations.of(context)!.camera,
                        onTap: () async {
                          AppNavigator.pop();
                          await pickImage(
                            context,
                            ImageSource.camera,
                            onImagePicked,
                            maxSizeInMB: maxSize,
                          );
                        },
                      ),

                    /// GALLERY BUTTON
                    if (showPickerOption == true)
                      CustomButton(
                        width: 45.sp,
                        label: AppLocalizations.of(context)!.gallery,
                        onTap: () async {
                          AppNavigator.pop();
                          await pickImage(
                            context,
                            ImageSource.gallery,
                            onImagePicked,
                            maxSizeInMB: maxSize,
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> pickImage(
  BuildContext context,
  ImageSource source,
  Function(XFile image) onImagePicked, {
  double? maxSizeInMB,
}) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: source, imageQuality: 10);

  if (image == null) return;

  File file = File(image.path);

  // Check for file size
  if (maxSizeInMB != null) {
    final int bytes = await file.length();
    final double sizeInMB = bytes / (1024 * 1024);
    if (sizeInMB > maxSizeInMB) {
      CustomAnimationToast.show(
        message:
            "Image size exceeds the maximum allowed size of ${maxSizeInMB.toStringAsFixed(0)} MB.",
        context: context,
        type: ToastType.error,
      );
      return;
    }
  }

  // Check if valid image
  bool isValidImage = await isValidImageFile(file);
  if (!isValidImage) {
    CustomAnimationToast.show(
      message:
          "This file appears to be encrypted. Please select another image.",
      context: context,
      type: ToastType.error,
    );
    return;
  }

  onImagePicked(image);
}

Future<bool> isValidImageFile(File file) async {
  try {
    Uint8List bytes = await file.readAsBytes();

    List<String> allowedExtensions = [
      "jpg",
      "jpeg",
      "png",
      "gif",
      "bmp",
      "webp",
    ];

    String extension = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) return false;

    List<List<int>> imageSignatures = [
      [0xFF, 0xD8, 0xFF], // JPEG
      [0x89, 0x50, 0x4E, 0x47], // PNG
      [0x47, 0x49, 0x46, 0x38], // GIF
      [0x42, 0x4D], // BMP
      [0x52, 0x49, 0x46, 0x46], // WEBP
    ];

    bool isImage = imageSignatures.any(
      (signature) =>
          bytes.length >= signature.length &&
          List<int>.from(bytes.sublist(0, signature.length)).toString() ==
              signature.toString(),
    );

    if (!isImage) return false;

    await decodeImageFromList(bytes);

    return true;
  } catch (e) {
    return false;
  }
}
