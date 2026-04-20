import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'affiliate_api.dart';

class AffiliateController extends ChangeNotifier {
  // ===========================================================================
  // TEXT CONTROLLERS
  // ===========================================================================
  final TextEditingController nickNameController = TextEditingController();

  final TextEditingController languageController = TextEditingController(
    text: 'Select',
  );

  final TextEditingController countryController = TextEditingController(
    text: 'Select',
  );

  final TextEditingController affiliateTypeController = TextEditingController(
    text: 'Select',
  );

  final TextEditingController contactInfoController = TextEditingController();

  final TextEditingController primaryPromoPlatformTypeController =
      TextEditingController(text: 'Select');

  final TextEditingController anyAnwserController = TextEditingController();

  final TextEditingController zayroPlatformController = TextEditingController(
    text: 'Select',
  );

  final GlobalKey<FormState> affiliateFormKey = GlobalKey<FormState>();

  // ===========================================================================
  // LOADER & STATUS
  // ===========================================================================
  bool isLoading = false;
  bool isSuccess = false;

  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // ===========================================================================
  // RESET
  // ===========================================================================
  void resetData() {
    nickNameController.clear();
    contactInfoController.clear();
    anyAnwserController.clear();

    languageController.text = 'Select';
    countryController.text = 'Select';
    affiliateTypeController.text = 'Select';
    primaryPromoPlatformTypeController.text = 'Select';
    zayroPlatformController.text = 'Select';
    directUsersList.clear();
    mySponsor = '';
    mySponsor = '';
    linkController.clear();
    codeController.clear();
    directCount = '';
    totalEarnings = '';
    earningsToday = '';
    isDownline = false;
    selectedSocialIndexes.clear();
  }

  List<int> selectedSocialIndexes = [];

  void toggleSocialPlatform(int index) {
    if (selectedSocialIndexes.contains(index)) {
      selectedSocialIndexes.remove(index);
    } else {
      selectedSocialIndexes.add(index);
    }
    notifyListeners();
  }

  List<String> socialMediaPlatformsList(BuildContext context) {
    return [
      AppLocalizations.of(context)!.twitter,
      AppLocalizations.of(context)!.telegram,
      AppLocalizations.of(context)!.youTube,
      AppLocalizations.of(context)!.discord,
      AppLocalizations.of(context)!.facebook,
      AppLocalizations.of(context)!.instagram,
      AppLocalizations.of(context)!.linkedIn,
      AppLocalizations.of(context)!.twitch,
      AppLocalizations.of(context)!.blog,
    ];
  }

  List<String> getSelectedSocials(BuildContext context) {
    final platforms = socialMediaPlatformsList(context);
    return selectedSocialIndexes
        .map((i) => platforms[i].toLowerCase())
        .toList();
  }

  // =========================================================
  // ⭐ CONVERT API STRING -> CHECKBOX INDEXES
  // =========================================================
  void applyApiSocialSelection(BuildContext context, dynamic socialsRaw) {
    try {
      if (socialsRaw == null) return;

      final List<dynamic> decoded = jsonDecode(socialsRaw.toString());

      final apiSocials = decoded
          .map((e) => e.toString().toLowerCase())
          .toList();

      final platforms = socialMediaPlatformsList(
        context,
      ).map((e) => e.toLowerCase()).toList();

      selectedSocialIndexes.clear();

      for (int i = 0; i < platforms.length; i++) {
        if (apiSocials.contains(platforms[i])) {
          selectedSocialIndexes.add(i);
        }
      }
    } catch (e) {
      debugPrint("Social parse error: $e");
    }
  }

  // ===========================================================================
  // AFFILIATE TYPE
  // ===========================================================================
  int affiliateTypeIndex = 0;

  void setAffiliateTypeDetails({required String type, required int id}) {
    affiliateTypeIndex = id;
    affiliateTypeController.text = type;
    notifyListeners();
  }

  List<String> affiliateTypeList(BuildContext context) {
    return [
      AppLocalizations.of(context)!.cryptoInfluencerIndividual,
      AppLocalizations.of(context)!.socialMediaInfluencerNonCryptoCommunity,
      AppLocalizations.of(context)!.developerTradingTools,
      AppLocalizations.of(context)!.others,
    ];
  }

