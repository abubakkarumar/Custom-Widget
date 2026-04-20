import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Market/market_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';
import 'package:zayroexchange/Views/Root/root_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class MarketView extends StatefulWidget {
  const MarketView({super.key});

  @override
  State<MarketView> createState() => _MarketViewState();
}

class _MarketViewState extends State<MarketView> {
  late MarketController controller;
  final ScrollController _coinScrollController = ScrollController();
  late SpotTradeController spotTradeController;
  late RootController rootController;
  bool _didFetch = false;

  // =============================
  // INIT
  // =============================
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller = context.read<MarketController>();
      spotTradeController = context.read<SpotTradeController>();
      rootController = context.read<RootController>();
      if (_didFetch) return;
      _didFetch = true;
      controller.getMarketOverview(context);
      _startAutoScroll();
    });
  }

  // =============================
  // AUTO SCROLL
  // =============================
  void _startAutoScroll() {
    controller.autoScrollTimer?.cancel();

    const double step = 2.0;
    const Duration tick = Duration(milliseconds: 20);

    controller.autoScrollTimer = Timer.periodic(tick, (timer) async {
      if (!_coinScrollController.hasClients) return;
      if (controller.isAutoScrollingBack) return;

      final maxScroll = _coinScrollController.position.maxScrollExtent;
      final current = _coinScrollController.offset;

      if (maxScroll <= 0) return;

      final next = current + step;

      if (next >= maxScroll) {
        controller.isAutoScrollingBack = true;
        _coinScrollController.jumpTo(maxScroll);

        await Future.delayed(const Duration(milliseconds: 900));

        if (_coinScrollController.hasClients) {
          await _coinScrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }

        controller.isAutoScrollingBack = false;
      } else {
        _coinScrollController.jumpTo(next);
      }
    });
  }

  void _stopAutoScroll() {
    controller.autoScrollTimer?.cancel();
    controller.autoScrollTimer = null;
  }

  void _resumeAutoScroll() {
    _startAutoScroll();
  }

  // =============================
  // SOCKET UPDATE (UNCHANGED)
  // =============================
  void _updateFromSocket(dynamic data, List list) {
    if (data == null) return;

    final parsed = jsonDecode(data);
    final symbol = parsed["data"]['symbol']?.toString();

    final index = list.indexWhere((e) => "${e.coinOne}${e.coinTwo}" == symbol);

    if (index == -1) return;

    list[index].last =
        (double.tryParse(parsed["data"]['lastPrice']?.toString() ?? "0") ?? 0)
            .toStringAsFixed(2);

    list[index].volume =
        (double.tryParse(parsed["data"]['volume24h']?.toString() ?? "0") ?? 0)
            .toStringAsFixed(2);

    list[index].exchange =
        ((double.tryParse(parsed["data"]['price24hPcnt']?.toString() ?? "0") ??
                    0) *
                100)
            .toStringAsFixed(2);
  }

  // =============================
  // DISPOSE
  // =============================
  @override
  void dispose() {
    controller.autoScrollTimer?.cancel();
    _coinScrollController.dispose();
    controller.searchController.clear();
    controller.topGainersList.clear();
    controller.topLosersList.clear();
    controller.newList.clear();
    controller.hotSpotList.clear();
    controller.topGainersListFilter.clear();
    controller.topLosersListFilter.clear();
    controller.newListFilter.clear();
    controller.hotSpotListFilter.clear();

    super.dispose();
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    return Consumer3<MarketController, SpotTradeController, RootController>(
      builder: (context, value, value1, value2, _) {
        controller = value;
        spotTradeController = value1;
        rootController = value2;

        return SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    children: [
                      CustomTextFieldWidget(
                        controller: controller.searchController,
                        hintText: AppLocalizations.of(context)!.search,
                        line: 1,
                        prefixIcon: Icon(Icons.search, size: 17.sp),
                        readOnly: false,
                        onChanged: (value) {
                          controller.searchTradePairs(value);
                        },
                        suffixIcon: controller.searchController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  controller.resetFilters();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15.sp,
                                  ),
                                  child: Icon(Icons.cancel, size: 18.sp),
                                ),
                              )
                            : null,
                      ),
                      SizedBox(height: 20.sp),
                      _autoScrollCoins(),
                      SizedBox(height: 20.sp),
                      _tabs(),
                      SizedBox(height: 10.sp),
                      _marketSection(),
                    ],
                  ),
                ),
                if (controller.isLoading) const CustomLoader(isLoading: true),
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================
  // AUTO SCROLL COINS
  // =============================
  Widget _autoScrollCoins() {
    if (controller.hotSpotList.isEmpty) {
      return SizedBox(
        height: 40.sp,
        child: Center(
          child: CustomText(
            label: AppLocalizations.of(context)!.noCoinsAvailable,
          ),
        ),
      );
    }

    return SizedBox(
      height: 40.sp,
      child: ListView.builder(
        controller: _coinScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: controller.hotSpotList.length,
        itemBuilder: (_, index) {
          final coin = controller.hotSpotList[index];

          return StreamBuilder(
            stream: controller.spotStreamController.stream,
            builder: (_, snapshot) {
              _updateFromSocket(snapshot.data, controller.hotSpotList);

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => _stopAutoScroll(),
                onTapCancel: _resumeAutoScroll,
                onTap: () async {
                  // await _showCoinDialog(context, coin);
                  // _resumeAutoScroll();
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 10.sp),
                  child: _coinCard(coin),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // =============================
  // TABS
  // =============================
  Widget _tabs() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.tabs(context).length,
        itemBuilder: (_, index) {
          final selected = controller.selectedIndex == index;

          return GestureDetector(
            onTap: () => controller.changeTab(index),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp),
              child: Column(
                children: [
                  CustomText(
                    label: controller.tabs(context)[index],
                    fontColour: selected
                        ? ThemeInversePrimaryColor.getInversePrimaryColor(
                            context,
                          )
                        : ThemeTextColor.getTextColor(context),
                  ),
                  SizedBox(height: 10.sp),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 2,
                    width: selected ? 55 : 0,
                    color: ThemeInversePrimaryColor.getInversePrimaryColor(
                      context,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =============================
  // MARKET SECTION
  // =============================
  Widget _marketSection() {
    if (controller.selectedIndex == 0) {
      return Expanded(child: _marketList(controller.hotSpotListFilter));
    } else if (controller.selectedIndex == 1) {
      return Expanded(child: _marketList(controller.topGainersListFilter));
    } else if (controller.selectedIndex == 2) {
      return Expanded(child: _marketList(controller.topLosersListFilter));
    } else {
      return Expanded(child: _marketList(controller.newListFilter));
    }
  }

  // =============================
  // MARKET LIST (OVERFLOW FIXED)
  // =============================
  Widget _marketList(List<MarketCoinModel> list) {
    if (list.isEmpty) {
      return Center(
        child: CustomText(
          label: AppLocalizations.of(context)!.noCoinsAvailable,
        ),
      );
    }

    controller.hotSpotList.sort((a, b) => double.parse(b.exchange).compareTo(double.parse(a.exchange)));
    controller.hotSpotListFilter.sort((a, b) => double.parse(b.exchange).compareTo(double.parse(a.exchange)));

    controller.topGainersList.sort((a, b) => double.parse(b.exchange).compareTo(double.parse(a.exchange)));
    controller.topGainersListFilter.sort((a, b) => double.parse(b.exchange).compareTo(double.parse(a.exchange)));

    controller.newList.sort((a, b) => double.parse(b.exchange).compareTo(double.parse(a.exchange)));
    controller.newListFilter.sort((a, b) => double.parse(b.exchange).compareTo(double.parse(a.exchange)));

    controller.topLosersList.sort((a, b) => double.parse(a.exchange).compareTo(double.parse(b.exchange)));
    controller.topLosersListFilter.sort((a, b) => double.parse(a.exchange).compareTo(double.parse(b.exchange)));
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: CustomText(
                label: AppLocalizations.of(context)!.tradingPair,
                fontSize: 15.sp,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
              ),
            ),
            SizedBox(width: 17.sp),
            Expanded(
              flex: 2,
              child: CustomText(
                label: AppLocalizations.of(context)!.price,
                fontSize: 15.sp,
                align: TextAlign.start,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
              ),
            ),
            Expanded(
              flex: 2,
              child: CustomText(
                label: AppLocalizations.of(context)!.twentyFourChange,
                fontSize: 15.sp,
                align: TextAlign.end,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, index) {
              final item = list[index];

              return StreamBuilder(
                stream: controller.spotStreamController.stream,
                builder: (_, snapshot) {
                  _updateFromSocket(snapshot.data, list);

                  return InkWell(
                    onTap: (){
                      spotTradeController.selectFromOutside(item.coinOne+item.coinTwo);

                      rootController.handleTradeClick(true);
                      rootController.setCenterPage(2, "update");
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.sp),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (item.isFavorite == true) {
                                      controller.removeFav(
                                        context: context,
                                        id: item.pairId.toString(),
                                        item: item,
                                      );
                                    } else {
                                      controller.addFav(
                                        context: context,
                                        id: item.pairId.toString(),
                                        item: item,
                                      );
                                    }
                                  },
                                  child: AnimatedRotation(
                                    turns: item.isFavorite == true ? 1 : 0,
                                    curve: Curves.decelerate,
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      item.isFavorite == true
                                          ? Icons.star
                                          : Icons.star_border_purple500_sharp,
                                      color: item.isFavorite == true
                                          ? ThemePrimaryColor.getPrimaryColor(
                                              context,
                                            )
                                          : ThemeTextOneColor.getTextOneColor(
                                              context,
                                            ),
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.sp),
                                // CustomText(
                                //   label: "${item.coinOne}/${item.coinTwo}",
                                //   labelFontWeight: FontWeight.bold,
                                // ),
                                RichText(
                                  text: TextSpan(
                                    text: item.coinOne,
                                    style: TextStyle(
                                      color: ThemeTextColor.getTextColor(context),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Outfit',
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "/${item.coinTwo}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              ThemeTextOneColor.getTextOneColor(
                                                context,
                                              ),
                                          fontSize: 13.sp,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // SizedBox(height: 12.sp),
                                // CustomText(
                                //   label: "${item.volume} USDT",
                                //   fontSize: 14.sp,
                                //   fontColour: ThemeTextOneColor.getTextOneColor(
                                //     context,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child:
                                // Column(
                                //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   children: [
                                CustomText(
                                  label: item.last,
                                  labelFontWeight: FontWeight.bold,
                                  align: TextAlign.start,
                                  fontSize: 15.sp,
                                ),
                            //     SizedBox(height: 12.sp),
                            //     CustomText(
                            //       label: "${item.last} USDT",
                            //       fontSize: 14.sp,
                            //       fontColour: ThemeTextOneColor.getTextOneColor(
                            //         context,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ),
                          SizedBox(width: 20.sp),

                          /// ✅ FIXED HERE
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10.sp,
                                horizontal: 6.sp,
                              ),
                              decoration: BoxDecoration(
                                color: item.exchange.contains('-')
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(8.sp),
                              ),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: CustomText(
                                    label: item.exchange + "%",
                                    labelFontWeight: FontWeight.w800,
                                    fontColour: Colors.white,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // =============================
  // COIN CARD
  // =============================
  Widget _coinCard(MarketCoinModel coin) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 35.w),
      child: Container(
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          color: ThemeTextFormFillColor.getTextFormFillColor(context),
          borderRadius: BorderRadius.circular(12.sp),
          border: Border.all(
            width: 5.sp,
            color: ThemeOutLineColor.getOutLineColor(context),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.network(coin.image, height: 22.sp),
                SizedBox(width: 8.sp),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      label: coin.coinOne,
                      maxLines: 1,
                      fontSize: 14.sp,
                    ),
                    CustomText(
                      label: coin.coinOneName,
                      maxLines: 1,
                      fontSize: 13.sp,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: CustomText(
                    label:
                        "\$${double.parse((coin.last.toString().isNotEmpty && coin.last.toString().toLowerCase() != "null") ? coin.last.toString() : "0.0").toStringAsFixed(2)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(width: 6.sp),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      Icon(
                        coin.exchange.contains('-')
                            ? Icons.arrow_drop_down_outlined
                            : Icons.arrow_drop_up,
                        color: coin.exchange.contains('-')
                            ? Colors.red
                            : Colors.green,
                        size: 18.sp,
                      ),
                      CustomText(
                        label: coin.exchange,
                        fontColour: coin.exchange.contains('-')
                            ? Colors.red
                            : Colors.green,
                        fontSize: 14.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /*  // =============================
  // ALERT
  // =============================
  Future<void> _showCoinDialog(BuildContext context, coin) {
    return customAlert(
      context: context,
      title: AppLocalizations.of(context)!.coinDetails,
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.network(coin.image, height: 26.sp),
              SizedBox(width: 12.sp),
              CustomText(
                label: "${coin.coinOne}/${coin.coinTwo}",
                labelFontWeight: FontWeight.bold,
              ),
            ],
          ),
          SizedBox(height: 12.sp),
          CustomText(
            label: "${AppLocalizations.of(context)!.price} \$${coin.last}",
          ),
          SizedBox(height: 10.sp),
          CustomText(
            label:
                "${AppLocalizations.of(context)!.marketChange} ${coin.exchange}%",
            fontColour: coin.exchange.contains('-')
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.tertiary,
          ),
          SizedBox(height: 10.sp),
          CustomText(
            label: "${AppLocalizations.of(context)!.volume} ${coin.volume}",
          ),
        ],
      ),
    );
  }*/
}
