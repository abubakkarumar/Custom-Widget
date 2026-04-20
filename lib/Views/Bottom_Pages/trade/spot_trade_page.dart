import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:provider/provider.dart' as pv;
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Utility/number_formator.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Market/market_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/wallet_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/show_spot_tradepair_bottomsheet.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_depth_chart_webview.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_price_chart.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';
import 'package:zayroexchange/Utility/global_state/global_providers.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'buy_sell_tab.dart';
import 'custom_progress_dialog.dart';
import 'customized_slider.dart';
import 'kchart_page.dart';
import 'order_history_tab.dart';
import 'orderbook_ui_spot.dart';

class SpotTradePage extends rp.ConsumerStatefulWidget {
  String type;
  bool isFromArena = false;
  bool isNew = true;
  SpotTradePage({
    super.key,
    required this.type,
    required this.isFromArena,
    required this.isNew,
  });

  @override
  rp.ConsumerState<SpotTradePage> createState() => _SpotTradePageState();
}

class _SpotTradePageState extends rp.ConsumerState<SpotTradePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late SpotTradeController controller;
  final GlobalKey leftKey = GlobalKey();
  double leftHeight = 0;
  MarketController? marketController;
  late WalletController walletController;
  bool _tradePairsSynced = false;
  bool _requestedFallback = false;
  String? _lastAppliedPair;
  // late final OrderBookTheme theme;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      print('App is in background (paused)');
    } else if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive) {
      print('App is active again (resumed)');
      Future.delayed(Duration(seconds: 1)).whenComplete(() {
        controller.orderBookSocketCall(controller.selectedPairValue);
        controller.byTickerBitSocketCall(controller.selectedPairValue);
      });
    } else if (state == AppLifecycleState.detached) {
      print('App is detached');
    }
  }

  @override
  void initState() {
    print("INIT STATE CALLED");
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = leftKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() {
          leftHeight = box.size.height;
        });
      }
    });

    controller = Provider.of<SpotTradeController>(context, listen: false);
    marketController = Provider.of<MarketController>(context, listen: false);
    walletController = Provider.of<WalletController>(context, listen: false);

    controller.initializeTabBar(this);
    controller.initializeTabBarPair(this);
    controller.initializeChartsTabBar(this);
    ref.read(tradePairsProvider.future);
    Future.delayed(Duration(seconds: 2)).whenComplete(() {
      controller.pusher =
          PusherChannelsFlutter.getInstance(); // ✅ Required initialization
      controller.updateWhereComeFrom(widget.isFromArena);
      print("IS FROM ARENA: ${widget.isFromArena}");
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.socketDispose();
    controller.clearData();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tradePairsAsync = ref.watch(tradePairsProvider);
    final tradePairs = tradePairsAsync.valueOrNull;
    if (tradePairs != null && !_tradePairsSynced) {
      controller.applyTradePairs(tradePairs, context, widget.isNew);
      _tradePairsSynced = true;
    } else if (tradePairsAsync.hasError && !_requestedFallback) {
      _requestedFallback = true;
      controller.getTradePairs(context, widget.isNew);
    } else if (tradePairs == null &&
        !tradePairsAsync.isLoading &&
        !_requestedFallback &&
        controller.tradePairList.isEmpty) {
      _requestedFallback = true;
      controller.getTradePairs(context, widget.isNew);
    }

    return pv.Consumer3<SpotTradeController, MarketController, WalletController>(
      builder: (context, value, mController, value3, child) {
        controller = value;
        marketController = mController;
        walletController = value3;

        /// Apply externally selected pair (from Market/Dashboard) once data is ready.
        final desiredPair = controller.selectedPairValue;
        if (desiredPair.isNotEmpty &&
            controller.tradePairList.isNotEmpty &&
            desiredPair != _lastAppliedPair) {
          final match = controller.tradePairList.firstWhere(
            (p) => "${p.coinOne}${p.coinTwo}".toLowerCase() ==
                desiredPair.toLowerCase(),
            orElse: () => controller.tradePairList.first,
          );
          _lastAppliedPair = desiredPair;
          controller.selectedTradePair(match, context, 'new');
        }
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body:  Stack(
            children: [
              AbsorbPointer(
                absorbing: controller.isLoading,
                child: Padding(
                  padding: EdgeInsets.all(8.sp),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (_) => false,
                    child:  RefreshIndicator(
                      onRefresh: () async {
                        Future.delayed(Duration.zero).whenComplete(
                              () async {
                            controller.getCoinBalances(context);
                            controller.orderBookDetails(context: context);
                            // controller.getLivePriceFromApi(context, false);
                          },
                        );
                      },
                      child: SingleChildScrollView(
                        controller: controller.scrollController,
                        scrollDirection: Axis.vertical,
                        physics: const AlwaysScrollableScrollPhysics(), // IMPORTANT
                        // physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).padding.top,
                            ),
                            SpotTradeHeader(),
                            if (controller.isPriceChartEnabled ||
                                controller.isDepthChartEnabled)
                              // ChartContainer(),
                              KChartPage(),
                            if (!controller.isPriceChartEnabled &&
                                !controller.isDepthChartEnabled)
                              SpotTradeOrderAndFormSection(
                                controller: controller,
                                walletController: walletController,
                                leftKey: leftKey,
                                leftHeight: leftHeight,
                              ),

                            SizedBox(height: 10.sp),

                            if (!controller.isPriceChartEnabled &&
                                !controller.isDepthChartEnabled)
                              customTabOrders(
                                context: context,
                                controller: controller,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (controller.isLoading)
                CustomLoader(isLoading: controller.isLoading),
            ],
          ),
        );
      },
    );
  }
}

class SpotTradeHeader extends StatelessWidget {
  const SpotTradeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SpotTradeController>();

    return Padding(
      padding: EdgeInsets.all(15.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PairSelector(controller: controller),
          HighLowInfo(controller: controller),
        ],
      ),
    );
  }
}

class PairSelector extends StatelessWidget {
  final SpotTradeController controller;

  const PairSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final percent = controller.selectedLiquiditySymbol.toLowerCase() == 'normal'
        ? controller.percentageInternal
        : controller.percentChange * 100;
    final isNegative = percent < 0;

    return GestureDetector(
      onTap: () => showSpotTradePairs(context, ""),
      child: Row(
        children: [
          // SvgPicture.network(controller.selectedCoinOneImage, height: 3.5.h),
          // SizedBox(width: 12.sp),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    label:
                        "${controller.selectedCoinOne}/${controller.selectedCoinTwo}",
                    labelFontWeight: FontWeight.w500,
                    fontSize: 17.sp,
                  ),
                  SizedBox(width: 8.sp),
                  SvgPicture.asset(
                    AppThemeIcons.arrowDown(context),
                    width: 10.sp,
                  ),
                ],
              ),
              SizedBox(height: 6.sp),
              Row(
                children: [
                  CustomText(
                    label: controller.selectedCoinName,
                    fontSize: 13.sp,
                  ),
                  Icon(
                    isNegative ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 14.sp,
                    color: isNegative
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                  CustomText(
                    label: "${percent.toStringAsFixed(2)}%",
                    labelFontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    fontColour: isNegative
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HighLowInfo extends StatelessWidget {
  final SpotTradeController controller;

  const HighLowInfo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!controller.isPriceChartEnabled && !controller.isDepthChartEnabled)
          _infoColumn(
            context,
            AppLocalizations.of(context)!.twentyFourHigh,
            controller.selectedLiquiditySymbol.toString().toLowerCase() ==
                    "normal"
                ? controller.highPrice24hInternal
                : controller.highPrice24h,
          ),
        if (!controller.isPriceChartEnabled && !controller.isDepthChartEnabled)
          SizedBox(width: 15.sp),
        if (!controller.isPriceChartEnabled && !controller.isDepthChartEnabled)
          _infoColumn(
            context,
            AppLocalizations.of(context)!.twentyFourLow,
            controller.selectedLiquiditySymbol.toString().toLowerCase() ==
                    "normal"
                ? controller.lowPrice24hInternal
                : controller.lowPrice24h,
          ),
        if (!controller.isPriceChartEnabled && !controller.isDepthChartEnabled)
          SizedBox(width: 15.sp),
        GestureDetector(
          onTap: () {
            controller.clearChartData();
          },
          child: Icon(Icons.candlestick_chart, size: 18.sp),
        ),
      ],
    );
  }

  Widget _infoColumn(BuildContext context, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label: title,
          fontColour: ThemeTextOneColor.getTextOneColor(context),
          labelFontWeight: FontWeight.w400,
          fontSize: 13.sp,
        ),
        CustomText(
          label: value,
          labelFontWeight: FontWeight.bold,
          fontSize: 13.sp,
        ),
      ],
    );
  }
}