  // ===========================================================================
  // COUNTRY
  // ===========================================================================
  int countryTypeIndex = 0;

  void setCountryTypeDetails({required String type, required int id}) {
    countryTypeIndex = id;
    countryController.text = type;
    notifyListeners();
  }

  List<String> countryList(BuildContext context) {
    return [
      AppLocalizations.of(context)!.india,
      AppLocalizations.of(context)!.usa,
      AppLocalizations.of(context)!.uk,
      AppLocalizations.of(context)!.chinese,
    ];
  }

  // ===========================================================================
  // PROMO PLATFORM
  // ===========================================================================
  int promoTypeIndex = 0;

  void setPromoTypeDetails({required String type, required int id}) {
    promoTypeIndex = id;
    primaryPromoPlatformTypeController.text = type;
    notifyListeners();
  }

  List<String> promoPlatformList(BuildContext context) {
    return [
      AppLocalizations.of(context)!.twitter,
      AppLocalizations.of(context)!.telegram,
      AppLocalizations.of(context)!.youTube,
      AppLocalizations.of(context)!.instagram,
      AppLocalizations.of(context)!.blog,
      AppLocalizations.of(context)!.others,
    ];
  }

  // ===========================================================================
  // ZAYRO PLATFORM
  // ===========================================================================
  int zayroPlatformTypeIndex = 0;

  void setZayroPlatformTypeDetails({required String type, required int id}) {
    zayroPlatformTypeIndex = id;
    zayroPlatformController.text = type;
    notifyListeners();
  }

  List<String> zayroPlatformList(BuildContext context) {
    return [
      AppLocalizations.of(context)!.zayroWebSite,
      AppLocalizations.of(context)!.anotherAffiliate,
      AppLocalizations.of(context)!.zayroInstagram,
      AppLocalizations.of(context)!.zayroTelegram,
      AppLocalizations.of(context)!.others,
    ];
  }

  // ===========================================================================
  // LANGUAGE
  // ===========================================================================
  int languageTypeIndex = 0;

  void setLanguageTypeDetails({required String type, required int id}) {
    languageTypeIndex = id;
    languageController.text = type;
    notifyListeners();
  }

  List<String> languageList(BuildContext context) {
    return [
      AppLocalizations.of(context)!.english,
      AppLocalizations.of(context)!.chinese,
    ];
  }

