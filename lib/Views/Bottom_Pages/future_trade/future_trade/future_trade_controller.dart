import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:k_chart_plus/chart_style.dart';
import 'package:k_chart_plus/entity/depth_entity.dart';
import 'package:k_chart_plus/entity/k_line_entity.dart';
import 'package:k_chart_plus/k_chart_widget.dart';
import 'package:k_chart_plus/utils/data_util.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';
import 'package:zayroexchange/material_theme/theme_controller.dart';
import 'future_trade_api.dart';
import 'orderbook_future.dart';
import 'package:http/http.dart' as http;

class FutureTradeController extends ChangeNotifier {
  FutureTradeAPI provider = FutureTradeAPI();

  final formKey = GlobalKey<FormState>();
  final closeMarketFormKey = GlobalKey<FormState>();
  final closeLimitFormKey = GlobalKey<FormState>();
  final addEditTPSLFormKey = GlobalKey<FormState>();
  final GlobalKey priceChartKey = GlobalKey();
  final GlobalKey depthChartKey = GlobalKey();

  InAppWebViewController? priceChartWebViewController;
  InAppWebViewController? depthChartWebViewController;

  StreamController? priceStreamController = StreamController.broadcast();
  StreamController? orderbookStreamController = StreamController.broadcast();
  StreamController? livePriceStreamController = StreamController.broadcast();

  IOWebSocketChannel? futureOrderBookChannel;
  StreamController futureOrderBookStreamController = StreamController.broadcast();

  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  TextEditingController orderTypeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController takeProfitController = TextEditingController();
  TextEditingController stopLossController = TextEditingController();

  var priceValidate = AutovalidateMode.onUserInteraction;
  var amountValidate = AutovalidateMode.onUserInteraction;
  var totalValidate = AutovalidateMode.onUserInteraction;

  IOWebSocketChannel? orderbookChannel;
  List<WebSocketChannel> priceChannelList = [];
  List<String> tradeSocketPairs = [];
  String pairs = "";

  List<FutureTradePairList> perpetualTradePairsList = [];
  List<FutureTradePairList> futuresTradePairsList = [];
  List<FuturePositionsList> futuresPositionsList = [];
  List<FutureOpenOrdersList> futuresOpenOrdersList = [];
  List<FuturePnLHistoryList> futuresPnLHistoryList = [];
  List<FutureMyOrdersList> futuresMyOrdersList = [];
  List<FutureMyOrdersTPSLList> futuresMyOrdersTPSLList = [];
  List sellOrderbook = [];
  List buyOrderbook = [];

  bool firstEventHandled = false;

  // ================= CHART =================
  bool isPriceChartEnabled = false;
  bool isDepthChartEnabled = false;
  bool isShowingLiveBalance = false;

  int orderBookType = 0;

  List<String> orderTypesList = ["Limit", "Market"];

  int tradePairTabIndex = 0;
  int tabIndex = 0;

  /// 0 - buy ,  1- sell
  int buySellTabIndex = 0;

  /// 0 - null , 1 - candle chart ,  2- area chart
  int chartTabIndex = 0;

  double chartProgress = 0.0;

  String tradePair = "";
  String tradePairId = "";
  String coinOne = "";
  String coinTwo = "";
  String coinOneImage = "";
  String coinOneName = "";
  double lastPrice = 0.0;
  double change24H = 0.0;
  double markPrice = 0.0;
  double openInterestPrice = 0.0;
  double indexPrice = 0.0;
  double turnOver24H = 0.0;
  double volume24H = 0.0;
  double low24H = 0.0;
  String totalAmount = "0.0";
  String liquidityType = "";
  String contractType = "";
  String orderTypeId = "";
  String marginMode = "";
  int marginModeId = 0;
  int leverageCopy = 1;
  String leverage = "";
  double marginBalance = 0.0;
  double marginBalanceCopy = 0.0;
  double availableBalance = 0.0;
  double availableBalanceCopy = 0.0;
  double cost = 0.0;
  double value = 0.0;
  double takerFee = 0.0;
  TextEditingController leverageController = TextEditingController();

  double percentChange = 0.0;
  bool isLoading = false;
  bool isSuccess = false;
  bool isTPSLChecked = false;

  double sliderValue = 0.00;

  List<OBLevel> buyObList = [];
  List<OBLevel> sellObList = [];

  final Map<double, double> bidsMap = {};
  final Map<double, double> asksMap = {};

  String storedLivePrice = "";
  String storedMarkPrice = "";

  ///kchart
  List<KLineEntity>? datas;
  bool showLoading = true;
  bool volHidden = false;
  // MainState mainState = MainState.MA;
  final List<MainState> mainStateLi = [MainState.MA];
  // final Set<SecondaryState> _secondaryStateLi = <SecondaryState>{};
  final List<SecondaryState> secondaryStateLi = [SecondaryState.KDJ, SecondaryState.RSI];
  List<DepthEntity>? bidsArr, asksArr;
  IOWebSocketChannel? klineTickerChannel;
  StreamController klineStreamController = StreamController.broadcast();
  bool kLineSocketConnected = false;
  ChartStyle chartStyle = ChartStyle();
  ChartColors chartColors = ChartColors();
  late Timer timer;
  String selectedTime = '5m';

  bool abstractChart = false;
  bool depthChartLoader = false;
  InAppWebViewController? depthWebController;
  var buyTrade = [];
  var sellTrade = [];

  double quantityDepth = 0.1;
  List<double> quantityDepthList = [0.01,0.1,1,10,100];

  setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  handleFirstEvent() {
    firstEventHandled = true;
  }

  clearFirstEvent() {
    firstEventHandled = false;
    notifyListeners();
  }

  setLivePriceController(String type) {
    print("Set LIVE PORICE ${lastPrice} amd Type ${type}");
    if(type == "tp"){
      if (lastPrice>0) {
        takeProfitController.text = lastPrice.toString();
      } else {
        takeProfitController.text = "";
      }
      notifyListeners();
    }else if(type == "sl"){
      if (lastPrice>0) {
        stopLossController.text = lastPrice.toString();
      } else {
        stopLossController.text = "";
      }
      notifyListeners();
    }else{
      if (lastPrice>0) {
        priceController.text = lastPrice.toString();
        getValueCost();
      } else {
        priceController.text = "";
      }
      notifyListeners();
    }

    notifyListeners();
  }


  resetData() {
    priceController.clear();
    amountController.clear();
    takeProfitController.clear();
    stopLossController.clear();
    isTPSLChecked = false;
    getValueCost();
    notifyListeners();
  }

  setTradePairTabIndex(int value) {
    tradePairTabIndex = value;
    notifyListeners();
  }

  isTPSLCheckBoxFunc() {
    isTPSLChecked = !isTPSLChecked;
    notifyListeners();
  }

  setTakeProfit(String value) {
    takeProfitController.text = value;
    notifyListeners();
  }

  setStopLoss(String value) {
    stopLossController.text = value;
    notifyListeners();
  }

  setBuySellTabIndex(int value) {
    if (formKey.currentState != null) {
      formKey.currentState!.reset();
    }
    buySellTabIndex = value;
    resetData();
    notifyListeners();
  }

  setChartTab(int value) {
    if (chartTabIndex == value) {
      chartTabIndex = 0;
    } else {
      chartTabIndex = value;
    }
    notifyListeners();
  }

  // =======================================================
  // UPDATE PRICE FIELD
  // =======================================================
  void updatePriceTextForm(String value) {
    priceController.text = value;
    notifyListeners();
  }

  // =======================================================
  // UPDATE AMOUNT FIELD
  // =======================================================
  void updateQuantityTextForm(String value) {
    amountController.text = value;
    notifyListeners();
  }

