import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class WalletApi {
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

  Future<Response> getWalletDetails() async {
    try {
      Response response = await services.request(
        'wallet',
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  Future<Response> getFutureWalletDetails() async {
    try {
      Response response = await services.request(
        'future_wallet',
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}