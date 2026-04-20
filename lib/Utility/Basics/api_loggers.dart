// ignore_for_file: file_names, deprecated_member_use

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiLogger extends Interceptor {
  final int maxCharacters = 5000;

  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i("📤 REQUEST:");
    logger.i("🔗 URL: ${options.baseUrl}${options.path}");
    logger.i("📦 METHOD: ${options.method}");
    logger.i("🧾 HEADERS: ${options.headers}");
    logger.i("📝 DATA: ${options.data}");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.i("✅ RESPONSE (${response.statusCode}):");

    final responseData = response.data.toString();
    if (responseData.length > maxCharacters) {
      int chunks = (responseData.length / maxCharacters).ceil();
      for (int i = 0; i < chunks; i++) {
        int start = i * maxCharacters;
        int end = (i + 1) * maxCharacters;
        if (end > responseData.length) end = responseData.length;
        logger.i(responseData.substring(start, end));
      }
    } else {
      logger.i(responseData);
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e("❌ ERROR:");
    logger.e("🔗 URL: ${err.requestOptions.uri}");
    logger.e("📦 METHOD: ${err.requestOptions.method}");
    logger.e("🧾 HEADERS: ${err.requestOptions.headers}");
    logger.e("🧨 MESSAGE: ${err.message}");
    logger.e("🧨 ERROR: ${err.error}");
    logger.e("📄 RESPONSE: ${err.response?.data}");
    super.onError(err, handler);
  }
}
