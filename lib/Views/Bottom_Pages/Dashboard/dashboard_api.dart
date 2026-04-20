import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class DashboardAPI {
  AppServices services = AppServices();

  /// User Details
  Future<Response> getUserDetails() async {
    try {
      Response response = await services.request(
        'get-user-details',
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  /// User Details
  Future<Response> getCoinList() async {
    try {
      Response response = await services.request(
        'markets/overview',
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Trade Pair List
  Future<Response> getTradePairList() async {
    try {
      Response response = await services.request(
        'trade/pairs',
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  /// Trade Pair List
  Future<Response> getDashboardData() async {
    try {
      Response response = await services.request(
        'dashboard-details',
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

}