  disposeData() {
    priceChannelList.clear();
    orderbookChannel?.sink.close();
    perpetualTradePairsList.clear();
    futuresTradePairsList.clear();
    futuresPositionsList.clear();
    futuresOpenOrdersList.clear();
    futuresPnLHistoryList.clear();
    futuresMyOrdersList.clear();
    futuresMyOrdersTPSLList.clear();
    priceController.clear();
    amountController.clear();
    takeProfitController.clear();
    stopLossController.clear();
    isTPSLChecked = false;
    leverageController.clear();
    quantityDepth = 0.1;
    pusher.unsubscribe(
      channelName: "future.position-update.${AppStorage.getUserId()}",
    );
  }

  changeQuantityDepth(double val){
    quantityDepth = val;
    notifyListeners();
  }

  clearChartData() {
    if (isPriceChartEnabled ||
        isDepthChartEnabled) {
      isPriceChartEnabled = false;
      isDepthChartEnabled = false;
    } else {
      isPriceChartEnabled = true;
    }

    notifyListeners();
  }

    loadCharts(BuildContext context) {
      ThemeController themeController = Provider.of<ThemeController>(
        context,
        listen: false,
      );
    priceChartWebViewController?.reload();
    if (liquidityType == "bybit") {
      if (tradePairTabIndex == 0) {
        priceChartWebViewController?.loadData(
          data: getPriceChartHTML(
            tradePair: tradePair.contains("PERP")
                ? "$coinOne$coinTwo"
                : tradePair,
          ),
          mimeType: "text/html",
          encoding: "utf-8",
        );
      } else {
        priceChartWebViewController?.loadUrl(
          urlRequest: URLRequest(
            url: WebUri("${ApiEndpoints.SPOT_PRICE_CHART_URL}${tradePair}"),
          ),
        );
      }
    }
    depthChartWebViewController?.reload();

    // depthChartWebViewController?.loadUrl(
    //   urlRequest: URLRequest(
    //     url: WebUri("${ApiEndpoints.FUTURE_DEPTH_CHART_URL}$tradePair"),
    //   ),
    // );
    if (depthWebController != null) {
      depthWebController?.loadUrl(
        urlRequest: URLRequest(
          url: WebUri.uri(
            Uri.parse(
              "${ApiEndpoints.FUTURE_DEPTH_CHART_URL}${coinOne}$coinTwo&mode=${themeController.themeMode == ThemeMode.system ? Theme.of(context).brightness == Brightness.dark ? "dark" : "light" : themeController.themeMode == ThemeMode.dark ? "dark" : "light"}",
            ),
          ),
        ),
      );
    }
    notifyListeners();
  }

  setOrderType(String type, String id) {
    if (formKey.currentState != null) {
      formKey.currentState!.reset();
    }
    orderTypeController.text = type;
    orderTypeId = id;
    resetData();

    notifyListeners();
  }

  setMarginModeId(int mode) {
    marginModeId = mode;
    notifyListeners();
  }

  setMarginMode() {
    if (marginModeId == 0) {
      marginMode = "Cross";
    } else {
      marginMode = "Isolated";
    }
    notifyListeners();
  }

  setLeverageCopy(bool isAdd) {
    if (isAdd) {
      leverageCopy = (leverageCopy + 1).clamp(1, 100);
    } else {
      leverageCopy = (leverageCopy - 1).clamp(1, 100);
    }


    leverageController.text = leverageCopy.toString();
    notifyListeners();
  }

  setLeverageCopyType(int val) {
    leverageCopy = val;
    leverageController.text = leverageCopy.toString();
    notifyListeners();
  }

  setLeverage(int value) {
    leverage = value.toString();
    leverageCopy = value;
    leverageController.text = leverageCopy.toString();
    notifyListeners();
  }

  getValueCost() {
    if (orderTypeId == "0"
        ? (priceController.text.isNotEmpty && amountController.text.isNotEmpty)
        : (amountController.text.isNotEmpty)) {
      var price = double.parse(
        orderTypeId == "0" ? priceController.text : lastPrice.toString(),
      );
      var amount = double.parse(amountController.text);
      var leverage = double.parse(this.leverage);
      var initialMargin = (price * amount) / leverage;
      var feeToOpenPosition = (amount * price * (takerFee / 100));
      var bankruptcyPrice = (price * (leverage - 1)) / leverage;
      var feeToClosePosition = amount * bankruptcyPrice * (takerFee / 100);

      value = double.parse((price * amount).toStringAsFixed(2));
      cost = double.parse(
        (initialMargin + feeToOpenPosition + feeToClosePosition)
            .toStringAsFixed(2),
      );
    } else {
      value = 0.0;
      cost = 0.0;
    }
    notifyListeners();
  }

  getBalances() {
    var initialMarginValue = 0.0;
    var bankruptcy = 0.0;
    var marginBal = marginBalanceCopy;
    var availableBal = availableBalanceCopy;

    // var lastOrderPrice = coinTwo == "USDC" ? markPrice : lastPrice;

    for (var list in futuresPositionsList) {
      if (coinTwo == list.coinTwo) {
        var lastOrderPrice = coinTwo == "USDC"
            ? list.markPrice
            : list.lastPrice;
        if (lastOrderPrice > 0) {
          if ((list.side ?? "").toLowerCase() == "buy") {
            list.unrealPnL = (list.qty * (lastOrderPrice - list.entryPrice));
            bankruptcy = list.leverage - 1;
          } else {
            list.unrealPnL = (list.qty * (list.entryPrice - lastOrderPrice));
            bankruptcy = list.leverage + 1;
          }

          var bankruptcyPrice = (list.entryPrice * bankruptcy) / list.leverage;
          var initialMargin = (list.value / list.leverage);
          // var openFee = (list.qty * 0.055) / 100;
          var closeFee = (bankruptcyPrice * list.qty * 0.055) / 100;

          list.unrealPnLPerc =
              (list.unrealPnL * 100) /
              (initialMargin + (list.coinTwo == "USDC" ? 0 : closeFee));
          // list.realPnL = (list.unrealPnL - openFee - closeFee - 1.5);

          if ((list.marginType ?? "").toLowerCase() == "cross" ||
              list.coinTwo == coinTwo) {
            marginBal = marginBal + list.unrealPnL;

            initialMarginValue = initialMarginValue + initialMargin;

            // availableBal = availableBal - initialMarginValue;
          }
        }
      }
    }
    marginBalance = marginBal;
    availableBalance = availableBal;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }


//   void getBalances() {
//     var initialMarginValue = 0.0;
//     var marginBal = marginBalanceCopy;
//
//     // Safety checks like (orderbook && orderbook.positions && positions.length > 0)
//     print("BAALNND ${marginBal}");
//     if (futuresPositionsList != null && futuresPositionsList.isNotEmpty) {
//       for (var position in futuresPositionsList) {
//         double lastOrderPrice = 0.0;
//
//         if (position.coinTwo == "USDC") {
//           lastOrderPrice = position.markPrice!;
//         } else {
//           lastOrderPrice = position.lastPrice;
//         }
//
//         if (lastOrderPrice > 0) {
//           double unrealPL;
//           double bankrupCalc;
//
//           if (position.side == 'Buy') {
//             unrealPL =
//                 position.qty! * (lastOrderPrice - position.entryPrice!);
//             bankrupCalc = position.leverage! - 1;
//           } else {
//             // Sell side
//             unrealPL =
//                 position.qty! * (position.entryPrice! - lastOrderPrice);
//             bankrupCalc = position.leverage! + 1;
//           }
//
//           final bankrupPrice =
//               (position.entryPrice! * bankrupCalc) / position.leverage!;
//
//           final initialMargin = (position.value! / position.leverage!);
//
//           final openFee = (position.value! * double.parse((takerFee.toString().isNotEmpty && takerFee.toString().toLowerCase() != "null" )? takerFee.toString() : "0.0" )) / 100.0;
//
//           final closeFee =
//               (bankrupPrice * position.qty! * double.parse((takerFee.toString().isNotEmpty && takerFee.toString().toLowerCase() != "null") ? takerFee.toString() : "0.0" )) / 100.0;
//
//           final uplPerc = (unrealPL * 100.0) /
//               (initialMargin +
//                   (position.coinTwo == "USDC" ? 0.0 : closeFee));
//
//           final actualUpl = unrealPL / position.leverage!;
//           final realPl = (actualUpl - openFee - closeFee - 1.5);
//           // realPl is calculated in your JS but not stored anywhere;
//           // keeping it here in case you want it later.
//
//           // Mutate the position same as you do in JS
//           position.markPrice = lastOrderPrice;
//           position.unrealPnL = _toFixed(unrealPL, 4);
//           // position.uplUsd = _toFixed(unrealPL, 2);
//           position.unrealPnLPerc = uplPerc;
//
//           // Cross / same-coin margin logic
//           if (position.marginType == "cross" ||
//               (coinTwo == "USDT" && position.coinTwo == "USDT") ||
//               (coinTwo == "USDC" && position.coinTwo == "USDC")) {
//             marginBal = (marginBalance + unrealPL + position.realPnL!);
//             initialMarginValue += initialMargin;
//           }
//
//           // mode = position.marginMode;
//         }
//       }
//     }else{
//
//     }
//     marginBalance = marginBal;
//
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   notifyListeners();
//     // });
//
// // notifyListeners();
//
//   }

