// ignore_for_file: deprecated_member_use

import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/handle_error.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';

class ProfileAPI {
  AppServices services = AppServices();

  // Profile API Function
  ///This function is used to update profile details in Map format method
  Future<Response> doUpdateProfileDetails(Map<String, dynamic> data) async {
    try {
      final response = await services.request(
        ApiEndpoints.updateProfile,
        body: data,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  ///This function is used to update profile image in FormData format method
  Future<Response> doUpdateProfileImage(dio.FormData formData) async {
    try {
      final response = await services.request(
        ApiEndpoints.updateProfileImage,
        body: formData,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // Get the Profile details API Function
  ///This function is used to get profile details in Map format method
  Future<Response> showProfileDetails() async {
    try {
      final response = await services.request(
        ApiEndpoints.getUserDetails,
        method: "post",
      );
      return response;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

}
