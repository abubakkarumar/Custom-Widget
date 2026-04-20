import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/kchart_page.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../../../../Utility/Basics/api_endpoints.dart';
import '../../../../Utility/Basics/custom_loader.dart';
import '../../../../Utility/Colors/custom_theme_change.dart';
import '../../../../Utility/custom_alertbox.dart';
import '../../../../Utility/custom_button.dart';
import '../../../../Utility/custom_list_items.dart';
import '../../../../Utility/custom_text.dart';
import '../../../Side_Menu_Pages/Security/Delete_Account/delete_account_view.dart';
import '../future_history/future_my_orders.dart';
import '../future_history/future_open_orders.dart';
import '../future_history/future_pnl_history.dart';
import '../future_history/future_positions.dart';
import '../transfer/transfer_view.dart';
import 'custom_bottom_sheet.dart';
import 'formatter.dart';
import 'future_trade_controller.dart';
import 'future_trade_pairs.dart';
import 'orderbook_ui_future.dart';

class FutureTradeView extends StatefulWidget {
  const FutureTradeView({super.key});

  @override
  State<FutureTradeView> createState() => _FutureTradeViewState();
}

class _FutureTradeViewState extends State<FutureTradeView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  FutureTradeController controller = FutureTradeController();
  final GlobalKey leftKey = GlobalKey();
  double leftHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = leftKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() {
          leftHeight = box.size.height;
        });
      }
    });

    Future.delayed(Duration.zero).whenComplete(() async {
      controller.clearFirstEvent();
      controller.resetData();
      controller.setOrderType(controller.orderTypesList.first.toString(), "0");
      controller.getTradePairs(context);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.disposeData();
    super.dispose();
  }

  // titleWidget: const FutureTradePairs(),
  @override
  Widget build(BuildContext context) {
    return Consumer<FutureTradeController>(
      builder: (context, value, child) {
        controller = value;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () {
                  return Future.delayed(Duration.zero).whenComplete(() async {
                    controller.clearFirstEvent();
                    controller.resetData();
                    controller.setOrderType(
                      controller.orderTypesList.first.toString(),
                      "0",
                    );
                    controller.getTradePairs(context);
                  });
                },
                child: AbsorbPointer(
                  absorbing: controller.isLoading,
                  child: uI(context, controller),
                ),
              ),
              CustomLoader(isLoading: controller.isLoading),
            ],
          ),
        );
      },
    );
  }

  uI(BuildContext context, FutureTradeController controller) {
    return Padding(
      padding: EdgeInsets.all(8.sp),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            FutureTradePairs(),
            tradePairLivePrice(context),

            if (controller.isPriceChartEnabled ||
                controller.isDepthChartEnabled)
              // ChartContainer(),
              KChartPageFutureTrade(),

            SizedBox(height: 15.sp),
            if (!controller.isPriceChartEnabled &&
                !controller.isDepthChartEnabled)
              Column(
                children: [
                  IntrinsicHeight(
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
                                return OrderBookUiFuture(
                                  controller: controller,
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
                            child: Column(
                              children: [
                                Expanded(
                                  child: buySellOrder(context, controller),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  getBalanceContainer(),
                  SizedBox(height: 10.sp),
                  contractDetails(context, controller),
                  SizedBox(height: 15.sp),
                  CustomTabView(
                    length: 4,
                    isScrollable: true,
                    tabViewHeight: 60.h,
                    listName: [
                      Tab(
                        text:
                            "${AppLocalizations.of(context)!.positions} (${controller.futuresPositionsList.length})",
                      ),
                      Tab(text: AppLocalizations.of(context)!.pnlHistory),
                      Tab(
                        text:
                            "${AppLocalizations.of(context)!.openOrders} (${controller.futuresOpenOrdersList.length})",
                      ),
                      Tab(text: AppLocalizations.of(context)!.myOrderHistory),
                    ],
                    functions: const [
                      FuturePositions(),
                      FuturePnLHistory(),
                      FutureOpenOrders(),
                      FutureMyOrders(),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  tradePairLivePrice(BuildContext context) {
    return StreamBuilder(
      stream: controller.priceStreamController?.stream,
      builder: (context, snap) {
        if (controller.liquidityType == "bybit") {
          if (snap.hasData) {
            try {
              final data = snap.data as Map<String, dynamic>;

              if (data.isNotEmpty) {
                final pair = controller.tradePair.toString();

                if (data['data'] != null) {
                  if (data['data'].containsKey('symbol') &&
                      data['data']['symbol'].toString() == pair) {
                    if (data['data']['lastPrice'] != null) {
                      controller.lastPrice = double.parse(
                        data['data']['lastPrice'].toString(),
                      );
                    }

                    if (data['data']['price24hPcnt'] != null) {
                      controller.change24H =
                          (double.parse(
                            data['data']['price24hPcnt'].toString(),
                          )) *
                          100;
                    }

                    if (data['data']['volume24h'] != null) {
                      controller.volume24H = double.parse(
                        data['data']['volume24h'].toString(),
                      );
                    }

                    if (data['data']['lowPrice24h'] != null) {
                      controller.low24H = double.parse(
                        data['data']['lowPrice24h'].toString(),
                      );
                    }
                    if (data['data']['markPrice'] != null) {
                      controller.markPrice = double.parse(
                        data['data']['markPrice'].toString(),
                      );
                    }
                  }
                }
              }
            } catch (e) {
              //
            }
          } else {}
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                tradePairList(context, controller);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12.sp),
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    padding: EdgeInsets.all(10.sp),
                    child: SvgPicture.network(
                      controller.coinOneImage.toString(),
                      height: 22.sp,
                      width: 22.sp,
                    ),
                  ),
                  SizedBox(width: 5.sp),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        label: controller.lastPrice.toStringAsFixed(2),
                        // fontColour: AppColors.primaryText,
                        fontSize: 16.sp,
                        labelFontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 4.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomText(
                            label: controller.contractType,
                            // fontColour: AppColors.secondaryText,
                            fontSize: 14.sp,
                            labelFontWeight: FontWeight.w400,
                          ),
                          SizedBox(width: 12.sp),
                          CustomText(
                            label:
                                "${controller.change24H < 0 ? "-" : "+"}${controller.change24H < 0 ? controller.change24H.toStringAsFixed(3).replaceAll("-", "") : controller.change24H.toStringAsFixed(3).replaceAll("+", "")}%",
                            fontColour: controller.change24H < 0
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.tertiary,
                            fontSize: 14.sp,
                            labelFontWeight: FontWeight.w400,
                          ),
                          SizedBox(width: 8.sp),
                          controller.change24H < 0
                              ? Icon(
                                  Icons.arrow_drop_down_outlined,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 13.sp,
                                )
                              : Icon(
                                  Icons.arrow_drop_up,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  size: 13.sp,
                                ),
                          // SvgPicture.asset(
                          //   controller.change24H < 0
                          //       ? AppImages.downArrowRed
                          //       : AppImages.upArrowGreen,
                          //   height: 13.sp,
                          // ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      label: AppLocalizations.of(context)!.twentyFourVolume,
                      // fontColour: AppColors.secondaryText,
                      fontSize: 13.sp,
                      labelFontWeight: FontWeight.w400,
                    ),
                    SizedBox(height: 4.sp),
                    CustomText(
                      label: controller.volume24H.toString(),
                      // fontColour: AppColors.primaryText,
                      fontSize: 15.sp,
                      labelFontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                SizedBox(width: 15.sp),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      label: AppLocalizations.of(context)!.twentyFourLow,
                      // fontColour: AppColors.secondaryText,
                      fontSize: 13.sp,
                      labelFontWeight: FontWeight.w400,
                    ),
                    SizedBox(height: 4.sp),
                    CustomText(
                      label: controller.low24H.toString(),
                      // fontColour: AppColors.primaryText,
                      fontSize: 15.sp,
                      labelFontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  chart(BuildContext context, FutureTradeController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.sp),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Row(
              key: ValueKey<int>(controller.chartTabIndex),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // CustomGestureButton(
                //     onTap: () {
                //       controller.setChartTab(1);
                //     },
                //     child: SvgPicture.asset(controller.chartTabIndex == 1
                //         ? AppImages.priceChartActive
                //         : AppImages.priceChartInactive)),
                // CustomGestureButton(
                //     onTap: () {
                //       controller.setChartTab(2);
                //     },
                //     child: SvgPicture.asset(controller.chartTabIndex == 2
                //         ? AppImages.depthChartActive
                //         : AppImages.depthChartInactive))
              ],
            ),
          ),
          controller.chartTabIndex != 0
              ? SizedBox(height: 15.sp)
              : const SizedBox.shrink(),
          Visibility(
            visible: controller.chartTabIndex == 1,
            child: controller.tradePairTabIndex == 0
                ? priceChartPerpetualWebView()
                : priceChartFutureWebView(),
          ),
          Visibility(
            visible: controller.chartTabIndex == 2,
            child: depthChartWebView(),
          ),
        ],
      ),
    );
  }

  priceChartPerpetualWebView() {
    return SizedBox(
      height: 60.h,
      width: 100.w,
      child: Align(
        alignment: Alignment.center,
        child: InAppWebView(
          key: controller.priceChartKey,
          initialData: InAppWebViewInitialData(
            data: controller.getPriceChartHTML(
              tradePair: controller.tradePair.contains("PERP")
                  ? "${controller.coinOne}${controller.coinTwo}"
                  : controller.tradePair,
            ),
          ),
          gestureRecognizers: {
            Factory<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(),
            ),
            Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
            ),
          },
          initialSettings: InAppWebViewSettings(
            transparentBackground: true,
            supportZoom: true,
            javaScriptEnabled: true,
            preferredContentMode: UserPreferredContentMode.MOBILE,
            displayZoomControls: true,
            builtInZoomControls: true,
            networkAvailable: true,
            loadWithOverviewMode: true,
            useWideViewPort: true,
            enableViewportScale: true,
          ),
          onWebViewCreated: (controllers) {
            controller.priceChartWebViewController = controllers;
          },
        ),
      ),
    );
  }

  tradePairList(BuildContext context, FutureTradeController controller) {
    return customBottomSheet(
      context: context,
      height: 60.h,
      title: AppLocalizations.of(context)!.selectPair,
      child: CustomTabView(
        length: 2,
        isScrollable: true,
        onChanged: (value) {
          controller.setTradePairTabIndex(value);
        },
        listName: [
          Tab(
            child: CustomText(label: AppLocalizations.of(context)!.perpetual),
          ),
          Tab(child: CustomText(label: AppLocalizations.of(context)!.futures)),
        ],
        functions: [
          perpetualTradePairList(context),
          futureTradePairList(context),
        ],
      ),
    );
  }

  perpetualTradePairList(BuildContext context) {
    List<FutureTradePairList> listFilter = controller.perpetualTradePairsList
        .where((element) => element.coinTwo == "USDT")
        .toList();

    return ListView.builder(
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.only(top: 15.sp),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: listFilter.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int i) {
        var list = listFilter[i];
        return StreamBuilder(
          stream: controller.priceStreamController?.stream,
          builder: (context, snap) {
            if (list.liquidity == "bybit") {
              if (snap.hasData) {
                try {
                  final data = snap.data as Map<String, dynamic>;

                  if (data.isNotEmpty) {
                    final pair = list.tradePair.toString();

                    if (data['data']['symbol'].toString() == pair) {
                      if (data['data']['lastPrice'] != null) {
                        list.price = data['data']['lastPrice'].toString();
                      }
                      if (data['data']['price24hPcnt'] != null) {
                        list.change =
                            (double.parse(
                                      data['data']['price24hPcnt'].toString(),
                                    ) *
                                    100)
                                .toStringAsFixed(3);
                      }
                    }
                  }
                } catch (e) {
                  // customFlutterToast(message: e);
                }
              } else {}
            }
            return CustomGestureButton(
              onTap: () {
                if (controller.tradePairId != list.id.toString()) {
                  var list = controller.perpetualTradePairsList[i];
                  controller.resetData();
                  controller.setTradePairTabIndex(0);
                  controller.setTradePair(
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
                    markPrice: double.parse(list.markPrice.toString()),
                    contractType: list.contractType.toString(),
                  );
                  // controller.getTradePairs(context);
                }
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(bottom: 20.sp),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(14.sp),
                          child: SvgPicture.network(
                            list.coinOneImage.toString(),
                            height: 22.sp,
                            width: 22.sp,
                          ),
                        ),
                        SizedBox(width: 12.sp),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              label: list.tradePair.toString(),
                              // fontColour: AppColors.primaryText,
                              fontSize: 16.sp,
                              labelFontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: 8.sp),
                            CustomText(
                              label:
                                  "${list.coinTwo} ${list.contractType.toString()}",
                              // fontColor: AppColors.secondaryText,
                              fontSize: 15.sp,
                              labelFontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomText(
                          label: list.price.toString(),
                          // fontColor: AppColors.primaryText,
                          fontSize: 16.sp,
                          labelFontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 8.sp),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // SvgPicture.asset(
                            double.parse(list.change.toString()) < 0
                                ? Icon(
                                    Icons.arrow_drop_down_outlined,
                                    color: Theme.of(context).colorScheme.error,
                                  )
                                : Icon(
                                    Icons.arrow_drop_up,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiary,
                                  ),

                            // height: 12.sp,
                            // ),
                            SizedBox(width: 8.sp),
                            CustomText(
                              label:
                                  "${double.parse(list.change.toString()) < 0 ? "-" : "+"}${double.parse(list.change.toString()) < 0 ? list.change.toString().replaceAll("-", "") : list.change.toString().replaceAll("+", "")}%",
                              fontColour:
                                  double.parse(list.change.toString()) < 0
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.tertiary,
                              fontSize: 14.sp,
                              labelFontWeight: FontWeight.w400,
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

  futureTradePairList(BuildContext context) {
    List<FutureTradePairList> listFilter = controller.perpetualTradePairsList
        .where((element) => element.coinTwo == "PERP")
        .toList();
    return ListView.builder(
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.only(top: 15.sp),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: listFilter.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int i) {
        var list = listFilter[i];
        return StreamBuilder(
          stream: controller.priceStreamController?.stream,
          builder: (context, snap) {
            if (list.liquidity == "bybit") {
              if (snap.hasData) {
                try {
                  final data = snap.data as Map<String, dynamic>;

                  if (data.isNotEmpty) {
                    final pair = list.tradePair.toString();

                    if (data['data']['symbol'].toString() == pair) {
                      if (data['data']['lastPrice'] != null) {
                        list.price = data['data']['lastPrice'].toString();
                      }
                      if (data['data']['price24hPcnt'] != null) {
                        list.change =
                            (double.parse(
                                      data['data']['price24hPcnt'].toString(),
                                    ) *
                                    100)
                                .toStringAsFixed(3);
                      }
                    }
                  }
                } catch (e) {
                  // customFlutterToast(message: e);
                }
              } else {}
            }
            return CustomGestureButton(
              onTap: () {
                if (controller.tradePairId != list.id.toString()) {
                  var list = controller.perpetualTradePairsList[i];
                  controller.resetData();
                  controller.setTradePairTabIndex(0);
                  controller.setTradePair(
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
                    markPrice: double.parse(list.markPrice.toString()),
                    contractType: list.contractType.toString(),
                  );
                  // controller.getTradePairs(context);
                }
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(bottom: 20.sp),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(14.sp),
                          child: SvgPicture.network(
                            list.coinOneImage.toString(),
                            height: 22.sp,
                            width: 22.sp,
                          ),
                        ),
                        SizedBox(width: 12.sp),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              label: list.tradePair.toString(),
                              // fontColour: AppColors.primaryText,
                              fontSize: 16.sp,
                              labelFontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: 8.sp),
                            CustomText(
                              label:
                                  "${list.coinTwo} ${list.contractType.toString()}",
                              // fontColor: AppColors.secondaryText,
                              fontSize: 15.sp,
                              labelFontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomText(
                          label: list.price.toString(),
                          // fontColor: AppColors.primaryText,
                          fontSize: 16.sp,
                          labelFontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 8.sp),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // SvgPicture.asset(
                            double.parse(list.change.toString()) < 0
                                ? Icon(
                                    Icons.arrow_drop_down_outlined,
                                    color: Theme.of(context).colorScheme.error,
                                  )
                                : Icon(
                                    Icons.arrow_drop_up,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiary,
                                  ),

                            // height: 12.sp,
                            // ),
                            SizedBox(width: 8.sp),
                            CustomText(
                              label:
                                  "${double.parse(list.change.toString()) < 0 ? "-" : "+"}${double.parse(list.change.toString()) < 0 ? list.change.toString().replaceAll("-", "") : list.change.toString().replaceAll("+", "")}%",
                              fontColour:
                                  double.parse(list.change.toString()) < 0
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.tertiary,
                              fontSize: 14.sp,
                              labelFontWeight: FontWeight.w400,
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

  priceChartFutureWebView() {
    return SizedBox(
      height: 60.h,
      width: 100.w,
      child: Align(
        alignment: Alignment.center,
        child: InAppWebView(
          key: controller.priceChartKey,
          initialUrlRequest: URLRequest(
            url: WebUri(
              "${ApiEndpoints.SPOT_PRICE_CHART_URL}${controller.tradePair}",
            ),
          ),
          gestureRecognizers: {
            Factory<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(),
            ),
            Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(),
            ),
          },
          initialSettings: InAppWebViewSettings(
            transparentBackground: true,
            supportZoom: true,
            javaScriptEnabled: true,
            preferredContentMode: UserPreferredContentMode.MOBILE,
            displayZoomControls: true,
            builtInZoomControls: true,
            networkAvailable: true,
            loadWithOverviewMode: true,
            useWideViewPort: true,
            enableViewportScale: true,
          ),
          onWebViewCreated: (controllers) {
            controller.priceChartWebViewController = controllers;
          },
        ),
      ),
    );
  }

  depthChartWebView() {
    return SizedBox(
      height: 60.h,
      child: InAppWebView(
        key: controller.depthChartKey,
        initialUrlRequest: URLRequest(
          url: WebUri(
            "${ApiEndpoints.SPOT_DEPTH_CHART_URL}${controller.tradePair}",
          ),
        ),
        onProgressChanged: (InAppWebViewController controllers, int progress) {
          controller.chartProgress = progress / 100;
        },
        gestureRecognizers: {
          Factory<HorizontalDragGestureRecognizer>(
            () => HorizontalDragGestureRecognizer(),
          ),
          Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer(),
          ),
        },
        initialSettings: InAppWebViewSettings(
          transparentBackground: true,
          supportZoom: true,
          javaScriptEnabled: true,
          preferredContentMode: UserPreferredContentMode.MOBILE,
          displayZoomControls: true,
          builtInZoomControls: true,
          networkAvailable: true,
          loadWithOverviewMode: true,
          useWideViewPort: true,
          enableViewportScale: true,
        ),
        onWebViewCreated: (controllers) {
          controller.depthChartWebViewController = controllers;
        },
      ),
    );
  }

  buySellOrder(BuildContext context, FutureTradeController controller) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            key: ValueKey<int>(controller.buySellTabIndex),
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    updateMarginAlert(context, controller);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.sp),
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                    ),
                    // label: controller.marginMode,
                    // color: AppColors.secondaryButton,
                    height: 5.h,
                    child: CustomText(
                      label: controller.marginMode,
                      fontColour: Colors.white,
                    ),

                    // fontSize: 15.5.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.sp),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    updateLeverageAlert(context, controller);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.sp),
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                    ),
                    // label: controller.marginMode,
                    // color: AppColors.secondaryButton,
                    height: 5.h,
                    child: CustomText(
                      label: "${controller.leverage}X",
                      fontColour: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.sp),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Row(
              key: ValueKey<int>(controller.buySellTabIndex),
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // controller.resetData();
                      controller.setBuySellTabIndex(0);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(15.sp),
                      ),

                      // label: "Buy/Long",
                      // color: controller.buySellTabIndex == 0
                      //     ? AppColors.greenButton
                      //     : AppColors.secondaryButton,
                      height: 5.h,
                      child: CustomText(
                        label: AppLocalizations.of(context)!.buyLong,
                        fontColour: Colors.white,
                        fontSize: 15.5.sp,
                        align: TextAlign.center,
                      ),
                      // fontSize: 15.5.sp,
                      //                 border: Border.all(
                      // color: controller.buySellTabIndex == 0
                      //     ? Theme.of(context).colorScheme.tertiary
                      //     : Theme.of(context).colorScheme.onPrimary.withOpacity(0.5)),
                    ),
                  ),
                ),
                SizedBox(width: 10.sp),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // controller.resetData();
                      controller.setBuySellTabIndex(1);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(15.sp),
                      ),

                      // label: "Buy/Long",
                      // color: controller.buySellTabIndex == 0
                      //     ? AppColors.greenButton
                      //     : AppColors.secondaryButton,
                      height: 5.h,
                      child: CustomText(
                        label: AppLocalizations.of(context)!.sellShort,
                        fontColour: Colors.white,
                        fontSize: 15.5.sp,
                        align: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15.sp),
          CustomTextFieldWidget(
            line: 1,
            readOnly: true,
            controller: controller.orderTypeController,
            hintText: AppLocalizations.of(context)!.selectOrderType,
            suffixIcon: Icon(Icons.arrow_drop_down_outlined),
            // SvgPicture.asset(
            //   AppImages.dropDown,
            //   height: 10.sp,
            // ),
            onTap: () {
              tradeOrderList(context, controller);
            },
            onValidate: (val) {
              if (val.toString().isEmpty) {
                return AppLocalizations.of(context)!.orderTypeRequired;
              }
              return null;
            },
          ),
          controller.orderTypeId == "0"
              ? SizedBox(height: 15.sp)
              : const SizedBox.shrink(),
          controller.orderTypeId == "0"
              ? CustomTextFieldWidget(
                  line: 1,
                  controller: controller.priceController,
                  hintText: AppLocalizations.of(context)!.price,
                  readOnly: false,
                  suffixIcon: CustomText(
                    label: controller.coinTwo,
                    fontSize: 15.sp,
                    labelFontWeight: FontWeight.w600,
                    // fontColor: AppColors.primaryText,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    AppFormatters(editingValidator: CryptoValidator()),
                  ],
                  onChanged: (val) {
                    controller.getValueCost();
                  },
                  onValidate: (val) {
                    if (controller.orderTypeId == "0") {
                      if (val.toString().isEmpty) {
                        return AppLocalizations.of(context)!.priceRequired;
                      } else if (double.parse(val.toString()) <= 0) {
                        return AppLocalizations.of(
                          context,
                        )!.priceShouldNotBeZero;
                      }
                    }
                    return null;
                  },
                )
              : const SizedBox.shrink(),

          if (controller.orderTypeId == "0")
            Padding(
              padding: EdgeInsets.only(right: 15.sp, top: 10.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.setLivePriceController("normal");
                    },
                    child: CustomText(
                      label: AppLocalizations.of(context)!.last,
                    ),
                  ),
                  // CustomText(
                  //   "BBO",
                  //   color: Theme.of(
                  //     context,
                  //   ).colorScheme.onPrimary,
                  //   role:
                  //       TextRole.bodyMedium,
                  // ),
                ],
              ),
            ),
          SizedBox(height: 15.sp),
          CustomTextFieldWidget(
            line: 1,
            controller: controller.amountController,
            hintText: AppLocalizations.of(context)!.amount,
            suffixIcon: CustomText(
              label: controller.coinOne,
              fontSize: 15.sp,
              labelFontWeight: FontWeight.w600,
              // fontColor: AppColors.primaryText,
            ),
            readOnly: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              AppFormatters(editingValidator: CryptoValidator()),
            ],
            onChanged: (val) {
              controller.getValueCost();
            },
            onValidate: (val) {
              if (val.toString().isEmpty) {
                return AppLocalizations.of(context)!.amountRequired;
              } else if (double.parse(val.toString()) <= 0) {
                return AppLocalizations.of(context)!.amountShouldNotBeZero;
              }
              return null;
            },
          ),
          SizedBox(height: 15.sp),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: ThemePrimaryColor.getPrimaryColor(context),
              inactiveTrackColor: ThemeOutLineColor.getOutLineColor(context),
              thumbColor: ThemePrimaryColor.getPrimaryColor(context),
              overlayColor: Colors.blue.withOpacity(0.2),
              tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 2),
              activeTickMarkColor: ThemePrimaryColor.getPrimaryColor(context),
              inactiveTickMarkColor: ThemeOutLineColor.getOutLineColor(context),
              trackHeight: 6,
              padding: EdgeInsets.symmetric(horizontal: 10.sp),
            ),
            child: Slider(
              value: controller.sliderValue,
              min: 0,
              max: 100,
              divisions: 100, // ⭐ this is the key
              label: "${controller.sliderValue.round()}%",
              onChanged: (value) {
                controller.percentageBasedAmountAndTotalAmount(value: value);
              },
            ),
          ),

          SizedBox(height: 15.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomGestureButton(
                onTap: () {
                  controller.isTPSLCheckBoxFunc();
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: CheckboxBox(isActive: controller.isTPSLChecked),
                  // SvgPicture.asset(
                  //   key: ValueKey<bool>(controller.isTPSLChecked),
                  //   controller.isTPSLChecked
                  //       ? AppImages.checkBoxEnable
                  //       : AppImages.checkBoxDisable,
                  //   height: 18.sp,
                  //
                  // ),
                ),
              ),
              SizedBox(width: 10.sp),
              CustomText(
                label: AppLocalizations.of(context)!.tpsl,
                labelFontWeight: FontWeight.w400,
                fontSize: 15.sp,
                // fontColor: AppColors.primaryText,
              ),
            ],
          ),
          !controller.isTPSLChecked
              ? const SizedBox.shrink()
              : SizedBox(height: 15.sp),
          !controller.isTPSLChecked
              ? const SizedBox.shrink()
              : addTPSL(context, controller),
          SizedBox(height: 15.sp),
          customLinearListItems(
            context: context,
            key: AppLocalizations.of(context)!.cost,
            useFlexible: false,
            value: "${controller.cost} ${controller.coinTwo}",
          ),
          SizedBox(height: 12.sp),
          customLinearListItems(
            context: context,
            key: AppLocalizations.of(context)!.valueText,
            useFlexible: false,
            value: "${controller.value} ${controller.coinTwo}",
          ),
          SizedBox(height: 18.sp),
          GestureDetector(
            onTap: () {
              if (controller.formKey.currentState!.validate()) {
                confirmOrderAlert(context);
              }
            },
            child: Container(
              height: 5.h,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: controller.buySellTabIndex == 1
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(15.sp),
              ),
              child: CustomText(
                label: controller.buySellTabIndex == 0
                    ? AppLocalizations.of(context)!.buyLong
                    : AppLocalizations.of(context)!.sellShort,
                fontColour: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  getBalanceContainer() {
    return Container(
      margin: EdgeInsets.all(10.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.sp),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Column(
        children: [
          customLinearListItems(
            context: context,
            key: AppLocalizations.of(context)!.marginBalance,
            useFlexible: false,
            value:
                (controller.futuresPositionsList.isEmpty &&
                    controller.futuresOpenOrdersList.isEmpty)
                ? "${controller.availableBalanceCopy.toStringAsFixed(2)} ${controller.coinTwo}"
                : "${controller.marginBalance.toStringAsFixed(2)} ${controller.coinTwo}",
          ),
          SizedBox(height: 12.sp),
          customLinearListItems(
            context: context,
            key: AppLocalizations.of(context)!.availableBalance,
            useFlexible: false,
            value:
                "${controller.availableBalanceCopy.toStringAsFixed(2)} ${controller.coinTwo}",
          ),
          SizedBox(height: 18.sp),
          CustomButton(
            label: AppLocalizations.of(context)!.transfer,
            onTap: () {
              transferAlert(context);
            },
          ),
        ],
      ),
    );
  }

  addTPSL(BuildContext context, FutureTradeController controller) {
    return Column(
      children: [
        CustomTextFieldWidget(
          line: 1,
          controller: controller.takeProfitController,
          hintText: AppLocalizations.of(context)!.takeProfit,
          suffixIcon: CustomGestureButton(
            onTap: () {
              controller.setTakeProfit(controller.lastPrice.toString());
            },
            child: CustomText(
              label: AppLocalizations.of(context)!.last,
              fontSize: 15.sp,
              labelFontWeight: FontWeight.w600,
              // fontColour: AppColors.primaryText,
            ),
          ),
          readOnly: false,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [AppFormatters(editingValidator: CryptoValidator())],
          onChanged: (val) {
            controller.getValueCost();
          },
          onValidate: (val) {
            if (val.toString().isEmpty) {
              return AppLocalizations.of(context)!.takeProfitRequired;
            } else if (double.parse(val.toString()) <= 0) {
              return AppLocalizations.of(context)!.takeProfitShouldNotBeZero;
            }
            return null;
          },
        ),
        SizedBox(height: 15.sp),
        CustomTextFieldWidget(
          line: 1,
          controller: controller.stopLossController,
          hintText: AppLocalizations.of(context)!.stopLoss,
          suffixIcon: CustomGestureButton(
            onTap: () {
              controller.setStopLoss(controller.lastPrice.toString());
            },
            child: CustomText(
              label: AppLocalizations.of(context)!.last,
              fontSize: 15.sp,
              labelFontWeight: FontWeight.w600,
              // fontColor: AppColors.primaryText,
            ),
          ),
          readOnly: false,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [AppFormatters(editingValidator: CryptoValidator())],
          onChanged: (val) {
            controller.getValueCost();
          },
          onValidate: (val) {
            if (val.toString().isEmpty) {
              return AppLocalizations.of(context)!.stopLossRequired;
            } else if (double.parse(val.toString()) <= 0) {
              return AppLocalizations.of(context)!.stopLossShouldNotBeZero;
            }
            return null;
          },
        ),
      ],
    );
  }

  contractDetails(BuildContext context, FutureTradeController controller) {
    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: StreamBuilder(
        stream: controller.priceStreamController?.stream,
        builder: (context, snap) {
          if (controller.liquidityType == "bybit") {
            if (snap.hasData) {
              final data = snap.data as Map<String, dynamic>;

              if (data.isNotEmpty) {
                final pair = controller.tradePair.toString();

                if (data['data'] != null) {
                  if (data['data'].containsKey('symbol') &&
                      data['data']['symbol'].toString() == pair) {
                    if (data['data']['indexPrice'] != null) {
                      controller.indexPrice = double.parse(
                        data['data']['indexPrice'].toString(),
                      );
                    }
                    if (data['data']['markPrice'] != null) {
                      controller.markPrice = double.parse(
                        data['data']['markPrice'].toString(),
                      );
                    }
                    if (data['data']['openInterest'] != null) {
                      controller.openInterestPrice = double.parse(
                        data['data']['openInterest'].toString(),
                      );
                    }
                    if (data['data']['turnover24h'] != null) {
                      controller.turnOver24H = double.parse(
                        data['data']['turnover24h'].toString(),
                      );
                    }
                    if (data['data']['volume24h'] != null) {
                      controller.volume24H = double.parse(
                        data['data']['volume24h'].toString(),
                      );
                    }
                  }
                }
              }
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomText(
                label:
                    "${AppLocalizations.of(context)!.contactDetails} ${controller.tradePair}",
                fontSize: 15.sp,
                labelFontWeight: FontWeight.bold,
              ),
              SizedBox(height: 12.sp),
              customListItems(
                context: context,
                leadingKey: AppLocalizations.of(context)!.expirationDate,
                leadingValue: controller.tradePairTabIndex == 0
                    ? AppLocalizations.of(context)!.perpetual
                    : controller.tradePair,
                trailingKey: AppLocalizations.of(context)!.indexPrice,
                trailingValue:
                    "${controller.indexPrice.toStringAsFixed(2)} ${controller.coinTwo}",
              ),
              customListItems(
                context: context,
                leadingKey: AppLocalizations.of(context)!.markPrice,
                leadingValue:
                    "${controller.markPrice.toStringAsFixed(2)} ${controller.coinTwo}",
                trailingKey: AppLocalizations.of(context)!.openInterest,
                trailingValue:
                    "${controller.openInterestPrice.toStringAsFixed(4)} ${controller.coinOne}",
              ),
              customListItems(
                context: context,
                leadingKey: AppLocalizations.of(context)!.twentyFourTurnOver,
                leadingValue:
                    "${controller.turnOver24H.toStringAsFixed(2)} ${controller.coinTwo}",
                trailingKey: AppLocalizations.of(context)!.twentyFourVolume,
                trailingValue:
                    "${controller.volume24H.toStringAsFixed(4)} ${controller.coinOne}",
              ),
            ],
          );
        },
      ),
    );
  }

  tradeOrderList(BuildContext context, FutureTradeController controller) {
    return customBottomSheet(
      context: context,
      height: 30.h,
      title: AppLocalizations.of(context)!.selectOrderType,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: controller.orderTypesList.length,
        itemBuilder: (context, i) {
          var list = controller.orderTypesList[i];
          return CustomGestureButton(
            onTap: () {
              controller.setOrderType(list.toString(), i.toString());

              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.all(15.sp),
              child: CustomText(
                label: list.toString(),
                labelFontWeight: FontWeight.w500,
                fontSize: 17.sp,
                // fontColour: AppColors.primaryText,
              ),
            ),
          );
        },
      ),
    );
  }

  updateMarginAlert(BuildContext context, FutureTradeController controller) {
    return customAlert(
      context: context,
      title: AppLocalizations.of(context)!.adjustMarginMode,
      widget: Consumer<FutureTradeController>(
        builder: (context, value, child) {
          controller = value;
          return Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Column(
                children: [
                  CustomGestureButton(
                    onTap: () {
                      controller.setMarginModeId(0);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxBox(isActive: controller.marginModeId == 0),
                        // SvgPicture.asset(
                        //   controller.marginModeId == 0
                        //       ? AppImages.checkBoxEnable
                        //       : AppImages.checkBoxDisable,
                        //   height: 18.sp,
                        // ),
                        SizedBox(width: 15.sp),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CustomText(
                                label: AppLocalizations.of(
                                  context,
                                )!.crossMarginMode,
                                fontSize: 15.5.sp,
                                // fontColour: AppColors.primaryText,
                                labelFontWeight: FontWeight.w600,
                              ),
                              SizedBox(height: 10.sp),
                              CustomText(
                                label: AppLocalizations.of(
                                  context,
                                )!.crossModeDescription,
                                fontSize: 14.sp,
                                // fontColour: AppColors.secondaryText,
                                labelFontWeight: FontWeight.w400,
                                align: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  CustomGestureButton(
                    onTap: () {
                      controller.setMarginModeId(1);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SvgPicture.asset(
                        CheckboxBox(isActive: controller.marginModeId == 1),

                        //   height: 18.sp,
                        // ),
                        SizedBox(width: 15.sp),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CustomText(
                                label: AppLocalizations.of(
                                  context,
                                )!.isolatedMarginMode,
                                fontSize: 15.5.sp,
                                // fontColour: AppColors.primaryText,
                                labelFontWeight: FontWeight.w600,
                              ),
                              SizedBox(height: 10.sp),
                              CustomText(
                                label: AppLocalizations.of(
                                  context,
                                )!.isolatedModeDescription,
                                fontSize: 14.sp,
                                // fontColour: AppColors.secondaryText,
                                labelFontWeight: FontWeight.w400,
                                align: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.sp),
                  CustomButton(
                    onTap: () {
                      controller.doUpdateMargin(context).whenComplete(() {
                        if (controller.isSuccess) {
                          Navigator.pop(context);
                        }
                      });
                    },
                    label: AppLocalizations.of(context)!.submit,
                  ),
                ],
              ),
              CustomLoader(isLoading: controller.isLoading),
            ],
          );
        },
      ),
    );
  }

  updateLeverageAlert(BuildContext context, FutureTradeController controller) {
    return customAlert(
      context: context,
      title: AppLocalizations.of(context)!.adjustLeverage,
      onTapBack: () {
        print("controller.leverage ${controller.leverage}");
        if (controller.leverage.isNotEmpty) {
          controller.setLeverage(int.parse(controller.leverage));
        }

        Navigator.pop(context);
      },
      widget: Consumer<FutureTradeController>(
        builder: (context, value, child) {
          controller = value;
          return Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(
                    label: AppLocalizations.of(context)!.leverage,
                    fontSize: 16.sp,
                    labelFontWeight: FontWeight.w600,
                    // fontColour: AppColors.primaryText,
                  ),
                  SizedBox(height: 10.sp),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 22.sp,
                      horizontal: 18.sp,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomGestureButton(
                          onTap: () {
                            controller.setLeverageCopy(false);
                          },
                          child: Icon(Icons.remove),
                          // SvgPicture.asset(
                          //   AppImages.subtract,
                          //   width: 3.5.h,
                          // )
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 15.w,
                              child: TextField(
                                controller: controller.leverageController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (controller.leverageController.text
                                      .toString()
                                      .isNotEmpty) {
                                    controller.setLeverageCopyType(
                                      int.parse(
                                        controller.leverageController.text
                                            .toString(),
                                      ),
                                    );
                                  }
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Only numbers
                                  LengthLimitingTextInputFormatter(
                                    3,
                                  ), // Max 3 digits
                                ],
                              ),
                            ),
                            CustomText(
                              label: "X",
                              fontSize: 18.sp,
                              labelFontWeight: FontWeight.w600,
                              // fontColour: AppColors.primaryText,
                            ),
                          ],
                        ),
                        CustomGestureButton(
                          onTap: () {
                            controller.setLeverageCopy(true);
                          },
                          child: Icon(Icons.add),
                          // SvgPicture.asset(
                          //   AppImages.add,
                          //   width: 3.5.h,
                          // )
                        ),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: controller.leverageCopy > 20 ? 1.0 : 0.0,
                    child: controller.leverageCopy > 20
                        ? Padding(
                            padding: EdgeInsets.only(top: 12.sp),
                            child: CustomText(
                              label: AppLocalizations.of(
                                context,
                              )!.leverageWarning,
                              fontSize: 14.sp,
                              fontColour: Theme.of(context).colorScheme.error,
                              labelFontWeight: FontWeight.w400,
                              align: TextAlign.center,
                            ),
                          )
                        : const SizedBox(),
                  ),
                  SizedBox(height: 20.sp),
                  CustomButton(
                    onTap: () {
                      if (controller.leverageController.text
                              .toString()
                              .isNotEmpty &&
                          double.parse(controller.leverageController.text) >
                              100) {
                        CustomAnimationToast.show(
                          message: AppLocalizations.of(
                            context,
                          )!.leverageMaxAlert,
                          context: context,
                          type: ToastType.error,
                        );
                        return;
                      }
                      controller.setLeverage(
                        int.parse(
                          controller.leverageController.text.toString(),
                        ),
                      );

                      controller.doUpdateLeverage(context).whenComplete(() {
                        if (controller.isSuccess) {
                          Navigator.pop(context);
                        }
                      });
                    },
                    label: AppLocalizations.of(context)!.submit,
                  ),
                ],
              ),
              CustomLoader(isLoading: controller.isLoading),
            ],
          );
        },
      ),
    );
  }

  transferAlert(BuildContext context) {
    return customAlert(
      context: context,
      title: AppLocalizations.of(context)!.transfer,
      widget: TransferView(type:'futures'),
    );
  }

  confirmOrderAlert(BuildContext context) {
    return customAlert(
      context: context,
      title: AppLocalizations.of(context)!.confirmOrder,
      widget: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Padding(
            padding: EdgeInsets.all(15.sp),
            child: Column(
              children: [
                CustomText(
                  label: AppLocalizations.of(
                    context,
                  )!.pleaseVerifyBeforeConfirming,
                  fontSize: 15.sp,
                  labelFontWeight: FontWeight.w500,
                  // fontColour: AppColors.secondaryText,
                ),
                SizedBox(height: 15.sp),
                customLinearListItems(
                  context: context,
                  key: AppLocalizations.of(context)!.contracts,
                  value: controller.tradePair,
                ),
                SizedBox(height: 12.sp),
                customLinearListItems(
                  context: context,
                  key: AppLocalizations.of(context)!.orderType,
                  value: controller.orderTypeController.text,
                ),
                SizedBox(height: 12.sp),
                customLinearListItems(
                  context: context,
                  key: AppLocalizations.of(context)!.type,
                  value: controller.buySellTabIndex == 0
                      ? AppLocalizations.of(context)!.buy
                      : AppLocalizations.of(context)!.sell,
                ),
                SizedBox(height: 12.sp),
                controller.orderTypeId != "0"
                    ? const SizedBox.shrink()
                    : customLinearListItems(
                        context: context,
                        key: AppLocalizations.of(context)!.price,
                        value:
                            "${controller.priceController.text} ${controller.coinTwo}",
                      ),
                controller.orderTypeId != "0"
                    ? const SizedBox.shrink()
                    : SizedBox(height: 12.sp),
                customLinearListItems(
                  context: context,
                  key: AppLocalizations.of(context)!.amount,
                  value:
                      "${controller.amountController.text} ${controller.coinOne}",
                ),
                SizedBox(height: 15.sp),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: AppLocalizations.of(context)!.cancel,
                        backgroundColor: Theme.of(context).colorScheme.error,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(width: 15.sp),
                    Expanded(
                      child: CustomButton(
                        label: AppLocalizations.of(context)!.confirm,
                        onTap: () {
                          Navigator.pop(context);

                          if (controller.orderTypeId == "0") {
                            /// Limit order
                            controller.doLimitOrder(context);
                          } else {
                            /// Market order
                            controller.doMarketOrder(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomLoader(isLoading: controller.isLoading),
        ],
      ),
    );
  }
}

class CustomTabView extends StatefulWidget {
  final double? height;
  final double? tabViewHeight;
  final void Function(int)? onChanged;
  final List<Widget> listName;
  final List<Widget> functions;
  final bool isScrollable;
  final int length;
  final int initialIndex;

  const CustomTabView({
    super.key,
    required this.isScrollable,
    this.height,
    required this.listName,
    required this.functions,
    required this.length,
    this.tabViewHeight,
    this.onChanged,
    this.initialIndex = 0,
  });

  @override
  State<CustomTabView> createState() => _CustomTabViewState();
}

class _CustomTabViewState extends State<CustomTabView>
    with TickerProviderStateMixin {
  late TabController _controller;
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = TabController(
      length: widget.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );

    _lastIndex = _controller.index;

    _controller.addListener(() {
      if (!_controller.indexIsChanging && _lastIndex != _controller.index) {
        _lastIndex = _controller.index;
        HapticFeedback.lightImpact();
        widget.onChanged?.call(_controller.index);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height ?? 5.h,
          child: TabBar(
            isScrollable: widget.isScrollable,
            controller: _controller,

            labelColor: ThemeTextColor.getTextColor(context),
            unselectedLabelColor: ThemeTextOneColor.getTextOneColor(context),

            indicatorColor: ThemeInversePrimaryColor.getInversePrimaryColor(
              context,
            ),

            dividerColor:Colors.transparent,
            dividerHeight: 4.sp,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 6.sp,

            padding: EdgeInsets.only(left: 5.sp, right: 5.sp),

            labelPadding: widget.isScrollable
                ? EdgeInsets.symmetric(horizontal: 12.sp)
                : EdgeInsets.zero,

            indicatorPadding: EdgeInsets.zero,
            tabAlignment: widget.isScrollable ? TabAlignment.start : null,

            labelStyle: TextStyle(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w600,
            ),

            unselectedLabelStyle: TextStyle(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w400,
            ),

            tabs: widget.listName,
          ),
        ),
        SizedBox(height: 12.sp),

        widget.tabViewHeight != null
            ? SizedBox(
                height: widget.tabViewHeight,
                child: TabBarView(
                  controller: _controller,
                  children: widget.functions,
                ),
              )
            : Expanded(
                child: TabBarView(
                  controller: _controller,
                  children: widget.functions,
                ),
              ),
      ],
    );
  }
}
