import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class SavingsAPI {
  AppServices services = AppServices();

  /// Saving get Stake Products
  Future<Response> getStakeProducts() async {
    try {
      Response response = await services.request(
        ApiEndpoints.getStakeProducts,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// stake preview Calculation
  Future<Response> stakePreview(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.stakePreview,
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  /// Submit save Stake
  Future<Response> saveStakeSubmit(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.saveStakeSubmit,
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// stake History
  Future<Response> stakeHistory() async {
    try {
      Response response = await services.request(
        ApiEndpoints.stakeHistory,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Cancel Stake
  Future<Response> cancelStakeSubmit(Map data) async {
    try {
      Response response = await services.request(
        "cancel_plan",
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

}