class ChartContainer extends StatelessWidget {
  const ChartContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SpotTradeController>();

    return Padding(
      padding: EdgeInsets.all(12.sp),
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.sp),
          border: Border.all(color: ThemeOutLineColor.getOutLineColor(context)),
        ),
        child: Column(
          children: [
            ChartActionRow(controller: controller),
            if (controller.isPriceChartEnabled ||
                controller.isDepthChartEnabled)
              SizedBox(height: 12.sp),
            if (controller.isPriceChartEnabled) const PriceChart(),
            if (controller.isDepthChartEnabled) const DepthChart(),
          ],
        ),
      ),
    );
  }
}

class ChartActionRow extends StatelessWidget {
  final SpotTradeController controller;

  const ChartActionRow({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                controller.setChartEnabled(
                  !controller.isPriceChartEnabled,
                  'price',
                );
              },
              child: SvgPicture.asset(
                controller.isPriceChartEnabled
                    ? AppThemeIcons.tradePriceChat(context)
                    : AppThemeIcons.tradePriceChat(context),
                height: 23.sp,
              ),
            ),
            SizedBox(width: 12.sp),
            GestureDetector(
              onTap: () {
                controller.setChartEnabled(
                  !controller.isDepthChartEnabled,
                  'depth',
                );
              },
              child: SvgPicture.asset(
                controller.isDepthChartEnabled
                    ? AppThemeIcons.tradeDepthChat(context)
                    : AppThemeIcons.tradeDepthChat(context),
                height: Theme.of(context).brightness == Brightness.light
                    ? 23.sp
                    : 26.sp,
              ),
            ),
          ],
        ),
        // Row(
        //   children: [
        //     _orderTypeButton(
        //       context,
        //       0,
        //       AppThemeIcons.valuesRedGreen(context),
        //       controller,
        //     ),
        //     SizedBox(width: 12.sp,),
        //     _orderTypeButton(
        //       context,
        //       1,
        //       AppThemeIcons.valuesGreen(context),
        //       controller,
        //     ),
        //     SizedBox(width: 12.sp,),
        //     _orderTypeButton(
        //       context,
        //       2,
        //       AppThemeIcons.valuesRed(context),
        //       controller,
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

