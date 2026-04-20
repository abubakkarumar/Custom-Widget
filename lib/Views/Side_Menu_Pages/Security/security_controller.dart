import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/Utility/custom_tooltip.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_api.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../../../Utility/Basics/app_navigator.dart';

class SecurityController extends ChangeNotifier {
  final securityKey = GlobalKey<FormState>();

  bool isSuccess = false;
  bool isMPinVerified = false;

  bool isLoading = false;
  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  SecurityAPI provider = SecurityAPI();

  // Controllers

  List<SecurityActivityModel> securityActivityList = [];

  List<String> freezeAccountReasonsList(BuildContext context) {
    return [
      AppLocalizations.of(context)!.freezeAccountReasonOne,
      AppLocalizations.of(context)!.freezeAccountReasonTwo,
      AppLocalizations.of(context)!.freezeAccountReasonThree,
      AppLocalizations.of(context)!.freezeAccountReasonFour,
      AppLocalizations.of(context)!.freezeAccountReasonFive,
    ];
  }

  List<String> deleteAccountReasonsList(BuildContext context) {
    return [
      AppLocalizations.of(context)!.deleteAccountReasonOne,
      AppLocalizations.of(context)!.deleteAccountReasonTwo,
      AppLocalizations.of(context)!.deleteAccountReasonThree,
      AppLocalizations.of(context)!.deleteAccountReasonFour,
      AppLocalizations.of(context)!.deleteAccountReasonFive,
    ];
  }

  resetData() {
    googleOTPController.clear();
    currentMPinController.clear();
    newMPinController.clear();
    confirmMPinController.clear();
    antiPhishingCodeOtpCode.clear();
    antiPhishingCodeController.clear();
    recoveryKeyPhraseController.clear();
    deleteAccountOtp.clear();
    freezeAccountOtp.clear();
    notifyListeners();
  }

  int securityLevel = 0;
  String securityLevelStatus = "";

  setSecurityLevel(BuildContext context) {
    if (securityLevelStatus == AppLocalizations.of(context)!.low) {
      securityLevel = 0;
    } else if (securityLevelStatus == AppLocalizations.of(context)!.medium) {
      securityLevel = 1;
    } else {
      securityLevel = 2;
    }
    notifyListeners();
  }

  dynamic freezeAccountStatus = "";
  int kyStatus = -1;