  // helper to mimic JS toFixed() behavior returning double with precision trim
  double _toFixed(double value, int fractionDigits) {
    final mod = pow(10, fractionDigits);
    return (value * mod).roundToDouble() / mod;
  }

  setTradePair({
    required BuildContext context,
    required String id,
    required String coinOne,
    required String coinTwo,
    required String tradePair,
    required String coinOneImage,
    required double price,
    required double change,
    required double markPrice,
    required double volume,
    required String contractType,
    required String liquidityType,
  }) {
    tradePairId = id;
    this.coinOne = coinOne;
    this.coinTwo = coinTwo;
    this.tradePair = tradePair;
    this.coinOneImage = coinOneImage;
    this.liquidityType = liquidityType;
    lastPrice = price;
    change24H = change;
    volume24H = volume;
    this.markPrice = markPrice;
    this.contractType = contractType;

    print(
      "TRADE PAIR LIST ${tradePairId}\n ${this.coinOne} ${this.coinTwo} ${this.tradePair} ${this.liquidityType} ${lastPrice} ${change24H}\n"
      "${volume24H} ${this.markPrice} ${this.contractType}",
    );
    clearFirstEvent();
    buyOrderbook.clear();
    sellOrderbook.clear();
    asksMap.clear();
    bidsMap.clear();

    isPriceChartEnabled = false;
    isDepthChartEnabled = false;

    pusherInitialization();

    byBitFuturePriceTickerSocket(coinOne + coinTwo);
    byBitFutureOrderbookSocket(coinOne + coinTwo);
    byBitLivePriceSocket(coinOne + coinTwo);
    getTradePairDetails();
    loadCharts(context);
    notifyListeners();
  }

  String dateFormatter(String date) {
    DateTime dateTime = DateTime.parse(date);

    DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return outputFormat.format(dateTime);
  }

  String getPriceChartHTML({required String tradePair}) {
    return """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Trading Chart</title>
        <script src="https://s3.tradingview.com/tv.js"></script>
        <style>
            body { background-color: #131723; margin: 0; padding: 0; }
            #chart-container { width: 100%; height: 400px; background-color: #f0f0f0; }
        </style>
    </head>
    <body>
        <div id="chart-container"></div>
        <script>
          function loadChart() {
              new TradingView.widget({
                  container_id: "chart-container",
                  width: "100%",
                  height: "400",
                  symbol:  "BYBIT:$tradePair.P", // Dynamic Pair
                  interval: "15",
                  timezone: "Etc/UTC",
                  theme: "Dark",
                  style: "1",
                  locale: "en",
                  toolbar_bg: "#f1f3f6",
                  enable_publishing: false,
                  withdateranges: true,
                  hide_side_toolbar: true,
                  allow_symbol_change: true,
              });
          }
          loadChart();
        </script>
    </body>
    </html>
  """;
  }

  Future getTradePairs(BuildContext context) async {
    setLoader(true);
    await provider
        .getTradePairs(
          derivativeType: tradePairTabIndex == 0 ? "perpetual" : "future",
        )
        .then((value) {
          final parsed = json.decode(value.toString());
          setLoader(false);
          if (parsed['success'] == true) {
            perpetualTradePairsList.clear();
            futuresTradePairsList.clear();
            tradeSocketPairs.clear();
            pairs = "";

            if (parsed['data'].toString() != "[]") {
              for (var market in parsed['data']['marketpairs']) {
                if (market['key'].toString() == 'USDC') {
                  for (var data in market['data']) {
                    if (data['contract_type'].toString() == 'LINEARFUTURES') {
                      futuresTradePairsList.add(
                        FutureTradePairList(
                          id: data['pair'].toString(),
                          coinOne: data['coinone'].toString(),
                          tradePair: data['contract'].toString(),
                          coinTwo: data['cointwo'].toString(),
                          coinOneImage: data['coinimg'].toString(),
                          contractType: data['contract_type']
                              .toString()
                              .replaceAll("LINEAR", "")
                              .toUpperCase(),
                          volume: data['Volume'].toString(),
                          price: data['Last'].toString(),
                          markPrice: data['markPrice'].toString(),
                          change:
                              (double.parse(data['Exchange'].toString()) * 100)
                                  .toStringAsFixed(3)
                                  .toString(),
                          liquidity: data['keytype'].toString(),
                        ),
                      );
                      if (data['keytype'].toString() == "bybit") {
                        byBitFuturePriceTickerSocket(
                          data['contract'].toString(),
                        );
                      }
                    }

                    if (data['contract_type'].toString() == 'LINEARPERPETUAL') {
                      perpetualTradePairsList.add(
                        FutureTradePairList(
                          id: data['pair'].toString(),
                          coinOne: data['coinone'].toString(),
                          tradePair: data['contract'].toString(),
                          coinTwo: data['cointwo'].toString(),
                          coinOneImage: data['coinimg'].toString(),
                          contractType: data['contract_type']
                              .toString()
                              .replaceAll("LINEAR", "")
                              .toUpperCase(),
                          volume: data['Volume'].toString(),
                          price: data['Last'].toString(),
                          markPrice: data['markPrice'].toString(),
                          change:
                              (double.parse(data['Exchange'].toString()) * 100)
                                  .toStringAsFixed(3)
                                  .toString(),
                          liquidity: data['keytype'].toString(),
                        ),
                      );
                      if (data['keytype'].toString() == "bybit") {
                        byBitFuturePriceTickerSocket(
                          data['contract'].toString(),
                        );
                      }
                    }
                  }
                } else {
                  for (var data in market['data']) {
                    if (data['contract_type'].toString() == 'LINEARPERPETUAL') {
                      perpetualTradePairsList.add(
                        FutureTradePairList(
                          id: data['pair'].toString(),
                          coinOne: data['coinone'].toString(),
                          tradePair: data['contract'].toString(),
                          coinTwo: data['cointwo'].toString(),
                          coinOneImage: data['coinimg'].toString(),
                          contractType: data['contract_type']
                              .toString()
                              .replaceAll("LINEAR", "")
                              .toUpperCase(),
                          volume: data['Volume'].toString(),
                          price: data['Last'].toString(),
                          markPrice: data['markPrice'].toString(),
                          change:
                              (double.parse(data['Exchange'].toString()) * 100)
                                  .toStringAsFixed(3)
                                  .toString(),
                          liquidity: data['keytype'].toString(),
                        ),
                      );

                      tradeSocketPairs.add(
                        '"tickers.${data['coinone'].toString()}${data['cointwo'].toString()}"',
                      );
                      pairs = tradeSocketPairs.join(',');

                      if (data['keytype'].toString() == "bybit") {
                        byBitFuturePriceTickerSocket(
                          data['contract'].toString(),
                        );
                      }
                    }
                  }

                  if (tradeSocketPairs.isNotEmpty) {
                    print("tradeSocketPairs. Pairs ${pairs}");
                    byBitTradeListDataUpdate();
                  }
                }
              }
            }

            if (tradePairTabIndex == 0) {
              var list = perpetualTradePairsList.first;

              setTradePair(
                context: context,
                id: list.id.toString(),
                coinOne: list.coinOne.toString(),
                coinTwo: list.coinTwo.toString(),
                tradePair: list.tradePair.toString(),
                coinOneImage: list.coinOneImage.toString(),
                price: double.parse(list.price.toString()),
                change: double.parse(list.change.toString()),
                volume: double.parse(list.volume.toString()),
                liquidityType: list.liquidity.toString(),
                contractType: list.contractType.toString(),
                markPrice: double.parse(list.markPrice.toString()),
              );
            } else {
              var list = futuresTradePairsList.first;
              setTradePair(
                context: context,
                id: list.id.toString(),
                coinOne: list.coinOne.toString(),
                coinTwo: list.coinTwo.toString(),
                tradePair: list.tradePair.toString(),
                coinOneImage: list.coinOneImage.toString(),
                price: double.parse(list.price.toString()),
                change: double.parse(list.change.toString()),
                volume: double.parse(list.volume.toString()),
                liquidityType: list.liquidity.toString(),
                contractType: list.contractType.toString(),
                markPrice: double.parse(list.markPrice.toString()),
              );
            }

            marginMode = parsed['data']['crosstype'].toString().toUpperCase();
            leverage = parsed['data']['leverage'].toString();
            leverageCopy = int.parse(leverage.toString());

            leverageController.text = leverageCopy.toString();

            availableBalanceCopy = double.parse(
              parsed['data']['cointwoBalance'].toString(),
            );
            marginBalanceCopy = double.parse(
              parsed['data']['cointwoSiteBalance'].toString(),
            );
            takerFee = double.parse(parsed['data']['takerFee'].toString());
            if (marginMode.toLowerCase() == "cross") {
              setMarginModeId(0);
            } else {
              setMarginModeId(1);
            }
            setMarginMode();
            getBalances();
          } else {
            Fluttertoast.showToast(msg: parsed['message'].toString());
          }
        })
        .catchError((e) {
          Fluttertoast.showToast(msg: e.toString());
        });
    notifyListeners();
  }

