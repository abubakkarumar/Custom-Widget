import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zayroexchange/Utility/global_state/global_providers.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/wallet_api.dart';

class WalletController with ChangeNotifier {
  WalletApi provider = WalletApi();

  bool isLoading = false;
  bool isSuccess = false;

  bool isSpotSelected = true;
  bool hideBalance = false;

  void setHideBalance(bool val) {
    hideBalance = val;
    notifyListeners();
  }

  // 🔹 totals as double (for SpotBalanceCard)
  double totalUsdValue = 0.0;
  double totalEurValue = 0.0;

  // 🔹 master list (full data from API)
  List<WalletDetails> allWalletDetailsList = [];

  // 🔹 per-coin list used for UI (filtered list)
  List<WalletDetails> walletDetailsList = [];

  // 🔹 expand/collapse
  int expandedIndex = -1; // -1 means nothing is expanded

  // 🔹 search state
  bool isSearchVisible = false;
  final TextEditingController searchController = TextEditingController();

  void setLoader(bool val) {
    isLoading = val;
    notifyListeners();
  }

  void toggleExpand(int index) {
    if (expandedIndex == index) {
      expandedIndex = -1; // collapse if tapped again
    } else {
      expandedIndex = index; // expand new one
    }
    notifyListeners();
  }

  // 🔹 toggle search bar visibility
  void toggleSearch() {
    isSearchVisible = !isSearchVisible;

    if (!isSearchVisible) {
      // when closing search, clear and reset list
      searchController.clear();
      walletDetailsList = allWalletDetailsList;
    }

    notifyListeners();
  }

