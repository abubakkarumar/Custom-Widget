import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class SpotTradeApi {
  AppServices api = AppServices();

  ///Trade pair List
  Future<Response> getTradePairs() async {
    try {
      Response response = await api.request(
        ApiEndpoints.TRADE_PAIRS,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///Spot Order History
  Future<Response> getSpotOrderHistory(FormData  data) async {
    try {
      Response response = await api.request(
        ApiEndpoints.SPOT_ORDER_HISTORY,
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///Post Limit Buy
  Future<Response> postLimitBuy(FormData data) async {
    try {
      Response response = await api.request(
        ApiEndpoints.LIMIT_BUY,
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///Get Total calculation from slider
  Future<Response> getTotalCalculationSlider(FormData data) async {
    try {
      Response response = await api.request(
        ApiEndpoints.GET_TOTAL_BALANCE_CALCULATION,
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///Cancel Spot Order

  Future<Response> cancelSpotOrder(FormData data) async {
    try {
      Response response = await api.request(
        ApiEndpoints.SPOT_CANCEL_ORDER,
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }


  Future<Response> orderBookDetails(FormData data) async {
    try {
      Response response = await api.request(
        "orderbook",
        method: "post",
        body: data,
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> addFav(FormData data) async {
    try {
      Response response = await api.request(
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
      Response response = await api.request(
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
      Response response = await api.request(
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
