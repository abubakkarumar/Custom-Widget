// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'email_verification_api.dart';

class EmailVerificationController extends ChangeNotifier {
  final VerificationTwoFaAPI provider = VerificationTwoFaAPI();

  /// UI State
  bool isLoading = false;

  /// OTP Text Controller
  final TextEditingController otpController = TextEditingController();

  bool isSuccess = false;

  /// Loader State Management
  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  /// Clear All OTP Inputs

  void clearAllInputs() {
    otpController.clear();
    notifyListeners();
  }

  Future doResendCode(BuildContext context) async {
    setLoader(true);
    await provider
        .doResendCode(email: AppStorage.getUserEmail())
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());

          if (parsed['success'] == true) {
            clearAllInputs();

            AppToast.show(
              context: context,
              message: parsed['message'].toString(),
              type: ToastType.success,
            );
          } else {
            AppToast.show(
              context: context,
              parsedResponse: parsed,
              errorKeys: ['email', 'error'],
            );
          }
        })
        .catchError((e) {
          setLoader(false);
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
    notifyListeners();
  }

  Future doEmailVerification(context) async {
    setLoader(true);

    await provider
        .doEmailVerification(
          email: AppStorage.getUserEmail(),
          code: otpController.text.toString(),
        )
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());
          isSuccess = parsed['success'];
          if (parsed['success'] == true) {
            AppToast.show(
              context: context,
              message: parsed['message'].toString(),
              type: ToastType.success,
            );
          } else {
            clearAllInputs();
            AppToast.show(
              context: context,
              parsedResponse: parsed,
              errorKeys: ['email', 'code', 'error'],
            );
          }
        })
        .catchError((e) {
          setLoader(false);
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
  }
}
