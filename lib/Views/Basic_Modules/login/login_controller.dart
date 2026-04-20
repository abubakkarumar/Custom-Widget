// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:zayroexchange/Utility/Basics/app_secure_storage.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'login_api.dart';

class LoginController with ChangeNotifier {
  final LoginAPI provider = LoginAPI();

  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AutovalidateMode emailAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode passwordAutoValidate = AutovalidateMode.disabled;

  enableAutoValidate() {
    emailAutoValidate = AutovalidateMode.onUserInteraction;
    passwordAutoValidate = AutovalidateMode.onUserInteraction;
    notifyListeners();
  }

  diableAutoValidate() {
    emailAutoValidate = AutovalidateMode.disabled;
    passwordAutoValidate = AutovalidateMode.disabled;
  }

  // Local auth
  final LocalAuthentication auth = LocalAuthentication();

  // UI flags
  bool isPassword = false;
  bool isLoading = false;
  bool isSuccess = false;
  bool isRememberMe = false;

  // Status fields
  int emailVerifiedStatus = 0;
  int tabIndex = 0;
  int fingerAuthStatus = 0;
  int faceAuthStatus = 0;
  int fingerAuthVerificationStatus = 0;
  int faceAuthVerificationStatus = 0;

  // Toggle password visibility
  void isPasswordFunc() {
    isPassword = !isPassword;
    notifyListeners();
  }

  // Restore saved credentials
  void restoreCredentials() {
    if (AppStorage.getRememberMeStatus() == true) {
      emailController.text = AppStorage.getUserEmail() ?? "";
      passwordController.text = AppStorage.getUserPassword() ?? "";
      isRememberMe = AppStorage.getRememberMeStatus() ?? false;
    }
    notifyListeners();
  }

  // Toggle Remember Me
  void isRememberMeFunc() {
    isRememberMe = !isRememberMe;
    AppStorage.storeRememberMeStatus(isRememberMe);
    notifyListeners();
  }

  // Loader helper
  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // Reset data
  void resetData() {
    emailController.clear();
    passwordController.clear();
    fingerAuthVerificationStatus = 0;
    faceAuthVerificationStatus = 0;
    isRememberMe = false;
    notifyListeners();
  }

