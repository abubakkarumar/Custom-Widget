import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:k_chart_plus/chart_style.dart';
import 'package:k_chart_plus/entity/depth_entity.dart';
import 'package:k_chart_plus/entity/k_line_entity.dart';
import 'package:k_chart_plus/k_chart_widget.dart';
import 'package:k_chart_plus/utils/data_util.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:web_socket_channel/io.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Basics/services.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Dashboard/dashboard_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/buy_sell_tab.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/chart_order_book.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_api.dart';
import 'package:zayroexchange/Utility/global_state/global_providers.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import '../../../Utility/custom_error_message.dart';
import '../../../material_theme/theme_controller.dart';
import '../Wallet/wallet_api.dart';
import 'orderbook.dart';
import 'package:http/http.dart' as http;

class SpotTradeController extends ChangeNotifier {
  // ================= LOADING =================
  bool isLoading = false;

  // ================= API =================
  SpotTradeApi spotTradeApi = SpotTradeApi();
  WalletApi walletApi = WalletApi();

  // ================= WALLET =================
  bool isWalletShow = false;

  // ================= TAB CONTROLLERS =================
  late TabController tabViewController;
  late TabController tabViewPairController;
  late TabController tabViewChartsController;

  int selectedTab = 0;
  int selectedPairTab = 0;
  int selectedChartTab = 0;
  String selectedCoinOneDropDown = "";

  // ================= WEBVIEW =================
  InAppWebViewController? priceWebController;
  InAppWebViewController? depthWebController;

  // ================= ORDER TYPE =================
  String selectedType = "Limit";
  List<String> typeArr = ["Limit", "Market"];

  // ================= COINS =================
  List<String> coinOneArr = [];

  // ================= PRICE DATA =================
  double finalLivePrice = 0.0;
  double markPrice = 0.0;
  double percentChange = 0.0;

  String volume24h = "";
  String highPrice24h = "";
  String lowPrice24h = "";

  String highPrice24hInternal = "";
  String lowPrice24hInternal = "";
  double percentageInternal = 0.0;

  bool firstEventHandled = false;

  // ================= FORMS =================
  final tradeForm = GlobalKey<FormState>();

  // ================= TEXT CONTROLLERS =================
  final typeController = TextEditingController();
  final priceController = TextEditingController();
  final marketPriceController = TextEditingController();
  final amountController = TextEditingController();
  final totalController = TextEditingController();
  final tpTriggerPriceController = TextEditingController();
  final slTriggerPriceController = TextEditingController();
  final searchController = TextEditingController();

  // ================= VALIDATION =================
  AutovalidateMode priceAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode amountAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode totalAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode tpTriggerPriceAutoValidate = AutovalidateMode.disabled;
  AutovalidateMode slTriggerPriceAutoValidate = AutovalidateMode.disabled;

  // ================= SLIDER =================
  double sliderValue = 0.00;
  // trigger to notify external widgets when slider is reset (increments on reset)
  int sliderResetTrigger = 0;

  // ================= SWAP =================
  String fromHint = "Spot";
  String toHint = "Future";

  String fromIcon = "";
  String toIcon = "";

  // ================= BUY SELL =================
  int buySellTab = 0;

  // ================= ORDER BOOK =================
  List<OBLevel> buyObList = [];
  List<OBLevel> sellObList = [];

  final Map<double, double> bidsMap = {};
  final Map<double, double> asksMap = {};

  ScrollController scrollController = ScrollController();

  int selectedCoinOneDecimal = 2;
  int selectedCoinTwoDecimal = 2;

  // ================= SOCKET =================
  IOWebSocketChannel? spotTickerChannel;
  StreamController spotStreamController = StreamController.broadcast();

  IOWebSocketChannel? spotOrderBookChannel;
  StreamController spotOrderBookStreamController = StreamController.broadcast();

  IOWebSocketChannel? klineTickerChannel;
  StreamController klineStreamController = StreamController.broadcast();
  bool kLineSocketConnected = false;

  // ================= CHART =================
  bool isPriceChartEnabled = false;
  bool isDepthChartEnabled = false;

  // ================= PAIRS =================
  String selectedPairValue = "";

  bool isShowingLiveBalance = false;

  List<TradePair> favTradePairList = [];
  List<TradePair> tradePairList = [];
  List<TradePair> usdtTradePairList = [];
  List<TradePair> linkTradePairList = [];

  List<OrderHistoryModel> orderHistoryList = [];
  List<OrderHistoryModel> openOrderHistoryList = [];

  List<Map<dynamic, dynamic>> marketTradesList = [];

  bool isFromArena = false;

  int orderBookType = 0;

  // ================= SELECTED COIN =================
  String selectedCoinOne = "";
  String selectedCoinTwo = "";
  String selectedLiquiditySymbol = "";
  String selectedLivePrice = "";
  String selectedCoinOneImage = '';
  String selectedPairId = "";
  String selectedCoinOneBalance = "0.0";
  String selectedCoinTwoBalance = "0.0";
  String selectedCoinName = "";

  String storedLivePrice = "";
  String storedMarkPrice = "";

  double quantityDepth = 0.1;
  List<double> quantityDepthList = [0.01, 0.1, 1, 10, 100];

  List<String> tradeSocketPairs = [];
  String pairs = "";

  List<String> pairTabs(BuildContext context) => [
    AppLocalizations.of(context)!.favourites,
    AppLocalizations.of(context)!.all,
    "USDT",
    "LINK",
  ];

  ///kchart
  List<KLineEntity>? datas;
  bool showLoading = true;
  bool volHidden = false;
  // MainState mainState = MainState.MA;
  final List<MainState> mainStateLi = [MainState.MA];
  // final Set<SecondaryState> _secondaryStateLi = <SecondaryState>{};
  final List<SecondaryState> secondaryStateLi = [
    SecondaryState.KDJ,
    SecondaryState.RSI,
  ];
  List<DepthEntity>? bidsArr, asksArr;
  double? lastPrice;
  int? lastProcessedTradeId;

  ChartStyle chartStyle = ChartStyle();
  ChartColors chartColors = ChartColors();
  late Timer timer;
  String selectedTime = '5m';

  bool abstractChart = false;
  bool depthChartLoader = false;
  IOWebSocketChannel? depthChannel;

  var buyTrade = [];
  var sellTrade = [];
  // ======================================================
  // ======================= METHODS ======================
  // ======================================================

  void changeTab(int index, BuildContext context) {
    if (selectedTab == index) return;
    selectedTab = index;
    notifyListeners();
  }

  changeQuantityDepth(double val) {
    quantityDepth = val;
    notifyListeners();
  }

  void changePairTab(int index) {
    selectedPairTab = index;
    notifyListeners();
  }