  Future getTradePairDetails() async {
    await provider
        .getFutureHistories(pairId: tradePairId)
        .then((value) {
          final parsed = json.decode(value.toString());
          print(parsed);
          if (parsed['success'] == true) {
            futuresPositionsList.clear();
            futuresOpenOrdersList.clear();
            futuresPnLHistoryList.clear();
            futuresMyOrdersList.clear();
            futuresMyOrdersTPSLList.clear();
            if (parsed['data']['positions'].toString() != "[]") {
              for (var data in parsed['data']['positions']) {
                futuresPositionsList.add(
                  FuturePositionsList(
                    id: data['id'].toString(),
                    pairId: data['pair'].toString(),
                    side: data['side'].toString(),
                    userId: data['uid'].toString(),
                    coinOne: data['coinone'].toString(),
                    coinTwo: data['cointwo'].toString(),
                    contract: data['symbol'].toString(),
                    marginType: data['margin_mode'].toString(),
                    leverage: int.parse(data['leverage'].toString()),
                    qty: double.parse(data['volume'].toString()),
                    value: double.parse(data['total'].toString()),
                    entryPrice: double.parse(data['entry_price'].toString()),
                    lastPrice: 0.0,
                    liqPrice: double.parse(data['liq_price'].toString()),
                    markPrice: double.parse(data['mark_price'].toString()),
                    positionIM: double.parse(data['positionIM'].toString()),
                    positionMM: double.parse(data['positionMM'].toString()),
                    unrealPnL: double.parse(data['upl'].toString()),
                    unrealPnLPerc: double.parse(data['upl'].toString()),
                    realPnL: double.parse(data['rpl'].toString()),
                    takeProfit: double.parse(data['take_profit'].toString()),
                    stopLoss: double.parse(data['stop_loss'].toString()),
                    tpTrigger: data['tp_trigger_by'].toString(),
                    slTrigger: data['sl_trigger_by'].toString(),
                    status: int.parse(data['status'].toString()),
                  ),
                );
                byBitFuturePriceTickerSocket(data['symbol'].toString());
              }

              byBitFuturePriceTickerSocketFuture();
            }

            if (parsed['data']['openorders'].toString() != "[]") {
              for (var data in parsed['data']['openorders']) {
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
            }

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
            }

            if (parsed['data']['closed_orders'].toString() != "[]") {
              for (var data in parsed['data']['closed_orders']) {
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
            }

            if (parsed['data']['tpsl_closed_orders'].toString() != "[]") {
              for (var data in parsed['data']['tpsl_closed_orders']) {
                futuresMyOrdersTPSLList.add(
                  FutureMyOrdersTPSLList(
                    id: data['id'].toString(),
                    tradePair: data['symbol'].toString(),
                    contract: data['contract'].toString(),
                    side: data['trade_type'].toString(),
                    orderId: data['order_id'].toString(),
                    orderType: data['order_type'].toString(),
                    orderPrice: data['price'].toString(),
                    qty: data['volume'].toString(),
                    filled: data['filled'].toString(),
                    takeProfit: data['take_profit'].toString(),
                    stopLoss: data['stop_loss'].toString(),
                    takeProfitBy: data['tp_trigger_by'].toString(),
                    stopLossBy: data['sl_trigger_by'].toString(),
                    filledPrice: data['avg_price'].toString(),
                    statusCode: data['status'].toString(),
                    status: data['status_text'].toString(),
                    dateTime: dateFormatter(data['created_at'].toString()),
                  ),
                );
              }
            }

            marginMode = parsed['data']['crosstype'].toString().toUpperCase();
            leverage = parsed['data']['leverage'].toString();
            leverageCopy = int.parse(leverage.toString());
            leverageController.text = leverageCopy.toString();

            availableBalanceCopy = double.parse(
              parsed['data']['cointwoBalance'].toString(),
            );
            marginBalanceCopy = double.parse(
              parsed['data']['cointwoSiteBalance'].toString(),
            );
            takerFee = double.parse(parsed['data']['takerFee'].toString());
            if (marginMode.toLowerCase() == "cross") {
              setMarginModeId(0);
            } else {
              setMarginModeId(1);
            }

            print("lscjlcdjlvsjdj ${futuresMyOrdersList.length}");

            notifyListeners();
            setMarginMode();
          } else {}
        })
        .catchError((e) {});
    notifyListeners();
  }

  Future doUpdateLeverage(BuildContext context) async {
    setLoader(true);
    await provider
        .doUpdateLeverage(
          tradePair: tradePair,
          pairId: tradePairId,
          leverage: leverageCopy.toString(),
        )
        .then((value) {
          final parsed = json.decode(value.toString());
          setLoader(false);
          if (parsed['success'] == true) {
            isSuccess = true;
            setLeverage(leverageCopy);
            Fluttertoast.showToast(msg: parsed['message'].toString());
          } else {
            isSuccess = false;
            var errorMessage = "";
            List<String> keyList = <String>[
              'leverage',
              'symbol',
              'pair',
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
            Fluttertoast.showToast(msg: errorMessage);
          }
        })
        .catchError((e) {
          isSuccess = false;
          Fluttertoast.showToast(msg: e.toString());
        });
    notifyListeners();
  }

  Future doUpdateMargin(BuildContext context) async {
    setLoader(true);
    await provider
        .doUpdateMargin(marginType: marginModeId == 0 ? "cross" : "isolated")
        .then((value) {
          final parsed = json.decode(value.toString());
          setLoader(false);
          if (parsed['success'] == true) {
            isSuccess = true;
            Fluttertoast.showToast(msg: parsed['message'].toString());
            setMarginMode();
            notifyListeners();
          } else {
            isSuccess = false;
            var errorMessage = "";
            List<String> keyList = <String>['type', 'error'];
            for (var key in keyList) {
              if (parsed['data'].toString().contains(key)) {
                errorMessage += parsed['data'][key]
                    .toString()
                    .replaceAll('null', '')
                    .replaceAll('[', '')
                    .replaceAll(']', '');
              }
            }
            Fluttertoast.showToast(msg: errorMessage);
          }
        })
        .catchError((e) {
          isSuccess = false;
          Fluttertoast.showToast(msg: e.toString());
        });
    notifyListeners();
  }

  Future doLimitOrder(BuildContext context) async {
    setLoader(true);
    await provider
        .doLimitOrder(
          tradePairId: tradePairId,
          price: priceController.text,
          amount: amountController.text,
          side: buySellTabIndex == 0 ? "buy" : "sell",
          coinOne: coinOne,
          isTPSLChecked: isTPSLChecked,
          takeProfit: takeProfitController.text,
          stopLoss: stopLossController.text,
          tpTriggerBy: "LastPrice",
          slTriggerBy: "LastPrice",
        )
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());
          if (parsed['success'] == true) {
            resetData();
            availableBalance = double.parse(
              parsed['data']['balance'].toString(),
            );
            marginBalance = double.parse(
              parsed['data']['site_balance'].toString(),
            );
            getTradePairDetails();
            Fluttertoast.showToast(msg: parsed['message']);
          } else {
            var errorMessage = "";
            List<String> keyList = <String>[
              'pair',
              'price',
              'amount',
              'type',
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
            Fluttertoast.showToast(msg: errorMessage);
            // Fluttertoast.showToast(message: parsed['message'], );
          }
        })
        .catchError((e) {
          setLoader(false);
          Fluttertoast.showToast(msg: e.toString());
        });
    notifyListeners();
  }

