// ignore_for_file: file_names, avoid_print

import 'package:get_storage/get_storage.dart';

class AppStorage {
  get({String? key}) {
    return GetStorage().read(key!);
  }

  save({String? key, dynamic value}) {
    GetStorage().write(key!, value);
  }

  /// Access Token
  static storeToken(String value) {
    return GetStorage().write("access_token", value);
  }

  static getToken() {
    return GetStorage().read("access_token");
  }

  static storeLanguage(String value) {
    return GetStorage().write("language", value);
  }

  static getLanguage() {
    return GetStorage().read("language");
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// FCM Token
  static storeFCMToken(String value) {
    return GetStorage().write("fcm_token", value);
  }

  static getFCMToken() {
    return GetStorage().read("fcm_token");
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// Remember Me Status
  static storeRememberMeStatus(bool value) {
    return GetStorage().write("remember_me_status", value);
  }

  static getRememberMeStatus() {
    return GetStorage().read("remember_me_status");
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// User Email
  static storeUserEmail(String value) {
    return GetStorage().write("user_email", value);
  }

  static getUserEmail() {
    return GetStorage().read("user_email");
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// User Password
  static getUserPassword() {
    return GetStorage().read("user_password");
  }

  static storeUserPassword(String value) {
    return GetStorage().write("user_password", value);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// User Nick Name
  static storeUserNickName(String value) {
    return GetStorage().write("nick_name", value);
  }

  static getUserNickName() {
    return GetStorage().read("nick_name");
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// User name
  static storeUserName(String value) {
    return GetStorage().write("username", value);
  }

  static getUserName() {
    return GetStorage().read("username");
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// User ID
  static getUserId() {
    return GetStorage().read("user_id");
  }

  static storeUserId(String value) {
    return GetStorage().write("user_id", value);
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// KYC Status
  static storeKYCStatus(int value) {
    /// 0 - Pending, 1 - Completed , 2 - Rejected , 3 - Null
    return GetStorage().write("kyc_status", value);
  }

  static getKYCStatus() {
    return GetStorage().read("kyc_status");
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// 2FA Status
  static storeTwofaStatus(int value) {
    /// 0 - null, 1 - google, 2 - Email
    return GetStorage().write("two_fa", value);
  }

  static getTwofaStatus() {
    return GetStorage().read("two_fa");
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  /// MPIN
  static storeMPIN(String value) {
    return GetStorage().write("mpin", value);
  }

  static getMPIN() {
    return GetStorage().read("mpin");
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////

  /// MPIN Status
  static storeMPINStatus(int value) {
    return GetStorage().write("mpin_status", value);
  }

  static getMPINStatus() {
    return GetStorage().read("mpin_status");
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// User Profile Image
  static storeProfileImage(String value) {
    return GetStorage().write("profile_image", value);
  }

  static getProfileImage() {
    return GetStorage().read("profile_image");
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// Recovery Key Status
  static storeRecoveryStatus(int value) {
    return GetStorage().write("recovery", value);
  }

  static getRecoveryStatus() {
    return GetStorage().read("recovery");
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// Anti-phishing code Status
  static storeAntiPhishingCodeStatus(int value) {
    return GetStorage().write("anti_phishing_status", value);
  }

  static getAntiPhishingCodeStatus() {
    return GetStorage().read("anti_phishing_status");
  }


  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// Biometric Status
  static storeBiometricStatus(int value) {
    /// 0 - none, 1 - finger/face
    return GetStorage().write("biometric", value);
  }

  static getBiometricStatus() {
    return GetStorage().read("biometric");
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// Device ID
  static storeDeviceID(String value) {
    return GetStorage().write("device_id", value);
  }

  static getDeviceID() {
    return GetStorage().read("device_id");
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////
  /// Bio
  static storeBio(String value) {
    return GetStorage().write("bio", value);
  }

  static getBio() {
    return GetStorage().read("bio");
  }
////////////////////////////////////////////////////////////////////////////////////////////////////
  /// Stats Level
  static storeStatusLevel(String value) {
    return GetStorage().write("tfa_status", value);
  }

  static getStatusLevel() {
    return GetStorage().read("tfa_status");
  }

}
