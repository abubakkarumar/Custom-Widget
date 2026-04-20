import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class LoginAPI {
  AppServices services = AppServices();
  Future<Response> doLogin({
    required String email,
    required String password,
    required String deviceToken,
    required String deviceId,
  }) async {
    try {
      var body = {
        'username_email': email,
        'password': password,
        'device_id': deviceId,
        'device_token': deviceToken,
        'device_type': Platform.isAndroid ? "android" : "ios",
      };

      Response response = await services.request(
        ApiEndpoints.login,
        body: body,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      Logger(
        printer: PrettyPrinter(colors: true, noBoxingByDefault: true),
      ).e(e.toString());
      throw DioExceptions.fromDioError(e).toString();
    }
  }

  /// Email Verification Status
  Future<Response> getEmailVerificationStatus({required String email}) async {
    try {
      var body = {
        'email': email,
        'device_type': Platform.isAndroid ? "android" : "ios",
      };
      Response response = await services.request(
        ApiEndpoints.emailVerificationStatus,
        body: body,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Resend 2FA Verification Code
  Future<Response> doResendTwoFACode() async {
    try {
      Response response = await services.request(
        ApiEndpoints.resendOtp,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> doVerifyTwoFA({
    required String email,
    required String code,
    required int twoFaType,
  }) async {
    try {
      var body = twoFaType == 1
          ? {'otp': code}
          : {'username_email': email, 'code': code};
      Response response = await services.request(
        twoFaType == 1 ? 'verify-google-2fa' : 'email-2FAVerify-otp',
        body: body,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Biometric Login
  Future<Response> doBiometricLogin({
    required String email,
    required String privateKey,
    required String deviceToken,
    required String deviceId,
  }) async {
    try {
      var body = {
        'email': email,
        'private_key': privateKey,
        'biometric_type':Platform.isAndroid ? "finger" : "face",
        'device_id': deviceId,
        'device_token': deviceToken,
        'device_type':  Platform.isAndroid ? "android" : "ios",
      };

      Response response =
      await services.request(ApiEndpoints.loginWithBiometric, body: body, method: "post");
      return response;
    } on DioException catch (e) {
      Logger(printer: PrettyPrinter(colors: true, noBoxingByDefault: true))
          .e(e.toString());
      throw DioExceptions.fromDioError(e).toString();
    }
  }
}