  percentageBasedAmountAndTotalAmount({required double value}) {
    sliderValue = value;

    double percentageVal = 0.0;
    double total = 0.0;

    final double balance = availableBalance;

    percentageVal = balance * (sliderValue / 100);

    if (orderTypeId.toString().toLowerCase() == "market") {
      total = percentageVal / lastPrice;
    } else {
      total = percentageVal / (double.tryParse(priceController.text) ?? 1);
    }

    if (leverageCopy > 1) {
      total = total * leverageCopy;
    } else {
      total = percentageVal / lastPrice;
    }
    amountController.text = total.toString();

    // totalController.text = percentageVal.toStringAsFixed(
    //   selectedCoinTwoDecimal,
    // );

    notifyListeners();

    getValueCost();
    notifyListeners();
  }

  Future doMarketOrder(BuildContext context) async {
    setLoader(true);
    await provider
        .doMarketOrder(
          tradePairId: tradePairId,
          amount: amountController.text,
          side: buySellTabIndex == 0 ? "buy" : "sell",
          coinOne: coinOne,
          isTPSLChecked: isTPSLChecked,
          takeProfit: takeProfitController.text,
          stopLoss: stopLossController.text,
          tpTriggerBy: "LastPrice",
          slTriggerBy: "LastPrice",
        )
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());
          if (parsed['success'] == true) {
            resetData();
            availableBalance = double.parse(
              parsed['data']['balance'].toString(),
            );
            marginBalance = double.parse(
              parsed['data']['site_balance'].toString(),
            );
            getTradePairDetails();
            Fluttertoast.showToast(msg: parsed['message']);
          } else {
            var errorMessage = "";
            List<String> keyList = <String>['pair', 'amount', 'type', 'error'];
            for (var key in keyList) {
              if (parsed['data'].toString().contains(key)) {
                errorMessage += parsed['data'][key]
                    .toString()
                    .replaceAll('null', '')
                    .replaceAll('[', '')
                    .replaceAll(']', '');
              }
            }
            Fluttertoast.showToast(msg: errorMessage);
            // Fluttertoast.showToast(message: parsed['message'], );
          }
        })
        .catchError((e) {
          setLoader(false);
          Fluttertoast.showToast(msg: e.toString());
        });
    notifyListeners();
  }

  Future doCloseLimitPosition({
    required BuildContext context,
    required String positionId,
    required String tradePairId,
    required String price,
    required String amount,
    required String side,
  }) async {
    setLoader(true);
    await provider
        .doCloseLimitPosition(
          tradePairId: tradePairId,
          positionId: positionId,
          price: price,
          amount: amount,
          side: side.toLowerCase() == "buy" ? "1" : "2",
        )
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());
          if (parsed['success'] == true) {
            resetData();

            Fluttertoast.showToast(msg: parsed['message']);
            Future.delayed(Duration(seconds: 1)).whenComplete(() {
              getTradePairDetails();
            });
          } else {
            var errorMessage = "";
            List<String> keyList = <String>[
              'pair',
              'price',
              'amount',
              'position_id',
              'side',
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
            Fluttertoast.showToast(msg: errorMessage);
            // Fluttertoast.showToast(message: parsed['message'], );
          }
        })
        .catchError((e) {
          setLoader(false);
          Fluttertoast.showToast(msg: e.toString());
        });
    notifyListeners();
  }

  Future doCloseMarketPosition({
    required BuildContext context,
    required String positionId,
    required String tradePairId,
    required String side,
  }) async {
    setLoader(true);
    await provider
        .doCloseMarketPosition(
          tradePairId: tradePairId,
          positionId: positionId,
          amount: amountController.text,
          side: side.toLowerCase() == "buy" ? "1" : "2",
        )
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());
          if (parsed['success'] == true) {
            resetData();

            Fluttertoast.showToast(msg: parsed['message']);
          } else {
            var errorMessage = "";
            List<String> keyList = <String>[
              'pair',
              'amount',
              'position_id',
              'side',
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
            Fluttertoast.showToast(msg: errorMessage);
            // Fluttertoast.showToast(message: parsed['message'], );
          }
        })
        .catchError((e) {
          setLoader(false);
          Fluttertoast.showToast(msg: e.toString());
        });
    notifyListeners();
  }

  Future doCancelOpenOrder({
    required BuildContext context,
    required String orderId,
  }) async {
    setLoader(true);
    await provider
        .doCancelOpenOrder(orderId: orderId)
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());
          if (parsed['success'] == true) {
            resetData();
            getTradePairDetails();
            Fluttertoast.showToast(msg: parsed['message']);
          } else {
            var errorMessage = "";
            List<String> keyList = <String>['order_id', 'error'];
            for (var key in keyList) {
              if (parsed['data'].toString().contains(key)) {
                errorMessage += parsed['data'][key]
                    .toString()
                    .replaceAll('null', '')
                    .replaceAll('[', '')
                    .replaceAll(']', '');
              }
            }
            Fluttertoast.showToast(msg: errorMessage);
            // Fluttertoast.showToast(message: parsed['message'], );
          }
        })
        .catchError((e) {
          setLoader(false);
          Fluttertoast.showToast(msg: e.toString());
        });
    notifyListeners();
  }

  Future doUpdateTPSL({
    required BuildContext context,
    required String tradePair,
    required String side,
    required String takeProfit,
    required String stopLoss,
  }) async {
    setLoader(true);
    await provider
        .doUpdateTPSL(
          tradePair: tradePair,
          side: side,
          takeProfit: takeProfit,
          stopLoss: stopLoss,
          tpTriggerBy: "LastPrice",
          slTriggerBy: "LastPrice",
        )
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());

          if (parsed['success'] == true) {
            resetData();
            isSuccess = true;
            Fluttertoast.showToast(msg: parsed['message']);
            getTradePairDetails();
          } else {
            isSuccess = false;
            var errorMessage = "";
            List<String> keyList = <String>[
              'liquidity_symbol',
              'tpsl_side',
              'take_profit',
              'stop_loss',
              'tp_triggerby',
              'sl_triggerby',
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
            Fluttertoast.showToast(msg: errorMessage);
            // Fluttertoast.showToast(message: parsed['message'], );
          }
        })
        .catchError((e) {
          isSuccess = false;
          setLoader(false);
          Fluttertoast.showToast(msg: e.toString());
        });
    notifyListeners();
  }


  ///KCHART
  Future<void> klineChartStreaming() async {
    try {
      if (klineTickerChannel != null) {
        await klineTickerChannel!.sink.close();
        klineTickerChannel = null;
      }
      final symbol = "${coinOne}${coinTwo}".toUpperCase();

      klineTickerChannel = IOWebSocketChannel.connect(
        Uri.parse(ApiEndpoints.FUTURE_WEB_SOCKET_URL),
      );

      klineTickerChannel!.stream.listen((event) {
        final msg = jsonDecode(event);
        handleKlineSocket(msg);
      });

      final interval = bybitInterval(selectedTime);
      print("Change Interval ${interval}");

      // subscribe
      klineTickerChannel!.sink.add(jsonEncode({
        "op": "subscribe",
        "args": ["kline.$interval.$symbol"]
      }));

      kLineSocketConnected = true;

    } catch (e) {
      print("Ticker Socket Init Error => $e");
    }
  }
  void changeInterval(String interval, BuildContext context) async {
    selectedTime = interval;
    notifyListeners();

      // close old stream
      await klineTickerChannel?.sink.close();
      kLineSocketConnected = false;

      datas = null;
      notifyListeners();

      // load correct history
      await loadBybitHistory(interval);

      // subscribe correct realtime timeframe
      klineChartStreaming();


  }


  void handleKlineSocket(Map msg) {
    if (msg['topic'] == null) return;
    if (!msg['topic'].toString().contains('kline')) return;
    if (datas == null || datas!.isEmpty) return;

    final k = msg['data'][0];

    final newCandle = KLineEntity.fromCustom(
      time: k['start'],
      open: double.parse(k['open']),
      close: double.parse(k['close']),
      high: double.parse(k['high']),
      low: double.parse(k['low']),
      vol: double.parse(k['volume']),
      amount: double.tryParse(k['turnover']?.toString() ?? "0"),
    );

    final last = datas!.last;
    /// forming candle
    if (k['confirm'] == false) {
      datas![datas!.length - 1] = newCandle;
    }

    /// closed candle
    else if (newCandle.time! > last.time!) {
      datas!.add(newCandle);

      if (datas!.length > 300) {
        datas!.removeAt(0);
      }
    }

    DataUtil.calculate(datas!);
    notifyListeners();
  }


  void setupChartStyle() {

    chartStyle.candleWidth = 5.0;
    chartStyle.candleLineWidth = 1;
    chartStyle.volWidth = 3.5;
    chartStyle.gridRows = 4;
    chartStyle.gridColumns = 4;

    notifyListeners();
  }

  setDepthChart(bool value){
    isDepthChartEnabled = value;
    notifyListeners();
  }

  reOpenFutureTrade(BuildContext context) {
    ThemeController themeController = Provider.of<ThemeController>(
      context,
      listen: false,
    );
    if (depthWebController != null) {
      depthWebController?.loadUrl(
        urlRequest: URLRequest(
          url: WebUri.uri(
            Uri.parse(
              "${ApiEndpoints.FUTURE_DEPTH_CHART_URL}${coinOne}$coinTwo&mode=${themeController.themeMode == ThemeMode.system ? Theme.of(context).brightness == Brightness.dark ? "dark" : "light" : themeController.themeMode == ThemeMode.dark ? "dark" : "light"}",
            ),
          ),
        ),
      );
    }

  }
  setDepthWebController(InAppWebViewController val) {
    depthWebController = val;
    notifyListeners();
  }
  changeChartColor(BuildContext context, bool isBuild){
    ThemeController themeController = Provider.of<ThemeController>(context, listen: false);

    final brightness = Theme.of(context).brightness;
    print("THEME change colordddd ${themeController.themeMode} The brightness ${brightness}");
    chartColors.bgColor = themeController.themeMode == ThemeMode.system ? brightness == Brightness.dark ? Colors.black : Colors.white : themeController.themeMode == ThemeMode.dark ? Colors.black : Colors.white;

    chartColors.gridColor = Colors.grey.withOpacity(0.1);
    chartColors.upColor = const Color(0xFF00C2D1); // Candle upward color
    chartColors.dnColor = const Color(0xFFFF2E93); // Candle downward color
    chartColors.ma5Color = Colors.orange; // MA5 line color
    chartColors.ma10Color = Colors.blue; // MA10 line color
    chartColors.ma30Color = Colors.purple; // MA30 line color
    chartColors.rsiColor = const Color(0xFFFF2E93); // Candle downward color
    notifyListeners();

  }

  chartInit() async {
    showLoading = true;
    notifyListeners();

    await loadBybitHistory(selectedTime); // 👈 now from Bybit

    klineChartStreaming(); // realtime updates after history




    showLoading = false;
    notifyListeners();
  }



  String bybitInterval(String ui) {
    switch (ui) {
      case '5m': return '5';
      case '15m': return '15';
      case '1h': return '60';
      case '4h': return '240';
      case '1D': return 'D';
      default: return '1';
    }
  }


  Future<void> loadBybitHistory(String interval) async {
    final symbol = "$coinOne$coinTwo".toUpperCase();
    final url =
        "https://api.bybit.com/v5/market/kline"
        "?category=linear"  // 👈 PERPETUAL
        "&symbol=$symbol"
        "&interval=${bybitInterval(interval)}"
        "&limit=300";
    // final url = "https://api.bybit.com/v5/market/kline?category=spot&symbol=$symbol&interval=${bybitInterval(interval)}&limit=300";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      debugPrint("Bybit history error");
      return;
    }

    final jsonData = jsonDecode(response.body);

    final List list = jsonData['result']['list'];
    print("JSONM DATA ${list}");

    /// IMPORTANT: Bybit returns newest → oldest
    final candles = list.reversed.map((e) {
      return KLineEntity.fromCustom(
        time: int.parse(e[0]),
        open: double.parse(e[1]),
        high: double.parse(e[2]),
        low: double.parse(e[3]),
        close: double.parse(e[4]),
        vol: double.parse(e[5]),
        amount: double.parse(e[6]),
      );
    }).toList();

    datas = candles;

    DataUtil.calculate(datas!);

    notifyListeners();
  }

  pusherInitialization() async {
    await pusher.init(
      apiKey: AppServices.pusherAppKey,
      cluster: AppServices.pusherCluster,
      onEvent: onEvent,
      onConnectionStateChange: onConnectionStateChange,
      onError: onError,
      onSubscriptionSucceeded: (channelName, data) {
        print("channelName:$channelName");
        print("CONNECT:$channelName");
      },
      onSubscriptionError: (message, error) {
        print("sub_error:${error.toString()}");
      },
    );
    await pusher.connect();
    // await pusher.cancel();
    await pusher.subscribe(
      channelName: "future.position-update.${AppStorage.getUserId()}",
    );
  }

  void onError(String message, int? code, dynamic e) {
    print("onError: $message code: $code exception: $e");
  }

  onConnectionStateChange(dynamic currentState, dynamic previousState) {}

  void onEvent(PusherEvent event) {
    try {
      print("Raw Pusher event data: ${event}");
      if (event.channelName ==
              "future.position-update.${AppStorage.getUserId()}" &&
          event.eventName.toString().trim().toLowerCase() == "update") {
        getTradePairDetails();
      }
      // final Map<String, dynamic> eventData = jsonDecode(event.data);
      //
      // if (eventData['status'] == 'reload') {
      //   getTradePairDetails();
      // }
    } catch (e, stackTrace) {
      print("Error: $e");
      print("StackTrace: $stackTrace");
    }

    notifyListeners();
  }

  byBitFuturePriceTickerSocket(String tradePair) {
    final channel = IOWebSocketChannel.connect(
      Uri.parse(ApiEndpoints.FUTURE_WEB_SOCKET_URL),
    );
    priceChannelList.add(channel);
    final message = {
      "op": "subscribe",
      "args": ["tickers.$tradePair"],
    };

    print(
      "FUTURE TRADE SOCKET DETAILS \n ${ApiEndpoints.FUTURE_WEB_SOCKET_URL} \n ${jsonEncode(message)}",
    );
    channel.sink.add(jsonEncode(message));
    channel.stream.listen((event) {
      if (event != null) {
        event = json.decode(event.toString());
        final parsed = event;
        if (parsed is! Map) return;
        if (parsed['type'] == 'snapshot') {
          // isFirstSnapshotHandled = true;
          final data = parsed['data'];
          try {
            if (data['symbol'].toString() == coinOne + coinTwo) {
              print(
                "EBEMNT DATA ${data['symbol'].toString()}  ANNANAND ${coinOne + coinTwo}",
              );

              if (data['lastPrice'] != null) {
                lastPrice = double.parse(data['lastPrice'].toString());

                /// ✅ Call your method only the first time
                if (!firstEventHandled) {
                  handleFirstEvent();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    updatePriceTextForm(data['lastPrice'].toString());
                  });
                }
              }

              if (data['price24hPcnt'] != null) {
                change24H =
                    (double.parse(data['price24hPcnt'].toString())) * 100;
              }

              if (data['volume24h'] != null) {
                volume24H = double.parse(data['volume24h'].toString());
              }

              if (data['lowPrice24h'] != null) {
                low24H = double.parse(data['lowPrice24h'].toString());
              }
              if (data['markPrice'] != null) {
                markPrice = double.parse(data['markPrice'].toString());
              }

              if (data['openInterest'] != null) {
                openInterestPrice = double.parse(
                  data['openInterest'].toString(),
                );
              }
              if (data['turnover24h'] != null) {
                turnOver24H = double.parse(data['turnover24h'].toString());
              }

              if (priceStreamController?.isClosed == false) {
                priceStreamController?.sink.add(event);
              }
            }
          } catch (e) {
            debugPrint("OrderBook parse error: $e");
          }
        }
        if (priceStreamController?.isClosed == false) {
          priceStreamController?.sink.add(event);
        }
      }
    });
    notifyListeners();
  }

  byBitFuturePriceTickerSocketFuture() {
    final channel = IOWebSocketChannel.connect(
      Uri.parse(ApiEndpoints.FUTURE_WEB_SOCKET_URL),
    );
    List<String> futurePositionPairs = [];
    String pairsVal = "";
    for (var element in futuresPositionsList) {
      futurePositionPairs.add(
        '"tickers.${element.coinOne.toString()}${element.coinTwo.toString()}"',
      );
    }
    pairsVal = futurePositionPairs.join(',');

    priceChannelList.add(channel);

    final decoded = jsonDecode('[$pairsVal]');
    final message = {"op": "subscribe", "args": decoded};

    print(
      "FUTURE TRADE SOCKET DETAILS Position \n ${ApiEndpoints.FUTURE_WEB_SOCKET_URL} \n ${jsonEncode(message)}",
    );
    channel.sink.add(jsonEncode(message));
    channel.stream.listen((event) {
      if (event != null) {
        event = json.decode(event.toString());
        final parsed = event;
        if (parsed is! Map) return;
        if (parsed['type'] == 'snapshot') {
          // isFirstSnapshotHandled = true;
          final data = parsed['data'];
          try {
            for (var element in futuresPositionsList) {
              if (data['symbol'].toString() ==
                  "${element.coinOne}${element.coinTwo}") {
                print(
                  "EBEMNT DATA ${data['symbol'].toString()}  ANNANAND ${coinOne + coinTwo}",
                );

                if (data['lastPrice'] != null) {
                  element.lastPrice = double.parse(
                    data['lastPrice'].toString(),
                  );
                }

                // if (data['price24hPcnt'] != null) {
                //   element.change =
                //       (double.parse(
                //         data['price24hPcnt'].toString(),
                //       )) *
                //           100;
                // }

                // if (data['volume24h'] != null) {
                //   volume24H = double.parse(
                //     data['volume24h'].toString(),
                //   );
                // }

                // if (data['lowPrice24h'] != null) {
                //   low24H = double.parse(
                //     data['lowPrice24h'].toString(),
                //   );
                // }
                if (data['markPrice'] != null) {
                  element.markPrice = double.parse(
                    data['markPrice'].toString(),
                  );
                }

                // if (data['turnover24h'] != null) {
                //   element.turnOver24H = double.parse(
                //     data['turnover24h'].toString(),
                //   );
                // }

                if (priceStreamController?.isClosed == false) {
                  priceStreamController?.sink.add(event);
                }
              }
            }
          } catch (e) {
            debugPrint("OrderBook parse error: $e");
          }
        }
        if (priceStreamController?.isClosed == false) {
          priceStreamController?.sink.add(event);
        }
      }
    });
    notifyListeners();
  }

  void setSelectedOrderBookType(int value) {
    if(value == 2){
      orderBookType = 0;
    }else if(value == 1){
      orderBookType = 2;
    }else{
      orderBookType = 1;
    }

    notifyListeners();
  }

  void setChartEnabled(bool value, String chartType) {
    if (chartType == 'depth') {
      isDepthChartEnabled = value;
      isPriceChartEnabled = false;
    } else {
      isPriceChartEnabled = value;
      isDepthChartEnabled = false;
      isShowingLiveBalance = false;
    }
    notifyListeners();
  }

  byBitTradeListDataUpdate() {
    final channel = IOWebSocketChannel.connect(
      Uri.parse(ApiEndpoints.FUTURE_WEB_SOCKET_URL),
    );
    priceChannelList.add(channel);

    final decoded = jsonDecode('[$pairs]');

    final message = {"op": "subscribe", "args": decoded};

    print(
      "FUTURE TRADE SOCKET DETAILS GG \n ${ApiEndpoints.FUTURE_WEB_SOCKET_URL} \n ${jsonEncode(message)}",
    );
    channel.sink.add(jsonEncode(message));
    channel.stream.listen((event) {
      if (event != null) {
        event = json.decode(event.toString());
        final parsed = event;
        if (parsed is! Map) return;

        if (parsed['type'] == 'snapshot') {
          // isFirstSnapshotHandled = true;
          final data = parsed['data'];
          try {
            for (var element in perpetualTradePairsList) {
              if ("${element.coinOne}${element.coinTwo}" ==
                  data['symbol'].toString()) {
                if (data['lastPrice'] != null) {
                  element.price = data['lastPrice'].toString();
                }
                if (data['price24hPcnt'] != null) {
                  element.change =
                      ((double.parse(data['price24hPcnt'].toString())) * 100)
                          .toStringAsFixed(3);
                }
              }
            }
          } catch (e) {
            debugPrint("OrderBook parse error: $e");
          }
        }
        if (priceStreamController?.isClosed == false) {
          priceStreamController?.sink.add(event);
        }
      }
    });
    notifyListeners();
  }

  byBitLivePriceSocket(String pair) {
    final channel = IOWebSocketChannel.connect(
      Uri.parse(ApiEndpoints.FUTURE_WEB_SOCKET_URL),
    );
    priceChannelList.add(channel);
    final message = {
      "op": "subscribe",
      "args": ["publicTrade.$tradePair"],
    };

    print(
      "FUTURE TRADE SOCKET DETAILS \n ${ApiEndpoints.FUTURE_WEB_SOCKET_URL} \n ${jsonEncode(message)}",
    );
    channel.sink.add(jsonEncode(message));
    channel.stream.listen((event) {
      if (event != null) {
        event = json.decode(event.toString());

        if (livePriceStreamController?.isClosed == false) {
          livePriceStreamController?.sink.add(event);
        }
      }
    });
    notifyListeners();
  }

  Future<void> orderBookSocketCall(String pair) async {
    try {
      if (futureOrderBookChannel != null) {
        await futureOrderBookChannel!.sink.close();
        futureOrderBookChannel = null;
      }

      var params = '{"op": "subscribe","args": ["orderbook.50.$pair"]}';

      print("Socket Params Orderbook $params");

      futureOrderBookChannel = IOWebSocketChannel.connect(
        Uri.parse(ApiEndpoints.SPOT_WEB_SOCKET_URL),
      );

      futureOrderBookChannel!.sink.add(params);

      futureOrderBookChannel!.stream.listen(
            (event) {
          try {

            if (event != null) {
              futureOrderBookStreamController.sink.add(event);
            }

            notifyListeners();
          } catch (e) {
            print("OrderBook Parse Error => $e");
          }
        },
        onError: (error) {
          print("OrderBook Socket Error => $error");
        },
        onDone: () {
          print("OrderBook Socket Closed");
        },
        cancelOnError: true,
      );
    } catch (e) {
      print("OrderBook Socket Init Error => $e");
    }
  }


  byBitFutureOrderbookSocket(String tradePair) {
    orderbookChannel = IOWebSocketChannel.connect(
      Uri.parse(ApiEndpoints.FUTURE_WEB_SOCKET_URL),
    );

    final message = {
      "op": "subscribe",
      "args": ["orderbook.50.$tradePair"],
    };

    orderbookChannel?.sink.add(jsonEncode(message));

    orderbookChannel!.stream.listen(
      (event) {
        if (event != null) {
          final parsed = jsonDecode(event);

          // ✅ Step 1: Check snapshot
          if (parsed['type'] == 'snapshot') {
            // isFirstSnapshotHandled = true;

            try {
              final data = parsed['data'];
              if (data is! Map) return;
              // if(data['s'] != controller.tradePair) {
              //   controller.asksMap.clear();
              //   controller.bidsMap.clear();
              //   return;
              // }

              /// -------- ASKS --------
              final asks = data['a'];
              if (asks is List) {
                for (final level in asks) {
                  if (level is! List || level.length < 2) continue;

                  final double price =
                      double.tryParse(level[0].toString()) ?? 0;
                  final double qty = double.tryParse(level[1].toString()) ?? 0;

                  if (price <= 0) continue;

                  if (qty == 0) {
                    asksMap.remove(price);
                  } else {
                    asksMap[price] = qty;
                  }
                }
              }

              /// -------- BIDS --------
              final bids = data['b'];
              if (bids is List) {
                for (final level in bids) {
                  if (level is! List || level.length < 2) continue;

                  final double price =
                      double.tryParse(level[0].toString()) ?? 0;
                  final double qty = double.tryParse(level[1].toString()) ?? 0;

                  if (price <= 0) continue;

                  if (qty == 0) {
                    bidsMap.remove(price);
                  } else {
                    bidsMap[price] = qty;
                  }
                }
              }
            } catch (e) {
              debugPrint("OrderBook parse error: $e");
            }

            // ✅ store in state / controller
            // controller.bestBid = firstBidPrice;
            // controller.bestAsk = firstAskPrice;
          }

          // 🔁 Step 2: Handle delta updates
          if (parsed['type'] == 'delta') {
            // update orderbook incrementally
          }

          if (orderbookStreamController?.isClosed == false) {
            orderbookStreamController?.sink.add(event);
          }
        }
      },
      onDone: () {
        print("WebSocket connection closed");
      },
      onError: (error) {
        print("WebSocket error: $error");
      },
    );

    notifyListeners();
  }

  socketDispose() {
    if (orderbookChannel != null) orderbookChannel!.sink.close();
    for (var channel in priceChannelList) {
      channel.sink.close();
    }
    priceChannelList.clear();
    pusher.unsubscribe(
      channelName: "future.position-update.${AppStorage.getUserId()}",
    );
    pusher.disconnect();
  }
}

