import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'forgot_password_api.dart';
import 'forgot_password_secondstep.dart';

class ForgotPasswordController extends ChangeNotifier {
  final ForgotPasswordAPI _forgotPasswordAPI = ForgotPasswordAPI();

  /// Text Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  AutovalidateMode emailAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode codeAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode newPasswordAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode confirmPasswordAutoValidate = AutovalidateMode.disabled;

  enableAutoValidate() {
    emailAutoValidate = AutovalidateMode.onUserInteraction;
    codeAutoValidate = AutovalidateMode.onUserInteraction;
    newPasswordAutoValidate = AutovalidateMode.onUserInteraction;
    confirmPasswordAutoValidate = AutovalidateMode.onUserInteraction;
    notifyListeners();
  }

  diableAutoValidate() {
    emailAutoValidate = AutovalidateMode.disabled;
    codeAutoValidate = AutovalidateMode.disabled;
    newPasswordAutoValidate = AutovalidateMode.disabled;
    confirmPasswordAutoValidate = AutovalidateMode.disabled;
  }

  /// UI State
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isPasswordTooltipOpen = false;
  bool isConfirmPasswordTooltipOpen = false;
  bool isLoading = false;

  /// UI State Setters
  void toggleNewPasswordVisibility(bool current) {
    isNewPasswordVisible = !current;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility(bool current) {
    isConfirmPasswordVisible = !current;
    notifyListeners();
  }

  void setPasswordTooltipOpen(bool value) {
    isPasswordTooltipOpen = value;
    notifyListeners();
  }

  void setConfirmPasswordTooltipOpen(bool value) {
    isConfirmPasswordTooltipOpen = value;
    notifyListeners();
  }

  int pageIndex = 0;

  setPageIndex(int value) {
    pageIndex = value;
    notifyListeners();
  }

  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  /// Clear All Inputs
  void clearAllFields() {
    emailController.clear();
    codeController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
  }

  /// Step 1 - Request Password Reset
  Future<void> requestForgotPassword(BuildContext context) async {
    setLoader(true);

    try {
      final raw = await _forgotPasswordAPI.doForgotPassword(
        email: emailController.text.toString(),
      );

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(raw.toString());

      if (parsed['success'] == true) {
        AppToast.show(
          context: context,
          message: parsed['message'].toString(),
          type: ToastType.success,
        );
        AppNavigator.replaceWith(const ForgotPasswordTwo());
      } else {
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

  /// Step 2 - Reset Password
  Future<void> updateForgotPassword(BuildContext context) async {
    setLoader(true);

    try {
      final Map<String, dynamic> body = {
        "email": emailController.text.trim(),
        "code": codeController.text.trim(),
        "password": newPasswordController.text.trim(),
        "confirm_password": confirmPasswordController.text.trim(),
      };

      final raw = await _forgotPasswordAPI.doForgotPasswordStepTwo(body);

      if (!context.mounted) return;
      final parsed = json.decode(raw.toString());

      if (parsed['success'] == true) {
        clearAllFields();

        AppToast.show(
          context: context,
          message: parsed['message'].toString(),
          type: ToastType.success,
        );
        setLoader(false);
        AppNavigator.pop();
      } else {
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['email', 'code', 'password', 'confirm_password', 'error'],
        );
        setLoader(false);
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

  /// Step 3 - Resend Code
  Future<void> doResendCode(BuildContext context) async {
    setLoader(true);

    try {
      final raw = await _forgotPasswordAPI.doResendCode();

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(raw.toString());

      if (parsed['success'] == true) {
        clearAllFields();

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
    } catch (e) {
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
    notifyListeners();
  }
}