class PriceChart extends StatelessWidget {
  const PriceChart({super.key});

  @override
  Widget build(BuildContext context) {
    final pair =
        "${context.read<SpotTradeController>().selectedCoinOne}_${context.read<SpotTradeController>().selectedCoinTwo}";

    return SizedBox(
      height: 55.h,
      child: SpotPriceChartView(pair: pair),
    );
  }
}

class DepthChart extends StatelessWidget {
  const DepthChart({super.key});

  @override
  Widget build(BuildContext context) {
    final pair =
        "${context.read<SpotTradeController>().selectedCoinOne}_${context.read<SpotTradeController>().selectedCoinTwo}";

    return Column(
      children: [
        SizedBox(
          height: 55.h,
          child: SpotDepthChartView(pair: pair),
        ),
      ],
    );
  }
}

/// ================= BUTTON =================
Widget _orderTypeButton(
  BuildContext context,
  int type,
  String icon,
  SpotTradeController controller,
) {
  return GestureDetector(
    onTap: () => controller.setSelectedOrderBookType(type),
    child: Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.px),
        color: controller.orderBookType == type
            ? ThemeOutLineColor.getOutLineColor(context)
            : ThemeTextFormFillColor.getTextFormFillColor(context),
      ),
      child: SvgPicture.asset(icon, height: 18.sp),
    ),
  );
}

class SpotTradeOrderAndFormSection extends StatelessWidget {
  final SpotTradeController controller;
  final WalletController walletController;
  final GlobalKey leftKey;
  final double leftHeight;

