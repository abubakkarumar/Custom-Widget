import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class AffiliateAPI {
  AppServices services = AppServices();

  /// Submit Affiliate Details
  Future<Response> submitAffiliateDetails(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.submitAffiliateDetails,
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> getAffiliateDetails() async {
    try {
      final response = await services.request(
        ApiEndpoints.affiliateDetails,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> getAffiliateAgentDetails() async {
    try {
      final response = await services.request(
        ApiEndpoints.affiliateAgentDetails,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

}
