import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class SecurityAPI {
  AppServices services = AppServices();

  Future<Response> getUserDetails() async {
    try {
      Response response = await services.request(
        ApiEndpoints.getUserDetails,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Google Secret API
  Future<Response> getGoogleSecretKey() async {
    try {
      Response response = await services.request(
        ApiEndpoints.getGoogleSecretDetails,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///Google Enable
  Future<Response> doEnableGoogle(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.enableGoogleTwoFa,
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Disable 2FA
  Future<Response> doDisableGoogle2Fa(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.disableGoogleTwoFa,
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////////////
  /// enable send email 2fa API
  Future<Response> getEmail2FaCode({required bool isEnable}) async {
    try {
      Response response = await services.request(
        isEnable
            ? ApiEndpoints.getEmailCode
            : ApiEndpoints.getEmailCodeWhileDisable,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// enable_email2fa API
  Future<Response> doEnableEmail2fa(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.enableEmailTwoFa,
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// disable_email2fa API
  Future<Response> doDisableEmail2Fa(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.disableEmailTwoFa,
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///////////////////////////////////////////////////////////////////////////////

  /// Get Change Password OTP
  Future<Response> getChangePasswordOtp() async {
    try {
      Response response = await services.request(
        ApiEndpoints.getChangePasswordOtp,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// change password
  Future<Response> doChangePassword(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.changePassword,
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///////////////////////////////////////////////////////////////////////////////

  /// Generate Recovery Key Phrase
  Future<Response> getRecoveryKeyPhrase() async {
    try {
      Response response = await services.request(
        ApiEndpoints.getRecoveryKeyPhrase,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Enable Recovery Key Phrase
  Future<Response> enableRecoveryKeyPhrase(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.enableRecoveryKeyPhrase,
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///////////////////////////////////////////////////////////////////////////////

  /// Login Activity
  Future<Response> getLoginActivity() async {
    try {
      Response response = await services.request(
        ApiEndpoints.deviceManagement,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///////////////////////////////////////////////////////////////////////////////

  /// Get Anti Phishing Code OTP
  Future<Response> getAntiPhishingCodeOtp() async {
    try {
      Response response = await services.request(
        ApiEndpoints.getAntiPhishingCodeOtp,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///Enable Anti Phishing Code
  Future<Response> enableUpdateAntiPhishingCode({required Map data, required bool isEnable}) async {
    try {
      Response response = await services.request(
        isEnable ?  ApiEndpoints.enableAntiPhishingCode : ApiEndpoints.updateAntiPhishingCode,
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///////////////////////////////////////////////////////////////////////////////

  Future<Response> getDeleteOtp() async {
    try {
      Response response = await services.request(
        ApiEndpoints.getDeleteOtp,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> doDeleteAccount(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.doDeleteAccount,
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///////////////////////////////////////////////////////////////////////////////

  /// Freeze Account
  Future<Response> sendOtpFreezeAccount(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.freezeSendOtp,
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> confirmFreezeAccount(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.freezeConfirm,
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///////////////////////////////////////////////////////////////////////////////

  Future<Response> createMPin(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.createMPin,
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> updateMPin(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.updateMPin,
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