class FutureTradePairList {
  String? id,
      coinOne,
      coinTwo,
      tradePair,
      coinOneImage,
      price,
      change,
      volume,
      markPrice,
      contractType,
      liquidity;

  FutureTradePairList({
    this.id,
    this.coinOne,
    this.coinTwo,
    this.tradePair,
    this.coinOneImage,
    this.price,
    this.change,
    this.liquidity,
    this.volume,
    this.markPrice,
    this.contractType,
  });
}

class FuturePositionsList {
  String? id,
      userId,
      pairId,
      side,
      coinOne,
      coinTwo,
      contract,
      marginType,
      tpTrigger,
      slTrigger;
  double qty,
      value,
      entryPrice,
      lastPrice,
      markPrice,
      liqPrice,
      positionIM,
      positionMM,
      unrealPnL,
      unrealPnLPerc,
      realPnL,
      takeProfit,
      stopLoss;

  int leverage, status;

  FuturePositionsList({
    this.id,
    this.userId,
    this.pairId,
    this.side,
    this.coinOne,
    this.coinTwo,
    this.contract,
    this.marginType,
    required this.leverage,
    required this.qty,
    required this.value,
    required this.entryPrice,
    required this.lastPrice,
    required this.markPrice,
    required this.liqPrice,
    required this.positionIM,
    required this.positionMM,
    required this.unrealPnL,
    required this.unrealPnLPerc,
    required this.realPnL,
    required this.takeProfit,
    required this.stopLoss,
    this.tpTrigger,
    this.slTrigger,
    required this.status,
  });
}

