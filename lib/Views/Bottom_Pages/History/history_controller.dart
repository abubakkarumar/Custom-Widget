import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/Utility/global_state/global_providers.dart';
import '../future_trade/future_trade/future_trade_controller.dart';
import 'history_api.dart';

class HistoryController extends ChangeNotifier {
  // ================= STATE =================
  CoinModel? selectedCoin;
  TradePair? selectedTradeCoin;
  FutureTradePairList? selectedFutureTradePair;
  String selectedTransferPair='All';
  int selectedTab = 0;

  DateTime? startDate;
  DateTime? endDate;

  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  bool isLoading = false;

  final HistoryApi provider = HistoryApi();

  // ================= DATA =================
  List<CoinModel> coinList = [];
  List<TradePair> tradePairList = [];
  List<String> transferCoinList = ["All","USDT","USDC"];

  List<DepositHistoryModel> depositHistoryList = [];
  List<WithdrawHistoryModel> withdrawHistoryList = [];
  List<TransferHistoryModel> transferHistoryList = [];
  List<TradeOrderHistoryModel> tradeOrderHistoryList = [];
  List<OrderHistoryModel> openOrderHistoryList = [];

  List<FutureOpenOrdersList> futuresOpenOrdersList = [];
  List<FuturePnLHistoryList> futuresPnLHistoryList = [];
  List<FutureMyOrdersList> futuresMyOrdersList = [];

  // ================= GET TRADE PAIR STRING =================
  String get selectedTradePair {
    final pair = selectedTradeCoin;
    if (pair == null) return "";
    return "${pair.coinOne}/${pair.coinTwo}";
  }

  // ================= TAB CHANGE =================
  void changeTab(
    int index,
    BuildContext context,
    FutureTradeController futureTradeController,
  ) {
    if (selectedTab == index) return;

    selectedTab = index;

    // reset filters only
    selectedCoin = null;
    selectedTradeCoin = null;
    startDate = null;
    endDate = null;

    startDateController.clear();
    endDateController.clear();

    notifyListeners();

    submitHistory(context, "", "", futureTradeController);
  }

  // ================= FILTER SUBMIT =================
  Future<void> submitHistory(
    BuildContext context,
    String searchCoin,
    String tradeSearchCoin,
    FutureTradeController futureTradeController,
  ) async {
    if (isLoading) return;

    switch (selectedTab) {
      case 0:
        await getDepositHistory(context, searchCoin);
        break;

      case 1:
        await getWithdrawHistory(context, searchCoin);
        break;

      case 2:
        await getTransferHistory(context, selectedTransferPair);
        break;

      case 3:
        await getTradePairs(context);
        await getTradeOrderHistory(context, tradeSearchCoin);
        break;
      case 4:
        await getTradePairs(context);
        await getOpenOrderHistory(context, searchCoin);
        break;

      case 5:
        await getFutureOpenOrders();
        break;
      case 6:
        await getFutureMyOrders();
        break;
      case 7:
        await getFuturePNLOrders();
        break;
    }
  }

  // ================= DATE =================
  void setStartDate(DateTime date) {
    startDate = date;
    startDateController.text = _formatDate(date);
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    endDate = date;
    endDateController.text = _formatDate(date);
    notifyListeners();
  }

  // ================= COIN =================
  void setSelectedCoin(CoinModel coin) {
    selectedCoin = coin;
    notifyListeners();
  }

  void setSelectedTradeCoin(TradePair tradeCoin) {
    selectedTradeCoin = tradeCoin;
    notifyListeners();
  }
  void clearSelectedTradeCoin() {
    selectedTradeCoin = null;
    notifyListeners();
  }
  void setSelectedTransferPair(String tradeCoin) {
    selectedTransferPair = tradeCoin;
    notifyListeners();
  }

  void setSelectedFutureTradeCoin(FutureTradePairList tradeCoin) {
    selectedFutureTradePair = tradeCoin;
    notifyListeners();
  }

