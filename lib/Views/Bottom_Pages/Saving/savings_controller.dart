import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'savings_api.dart';

class SavingsController extends ChangeNotifier {
  bool _initialized = false;

  Future<void> init(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;
    await doGetStakeProductsAPI(context);
  }

  // ---------------------------------------------------------------------------
  // Text Controllers
  // ---------------------------------------------------------------------------

  final TextEditingController savingAmountController = TextEditingController();

  AutovalidateMode savingAmountAutoValidate = AutovalidateMode.disabled;

  final TextEditingController chooseCryptoController = TextEditingController(
    text: 'Select Coin',
  );
  AutovalidateMode chooseCryptoAutoValidate = AutovalidateMode.disabled;

  final TextEditingController investmentTypeController = TextEditingController(
    text: 'Select Type',
  );
  AutovalidateMode investmentTypeAutoValidate = AutovalidateMode.disabled;

  final TextEditingController planController = TextEditingController(
    text: 'Select',
  );
  AutovalidateMode planAutoValidate = AutovalidateMode.disabled;

  final TextEditingController calculateAmountController = TextEditingController(
    text: '0.000',
  );

  AutovalidateMode calculateAmountAutoValidate = AutovalidateMode.disabled;
  // ---------------------------------------------------------------------------
  // Loader & Status
  // ---------------------------------------------------------------------------

  bool isLoading = false;
  bool isSuccess = false;
  bool isHidden = false;
  bool isSecendHidden = false;
  bool isSelectColorFeild = false;

  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setHidden(bool value) {
    isHidden = !isHidden;
    notifyListeners();
  }

  void setSecendHidden(bool value) {
    isSecendHidden = !isSecendHidden;
    notifyListeners();
  }

  void setIsSelectColorFeild(bool value) {
    isSelectColorFeild = !isSelectColorFeild;
    notifyListeners();
  }

  ///Agree and Terms////
  bool isTermsAccepted = false;

