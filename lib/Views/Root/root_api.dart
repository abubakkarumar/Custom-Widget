import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

import '../../Utility/Basics/handle_error.dart';

class RootAPI {
  AppServices services = AppServices();


  /// Enable Biometric Auth
  Future<Response> doEnableBiometricAuth(
      {required String publicKey,
        required String deviceId,
        required String authType}) async {
    try {
      var body = {
        'public_key': publicKey,
        'device_id': deviceId,
        'biometric_type': authType,
      };

      Response response = await services.request(ApiEndpoints.enableBiometric,
          body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  /// Disable Biometric Auth
  Future<Response> doDisableBiometricAuth(
      {required String privateKey,
        required String deviceId,
        required String authType}) async {
    try {
      var body = {
        'private_key': privateKey,
        'device_id': deviceId,
        'biometric_type': authType,
      };

      Response response = await services.request(ApiEndpoints.disableBiometric,
          body: body, method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }



  Future<Response> notificationCount() async {
    try {
      Response response = await services.request(
        ApiEndpoints.notificationCount,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

}