  // 🔹 filter by coin name or symbol``
  void filterCoins(String query) {
    if (query.isEmpty) {
      walletDetailsList = allWalletDetailsList;
    } else {
      final lower = query.toLowerCase();
      walletDetailsList = allWalletDetailsList.where((coin) {
        return coin.name.toLowerCase().contains(lower) ||
            coin.symbol.toLowerCase().contains(lower);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> getWalletDetails(BuildContext context) async {
    setLoader(true);

    try {
      final response = await provider.getWalletDetails();
      setLoader(false);
      final parsed = json.decode(response.toString());

      if (parsed["success"] == true) {
        isSuccess = true;

        allWalletDetailsList.clear();
        walletDetailsList.clear();
        print("Wallet api call init");
        final data = parsed["data"] ?? {};
        print("Wallet api call data");
        // 🔥 wallet list
        final walletList = (data["wallet"] as List<dynamic>?) ?? [];
        print("Wallet api call list");
        // 🔥 totals (same for all coins) – kept as String + parsed to double
        final String totalUsdString = data["total_usd"]?.toString() ?? "0.00";
        final String totalEurString = data["total_eur"]?.toString() ?? "0.00";

        // 🔥 usable in SpotBalanceCard as double
        totalUsdValue = double.tryParse(totalUsdString) ?? 0.0;
        totalEurValue = double.tryParse(totalEurString) ?? 0.0;
        print("Wallet api call before");
        for (var item in walletList) {
          final walletInfo = item["wallet"] ?? {};

          print("Wallet api call $item");

          allWalletDetailsList.add(
            WalletDetails(
              id: item["id"] ?? 0,
              name: item["name"]?.toString() ?? "",
              symbol: item["symbol"]?.toString() ?? "",
              type: item["type"]?.toString() ?? "",
              imageUrl: item["image_url"]?.toString() ?? "",
              balance: walletInfo["balance"]?.toString() ?? "0.00",
              freeBalance: walletInfo["free_balance"]?.toString() ?? "0.00",
              escrowBalance: walletInfo["escrow_balance"]?.toString() ?? "0.00",
              activeDeposit: (item['settings'] != null && item['settings'].runtimeType == List<dynamic>) ?
              item['settings'].toString() != "[]" ?
              item['settings'][0]['activate_deposit'] : 1 : 0,
              activeWithdraw: (item['settings'] != null && item['settings'].runtimeType == List<dynamic>) ?
              item['settings'].toString() != "[]" ?
              item['settings'][0]['activate_withdraw'] : 1 : 0,
              // 🔥 same totals stored per item as String (if you still want them)
              totalUsd: totalUsdString,
              totalEur: totalEurString,
            ),
          );

          print("Wallet api call done");
        }

        // initially show all
        walletDetailsList = List<WalletDetails>.from(allWalletDetailsList);

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

  /// Hydrate wallet data from Riverpod cache to avoid duplicate network calls.
  void applyWalletSummary(GlobalWalletSummary summary) {
    totalUsdValue = summary.totalUsd;
    totalEurValue = summary.totalEur;

    allWalletDetailsList = summary.wallets
        .map(
          (entry) => WalletDetails(
            id: entry.id,
            name: entry.name,
            symbol: entry.symbol,
            type: entry.type,
            imageUrl: entry.imageUrl,
            balance: entry.balance,
            freeBalance: entry.freeBalance,
            escrowBalance: entry.escrowBalance,
            totalUsd: summary.totalUsd.toString(),
            totalEur: summary.totalEur.toString(),
            activeDeposit: entry.activeDeposit,
            activeWithdraw: entry.activeWithdraw
          ),
        )
        .toList();

    walletDetailsList = List<WalletDetails>.from(allWalletDetailsList);
    isSuccess = true;
    notifyListeners();
  }

  //////////////////////////////// Future Trade ///////////////////////////////////
  bool isFutureSearchVisible = false;
  final TextEditingController futureSearchController = TextEditingController();

  // 🔹 toggle search bar visibility
  void futureToggleSearch() {
    isFutureSearchVisible = !isFutureSearchVisible;

    if (!isFutureSearchVisible) {
      // when closing search, clear and reset list
      futureSearchController.clear();
      allFutureWalletList = allFutureWalletList;
    }

    notifyListeners();
  }

  // 🔹 filter by coin name or symbol
  void futureFilterCoins(String query) {
    if (query.isEmpty) {
      futureWalletList = allFutureWalletList;
    } else {
      final lower = query.toLowerCase();
      futureWalletList = allFutureWalletList.where((coin) {
        return coin.name.toLowerCase().contains(lower) ||
            coin.symbol.toLowerCase().contains(lower);
      }).toList();
    }
    notifyListeners();
  }

  List<FutureWalletDetails> allFutureWalletList = [];
  List<FutureWalletDetails> futureWalletList = [];

  double totalFutureUsdValue = 0.0;
  double totalFutureBtcValue = 0.0;

  Future<void> getFutureWalletDetails(BuildContext context) async {
    setLoader(true);

    try {
      final response = await provider.getFutureWalletDetails();
      setLoader(false);
      final parsed = json.decode(response.toString());

      if (parsed["success"] == true) {
        isSuccess = true;

        allFutureWalletList.clear();
        futureWalletList.clear();

        final data = parsed["data"] ?? {};
        final walletList = (data["wallet"] as List<dynamic>?) ?? [];

        // 🔥 global totals
        final String estimatedUsd = data["estimated_usd"]?.toString() ?? "0.00";
        final String estimatedBtc =
            data["estimated_btc"]?.toString() ?? "0.00000000";

        totalFutureUsdValue = double.tryParse(estimatedUsd) ?? 0.0;
        totalFutureBtcValue = double.tryParse(estimatedBtc) ?? 0.0;

        for (var item in walletList) {
          final walletInfo = item["wallet"] ?? {};

          allFutureWalletList.add(
            FutureWalletDetails(
              id: item["id"] ?? 0,
              name: item["coin_name"]?.toString() ?? "",
              symbol: item["coin_symbol"]?.toString() ?? "",
              type: item["coin_type"]?.toString() ?? "",
              imageUrl: item["image_url"]?.toString() ?? "",

              balance: walletInfo["balance"]?.toString() ?? "0.00",
              escrowBalance: walletInfo["escrow_balance"]?.toString() ?? "0.00",
              totalBalance: walletInfo["total_balance"]?.toString() ?? "0.00",

              usdValue: item["usd_value"]?.toString() ?? "0.00",

              estimatedUsd: estimatedUsd,
              estimatedBtc: estimatedBtc,
            ),
          );
        }

        // 🔥 show all by default
        futureWalletList = List<FutureWalletDetails>.from(allFutureWalletList);

        notifyListeners();
      } else {
        if (!context.mounted) return;
        _showParsedError(context, parsed, ["message"]);
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

class WalletDetails {
  final int id;
  final String name;
  final String symbol;
  final String type;
  final String imageUrl;

  final String balance;
  final String freeBalance;
  final String escrowBalance;

  // 🔥 new fields (kept as String, directly from API)
  final String totalUsd;
  final String totalEur;
  final int activeDeposit;
  final int activeWithdraw;


  WalletDetails({
    required this.id,
    required this.name,
    required this.symbol,
    required this.type,
    required this.imageUrl,
    required this.balance,
    required this.freeBalance,
    required this.escrowBalance,
    required this.totalUsd,
    required this.totalEur,
    required this.activeDeposit,
    required this.activeWithdraw
  });
}

class FutureWalletDetails {
  final int id;
  final String name;
  final String symbol;
  final String type;
  final String imageUrl;

  final String balance;
  final String escrowBalance;
  final String totalBalance;

  final String usdValue;

  // global totals
  final String estimatedUsd;
  final String estimatedBtc;

  FutureWalletDetails({
    required this.id,
    required this.name,
    required this.symbol,
    required this.type,
    required this.imageUrl,
    required this.balance,
    required this.escrowBalance,
    required this.totalBalance,
    required this.usdValue,
    required this.estimatedUsd,
    required this.estimatedBtc,
  });
}
