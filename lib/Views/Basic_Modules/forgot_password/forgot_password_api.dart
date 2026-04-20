// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class ForgotPasswordAPI {
  AppServices services = AppServices();

  // Forgot-password API
  ///This function is used to Forgot-password a user in Map format method
  Future<Response> doForgotPassword({required String email}) async {
    try {
      var body = {'email': email};

      Response response = await services.request(
        ApiEndpoints.forgetPassword,
        body: body,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // Reset Forgot-password Step Two API
  ///This function is used to Forgot-password a user in Map format method
  Future<Response> doForgotPasswordStepTwo(Map data) async {
    try {
      final response = await services.request(
        ApiEndpoints.resetPassword,
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Resend Email Verification Code
  Future<Response> doResendCode() async {
    try {
      var body = {};
      Response response = await services.request(
        ApiEndpoints.resendOtp,
        body: body,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
