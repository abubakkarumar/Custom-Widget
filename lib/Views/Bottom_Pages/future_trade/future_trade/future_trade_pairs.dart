import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../../../../Utility/custom_button.dart';
import '../../../../Utility/custom_text.dart';
import 'custom_bottom_sheet.dart';
import 'future_trade_controller.dart';
import 'future_trade_view.dart';

class FutureTradePairs extends StatefulWidget {
  const FutureTradePairs({super.key});

  @override
  State<FutureTradePairs> createState() => _FutureTradePairsState();
}

class _FutureTradePairsState extends State<FutureTradePairs> {
  FutureTradeController controller = FutureTradeController();
  @override
  Widget build(BuildContext context) {
    return Consumer<FutureTradeController>(
      builder: (context, value, child) {
        controller = value;
        return CustomGestureButton(
          onTap: () {
            tradePairList(context, controller);
          },
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    label: controller.tradePair,
                    labelFontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                  ),
                  SizedBox(width: 12.sp),
                  // SvgPicture.asset(AppImages.dropDown)
                  Icon(Icons.arrow_drop_down_outlined),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    controller.clearChartData();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 15.sp),
                    child: Icon(Icons.candlestick_chart, size: 20.sp),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          // Tab(child: CustomText(label: AppLocalizations.of(context)!.futures)),
        ],
        functions: [
          perpetualTradePairList(context),
          // futureTradePairList(context),
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
                padding: EdgeInsets.only(bottom: 12.sp,right: 10.sp, left: 10.sp),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.network(
                          list.coinOneImage.toString(),
                          height: 20.sp,
                          width: 20.sp,
                        ),
                        SizedBox(width: 15.sp),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              label: list.tradePair.toString(),
                              labelFontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: 8.sp),
                            CustomText(
                              label:
                                  "${list.coinTwo} ${list.contractType.toString()}",
                              fontSize: 14.sp,
                              fontColour: ThemeTextColor.getTextColor(context),
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

                            SizedBox(width: 10.sp),
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

  // futureTradePairList(BuildContext context) {
  //   return ListView.builder(
  //     scrollDirection: Axis.vertical,
  //     padding: EdgeInsets.only(top: 15.sp),
  //     physics: const AlwaysScrollableScrollPhysics(),
  //     itemCount: controller.futuresTradePairsList.length,
  //     shrinkWrap: true,
  //     itemBuilder: (BuildContext context, int i) {
  //       var list = controller.futuresTradePairsList[i];
  //       return StreamBuilder(
  //           stream: controller.priceStreamController?.stream,
  //           builder: (context, snap) {
  //             if (list.liquidity == "bybit") {
  //               if (snap.hasData) {
  //                 try {
  //                   final data = snap.data as Map<String, dynamic>;
  //
  //                   if (data.isNotEmpty) {
  //                     final pair = list.tradePair.toString();
  //
  //                     if (data['data']['symbol'].toString() == pair) {
  //                       if (data['data']['lastPrice'] != null) {
  //                         list.price = data['data']['lastPrice'].toString();
  //                       }
  //                       if (data['data']['price24hPcnt'] != null) {
  //                         list.change = (double.parse(
  //                                     data['data']['price24hPcnt'].toString()) *
  //                                 100)
  //                             .toStringAsFixed(3);
  //                       }
  //                     }
  //                   }
  //                 } catch (e) {
  //                   // customFlutterToast(message: e);
  //                 }
  //               } else {}
  //             }
  //             return CustomGestureButton(
  //               onTap: () {
  //                 if (controller.tradePairId != list.id.toString())  {
  //                   var list = controller.futuresTradePairsList[i];
  //                   controller.resetData();
  //                   controller.setTradePairTabIndex(1);
  //                   controller.setTradePair(
  //                     context: context,
  //                     id: list.id.toString(),
  //                     coinOne: list.coinOne.toString(),
  //                     coinTwo: list.coinTwo.toString(),
  //                     tradePair: list.tradePair.toString(),
  //                     coinOneImage: list.coinOneImage.toString(),
  //                     price: double.parse(list.price.toString()),
  //                     change: double.parse(list.change.toString()),
  //                     volume: double.parse(list.volume.toString()),
  //                     liquidityType: list.liquidity.toString(),
  //                     markPrice: double.parse(list.markPrice.toString()),
  //                     contractType: list.contractType.toString(),
  //                   );
  //                 }
  //                 Navigator.pop(context);
  //               },
  //               child: Container(
  //                 color: Colors.transparent,
  //                 padding: EdgeInsets.only(bottom: 20.sp),
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Row(
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       children: [
  //                         Container(
  //                           padding: EdgeInsets.all(14.sp),
  //                           child: SvgPicture.network(
  //                             list.coinOneImage.toString(),
  //                             height: 22.sp,
  //                             width: 22.sp,
  //                           ),
  //                         ),
  //                         SizedBox(
  //                           width: 12.sp,
  //                         ),
  //                         Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             CustomText(
  //                               label: list.tradePair.toString(),
  //                               // fontColor: AppColors.primaryText,
  //                               fontSize: 16.sp,
  //                               labelFontWeight: FontWeight.w600,
  //                             ),
  //                             SizedBox(
  //                               height: 8.sp,
  //                             ),
  //                             CustomText(
  //                               label: list.contractType.toString(),
  //                               // fontColor: AppColors.secondaryText,
  //                               fontSize: 15.sp,
  //                               labelFontWeight: FontWeight.w400,
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.end,
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       children: [
  //                         CustomText(
  //                           label: list.price.toString(),
  //                           // fontColor: AppColors.primaryText,
  //                           fontSize: 16.sp,
  //                           labelFontWeight: FontWeight.w600,
  //                         ),
  //                         SizedBox(
  //                           height: 8.sp,
  //                         ),
  //                         Row(
  //                           mainAxisAlignment: MainAxisAlignment.end,
  //                           crossAxisAlignment: CrossAxisAlignment.center,
  //                           children: [
  //                             double.parse(list.change.toString()) < 0
  //                                 ?
  //                             Icon(Icons.arrow_drop_down_outlined, color: Theme.of(context).colorScheme.error, size: 12.sp,):
  //                             Icon(Icons.arrow_drop_up, color: Theme.of(context).colorScheme.tertiary, size: 12.sp,),
  //                             // SvgPicture.asset(
  //                             //   double.parse(list.change.toString()) < 0
  //                             //       ? AppImages.downArrowRed
  //                             //       : AppImages.upArrowGreen,
  //                             //   height: 12.sp,
  //                             // ),
  //                             SizedBox(
  //                               width: 8.sp,
  //                             ),
  //                             CustomText(
  //                               label:
  //                                   "${double.parse(list.change.toString()) < 0 ? "-" : "+"}${double.parse(list.change.toString()) < 0 ? list.change.toString().replaceAll("-", "") : list.change.toString().replaceAll("+", "")}%",
  //                               fontColour:
  //                                   double.parse(list.change.toString()) < 0
  //                                       ? Theme.of(context).colorScheme.error
  //                                       : Theme.of(context).colorScheme.tertiary,
  //                               fontSize: 14.sp,
  //                               labelFontWeight: FontWeight.w400,
  //                             ),
  //                           ],
  //                         )
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             );
  //           });
  //     },
  //   );
  // }
}
