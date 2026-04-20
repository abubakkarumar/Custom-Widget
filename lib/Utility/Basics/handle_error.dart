// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';

import 'local_data.dart';

handleError(DioError error) {
  //log(error.response.toString());
  print("DIO error Message ${error.message}");
  print("DIO error catch ${error.response?.statusCode}");

  if(error.response?.statusCode == 401){
    return AppStorage.getLanguage() == 'cn'
        ? "会话已过期，请登录。"
        : 'Session expired. Please login.';
  }
  if (error.message!.contains('SocketException')) {
    return 'Cannot connect to the internet. Please try again later.';
  }
  if (error.type == DioErrorType.receiveTimeout) {
    return 'Received timed out. Please retry again.';
  }
  if (error.type == DioErrorType.connectionTimeout) {
    return 'Connection timed out. Please retry again.';
  }
  if (error.type == DioErrorType.sendTimeout) {
    return 'Send timed out. Please retry again.';
  }
  if (error.response == null || error.response!.data is String) {
    return 'Response is null or blank.';
  }
  return 'Something went wrong. Please try again later.';
}
