// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class ReferralApi {
  AppServices services = AppServices();

  Future<Response> getReferalDetails() async {
    try {
      final response = await services.request(
        ApiEndpoints.referalDetails,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  Future<Response> getReferalHistory() async {
    try {
      final response = await services.request(
        ApiEndpoints.referalHistory,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
