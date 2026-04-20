import 'package:dio/dio.dart';

import '../../../../Utility/Basics/handle_error.dart';
import '../../../../Utility/Basics/services.dart';

class FutureTradeAPI {
  AppServices services = AppServices();

  /// Trade Pairs
  Future<Response> getTradePairs({required String derivativeType,}) async {
    try {
      var body = {
        "type" : derivativeType,
      };
      Response response = await services.request('future/tradepairs', body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Update Leverage
  Future<Response> doUpdateLeverage({required String leverage, required String tradePair, required String pairId}) async {
    try {
      var body = {
        'leverage':leverage,
        "symbol" : tradePair,
    'pair': pairId
      };
      Response response = await services.request('future/leverage', body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Update Margin
  Future<Response> doUpdateMargin({required String marginType}) async {
    try {
      var body = {
        "type" : marginType
      };
      Response response = await services.request('future/margin', body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Limit Order
  Future<Response> doLimitOrder(
      {required String tradePairId,
        required String price,
        required String amount,
        required String side,
        required String coinOne,
        required bool isTPSLChecked,
        required String takeProfit,
        required String stopLoss,
        required String tpTriggerBy,
        required String slTriggerBy,
      }) async {
    try {
      var body = {
        'pair': tradePairId,
        'price': price,
        'amount': amount,
        'type': side,
        'ordercurrency': coinOne,
        'tpslm': isTPSLChecked,
        'take_profit': takeProfit,
        'stop_loss': stopLoss,
        'tpTriggerBy': tpTriggerBy,
        'slTriggerBy': slTriggerBy,
      };
      Response response =
      await services.request("future/limit-trade", body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///  Market Order
  Future<Response> doMarketOrder(
      {required String tradePairId,
        required String amount,
        required String side,
        required String coinOne,
        required bool isTPSLChecked,
        required String takeProfit,
        required String stopLoss,
        required String tpTriggerBy,
        required String slTriggerBy,
      }) async {
    try {
      var body = {
        'pair': tradePairId,
        'amount': amount,
        'type': side,
        'ordercurrency': coinOne,
        'tpslm': isTPSLChecked,
        'take_profit': takeProfit,
        'stop_loss': stopLoss,
        'tpTriggerBy': tpTriggerBy,
        'slTriggerBy': slTriggerBy,
      };
      Response response =
      await services.request("future/market-trade", body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Get Future Histories
  Future<Response> getFutureHistories({required String pairId, String? startDate, String? endDate}) async {
    try {
      var body = {
        "pair" : pairId,
        "start": startDate,
        "end": endDate
      };
      print("paorrrr$body");
      Response response = await services.request('future/orderbook', body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///  Close Limit position
  Future<Response> doCloseLimitPosition(
      {
        required String positionId,
        required String tradePairId,
        required String price,
        required String amount,
        required String side,
      }) async {
    try {
      var body = {
        'pair': tradePairId,
        'price': price,
        'amount': amount,
        'position_id': positionId,
        'side': side,
      };
      Response response =
      await services.request("future/close-limit-position", body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///  Close Market Position
  Future<Response> doCloseMarketPosition(
      { required String positionId,
        required String tradePairId,
        required String amount,
        required String side,
      }) async {
    try {
      var body = {
        'pair': tradePairId,
        'amount': amount,
        'position_id': positionId,
        'side': side,
      };
      Response response =
      await services.request("future/close-market-position", body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  ///  Cancel Open order
  Future<Response> doCancelOpenOrder(
      { required String orderId,
      }) async {
    try {
      var body = {
        'order_id': orderId,
      };
      Response response =
      await services.request("future/cancel", body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  ///  Update TPSL
  Future<Response> doUpdateTPSL({
    required String tradePair,
    required String side,
    required String takeProfit,
    required String stopLoss,
    required String tpTriggerBy,
    required String slTriggerBy,

  }) async {
    try {
      var body = {
        'liquidity_symbol': tradePair,
        'tpsl_side': side.toLowerCase() == "sell" ? "Sell" : "Buy",
        'take_profit': takeProfit,
        'stop_loss': stopLoss,
        'tp_triggerby': tpTriggerBy,
        'sl_triggerby': slTriggerBy,
      };
      print("Update TPSL ${body}");
      Response response =
      await services.request("future/update-tpsl", body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}