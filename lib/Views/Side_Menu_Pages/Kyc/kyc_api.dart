import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class KycAPI {
  AppServices services = AppServices();

  Future<Response> getCountryList() async {
    try {
      Response response = await services.request('get-country', method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> getKYCDetails() async {
    try {
      Response response = await services.request(
        'get-kyc-detail',
        method: "get",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Update KYC Details
  Future<Response> doUpdateKYCDetails({required FormData formData}) async {
    try {
      Response response =
      await services.request('add-kyc-detail', body:  formData, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

}
