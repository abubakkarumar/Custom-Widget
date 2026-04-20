// ignore_for_file: file_names, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:zayroexchange/Utility/Basics/app_secure_storage.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Affiliate/affiliate_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Dashboard/dashboard_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/History/history_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Market/market_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Saving/savings_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/wallet_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/future_trade_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_page.dart';
import 'package:zayroexchange/Views/Root/root_api.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Profile/profile_api.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/referral_view.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class RootController extends ChangeNotifier {
  RootController() {
    loadInitData();
  }

  RootAPI provider = RootAPI();
  // Bottom navigation index
  int tabIndex = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// USER VALUES
  String profileImageUrl = AppStorage.getProfileImage().toString();
  String userName = AppStorage.getUserName().toString();
  String userEmailId = AppStorage.getUserEmail().toString();
  String bio = AppStorage.getBio().toString();
  String nickName = "";
  String dob = "";
  String profileUid = "";
  String antiPhishingCode = "";
  bool isVerified = false;
  bool isLoading = false;
  bool isSuccess = false;
  bool isRepeatVertical = false;
  bool isNewSpot = true;

  final LocalAuthentication auth = LocalAuthentication();

  /// Initial Storage data load to refresh UI values
  void loadInitData() {
    userName = AppStorage.getUserName().toString();
    userEmailId = AppStorage.getUserEmail().toString();
    profileImageUrl = AppStorage.getProfileImage().toString();
    bio = AppStorage.getBio().toString();
    notifyListeners();
  }

  /// Bottom Screens navigation
  // List<Widget> screens = [
  //   const DashboardView(),
  //   const MarketView(),
  //   SpotTradePage(type: "root", isFromArena: false, isNew: true),
  //   const WalletView(),
  //   const HistoryView(),
  //
  //   FutureTradeView(),
  //   ReferralView(isSelectedFrom: false),
  //   AffiliateView(isSelectedFrom: false),
  //   SavingsView(),
  // ];

  setRotateRepeatVertical(bool value) {
    isRepeatVertical = value;
    notifyListeners();
  }
  Widget getScreen() {
    switch (_currentPageIndex) {
      case 0:
        return const DashboardView();
      case 1:
        return const MarketView();
      case 2:
        return SpotTradePage(
          type: "root",
          isFromArena: false,
          isNew: isNewSpot,
        );
      case 3:
        return const WalletView();
      case 4:
        return const HistoryView();
      case 5:
        return FutureTradeView();
      case 6:
        return ReferralView(isSelectedFrom: false);
      case 7:
        return AffiliateView(isSelectedFrom: false);
      case 8:
        return SavingsView();
      default:
        return const DashboardView();
    }
  }
  /// Bottom Navigation Titles
  List<String> screenNames(BuildContext context) {
    return [
      AppLocalizations.of(context)!.dashboard,
      AppLocalizations.of(context)!.market,
      AppLocalizations.of(context)!.buySell,
      AppLocalizations.of(context)!.wallet,
      AppLocalizations.of(context)!.history,
      AppLocalizations.of(context)!.perpetualTrade,
      AppLocalizations.of(context)!.referral,
      AppLocalizations.of(context)!.affiliate,
      AppLocalizations.of(context)!.saving,
    ];
  }

  /// Active bottom icons
  List<Widget> activeIcons = [
    SvgPicture.asset(AppBottomIcons.dashboardActive),
    SvgPicture.asset(AppBottomIcons.marketActive),
    SvgPicture.asset(AppBottomIcons.tradeActive),
    SvgPicture.asset(AppBottomIcons.walletActive),
    SvgPicture.asset(AppBottomIcons.historyActive),
  ];

  /// Inactive bottom icons
  List<Widget> getInactiveIcons(BuildContext context) {
    return [
      SvgPicture.asset(AppThemeIcons.dashboardBottom(context)),
      SvgPicture.asset(AppThemeIcons.marketBottom(context)),
      SvgPicture.asset(AppThemeIcons.tradeBottom(context)),
      SvgPicture.asset(AppThemeIcons.walletBottom(context)),
      SvgPicture.asset(AppThemeIcons.historyBottom(context)),
    ];
  }

  /// Change Bottom Navigation Page
  void changeTabIndex(int index) {
    tabIndex = index;
    _bottomNavIndex = index;
    _showCenterMenu = false;
    print("change Tab Index -->$index");
    setRotateRepeatVertical(false);

    print("change setRotateRepeatVertical -->$isRepeatVertical");

    switch (index) {
      case 0:
        handleTradeClick(false);
        _currentPageIndex = 0;
        break;
      case 1:
        handleTradeClick(false);
        _currentPageIndex = 1;
        break;
      case 3:
        handleTradeClick(false);
        _currentPageIndex = 3;
        break;
      case 4:
        handleTradeClick(false);
        _currentPageIndex = 4;
        break;
    }
    notifyListeners();
  }

  Locale locale = Locale('cn');
  String flag = "assets/basic_icons/china.svg";

  void setLocale(Locale value) {
    print('Set local  default  ${value.languageCode}');
    //AppStorage.saveLanguage(value.languageCode);
    locale = value;

    for (var element in languages) {
      if (locale.languageCode == element.lan) {
        AppStorage.storeLanguage(element.lan);
        flag = element.flag;
      }
    }
    notifyListeners();
  }

  resetLanguage() {
    print('Reset Language to default  ');
    AppStorage.storeLanguage('cn');
    locale = Locale('cn');
    for (var element in languages) {
      print("Value Language--------->${locale.languageCode} ${element.lan}");
      if (locale.languageCode == element.lan) {
        flag = element.flag;
      }
    }
    notifyListeners();
    // AppStorage.saveLanguage('en');
  }

  final List<LanguageOption> languages = [
    LanguageOption(
      code: "ENG",
      name: "English",
      flag: "assets/basic_icons/eng.svg",
      lan: "en",
    ),
    LanguageOption(
      code: "CHN",
      name: "Chinese",
      flag: "assets/basic_icons/china.svg",
      lan: "cn",
    ),
  ];

  // LanguageOption selectedLanguage = LanguageOption(
  //   code: "ENG",
  //   name: "English",
  //   flag: "assets/basic_icons/eng.svg",
  //   lan: "en",
  // );

  // -------------------- PROFILE API SECTION ---------------------------

  final ProfileAPI profileApi = ProfileAPI();
  XFile? profilePictureFile;

  void setProfilePicture(XFile file) {
    profilePictureFile = file;
    notifyListeners();
  }

  /// Loader state update
  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  bool hasNotification = true; // default
  void clearNotification() {
    hasNotification = false;
    notifyListeners();
  }

  /// Common Error Toast
  void _showError(BuildContext context, String message) {
    CustomAnimationToast.show(
      context: context,
      message: message,
      type: ToastType.error,
    );
  }

  void _showSuccessToast(BuildContext context, String message) {
    CustomAnimationToast.show(
      context: context,
      message: message,
      type: ToastType.success,
    );
  }

  Future<void> authenticateBiometric(BuildContext context) async {
    print("cbisbscuvbbvccbweocwe");
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    if (!canCheckBiometrics || !isDeviceSupported) {
      _showError(
        context,
        "Please register ${Platform.isAndroid ? "Fingerprint" : "Face ID"} in Security settings.",
      );

      return;
    }

    try {
      print("owbbfowibowufbwowufbfowubf");
      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate using biometrics',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        isSuccess = true;
      } else {
        isSuccess = false;
        // Optional: Add extra toast here if needed
      }
    } on PlatformException catch (e) {
      isSuccess = false;
      print("wcbibcfwibucwbuw $isSuccess");
      print("wcbibcfwibucwbuw ${e.toString()}");
      if (e.code == "NotAvailable" || e.code == "PasscodeNotSet") {
        _showError(
          context,
          AppLocalizations.of(context)!.biometricsNotAvailableMessage,
        );
      } else if (e.code == "LockedOut" || e.code == "PermanentlyLockedOut") {
        _showError(
          context,
          "Too many attempts. Try again later or use device passcode.",
        );
      }
    }

    notifyListeners();
  }

  /// Update Profile Picture API
  Future<void> updateProfilePicture(BuildContext context) async {
    if (profilePictureFile == null) return;

    setLoader(true);

    try {
      final formData = dio.FormData.fromMap({
        "profile_image": await dio.MultipartFile.fromFile(
          profilePictureFile!.path,
          filename: "profilePicture.png",
        ),
      });

      final response = await profileApi.doUpdateProfileImage(formData);
      final parsed = json.decode(response.toString());

      debugPrint("PROFILE UPDATE RESPONSE: $parsed");

      if (parsed['success'] == true) {
        profileImageUrl = parsed['data']['profile_image'] ?? "";
        AppStorage.storeProfileImage(profileImageUrl);
        notifyListeners();

        if (context.mounted) {
          CustomAnimationToast.show(
            context: context,
            message: parsed['message'].toString(),
            type: ToastType.success,
          );
        }
      } else {
        _showError(context, parsed['message'] ?? "Something went wrong");
      }
    } catch (e) {
      _showError(context, e.toString());
    } finally {
      setLoader(false);
    }
  }

  /// Get Profile Details API
  Future<void> getProfile(BuildContext context) async {
    setLoader(true);

    try {
      final response = await profileApi.showProfileDetails();
      setLoader(false);
      final parsed = json.decode(response.toString());

      debugPrint("PROFILE DETAILS RESPONSE: $parsed");

      if (parsed['success'] == true && parsed['data'] != null) {
        final data = parsed['data'];

        userName = data['name'].toString();
        nickName = data['nick_name'].toString();
        dob = data['dob'].toString();
        userEmailId = data['email'].toString();
        bio = data['bio'].toString();
        antiPhishingCode = data['anti_phishing_code'].toString();
        profileImageUrl = data['profile_image']?.toString() ?? "";

        AppStorage.storeUserName(userName);
        AppStorage.storeUserEmail(userEmailId);
        AppStorage.storeBio(bio);
        AppStorage.storeProfileImage(profileImageUrl);

        notifyListeners();
      } else {
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['email', 'error'],
        );
      }
    } catch (e) {
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  /// Enable Biometric Auth
  Future doEnableBiometricAuth(BuildContext context) async {
    setLoader(true);

    final publicKey = await AppSecureStorage.getPublicKey();

    print('🔐 Public Key: $publicKey');
    await provider
        .doEnableBiometricAuth(
          authType: Platform.isAndroid ? "finger" : "face",
          deviceId: AppStorage.getDeviceID(),
          publicKey: publicKey.toString(),
        )
        .then((value) {
          setLoader(false);

          final parsed = json.decode(value.toString());
          if (parsed['success'] == true) {
            _showSuccessToast(context, parsed['message'].toString());

            AppStorage.storeBiometricStatus(1);
          } else {
            AppStorage.storeBiometricStatus(0);

            var errorMessage = "";
            List<String> keyList = <String>[
              'public_key',
              'device_id',
              'biometric_type',
              'error',
            ];
            for (var key in keyList) {
              if (parsed['data'].toString().contains(key)) {
                errorMessage += parsed['data'][key]
                    .toString()
                    .replaceAll('null', '')
                    .replaceAll('[', '')
                    .replaceAll(']', '');
              }
            }
            if (errorMessage.isNotEmpty) {
              _showError(context, errorMessage);
            }
          }
        })
        .catchError((e) {
          setLoader(false);
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
    notifyListeners();
  }

  /// Disable Biometric Auth
  Future doDisableBiometricAuth(BuildContext context) async {
    setLoader(true);
    final privateKey = await AppSecureStorage.getPrivateKey();
    print('🔐 Private Key: $privateKey');
    await provider
        .doDisableBiometricAuth(
          authType: Platform.isAndroid ? "finger" : "face",
          deviceId: AppStorage.getDeviceID(),
          privateKey: privateKey.toString(),
        )
        .then((value) {
          setLoader(false);

          final parsed = json.decode(value.toString());
          if (parsed['success'] == true) {
            _showSuccessToast(context, parsed['message'].toString());

            AppStorage.storeBiometricStatus(0);
          } else {
            AppStorage.storeBiometricStatus(1);

            var errorMessage = "";
            List<String> keyList = <String>[
              'private_key',
              'device_id',
              'biometric_type',
              'error',
            ];
            for (var key in keyList) {
              if (parsed['data'].toString().contains(key)) {
                errorMessage += parsed['data'][key]
                    .toString()
                    .replaceAll('null', '')
                    .replaceAll('[', '')
                    .replaceAll(']', '');
              }
            }
            if (errorMessage.isNotEmpty) {
              _showError(context, errorMessage);
            }
          }
        })
        .catchError((e) {
          setLoader(false);
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
    notifyListeners();
  }

  ///New Changes
  int _bottomNavIndex = 0;
  int _selectedCenterIndex = 2; // Default to Spot
  int _currentPageIndex = 0;
  bool _showCenterMenu = false;
  bool isTradeMenuOpen = false;

  int get bottomNavIndex => _bottomNavIndex;
  int get selectedCenterIndex => _selectedCenterIndex;
  int get currentPageIndex => _currentPageIndex;
  bool get showCenterMenu => _showCenterMenu;

  handleTradeClick(bool val) {
    isTradeMenuOpen = val;
    notifyListeners();
  }

  void setCenterPage(int centerPageIndex, String type) {
    tabIndex = centerPageIndex;

    _selectedCenterIndex = centerPageIndex;
    _currentPageIndex = centerPageIndex;
    print("Selected Center Index: $centerPageIndex, Type: $type");
    if(centerPageIndex == 2 && type == "new"){
      isNewSpot = true;
    } else {
      isNewSpot = false;
    }
    isNewSpot = false;
    _bottomNavIndex = 2;
    _showCenterMenu = false;
    setRotateRepeatVertical(true);
    notifyListeners();
  }

  void openCenterPage() {
    if (_showCenterMenu) {
      _showCenterMenu = false;
    } else {
      _currentPageIndex = _selectedCenterIndex;
      _bottomNavIndex = 2;
    }
    notifyListeners();
  }

  void toggleCenterMenu() {
    _showCenterMenu = !_showCenterMenu;
    if (_showCenterMenu) {
      _bottomNavIndex = 2;
    }
    notifyListeners();
  }

  int notificationCountValue = 0;

  Future<void> notificationCount(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await provider.notificationCount();
      setLoader(false);
      final parsed = json.decode(response.toString());

      if (parsed["success"] == true) {
        /// ✅ FORCE INT SAFELY
        notificationCountValue = parsed["data"]?["totalUnread"];
        notifyListeners();
      } else {
        _showError(context, parsed);
      }
    } catch (e) {
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String flag;
  final String lan;

  LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
    required this.lan,
  });
}
