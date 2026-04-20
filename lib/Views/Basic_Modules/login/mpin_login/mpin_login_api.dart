import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class MPINLoginAPI {
  AppServices services = AppServices();

  Future<Response> doLoginMPin(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.loginWithMPIN,
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> getForgotMPinOtp(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.forgotMPIN,
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> doForgotMPin(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.updateForgotMPIN,
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
