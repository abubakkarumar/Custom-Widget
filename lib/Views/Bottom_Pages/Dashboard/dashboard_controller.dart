// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'dashboard_api.dart';

class DashboardController with ChangeNotifier {
  DashboardAPI provider = DashboardAPI();

  bool isLoading = false;
  bool isAmountVisible = false;

  String walletBalanceUSD = "0.0";
  String walletBalanceBTC = "0.0";
  String totalDeposit = "0.0";
  String totalWithdraw = "0.0";

  setVisibility(bool val) {
    isAmountVisible = !val;
    notifyListeners();
  }

  setLoader(bool val) {
    isLoading = val;
    notifyListeners();
  }

  /// Balance visibility toggle
  bool _isHiddenBalance = false;
  bool get isHiddenBalance => _isHiddenBalance;

  void toggleBalance() {
    _isHiddenBalance = !_isHiddenBalance;
    notifyListeners();
  }

  int selectedIndex = 1;

  List<String> tabs(BuildContext context) {
    return [
      AppLocalizations.of(context)!.hotSpot,
      AppLocalizations.of(context)!.topGainer,
      AppLocalizations.of(context)!.topLooser,
      AppLocalizations.of(context)!.newListing,
    ];
  }

  List<MarketCoinModel> topGainersList = [];
  List<MarketCoinModel> topLosersList = [];
  List<MarketCoinModel> newList = [];
  List<MarketCoinModel> hotSpotList = [];
  List<TradePair> tradePairList = [];
  List<String> tradeSocketPairs = <String>[];
  String pairs = '';