  // ================= CLEAR FILTER =================
  void clearFilters(
    BuildContext context,
    FutureTradeController futureController,
  ) {
    selectedCoin = null;
    selectedTradeCoin = null;
    startDate = null;
    endDate = null;
    selectedFutureTradePair = null;
    selectedTransferPair='All';


    startDateController.clear();
    endDateController.clear();

    notifyListeners();

    submitHistory(context, "", "", futureController);
  }

  // ================= LOADER =================
  void setLoader(bool value) {
    if (isLoading == value) return;
    isLoading = value;
    notifyListeners();
  }

  // ================= COINS =================
  Future<void> getCoins(BuildContext context) async {
    setLoader(true);
    try {
      final value = await provider.getCoinList();
      setLoader(false);
      final parsed = json.decode(value.toString());

      if (parsed["success"] == true) {
        coinList.clear();
        for (var item in parsed["data"]) {
          coinList.add(
            CoinModel(
              id: item["id"] ?? 0,
              name: item["name"] ?? "",
              symbol: item["symbol"] ?? "",
              type: item["type"] ?? "",
              decimalPlaces: item["decimal_places"] ?? 0,
              network: [],
              imageUrl: item["image_url"] ?? "",
            ),
          );
        }
        notifyListeners();
      } else {
        setLoader(false);
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['error'],
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

  // ================= TRADE PAIRS =================
  Future<void> getTradePairs(BuildContext context) async {
    setLoader(true);
    try {
      final value = await provider.getTradePairList();
      setLoader(false);
      final parsed = json.decode(value.toString());

      if (parsed["success"] == true) {
        tradePairList.clear();
        for (var data in parsed["data"]["tradePairs"]) {
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
              isActive: data["is_active"],
            ),
          );
        }
        notifyListeners();
      } else {
        setLoader(false);
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['error'],
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

  /// Hydrate trade pairs from the Riverpod cache to avoid repeat fetches.
  void applyTradePairsFromGlobal(List<GlobalTradePair> pairs) {
    tradePairList = pairs
        .map(
          (data) => TradePair(
            id: data.id,
            coinOne: data.coinOne,
            coinTwo: data.coinTwo,
            coinOneName: data.coinOneName,
            coinTwoName: data.coinTwoName,
            image: data.image,
            coinOneDecimal: data.coinOneDecimal,
            coinTwoDecimal: data.coinTwoDecimal,
            isActive: data.isActive ? 1 : 0,
          ),
        )
        .toList();
    notifyListeners();
  }

  // ================= DEPOSIT =================
  Future<void> getDepositHistory(BuildContext context, String coin) async {
    setLoader(true);
    try {
      final value = await provider.getDepositHistory({
        "offset": "0",
        "limit": "10",
        "from_date": _dateOrEmpty(startDate),
        "to_date": _dateOrEmpty(endDate),
        "coin": coin,
      });
      setLoader(false);
      final parsed = json.decode(value.toString());

      if (parsed["success"] == true) {
        depositHistoryList.clear();
        for (var item in parsed["data"]["transactions"]) {
          depositHistoryList.add(
            DepositHistoryModel(
              txnId: item["txn_id"] ?? "",
              coin: item["coin"] ?? "",
              coinName: item["coin_name"] ?? "",
              sender: item["sender"] ?? "",
              receiver: item["receiver"] ?? "",
              network: item["network"] ?? "",
              type: item["type"] ?? "",
              status: item["status"] ?? 0,
              remark: item["remark"] ?? "",
              createdAt: item["created_at"] ?? "",
              amount: item["amount"] ?? "0",
              total: item["total"] ?? "0",
              fee: item["fee"] ?? "0",
              proof: item["proof"] ?? "",
              imageUrl: item["image_url"] ?? "",
            ),
          );
        }
        notifyListeners();
      } else {
        setLoader(false);
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['error'],
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

  // ================= WITHDRAW =================
  Future<void> getWithdrawHistory(BuildContext context, String coin) async {
    setLoader(true);
    try {
      final value = await provider.getWithdrawHistory({
        "offset": "0",
        "limit": "10",
        "from_date": _dateOrEmpty(startDate),
        "to_date": _dateOrEmpty(endDate),
        "coin": coin,
      });
      setLoader(false);
      final parsed = json.decode(value.toString());

      if (parsed["success"] == true) {
        withdrawHistoryList.clear();
        for (var item in parsed["data"]["rows"]) {
          withdrawHistoryList.add(
            WithdrawHistoryModel(
              id: item["id"],
              userId: item["user_id"],
              txnId: item["txn_id"] ?? "",
              coin: item["coin"] ?? "",
              sender: item["sender"] ?? "",
              receiver: item["receiver"] ?? "",
              network: item["network"] ?? "",
              type: item["type"] ?? "",
              amount: item["amount"] ?? "0",
              fee: item["fee"].toString(),
              total: item["total"].toString(),
              status: item["status"] ?? 0,
              remark: item["remark"] ?? "",
              createdAt: item["created_at"] ?? "",
            ),
          );
        }
        notifyListeners();
      } else {
        setLoader(false);
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['error'],
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

  // ================= TRANSFER =================
  Future<void> getTransferHistory(BuildContext context, String coin) async {
    setLoader(true);
    try {
      final value = await provider.getTransferHistory({
        "offset": "0",
        "limit": "10",
        "from_date": _dateOrEmpty(startDate),
        "to_date": _dateOrEmpty(endDate),
        if(coin.toLowerCase() != "all")
        "coin": coin,
      });
      setLoader(false);
      final parsed = json.decode(value.toString());

      if (parsed["success"] == true) {
        transferHistoryList.clear();
        for (var item in parsed["data"]["transactions"]) {
          transferHistoryList.add(
            TransferHistoryModel(
              id: item["id"],
              amount: item["amount"].toString(),
              balance: item["balance"].toString(),
              currency: item["currency"].toString(),
              from: item["from"].toString(),
              to: item["to"].toString(),
              type: item["type"].toString(),
              createdAt: item["created_at"].toString(),
            ),
          );
        }
        notifyListeners();
      } else {
        setLoader(false);
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['error'],
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

  // ================= TRADE ORDER =================
  Future<void> getTradeOrderHistory(BuildContext context, String coin) async {
    setLoader(true);
    try {
      final value = await provider.getOrderOpenHistory({
        "category": "spot",
        "from_date": _dateOrEmpty(startDate),
        "to_date": _dateOrEmpty(endDate),
      });
      setLoader(false);
      final parsed = json.decode(value.toString());

      if (parsed["success"] == true) {
        tradeOrderHistoryList.clear();

        for (var data in parsed["data"]["transactions"]) {
          tradeOrderHistoryList.add(
            TradeOrderHistoryModel(
              id: data['id'],
              pair: data['pairId'],
              orderId: data['orderId'],
              symbol: data['symbol'],
              orderType: data['orderType'],
              side: data['side'],
              price: data['orderPrice'].toString(),
              avgPrice: data['avgFilledPrice'].toString(),
              qty: data['orderVolume'],
              filledVolume: data['filledVolume'].toString(),
              filledValue: data['filledValue'].toString(),
              orderValue: data['orderValue'].toString(),
              fee: data['fee'],
              remainingQty: data['remainingVolume'],
              orderStatus: data['orderStatus'],
              createdAt: updateDateTimeFormat(data['createdAt'].toString()),
            ),
          );
        }

        /// 🔥 LOCAL FILTER BY TRADE PAIR
        if (selectedTradeCoin != null) {
          tradeOrderHistoryList = tradeOrderHistoryList.where((e) {
            return e.symbol == selectedTradePair;
          }).toList();
        }

        notifyListeners();
      } else {
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['category', 'from_date', 'to_date', 'error'],
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

  // ================= OPEN TRADE ORDER =================

  Future<void> getOpenOrderHistory(BuildContext context, String coin) async {
    setLoader(true);
    try {
      final value = await provider.getOrderOpenHistory({
        "category": "spot",
        "from_date": _dateOrEmpty(startDate),
        "to_date": _dateOrEmpty(endDate),
        if(selectedTradeCoin!=null)
          "pair":selectedTradeCoin?.id.toString()
      });
      var ii = {
        "category": "spot",
        "from_date": _dateOrEmpty(startDate),
        "to_date": _dateOrEmpty(endDate),
        if(selectedTradeCoin!=null)
          "pair":selectedTradeCoin?.id.toString()
      };
      print("FormData Open ${ii}");
      setLoader(false);
      final parsed = json.decode(value.toString());

      if (parsed["success"] == true) {
        openOrderHistoryList.clear();
        for (var data in parsed['data']['transactions']) {
          if (data['orderStatus'].toString().toLowerCase() == "active") {
            openOrderHistoryList.add(
              OrderHistoryModel(
                id: data['id'],
                pair: data['pairId'],
                orderId: data['orderId'],
                symbol: data['symbol'],
                orderType: data['orderType'],
                side: data['side'],
                price: data['orderPrice'].toString(),
                avgPrice: data['avgFilledPrice'].toString(),
                qty: data['orderVolume'],
                filledVolume: data['filledVolume'].toString(),
                filledValue: data['filledValue'].toString(),
                orderValue: data['orderValue'].toString(),
                fee: data['fee'],
                remainingQty: data['remainingVolume'],
                orderStatus: data['orderStatus'],
                createdAt: updateDateTimeFormat(data['createdAt'].toString()),
              ),
            );
          }
        }
        notifyListeners();
      } else {
        AppToast.show(
          context: context,
          parsedResponse: parsed,
          errorKeys: ['error'],
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

  /// Hydrate open orders from Riverpod cache to avoid repeat fetches.
  void applyOpenOrdersFromGlobal(List<GlobalOrderHistory> orders) {
    openOrderHistoryList = orders
        .map(
          (data) => OrderHistoryModel(
            id: data.id,
            pair: data.pair,
            orderId: data.orderId,
            symbol: data.symbol,
            orderType: data.orderType,
            side: data.side,
            price: data.orderPrice,
            avgPrice: data.avgPrice,
            qty: data.orderVolume,
            filledVolume: data.filledVolume,
            filledValue: data.filledValue,
            orderValue: data.orderValue,
            fee: data.fee,
            remainingQty: data.remainingVolume,
            orderStatus: data.orderStatus,
            createdAt: data.createdAt,
          ),
        )
        .toList();
    notifyListeners();
  }

  Future getFutureOpenOrders() async {
    await provider
        .getFutureOpenOrdersHistory({
          "pair": selectedFutureTradePair != null
              ? selectedFutureTradePair!.id.toString()
              : "all",
          "start": _dateOrEmpty(startDate),
          "end": _dateOrEmpty(endDate),
        })
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());
          print(parsed);
          if (parsed['success'] == true) {
            futuresOpenOrdersList.clear();
            notifyListeners();

            if (parsed['data']['orders'].toString() != "[]") {
              for (var data in parsed['data']['orders']) {
                futuresOpenOrdersList.add(
                  FutureOpenOrdersList(
                    id: data['id'].toString(),
                    pairId: data['pair'].toString(),
                    userId: data['uid'].toString(),
                    orderId: data['order_id'].toString(),
                    contract: data['symbol'].toString(),
                    instrument: data['contract'].toString(),
                    qty: data['volume'].toString(),
                    orderPrice: data['price'].toString(),
                    filled: data['filled'].toString(),
                    remaining: data['remaining'].toString(),
                    orderType: data['order_type'].toString(),
                    tradeType: data['trade_type'].toString(),
                    takeProfit: data['take_profit'].toString(),
                    stopLoss: data['stop_loss'].toString(),
                    dateTime: dateFormatter(data['created_at'].toString()),
                    status: data['status'].toString(),
                  ),
                );
              }
            } else {
              futuresOpenOrdersList.clear();
              notifyListeners();
            }

            notifyListeners();
          } else {}
        })
        .catchError((e) {});
    notifyListeners();
  }

  Future getFutureMyOrders() async {
    await provider
        .getClosedOrdersHistory({
          "pair": selectedFutureTradePair != null
              ? selectedFutureTradePair!.id.toString()
              : "all",
          "start": _dateOrEmpty(startDate),
          "end": _dateOrEmpty(endDate),
        })
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());
          print(parsed);
          if (parsed['success'] == true) {
            futuresMyOrdersList.clear();

            if (parsed['data']['orders'].toString() != "[]") {
              for (var data in parsed['data']['orders']) {
                futuresMyOrdersList.add(
                  FutureMyOrdersList(
                    id: data['id'].toString(),
                    tradePair: data['symbol'].toString(),
                    contract: data['contract'].toString(),
                    side: data['trade_type'].toString(),
                    orderId: data['order_id'].toString(),
                    orderType: data['order_type'].toString(),
                    orderPrice: data['price'].toString(),
                    total: data['volume'].toString(),
                    filled: data['filled'].toString(),
                    filledPrice: data['avg_price'].toString(),
                    statusCode: data['status'].toString(),
                    status: data['status_text'].toString(),
                    dateTime: dateFormatter(data['created_at'].toString()),
                  ),
                );
              }
            } else {
              futuresMyOrdersList.clear();
            }

            notifyListeners();
          } else {}
        })
        .catchError((e) {});
    notifyListeners();
  }

  Future getFuturePNLOrders() async {
    await provider
        .getPNLHistory({
          "pair": selectedFutureTradePair != null
              ? selectedFutureTradePair!.id.toString()
              : "all",
          "start": _dateOrEmpty(startDate),
          "end": _dateOrEmpty(endDate),
        })
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());
          print(parsed);
          if (parsed['success'] == true) {
            futuresPnLHistoryList.clear();

            if (parsed['data']['pnlhistories'].toString() != "[]") {
              for (var data in parsed['data']['pnlhistories']) {
                futuresPnLHistoryList.add(
                  FuturePnLHistoryList(
                    id: data['id'].toString(),
                    qty: data['volume'].toString(),
                    entryPrice: data['entry_price'].toString(),
                    exitPrice: data['exit_price'].toString(),
                    exitType: data['exec_type'].toString(),
                    side: data['side'].toString(),
                    tradePair: data['symbol'].toString(),
                    contract: data['contract'].toString(),
                    closedPnL: data['closedPnl'].toString(),
                    dateTime: dateFormatter(data['created_at'].toString()),
                  ),
                );
              }
            } else {
              futuresPnLHistoryList.clear();
            }

            notifyListeners();
          } else {}
        })
        .catchError((e) {});
    notifyListeners();
  }

  String dateFormatter(String date) {
    DateTime dateTime = DateTime.parse(date);

    DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return outputFormat.format(dateTime);
  }

  Future cancelOrder({
    required BuildContext context,
    required String id,
    required String type,
  }) async {
    setLoader(true);
    try {
      final value = await provider.cancelOrderOpenHistory({
        "category": "spot",
        "order_id": id,
        "side": type,
      });
      setLoader(false);

      final parsed = json.decode(value.toString());

      if (parsed is Map && parsed["success"] == true) {
        getOpenOrderHistory(context, "");
        _showSuccessToast(context, parsed['message']);
        Navigator.pop(context);
      } else {
        _showParsedError(context, parsed, ["error", "message"]);
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

  // ================= DATE FORMAT =================

  String _formatDate(DateTime date) =>
      "${date.year}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";

  String _dateOrEmpty(DateTime? date) => date == null ? "" : _formatDate(date);

  String updateDateTimeFormat(String value) {
    if (value.isEmpty) return "";

    DateTime? dt;

    final formats = [
      "yyyy-MM-dd HH:mm:ss",
      "dd MMM yyyy",
      "dd-MMM-yyyy",
      "dd/MM/yyyy",
    ];

    for (final format in formats) {
      try {
        dt = DateFormat(format).parseStrict(value);
        break;
      } catch (_) {}
    }

    if (dt == null) return value;

    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt.toLocal());
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }
}

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

// ================= MODELS =================

class StatusUI {
  final String text;
  final Color color;

  StatusUI(this.text, this.color);
}

class CoinModel {
  final int id;
  final String name;
  final String symbol;
  final String type;
  final int decimalPlaces;
  final List<String> network;
  final String imageUrl;

  CoinModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.type,
    required this.decimalPlaces,
    required this.network,
    required this.imageUrl,
  });
}

class DepositHistoryModel {
  final String txnId;
  final String coin;
  final String coinName;
  final String sender;
  final String receiver;
  final String network;
  final String type;
  final int status;
  final String remark;
  final String createdAt;
  final String amount;
  final String total;
  final String fee;
  final String proof;
  final String imageUrl;

  DepositHistoryModel({
    required this.txnId,
    required this.coin,
    required this.coinName,
    required this.sender,
    required this.receiver,
    required this.network,
    required this.type,
    required this.status,
    required this.remark,
    required this.createdAt,
    required this.amount,
    required this.total,
    required this.fee,
    required this.proof,
    required this.imageUrl,
  });
}

class WithdrawHistoryModel {
  final int id;
  final int userId;
  final String txnId;
  final String coin;
  final String sender;
  final String receiver;
  final String network;
  final String type;
  final String amount;
  final String fee;
  final String total;
  final int status;
  final String remark;
  final String createdAt;

  WithdrawHistoryModel({
    required this.id,
    required this.userId,
    required this.txnId,
    required this.coin,
    required this.sender,
    required this.receiver,
    required this.network,
    required this.type,
    required this.amount,
    required this.fee,
    required this.total,
    required this.status,
    required this.remark,
    required this.createdAt,
  });
}

class TransferHistoryModel {
  final int id;
  final String currency;
  final String balance;
  final String from;
  final String to;
  final String type;
  final String amount;
  final String createdAt;

  TransferHistoryModel({
    required this.id,
    required this.currency,
    required this.balance,
    required this.from,
    required this.to,
    required this.type,
    required this.amount,
    required this.createdAt,
  });
}

class TradeOrderHistoryModel {
  int? id, pair;
  String? orderId,
      symbol,
      orderType,
      side,
      price,
      avgPrice,
      qty,
      value,
      orderValue,
      fee,
      remainingQty,
      orderStatus,
      createdAt,
      filledValue,
      filledVolume,
      orderPrice,
      filled;

  TradeOrderHistoryModel({
    this.id,
    this.pair,
    this.orderId,
    this.symbol,
    this.orderType,
    this.filledVolume,
    this.side,
    this.price,
    this.avgPrice,
    this.qty,
    this.filledValue,
    this.value,
    this.orderValue,
    this.fee,
    this.remainingQty,
    this.orderStatus,
    this.createdAt,
    this.orderPrice,
    this.filled,
  });
}

class OrderHistoryModel {
  int? id, pair;
  String? orderId,
      symbol,
      orderType,
      side,
      price,
      avgPrice,
      qty,
      value,
      orderValue,
      fee,
      remainingQty,
      orderStatus,
      createdAt,
      filledValue,
      filledVolume,
      orderPrice,
      filled;

  OrderHistoryModel({
    this.id,
    this.pair,
    this.orderId,
    this.symbol,
    this.orderType,
    this.filledVolume,
    this.side,
    this.price,
    this.avgPrice,
    this.qty,
    this.filledValue,
    this.value,
    this.orderValue,
    this.fee,
    this.remainingQty,
    this.orderStatus,
    this.createdAt,
    this.orderPrice,
    this.filled,
  });
}

class TradePair {
  int? id, coinOneDecimal, coinTwoDecimal, isActive;
  String? coinOne, coinTwo, coinOneName, coinTwoName, image;
  TradePair({
    this.id,
    this.coinOne,
    this.coinTwo,
    this.coinOneName,
    this.coinTwoName,
    this.image,
    this.coinOneDecimal,
    this.coinTwoDecimal,
    this.isActive,
  });
}
