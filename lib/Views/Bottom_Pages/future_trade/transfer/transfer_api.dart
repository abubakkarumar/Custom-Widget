import 'package:dio/dio.dart';
import '../../../../Utility/Basics/handle_error.dart';
import '../../../../Utility/Basics/services.dart';

class TransferAPI {
  AppServices services = AppServices();

  /// Transfer
  Future<Response> doTransfer({required String amount, required String coin, required String fromWallet, required String toWallet}) async {
    try {
      var body = {
        'amount': amount,
        'coin_id': coin,
        'from_wallet': fromWallet,
        'to_wallet': toWallet,
      };
      Response response = await services.request('fund-transfer', body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
  /// Update Margin
  Future<Response> getWalletBalance({required String fromWallet, required String coin}) async {
    try {
      var body = {
        "from_wallet" : fromWallet,
        "coin_id": coin
      };
      Response response = await services.request('future/balance', body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }


}
