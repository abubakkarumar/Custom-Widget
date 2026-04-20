import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Dashboard/dashboard_api.dart';
import 'package:zayroexchange/Views/Bottom_Pages/History/history_api.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/wallet_api.dart';

/// Shared model for trade pairs across tabs.
class GlobalTradePair {
  final int id;
  final String coinOne;
  final String coinTwo;
  final String coinOneName;
  final String coinTwoName;
  final String image;
  final int coinOneDecimal;
  final int coinTwoDecimal;
  final String liquidityType;
  final String liquiditySymbol;
  final String minBuyPrice;
  final String minBuyAmount;
  final String minSellPrice;
  final String minSellAmount;
  final String minBuyTotal;
  final String minSellTotal;
  final String livePrice;
  final String volume24h;
  final String change24hPercentage;
  final bool isActive;

  GlobalTradePair({
    required this.id,
    required this.coinOne,
    required this.coinTwo,
    required this.coinOneName,
    required this.coinTwoName,
    required this.image,
    required this.coinOneDecimal,
    required this.coinTwoDecimal,
    required this.liquidityType,
    required this.liquiditySymbol,
    required this.minBuyPrice,
    required this.minBuyAmount,
    required this.minSellPrice,
    required this.minSellAmount,
    required this.minBuyTotal,
    required this.minSellTotal,
    required this.livePrice,
    required this.volume24h,
    required this.change24hPercentage,
    required this.isActive,
  });

  factory GlobalTradePair.fromJson(Map<String, dynamic> json) {
    return GlobalTradePair(
      id: json["id"],
      coinOne: json["coin_one_liquidity"],
      coinTwo: json["coin_two_liquidity"],
      coinOneName: json["coin_one"]["coin_name"],
      coinTwoName: json["coin_two"]["coin_name"],
      image: json["coin_one"]["image"],
      coinOneDecimal: json["coin_one_decimal"] ?? 0,
      coinTwoDecimal: json["coin_two_decimal"] ?? 0,
      liquidityType: json["liquidity_type"] ?? "",
      liquiditySymbol: json["liquidity_symbol"]?.toString() ?? "",
      minBuyPrice: json["min_buy_price"].toString(),
      minBuyAmount: json["min_buy_amount"].toString(),
      minSellPrice: json["min_sell_price"].toString(),
      minSellAmount: json["min_sell_amount"].toString(),
      minBuyTotal: json["min_buy_total"].toString(),
      minSellTotal: json["min_sell_total"].toString(),
      livePrice: json["live_price"].toString(),
      volume24h: json["volume_24h"].toString(),
      change24hPercentage: json["change_24h_percentage"].toString(),
      isActive: json["is_active"] ?? false,
    );
  }
}

/// Shared model for wallet totals and coins.
class GlobalWalletEntry {
  final int id;
  final String name;
  final String symbol;
  final String type;
  final String imageUrl;
  final String balance;
  final String freeBalance;
  final String escrowBalance;
  final int activeDeposit;
  final int activeWithdraw;

  GlobalWalletEntry({
    required this.id,
    required this.name,
    required this.symbol,
    required this.type,
    required this.imageUrl,
    required this.balance,
    required this.freeBalance,
    required this.escrowBalance,
    required this.activeDeposit,
    required this.activeWithdraw
  });
}

class GlobalWalletSummary {
  final double totalUsd;
  final double totalEur;
  final List<GlobalWalletEntry> wallets;

  GlobalWalletSummary({
    required this.totalUsd,
    required this.totalEur,
    required this.wallets,
  });
}

class GlobalOrderHistory {
  final int? id;
  final int? pair;
  final String? orderId;
  final String? symbol;
  final String? orderType;
  final String? side;
  final String? orderPrice;
  final String? avgPrice;
  final String? orderVolume;
  final String? filledVolume;
  final String? filledValue;
  final String? orderValue;
  final String? fee;
  final String? remainingVolume;
  final String? orderStatus;
  final String? createdAt;

