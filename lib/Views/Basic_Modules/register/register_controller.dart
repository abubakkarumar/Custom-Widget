import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Views/Basic_Modules/register/register_api.dart';

class RegisterController with ChangeNotifier {
  // API provider
  final RegisterApi provider = RegisterApi();

  // Form and input controllers
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController referralIdController = TextEditingController();

  AutovalidateMode userNameAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode emailAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode passwordAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode confirmPasswordAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode referralIdAutoValidate = AutovalidateMode.disabled;

  enableAutoValidate() {
    userNameAutoValidate = AutovalidateMode.onUserInteraction;
    emailAutoValidate = AutovalidateMode.onUserInteraction;
    passwordAutoValidate = AutovalidateMode.onUserInteraction;
    confirmPasswordAutoValidate = AutovalidateMode.onUserInteraction;
    referralIdAutoValidate = AutovalidateMode.onUserInteraction;
    notifyListeners();
  }

  diableAutoValidate() {
    userNameAutoValidate = AutovalidateMode.disabled;
    emailAutoValidate = AutovalidateMode.disabled;
    passwordAutoValidate = AutovalidateMode.disabled;
    confirmPasswordAutoValidate = AutovalidateMode.disabled;
    referralIdAutoValidate = AutovalidateMode.disabled;
  }

  // UI / state flags
  bool isPassword = false;
  bool isConfirmPassword = false;

  bool isPassNotesOpen = false;
  bool isConfirmPassNotesOpen = false;

  bool isLoading = false;

  /// Toggle password visibility and notify listeners
  void isPasswordFunc() {
    isPassword = !isPassword;
    notifyListeners();
  }

  /// Toggle confirm password visibility and notify listeners
  void isConfirmPasswordFunc() {
    isConfirmPassword = !isConfirmPassword;
    notifyListeners();
  }

  bool isTermsAccepted = false;

  void toggleTermsAccepted() {
    isTermsAccepted = !isTermsAccepted;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  int successIndex = 0;

  void resetData() {
    userNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    // referralIdController.clear();
    isTermsAccepted = false;

    notifyListeners();
  }

  Future<void> doRegister(BuildContext context) async {
    setLoading(true);

    final Map<String, dynamic> requestData = {
      "username": userNameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "confirm_password": confirmPasswordController.text.trim(),
      "device_type": Platform.isAndroid ? "android" : "ios",
      "agreeTerms": isTermsAccepted,
      if(referralIdController.text.isNotEmpty)
      "sponser_referal_id": referralIdController.text
    };
    setLoading(false);
    try {
      final response = await provider.doRegister(requestData);
      final parsed = json.decode(response.toString());
      successIndex = 1;
      if (!context.mounted) return;

      if (parsed['success'] == true) {
        AppStorage.storeUserEmail(emailController.text.toString());
        resetData();
        CustomAnimationToast.show(
          context: context,
          message: parsed['message'].toString(),
          type: ToastType.success,
        );
      } else {
        successIndex = 2;
        await handleApiFailure(
          context: context,
          response: parsed,
          errorFields: [
            'email',
            'password',
            'name',
            'confirm_password',
            'device_type',
            'sponser_referal_id',
            'agreeTerms',
            'sponser_referal_id',
            'error',
            'username'
          ],
        );
      }
    } catch (e) {
      successIndex = 0;
      setLoading(false);

      if (context.mounted) {
        CustomAnimationToast.show(
          context: context,
          message: e.toString(),
          type: ToastType.error,
        );
      }
    }
  }

  // ---------------------------------------Common error handling for API failures ---------------------------------------
  Future<void> handleApiFailure({
    required BuildContext context,
    required Map<String, dynamic> response,
    List<String> errorFields = const ['error'],
  }) async {
    if (!context.mounted) return;

    String errorMessage = '';

    for (final field in errorFields) {
      final value = response['data']?[field];
      if (value != null && value.toString().isNotEmpty) {
        errorMessage +=
            '${value.toString().replaceAll('[', '').replaceAll(']', '')}\n';
      }
    }

    if (errorMessage.trim().isEmpty && response['message'] != null) {
      errorMessage = response['message'].toString();
    }

    CustomAnimationToast.show(
      context: context,
      message: errorMessage.trim(),
      type: ToastType.error,
    );
  }
}
