import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class DepositApi {
  AppServices services = AppServices();

  /// User Details
  Future<Response> getCoinList() async {
    try {
      Response response = await services.request(
        'coin-list',
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  Future<Response> getDepositDetails(Map data) async {
    try {
      Response response = await services.request(
        'deposit-detail',
        method: "post",
        body: data
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}