  // Device ID helper
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        return android.id;
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        return ios.identifierForVendor ?? const Uuid().v4();
      }
    } catch (e, st) {
      if (kDebugMode) print("getDeviceId error: $e\n$st");
    }

    return const Uuid().v4();
  }

  void _showError(BuildContext context, String message) {
    CustomAnimationToast.show(
      context: context,
      message: message,
      type: ToastType.error,
    );
  }

  Future<void> authenticateBiometric(BuildContext context) async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    if (!canCheckBiometrics || !isDeviceSupported) {
      _showError(
        context,
        "Please register ${Platform.isAndroid ? "Fingerprint" : "Face ID"} in Security settings.",
      );
      return;
    }

    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate using biometrics',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        isSuccess = true;
      } else {
        isSuccess = false;
      }
    } on PlatformException catch (e) {
      isSuccess = false;

      if (e.code == "NotAvailable" || e.code == "PasscodeNotSet") {
        _showError(
          context,
          "Biometrics are not enabled. Please enable it from your phone's system settings.",
        );
      } else if (e.code == "LockedOut" || e.code == "PermanentlyLockedOut") {
        _showError(
          context,
          "Too many attempts. Try again later or use device passcode.",
        );
      }
    }

    notifyListeners();
  }

  // Check email verification
  Future<void> getEmailVerificationStatus(BuildContext context) async {
    setLoader(true);
    print("Get Email Verification Status---->");
    await provider
        .getEmailVerificationStatus(email: emailController.text)
        .then((resp) {
          setLoader(false);

          final parsed = json.decode(resp.toString());

          if (parsed['success'] == true) {
            isSuccess = true;
            emailVerifiedStatus =
                parsed['data']['email_verify_status'].toString() == "1" ? 1 : 2;
          } else {
            isSuccess = false;
            emailVerifiedStatus = 0;
          }
        })
        .catchError((error) {
          isSuccess = false;
          setLoader(false);
          AppToast.show(
            context: context,
            message: error.toString(),
            type: ToastType.error,
          );
        });
    notifyListeners();
  }

  // Login handler
  Future<void> doLogin(BuildContext context) async {
    setLoader(true);
    final deviceId = await getDeviceId();
    AppStorage.storeDeviceID(deviceId);

    try {
      print("FCM_TOKEN ${AppStorage.getFCMToken()}");

      final resp = await provider.doLogin(
        email: emailController.text,
        password: passwordController.text,
        deviceToken: AppStorage.getFCMToken() ?? "dummy_fcm_token",
        deviceId: AppStorage.getDeviceID().toString(),
      );

      setLoader(false);

      final parsed = json.decode(resp.toString());

      if (parsed['success'] == true) {
        isSuccess = true;

        final data = parsed['data'];

        if ((AppStorage.getUserEmail() ?? "") != emailController.text) {
          AppStorage.storeBiometricStatus(0);
        }

        AppStorage.storeUserEmail(emailController.text);
        AppStorage.storeUserPassword(passwordController.text);
        AppStorage.storeRememberMeStatus(isRememberMe);

        AppStorage.storeToken(data['token'] ?? "");
        AppStorage.storeUserId(data['user_details']['id'].toString());

        AppStorage.storeUserName(data['user_details']['user_name']);
        AppStorage.storeProfileImage(data['user_details']['profile_image']);
        AppStorage.storeKYCStatus(data['user_details']['verified_kyc'] ?? 3);

        final tfa = data['user_details']['tfa'].toString();
        AppStorage.storeTwofaStatus(
          tfa == "google"
              ? 1
              : tfa == "email"
              ? 2
              : 0,
        );

        resetData();

        AppToast.show(
          context: context,
          message: parsed['message'].toString(),
          type: ToastType.success,
        );
      } else {
        isSuccess = false;
        AppStorage.storeUserEmail(emailController.text.toString());
        setLoader(false);
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: [
            'username_email',
            'password',
            'device_id',
            'device_token',
            'device_type',
            'error',
          ],
        );
      }
    } catch (e) {
      isSuccess = false;
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }

    notifyListeners();
  }

  // Resend TwoFA Code
  Future doResendEmailTwoFACode({required BuildContext context}) async {
    setLoader(true);

    try {
      final resp = await provider.doResendTwoFACode();

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(resp.toString());

      if (parsed['success'] == true) {
        AppToast.show(
          context: context,
          message: parsed['message'].toString(),
          type: ToastType.success,
        );
      } else {
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['data', 'error'],
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

  // Verify TwoFA
  Future doVerifyTwoFA({
    required BuildContext context,
    required String code,
  }) async {
    setLoader(true);

    try {
      final resp = await provider.doVerifyTwoFA(
        email: AppStorage.getUserEmail(),
        code: code,
        twoFaType: AppStorage.getTwofaStatus(),
      );

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(resp.toString());

      if (parsed['success'] == true) {
        isSuccess = true;
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
          errorKeys: ['email', 'code', 'error'],
        );
      }
    } catch (e) {
      setLoader(false);
      isSuccess = false;
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }

    notifyListeners();
  }

  Future<void> doBiometricLogin(BuildContext context) async {
    setLoader(true);
    final privateKey = await AppSecureStorage.getPrivateKey();
    print('🔐 Private Key: $privateKey');
    await provider
        .doBiometricLogin(
          email: AppStorage.getUserEmail(),
          privateKey: privateKey.toString(),
          deviceToken: AppStorage.getFCMToken() ?? "dummy_fcm_token",
          deviceId: AppStorage.getDeviceID(),
        )
        .then((value) {
          setLoader(false);

          final parsed = json.decode(value.toString());
          if (!context.mounted) return;
          if (parsed['success'] == true) {
            isSuccess = true;
            setLoader(false);
            var data = parsed['data'];
            AppStorage.storeToken(data['token'] ?? "");
            AppStorage.storeUserId(data['me']['id'].toString());
            AppStorage.storeRecoveryStatus(
              data['me']['recovery_code_status'] ?? 0,
            );
            AppStorage.storeUserName(data['me']['user_name'].toString());
            AppStorage.storeProfileImage(
              data['me']['profile_image'].toString(),
            );
            AppStorage.storeKYCStatus(data['me']['kyc_verified'] ?? 0);

            if (data['me']['tfa'].toString() == "google") {
              /// 1 - google
              AppStorage.storeTwofaStatus(1);
            } else if (data['me']['tfa'].toString() == "email") {
              /// 2 - Email
              AppStorage.storeTwofaStatus(2);
            } else {
              /// 0 - Null
              AppStorage.storeTwofaStatus(0);
            }
            resetData();
            AppToast.show(
              context: context,
              message: parsed['message'].toString(),
              type: ToastType.success,
            );
          } else {
            isSuccess = false;
            setLoader(false);
            AppToast.show(
              context: context,
              parsedResponse: parsed,
              errorKeys: [
                'email',
                'private_key',
                'device_id',
                'device_token',
                'device_type',
                'biometric_type',
                'error',
              ],
            );
          }
        })
        .catchError((e) {
          isSuccess = false;
          setLoader(false);
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
    notifyListeners();
  }
}
