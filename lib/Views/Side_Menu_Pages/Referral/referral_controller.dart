// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/referral_api.dart';

class ReferralController extends ChangeNotifier {
  // =====================================================
  // USER DETAILS
  // =====================================================
  String emailVerifiedAt = '';
  int verifiedKyc = 0;
  String affiliateId = '';
  String affiliateIdLink = '';

  // =====================================================
  // CHEST DETAILS
  // =====================================================
  int blueOpened = 0;
  int redOpened = 0;
  int goldOpened = 0;
  bool chestFrozen = false;

  // =====================================================
  // PROGRESS DETAILS
  // =====================================================
  int referralsCount = 0;
  int cycleStartRef = 0;
  int cyclePosition = 0;
  int completedSubCycles = 0;
  int fullResetCount = 0;

  // =====================================================
  // FRAGMENTS DETAILS
  // =====================================================
  int goldFragments = 0;
  int samuraiFragments = 0;
  int legendaryFragments = 0;
  bool legendaryUnlocked = false;
  bool phase1Maxed = false;
  bool pendingReset = false;
  int fullResetCycle = 0;

  // =====================================================
  // TEXT CONTROLLERS
  // =====================================================
  final TextEditingController linkController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  // =====================================================
  // API
  // =====================================================
  final ReferralApi provider = ReferralApi();

  // =====================================================
  // LOADER
  // =====================================================
  bool isLoading = false;

  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // =====================================================
  // TAB STATE
  // =====================================================
  int selectedTab = 0;

  void changeTab(int index) {
    selectedTab = index;
    notifyListeners();
  }

  // =====================================================
  // INIT (OPTIONAL API CALL)
  // =====================================================
  Future<void> init() async {
    // Example:
    // await fetchReferralData();
  }

  // =====================================================
  // GET REFERRAL DETAILS
  // =====================================================
  Future<void> getReferralDetails(BuildContext context) async {
    setLoader(true);

    try {
      final response = await provider.getReferalDetails();
      final parsed = json.decode(response.toString());

      debugPrint("🔍 REFERRAL API RESPONSE: $parsed");

      if (parsed['status'] == true) {
        setLoader(false);
        final dashboard = parsed['dashboard'] ?? {};
        final user = dashboard['user'] ?? {};
        final chests = dashboard['chests'] ?? {};
        final progress = dashboard['progress'] ?? {};
        final fragments = dashboard['fragments'] ?? {};

        emailVerifiedAt = user['email_verified_at'] ?? '';
        verifiedKyc = _asInt(user['verified_kyc']);
        linkController.text = (user['affiliate_id'] ?? '').toString();
        affiliateIdLink = (user['link'] ?? '').toString();

        blueOpened = _asInt(chests['blue_opened']);
        redOpened = _asInt(chests['red_opened']);
        goldOpened = _asInt(chests['gold_opened']);
        chestFrozen = chests['chest_frozen'] == true;

        referralsCount = _asInt(progress['referrals_count']);
        cycleStartRef = _asInt(progress['cycle_start_ref']);
        cyclePosition = _asInt(progress['cycle_position']);
        completedSubCycles = _asInt(progress['completed_sub_cycles']);
        fullResetCount = _asInt(progress['full_reset_count']);

        goldFragments = _asInt(fragments['gold_fragments']);
        samuraiFragments = _asInt(fragments['samurai_fragments']);
        legendaryFragments = _asInt(fragments['legendary_fragments']);
        legendaryUnlocked = fragments['legendary_unlocked'] == true;
        phase1Maxed = fragments['phase1_maxed'] == true;
        pendingReset = fragments['pending_reset'] == true;
        fullResetCycle = _asInt(fragments['full_reset_cycle']);

        notifyListeners();
      } else {
        setLoader(false);
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['error', 'message'],
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

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  void dispose() {
    linkController.dispose();
    codeController.dispose();
    super.dispose();
  }
}
