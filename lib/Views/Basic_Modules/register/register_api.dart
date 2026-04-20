// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class RegisterApi {
  final AppServices services = AppServices();

  // Registers a new user with the provided [registerData].
  final Logger _logger = Logger(); // ✅ Added logger instance
  Future<Response> doRegister(Map<String, dynamic> loginData) async {
    try {
      _logger.i("Register Request → $loginData"); // ✅ Log request body

      final response = await services.request(
        ApiEndpoints.register,
        body: loginData,
        method: "post",
      );

      _logger.i("Register Response → ${response.data}"); // ✅ Log response

      return response;
    } on DioException catch (e) {
      _logger.e("Register Error → ${e.message}"); // ✅ Log error
      throw handleError(e);
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
}