class FutureOpenOrdersList {
  String? id,
      userId,
      pairId,
      orderId,
      contract,
      instrument,
      orderPrice,
      qty,
      filled,
      remaining,
      tradeType,
      orderType,
      dateTime,
      takeProfit,
      stopLoss,
      status;

  FutureOpenOrdersList({
    this.id,
    this.userId,
    this.pairId,
    this.orderId,
    this.contract,
    this.instrument,
    this.orderPrice,
    this.qty,
    this.filled,
    this.remaining,
    this.tradeType,
    this.orderType,
    this.dateTime,
    this.takeProfit,
    this.stopLoss,
    this.status,
  });
}

class FuturePnLHistoryList {
  String? id,
      tradePair,
      contract,
      qty,
      entryPrice,
      exitPrice,
      side,
      closedPnL,
      exitType,
      dateTime;

  FuturePnLHistoryList({
    this.id,
    this.tradePair,
    this.contract,
    this.qty,
    this.entryPrice,
    this.exitPrice,
    this.side,
    this.closedPnL,
    this.exitType,
    this.dateTime,
  });
}

class FutureMyOrdersList {
  String? id,
      tradePair,
      contract,
      filled,
      total,
      filledPrice,
      orderPrice,
      side,
      orderType,
      status,
      statusCode,
      orderId,
      dateTime;

  FutureMyOrdersList({
    this.id,
    this.tradePair,
    this.contract,
    this.filled,
    this.total,
    this.filledPrice,
    this.orderPrice,
    this.side,
    this.orderType,
    this.status,
    this.statusCode,
    this.orderId,
    this.dateTime,
  });
}

class FutureMyOrdersTPSLList {
  String? id,
      tradePair,
      contract,
      filled,
      qty,
      takeProfit,
      stopLoss,
      takeProfitBy,
      stopLossBy,
      filledPrice,
      orderPrice,
      side,
      orderType,
      status,
      statusCode,
      orderId,
      dateTime;

  FutureMyOrdersTPSLList({
    this.id,
    this.tradePair,
    this.contract,
    this.filled,
    this.qty,
    this.takeProfit,
    this.stopLoss,
    this.takeProfitBy,
    this.stopLossBy,
    this.filledPrice,
    this.orderPrice,
    this.side,
    this.orderType,
    this.status,
    this.statusCode,
    this.orderId,
    this.dateTime,
  });
}