  const SpotTradeOrderAndFormSection({
    super.key,
    required this.controller,
    required this.walletController,
    required this.leftKey,
    required this.leftHeight,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// ORDER BOOK (LEFT)
          SizedBox(
            width: 47.w,
            height: leftHeight,
            child: Padding(
              padding: EdgeInsets.all(12.sp),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalHeight = constraints.maxHeight;
                  return OrderBookUiSpot(
                    controller: controller,
                    walletController: walletController,
                    remainingHeight: totalHeight,
                  );
                },
              ),
            ),
          ),

          SizedBox(width: 5.sp),

          /// TRADE FORM (RIGHT)
          SizedBox(
            width: 50.w,
            key: leftKey,
            child: Padding(
              padding: EdgeInsets.only(
                left: 8.sp,
                right: 8.sp,
                top: 10.sp,
                bottom: 15.sp,
              ),
              child: SingleChildScrollView(
                child: _TradeFormContent(controller: controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TradeFormContent extends StatelessWidget {
  final SpotTradeController controller;

  const _TradeFormContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// BUY / SELL TABS
        TradeToggle(
          value: controller.tradeType,
          onChanged: (value) {
            if (value == TradeType.buy) {
              controller.setBuySellTabIndex(value: 0);
            } else {
              controller.setBuySellTabIndex(value: 1);
            }
            controller.resetSlider(context);
            controller.changeTradeType(value);
            print(controller.sliderValue); // buy or sell
          },
        ),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     GestureDetector(
        //       onTap: () => controller.setBuySellTabIndex(value: 0),
        //       child: _buySellTab(
        //         context,
        //         isBuy: true,
        //         isActive: controller.buySellTab == 0,
        //       ),
        //     ),
        //     GestureDetector(
        //       onTap: () => controller.setBuySellTabIndex(value: 1),
        //       child: _buySellTab(
        //         context,
        //         isBuy: false,
        //         isActive: controller.buySellTab == 1,
        //       ),
        //     ),
        //   ],
        // ),
        SizedBox(height: 15.sp),

        /// ORDER TYPE DROPDOWN
        _orderTypeDropdown(context),

        SizedBox(height: 15.sp),

        /// FORM (UNCHANGED – FULL CODE)
        _tradeForm(context),
      ],
    );
  }

  // ---------------- HELPERS (NO LOGIC CHANGE) ----------------

  Widget _buySellTab(
    BuildContext context, {
    required bool isBuy,
    required bool isActive,
  }) {
    return Container(
      alignment: Alignment.center,
      width: 21.w,
      padding: EdgeInsets.symmetric(vertical: 5.sp),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            isBuy
                ? (isActive
                      ? AppThemeIcons.buyActiveBg(context)
                      : AppThemeIcons.buyInActiveBg(context))
                : (isActive
                      ? AppThemeIcons.sellActiveBg(context)
                      : AppThemeIcons.sellInActiveBg(context)),
          ),
          fit: BoxFit.fill,
        ),
      ),
      child: CustomText(
        label: isBuy
            ? AppLocalizations.of(context)!.buy
            : AppLocalizations.of(context)!.sell,
        fontSize: 13.px,
        labelFontWeight: FontWeight.w500,
        fontColour: isActive
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _orderTypeDropdown(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4.h,
            padding: EdgeInsets.only(left: 10.sp),
            decoration: BoxDecoration(
              color: ThemeTextFormFillColor.getTextFormFillColor(context),
              borderRadius: BorderRadius.circular(15.sp),
              border: Border.all(
                color: ThemeOutLineColor.getOutLineColor(context),
                width: 4.sp,
              ),
            ),
            child: DropdownButton<String>(
              dropdownColor: Theme.of(context).colorScheme.surface,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              value: controller.selectedType,
              icon: Padding(
                padding: EdgeInsets.only(right: 10.sp),
                child: Icon(Icons.arrow_drop_down, size: 18.sp),
              ),
              items: controller.typeArr.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: CustomText(label: value, fontSize: 11.px),
                );
              }).toList(),
              onChanged: (val) => controller.setSelectType(val!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tradeForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// FORM START
        Form(
          key: controller.tradeForm,
          child: Column(
            children: [
              /// PRICE (LIMIT / STOP)
              if (controller.selectedType != "Market")
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFieldTrade(
                        readOnly: false,
                        controller: controller.priceController,
                        hintText: AppLocalizations.of(context)!.price,
                        autoValidateMode: controller.priceAutoValidate,
                        line: 1,
                        onChanged: (value) {
                          controller.totalBasedOnLastPrice(lastPrice: value);
                        },
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomText(
                                label: controller.selectedCoinTwo,
                                fontSize: 10.px,
                              ),
                            ),
                            // Column(
                            //   mainAxisSize: MainAxisSize.min,
                            //   children: [
                            //     InkWell(
                            //       onTap: () {
                            //         controller.priceUpdateIncDec(
                            //             "inc", context);
                            //       },
                            //       child: Icon(Icons.arrow_drop_up, size: 18.sp),
                            //     ),
                            //     InkWell(
                            //       onTap: () {
                            //         controller.priceUpdateIncDec(
                            //             "dec", context);
                            //       },
                            //       child:
                            //       Icon(Icons.arrow_drop_down, size: 18.sp),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                        inputFormatters: [
                          DecimalTextInputFormatter(
                            decimalRange: controller.selectedCoinTwoDecimal,
                          ),
                        ],
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onValidate: (val) {
                          if (val!.isEmpty) {
                            return AppLocalizations.of(context)!.priceRequired;
                          } else if (double.parse(val) <= 0) {
                            return AppLocalizations.of(
                              context,
                            )!.priceShouldNotBeZero;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

              /// MARKET PRICE
              if (controller.selectedType == "Market")
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFieldTrade(
                        controller: controller.marketPriceController,
                        hintText: AppLocalizations.of(context)!.marketPrice,
                        readOnly: true,
                        line: 1,
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 12.sp),
                          child: CustomText(
                            label: controller.selectedCoinTwo,
                            fontSize: 10.px,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              SizedBox(height: 12.sp),

              /// AMOUNT
              Row(
                children: [
                  Expanded(
                    child: CustomTextFieldTrade(
                      // height: 4.h,
                      readOnly: false,
                      controller: controller.amountController,
                      hintText: AppLocalizations.of(context)!.amount,
                      autoValidateMode: controller.amountAutoValidate,
                      onChanged: (val) {
                        controller.getTotalAmount(
                          amount: val,
                          context: context,
                        );
                      },
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.sp),
                              color: Colors.transparent,
                            ),
                            // border: Border.all(color: Theme.of(context).disabledColor, width: 4.sp)),
                            child: DropdownButton<String>(
                              dropdownColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              isDense: true,
                              isExpanded: false,
                              padding: EdgeInsets.zero,
                              underline: const SizedBox.shrink(),
                              value: controller.selectedCoinOneDropDown,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                size: 13.sp,
                                color: ThemeTextColor.getTextColor(context),
                              ),
                              items: controller.coinOneArr.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: CustomText(
                                    label: value,
                                    fontSize: 10.px,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                controller.setSelectCoinOneDropDown(
                                  newValue!,
                                  context,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      // suffixIcon: Padding(
                      //   padding: EdgeInsets.only(right: 12.sp, top: 10.sp),
                      //   child: CustomText(
                      //     label: controller.selectedCoinOne,
                      //     fontSize: 11.px,
                      //   ),
                      // ),
                      inputFormatters: [
                        DecimalTextInputFormatter(
                          decimalRange: controller.selectedCoinOneDecimal,
                        ),
                      ],
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onValidate: (val) {
                        if (val!.isEmpty) {
                          return AppLocalizations.of(context)!.amountRequired;
                        } else if (double.parse(val) <= 0) {
                          return AppLocalizations.of(
                            context,
                          )!.amountShouldNotBeZero;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15.sp),

              /// SLIDER
              SizedBox(
                width: 40.w,
                height: 20.sp,
                child: TradePercentSlider(
                  value: controller.sliderValue,
                  onChanged: (v) {
                    controller.percentageBasedAmountAndTotalAmount(
                      value: v,
                      c: context,
                    );
                  },
                ),
              ),

              // SliderTheme(
              //   data: SliderTheme.of(context).copyWith(
              //     activeTrackColor: ThemePrimaryColor.getPrimaryColor(context),
              //     inactiveTrackColor: ThemeOutLineColor.getOutLineColor(
              //       context,
              //     ),
              //     thumbColor: ThemePrimaryColor.getPrimaryColor(context),
              //     overlayColor: Colors.blue.withOpacity(0.2),
              //     tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 2),
              //     activeTickMarkColor: ThemePrimaryColor.getPrimaryColor(
              //       context,
              //     ),
              //     inactiveTickMarkColor: ThemeOutLineColor.getOutLineColor(
              //       context,
              //     ),
              //     trackHeight: 6,
              //       padding: EdgeInsets.symmetric(horizontal: 10.sp)
              //   ),
              //   child: Slider(
              //     value: controller.sliderValue,
              //     min: 0,
              //     max: 100,
              //     divisions: 100, // ⭐ this is the key
              //     label: "${controller.sliderValue.round()}%",
              //     onChanged: (value) {
              //       controller.percentageBasedAmountAndTotalAmount(
              //         value: value,
              //         c: context,
              //       );
              //     },
              //   ),
              // ),
              SizedBox(height: 15.sp),

              /// TOTAL
              if (controller.selectedType != "Market")
                SizedBox(
                  width: 50.w,
                  child: CustomTextFieldTrade(
                    controller: controller.totalController,
                    hintText: AppLocalizations.of(context)!.total,
                    autoValidateMode: controller.totalAutoValidate,
                    readOnly: true,
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 12.sp),
                      child: CustomText(
                        label: controller.selectedCoinTwo,
                        fontSize: 10.px,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 12.sp),

        /// ================= WALLET SECTION =================
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 15.sp),
            child: CustomText(
              label:
                  "${AppLocalizations.of(context)!.available} ${AppLocalizations.of(context)!.balance}",
              labelFontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ),

        SizedBox(height: 10.sp),

        /// Coin One Available
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 15.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(label: controller.selectedCoinOne, fontSize: 10.px),
                CustomText(
                  label:
                      "${numberFormatter(controller.selectedCoinOneBalance.toString(), decimal: controller.selectedCoinOneDecimal)} ${controller.selectedCoinOne}",
                  fontSize: 10.px,
                  align: TextAlign.end,
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 10.sp),

        /// Coin Two Available
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 15.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(label: controller.selectedCoinTwo, fontSize: 10.px),
                Expanded(
                  child: CustomText(
                    label:
                        "${numberFormatter(controller.selectedCoinTwoBalance.toString(), decimal: controller.selectedCoinTwoDecimal)} ${controller.selectedCoinTwo}",
                    fontSize: 10.px,
                    align: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 15.sp),
        SizedBox(
          width: 45.w,
          height: 5.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.buySellTab == 0
                  ? const Color(0xff2EBD85)
                  : const Color(0xffF6465D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // 👈 radius here
              ),
            ),
            onPressed: () {
              controller.enableAutoValidate();
              if (controller.tradeForm.currentState!.validate()) {
                tradeDetailsBottomSheet(context);
              }
            },
            child: CustomText(
              label: controller.buySellTab == 0
                  ? AppLocalizations.of(context)!.buy
                  : AppLocalizations.of(context)!.sell,
              fontColour: Theme.of(context).colorScheme.surface,
              fontSize: 11.px,
            ),
          ),
        ),
        SizedBox(height: 15.sp),

        /// DEPOSIT BUTTON
        // SizedBox(
        //   width: 45.w,
        //   height: 3.h,
        //   child: OutlinedButton(
        //     style: ButtonStyle(
        //       side: WidgetStateProperty.all(
        //         BorderSide(
        //           color: Theme.of(context).colorScheme.tertiary,
        //           width: 0.8,
        //         ),
        //       ),
        //       shape: WidgetStateProperty.all(
        //         RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(25.sp),
        //         ),
        //       ),
        //     ),
        //     onPressed: () {
        //       // Navigator.of(context)
        //       //     .pushNamed(depositPage, arguments: controller.selectedCoinTwo);
        //     },
        //     child: CustomText(
        //       label: AppLocalizations.of(context)!.deposit,
        //       fontColour: Theme.of(context).colorScheme.tertiary,
        //       fontSize: 14.sp,
        //     ),
        //   ),
        // ),

        // SizedBox(height: 10.sp),

        /// WITHDRAW BUTTON
        // SizedBox(
        //   width: 45.w,
        //   height: 3.h,
        //   child: OutlinedButton(
        //     style: ButtonStyle(
        //       side: WidgetStateProperty.all(
        //         BorderSide(
        //           color: Theme.of(context).colorScheme.error,
        //           width: 0.8,
        //         ),
        //       ),
        //       shape: WidgetStateProperty.all(
        //         RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(25.sp),
        //         ),
        //       ),
        //     ),
        //     onPressed: () {
        //       // Navigator.of(context)
        //       //     .pushNamed(withdrawPage, arguments: controller.selectedCoinTwo);
        //     },
        //     child: CustomText(
        //       label: AppLocalizations.of(context)!.withdraw,
        //       fontColour: Theme.of(context).colorScheme.error, fontSize: 14.sp,
        //
        //     ),
        //   ),
        // ),
      ],
    );
  }

  void tradeDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      builder: (_) {
        return Consumer<SpotTradeController>(
          builder: (context, value, child) {
            var amountVal = "0.0";

            if (value.selectedCoinOneDropDown != value.selectedCoinOne) {
              if (value.selectedType != "Market" &&
                  (value.priceController.text.isNotEmpty &&
                      value.priceController.text.toLowerCase() != "null") &&
                  (value.amountController.text.isNotEmpty &&
                      value.amountController.text.toLowerCase() != "null")) {
                var price = double.parse(value.priceController.text);
                var amount = double.parse(value.amountController.text);
                amountVal = (amount / price).toStringAsFixed(8);

                print("New Amount $amountVal");
              } else {
                var price = double.parse(value.selectedLiquiditySymbol.toLowerCase() == "normal" ? value.selectedLivePrice.toString() : value.finalLivePrice.toString());
                var amount = double.parse(
                  (value.amountController.text.isNotEmpty &&
                          value.amountController.text.toLowerCase() != "null")
                      ? value.amountController.text
                      : "0.0",
                );
                amountVal = (amount / price).toStringAsFixed(8);

                print("New Amount $amountVal");
              }
            }

            return SizedBox(
              height: 32.h,
              child: Padding(
                padding: EdgeInsets.all(15.sp),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          label: AppLocalizations.of(context)!.orderConfirmation,
                          labelFontWeight: FontWeight.bold,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset(
                            AppBasicIcons.close,
                            height: 20.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.sp),
                    controller.selectedType == "Market"
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                label: controller.buySellTab == 0 ? AppLocalizations.of(context)!.spotMarketBuy : AppLocalizations.of(context)!.spotMarketSell,
                                labelFontWeight: FontWeight.bold,
                              ),
                              SizedBox(height: 15.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(label: AppLocalizations.of(context)!.price),
                                  CustomText(label: AppLocalizations.of(context)!.marketPrice),
                                ],
                              ),
                              SizedBox(height: 15.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(label: AppLocalizations.of(context)!.amount),
                                  CustomText(
                                    label:
                                        "${(value.selectedCoinOneDropDown != value.selectedCoinOne) ? amountVal : controller.amountController.text} ${controller.selectedCoinOne}",
                                  ),
                                ],
                              ),
                              SizedBox(height: 15.sp),
                              value.isLoading == true
                                  ? CustomProgressDialog()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CancelButton(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.cancel,
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        CustomButton(
                                          width: 38.w,
                                          label: AppLocalizations.of(
                                            context,
                                          )!.submit,
                                          onTap: () {
                                            controller.postOrderLimit(
                                              context: context,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                label: controller.buySellTab == 0 ? AppLocalizations.of(context)!.spotLimitBuy : AppLocalizations.of(context)!.spotLimitSell,
                                labelFontWeight: FontWeight.bold,
                              ),
                              SizedBox(height: 15.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(label: AppLocalizations.of(context)!.price),
                                  CustomText(
                                    label: controller.priceController.text,
                                  ),
                                ],
                              ),
                              SizedBox(height: 15.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(label: AppLocalizations.of(context)!.amount),
                                  CustomText(
                                    label:
                                        "${(value.selectedCoinOneDropDown != value.selectedCoinOne) ? amountVal : controller.amountController.text} ${controller.selectedCoinOne}",
                                  ),
                                ],
                              ),
                              SizedBox(height: 15.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(label: AppLocalizations.of(context)!.total),
                                  CustomText(
                                    label: controller.totalController.text,
                                  ),
                                ],
                              ),
                              SizedBox(height: 15.sp),
                              value.isLoading == true
                                  ? CustomProgressDialog()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CancelButton(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.cancel,
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        CustomButton(
                                          width: 38.w,
                                          label: AppLocalizations.of(
                                            context,
                                          )!.submit,
                                          onTap: () {
                                            controller.postOrderLimit(
                                              context: context,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CustomTextFieldTrade extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? suffixText;
  final String? prefixText;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final Widget? suffixIcon;
  final Color? fillColor;
  final bool? filled, obscure;
  final int? length;
  final double? height;
  final double? width;
  final bool readOnly;
  final FocusNode? node;
  final Color? cursorColor;
  final int? line;
  final TextInputType? keyboardType;
  final AutovalidateMode? autoValidateMode;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? onValidate;
  final BorderRadius? borderRadius;
  final String? label;
  final Widget? prefixIcon;
  final String? labelTwo;
  final Color? labelTwoColour;
  final bool? isDisabled;
  final void Function(String)? onSubmit;

  const CustomTextFieldTrade({
    super.key,
    required this.controller,
    required this.hintText,
    this.suffixText,
    this.onChanged,
    this.obscure = false,
    this.onValidate,
    this.length,
    this.width,
    this.height,
    this.keyboardType,
    this.inputFormatters,
    this.suffixIcon,
    this.fillColor,
    this.filled,
    required this.readOnly,
    this.autoValidateMode,
    this.borderRadius,
    this.node,
    this.line,
    this.cursorColor,
    this.prefixText,
    this.label,
    this.labelTwo,
    this.labelTwoColour,
    this.prefixIcon,
    this.onSubmit,
    this.onTap,
    this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            onTap: (isDisabled ?? false)
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    if (onTap != null) {
                      onTap!();
                    }
                  },
            focusNode: node,
            readOnly: (isDisabled ?? false) ? true : readOnly ?? false,
            keyboardType: keyboardType,
            onChanged: onChanged,
            onFieldSubmitted: onSubmit,
            autovalidateMode: autoValidateMode,
            inputFormatters: inputFormatters,
            maxLines: line,
            maxLength: length,
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },

            style: TextStyle(
              fontSize: 13.5.sp,
              color: ThemeTextColor.getTextColor(context),
              fontWeight: FontWeight.w400,
            ),
            cursorColor: ThemeTextColor.getTextColor(context),
            validator: (isDisabled ?? false) ? null : onValidate,
            obscureText: obscure!,
            controller: controller,
            decoration: InputDecoration(
              counterText: "",
              suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 10.sp, left: 10.sp),
                child: suffixIcon,
              ),

              suffixText: suffixText,
              suffixStyle: TextStyle(
                fontSize: 14.5.sp,
                color: ThemeTextColor.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
              prefixText: prefixText,
              prefixIcon: prefixIcon,
              filled: true,
              fillColor: ThemeTextFormFillColor.getTextFormFillColor(context),
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 13.5.sp,
                color: ThemeTextOneColor.getTextOneColor(context),
                fontWeight: FontWeight.w400,
              ),
              errorStyle: TextStyle(
                fontSize: 15.sp,
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 5.sp,
                  color: ThemeOutLineColor.getOutLineColor(context),
                ),
                borderRadius: BorderRadius.circular(15.sp),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 5.sp,
                  color: ThemeOutLineColor.getOutLineColor(context),
                ),
                borderRadius: BorderRadius.circular(15.sp),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 5.sp,
                  color: ThemeOutLineColor.getOutLineColor(context),
                ),
                borderRadius: BorderRadius.circular(15.sp),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 5.sp,
                  color: Theme.of(context).colorScheme.error,
                ),
                borderRadius: BorderRadius.circular(15.sp),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 5.sp,
                  color: Theme.of(context).colorScheme.error,
                ),
                borderRadius: BorderRadius.circular(12.sp),
              ),
              contentPadding: EdgeInsets.only(top: 15.sp, left: 15.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange})
    : assert(decimalRange >= 0, "Decimal range must be non-negative");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Validate the input using the dynamic RegExp
    final regex = RegExp(r'^\d*(\.\d{0,' + decimalRange.toString() + r'})?$');
    if (!regex.hasMatch(text)) {
      return oldValue; // Revert to the previous value
    }

    return newValue; // Accept the input
  }
}