  void changeTab(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  String dateFormatter(String date) {
    DateTime dateTime = DateTime.parse(date);

    DateFormat outputFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
    return outputFormat.format(dateTime);
  }

  /// Get User Details
  Future<void> getUserDetails(BuildContext context) async {
    try {
      setLoader(true);

      final response = await provider.getUserDetails();
      setLoader(false);

      final parsed = json.decode(response.toString());

      if (parsed['success'] == true) {
        final data = parsed['data'];

        // Extract values from response
        final String name = data['name'] ?? '';
        final String email = data['email'] ?? '';
        final String profileImage = data['profile_image'] ?? '';
        final int kycStatus = data['verified_kyc'] ?? 0;
        final String tfa = data['tfa'] ?? '';
        final String tfaStatus = data['tfa_status'] ?? '';
        final int recoveryKeyStatus =
            int.tryParse(data['recovery_key_status'].toString()) ?? 0;
        final int antiPhishingCodeStatus =
            int.tryParse(data['anti_phishing_code_status'].toString()) ?? 0;
        var mpinStatus = (AppStorage.getMPIN() == null) ? 0 : 1;

        // Store in AppStorage
        AppStorage.storeTwofaStatus(
          tfa == "google"
              ? 1
              : tfa == "email"
              ? 2
              : 0,
        );
        AppStorage.storeMPINStatus(mpinStatus);
        AppStorage.storeKYCStatus(kycStatus);
        AppStorage.storeRecoveryStatus(recoveryKeyStatus);
        AppStorage.storeAntiPhishingCodeStatus(antiPhishingCodeStatus);

        // Optionally store other values if needed
        AppStorage.storeUserName(name);
        AppStorage.storeUserEmail(email);
        AppStorage.storeProfileImage(profileImage);
        AppStorage.storeStatusLevel(tfaStatus);
      } else {
        // Extract error message
        String errorMessage = "";
        if (parsed['data'] != null && parsed['data'] is Map) {
          parsed['data'].forEach((key, value) {
            if (value != null) errorMessage += value.toString();
          });
        }

        if (errorMessage.isNotEmpty) {
          CustomAnimationToast.show(
            message: errorMessage,
            context: context,
            type: ToastType.error,
          );
        }
      }
    } catch (e) {
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }

    notifyListeners();
  }

  Future<void> getMarketOverview(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getCoinList();
      final parsed = json.decode(value.toString());
      setLoader(false);

      if (parsed["success"] == true) {
        final data = parsed["data"];

        topGainersList.clear();
        topLosersList.clear();
        newList.clear();
        hotSpotList.clear();

        // 🔹 Top Gainers
        if (data["topGainers"] != null) {
          for (var item in data["topGainers"]) {
            topGainersList.add(MarketCoinModel.fromJson(item));
          }
        }

        // 🔹 Top Losers
        if (data["topLosers"] != null) {
          for (var item in data["topLosers"]) {
            topLosersList.add(MarketCoinModel.fromJson(item));
          }
        }

        // 🔹 New List
        if (data["newList"] != null) {
          for (var item in data["newList"]) {
            newList.add(MarketCoinModel.fromJson(item));
          }
        }

        // 🔹 Hot Spot
        if (data["hotSpot"] != null) {
          for (var item in data["hotSpot"]) {
            hotSpotList.add(MarketCoinModel.fromJson(item));
          }
        }

        if (newList.length > 2) {
          newList = newList.take(2).toList();
        }

        // byTickerBitSocketCall();
        getTradePairs(context);
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

  Future<void> getDashboardData(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getDashboardData(); // <-- your API method
      final parsed = json.decode(value.toString());
      setLoader(false);

      if (parsed["success"] == true) {
        tradePairList.clear();
        pairs = "";
        tradeSocketPairs.clear();
        if (parsed["data"] != null &&
            parsed["data"]["user_wallet_details"] != null) {
          walletBalanceUSD =
              parsed["data"]["user_wallet_details"]["spot_balance_usd"];
          walletBalanceBTC =
              parsed["data"]["user_wallet_details"]["spot_balance_btc"];
        }
        notifyListeners();

        notifyListeners();
      } else {
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

  Future<void> getTradePairs(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getTradePairList(); // <-- your API method
      final parsed = json.decode(value.toString());
      setLoader(false);

      if (parsed["success"] == true) {
        tradePairList.clear();
        pairs = "";
        tradeSocketPairs.clear();
        if (parsed["data"]["tradePairs"].toString() != "[]") {
          for (var data in parsed["data"]["tradePairs"]) {
            if (data["liquidity_type"] == 'bybit') {
              tradeSocketPairs.add('"tickers.${data["liquidity_symbol"]}"');

              pairs = tradeSocketPairs.join(',');
            }

            tradePairList.add(
              TradePair(
                id: data["id"],
                coinOne: data["coin_one_liquidity"],
                coinTwo: data["coin_two_liquidity"],
                coinOneName: data["coin_one"]["coin_name"],
                coinTwoName: data["coin_two"]["coin_name"],
                image: data["coin_one"]["image"],
                coinOneDecimal: data["coin_one_decimal"],
                coinTwoDecimal: data["coin_two_decimal"],
                liquidityType: data["liquidityType"],
                liquiditySymbol: data["liquidity_type"],
                minBuyPrice: data["min_buy_price"].toString(),
                minBuyAmount: data["min_buy_amount"].toString(),
                minSellPrice: data["min_sell_price"].toString(),
                minSellAmount: data["min_sell_amount"].toString(),
                minBuyTotal: data["min_buy_total"].toString(),
                minSellTotal: data["min_sell_total"].toString(),
                livePrice: data["live_price"].toString(),
                volume24h: data["volume_24h"].toString(),
                change24hPercentage: data["change_24h_percentage"].toString(),
                isActive: data["is_active"],
              ),
            );
          }
          byTickerBitSocketCall(pairs);
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

  IOWebSocketChannel? spotTickerChannel;

  StreamController spotStreamController = StreamController.broadcast();

  ///Spot Ticker Socket
  Future<void> byTickerBitSocketCall(String pair) async {
    if (spotTickerChannel != null) spotTickerChannel!.sink.close();

    var params = '{"op": "subscribe","args": [${pair}]}';

    print("Socket Params ${params}");

    spotTickerChannel = IOWebSocketChannel.connect(
      Uri.parse(ApiEndpoints.SPOT_WEB_SOCKET_URL),
    );

    spotTickerChannel!.sink.add(params);
    spotTickerChannel!.stream.listen((event) {
      if (event != null) {
        spotStreamController.sink.add(event);
      }
      notifyListeners();
    });
  }

  void _showErrorToast(BuildContext context, String message) {
    CustomAnimationToast.show(
      context: context,
      message: message,
      type: ToastType.error,
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

class MarketCoinModel {
  String coinOne;
  String coinTwo;
  String coinOneType;
  String coinTwoType;
  String liquidityType;
  int isLiquidity;

  String image;
  String chart;

  int coinOneDecimal;
  int coinTwoDecimal;

  String last;
  String low;
  String high;
  String volume;

  String completedTradeType;
  String exchange;

  bool isFavorite;

  MarketCoinModel({
    required this.coinOne,
    required this.coinTwo,
    required this.coinOneType,
    required this.coinTwoType,
    required this.liquidityType,
    required this.isLiquidity,
    required this.image,
    required this.chart,
    required this.coinOneDecimal,
    required this.coinTwoDecimal,
    required this.last,
    required this.low,
    required this.high,
    required this.volume,
    required this.completedTradeType,
    required this.exchange,
    this.isFavorite = false,
  });

  factory MarketCoinModel.fromJson(Map<String, dynamic> json) {
    return MarketCoinModel(
      coinOne: json["coinOne"].toString(),
      coinTwo: json["coinTwo"].toString(),
      coinOneType: json["coinOneType"].toString(),
      coinTwoType: json["coinTwoType"].toString(),
      liquidityType: json["liquidityType"].toString(),
      isLiquidity: json["isLiquidity"] ?? 0,
      image: json["image"].toString(),
      chart: json["chart"].toString(),
      coinOneDecimal: json["coinOneDecimal"] ?? 0,
      coinTwoDecimal: json["coinTwoDecimal"] ?? 0,
      last: json["last"].toString(),
      low: json["low"].toString(),
      high: json["high"].toString(),
      volume: json["volume"].toString(),
      completedTradeType: json["completedTradeType"].toString(),
      exchange: json["exchange"].toString(),
    );
  }
}

class TradePair {
  int? id, coinOneDecimal, coinTwoDecimal, isActive;
  String? coinOne,
      coinTwo,
      coinOneName,
      coinTwoName,
      image,
      liquidityType,
      liquiditySymbol,
      minBuyPrice,
      minBuyAmount,
      minSellPrice,
      minSellAmount,
      minBuyTotal,
      minSellTotal,
      livePrice,
      volume24h,
      change24hPercentage;
  bool? isFavorite = false;
  TradePair({
    this.id,
    this.coinOne,
    this.coinTwo,
    this.coinOneName,
    this.coinTwoName,
    this.image,
    this.coinOneDecimal,
    this.coinTwoDecimal,
    this.liquidityType,
    this.liquiditySymbol,
    this.minBuyPrice,
    this.minBuyAmount,
    this.minSellPrice,
    this.minSellAmount,
    this.minBuyTotal,
    this.minSellTotal,
    this.livePrice,
    this.volume24h,
    this.change24hPercentage,
    this.isActive,
    this.isFavorite = false,
  });
}