  Future<void> getUserDetails(BuildContext context) async {
    await provider
        .getUserDetails()
        .then((value) {
          final parsed = json.decode(value.toString());

          if (parsed['success'] == true) {
            final data = parsed['data'] ?? {};

            antiPhishingCode = data['anti_phishing_code'] ?? "";
            securityLevelStatus = data['tfa_status'];
            freezeAccountStatus = data['freeze_status'];
            kyStatus = data['verified_kyc'] ?? -1;
            if(data["tfa"] != null && data["tfa"].toString().isNotEmpty){
              if(data['tfa'].toString().toLowerCase() == "email"){
                AppStorage.storeTwofaStatus(2);
              }else if(data['tfa'].toString().toLowerCase() == "google"){
                AppStorage.storeTwofaStatus(1);
              }else{
                AppStorage.storeTwofaStatus(0);
              }

            }else{
              AppStorage.storeTwofaStatus(0);
            }

            setSecurityLevel(context);
          } else {
            _showErrorToast(context, parsed['message'].toString());
          }
        })
        .catchError((e) {
          notifyListeners();
          setLoader(false);
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
    notifyListeners();
  }

  //////////////////////////////////////////////////////////////////////////////
  // -------------------------- GOOGLE 2FA ------------------------------------
  //////////////////////////////////////////////////////////////////////////////
  TextEditingController googleOTPController = TextEditingController();
  TextEditingController googleSecretKeyController = TextEditingController();

  String googleQRUrl = "";

  ///Get Google Secret Key
  Future<void> getGoogleSecretKey(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getGoogleSecretKey();

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        googleQRUrl = parsed['data']['url']?.toString() ?? "";
        googleSecretKeyController.text =
            parsed['data']['Secret']?.toString() ?? "";
        notifyListeners();
      } else {
        _showErrorToast(context, parsed['message']);
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

  ///Enable Google 2FA
  Future<void> doEnableGoogle2FA(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.doEnableGoogle({
        "otp": googleOTPController.text,
      });

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());

      if (parsed['success'] == true) {
        googleOTPController.clear();
        AppStorage.storeTwofaStatus(1);
        _showSuccessToast(context, parsed['message']);
      } else {
        googleOTPController.clear();
        AppStorage.storeTwofaStatus(0);
        _showParsedError(context, parsed, ['otp', 'error']);
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

  ///Disable Google 2FA
  Future<void> doDisableGoogle2Fa(BuildContext context, String otp) async {
    setLoader(true);

    try {
      final value = await provider.doDisableGoogle2Fa({"otp": otp});

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());

      if (parsed['success'] == true) {
        AppStorage.storeTwofaStatus(0);
        googleOTPController.clear();
        _showSuccessToast(context, parsed['message']);
        Navigator.pop(context);
      } else {
        _showParsedError(context, parsed, ['error']);
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

  //////////////////////////////////////////////////////////////////////////////
  // -------------------------- EMAIL 2FA -------------------------------------
  //////////////////////////////////////////////////////////////////////////////

  /// Get Email Verification Code
  Future<void> getEmailVerificationCode(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getEmail2FaCode(
        isEnable: AppStorage.getTwofaStatus() != 2,
      );

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        _showSuccessToast(context, parsed['message']);
      } else {
        _showParsedError(context, parsed, ['error']);
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

  /// Enable Email 2FA
  Future<void> doEnableEmail2FA({
    required BuildContext context,
    required String otp,
  }) async {
    setLoader(true);

    try {
      final value = await provider.doEnableEmail2fa({"otp": otp});

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());

      if (parsed['success'] == true) {
        AppStorage.storeTwofaStatus(2);
        _showSuccessToast(context, parsed['message']);
      } else {
        AppStorage.storeTwofaStatus(0);
        _showParsedError(context, parsed, ['error']);
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

  /// Disable Email 2FA
  Future<void> doDisableEmail2Fa(BuildContext context, String otp) async {
    setLoader(true);

    try {
      final value = await provider.doDisableEmail2Fa({"otp": otp});

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());

      if (parsed['success'] == true) {
        AppStorage.storeTwofaStatus(0);
        googleOTPController.clear();
        _showSuccessToast(context, parsed['message']);
      } else {
        _showParsedError(context, parsed, ['error']);
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

  //////////////////////////////////////////////////////////////////////////////
  // -------------------------- Change Password -------------------------------------
  //////////////////////////////////////////////////////////////////////////////

  final changePasswordKey = GlobalKey<FormState>();

  // Reset data
  resetChangePasswordData() {
    currentPassword.clear();
    newPassword.clear();
    confirmPassword.clear();
    changePasswordOtpCode.clear();
    notifyListeners();
  }

  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController changePasswordOtpCode = TextEditingController();
  FocusNode currentPasswordNode = FocusNode();
  FocusNode newPasswordNode = FocusNode();
  FocusNode confirmPasswordNode = FocusNode();

  bool isCurrentPassword = false;
  bool isNewPassword = false;
  bool isConfirmPassword = false;

  bool isPasswordTooltipOpen = false;

  void togglePasswordTooltip(BuildContext context, String message) {
    isPasswordTooltipOpen = !isPasswordTooltipOpen;

    if (isPasswordTooltipOpen) {
      showPasswordTooltip(context, message);
    } else {
      removePasswordTooltip();
    }

    notifyListeners();
  }

  isCurrentPasswordFunc(bool current) {
    isCurrentPassword = !current;
    notifyListeners();
  }

  isNewPasswordFunc() {
    isNewPassword = !isNewPassword;
    notifyListeners();
  }

  isConfirmPasswordFunc() {
    isConfirmPassword = !isConfirmPassword;
    notifyListeners();
  }

  ///Get Change Password OTP
  Future<void> getChangePasswordOtp(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getChangePasswordOtp();

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        AppNavigator.pop();
        _showSuccessToast(context, parsed['message']);
      } else {
        _showParsedError(context, parsed, ['error']);
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

  ///Change Password
  Future<void> doChangePassword(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.doChangePassword({
        "code": changePasswordOtpCode.text,
        "current_password": currentPassword.text,
        "new_password": newPassword.text,
        "confirm_password": confirmPassword.text,
      });

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        isSuccess = true;
        AppStorage.storeUserPassword(newPassword.text.toString());
        resetChangePasswordData();
        _showSuccessToast(context, parsed['message']);
      } else {
        isSuccess = false;
        _showParsedError(context, parsed, [
          'code',
          'current_password',
          'new_password',
          'confirm_password',
          'error',
        ]);
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

  //////////////////////////////////////////////////////////////////////////////
  // -------------------------- Recovery Key -------------------------------------
  //////////////////////////////////////////////////////////////////////////////

  List recoveryPhraseList = [];
  int recoveryKeyPosition = 0;
  bool isRecoveryCheckBox = false;

  void toggleTermsAccepted() {
    isRecoveryCheckBox = !isRecoveryCheckBox;
    notifyListeners();
  }

  TextEditingController recoveryKeyPhraseController = TextEditingController();

  ///Get Recovery Key Phrase
  Future<void> getRecoveryKeyPhrase(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getRecoveryKeyPhrase();

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        recoveryPhraseList = parsed['data']['recovery_code'];
        if (AppStorage.getRecoveryStatus() == 0) {
          recoveryKeyPosition = parsed['data']['position'];
        }
        notifyListeners();
        _showSuccessToast(context, parsed['message']);
      } else {
        _showParsedError(context, parsed, ['error']);
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

  ///Enable Recovery Key Phrase
  Future<void> doRecoveryKeyPhrase(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.enableRecoveryKeyPhrase({
        "code": recoveryKeyPhraseController.text,
        "position": recoveryKeyPosition.toString(),
        "accept": "1",
      });

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        AppStorage.storeRecoveryStatus(1);
        recoveryKeyPhraseController.clear();
        _showSuccessToast(context, parsed['message']);
        isSuccess = true;
      } else {
        isSuccess = false;
        _showParsedError(context, parsed, [
          'code',
          'position',
          'accept',
          'error',
        ]);
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

  //////////////////////////////////////////////////////////////////////////////
  // -------------------------- Freeze Account -------------------------------------
  //////////////////////////////////////////////////////////////////////////////

  bool isFreezeOrDeleteAccount = false;
  int checkBoxId = 0;
  int conditionId = 0;
  String reason = "";

  conditionIdFunc(int id) {
    conditionId = id;
    notifyListeners();
  }

  void checkBoxIdFunc(int id) {
    if (checkBoxId == id) {
      checkBoxId = -1; // unselect if same selected again
    } else {
      checkBoxId = id;
    }
    notifyListeners();
  }

  //////////////////////////////////////////////////////////////////////////////
  // -------------------------- Account Activity -------------------------------------
  //////////////////////////////////////////////////////////////////////////////
  List<LoginActivityModel> accountActivityList = [];

  Future<void> getLoginActivity(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getLoginActivity();
      final parsed = json.decode(value.toString());
      setLoader(false);
      if (parsed["success"] == true) {
        accountActivityList.clear();
        if (parsed['data'].toString() != "[]") {
          for (var data in parsed['data']) {
            accountActivityList.add(
              LoginActivityModel(
                ip: data['logged_in_location'].toString(),
                type: data['logged_in_os'].toString(),
                browser: data['logged_in_browser'].toString(),
                date: data['created_at'].toString(),
                device: data['logged_in_device'].toString(),
              ),
            );
          }
        }
        notifyListeners();
      } else {
        if (!context.mounted) return;
        _showParsedError(context, parsed, ["error"]);
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

  //////////////////////////////////////////////////////////////////////////////
  // -------------------------- Anti-Phishing Code -------------------------------------
  //////////////////////////////////////////////////////////////////////////////
  String antiPhishingCode = "";
  bool isAntiPhishingCode = false;
  final antiPhishingCodeKey = GlobalKey<FormState>();

  isAntiPhishingCodeFunc(bool isToggle) {
    isAntiPhishingCode = !isToggle;
    notifyListeners();
  }

  TextEditingController antiPhishingCodeController = TextEditingController();
  TextEditingController antiPhishingCodeOtpCode = TextEditingController();

  Future<void> getAntiPhishingCodeOtp(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getAntiPhishingCodeOtp();

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        // AppNavigator.pop();
        notifyListeners();
        _showSuccessToast(context, parsed['message']);
      } else {
        _showParsedError(context, parsed, ['error']);
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

  Future<void> enableUpdateAntiPhishingCode(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.enableUpdateAntiPhishingCode(
        data: {
          "anti_phishing_code": antiPhishingCodeController.text,
          "otp": antiPhishingCodeOtpCode.text,
        },
        isEnable: AppStorage.getAntiPhishingCodeStatus() == 0,
      );

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        isSuccess = true;
        antiPhishingCodeController.clear();
        antiPhishingCodeOtpCode.clear();
        getUserDetails(context);
        AppStorage.storeAntiPhishingCodeStatus(1);
        _showSuccessToast(context, parsed['message']);
      } else {
        AppStorage.storeAntiPhishingCodeStatus(0);

        isSuccess = false;
        _showParsedError(context, parsed, ['anti_phishing_code', 'error']);
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

  //////////////////////////////////////////////////////////////////////////////
  // -------------------------- Delete Account -------------------------------------
  //////////////////////////////////////////////////////////////////////////////

  TextEditingController deleteAccountOtp = TextEditingController();

  Future<void> getDeleteOtp(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getDeleteOtp();

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        AppNavigator.pop();
        notifyListeners();
        _showSuccessToast(context, parsed['message']);
      } else {
        _showParsedError(context, parsed, ['error']);
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

  Future<void> doDeleteAccount(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.doDeleteAccount({
        "email": AppStorage.getUserEmail(),
        "code": deleteAccountOtp.text,
      });

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        isSuccess = true;
        resetData();
        _showSuccessToast(context, parsed['message']);
      } else {
        isSuccess = false;
        _showParsedError(context, parsed, ['email', 'code', 'error']);
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

  //////////////////////////////////////////////////////////////////////////////
  // -------------------------- Freeze Account -------------------------------------
  //////////////////////////////////////////////////////////////////////////////

  TextEditingController freezeAccountOtp = TextEditingController();

  Future<void> sendOtpFreezeAccount(BuildContext context, String status) async {
    setLoader(true);

    try {
      final value = await provider.sendOtpFreezeAccount({"action": status});

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        isSuccess = true;
        resetData();
        _showSuccessToast(context, parsed['message']);
      } else {
        isSuccess = false;
        _showParsedError(context, parsed, ['action', 'error']);
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

  Future<void> confirmFreezeAccount(BuildContext context, String status) async {
    setLoader(true);

    try {
      final value = await provider.confirmFreezeAccount({
        "action": status,
        "otp": freezeAccountOtp.text,
      });

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        isSuccess = true;
        resetData();
        _showSuccessToast(context, parsed['message']);
      } else {
        resetData();
        isSuccess = false;
        _showParsedError(context, parsed, ['action', 'otp', 'error']);
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

  //////////////////////////////////////////////////////////////////////////////
  // -------------------------- MPIN -------------------------------------
  //////////////////////////////////////////////////////////////////////////////

  TextEditingController currentMPinController = TextEditingController();
  TextEditingController newMPinController = TextEditingController();
  TextEditingController confirmMPinController = TextEditingController();

  final mPinKey = GlobalKey<FormState>();

  bool isCurrentMPIN = false;
  bool isNewMPin = false;
  bool isConfirmMPIN = false;

  Future<void> createMPin(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.createMPin({
        "new_mpin": newMPinController.text,
        "confirm_mpin": confirmMPinController.text,
      });

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        isSuccess = true;
        isMPinVerified = true;
        AppStorage.storeMPIN(newMPinController.text);
        AppStorage.storeMPINStatus(1);
        resetData();
        Future.delayed(const Duration(seconds: 3), () {
          isMPinVerified = false;
        });
        //_showSuccessToast(context, parsed['message']);
      } else {
        isSuccess = false;
        resetData();
        _showParsedError(context, parsed, [
          'new_mpin',
          'confirm_mpin',
          'error',
        ]);
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

  Future<void> updateMPin(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.updateMPin({
        "old_mpin": currentMPinController.text,
        "new_mpin": newMPinController.text,
        "confirm_mpin": confirmMPinController.text,
      });

      if (!context.mounted) return;
      setLoader(false);

      final parsed = json.decode(value.toString());
      if (parsed['success'] == true) {
        isSuccess = true;
        resetData();
        _showSuccessToast(context, parsed['message']);
      } else {
        isSuccess = false;
        resetData();
        _showParsedError(context, parsed, [
          'old_mpin',
          'new_mpin',
          'confirm_mpin',
          'error',
        ]);
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

  //////////////////////////////////////////////////////////////////////////////
  // -------------------------- Helper Functions ------------------------------
  //////////////////////////////////////////////////////////////////////////////

  void _showSuccessToast(BuildContext context, String message) {
    CustomAnimationToast.show(
      context: context,
      message: message,
      type: ToastType.success,
    );
  }

  void _showErrorToast(BuildContext context, String message) {
    CustomAnimationToast.show(
      context: context,
      message: message,
      type: ToastType.error,
    );
  }

  void _showParsedError(
    BuildContext context,
    dynamic parsed,
    List<String> keys,
  ) {
    String errorMessage = "";
    for (var key in keys) {
      if (parsed['data'].toString().contains(key)) {
        errorMessage += parsed['data'][key]
            .toString()
            .replaceAll('null', '')
            .replaceAll('[', '')
            .replaceAll(']', '');
      }
    }
    if (errorMessage.isNotEmpty) {
      _showErrorToast(context, errorMessage);
    }
  }
}

class LoginActivityModel {
  final String? ip, device, type, browser, date;
  LoginActivityModel({
    this.ip,
    this.device,
    this.type,
    this.browser,
    this.date,
  });
}

class SecurityActivityModel {
  final String? ip, type, browser, os;
  SecurityActivityModel({this.ip, this.type, this.browser, this.os});
}