  // ===========================================================================
  // API
  // ===========================================================================
  final AffiliateAPI provider = AffiliateAPI();
  String statusValue = '';
  Future<void> doSubmitAffiliateDetailsAPI(BuildContext context) async {
    setLoader(true);

    try {
      final payload = {
        "nickname": nickNameController.text.trim(),
        "affiliatetype": affiliateTypeController.text,
        "language": languageController.text,
        "contactinfo": contactInfoController.text.trim(),
        "country": countryController.text,
        "promoplatform": primaryPromoPlatformTypeController.text,
        if (selectedSocialIndexes.isNotEmpty)
          "othersocials": getSelectedSocials(context),
        "hearingplatform": zayroPlatformController.text,
        "description": anyAnwserController.text.trim(),
      };

      final value = await provider.submitAffiliateDetails(payload);

      if (!context.mounted) return;

      setLoader(false);

      final parsed = json.decode(value.toString());

      if (parsed['success'] == true) {
        isSuccess = true;
        _showSuccessToast(context, parsed['message']);
        statusValue = parsed['message'].toString();
        getAffiliateDetails(context);
        // Navigator.pop(context);
        // resetData();
      } else {
        isSuccess = false;
        _showParsedError(context, parsed, [
          'nickname',
          'affiliatetype',
          'language',
          'contactinfo',
          'country',
          'promoplatform',
          'othersocials',
          'hearingplatform',
          'error',
        ]);
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

  // =====================================================
  // TEXT CONTROLLERS
  // =====================================================
  final TextEditingController linkController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  // =====================================================
  // BASIC DATA
  // =====================================================
  String sponsorName = "";

  bool isDownline = true;

  void changeTab(bool value) {
    isDownline = value;
    notifyListeners();
  }

  // =====================================================
  // MAIN DATA MODEL
  // =====================================================
  AffiliateModel? referralData;

  // =====================================================
  // LISTS
  // =====================================================
  List<DirectUserModel> directUsersList = [];

  /// full history from API
  List<AffiliateHistoryModel> referralHistoryList = [];

  /// filtered history based on level
  List<AffiliateHistoryModel> filteredHistory = [];

  // =====================================================
  // DROPDOWN
  // =====================================================
  int selectedLevel = 1;

  // =====================================================
  // API CALL
  // =====================================================
  String isAffiliate = '';
  String statusText = '';
  String userID = '';
  String affiliateID = '';
  String affiliateStatus = '';

  Future<void> getAffiliateDetails(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getAffiliateDetails();
      final parsed = json.decode(value.toString());
      setLoader(false);
      if (parsed["success"] == true) {
        // _showSuccessToast(context, parsed['message'].toString());
        final data = parsed["data"]['affiliate'];
        print("One");
        affiliateStatus = parsed["data"]['affiliate'].toString();
        isAffiliate = parsed["data"]['is_affiliate'].toString();
        statusText = parsed["data"]['status_text'].toString();
        print("One2");
        if(data.runtimeType == List<dynamic>){
          return;
        }
        affiliateID = data['id'].toString();
        userID = data['user_id'].toString();
        nickNameController.text = data['nickname'].toString();
        print("One3");
        affiliateTypeController.text = data['affiliate_type'].toString();
        languageController.text = data['language'].toString();
        contactInfoController.text = data['contact_info'].toString();
        print("One4");
        countryController.text = data['country'].toString();
        primaryPromoPlatformTypeController.text = data['promo_platform']
            .toString();
        anyAnwserController.text = data['description'].toString();
        print("One5");
        zayroPlatformController.text = data['hearing_platform'].toString();
        zayroPlatformController.text = data['hearing_platform'].toString();
        print("One6");
        /// ⭐ restore checkbox
        applyApiSocialSelection(context, data['other_socials']);

        if (parsed["data"]['is_affiliate'].toString() == '1') {
          Future.delayed(Duration.zero).whenComplete(() {
            getAffiliateAgentDetailsApi(context);
          });
        }

        notifyListeners();
      } else {
        if (!context.mounted) return;
        // _showParsedError(context, parsed, ["error"]);
        _showErrorToast(context, parsed['message'].toString());
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

  // =====================================================
  // Referral Affiliate API
  // =====================================================
  String mySponsor = '';
  String link = '';
  String code = '';
  String directCount = '';
  String totalEarnings = '';
  String earningsToday = '';

  Future<void> getAffiliateAgentDetailsApi(BuildContext context) async {
    setLoader(true);

    try {
      final response = await provider.getAffiliateAgentDetails();
      final parsed = json.decode(response.toString());

      setLoader(false);

      if (parsed['success'] == true && parsed['data'] != null) {
        final data = parsed['data'];

        /// CLEAR OLD DATA
        directUsersList.clear();
        referralHistoryList.clear();
        filteredHistory.clear();

        /// SPONSOR
        final sponsor = data['sponsor'];
        mySponsor = sponsor?['my_sponsor']?.toString() ?? '-';
        linkController.text = sponsor?['link']?.toString() ?? '';

        final code = sponsor?['code']?.toString();
        codeController.text =
            code != null && code.isNotEmpty && code.toLowerCase() != 'null'
            ? code
            : '-';

        /// SUMMARY
        directCount = data['direct_count']?.toString() ?? '0';
        totalEarnings = data['total_earnings']?.toString() ?? '0';
        earningsToday = data['earnings_today']?.toString() ?? '0';

        /// DIRECT USERS
        if (data['direct_users'] is List) {
          for (final item in data['direct_users']) {
            directUsersList.add(
              DirectUserModel(
                username: item['username']?.toString() ?? '',
                totalUsd: item['total_usd']?.toString() ?? '0',
                verifiedKyc: item['verified_kyc'] ?? 0,
              ),
            );
          }
        }

        /// 🔥 HISTORY (THIS WAS MISSING)
        if (data['history'] is List) {
          for (final item in data['history']) {
            referralHistoryList.add(
              AffiliateHistoryModel(
                level: item['level'],
                commissionUsd: item['commission_usd']?.toString() ?? '',
                createdAt: item['created_at']?.toString() ?? '',
              ),
            );
          }

          /// DEFAULT LEVEL 1
          filterHistoryByLevel(1);
        }

        notifyListeners();
      } else {
        _showErrorToast(
          context,
          parsed['message']?.toString() ?? 'Something went wrong',
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

  // =====================================================
  // FILTER BY LEVEL
  // =====================================================
  void filterHistoryByLevel(int level) {
    selectedLevel = level;

    filteredHistory = referralHistoryList
        .where((e) => e.level == level)
        .toList();

    notifyListeners();
  }

  // =====================================================
  // ERROR HANDLING
  // =====================================================
  void _showErrorToast(BuildContext context, String message) {
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

  void _showParsedError(
    BuildContext context,
    dynamic parsed,
    List<String> keys,
  ) {
    String errorMessage = "";

    for (var key in keys) {
      if (parsed['data'].toString().contains(key)) {
        errorMessage += parsed['data'][key]
            .toString()
            .replaceAll('null', '')
            .replaceAll('[', '')
            .replaceAll(']', '');
      }
    }

    if (errorMessage.isNotEmpty) {
      _showErrorToast(context, errorMessage);
    }
  }
}

// =============================================================================
// MODELS (kept same)
// =============================================================================

class YourAffiliateTypeModel {
  final String id;
  final String name;
  YourAffiliateTypeModel({required this.id, required this.name});
}

class CountryModel {
  final String id;
  final String countryName;
  CountryModel({required this.id, required this.countryName});
}

class PrimaryPromoPlatformModel {
  final String id;
  final String name;
  PrimaryPromoPlatformModel({required this.id, required this.name});
}

class ZayroPlatformModel {
  final String id;
  final String name;
  ZayroPlatformModel({required this.id, required this.name});
}

class LanguageModel {
  final String id;
  final String name;
  LanguageModel({required this.id, required this.name});
}

/////////////////Affiliate Over Model ///////////////////
class AffiliateModel {
  final SponsorModel? sponsor;
  final int? directCount;
  final List<DirectUserModel>? directUsers;
  final List<AffiliateHistoryModel>? history;

  // ✅ ADD THESE
  final String? totalEarnings;
  final String? earningsToday;

  AffiliateModel({
    this.sponsor,
    this.directCount,
    this.directUsers,
    this.history,
    this.totalEarnings,
    this.earningsToday,
  });

  factory AffiliateModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return AffiliateModel(
      sponsor: data['sponsor'] != null
          ? SponsorModel.fromJson(data['sponsor'])
          : null,

      directCount: data['direct_count'],

      totalEarnings: data['total_earnings']?.toString(),
      earningsToday: data['earnings_today']?.toString(),

      directUsers: (data['direct_users'] as List? ?? [])
          .map((e) => DirectUserModel.fromJson(e))
          .toList(),

      history: (data['history'] as List? ?? [])
          .map((e) => AffiliateHistoryModel.fromJson(e))
          .toList(),
    );
  }
}

class SponsorModel {
  final String? mySponsor;
  final String? link;
  final String? code;

  SponsorModel({this.mySponsor, this.link, this.code});

  factory SponsorModel.fromJson(Map<String, dynamic> json) {
    return SponsorModel(
      mySponsor: json['my_sponsor']?.toString(),
      link: json['link']?.toString(),
      code: json['code']?.toString(),
    );
  }
}

class DirectUserModel {
  final String? username;
  final String? totalUsd;
  final int? verifiedKyc;

  DirectUserModel({this.username, this.totalUsd, this.verifiedKyc});

  factory DirectUserModel.fromJson(Map<String, dynamic> json) {
    return DirectUserModel(
      username: json['username']?.toString(),
      totalUsd: json['total_usd']?.toString(),
      verifiedKyc: json['verified_kyc'],
    );
  }
}

class AffiliateHistoryModel {
  final int? level;
  final String? createdAt;
  final String? commissionUsd;

  AffiliateHistoryModel({this.level, this.createdAt, this.commissionUsd});

  factory AffiliateHistoryModel.fromJson(Map<String, dynamic> json) {
    return AffiliateHistoryModel(
      level: json['level'],
      createdAt: json['created_at']?.toString(),
      commissionUsd: json['commission_usd']?.toString(),
    );
  }
}
