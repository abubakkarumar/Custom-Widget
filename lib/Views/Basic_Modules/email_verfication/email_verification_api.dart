// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

/// API class to handle email & Google 2FA verification requests
class VerificationTwoFaAPI {
  final AppServices services = AppServices();

  /// Email Verification
  Future<Response> doEmailVerification({
    required String email,
    required String code,
  }) async {
    try {
      var body = {'username_email': email, 'code': code};
      Response response = await services.request(
        ApiEndpoints.verifyEmail,
        body: body,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Resend Email Verification Code
  Future<Response> doResendCode({required String email}) async {
    try {
      var body = {
        'username_email': email,
        'device_type': Platform.isAndroid ? 'android' : 'ios',
      };
      Response response = await services.request(
        ApiEndpoints.resentVerifyEmail,
        body: body,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
