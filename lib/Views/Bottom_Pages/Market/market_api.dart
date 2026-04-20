import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class MarketApi {
  AppServices services = AppServices();

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

  Future<Response> addFav(FormData data) async {
    try {
      Response response = await services.request(
        "favorite-pairs/add",
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> removeFav(FormData data) async {
    try {
      Response response = await services.request(
        "favorite-pairs/remove",
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> getFavList(FormData data) async {
    try {
      Response response = await services.request(
        "favorite-pairs/list",
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
