import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'mpin_login_api.dart';

class MPINLoginController extends ChangeNotifier {
  MPINLoginAPI provider = MPINLoginAPI();

  bool isLoading = false;
  bool isSuccess = false;

  final formKey = GlobalKey<FormState>();

  TextEditingController mPinController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController newMPinController = TextEditingController();
  TextEditingController confirmMPinController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  AutovalidateMode mPinAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode emailAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode newMPinAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode confirmMPinAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode otpAutoValidate = AutovalidateMode.disabled;

  enableAutoValidate() {
    mPinAutoValidate = AutovalidateMode.onUserInteraction;
    emailAutoValidate = AutovalidateMode.onUserInteraction;
    newMPinAutoValidate = AutovalidateMode.onUserInteraction;
    confirmMPinAutoValidate = AutovalidateMode.onUserInteraction;
    otpAutoValidate = AutovalidateMode.onUserInteraction;
    notifyListeners();
  }

  diableAutoValidate() {
    mPinAutoValidate = AutovalidateMode.disabled;
    emailAutoValidate = AutovalidateMode.disabled;
    newMPinAutoValidate = AutovalidateMode.disabled;
    confirmMPinAutoValidate = AutovalidateMode.disabled;
    otpAutoValidate = AutovalidateMode.disabled;
  }

  setLoader(bool val) {
    isLoading = val;
    notifyListeners();
  }

  resetData() {
    mPinController.clear();
    emailController.clear();
    newMPinController.clear();
    confirmMPinController.clear();
    otpController.clear();
    isLoading = false;
    notifyListeners();
  }

  Future<void> doLoginMPin(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.doLoginMPin({
        "email": AppStorage.getUserEmail().toString(),
        "device_type": Platform.isAndroid ? "android" : "ios",
        "device_id": AppStorage.getDeviceID().toString(),
        "device_token": AppStorage.getFCMToken() ?? "dummy_fcm_token",
        "mpin": mPinController.text,
      });

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        isSuccess = true;
        resetData();
        AppToast.show(
          context: context,
          message: parsed['message'].toString(),
          type: ToastType.success,
        );
      } else {
        isSuccess = false;
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: [
            'email',
            'mpin',
            'device_type',
            'device_id',
            'device_token',
            'error',
          ],
        );
      }
    } catch (e) {
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future<void> getForgotMPinOtp(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getForgotMPinOtp({
        "email": AppStorage.getUserEmail().toString(),
      });

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        isSuccess = true;
        resetData();
        AppToast.show(
          context: context,
          message: parsed['message'].toString(),
          type: ToastType.success,
        );
      } else {
        resetData();
        isSuccess = false;
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['email', 'error'],
        );
      }
    } catch (e) {
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future<void> updateForgotMPin(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.doForgotMPin({
        "email": AppStorage.getUserEmail().toString(),
        "otp": otpController.text,
        "new_mpin": newMPinController.text,
      });

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        isSuccess = true;
        resetData();
        AppToast.show(
          context: context,
          message: parsed['message'].toString(),
          type: ToastType.success,
        );
      } else {
        isSuccess = false;
        resetData();
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: [
            'email',
            'mpin',
            'device_type',
            'device_id',
            'device_token',
            'error',
          ],
        );
      }
    } catch (e) {
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }
}
