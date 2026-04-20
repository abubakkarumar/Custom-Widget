import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Views/Basic_Modules/segmentedToggle/login_register.dart';
import 'api_loggers.dart';
import 'local_data.dart';

class AppServices {
  // ======================
  // BASE CONFIG
  // ======================

  /// Demo
  // static const String baseURL =
  //     "https://new.demozab.com/zayro/zayro-api/public/api/";
  static const String baseURL = "https://myapi.zayro.io/api/";
  static const String pusherAppKey = "dd3da22d599683a979fe";
  static const String pusherCluster = "ap2";

  // /// Live
  // static const String baseURL = "https://myapi.affiliatex.com/api/";
  // static const String pusherAppKey = "8822746aea71164e36e4";
  // static const String pusherCluster = "ap2";

  /// To get image base from api base
  static String get baseURLForImage {
    const toRemove = "api/";
    final index = baseURL.lastIndexOf(toRemove);
    if (index != -1) {
      return baseURL.substring(0, index);
    }
    return baseURL;
  }

  // ======================
  // DIO INSTANCE
  // ======================
  bool isRedirecting = false;

  late Dio dio =
      Dio(
          BaseOptions(
            baseUrl: baseURL,
            validateStatus: (status) => status != null && status < 500,

            connectTimeout: const Duration(minutes: 1),
            receiveTimeout: const Duration(minutes: 1),
          ),
        )
        ..interceptors.add(ApiLogger()) // your custom logger
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              // attach token on every request
              final token = AppStorage.getToken();
              final lang = AppStorage.getLanguage();
              print("Service Lang $lang");
              // redirectToLogin();
              if (token != null && token.isNotEmpty) {
                options.headers["Authorization"] = "Bearer $token";
              }
              if (lang != null && lang.isNotEmpty) {
                options.headers["Accept-Language"] = lang;
              }
              handler.next(options);
            },
          ),
        );

  // ======================
  // GENERIC REQUEST METHOD
  // ======================
  Future<Response> request(
    String url, {
    dynamic body,
    String method = 'POST',
    Map<String, dynamic>? extraHeaders,
    // required BuildContext context
  }) async {
    try {
      if (kDebugMode) {
        final token = AppStorage.getToken();
        print("🔐 Auth token: $token");
        print("➡️  $method $url");
      }

      final response = await dio.request(
        url,
        data: body ?? '',
        options: Options(method: method, headers: extraHeaders),
      );

      // Log actual payload
      print("DIO RESPONSE ${response.statusCode} ${url} ${body.toString() ?? ''}");

      // Handle error responses so callers can read messages
      final status = response.statusCode ?? 0;
      if (status > 400) {
        print("DIO ERROR STATUS CODE $status");
        if (status == 401) {
          print("Status code kkk ");
          // Fluttertoast.showToast(
          //   msg: AppStorage.getLanguage() == 'cn'
          //       ? "会话已过期，请登录。"
          //       : "Session expired. Please login.",
          // );
          redirectToLogin();
          print("DIO ERROR STATUS CODE INSIDE uu $status");
        }
        // Throw a DioExceptions with backend message
        throw DioExceptions.fromDioError(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
          ),
        );
      }

      return response;
    } on DioException catch (e) {
      print("DIO ERRORRRRR ${e.response?.statusCode}");
      if (e.response?.statusCode == 401) {
        // Fluttertoast.showToast(
        //   msg: AppStorage.getLanguage() == 'cn'
        //       ? "会话已过期，请登录。"
        //       : "Session expired. Please login.",
        // );

        redirectToLogin();
      }
      HapticFeedback.heavyImpact();
      throw DioExceptions.fromDioError(e);
    }
  }

  void redirectToLogin() {
    print("redirext to login $isRedirecting");
    if (isRedirecting) return;
    isRedirecting = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("Goto login");
      AppNavigator.replaceAllWith(
        const SegmentedToggleView(appBarTitle: "Login"),
      );

      Future.delayed(const Duration(seconds: 1), () {
        isRedirecting = false;
      });
    });
  }
}

// =====================================================
// ERROR HANDLING
// =====================================================
class DioExceptions implements Exception {
  DioExceptions.fromDioError(DioException dioError) {
    print("DioExceptions.fromDioError ${dioError.type}");
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = AppStorage.getLanguage() == 'cn'
            ? "对 API 服务器的请求已取消"
            : "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        message = AppStorage.getLanguage() == 'cn'
            ? "与 API 服务器的连接超时"
            : "Connection timeout with API server";
        break;
      case DioExceptionType.connectionError:
        message = AppStorage.getLanguage() == 'cn'
            ? "由于网络连接问题，与 API 服务器的连接失败。"
            : "Connection to API server failed due to internet connection";
        break;
      case DioExceptionType.receiveTimeout:
        message = AppStorage.getLanguage() == 'cn'
            ? "与 API 服务器连接时收到超时信息"
            : "Receive timeout in connection with API server";
        break;
      case DioExceptionType.sendTimeout:
        message = AppStorage.getLanguage() == 'cn'
            ? "向 API 服务器发送超时信息"
            : "Send timeout in connection with API server";
        break;
      case DioExceptionType.badResponse:
        // server gave a response but with error status
        final statusCode = dioError.response?.statusCode;
        print("Bad Response $statusCode");
        final data = dioError.response?.data;
        print("Bad Response Data $statusCode");
        message = handleError(statusCode, data);
        print("Bad Response Data After $message");
        break;
      case DioExceptionType.unknown:
      default:
        // could be no internet, socket issue, etc.
        message = AppStorage.getLanguage() == 'cn'
            ? "出错了！请稍后再试。"
            : "Something went wrong! Please try again later.";
        break;
    }
  }

  late final String message;

  String handleError(int? statusCode, dynamic error) {
    print("Bad Response handleError $statusCode");
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        print("Bad Response Token expired.  $statusCode");
        return AppStorage.getLanguage() == 'cn'
            ? "会话已过期，请登录。"
            : 'Session expired. Please login.';
      case 403:
        return AppStorage.getLanguage() == 'cn' ? '禁忌' : 'Forbidden';
      case 404:
        // try to read message from API
        if (error is Map && error["message"] != null) {
          return error["message"].toString();
        }
        return AppStorage.getLanguage() == 'cn' ? '未找到' : 'Not found';
      case 500:
        return AppStorage.getLanguage() == 'cn'
            ? '内部服务器错误'
            : 'Internal server error';
      default:
        return AppStorage.getLanguage() == 'cn'
            ? '糟糕！出问题了'
            : 'Oops! Something went wrong';
    }
  }

  @override
  String toString() => message;
}
