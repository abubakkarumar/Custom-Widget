import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class WithdrawApi {
  AppServices services = AppServices();

  /// User Details
  Future<Response> getCoinList() async {
    try {
      Response response = await services.request('coin-list', method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }


  Future<Response> getTransactionStatus() async {
    try {
      Response response = await services.request('transaction-setting-status', method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> getWithdrawDetails(Map data) async {
    try {
      Response response = await services.request(
        'withdraw-detail',
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> withDrawVerifyOtp(Map data) async {
    try {
      Response response = await services.request(
        'verify-withdraw',
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> withDrawConfirm(Map data) async {
    try {
      Response response = await services.request(
        'confirm-withdraw',
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
