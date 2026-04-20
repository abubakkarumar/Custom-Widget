import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Market/market_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';

import '../../../l10n/app_localizations.dart';

class AllTradePairs extends StatefulWidget {
  final String type;
  const AllTradePairs({super.key, required this.type});

  @override
  State<AllTradePairs> createState() => _AllTradePairsState();
}

class _AllTradePairsState extends State<AllTradePairs> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<SpotTradeController, MarketController>(
      builder: (context, controller, mController, child) {
        return widget.type == "fav"?
            getFavList(controller, mController):
            widget.type == "usdt"
            ? getUSDTList(controller, mController)
            : widget.type == "link"
            ? getLINKList(controller, mController)
            : getAllList(controller, mController);
      },
    );
  }

  getFavList(SpotTradeController controller, MarketController mController) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 15.sp),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
            CustomText(
              label: AppLocalizations.of(context)!.tradingPair,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
            CustomText(
              label: AppLocalizations.of(context)!.lastPrice,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
            CustomText(
              label: AppLocalizations.of(context)!.twentyFourVolume,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
            CustomText(
              label: AppLocalizations.of(context)!.twentyFourChange,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
          ],),
          SizedBox(height: 15.sp),
          controller.favTradePairList.isEmpty
              ? Center(
            child: CustomText(
              label: AppLocalizations.of(context)!.noDataAvailable,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
          )
              : ListView.builder(
            itemCount: controller.favTradePairList.length,
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemBuilder: (_, index) {
              final item = controller.favTradePairList[index];
              // final realIndex = controller.hotSpotList
              //     .indexOf(item);

              return StreamBuilder(
                stream: mController.spotStreamController.stream,
                builder: (context, snapshot) {
                  String _ = '';
                  String _ = '';
                  bool _ = false;
                  String lastPrice = '';
                  String _ = '';
                  String volume24 = '';

                  print("Snapshot data in all trade pairs: ${snapshot.data}");
                  // final parsed = jsonDecode(data);
                  // final symbol = parsed["data"]['symbol']?.toString();
                  //
                  // final index = list.indexWhere((e) => "${e.coinOne}${e.coinTwo}" == symbol);
                  //
                  // if (index == -1) return;
                  //
                  // list[index].last =
                  // (double.tryParse(parsed["data"]['lastPrice']?.toString() ?? "0") ?? 0)
                  //     .toStringAsFixed(2);
                  //
                  // list[index].volume =
                  // (double.tryParse(parsed["data"]['volume24h']?.toString() ?? "0") ?? 0)
                  //     .toStringAsFixed(2);
                  //
                  // list[index].exchange =
                  // ((double.tryParse(parsed["data"]['price24hPcnt']?.toString() ?? "0") ??
                  // 0) *
                  // 100)
                  //     .toStringAsFixed(2);
                  // }

                  if (snapshot.data != null) {
                    // final Map<String, dynamic> parsed =
                    //     snapshot.data as Map<String, dynamic>;
                    // int index = -1;
                    // final elementSymbol = parsed["data"]['symbol']
                    //     ?.toString();
                    // index = mController.tradePairList.indexWhere(
                    //   (user) =>
                    //       "${user.coinOne}${user.coinTwo}" == elementSymbol,
                    // );
                    final parsed = jsonDecode(snapshot.data);
                    final symbol = parsed["data"]['symbol']?.toString();
                    print("Symbol in all trade pairs $parsed");
                    final index = controller.favTradePairList.indexWhere(
                          (e) => "${e.coinOne}${e.coinTwo}" == symbol,
                    );

                    if (index != -1) {
                      lastPrice = parsed["data"]['lastPrice'].toString();
                      volume24 = parsed["data"]['volume24h'].toString();

                      controller
                          .favTradePairList[index]
                          .livePrice = double.parse(
                        (lastPrice.toString().isNotEmpty &&
                            lastPrice.toString().toLowerCase() != "null")
                            ? lastPrice.toString()
                            : "0.0",
                      ).toStringAsFixed(2);
                      controller
                          .favTradePairList[index]
                          .volume24h = double.parse(
                        (volume24.toString().isNotEmpty &&
                            volume24.toString().toLowerCase() != "null")
                            ? volume24.toString()
                            : "0.0",
                      ).toStringAsFixed(2);

                      controller.favTradePairList[index].change24hPercentage =
                          (double.parse(
                            (parsed["data"]['price24hPcnt']
                                .toString()
                                .isNotEmpty &&
                                parsed["data"]['price24hPcnt']
                                    .toString()
                                    .toLowerCase() !=
                                    "null")
                                ? parsed["data"]['price24hPcnt']
                                .toString()
                                : "0.0",
                          ) *
                              100)
                              .toStringAsFixed(2);
                    } else {}
                  }

                  return InkWell(
                    onTap: () {
                      for (var element in controller.favTradePairList) {
                        if ("${element.coinOne}${element.coinTwo}" ==
                            item.coinOne.toString() +
                                item.coinTwo.toString()) {
                          controller.selectedTradePair(
                            element,
                            context,
                            "update",
                          );
                          break;
                        }
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 0.sp,
                        top: 12.sp,
                        bottom: 15.sp,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                      controller.removeFav(context: context, id: item.id.toString(), item: item);
                                  },
                                  child: AnimatedRotation(
                                    turns: item.isFavorite == true ? 1 : 0,
                                    curve: Curves.decelerate,
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      Icons.star,
                                      color: item.isFavorite == true
                                          ? ThemePrimaryColor.getPrimaryColor(context)
                                          : ThemeTextOneColor.getTextOneColor(context),
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 10.sp),

                          // PAIR + VOLUME
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  label: "${item.coinOne}/${item.coinTwo}",
                                  fontSize: 14.sp,
                                  labelFontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                          // PRICE + USD
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  label: item.livePrice.toString(),
                                  fontSize: 14.sp,
                                  labelFontWeight: FontWeight.bold,
                                ),
                                SizedBox(height: 8.sp),
                              ],
                            ),
                          ),
                          SizedBox(width: 22.sp),

                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  label: item.volume24h.toString(),
                                  fontSize: 14.sp,
                                  labelFontWeight: FontWeight.bold,
                                ),
                                SizedBox(height: 8.sp),
                              ],
                            ),
                          ),
                          SizedBox(width: 22.sp),

                          // 24H CHANGE BOX
                          Container(
                            width: 15.w,
                            padding: EdgeInsets.all(8.sp),
                            decoration: BoxDecoration(
                              color:
                              item.change24hPercentage
                                  .toString()
                                  .contains("-")
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(8.sp),
                            ),
                            child: Center(
                              child: CustomText(
                                label: item.change24hPercentage.toString(),
                                fontSize: 13.sp,
                                labelFontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  getAllList(SpotTradeController controller, MarketController mController) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 15.sp),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
            CustomText(
              label: AppLocalizations.of(context)!.tradingPair,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
            CustomText(
              label: AppLocalizations.of(context)!.lastPrice,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
            CustomText(
              label: AppLocalizations.of(context)!.twentyFourVolume,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
            CustomText(
              label: AppLocalizations.of(context)!.twentyFourChange,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
          ],),
          SizedBox(height: 15.sp),
          controller.tradePairList.isEmpty
              ? Center(
                  child: CustomText(
                    label: AppLocalizations.of(context)!.noDataAvailable,
                    fontSize: 15.sp,
                    fontColour: ThemeTextOneColor.getTextOneColor(context),
                  ),
                )
              : ListView.builder(
                  itemCount: controller.tradePairList.length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder: (_, index) {
                    final item = controller.tradePairList[index];
                    // final realIndex = controller.hotSpotList
                    //     .indexOf(item);

                    return StreamBuilder(
                      stream: mController.spotStreamController.stream,
                      builder: (context, snapshot) {
                        String _ = '';
                        String _ = '';
                        bool _ = false;
                        String lastPrice = '';
                        String _ = '';
                        String volume24 = '';

                        print("Snapshot data in all trade pairs: ${snapshot.data}");
                        // final parsed = jsonDecode(data);
                        // final symbol = parsed["data"]['symbol']?.toString();
                        //
                        // final index = list.indexWhere((e) => "${e.coinOne}${e.coinTwo}" == symbol);
                        //
                        // if (index == -1) return;
                        //
                        // list[index].last =
                        // (double.tryParse(parsed["data"]['lastPrice']?.toString() ?? "0") ?? 0)
                        //     .toStringAsFixed(2);
                        //
                        // list[index].volume =
                        // (double.tryParse(parsed["data"]['volume24h']?.toString() ?? "0") ?? 0)
                        //     .toStringAsFixed(2);
                        //
                        // list[index].exchange =
                        // ((double.tryParse(parsed["data"]['price24hPcnt']?.toString() ?? "0") ??
                        // 0) *
                        // 100)
                        //     .toStringAsFixed(2);
                        // }

                        if (snapshot.data != null) {
                          // final Map<String, dynamic> parsed =
                          //     snapshot.data as Map<String, dynamic>;
                          // int index = -1;
                          // final elementSymbol = parsed["data"]['symbol']
                          //     ?.toString();
                          // index = mController.tradePairList.indexWhere(
                          //   (user) =>
                          //       "${user.coinOne}${user.coinTwo}" == elementSymbol,
                          // );
                          final parsed = jsonDecode(snapshot.data);
                          final symbol = parsed["data"]['symbol']?.toString();
                          print("Symbol in all trade pairs $parsed");
                          final index = controller.tradePairList.indexWhere(
                            (e) => "${e.coinOne}${e.coinTwo}" == symbol,
                          );

                          if (index != -1) {
                            lastPrice = parsed["data"]['lastPrice'].toString();
                            volume24 = parsed["data"]['volume24h'].toString();

                            controller
                                .tradePairList[index]
                                .livePrice = double.parse(
                              (lastPrice.toString().isNotEmpty &&
                                      lastPrice.toString().toLowerCase() != "null")
                                  ? lastPrice.toString()
                                  : "0.0",
                            ).toStringAsFixed(2);
                            controller
                                .tradePairList[index]
                                .volume24h = double.parse(
                              (volume24.toString().isNotEmpty &&
                                      volume24.toString().toLowerCase() != "null")
                                  ? volume24.toString()
                                  : "0.0",
                            ).toStringAsFixed(2);

                            controller.tradePairList[index].change24hPercentage =
                                (double.parse(
                                          (parsed["data"]['price24hPcnt']
                                                      .toString()
                                                      .isNotEmpty &&
                                                  parsed["data"]['price24hPcnt']
                                                          .toString()
                                                          .toLowerCase() !=
                                                      "null")
                                              ? parsed["data"]['price24hPcnt']
                                                    .toString()
                                              : "0.0",
                                        ) *
                                        100)
                                    .toStringAsFixed(2);
                          } else {}
                        }

                        return InkWell(
                          onTap: () {
                            for (var element in controller.tradePairList) {
                              if ("${element.coinOne}${element.coinTwo}" ==
                                  item.coinOne.toString() +
                                      item.coinTwo.toString()) {
                                controller.selectedTradePair(
                                  element,
                                  context,
                                  "update",
                                );
                                break;
                              }
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 0.sp,
                              top: 12.sp,
                              bottom: 15.sp,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if(item.isFavorite == true){
                                            controller.removeFav(context: context, id: item.id.toString(), item: item);
                                          }else{
                                            controller.addFav(context: context, id: item.id.toString(), item: item);
                                          }

                                        },
                                        child: AnimatedRotation(
                                          turns: item.isFavorite == true ? 1 : 0,
                                          curve: Curves.decelerate,
                                          duration: const Duration(milliseconds: 300),
                                          child: Icon(
                                            Icons.star,
                                            color: item.isFavorite == true
                                                ? Theme.of(context).colorScheme.primary
                                                : ThemeTextOneColor.getTextOneColor(context),
                                            size: 20.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10.sp),

                                // PAIR + VOLUME
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        label: "${item.coinOne}/${item.coinTwo}",
                                        fontSize: 14.sp,
                                        labelFontWeight: FontWeight.bold,
                                      ),
                                    ],
                                  ),
                                ),
                                // PRICE + USD
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        label: item.livePrice.toString(),
                                        fontSize: 14.sp,
                                        labelFontWeight: FontWeight.bold,
                                      ),
                                      SizedBox(height: 8.sp),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 22.sp),

                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        label: item.volume24h.toString(),
                                        fontSize: 14.sp,
                                        labelFontWeight: FontWeight.bold,
                                      ),
                                      SizedBox(height: 8.sp),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 22.sp),

                                // 24H CHANGE BOX
                                Container(
                                  width: 15.w,
                                  padding: EdgeInsets.all(8.sp),
                                  decoration: BoxDecoration(
                                    color:
                                        item.change24hPercentage
                                            .toString()
                                            .contains("-")
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.tertiary,
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  child: Center(
                                    child: CustomText(
                                      label: item.change24hPercentage.toString(),
                                      fontSize: 13.sp,
                                      labelFontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  getUSDTList(SpotTradeController controller, MarketController mController) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 15.sp),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
            CustomText(
              label: AppLocalizations.of(context)!.tradingPair,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
            CustomText(
              label: AppLocalizations.of(context)!.lastPrice,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
            CustomText(
              label: AppLocalizations.of(context)!.twentyFourVolume,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
            CustomText(
              label: AppLocalizations.of(context)!.twentyFourChange,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
          ],),
          SizedBox(height: 15.sp,),
          controller.usdtTradePairList.isEmpty
              ? Center(
                  child: CustomText(
                    label: AppLocalizations.of(context)!.noDataAvailable,
                    fontSize: 15.sp,
                    fontColour: ThemeTextOneColor.getTextOneColor(context),
                  ),
                )
              : ListView.builder(
                  itemCount: controller.usdtTradePairList.length,
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    final item = controller.usdtTradePairList[index];
                    return StreamBuilder(
                      stream: mController.spotStreamController.stream,
                      builder: (context, snapshot) {
                        // if (snapshot.hasData) {
                        String _ = '';
                        String _ = '';
                        bool _ = false;
                        String lastPrice = '';
                        String _ = '';
                        String volume24 = '';
                        if (snapshot.data != null) {
                          // final Map<String, dynamic> parsed =
                          //     snapshot.data as Map<String, dynamic>;
                          // int index = -1;

                          // final elementSymbol = parsed["data"]['symbol']
                          //     ?.toString();
                          // index = controller.usdtTradePairList.indexWhere(
                          //   (user) =>
                          //       "${user.coinOne}${user.coinTwo}" == elementSymbol,
                          // );

                          final parsed = jsonDecode(snapshot.data);
                          final symbol = parsed["data"]['symbol']?.toString();

                          final index = controller.usdtTradePairList.indexWhere(
                                (e) => "${e.coinOne}${e.coinTwo}" == symbol,
                          );
                          if (index != -1) {
                            lastPrice = parsed["data"]['lastPrice'].toString();
                            volume24 = parsed["data"]['volume24h'].toString();

                            controller
                                .usdtTradePairList[index]
                                .livePrice = double.parse(
                              (lastPrice.toString().isNotEmpty &&
                                      lastPrice.toString().toLowerCase() != "null")
                                  ? lastPrice.toString()
                                  : "0.0",
                            ).toStringAsFixed(2);
                            controller
                                .usdtTradePairList[index]
                                .volume24h = double.parse(
                              (volume24.toString().isNotEmpty &&
                                      volume24.toString().toLowerCase() != "null")
                                  ? volume24.toString()
                                  : "0.0",
                            ).toStringAsFixed(2);

                           controller
                                    .usdtTradePairList[index]
                                    .change24hPercentage =
                                (double.parse(
                                          (parsed["data"]['price24hPcnt']
                                                      .toString()
                                                      .isNotEmpty &&
                                                  parsed["data"]['price24hPcnt']
                                                          .toString()
                                                          .toLowerCase() !=
                                                      "null")
                                              ? parsed["data"]['price24hPcnt']
                                                    .toString()
                                              : "0.0",
                                        ) *
                                        100)
                                    .toStringAsFixed(2);
                          } else {}
                        }

                        return InkWell(
                          onTap: () {
                            for (var element in controller.usdtTradePairList) {
                              if ("${element.coinOne}${element.coinTwo}" ==
                                  item.coinOne.toString() +
                                      item.coinTwo.toString()) {
                                controller.selectedTradePair(
                                  element,
                                  context,
                                  "update",
                                );
                                break;
                              }
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 0.sp,
                              top: 12.sp,
                              bottom: 15.sp,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [

                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if(item.isFavorite == true){
                                            controller.removeFav(context: context, id: item.id.toString(), item: item);
                                          }else{
                                            controller.addFav(context: context, id: item.id.toString(), item: item);
                                          }

                                        },
                                        child: AnimatedRotation(
                                          turns: item.isFavorite == true ? 1 : 0,
                                          curve: Curves.decelerate,
                                          duration: const Duration(milliseconds: 300),
                                          child: Icon(
                                            Icons.star,
                                            color: item.isFavorite == true
                                                ? Theme.of(context).colorScheme.primary
                                                : ThemeTextOneColor.getTextOneColor(context),
                                            size: 20.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: 10.sp),

                                // PAIR + VOLUME
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        label: "${item.coinOne}/${item.coinTwo}",
                                        fontSize: 14.sp,
                                        labelFontWeight: FontWeight.bold,
                                      ),
                                      SizedBox(height: 8.sp),

                                    ],
                                  ),
                                ),
                                // PRICE + USD
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        label: item.livePrice.toString(),
                                        fontSize: 14.sp,
                                        labelFontWeight: FontWeight.bold,
                                      ),
                                      SizedBox(height: 8.sp),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 22.sp),

                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        label: item.volume24h.toString(),
                                        fontSize: 14.sp,
                                        labelFontWeight: FontWeight.bold,
                                      ),
                                      SizedBox(height: 8.sp),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 22.sp),

                                // 24H CHANGE BOX
                                Container(
                                  width: 15.w,
                                  padding: EdgeInsets.all(8.sp),
                                  decoration: BoxDecoration(
                                    color:
                                        item.change24hPercentage
                                            .toString()
                                            .contains("-")
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.tertiary,
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  child: Center(
                                    child: CustomText(
                                      label: item.change24hPercentage.toString(),
                                      fontSize: 13.sp,
                                      labelFontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  getLINKList(SpotTradeController controller, MarketController mController) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 15.sp),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
            CustomText(
              label: AppLocalizations.of(context)!.tradingPair,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
            CustomText(
              label: AppLocalizations.of(context)!.lastPrice,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
            CustomText(
              label: AppLocalizations.of(context)!.twentyFourVolume,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
            CustomText(
              label: AppLocalizations.of(context)!.twentyFourChange,
              fontSize: 15.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
          ],),
          SizedBox(height: 15.sp,),
          controller.linkTradePairList.isEmpty
              ? Center(
                  child: CustomText(
                    label: AppLocalizations.of(context)!.noDataAvailable,
                    fontSize: 15.sp,
                    fontColour: ThemeTextOneColor.getTextOneColor(context),
                  ),
                )
              : ListView.builder(
                  itemCount: controller.linkTradePairList.length,
                  shrinkWrap: true,
                  itemBuilder: (_, index) {
                    final item = controller.linkTradePairList[index];
                    // final realIndex = controller.hotSpotList
                    //     .indexOf(item);

                    return StreamBuilder(
                      stream: mController.spotStreamController.stream,
                      builder: (context, snapshot) {
                        // if (snapshot.hasData) {
                        String _ = '';
                        String _ = '';
                        bool _ = false;
                        String lastPrice = '';
                        String _ = '';
                        String volume24 = '';
                        // if (!snapshot.hasData) {
                        //   return const SizedBox();
                        // }

                        if (snapshot.data != null) {
                          // final Map<String, dynamic> parsed =
                          //     snapshot.data as Map<String, dynamic>;
                          //
                          // final _ = parsed['data'];
                          // if (data == null) return const SizedBox();
                          // int index = -1;
                          //
                          // final elementSymbol = parsed["data"]['symbol']
                          //     ?.toString();
                          // index = controller.linkTradePairList.indexWhere(
                          //   (user) =>
                          //       "${user.coinOne}${user.coinTwo}" == elementSymbol,
                          // );
                          final parsed = jsonDecode(snapshot.data);
                          final symbol = parsed["data"]['symbol']?.toString();

                          final index = controller.linkTradePairList.indexWhere(
                                (e) => "${e.coinOne}${e.coinTwo}" == symbol,
                          );
                          if (index != -1) {
                            lastPrice = parsed["data"]['lastPrice'].toString();
                            volume24 = parsed["data"]['volume24h'].toString();

                            controller
                                .linkTradePairList[index]
                                .livePrice = double.parse(
                              (lastPrice.toString().isNotEmpty &&
                                      lastPrice.toString().toLowerCase() != "null")
                                  ? lastPrice.toString()
                                  : "0.0",
                            ).toStringAsFixed(2);
                            controller
                                .linkTradePairList[index]
                                .volume24h = double.parse(
                              (volume24.toString().isNotEmpty &&
                                      volume24.toString().toLowerCase() != "null")
                                  ? volume24.toString()
                                  : "0.0",
                            ).toStringAsFixed(2);

                            controller
                                    .linkTradePairList[index]
                                    .change24hPercentage =
                                (double.parse(
                                          (parsed["data"]['price24hPcnt']
                                                      .toString()
                                                      .isNotEmpty &&
                                                  parsed["data"]['price24hPcnt']
                                                          .toString()
                                                          .toLowerCase() !=
                                                      "null")
                                              ? parsed["data"]['price24hPcnt']
                                                    .toString()
                                              : "0.0",
                                        ) *
                                        100)
                                    .toStringAsFixed(2);
                          } else {}
                        }

                        return InkWell(
                          onTap: () {
                            for (var element in controller.linkTradePairList) {
                              if ("${element.coinOne}${element.coinTwo}" ==
                                  item.coinOne.toString() +
                                      item.coinTwo.toString()) {
                                controller.selectedTradePair(
                                  element,
                                  context,
                                  "update",
                                );
                                break;
                              }
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 0.sp,
                              top: 12.sp,
                              bottom: 15.sp,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // FAVORITE ICON
                                // GestureDetector(
                                //   // onTap: () => controller
                                //   //     .toggleFavorite(realIndex),
                                //   child: Icon(
                                //     item.isFavorite
                                //         ? Icons.star
                                //         : Icons.star_border,
                                //     size: 18.sp,
                                //     color: item.isFavorite
                                //         ? ThemeInversePrimaryColor.getInversePrimaryColor(
                                //       context,
                                //     )
                                //         : ThemeTextOneColor.getTextOneColor(
                                //       context,
                                //     ),
                                //   ),
                                // ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if(item.isFavorite == true){
                                            controller.removeFav(context: context, id: item.id.toString(), item: item);
                                          }else{
                                            controller.addFav(context: context, id: item.id.toString(), item: item);
                                          }

                                        },
                                        child: AnimatedRotation(
                                          turns: item.isFavorite == true ? 1 : 0,
                                          curve: Curves.decelerate,
                                          duration: const Duration(milliseconds: 300),
                                          child: Icon(
                                            Icons.star,
                                            color: item.isFavorite == true
                                                ? Theme.of(context).colorScheme.primary
                                                : ThemeTextOneColor.getTextOneColor(context),
                                            size: 20.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10.sp),

                                // PAIR + VOLUME
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        label: "${item.coinOne}/${item.coinTwo}",
                                        fontSize: 14.sp,
                                        labelFontWeight: FontWeight.bold,
                                      ),
                                      SizedBox(height: 8.sp),
                                    ],
                                  ),
                                ),
                                // PRICE + USD
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        label: item.livePrice.toString(),
                                        fontSize: 14.sp,
                                        labelFontWeight: FontWeight.bold,
                                      ),
                                      SizedBox(height: 8.sp),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 22.sp),

                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        label: item.volume24h.toString(),
                                        fontSize: 14.sp,
                                        labelFontWeight: FontWeight.bold,
                                      ),
                                      SizedBox(height: 8.sp),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 22.sp),

                                // 24H CHANGE BOX
                                Container(
                                  width: 15.w,
                                  padding: EdgeInsets.all(8.sp),
                                  decoration: BoxDecoration(
                                    color:
                                        item.change24hPercentage
                                            .toString()
                                            .contains("-")
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.tertiary,
                                    borderRadius: BorderRadius.circular(8.sp),
                                  ),
                                  child: Center(
                                    child: CustomText(
                                      label: item.change24hPercentage.toString(),
                                      fontSize: 13.sp,
                                      labelFontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }
}
