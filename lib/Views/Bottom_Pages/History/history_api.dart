import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class HistoryApi {
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

  Future<Response> getDepositHistory(Map data) async {
    try {
      Response response = await services.request(
        'deposit-history',
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> getWithdrawHistory(Map data) async {
    try {
      Response response = await services.request(
        'withdraw-history',
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> getTransferHistory(Map data) async {
    try {
      Response response = await services.request(
        'future/funds-transfer-history',
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> getOrderOpenHistory(Map data) async {
    try {
      Response response = await services.request(
        'order/history',
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> cancelOrderOpenHistory(Map data) async {
    try {
      Response response = await services.request(
        'order/cancel',
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Trade Pair List
  Future<Response> getTradePairList() async {
    try {
      Response response = await services.request('trade/pairs', method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> getFutureOpenOrdersHistory(Map data) async {
    try {
      Response response = await services.request(
        'future/openorders',
        method: "post",
        body: data,
      );

      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> getClosedOrdersHistory(Map data) async {
    try {
      Response response = await services.request(
        'future/closed_orders',
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> getPNLHistory(Map data) async {
    try {
      Response response = await services.request(
        'future/pnlhistories',
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
