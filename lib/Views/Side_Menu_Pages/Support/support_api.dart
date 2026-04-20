import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class SupportAPI {
  AppServices services = AppServices();

  Future<Response> getSupportChatList() async {
    try {
      Response response = await services.request('ticket-list', method: "post");
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> getSupportChat({required String ticketId}) async {
    try {
      Response response = await services.request(
        'view-ticket/$ticketId',
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> doCreateSupportTicket({FormData? formData}) async {
    try {
      Response response = await services.request(
        ApiEndpoints.addTicket,
        body: formData,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response> doSendMessage(Map data) async {
    try {
      Response response = await services.request(
        ApiEndpoints.sendMessage,
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