  void toggleTermsAccepted() {
    isTermsAccepted = !isTermsAccepted;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Subscribe Tab bar View Function
  // ---------------------------------------------------------------------------
  int selectedIndex = 0;

  void changeTab(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Subscribe Pop Tab bar View Function
  // ---------------------------------------------------------------------------
  int selectedPlanIndex = 0;

  void changePlanTab(BuildContext context, int index) {
    selectedPlanIndex = index;
    notifyListeners();
  }
  // ---------------------------------------------------------------------------
  // LinearProgressBar View Function
  // ---------------------------------------------------------------------------

  int stakingFilledToStep(String stakingFilled, int maxSteps) {
    try {
      final parts = stakingFilled.split('/');
      final used = double.parse(parts[0].trim());
      final total = double.parse(parts[1].trim());

      if (total == 0) return 0;

      return ((used / total) * maxSteps).round().clamp(0, maxSteps);
    } catch (e) {
      return 0;
    }
  }

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------

  void clearData() {
    planListID = '';
    planListMinLimit = '0.0';
    planListMaxLimit = '0.0';
    calculationPreviewDaily = '';
    coinValue = '';
    planListRate = '0';
    selectItem = null;
    calculateAmountController.text = '';
    chooseCryptoController.text = '';
    investmentTypeController.text = '';
    savingAmountController.text = '';
    stakePreviewDaily = '';
    stakeProductsList.clear();
    stakeTypeList.clear();
    flexibleDurationList.clear();
    fixedDurationList.clear();
    isHidden = false;
    isSecendHidden = false;
    isSelectColorFeild = false;
    selectedPlanIndex = 0;
    isTermsAccepted = false;
    stakePreviewAmount = '';
    stakePreviewTotal = '';
    stakePlanID = '';
    stakePlanCrypto = '';
    stakePlanApr = '';
    stakePlanStakeType = '';
    stakePreviewTotal = '';
    stakePreviewMin = '';
    stakePreviewMax = '';
    availableBalance = '';
    remainingPool = '';
    subscriptionDate = '';
    interestStart = '';
    interestPayment = '';
    interestPeriod = '';
    earningsUsdValue = '';
    earningsBtcValue = '';
    profitTotalUSDTValue = '';
    profitTotalUsdValue = '';
    profitYesterdayUSDTValue = '';
    profitYesterdayUsdValue = '';
  }

  // 🔹 expand/collapse
  int expandedIndex = -1; // -1 means nothing is expanded

  void toggleExpand(int index) {
    if (expandedIndex == index) {
      expandedIndex = -1; // collapse if tapped again
    } else {
      expandedIndex = index; // expand new one
    }
    notifyListeners();
  }

  SavingsAPI provider = SavingsAPI();

  String earningsUsdValue = '';
  String earningsBtcValue = '';
  String profitTotalUSDTValue = '';
  String profitTotalUsdValue = '';
  String profitYesterdayUSDTValue = '';
  String profitYesterdayUsdValue = '';
  String planListID = '';
  String coinValue = '';
  String planListMinLimit = '0.0';
  String planListMaxLimit = '0.0';
  String planListRate = '0';
  String investmentStakeType = '';
  StakePlan? selectStakePlanList;
  StakeProductsModel? selectItem;

  /// get Stake Products List API Function
  List<StakeProductsModel> stakeProductsList = [];
  List<String> stakeTypeList = [];
  List<StakePlan> flexibleDurationList = [];
  List<StakePlan> fixedDurationList = [];

  List<UserStakingModel> userHistoryList = [];
  List<UserStakingModel> cancelledHistoryList = [];
  List<UserStakingModel> historicalHoldingList = [];

  Future<void> getStakeHistory(BuildContext context) async {
    setLoader(true);
    try {
      final value = await provider.stakeHistory();
      final parsed = json.decode(value.toString());
      setLoader(false);

      if (parsed['success'] == true) {
        userHistoryList.clear();
        historicalHoldingList.clear();
        cancelledHistoryList.clear();

        for (final item in parsed['data']['user_staking']) {
          final model = UserStakingModel(
            id: item['stake_id']?.toString(),
            coin: item['coin']?.toString(),
            coinImage: item['coin_image']?.toString(),
            coinName: item['coin_name']?.toString(),
            stakedAmount: item['staked_amount']?.toString(),
            duration: item['duration']?.toString(),
            interestRate: item['interest_rate']?.toString(),
            interestReceived: item['interest_received']?.toString(),
            interestEstimated: item['interest_estimated']?.toString(),
            interestCreditSchedule: item['interest_credit_schedule']
                ?.toString(),
            subscribeDate: item['subscribe_date']?.toString(),
            unlockDate: item['unlock_date']?.toString(),
            status: item['status'],
            statusText: item['status_text']?.toString(),
            planType: item['plan_type']?.toString(),
          );

          item['status']?.toString() == '3'
              ? cancelledHistoryList.add(model)
              : item['status']?.toString() == '1'
              ? userHistoryList.add(model)
              : historicalHoldingList.add(model);
        }

        notifyListeners();
      } else {
        _showParsedError(context, parsed, ['error']);
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

  // StakePlan? selectedPlan;
  // StakeProductsModel? selectedCoin;
  //
  // void coinListModule(StakePlan plan) {
  //
  //   selectedPlan = plan;
  //
  //   /// find parent coin
  //   for (var coin in stakeProductsList) {
  //     if (coin.plans.any((p) => p.id == plan.id)) {
  //       selectedCoin = coin;
  //       break;
  //     }
  //   }
  //
  //   /// fill UI
  //   chooseCryptoController.text = selectedCoin?.coin ?? "";
  //   investmentTypeController.text = plan.stakeType ?? "";
  //   planController.text = '${plan.stakeType} - ${plan.rate}';
  //
  //   notifyListeners();
  // }

  void coinListModule(BuildContext context, StakeProductsModel item) {
    selectItem = item;
    chooseCryptoController.text = selectItem!.coin.toString();
    coinValue = selectItem!.coin.toString();
    investmentTypeController.text = selectItem!.plans.first.stakeType
        .toString();
    updateInvestmentType(selectItem!.plans.first.stakeType.toString());
    planListID = selectItem!.plans.first.id.toString();
    planListMinLimit = double.parse(
      selectItem!.plans.first.minLimit.toString(),
    ).toStringAsFixed(3);
    planListMaxLimit = double.parse(
      selectItem!.plans.first.maxLimit.toString(),
    ).toStringAsFixed(3);
    planListRate = selectItem!.plans.first.rate.toString();
    planController.text =
        '${selectItem!.plans.first.stakeType == 'fixed' ? '${selectItem!.plans.first.duration} ${AppLocalizations.of(context)!.days}' : selectItem!.plans.first.stakeType.toString()} - ${'${selectItem!.plans.first.rate} %'}';
    stakeTypeList = getAvailableTypes(item.plans);
    getDurationArrays(item.plans, context);
    notifyListeners();
  }

  void planListModule(BuildContext context, StakePlan listItem) {
    planController.text = listItem.stakeType == 'fixed'
        ? '${listItem.duration} days-${listItem.rate} %' ?? ''
        : "${AppLocalizations.of(context)!.flexible} - ${listItem.rate} %";
    planListID = listItem.id.toString();
    planListMinLimit = double.parse(
      listItem.minLimit.toString(),
    ).toStringAsFixed(3);
    planListMaxLimit = double.parse(
      listItem.maxLimit.toString(),
    ).toStringAsFixed(3);

    notifyListeners();
  }

  updateInvestmentType(String list) {
    investmentTypeController.text = list.toString();
    investmentStakeType = list.toString();
    notifyListeners();
  }

  Future<void> doGetStakeProductsAPI(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getStakeProducts();
      final parsed = json.decode(value.toString());
      setLoader(false);
      if (parsed['success'] == true) {
        setLoader(false);
        print('parsed object: ${parsed.toString()}');
        earningsUsdValue = parsed['data']['earnings']['usdValue'].toString();
        earningsBtcValue = parsed['data']['earnings']['btcValue'].toString();
        profitTotalUSDTValue = parsed['data']['profit']['total']['usdt']
            .toString();
        profitTotalUsdValue = parsed['data']['profit']['total']['usd']
            .toString();
        profitYesterdayUSDTValue = parsed['data']['profit']['yesterday']['usdt']
            .toString();
        profitYesterdayUsdValue = parsed['data']['profit']['yesterday']['usd']
            .toString();
        // Clear old data
        stakeProductsList.clear();
        // if (parsed['data']['list'].toString() != "[]") {
        //   for (var coinData in parsed['data']['list']) {
        //     final String coin = coinData['coin'].toString();
        //     if (coinData['plans'].toString() != "[]") {
        //       for (var plan in coinData['plans']) {
        //         stakeProductsList.add(
        //           StakeProductsModel(
        //             coin: coin,
        //             id: plan['id'].toString(),
        //             crypto: plan['crypto'].toString(),
        //             image: plan['image'].toString(),
        //             rate: plan['rate'].toString(),
        //             rateType: plan['rate_type'].toString(),
        //             duration: plan['duration']?.toString() ?? '',
        //             stakeType: plan['stake_type'].toString(),
        //             minLimit: plan['min_limit'].toString(),
        //             maxLimit: plan['max_limit'].toString(),
        //             balance: plan['balance'].toString(),
        //             stakingFilled: plan['staking_filled'].toString(),
        //             usedQty: plan['used_qty'].toString(),
        //             totalQty: plan['total_qty'].toString(),
        //           ),
        //         );
        //       }
        //     }
        //   }
        //   notifyListeners();
        // }

        if (parsed['data']['list'].toString() != "[]") {
          for (var coinData in parsed['data']['list']) {
            List<StakePlan> planList = [];
            for (var plan in coinData['plans']) {
              // 🔑 SINGLE BASE DATE (IMPORTANT)
              final DateTime baseDate = DateTime.now();

              final String stakeType = plan['stake_type'].toString();
              final String? duration = plan['duration']?.toString();

              final String subscriptionDate = formatDate(baseDate);
              final String interestStart = subscriptionDate;

              final String interestPayment = getInterestPaymentDate(
                baseDate: baseDate,
                stakeType: stakeType,
                duration: duration,
              );

              planList.add(
                StakePlan(
                  id: plan['id'].toString(),
                  crypto: plan['crypto'].toString(),
                  image: plan['image'].toString(),
                  rate: plan['rate'].toString(),
                  rateType: plan['rate_type'].toString(),
                  duration: duration ?? '',
                  stakeType: stakeType,
                  minLimit: plan['min_limit'].toString(),
                  maxLimit: plan['max_limit'].toString(),
                  stakingFilled: plan['staking_filled'].toString(),
                  balance: plan['balance'].toString(),
                  subscriptionDate: subscriptionDate,
                  interestStart: interestStart,
                  interestPayment: interestPayment,
                ),
              );
            }

            // 🔥 ADD COIN ONLY ONCE
            stakeProductsList.add(
              StakeProductsModel(
                coin: coinData['coin'].toString(),
                plans: planList,
              ),
            );
            // stakeTypes.clear();
            //
            // List coins = parsed['data']['list'];
            //
            // for (var coin in coins) {
            //   for (var plan in coin['plans']) {
            //
            //     String type = plan['stake_type'];
            //
            //     if (!stakeTypes.contains(type)) {
            //       stakeTypes.add(type);
            //     }
            //   }
            // }
          }
        }

        notifyListeners();
      } else {
        if (!context.mounted) return;
        _showParsedError(context, parsed, ["error"]);
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

  List<String> getAvailableTypes(List<StakePlan> data) {
    Set<String> types = {};

    for (var item in data) {
      types.add(item.stakeType.toString());
    }

    return types.toList();
  }

  getDurationArrays(List<StakePlan> data, BuildContext context) {
    flexibleDurationList = [];
    fixedDurationList = [];
    for (var item in data) {
      if (item.stakeType.toString().toLowerCase() == 'flexible') {
        // flexibleDurationList.add("${AppLocalizations.of(context)!.flexible} - ${item.rate}%");
        flexibleDurationList.add(item);
      } else {
        fixedDurationList.add(item);
      }

      print(
        "getDuration Arrays ${flexibleDurationList.length} and ${fixedDurationList.length} annnd ${investmentStakeType.toLowerCase()}",
      );
      notifyListeners();
    }
  }

  // ---------- SAFE DURATION PARSER ----------
  int safeDurationDays(String? duration) {
    if (duration == null || duration.trim().isEmpty) return 0;
    return int.tryParse(duration.trim()) ?? 0;
  }

  // ---------- DATE FORMATTER ----------
  String formatDate(DateTime date) {
    print("objectvvvv" + date.day.toString());

    String two(int n) => n.toString().padLeft(2, '0');

    return '${date.year}-'
        '${two(date.month)}-'
        '${two(date.day)} '
        '${two(date.hour)}:'
        '${two(date.minute)}:'
        '${two(date.second)}';
  }

  // ---------- STAKE-AWARE INTEREST PAYMENT (NO DAY SHIFT) ----------
  String getInterestPaymentDate({
    required DateTime baseDate,
    required String stakeType,
    required String? duration,
  }) {
    // Flexible staking → same day
    // if (stakeType.toLowerCase() != 'fixed') {
    //   return formatDate(baseDate);
    // }

    if (stakeType.toLowerCase() != 'fixed') {
      return formatDate(baseDate.add(const Duration(days: 1)));
    } else {
      final int days = safeDurationDays(duration);
      return formatDate(baseDate.add(Duration(days: days)));
    }
  }

  ///  Saving Calculation API///
  void restData() {
    calculateAmountController.text = '';
    savingAmountController.text = '';
    selectedPlanIndex = 0;
    isTermsAccepted = false;
    calculationPreviewDaily = '';
    stakePreviewAmount = '';
    stakePreviewDaily = '';
    stakePreviewTotal = '';
    stakePlanID = '';
    stakePlanCrypto = '';
    stakePlanApr = '';
    stakePlanStakeType = '';
    stakePreviewTotal = '';
    stakePreviewMin = '';
    stakePreviewMax = '';
    availableBalance = '';
    remainingPool = '';
    subscriptionDate = '';
    interestStart = '';
    interestPayment = '';
    interestPeriod = '';
  }

  // ///// Saving text Filed API ////
  Timer? _debounce;
  void onAmountChanged(BuildContext context, String text, String planId) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (text.trim().isEmpty) {
        stakePreviewAmount = '';
        stakePreviewDaily = '';
        notifyListeners();
        return;
      }

      doStakePreviewCalculationAPI(context, planId, text);
    });
  }

  // ///// Saving Calculation filed text Filed API ////
  Timer? _calculateDebounce;
  void onCalculationAmountChanged(
    BuildContext context,
    String text,
    String planId,
  ) {
    if (_calculateDebounce?.isActive ?? false) _calculateDebounce!.cancel();

    _calculateDebounce = Timer(const Duration(milliseconds: 600), () {
      if (text.trim().isEmpty) {
        stakePreviewDaily = '';
        calculationPreviewDaily = '';
        notifyListeners();
        return;
      }

      doStakePreviewCalculationAPI(context, planId, text);
    });
  }

  String stakePlanID = '';
  String stakePlanCrypto = '';
  String stakePlanApr = '';
  String stakePlanStakeType = '';
  String stakePreviewDaily = '';
  String calculationPreviewDaily = '';
  String stakePreviewAmount = '';
  String stakePreviewTotal = '';
  String stakePreviewMin = '';
  String stakePreviewMax = '';
  String availableBalance = '';
  String remainingPool = '';
  String subscriptionDate = '';
  String interestStart = '';
  String interestPayment = '';
  String interestPeriod = '';

  Future<void> doStakePreviewCalculationAPI(
    BuildContext context,
    String planId,
    String amount,
  ) async {
    setLoader(true);

    try {
      final payload = {"plan_id": planId, "amount": amount};

      final value = await provider.stakePreview(payload);

      if (!context.mounted) return;

      setLoader(false);

      final parsed = json.decode(value.toString());

      if (parsed['success'] == true) {
        isSuccess = true;
        // _showSuccessToast(context, parsed['message']);
        stakePlanID = parsed['data']['plan']['id'].toString();
        stakePlanCrypto = parsed['data']['plan']['crypto'].toString();
        stakePlanApr = parsed['data']['plan']['apr'].toString();
        stakePlanStakeType = parsed['data']['plan']['stake_type'].toString();
        stakePreviewAmount = parsed['data']['amount'].toString();
        stakePreviewDaily = parsed['data']['earnings']['daily'].toString();
        calculationPreviewDaily = parsed['data']['earnings']['daily']
            .toString();
        stakePreviewTotal = parsed['data']['earnings']['total'].toString();
        stakePreviewMin = parsed['data']['limits']['min'].toString();
        stakePreviewMax = parsed['data']['limits']['max'].toString();
        availableBalance = parsed['data']['limits']['max'].toString();
        subscriptionDate = parsed['data']['timeline']['subscription_date']
            .toString();
        interestStart = parsed['data']['timeline']['interest_start'].toString();
        interestPayment = parsed['data']['timeline']['interest_payment']
            .toString();
        interestPeriod = parsed['data']['timeline']['interest_period']
            .toString();
      } else {
        isSuccess = false;
        if (!context.mounted) return;
        // _showParsedError(context, parsed, ['plan_id', 'amount', 'error']);
        // _showParsedError(context, parsed, ['message']);
        _showErrorToast(context, parsed['message']);
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

  /// Submit Stake Submit Api///
  Future<void> cancelStack(BuildContext context, String stakeId) async {
    setLoader(true);

    try {
      final payload = {"staking_id": stakeId};

      final value = await provider.cancelStakeSubmit(payload);

      setLoader(false);

      final parsed = json.decode(value.toString());

      if (parsed['success'] == true) {
        isSuccess = true;
        _showSuccessToast(context, parsed['message']);
        getStakeHistory(context);
      } else {
        isSuccess = false;
        _showErrorToast(context, parsed['message']);
        // _showParsedError(context, parsed, parsed['message']
        // );
        // _showParsedError(context, parsed, [
        //   'amount',
        //   'duration',
        //   'language',
        //   'interest_credit_schedule',
        //   'interest_payment_date',
        //   'interest_start_date',
        //   'stake_id',
        //   'duration',
        //   'error',
        // ]
        // );
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

  /// Submit Stake Submit Api///
  Future<void> doSaveStakeSubmitAPI(
    BuildContext context,
    String duration,
    String interestCreditSchedule,
    String interestPaymentDate,
    String interestStartDate,
    String stakeId,
  ) async {
    setLoader(true);

    try {
      final payload = {
        "amount": savingAmountController.text,
        "duration": duration,
        "interest_credit_schedule": interestCreditSchedule,
        "interest_payment_date": interestPaymentDate,
        "interest_start_date": interestStartDate,
        "stake_id": stakeId,
      };

      final value = await provider.saveStakeSubmit(payload);

      if (!context.mounted) return;

      setLoader(false);

      final parsed = json.decode(value.toString());

      if (parsed['success'] == true) {
        isSuccess = true;
        _showSuccessToast(context, parsed['message']);
        restData();
        doGetStakeProductsAPI(context);
        Navigator.pop(context);
      } else {
        isSuccess = false;
        _showErrorToast(context, parsed['message']);
        // _showParsedError(context, parsed, parsed['message']
        // );
        // _showParsedError(context, parsed, [
        //   'amount',
        //   'duration',
        //   'language',
        //   'interest_credit_schedule',
        //   'interest_payment_date',
        //   'interest_start_date',
        //   'stake_id',
        //   'duration',
        //   'error',
        // ]
        // );
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

// -----------------------------------------------------------------------------
// Models
// -----------------------------------------------------------------------------

class CoinCardDeatilsModule {
  final String coin;
  final String Image;

  CoinCardDeatilsModule({required this.coin, required this.Image});
}

class StakeProductsModel {
  final String coin;
  final List<StakePlan> plans;

  StakeProductsModel({required this.coin, required this.plans});
}

class StakePlan {
  final String id;
  final String crypto;
  final String image;
  final String rate;
  final String rateType;
  final String duration;
  final String stakeType;
  final String minLimit;
  final String maxLimit;
  final String stakingFilled;
  final String balance;
  final String subscriptionDate;
  final String interestStart;
  final String interestPayment;

  StakePlan({
    required this.id,
    required this.crypto,
    required this.image,
    required this.rate,
    required this.rateType,
    required this.duration,
    required this.stakeType,
    required this.minLimit,
    required this.maxLimit,
    required this.stakingFilled,
    required this.balance,
    required this.subscriptionDate,
    required this.interestStart,
    required this.interestPayment,
  });
}

// class StakeProductsModel {
//   final String coin;
//   final String id;
//   final String crypto;
//   final String image;
//   final String rate;
//   final String rateType;
//   final String duration;
//   final String stakeType;
//   final String minLimit;
//   final String maxLimit;
//   final String balance;
//   final String stakingFilled;
//   final String usedQty;
//   final String totalQty;
//
//   StakeProductsModel({
//     required this.coin,
//     required this.id,
//     required this.crypto,
//     required this.image,
//     required this.rate,
//     required this.rateType,
//     required this.duration,
//     required this.stakeType,
//     required this.minLimit,
//     required this.maxLimit,
//     required this.balance,
//     required this.stakingFilled,
//     required this.usedQty,
//     required this.totalQty,
//   });
// }

// ------------------------ Error Handler ------------------------

void _showSuccessToast(BuildContext context, String message) {
  CustomAnimationToast.show(
    context: context,
    message: message,
    type: ToastType.success,
  );
}

void _showErrorToast(BuildContext context, String message) {
  CustomAnimationToast.show(
    context: context,
    message: message,
    type: ToastType.error,
  );
}

void _showParsedError(BuildContext context, dynamic parsed, List<String> keys) {
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

class UserStakingModel {
  final String? id;
  final String? coin;
  final String? coinImage;
  final String? coinName;
  final String? stakedAmount;
  final String? duration;
  final String? interestRate;
  final String? interestReceived;
  final String? interestEstimated;
  final String? interestCreditSchedule;
  final String? subscribeDate;
  final String? unlockDate;
  final int? status;
  final String? statusText;
  final String? planType;

  UserStakingModel({
    this.id,
    this.coin,
    this.coinImage,
    this.coinName,
    this.stakedAmount,
    this.duration,
    this.interestRate,
    this.interestReceived,
    this.interestEstimated,
    this.interestCreditSchedule,
    this.subscribeDate,
    this.unlockDate,
    this.status,
    this.statusText,
    this.planType,
  });
}