  GlobalOrderHistory({
    this.id,
    this.pair,
    this.orderId,
    this.symbol,
    this.orderType,
    this.side,
    this.orderPrice,
    this.avgPrice,
    this.orderVolume,
    this.filledVolume,
    this.filledValue,
    this.orderValue,
    this.fee,
    this.remainingVolume,
    this.orderStatus,
    this.createdAt,
  });
}

class TradePairsNotifier extends AsyncNotifier<List<GlobalTradePair>> {
  @override
  Future<List<GlobalTradePair>> build() async {
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<List<GlobalTradePair>> _fetch() async {
    final response = await DashboardAPI().getTradePairList();
    final parsed = json.decode(response.toString());

    if (parsed["success"] == true) {
      final List<GlobalTradePair> pairs = [];
      for (final data in parsed["data"]["tradePairs"]) {
        pairs.add(GlobalTradePair.fromJson(data));
      }
      return pairs;
    }

    throw Exception(parsed["data"] ?? "Unable to fetch trade pairs");
  }
}

final tradePairsProvider =
    AsyncNotifierProvider<TradePairsNotifier, List<GlobalTradePair>>(
  TradePairsNotifier.new,
);

class WalletSummaryNotifier extends AsyncNotifier<GlobalWalletSummary> {
  @override
  Future<GlobalWalletSummary> build() async {
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<GlobalWalletSummary> _fetch() async {
    final response = await WalletApi().getWalletDetails();
    final parsed = json.decode(response.toString());
    print("Wallet api call global");
    if (parsed["success"] == true) {
      final data = parsed["data"] ?? {};
      final walletList = (data["wallet"] as List<dynamic>?) ?? [];
      print("Wallet api call global walletList $walletList");
      final List<GlobalWalletEntry> wallets = walletList.map((item) {
        final walletInfo = item["wallet"] ?? {};

        return GlobalWalletEntry(
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
        );
      }).toList();
      print("Wallet api call global after list");
      final double totalUsd =
          double.tryParse(data["total_usd"]?.toString() ?? "0.0") ?? 0.0;
      final double totalEur =
          double.tryParse(data["total_eur"]?.toString() ?? "0.0") ?? 0.0;
      print("Wallet api call global after total");
      return GlobalWalletSummary(
        totalUsd: totalUsd,
        totalEur: totalEur,
        wallets: wallets,
      );
    }

    throw Exception(parsed["data"] ?? "Unable to fetch wallet summary");
  }
}

final walletSummaryProvider =
    AsyncNotifierProvider<WalletSummaryNotifier, GlobalWalletSummary>(
  WalletSummaryNotifier.new,
);

class OrderHistoryNotifier extends AsyncNotifier<List<GlobalOrderHistory>> {
  @override
  Future<List<GlobalOrderHistory>> build() async {
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<List<GlobalOrderHistory>> _fetch() async {
    final response = await HistoryApi().getOrderOpenHistory({
      "category": "spot",
      "from_date": "",
      "to_date": "",
    });
    final parsed = json.decode(response.toString());

    if (parsed["success"] == true) {
      final List<GlobalOrderHistory> orders = [];
      for (final data in parsed['data']['transactions']) {
        if (data['orderStatus'].toString().toLowerCase() == "active") {
          orders.add(
            GlobalOrderHistory(
              id: data['id'],
              pair: data['pairId'],
              orderId: data['orderId'],
              symbol: data['symbol'],
              orderType: data['orderType'],
              side: data['side'],
              orderPrice: data['orderPrice']?.toString(),
              avgPrice: data['avgFilledPrice']?.toString(),
              orderVolume: data['orderVolume']?.toString(),
              filledVolume: data['filledVolume']?.toString(),
              filledValue: data['filledValue']?.toString(),
              orderValue: data['orderValue']?.toString(),
              fee: data['fee']?.toString(),
              remainingVolume: data['remainingVolume']?.toString(),
              orderStatus: data['orderStatus']?.toString(),
              createdAt: data['createdAt']?.toString(),
            ),
          );
        }
      }
      return orders;
    }

    throw Exception(parsed["data"] ?? "Unable to fetch open orders");
  }
}

final orderHistoryProvider =
    AsyncNotifierProvider<OrderHistoryNotifier, List<GlobalOrderHistory>>(
  OrderHistoryNotifier.new,
);