  void setSelectedOrderBookType(int value) {
    if (value == 2) {
      orderBookType = 0;
    } else if (value == 1) {
      orderBookType = 2;
    } else {
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
              "${ApiEndpoints.SPOT_DEPTH_CHART_URL}${selectedCoinOne}$selectedCoinTwo&mode=${themeController.themeMode == ThemeMode.system ? Theme.of(context).brightness == Brightness.dark ? "dark" : "light" : themeController.themeMode == ThemeMode.dark ? "dark" : "light"}",
            ),
          ),
        ),
      );
    }

  }

  setDepthChart(bool value){
    isDepthChartEnabled = value;
    notifyListeners();
  }

  void setBuySellTabIndex({required int value}) {
    buySellTab = value;
    amountController.clear();
    totalController.clear();
    totalAmount = "";
    sliderValue = 0.00;
    notifyListeners();
  }

  void setLoader(bool value) {
    print("SetLoader $value");
    isLoading = value;
    notifyListeners();
  }

  void setSelectType(String val) {
    print("Live Price Check" + selectedLivePrice);
    selectedType = val;
    amountController.clear();
    totalController.clear();
    notifyListeners();
  }

  void initializeTabBar(TickerProvider tickerProvider) {
    tabViewController = TabController(length: 2, vsync: tickerProvider);

    tabViewController.addListener(() {
      if (!tabViewController.indexIsChanging) {
        selectedTab = tabViewController.index;
        notifyListeners();
      }
    });
  }

  void updateWhereComeFrom(bool value) {
    isFromArena = value;
    notifyListeners();
  }

  void enableAutoValidate() {
    priceAutoValidate = AutovalidateMode.always;
    amountAutoValidate = AutovalidateMode.always;
    totalAutoValidate = AutovalidateMode.always;
    tpTriggerPriceAutoValidate = AutovalidateMode.always;
    slTriggerPriceAutoValidate = AutovalidateMode.always;
    notifyListeners();
  }

  void disableAutoValidate() {
    priceAutoValidate = AutovalidateMode.disabled;
    amountAutoValidate = AutovalidateMode.disabled;
    totalAutoValidate = AutovalidateMode.disabled;
    tpTriggerPriceAutoValidate = AutovalidateMode.disabled;
    slTriggerPriceAutoValidate = AutovalidateMode.disabled;
    notifyListeners();
  }

  void socketDispose() {
    spotTickerChannel?.sink.close();
    spotOrderBookChannel?.sink.close();

    klineTickerChannel?.sink.close();

    priceController.clear();
    amountController.clear();
  }

  void clearData() {
    buyObList.clear();
    sellObList.clear();
    bidsMap.clear();
    asksMap.clear();

    priceController.clear();
    amountController.clear();
    totalController.clear();

    selectedTab = 0;
    selectedPairTab = 0;
    buySellTab = 0;

    sliderValue = 0.00;
    totalAmount = "";

    selectedCoinOne = "";
    selectedCoinTwo = "";
    selectedCoinOneImage = '';
    selectedPairId = "";

    selectedCoinOneBalance = "0.0";
    selectedCoinTwoBalance = "0.0";
    selectedCoinName = "";

    isPriceChartEnabled = false;
    isDepthChartEnabled = false;
    orderBookType = 0;

    storedLivePrice = "";
    storedMarkPrice = "";

    quantityDepth = 0.1;
  }

  String totalAmount = "";

  // =======================================================
  // 2️⃣ TOTAL BASED ON LAST PRICE
  // =======================================================
  void totalBasedOnLastPrice({required String lastPrice}) {
    if (priceController.text.isNotEmpty && amountController.text.isNotEmpty) {
      final double price = double.tryParse(priceController.text) ?? 0.0;

      final double amount = double.tryParse(amountController.text) ?? 0.0;
      if (selectedCoinOneDropDown == selectedCoinOne) {
        var totalAmount = (price * amount).toStringAsFixed(
          selectedCoinOneDecimal + selectedCoinTwoDecimal,
        );
        totalController.text = totalAmount;
      } else {
        var totalAmount = (amount).toStringAsFixed(4);
        totalAmount = totalAmount;
        totalController.text = totalAmount;
      }
    } else {
      totalAmount = "";
      totalController.text = "";
      sliderValue = 0.00;
    }

    notifyListeners();
  }

  clearChartData() {
    if (isPriceChartEnabled || isDepthChartEnabled) {
      isPriceChartEnabled = false;
      isDepthChartEnabled = false;
    } else {
      isPriceChartEnabled = true;
    }

    notifyListeners();
  }

  resetSlider(BuildContext context) {
    sliderValue = 0.0;
    sliderResetTrigger++;

    notifyListeners();
  }

  setSelectCoinOneDropDown(String val, BuildContext context) {
    if (selectedCoinOneDropDown == val) {
      return; // Prevent duplicate selection
    }

    selectedCoinOneDropDown = val;
    if (amountController.text.isNotEmpty &&
        amountController.text.toString().toLowerCase() != "null" &&
        amountController.text != "0.0") {
      var amount = double.parse(amountController.text);
      var lastPrice = 0.0;
      if (selectedType != "Market") {
        lastPrice = double.parse(priceController.text);
      } else {
        lastPrice = double.parse(
          selectedLiquiditySymbol.toLowerCase() == "normal"
              ? selectedLivePrice.toLowerCase()
              : finalLivePrice.toString(),
        );
      }

      double.parse(priceController.text);
      if (selectedCoinOneDropDown == selectedCoinOne) {
        var amountVal = (amount / lastPrice).toStringAsFixed(
          selectedCoinOneDecimal,
        );
        amountController.text = amountVal;
      } else {
        var amountVal = (amount * lastPrice).toStringAsFixed(
          selectedCoinOneDecimal,
        );
        amountController.text = amountVal;
      }
    }

    getTotalAmount(amount: amountController.text, context: context);

    notifyListeners();
  }

  ///KCHART
  Future<void> klineChartStreaming() async {
    try {
      if (klineTickerChannel != null) {
        await klineTickerChannel!.sink.close();
        klineTickerChannel = null;
      }
      final symbol = "$selectedCoinOne$selectedCoinTwo".toUpperCase();

      klineTickerChannel = IOWebSocketChannel.connect(
        Uri.parse(ApiEndpoints.SPOT_WEB_SOCKET_URL),
      );

      klineTickerChannel!.stream.listen((event) {
        final msg = jsonDecode(event);
        print("MESAAGFE FROM STREAM ${msg}");
        handleKlineSocket(msg);
      });

      final interval = bybitInterval(selectedTime);
      print("Change Interval ${interval}");

      // subscribe
      klineTickerChannel!.sink.add(
        jsonEncode({
          "op": "subscribe",
          "args": ["kline.$interval.$symbol"],
        }),
      );

      kLineSocketConnected = true;
    } catch (e) {
      print("Ticker Socket Init Error => $e");
    }
  }

  void changeInterval(String interval, BuildContext context) async {
    selectedTime = interval;
    notifyListeners();

    if (selectedLiquiditySymbol == "normal") {
      orderBookDetails(context: context);
    } else {
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
  }

  void handleKlineSocket(Map msg) {
    if (msg['topic'] == null) return;
    if (!msg['topic'].toString().contains('kline')) return;
    if (datas == null || datas!.isEmpty) return;

    final k = msg['data'][0];

    final newCandle = KLineEntity.fromCustom(
      time: k['start'], // timestamp
      open: double.parse(k['open']),
      close: double.parse(k['close']),
      high: double.parse(k['high']),
      low: double.parse(k['low']),
      vol: double.parse(k['volume']),
      amount: double.tryParse(k['turnover']?.toString() ?? "0"),
    );

    final last = datas!.last;

    /// SAME CANDLE → UPDATE (forming candle)
    if (last.time == newCandle.time) {
      datas![datas!.length - 1] = newCandle;
    }
    /// NEW CANDLE → APPEND (closed candle)
    else if (newCandle.time! > last.time!) {
      datas!.add(newCandle);

      if (datas!.length > 300) {
        datas!.removeAt(0);
      }
    }

    // recalc indicators (MA/EMA/MACD...)
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

  changeChartColor(BuildContext context, bool isBuild) {
    ThemeController themeController = Provider.of<ThemeController>(
      context,
      listen: false,
    );

    final brightness = Theme.of(context).brightness;
    print(
      "THEME change colordddd ${themeController.themeMode} The brightness ${brightness}",
    );
    chartColors.bgColor = themeController.themeMode == ThemeMode.system
        ? brightness == Brightness.dark
              ? Colors.black
              : Colors.white
        : themeController.themeMode == ThemeMode.dark
        ? Colors.black
        : Colors.white;

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

    if (selectedLiquiditySymbol.toString().toLowerCase() == "normal") {
      return;
    }

    await loadBybitHistory(selectedTime); // 👈 now from Bybit

    klineChartStreaming(); // realtime updates after history

    showLoading = false;
    notifyListeners();
  }

  String bybitInterval(String ui) {
    switch (ui) {
      case '5m':
        return '5';
      case '15m':
        return '15';
      case '1h':
        return '60';
      case '4h':
        return '240';
      case '1D':
        return 'D';
      default:
        return '1';
    }
  }

  Future<void> loadBybitHistory(String interval) async {
    final symbol = "$selectedCoinOne$selectedCoinTwo".toUpperCase();

    final url =
        "https://api.bybit.com/v5/market/kline?category=spot&symbol=$symbol&interval=${bybitInterval(interval)}&limit=300";
    print("LOAD HISTORY URL ${url}");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      debugPrint("Bybit history error");
      return;
    }

    final jsonData = jsonDecode(response.body);

    final List list = jsonData['result']['list'];

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

  int timeframeMs(String tf) {
    switch (tf) {
      case '5m':
        return 5 * 60 * 1000;
      case '15m':
        return 15 * 60 * 1000;
      case '1h':
        return 60 * 60 * 1000;
      case '4h':
        return 4 * 60 * 60 * 1000;
      case '1D':
        return 24 * 60 * 60 * 1000;
      default:
        return 60 * 1000; // 1m
    }
  }

  int parseDate(String d) {
    return DateTime.parse(d.replaceFirst(' ', 'T')).millisecondsSinceEpoch;
  }

  // =======================================================
  // 4️⃣ GET TOTAL AMOUNT (LIMIT + MARKET)
  // =======================================================
  void getTotalAmount({required String amount, required BuildContext context}) {
    // if (amount.isEmpty) {
    //   totalController.text = "";
    //   sliderValue = 0.00;
    //   notifyListeners();
    //   return;
    // }
    //
    // final double amountValue = double.tryParse(amount) ?? 0.0;
    //
    // double price = 0.0;
    //
    // if (selectedType != "Market") {
    //   price = double.tryParse(priceController.text) ?? 0.0;
    // } else {
    //   price = finalLivePrice;
    // }
    //
    // if (price <= 0) {
    //   totalController.text = "";
    //   sliderValue = 0.00;
    //   notifyListeners();
    //   return;
    // }
    //
    // totalAmount = (price * amountValue).toStringAsFixed(
    //   selectedCoinOneDecimal + selectedCoinTwoDecimal,
    // );
    //
    // totalController.text = totalAmount;
    //
    // notifyListeners();

    if (selectedType != "Market") {
      if (priceController.text.isNotEmpty) {
        if (amount.isNotEmpty) {
          var amount0 = double.parse(amount);
          var lastPrice = double.parse(priceController.text);
          double.parse(priceController.text);
          if (selectedCoinOneDropDown == selectedCoinOne) {
            var totalAmount = (lastPrice * amount0).toStringAsFixed(
              selectedCoinOneDecimal + selectedCoinTwoDecimal,
            );
            totalAmount = totalAmount;
            totalController.text = totalAmount;
          } else {
            var totalAmount = (amount0).toStringAsFixed(
              selectedCoinOneDecimal + selectedCoinTwoDecimal,
            );
            totalAmount = totalAmount;
            totalController.text = totalAmount;
          }
        } else {
          totalController.text = "";
          sliderValue = 0.00;
        }
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   CustomErrorSnackBar().getSnackBar("Please fill the price", context),
        // );
      }
    } else {
      print("Final live price $finalLivePrice");

      if (finalLivePrice.toString().isNotEmpty) {
        if (amount.isNotEmpty) {
          var amount0 = double.parse(amount);
          var lastPrice = double.parse(finalLivePrice.toString());
          double.parse(finalLivePrice.toString());
          if (selectedCoinOneDropDown == selectedCoinOne) {
            var totalAmount = (lastPrice * amount0).toStringAsFixed(
              selectedCoinOneDecimal + selectedCoinTwoDecimal,
            );
            totalAmount = totalAmount;
            totalController.text = totalAmount;
          } else {
            var totalAmount = (amount0).toStringAsFixed(
              selectedCoinOneDecimal + selectedCoinTwoDecimal,
            );
            totalAmount = totalAmount;
            totalController.text = totalAmount;
          }
        } else {
          totalController.text = "";
          sliderValue = 0.00;
        }
      } else {}
    }

    notifyListeners();
  }

  // =======================================================
  // 5️⃣ INITIALIZE PAIR TAB BAR
  // =======================================================
  void initializeTabBarPair(TickerProvider tickerProvider) {
    tabViewPairController = TabController(length: 3, vsync: tickerProvider);

    tabViewPairController.addListener(() {
      if (!tabViewPairController.indexIsChanging) {
        selectedPairTab = tabViewPairController.index;
        notifyListeners();
      }
    });
  }

  // =======================================================
  // SET LIVE PRICE VALUES
  // =======================================================
  void setLivePrice(
    String price,
    String mPrice,
    String pChange,
    String volume24hValue,
    String highPrice24hValue,
    String lowPrice24hValue,
  ) {
    finalLivePrice = double.tryParse(price) ?? 0.0;
    markPrice = double.tryParse(mPrice) ?? 0.0;
    if (pChange.isNotEmpty && pChange.toString().toLowerCase() != "null") {
      if (double.parse(pChange) > 0) {
        percentChange = double.tryParse(pChange) ?? 0.0;
      }
    }

    volume24h = volume24hValue.isNotEmpty ? volume24hValue : "";
    highPrice24h = highPrice24hValue.isNotEmpty ? highPrice24hValue : "";
    lowPrice24h = lowPrice24hValue.isNotEmpty ? lowPrice24hValue : "";
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

  // =======================================================
  // SLIDER PERCENTAGE CALCULATION
  // =======================================================
  void percentageBasedAmountAndTotalAmount({
    required double value,
    required BuildContext c,
  }) {
    sliderValue = value * 100;
    print("Percentage value ${value}");

    if (sliderValue <= 0) {
      amountController.text = "0.0";
      totalController.text = "0.0";
      notifyListeners();
      return;
    }

    double percentageVal = 0.0;
    double total = 0.0;

    final bool isMarket = selectedType.toLowerCase() == "market";

    // ================= SELL =================
    if (buySellTab == 1) {
      if (!isMarket && priceController.text.isEmpty) {
        CustomAnimationToast.show(
          message:
              "${AppLocalizations.of(c)!.sell} ${AppLocalizations.of(c)!.priceRequired}",
          context: c,
          type: ToastType.error,
        );
        return;
      }

      final double balance = double.tryParse(selectedCoinOneBalance) ?? 0.0;

      percentageVal = balance * (sliderValue / 100);

      if (isMarket) {
        total = selectedLiquiditySymbol.toLowerCase() == "normal"
            ? (double.tryParse(selectedLivePrice) ?? 0.0) * percentageVal
            : finalLivePrice * percentageVal;
      } else {
        total = (double.tryParse(priceController.text) ?? 0.0) * percentageVal;
      }

      if (selectedCoinOneDropDown == selectedCoinOne) {
        amountController.text = percentageVal.toStringAsFixed(
          selectedCoinOneDecimal,
        );
      } else {
        amountController.text = total.toStringAsFixed(selectedCoinOneDecimal);
      }

      totalController.text = total.toStringAsFixed(selectedCoinTwoDecimal);
    }
    // ================= BUY =================
    else {
      if (!isMarket && priceController.text.isEmpty) {
        CustomAnimationToast.show(
          message:
              "${AppLocalizations.of(c)!.buy} ${AppLocalizations.of(c)!.priceRequired}",
          context: c,
          type: ToastType.error,
        );
        return;
      }

      final double balance = double.tryParse(selectedCoinTwoBalance) ?? 0.0;

      percentageVal = balance * (sliderValue / 100);

      if (isMarket) {
        total = selectedLiquiditySymbol.toLowerCase() == "normal"
            ? percentageVal / (double.tryParse(selectedLivePrice) ?? 1)
            : percentageVal / finalLivePrice;
      } else {
        total = percentageVal / (double.tryParse(priceController.text) ?? 1);
      }

      if (selectedCoinOneDropDown == selectedCoinOne) {
        amountController.text = total.toStringAsFixed(selectedCoinOneDecimal);
      } else {
        amountController.text = percentageVal.toStringAsFixed(
          selectedCoinOneDecimal,
        );
      }

      totalController.text = percentageVal.toStringAsFixed(
        selectedCoinTwoDecimal,
      );
    }

    notifyListeners();
  }

  // =======================================================
  // CHART TAB BAR INITIALIZATION
  // =======================================================
  void initializeChartsTabBar(TickerProvider tickerProvider) {
    tabViewChartsController = TabController(length: 2, vsync: tickerProvider);

    tabViewChartsController.addListener(() {
      if (!tabViewChartsController.indexIsChanging) {
        selectedChartTab = tabViewChartsController.index;
        notifyListeners();
      }
    });
  }

  Future<void> getTradePairs(BuildContext context, bool isNew) async {
    setLoader(true);
    print("Getting trade pairs...");
    try {
      final value = await spotTradeApi.getTradePairs();

      final parsed = json.decode(value.toString());

      setLoader(false);


      if (parsed["success"] == true) {
        tradePairList.clear();
        usdtTradePairList.clear();
        linkTradePairList.clear();
        tradeSocketPairs.clear();
        pairs = "";
        print("Parsed Trade Pairs: ${parsed["data"]["tradePairs"]}");

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
                isFavorite: false,
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
                  isFavorite: false,
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
                  isFavorite: false,
                ),
              );
            }
          }

          if (tradePairList.isNotEmpty) {
            getFavTradePairs(context);
            print("GETDIRECT DATA ${selectedPairValue} $isNew");
            if (selectedPairValue == "" || isNew == true) {
              selectedTradePair(tradePairList.first, context, 'new');
            } else {
              for (var item in tradePairList) {
                if ("${item.coinOne}${item.coinTwo}" == selectedPairValue) {
                  selectedTradePair(item, context, 'new');
                  break;
                }
              }
            }
          }
        }

        notifyListeners();
      } else {
        _showParsedError(context, parsed, ["error"]);
      }
    } catch (e) {
      setLoader(false);
      print("Error in Trade Pairs: ${e.toString()}");
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future<void> getLivePriceFromApi(BuildContext context, bool isNew) async {
    setLoader(true);
    print("Getting Live pairs...");
    try {
      List<TradePair> pairList = [];
      final value = await spotTradeApi.getTradePairs();

      final parsed = json.decode(value.toString());

      setLoader(false);

      if (parsed["success"] == true) {
        pairList.clear();

        print("Parsed Trade Pairs: ${parsed["data"]["tradePairs"]}");

        if (parsed["data"]["tradePairs"].toString() != "[]") {
          for (var data in parsed["data"]["tradePairs"]) {
            pairList.add(
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
                isFavorite: false,
              ),
            );
          }

          if (pairList.isNotEmpty) {
              for (var item in pairList) {
                print("Pairlist connect ${item.coinOne}${item.coinTwo} == $selectedPairValue");
                if ("${item.coinOne}${item.coinTwo}" == selectedPairValue) {
                  print("Pair Live price ${item.livePrice}");
                  selectLivePriceUpdate(item);
                  break;
                }
            }
          }
        }

        notifyListeners();
      } else {
        _showParsedError(context, parsed, ["error"]);
      }
    } catch (e) {
      setLoader(false);
      print("Error in Trade Pairs: ${e.toString()}");
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  /// Hydrates trade pairs from global Riverpod cache to avoid duplicate API calls.
  void applyTradePairs(
    List<GlobalTradePair> pairsFromCache,
    BuildContext context,
    bool isNew,
  ) {
    tradePairList.clear();
    usdtTradePairList.clear();
    linkTradePairList.clear();
    tradeSocketPairs.clear();
    pairs = "";

    for (final data in pairsFromCache) {
      if (data.liquidityType.toLowerCase() == 'bybit' &&
          data.liquiditySymbol.isNotEmpty) {
        tradeSocketPairs.add('"tickers.${data.liquiditySymbol}"');
        pairs = tradeSocketPairs.join(',');
      }

      final mapped = _mapGlobalPair(data);
      tradePairList.add(mapped);

      if (data.coinTwo.toLowerCase() == "usdt") {
        usdtTradePairList.add(_mapGlobalPair(data));
      }

      if (data.coinTwo.toLowerCase() == "link") {
        linkTradePairList.add(_mapGlobalPair(data));
      }
    }

    if (tradePairList.isNotEmpty) {
      getFavTradePairs(context);
      if (selectedPairValue == "" || isNew == true) {
        selectedTradePair(tradePairList.first, context, 'new');
      } else {
        for (var item in tradePairList) {
          if ("${item.coinOne}${item.coinTwo}" == selectedPairValue) {
            selectedTradePair(item, context, 'new');
            break;
          }
        }
      }
    }

    notifyListeners();
  }

  TradePair _mapGlobalPair(GlobalTradePair data) {
    return TradePair(
      id: data.id,
      coinOne: data.coinOne,
      coinTwo: data.coinTwo,
      coinOneName: data.coinOneName,
      coinTwoName: data.coinTwoName,
      image: data.image,
      coinOneDecimal: data.coinOneDecimal,
      coinTwoDecimal: data.coinTwoDecimal,
      liquidityType: data.liquidityType,
      liquiditySymbol: data.liquiditySymbol,
      minBuyPrice: data.minBuyPrice,
      minBuyAmount: data.minBuyAmount,
      minSellPrice: data.minSellPrice,
      minSellAmount: data.minSellAmount,
      minBuyTotal: data.minBuyTotal,
      minSellTotal: data.minSellTotal,
      livePrice: data.livePrice,
      volume24h: data.volume24h,
      change24hPercentage: data.change24hPercentage,
      isActive: data.isActive == true ? 1 : 0,
      isFavorite: false,
    );
  }

  Future<void> getFavTradePairs(BuildContext context) async {
    // setLoader(true);
    FormData data = FormData.fromMap({"category": "spot"});

    try {
      final value = await spotTradeApi.getFavList(data);

      final parsed = json.decode(value.toString());
      setLoader(false);

      print("Parsed Trade Pairs: ${parsed["data"]["tradePairs"]}");

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

        if (favTradePairList.isNotEmpty && tradePairList.isNotEmpty) {
          for (var element in tradePairList) {
            for (var favElement in favTradePairList) {
              if (element.id == favElement.id) {
                element.isFavorite = true;
                notifyListeners();
              }
            }
          }
        }

        if (favTradePairList.isNotEmpty && usdtTradePairList.isNotEmpty) {
          for (var element in usdtTradePairList) {
            for (var favElement in favTradePairList) {
              if (element.id == favElement.id) {
                element.isFavorite = true;
                notifyListeners();
              }
            }
          }
        }

        if (favTradePairList.isNotEmpty && linkTradePairList.isNotEmpty) {
          for (var element in linkTradePairList) {
            for (var favElement in favTradePairList) {
              if (element.id == favElement.id) {
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
      print("Error in Trade Pairs: ${e.toString()}");
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }

  Future getTotalCalculationFromSlider({
    required BuildContext context,
    required String percentage,
  }) async {
    setLoader(true);

    FormData data = FormData.fromMap({
      "order_type": selectedType.toString().toLowerCase(),
      "pair": selectedPairId,
      "percentage": percentage,
      "price": priceController.text.toString(),
      "side": buySellTab == 0 ? 'buy' : 'sell',
    });

    print("Total Calculation: ${data.fields}");

    await spotTradeApi
        .getTotalCalculationSlider(data)
        .then((value) {
          setLoader(false);
          var response = json.decode(value.toString());

          if (response['success']) {
            amountController.clear();
            totalController.clear();

            amountController.text = response['data']['volume'].toString();
            totalController.text = response['data']['total'].toString();

            notifyListeners();
          } else {
            FocusScope.of(context).requestFocus(FocusNode());
            _showParsedError(context, response, ["error"]);
          }
        })
        .catchError((e) {
          setLoader(false);
          print("Error in Total Calculation: ${e.toString()}");
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
  }

  Future postOrderLimit({required BuildContext context}) async {
    setLoader(true);

    var _ = "0.0";

    var amountVal = "0.0";

    if (selectedCoinOneDropDown != selectedCoinOne) {
      if (selectedType != "Market") {
        var price = double.parse(priceController.text);
        var amount = double.parse(amountController.text);
        amountVal = (amount / price).toStringAsFixed(18);

        print("New Amount $amountVal");
      } else {
        var price = double.parse(
          selectedLiquiditySymbol.toString().toLowerCase() == "normal"
              ? selectedLivePrice.toString()
              : finalLivePrice.toString(),
        );
        var amount = double.parse(amountController.text);
        amountVal = (amount / price).toStringAsFixed(18);

        print("New Amount $amountVal");
      }
    }

    FormData data = FormData.fromMap({
      "pair": selectedPairId,
      "price": priceController.text.toString(),
      "volume": (selectedCoinOneDropDown != selectedCoinOne)
          ? amountVal
          : amountController.text.toString(),
      "order_type": selectedType.toString().toLowerCase(),
      "side": buySellTab == 0 ? 'buy' : 'sell',
      "category": "spot",
      "total": selectedType.toString().toLowerCase() == "market"
          ? 1
          : totalController.text.toString(),
      "coin": selectedCoinOne.toString(),
    });

    // FormData data = FormData.fromMap({
    //   "pair": selectedPairId,
    //   "price": priceController.text.toString(),
    //   "volume": amountController.text.toString(),
    //   "order_type": selectedType.toString().toLowerCase(),
    //   "side": buySellTab == 0 ? 'buy' : 'sell',
    //   "category": "spot",
    //   "total": selectedType.toString().toLowerCase() == "market"
    //       ? 1
    //       : totalController.text.toString(),
    //   "coin": selectedCoinOne.toString(),
    // });

    print("FORMDATA ${data.fields}");

    await spotTradeApi
        .postLimitBuy(data)
        .then((value) {
          setLoader(false);
          var response = json.decode(value.toString());

          if (response['success']) {
            Navigator.of(context).pop();
            _showSuccessToast(context, response['message']);
            amountController.clear();
            totalController.clear();
            disableAutoValidate();
            //getOrderHistory(context);
            notifyListeners();
          } else {
            FocusScope.of(context).requestFocus(FocusNode());
            _showParsedError(context, response, ["error"]);
          }
        })
        .catchError((e) {
          setLoader(false);
          print("Error in postOrderLimit: ${e.toString()}");
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
  }

  Future postOrderMarket({required BuildContext context}) async {
    setLoader(true);

    FormData data = FormData.fromMap({
      "pair": selectedPairId,
      "price": priceController.text.toString(),
      "volume": amountController.text.toString(),
      "order_type": selectedType.toString().toLowerCase(),
      "side": buySellTab == 0 ? 'buy' : 'sell',
      "category": "spot",
    });

    await spotTradeApi
        .postLimitBuy(data)
        .then((value) {
          setLoader(false);
          var response = json.decode(value.toString());

          if (response['success']) {
            _showSuccessToast(context, response['message']);
            amountController.clear();
            totalController.clear();
            // getOrderHistory(context);
            notifyListeners();
          } else {
            FocusScope.of(context).requestFocus(FocusNode());
            _showParsedError(context, response, ["error"]);
          }
        })
        .catchError((e) {
          setLoader(false);
          print("Error in postOrderMarket: ${e.toString()}");
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
  }

  Future<void> getOrderHistory(BuildContext context) async {
    setLoader(true);
    print("Getting order history}");
    FormData data = FormData.fromMap({
      "category": "spot",
      "pair": selectedPairId,
    });

    print("Selected Pair for Order History: ${data.fields}");

    await spotTradeApi
        .getSpotOrderHistory(data)
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());

          if (parsed['success'] == true) {
            openOrderHistoryList.clear();
            orderHistoryList.clear();

            if (parsed['data']['transactions'].toString() != "[]") {
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
                      createdAt: updateDateTimeFormat(
                        data['createdAt'].toString(),
                      ),
                    ),
                  );
                } else {
                  orderHistoryList.add(
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
                      createdAt: updateDateTimeFormat(
                        data['createdAt'].toString(),
                      ),
                    ),
                  );
                }
              }
              notifyListeners();
            }

            notifyListeners();
          } else {
            FocusScope.of(context).requestFocus(FocusNode());
            _showParsedError(context, parsed, ["error"]);
          }
        })
        .catchError((e) {
          setLoader(false);
          print("Error in getOrderHistory: ${e.toString()}");
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });

    notifyListeners();
  }

  Future cancelOrder({
    required BuildContext context,
    required String id,
    required String type,
  }) async {
    setLoader(true);

    FormData data = FormData.fromMap({
      "category": "spot",
      "order_id": id,
      "side": type,
    });

    await spotTradeApi
        .cancelSpotOrder(data)
        .then((value) {
          setLoader(false);
          var response = json.decode(value.toString());

          if (response['success']) {
            _showSuccessToast(context, response['message']);
            Navigator.pop(context);
            // getOrderHistory(context);
            // getCoinBalances(context);

            notifyListeners();
          } else {
            FocusScope.of(context).requestFocus(FocusNode());
            _showParsedError(context, response, ["error"]);
          }
        })
        .catchError((e) {
          setLoader(false);
          print("Error in cancelOrder: ${e.toString()}");
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
  }

  Future removeFav({
    required BuildContext context,
    required String id,
    required TradePair item,
  }) async {
    item.isFavorite = false;
    final index = tradePairList.indexWhere((e) => e.id.toString() == id);

    if (index != -1) {
      tradePairList[index].isFavorite = false;
    }

    final usdtIndex = usdtTradePairList.indexWhere(
      (e) => e.id.toString() == id,
    );

    if (usdtIndex != -1) {
      usdtTradePairList[usdtIndex].isFavorite = false;
    }

    final linkIndex = linkTradePairList.indexWhere(
      (e) => e.id.toString() == id,
    );

    if (linkIndex != -1) {
      linkTradePairList[linkIndex].isFavorite = false;
    }

    notifyListeners();

    setLoader(true);

    FormData data = FormData.fromMap({"category": "spot", "pair_id": id});

    await spotTradeApi
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
          print("Error in cancelOrder: ${e.toString()}");
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
    required TradePair item,
  }) async {
    item.isFavorite = true;

    notifyListeners();

    FormData data = FormData.fromMap({"category": "spot", "pair_id": id});

    await spotTradeApi
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
          print("Error in cancelOrder: ${e.toString()}");
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
  }

  List<OBLevel> internalBuyList = [];
  List<OBLevel> internalSellList = [];
  List<OBLevelKChart> internalBuyListKChart = [];
  List<OBLevelKChart> internalSellListKChart = [];
  TradeType tradeType = TradeType.buy;

  changeTradeType(TradeType val) {
    tradeType = val;
    notifyListeners();
  }

  Future orderBookDetails({required BuildContext context}) async {
    setLoader(true);

    FormData data = FormData.fromMap({
      "liquidity_symbol":
          selectedLiquiditySymbol.toString().toLowerCase() == "normal"
          ? "${selectedCoinOne}_$selectedCoinTwo"
          : "$selectedCoinOne$selectedCoinTwo",
    });

    await spotTradeApi
        .orderBookDetails(data)
        .then((value) {
          print("OrderBOOK API POST ${data.fields}");

          setLoader(false);

          var parsed = json.decode(value.toString());

          internalBuyList.clear();
          internalSellList.clear();
          internalSellListKChart.clear();
          internalBuyListKChart.clear();

          if (parsed['success'] == true) {
            if (parsed['data']['buyOrderBook'].toString() != "[]") {
              for (var data in parsed['data']['buyOrderBook']) {
                internalBuyList.add(
                  OBLevel(
                    price: double.parse(
                      data['price'] != null &&
                              data['price'].toString().toLowerCase() != "null"
                          ? data['price'].toString()
                          : "0.0",
                    ),
                    qty: double.parse(
                      data['remaining_qty'] != null &&
                              data['remaining_qty'].toString().toLowerCase() !=
                                  "null"
                          ? data['remaining_qty'].toString()
                          : "0.0",
                    ),
                  ),
                );

                internalBuyListKChart.add(
                  OBLevelKChart(
                    price: double.parse(
                      data['price'] != null &&
                              data['price'].toString().toLowerCase() != "null"
                          ? data['price'].toString()
                          : "0.0",
                    ),
                    qty: double.parse(
                      data['remaining_qty'] != null &&
                              data['remaining_qty'].toString().toLowerCase() !=
                                  "null"
                          ? data['remaining_qty'].toString()
                          : "0.0",
                    ),
                  ),
                );
              }
            }

            notifyListeners();

            if (parsed['data']['sellOrderBook'].toString() != "[]") {
              for (var data in parsed['data']['sellOrderBook']) {
                internalSellList.add(
                  OBLevel(
                    price: double.parse(
                      data['price'] != null &&
                              data['price'].toString().toLowerCase() != "null"
                          ? data['price'].toString()
                          : "0.0",
                    ),
                    qty: double.parse(
                      data['remaining_qty'] != null &&
                              data['remaining_qty'].toString().toLowerCase() !=
                                  "null"
                          ? data['remaining_qty'].toString()
                          : "0.0",
                    ),
                  ),
                );
                internalSellListKChart.add(
                  OBLevelKChart(
                    price: double.parse(
                      data['price'] != null &&
                              data['price'].toString().toLowerCase() != "null"
                          ? data['price'].toString()
                          : "0.0",
                    ),
                    qty: double.parse(
                      data['remaining_qty'] != null &&
                              data['remaining_qty'].toString().toLowerCase() !=
                                  "null"
                          ? data['remaining_qty'].toString()
                          : "0.0",
                    ),
                  ),
                );
                notifyListeners();
              }
            }

            if (selectedLiquiditySymbol.toString().toLowerCase() == "normal") {
              // datas = buildKlines(parsed['data']['tradeHistory'], selectedTime);
              print("TRADE ORDERBOOK Hello");
              // loadTradeHistory(parsed['data']['tradehistory_k_charts']);
              /// STEP 2: then listen live trades

              if (parsed['data']['tradehistory_k_charts'].toString() != "[]") {
                print(
                  "Orderbook Data ${parsed['data']['tradehistory_k_charts']}",
                );
                List<dynamic> rawList = parsed['data']['tradehistory_k_charts'];

                List<List<String>> formattedKlines = rawList.map<List<String>>((
                  item,
                ) {
                  return [
                    item['timestamp'].toString(),
                    item['open'].toString(),
                    item['high'].toString(),
                    item['low'].toString(),
                    item['close'].toString(),
                    item['vol'].toString(),
                    item['amount'].toString(),
                  ];
                }).toList();

                print("TRADE ORDERBOOK ${formattedKlines}");

                // final List list = jsonData['result']['list'];

                /// IMPORTANT: Bybit returns newest → oldest
                final candles = formattedKlines.reversed.map((e) {
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
              // for (var trade in parsed['data']['tradehistory_k_charts']) {
              //   processLiveTrade(trade);
              // }

              notifyListeners();
            }

            if (parsed['data']['marketInfo'].toString() != "[]") {
              for (var data in parsed['data']['marketInfo']) {
                if ((data['sy'].toString() ==
                        selectedCoinOne + selectedCoinTwo) ||
                    (data['sy'].toString() ==
                        "${selectedCoinOne}_$selectedCoinTwo")) {
                  selectedLivePrice = data['p'].toString();
                  highPrice24hInternal = data['h'].toString();
                  lowPrice24hInternal = data['l'].toString();
                  percentageInternal = double.parse(
                    (data['e'].toString().isNotEmpty &&
                            data['e'].toString().toLowerCase() != "null")
                        ? data['e'].toString()
                        : "0.0",
                  );
                }
                notifyListeners();
              }
            }
          } else {
            print("Order Book Details of internal Trade");
            FocusScope.of(context).requestFocus(FocusNode());
            _showParsedError(context, parsed, ["error"]);
          }
        })
        .catchError((e) {
          setLoader(false);
          print("Error in cancelOrder: ${e.toString()}");
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
  }

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

  setPriceWebController(InAppWebViewController val) {
    priceWebController = val;
    notifyListeners();
  }

  setDepthWebController(InAppWebViewController val) {
    depthWebController = val;
    notifyListeners();
  }

  selectFromOutside(String pair) {
    selectedPairValue = pair;
    notifyListeners();
  }
  clearSelectedPair(){
    selectedPairValue = "";
    notifyListeners();
  }

  selectedTradePair(TradePair tradePair, BuildContext context, String type) {
    print("Selected Trade pAir ${tradePair.livePrice}");
    selectedCoinOneDecimal = tradePair.coinOneDecimal ?? 2;
    selectedCoinTwoDecimal = tradePair.coinTwoDecimal ?? 2;
    selectedCoinOne = tradePair.coinOne!;
    selectedCoinTwo = tradePair.coinTwo!;

    selectedTime = "5m";
    amountController.clear();
    totalController.clear();
    changeQuantityDepth(0.1);
    resetSlider(context);
    klineTickerChannel?.sink.close();

    setSelectCoinOneDropDown(selectedCoinOne, context);
    selectedLiquiditySymbol = tradePair.liquidityType.toString();
    selectedLivePrice = tradePair.livePrice.toString();

    coinOneArr.clear();
    coinOneArr.add(selectedCoinOne);
    coinOneArr.add(selectedCoinTwo);

    selectedCoinOneImage = tradePair.image ?? "";
    selectedPairId = tradePair.id.toString();

    priceController.text = double.parse(
      tradePair.livePrice.toString(),
    ).toStringAsFixed(selectedCoinTwoDecimal);

    selectedPairValue = "${tradePair.coinOne}${tradePair.coinTwo}";

    bidsMap.clear();
    asksMap.clear();

    notifyListeners();

    byTickerBitSocketCall(selectedPairValue);
    orderBookSocketCall(selectedPairValue);

    // ✅ BEFORE calling async functions

    getCoinBalances(context);
    orderBookDetails(context: context);
    getOrderHistory(context);
    initPusher(context);

    notifyListeners();

    if (isPriceChartEnabled == true || isDepthChartEnabled == true) {
      isPriceChartEnabled = false;
      notifyListeners();
    }

    // if (priceWebController != null) {
    //   priceWebController?.loadUrl(
    //     urlRequest: URLRequest(
    //       url: WebUri.uri(
    //         Uri.parse(
    //           "${ApiEndpoints.SPOT_PRICE_CHART_URL}${selectedCoinOne}_$selectedCoinTwo",
    //         ),
    //       ),
    //     ),
    //   );
    // }

      ThemeController themeController = Provider.of<ThemeController>(
        context,
        listen: false,
      );
      if (depthWebController != null) {
        depthWebController?.loadUrl(
          urlRequest: URLRequest(
            url: WebUri.uri(
              Uri.parse(
                "${ApiEndpoints.SPOT_DEPTH_CHART_URL}${selectedCoinOne}$selectedCoinTwo&mode=${themeController.themeMode == ThemeMode.system ? Theme.of(context).brightness == Brightness.dark ? "dark" : "light" : themeController.themeMode == ThemeMode.dark ? "dark" : "light"}",
              ),
            ),
          ),
        );
      }



    // if (depthWebController != null) {
    //   depthWebController?.loadUrl(
    //     urlRequest: URLRequest(
    //       url: WebUri.uri(
    //         Uri.parse(
    //           "${ApiEndpoints.SPOT_DEPTH_CHART_URL}${selectedCoinOne}_$selectedCoinTwo",
    //         ),
    //       ),
    //     ),
    //   );
    // }

    orderBookSocketCall(selectedPairValue);
    byTickerBitSocketCall(selectedPairValue);

    firstEventHandled = false;

    if (type == "update") {
      Navigator.of(context).pop();
    }
  }

  selectLivePriceUpdate(TradePair tradePair) {
    selectedLivePrice = tradePair.livePrice.toString();
    percentageInternal = double.parse(
      tradePair.change24hPercentage != null &&
          tradePair.change24hPercentage.toString().toLowerCase() != "null"
          ? tradePair.change24hPercentage.toString()
          : "0.0",
    );
    notifyListeners();
  }

  setLiveAndChangeTwentyFourData(String lPrice, String changeTwentyFourData, String h, String l){
    selectedLivePrice = lPrice;
    percentageInternal =  double.parse(
      changeTwentyFourData != null &&
          changeTwentyFourData.toString().toLowerCase() != "null"
          ? changeTwentyFourData.toString()
          : "0.0",
    );
    highPrice24hInternal = h;
    lowPrice24hInternal = l;
    notifyListeners();
  }

  /// Spot Ticker Socket
  Future<void> byTickerBitSocketCall(String pair) async {
    try {
      if (spotTickerChannel != null) {
        await spotTickerChannel!.sink.close();
        spotTickerChannel = null;
      }

      final params = {
        "op": "subscribe",
        "args": ["tickers.$pair"],
      };

      print("WebSocket Values---------->$params");

      spotTickerChannel = IOWebSocketChannel.connect(
        Uri.parse(ApiEndpoints.SPOT_WEB_SOCKET_URL),
      );

      spotTickerChannel!.sink.add(jsonEncode(params));

      spotTickerChannel!.stream.listen(
        (event) {
          try {
            final Map<String, dynamic> parsed = event is String
                ? jsonDecode(event)
                : event;

            if (parsed['data'] == null) return;

            final data = parsed['data'];

            // print("Set Live Price ${data}\n and ${data['price24hPcnt']?.toString() ?? "0"}");

            /// ✅ Correct keys from your JSON
            final String lastPrice = data['lastPrice']?.toString() ?? "0";
            final String markPrice = data['prevPrice24h']?.toString() ?? "0";
            final String percent24 = data['price24hPcnt']?.toString() ?? "0";
            final String volume24h = data['volume24h']?.toString() ?? "0";
            final String highPrice24h = data['highPrice24h']?.toString() ?? "0";
            final String lowPrice24h = data['lowPrice24h']?.toString() ?? "0";

            /// ✅ Update UI
            if (data['symbol'] == selectedCoinOne + selectedCoinTwo) {
              setLivePrice(
                lastPrice,
                markPrice,
                percent24,
                volume24h,
                highPrice24h,
                lowPrice24h,
              );
            }

            spotStreamController.sink.add(parsed);
            notifyListeners();
          } catch (e) {
            print("Ticker Parse Error => $e");
          }
        },
        onError: (error) {
          print("Ticker Socket Error => $error");
        },
        onDone: () {
          print("Ticker Socket Closed");
        },
        cancelOnError: true,
      );
    } catch (e) {
      print("Ticker Socket Init Error => $e");
    }
  }

  /// Spot Ticker Socket
  Future<void> orderBookSocketCall(String pair) async {
    try {
      if (spotOrderBookChannel != null) {
        await spotOrderBookChannel!.sink.close();
        spotOrderBookChannel = null;
      }

      var params = '{"op": "subscribe","args": ["orderbook.50.$pair"]}';

      print("Socket Params Orderbook $params");

      spotOrderBookChannel = IOWebSocketChannel.connect(
        Uri.parse(ApiEndpoints.SPOT_WEB_SOCKET_URL),
      );

      spotOrderBookChannel!.sink.add(params);

      spotOrderBookChannel!.stream.listen(
        (event) {
          try {
            if (event != null) {
              spotOrderBookStreamController.sink.add(event);
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

  late PusherChannelsFlutter pusher;
  String message = "Waiting for message...";

  Future<void> initPusher(BuildContext context) async {
    try {
      await pusher.init(
        apiKey: AppServices.pusherAppKey,
        cluster: AppServices.pusherCluster,
        onConnectionStateChange: (currentState, previousState) {
          print("Pusher state: $currentState");
        },
        onError: (message, code, error) {
          print("Pusher error: $message");
        },
        onEvent: (event) {
          onEvent(event, context);
        },
      );

      await pusher.subscribe(
        channelName:
            "${selectedCoinOne}_${selectedCoinTwo}_${AppStorage.getUserId()}",
      );

      await pusher.subscribe(
        channelName:
            "$selectedCoinOne${selectedCoinTwo}_${AppStorage.getUserId()}",
      );

      await pusher.subscribe(
        channelName: "${selectedCoinOne}_$selectedCoinTwo",
      );

      await pusher.connect();
    } catch (e) {
      print("Error initializing Pusher: $e");
    }
  }

  void onEvent(PusherEvent event, BuildContext context) {
    print("Pusher event Spot: $event");

    if (event.channelName ==
            "$selectedCoinOne${selectedCoinTwo}_${AppStorage.getUserId()}" &&
        event.eventName.toString().trim().toLowerCase() == "trade-data") {
      // getLivePriceFromApi(context,false);
      orderBookDetails(context: context);
      getCoinBalances(context);
      getOrderHistory(context);
    } else if (event.channelName ==
        "${selectedCoinOne}_${selectedCoinTwo}_${AppStorage.getUserId()}" &&
        event.eventName.toString().trim().toLowerCase() == "trade-data") {
      // getLivePriceFromApi(context,false);
      orderBookDetails(context: context);
      getCoinBalances(context);
      getOrderHistory(context);
    } else if (event.channelName == "${selectedCoinOne}_$selectedCoinTwo" &&
        event.eventName.toString().trim().toLowerCase() == "trade-data") {
      if (event.data != null) {
        final decodedData = json.decode(event.data);
        final messageString = decodedData['message'];
        final messageJson = json.decode(messageString);
        print("Pusher Message Data ${messageJson}");
        print("Pusher Data is ${messageJson['p']}");
        print("Bids: ${messageJson['bids']}");
        print("Asks: ${messageJson['asks']}");
        setLiveAndChangeTwentyFourData(messageJson['p'].toString(),messageJson['e'].toString(),messageJson['h'].toString(),messageJson['l'].toString(),);

        if (messageJson['bids'] != null && messageJson['asks'] != null) {
          internalBuyList.clear();
          internalSellList.clear();
          internalSellListKChart.clear();
          internalBuyListKChart.clear();

          for (final bid in messageJson['bids']) {
            internalBuyList.add(
              OBLevel(
                price: double.parse(bid['p'].toString()),
                qty: double.parse(bid['r'].toString()),
              ),
            );
            internalBuyListKChart.add(
              OBLevelKChart(
                price: double.parse(bid['p'].toString()),
                qty: double.parse(bid['r'].toString()),
              ),
            );
          }

          for (final ask in messageJson['asks']) {
            internalSellList.add(
              OBLevel(
                price: double.parse(ask['p'].toString()),
                qty: double.parse(ask['r'].toString()),
              ),
            );
            internalSellListKChart.add(
              OBLevelKChart(
                price: double.parse(ask['p'].toString()),
                qty: double.parse(ask['r'].toString()),
              ),
            );
          }

          notifyListeners();
        }
      }
    }
  }

  Future<void> getCoinBalances(BuildContext context) async {
    setLoader(true);
    print("Wallet API POST ");
    await walletApi
        .getWalletDetails()
        .then((value) {
          setLoader(false);

          final parsed = json.decode(value.toString());

          if (parsed['success'] == true) {
            selectedCoinOneBalance = "0.0";
            selectedCoinTwoBalance = "0.0";
            selectedCoinName = "";
            notifyListeners();

            if (parsed['data']['wallet'].toString() != "[]") {
              for (var data in parsed['data']['wallet']) {
                if (data['symbol'].toString() == selectedCoinOne.toString()) {
                  selectedCoinName = data['name'].toString();
                  selectedCoinOneBalance = double.parse(
                    (data['wallet']['free_balance'].toString().isNotEmpty &&
                            data['wallet']['free_balance']
                                    .toString()
                                    .toLowerCase() !=
                                "null")
                        ? data['wallet']['free_balance'].toString()
                        : "0.0",
                  ).toString();
                }

                if (data['symbol'].toString() == selectedCoinTwo.toString()) {
                  selectedCoinTwoBalance = double.parse(
                    (data['wallet']['free_balance'].toString().isNotEmpty &&
                            data['wallet']['free_balance']
                                    .toString()
                                    .toLowerCase() !=
                                "null")
                        ? data['wallet']['free_balance'].toString()
                        : "0.0",
                  ).toString();
                }
              }
            }

            notifyListeners();
          } else {
            FocusScope.of(context).requestFocus(FocusNode());
            _showParsedError(context, parsed, ["error"]);
          }
        })
        .catchError((e) {
          setLoader(false);
          print("Error in cancelOrder: ${e.toString()}");
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
  }

  //////////////////////////////////////////////////////////////////////////////
  // -------------------------- Helper Functions ------------------------------
  //////////////////////////////////////////////////////////////////////////////

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

class InternalOrderBook {
  String? price, quantity;
  InternalOrderBook({this.price, this.quantity});
}

// class TradePair {
//   String? coinOne, coinTwo, liquidityType, coinOneImage, volume, change24,
//   last,
//   low,
//   high,
//   exchange;
//
//   int? favourite, coinOneDecimal, coinTwoDecimal, id;
//   double? livePrice,
//       minBuyPrice,
//       minBuyAmount,
//       minSellPrice,
//       minSellAmount,
//       unlistBinanMultiplier;
//
//   TradePair(
//       {this.id,
//         this.coinOne,
//         this.coinTwo,
//         this.liquidityType,
//         this.coinOneImage,
//         this.favourite,
//         this.coinOneDecimal,
//         this.coinTwoDecimal,
//         this.livePrice,
//         this.minBuyPrice,
//         this.minBuyAmount,
//         this.minSellPrice,
//         this.minSellAmount,
//         this.unlistBinanMultiplier,
//         this.volume,
//         this.change24,
//         this.last,
//         this.low,
//         this.high,
//         this.exchange,});
// }

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
