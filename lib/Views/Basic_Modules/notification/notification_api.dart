// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class NotificationApi {
  AppServices services = AppServices();

  Future<Response> notificationsDetails() async {
    try {
      Response response = await services.request(
        ApiEndpoints.notificationsDetails,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> clearNotificationDetails() async {
    try {
      Response response = await services.request(
        ApiEndpoints.clearNotificationsDetails,
        method: "post",
      );
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


  Future<Response> clearDetails(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.clearDetails,
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

}
