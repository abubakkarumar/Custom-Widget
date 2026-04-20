import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Market/market_api.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../../../Utility/Basics/api_endpoints.dart';
import '../Dashboard/dashboard_controller.dart';

class MarketController with ChangeNotifier {
  MarketApi provider = MarketApi();

  Timer? autoScrollTimer;
  bool isAutoScrollingBack = false;

  bool isLoading = false;

  IOWebSocketChannel? spotTickerChannel;

  StreamController spotStreamController = StreamController.broadcast();
  final searchController = TextEditingController();
  setLoader(bool val) {
    isLoading = val;
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

  List<MarketCoinModel> topGainersListFilter = [];
  List<MarketCoinModel> topLosersListFilter = [];
  List<MarketCoinModel> newListFilter = [];
  List<MarketCoinModel> hotSpotListFilter = [];

  List<TradePair> tradePairList = [];
  List<TradePair> usdtTradePairList = [];
  List<TradePair> linkTradePairList = [];

  List<TradePair> favTradePairList = [];

  List<String> tradeSocketPairs = <String>[];
  String pairs = '';
  // void toggleFavorite(int index) {
  //   allList[index].isFavorite = !allList[index].isFavorite;
  //   notifyListeners();
  // }

  void changeTab(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  searchTradePairs(String val) {
    print("searchTradePaird");
    if (val.isNotEmpty) {
      hotSpotListFilter = hotSpotList
          .where(
            (item) =>
                item.coinOne.toString().toLowerCase().contains(
                  val.toLowerCase(),
                ) ||
                item.coinTwo.toString().toLowerCase().contains(
                  val.toLowerCase(),
                ),
          )
          .toList();

      topGainersListFilter = topGainersList
          .where(
            (item) =>
                item.coinOne.toString().toLowerCase().contains(
                  val.toLowerCase(),
                ) ||
                item.coinTwo.toString().toLowerCase().contains(
                  val.toLowerCase(),
                ),
          )
          .toList();

      topLosersListFilter = topLosersList
          .where(
            (item) =>
                item.coinOne.toString().toLowerCase().contains(
                  val.toLowerCase(),
                ) ||
                item.coinTwo.toString().toLowerCase().contains(
                  val.toLowerCase(),
                ),
          )
          .toList();

      newListFilter = newList
          .where(
            (item) =>
                item.coinOne.toString().toLowerCase().contains(
                  val.toLowerCase(),
                ) ||
                item.coinTwo.toString().toLowerCase().contains(
                  val.toLowerCase(),
                ),
          )
          .toList();

      notifyListeners();
    } else {
      resetFilters();
    }
  }

  resetFilters() {
    searchController.clear();

    hotSpotListFilter = hotSpotList;

    topGainersListFilter = topGainersList;

    topLosersListFilter = topLosersList;

    newListFilter = newList;

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
        topGainersListFilter.clear();
        topLosersListFilter.clear();
        newListFilter.clear();
        hotSpotListFilter.clear();
        notifyListeners();

        // 🔹 Top Gainers
        // if (data["topGainers"] != null) {
        //   for (var item in data["topGainers"]) {
        //     topGainersList.add(MarketCoinModel.fromJson(item));
        //     topGainersListFilter.add(MarketCoinModel.fromJson(item));
        //
        //   }
        // }

        final Map<String, MarketCoinModel> topGainersMap = {};

        if (data["topLosers"] != null) {
          for (var item in data["topLosers"]) {
            final model = MarketCoinModel.fromJson(item);
            final key = model.pairId; // or id

            if (key != null) {
              topGainersMap[key.toString()] = model; // replaces duplicates
            }
          }

          topGainersList = topGainersMap.values.toList();
          topGainersListFilter = List.from(topGainersList);
          topGainersList.sort((a, b) => b.last.compareTo(a.last));
          topGainersListFilter.sort((a, b) => b.last.compareTo(a.last));
        }

        // 🔹 Top Losers
        // if (data["topLosers"] != null) {
        //   for (var item in data["topLosers"]) {
        //     topLosersList.add(MarketCoinModel.fromJson(item));
        //     topLosersListFilter.add(MarketCoinModel.fromJson(item));
        //   }
        // }

        final Map<String, MarketCoinModel> topLosersMap = {};

        if (data["topLosers"] != null) {
          for (var item in data["topLosers"]) {
            final model = MarketCoinModel.fromJson(item);
            final key = model.pairId; // or id

            if (key != null) {
              topLosersMap[key.toString()] = model; // replaces duplicates
            }
          }

          topLosersList = topLosersMap.values.toList();
          topLosersListFilter = List.from(topLosersList);
          topLosersList.sort((a, b) => a.last.compareTo(b.last));
          topLosersListFilter.sort((a, b) => a.last.compareTo(b.last));
        }

        // 🔹 New List
        // if (data["newList"] != null) {
        //   for (var item in data["newList"]) {
        //     newList.add(MarketCoinModel.fromJson(item));
        //     newListFilter.add(MarketCoinModel.fromJson(item));
        //   }
        // }
        final Map<String, MarketCoinModel> newListMap = {};

        if (data["newList"] != null) {
          for (var item in data["newList"]) {
            final model = MarketCoinModel.fromJson(item);
            final key = model.pairId; // or id

            if (key != null) {
              newListMap[key.toString()] = model; // replaces duplicates
            }
          }

          newList = newListMap.values.toList();
          if (newList.length > 2) {
            newList = newList.take(2).toList();
          }

          newListFilter = List.from(newList);
        }

        // 🔹 Hot Spot
        // if (data["hotSpot"] != null) {
        //   for (var item in data["hotSpot"]) {
        //     hotSpotList.add(MarketCoinModel.fromJson(item));
        //     hotSpotListFilter.add(MarketCoinModel.fromJson(item));
        //   }
        // }

        final Map<String, MarketCoinModel> hotSpotMap = {};

        if (data["hotSpot"] != null) {
          for (var item in data["hotSpot"]) {
            final model = MarketCoinModel.fromJson(item);
            final key = model.pairId; // or id

            if (key != null) {
              hotSpotMap[key.toString()] = model; // replaces duplicates
            }
          }

          hotSpotList = hotSpotMap.values.toList();
          hotSpotListFilter = List.from(hotSpotList);

          hotSpotList.sort((a, b) => b.last.compareTo(a.last));
          hotSpotListFilter.sort((a, b) => b.last.compareTo(a.last));
        }

        print(
          "MARKET DATA ${hotSpotList.length} ${hotSpotListFilter.length} ${(data["hotSpot"] as List).length}",
        );

        getFavTradePairs(context);
        // byTickerBitSocketCall();
        getTradePairs(context);

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

  Future<void> getTradePairs(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getTradePairList(); // <-- your API method
      final parsed = json.decode(value.toString());
      setLoader(false);

      if (parsed["success"] == true) {
        tradePairList.clear();
        usdtTradePairList.clear();
        linkTradePairList.clear();
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

            if (data['coin_two_liquidity'].toString().toLowerCase() == "usdt") {
              usdtTradePairList.add(
                TradePair(
                  id: data["id"],
                  coinOne: data["coin_one_liquidity"],
                  coinTwo: data["coin_two_liquidity"],
                  coinOneName: data["coin_one"]["coin_name"],
                  coinTwoName: data["coin_two"]["coin_name"],
                  image: data["coin_one"]["image"],
                  coinOneDecimal: data["coin_one_decimal"],
                  coinTwoDecimal: data["coin_two_decimal"],
                  liquidityType: data["liquidity_type"],
                  liquiditySymbol: data["liquidity_symbol"],
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

            if (data['coin_two_liquidity'].toString().toLowerCase() == "link") {
              linkTradePairList.add(
                TradePair(
                  id: data["id"],
                  coinOne: data["coin_one_liquidity"],
                  coinTwo: data["coin_two_liquidity"],
                  coinOneName: data["coin_one"]["coin_name"],
                  coinTwoName: data["coin_two"]["coin_name"],
                  image: data["coin_one"]["image"],
                  coinOneDecimal: data["coin_one_decimal"],
                  coinTwoDecimal: data["coin_two_decimal"],
                  liquidityType: data["liquidity_type"],
                  liquiditySymbol: data["liquidity_symbol"],
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
          }
          byTickerBitSocketCall(pairs);
        }
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

  Future removeFav({
    required BuildContext context,
    required String id,
    required MarketCoinModel item,
  }) async {
    item.isFavorite = false;
    final index = topGainersListFilter.indexWhere(
      (e) => e.pairId == item.pairId,
    );

    if (index != -1) {
      topGainersListFilter[index].isFavorite = false;
    }

    final topLoserIndex = topLosersListFilter.indexWhere(
      (e) => e.pairId == item.pairId,
    );

    if (topLoserIndex != -1) {
      topLosersListFilter[topLoserIndex].isFavorite = false;
    }

    final newIndex = newListFilter.indexWhere((e) => e.pairId == item.pairId);

    if (newIndex != -1) {
      newListFilter[newIndex].isFavorite = false;
    }

    final hotspotIndex = hotSpotListFilter.indexWhere(
      (e) => e.pairId == item.pairId,
    );

    if (hotspotIndex != -1) {
      hotSpotListFilter[hotspotIndex].isFavorite = false;
    }

    notifyListeners();

    setLoader(true);

    FormData data = FormData.fromMap({"category": "spot", "pair_id": id});

    await provider
        .removeFav(data)
        .then((value) {
          setLoader(false);
          var response = json.decode(value.toString());

          if (response['success']) {
            _showSuccessToast(context, response['message']);
            getFavTradePairs(context);
            notifyListeners();
          } else {
            FocusScope.of(context).requestFocus(FocusNode());
            _showParsedError(context, response, ["error"]);
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
  }

  Future addFav({
    required BuildContext context,
    required String id,
    required MarketCoinModel item,
  }) async {
    item.isFavorite = true;

    notifyListeners();

    FormData data = FormData.fromMap({"category": "spot", "pair_id": id});

    await provider
        .addFav(data)
        .then((value) {
          setLoader(false);
          var response = json.decode(value.toString());

          if (response['success']) {
            _showSuccessToast(context, response['message']);
            getFavTradePairs(context);
            notifyListeners();
          } else {
            FocusScope.of(context).requestFocus(FocusNode());
            _showParsedError(context, response, ["error"]);
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
  }

  void _showSuccessToast(BuildContext context, String message) {
    CustomAnimationToast.show(
      context: context,
      message: message,
      type: ToastType.success,
    );
  }

  Future<void> getFavTradePairs(BuildContext context) async {
    // setLoader(true);
    FormData data = FormData.fromMap({"category": "spot"});

    try {
      final value = await provider.getFavList(data);

      final parsed = json.decode(value.toString());
      setLoader(false);

      print("Parsed Trade Pairs: ${parsed["data"]["favoritePairs"]}");

      if (parsed["success"] == true) {
        favTradePairList.clear();

        if (parsed["data"]["favoritePairs"].toString() != "[]") {
          for (var data in parsed["data"]["favoritePairs"]) {
            favTradePairList.add(
              TradePair(
                id: data["id"],
                coinOne: data["coin_one_liquidity"],
                coinTwo: data["coin_two_liquidity"],
                coinOneName: data["coin_one"]["coin_name"],
                coinTwoName: data["coin_two"]["coin_name"],
                image: data["coin_one"]["image"],
                coinOneDecimal: data["coin_one_decimal"],
                coinTwoDecimal: data["coin_two_decimal"],
                liquidityType: data["liquidity_type"],
                liquiditySymbol: data["liquidity_symbol"],
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
                isFavorite: true,
              ),
            );
          }
        }

        notifyListeners();

        if (favTradePairList.isNotEmpty && hotSpotListFilter.isNotEmpty) {
          for (var element in hotSpotListFilter) {
            for (var favElement in favTradePairList) {
              print("Fav HOTSPOT ${element.pairId} == ${favElement.id}");
              if (element.pairId == favElement.id) {
                element.isFavorite = true;
                notifyListeners();
              }
            }
          }
        }

        if (favTradePairList.isNotEmpty && topGainersListFilter.isNotEmpty) {
          for (var element in topGainersListFilter) {
            for (var favElement in favTradePairList) {
              print("Fav TOPGAINERS ${element.pairId} == ${favElement.id}");
              if (element.pairId == favElement.id) {
                element.isFavorite = true;
                notifyListeners();
              }
            }
          }
        }

        if (favTradePairList.isNotEmpty && topLosersListFilter.isNotEmpty) {
          for (var element in topLosersListFilter) {
            for (var favElement in favTradePairList) {
              print("Fav TOPLOSERS ${element.pairId} == ${favElement.id}");
              if (element.pairId == favElement.id) {
                element.isFavorite = true;
                notifyListeners();
              }
            }
          }
        }

        if (favTradePairList.isNotEmpty && newListFilter.isNotEmpty) {
          for (var element in newListFilter) {
            for (var favElement in favTradePairList) {
              print("Fav NEWLIST ${element.pairId} == ${favElement.id}");
              if (element.pairId == favElement.id) {
                element.isFavorite = true;
                notifyListeners();
              }
            }
          }
        }
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
}

class MarketCoinModel {
  int pairId;
  String coinOne;
  String coinTwo;
  String coinOneType;
  String coinTwoType;
  String liquidityType;
  int isLiquidity;
  String coinOneName;

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
    required this.pairId,
    required this.coinOneName,
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
      pairId: json["pairId"],
      coinOneName: json["coinOneName"],
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
