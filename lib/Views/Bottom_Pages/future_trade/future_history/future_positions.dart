import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../../../../Utility/Basics/custom_loader.dart';
import '../../../../Utility/Colors/custom_theme_change.dart';
import '../../../../Utility/custom_alertbox.dart';
import '../../../../Utility/custom_button.dart';
import '../../../../Utility/custom_list_items.dart';
import '../../../../Utility/custom_no_records.dart';
import '../../../../Utility/custom_text.dart';
import '../../../../Utility/custom_text_form_field.dart';
import '../future_trade/formatter.dart';
import '../future_trade/future_trade_controller.dart';

class FuturePositions extends StatefulWidget {
  const FuturePositions({super.key});

  @override
  State<FuturePositions> createState() => _FuturePositionsState();
}

class _FuturePositionsState extends State<FuturePositions> {
  FutureTradeController controller = FutureTradeController();
  @override
  Widget build(BuildContext context) {
    return Consumer<FutureTradeController>(
      builder: (context, value, child) {
        controller = value;
        return futuresPositionsList(context, controller);
      },
    );
  }

  futuresPositionsList(BuildContext context, FutureTradeController controller) {
    return Container(
      child: controller.futuresPositionsList.isEmpty
          ? customNoRecordsFound(context)
          : ListView.builder(
              itemCount: controller.futuresPositionsList.length,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 5.h,
              ),
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int i) {
                var list = controller.futuresPositionsList[i];
                controller.getBalances();
                return StreamBuilder(
                  stream: controller.priceStreamController?.stream,
                  builder: (context, snap) {
                    if (snap.hasData) {
                      try {
                        final data = snap.data as Map<String, dynamic>;

                        if (data.isNotEmpty) {
                          final pair = list.contract.toString();

                          if (data['data'] != null) {
                            if (data['data']['symbol'].toString() == pair) {
                              if (data['data']['lastPrice'] != null) {
                                list.lastPrice = double.parse(
                                  data['data']['lastPrice'].toString(),
                                );

                                controller.getBalances();
                              }

                              if (data['data']['markPrice'] != null) {
                                list.markPrice = double.parse(
                                  data['data']['markPrice'].toString(),
                                );

                                controller.getBalances();
                              }
                            }
                          }
                        }
                      } catch (e) {
                        //
                      }
                    } else {}

                    return Container(
                      margin: EdgeInsets.only(bottom: 15.sp),
                      padding: EdgeInsets.only(
                        left: 13.sp,
                        right: 13.sp,
                        top: 13.sp,
                        bottom: 10.sp,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeTextFormFillColor.getTextFormFillColor(
                          context,
                        ),
                        borderRadius: BorderRadius.circular(15.sp),
                        border: Border.all(
                          color: ThemeOutLineColor.getOutLineColor(context),
                          width: 5.sp,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row(
                            context,
                            AppLocalizations.of(context)!.contracts,
                            list.contract.toString(),
                          ),
                          SizedBox(height: 12.sp),
                          Divider(
                            color: ThemeOutLineColor.getOutLineColor(context),
                            thickness: 6.sp,
                            height: 5.sp,
                          ),
                          _row(
                            context,
                            "",
                            "${list.marginType.toString().toUpperCase()} ${list.leverage.toString()}X",
                            valueColor: (list.side ?? "").toLowerCase() == "buy"
                                ? Theme.of(context).colorScheme.tertiary
                                : Theme.of(context).colorScheme.error,
                          ),
                          _row(
                            context,
                            AppLocalizations.of(context)!.qty,
                            "${list.qty.toString()} ${list.coinOne}",
                          ),
                          _row(
                            context,
                            AppLocalizations.of(context)!.valueText,
                            "${list.value.toString()} ${list.coinTwo}",
                          ),
                          _row(
                            context,
                            AppLocalizations.of(context)!.entryPrice,
                            "${list.entryPrice}",
                          ),
                          _row(
                            context,
                            AppLocalizations.of(context)!.markPrice,
                            "${controller.markPrice}",
                          ),
                          _row(
                            context,
                            AppLocalizations.of(context)!.liqPrice,
                            "${list.liqPrice}",
                          ),
                          _row(context, "IM", "${list.positionIM}"),
                          _row(context, "MM", "${list.positionMM}"),
                          _row(
                            context,
                            AppLocalizations.of(context)!.unrealizedPnl,
                            "${list.unrealPnL.toStringAsFixed(4)} ${list.coinTwo} (${list.unrealPnLPerc.toStringAsFixed(2)}%)",
                            valueColor: list.unrealPnL.toString().contains("-")
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.tertiary,
                          ),
                          _row(
                            context,
                            AppLocalizations.of(context)!.realizedPNL,
                            "${list.realPnL.toStringAsFixed(4)} ${list.coinTwo}",
                          ),
                          _row(
                            context,
                            AppLocalizations.of(context)!.tpsl,
                            "${list.takeProfit != 0 ? list.takeProfit : "--"} / ${list.stopLoss != 0 ? list.stopLoss : "--"}",
                          ),
                          SizedBox(height: 12.sp),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CustomText(
                                label: AppLocalizations.of(context)!.action,
                                labelFontWeight: FontWeight.w400,
                                fontSize: 15.sp,
                                // fontColor: AppColors.secondaryText,
                              ),
                              SizedBox(height: 10.sp),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomButton(
                                    width: 25.w,
                                    onTap: () {
                                      updateTPSL(
                                        context: context,
                                        controller: controller,
                                        side: list.side
                                            .toString()
                                            .toUpperCase(),
                                        coinOne: list.coinOne.toString(),
                                        coinTwo: list.coinTwo.toString(),
                                        tradePair: list.contract.toString(),
                                        takeProfit: list.takeProfit.toString(),
                                        stopLoss: list.stopLoss.toString(),
                                        orderPrice: list.entryPrice.toString(),
                                        qty: list.qty.toString(),
                                        isAdd:
                                            list.takeProfit == 0.0 &&
                                                list.stopLoss == 0.0
                                            ? true
                                            : false,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(20.sp),
                                    label:
                                        (double.parse(
                                                  list.takeProfit.toString(),
                                                ) ==
                                                0 &&
                                            double.parse(
                                                  list.stopLoss.toString(),
                                                ) ==
                                                0)
                                        ? AppLocalizations.of(context)!.addTpSl
                                        : AppLocalizations.of(
                                            context,
                                          )!.editTpSl,
                                  ),
                                  CustomButton(
                                    width: 25.w,
                                    onTap: () {
                                      closeMarketPositionAlert(
                                        context: context,
                                        controller: controller,
                                        positionId: list.id.toString(),
                                        tradePairId: list.pairId.toString(),
                                        coinOne: list.coinOne.toString(),
                                        amount: list.qty.toString(),
                                        side: list.side.toString(),
                                      );
                                    },
                                    label: AppLocalizations.of(context)!.market,

                                    borderRadius: BorderRadius.circular(20.sp),
                                  ),
                                  CustomButton(
                                    width: 25.w,
                                    onTap: () {
                                      closeLimitPositionAlert(
                                        context: context,
                                        controller: controller,
                                        positionId: list.id.toString(),
                                        tradePairId: list.pairId.toString(),
                                        coinOne: list.coinOne.toString(),
                                        coinTwo: list.coinTwo.toString(),
                                        price: list.markPrice.toString(),
                                        amount: list.qty.toString(),
                                        side: list.side.toString(),
                                      );
                                    },
                                    label: AppLocalizations.of(context)!.limit,

                                    borderRadius: BorderRadius.circular(20.sp),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  updateTPSL({
    required BuildContext context,
    required FutureTradeController controller,
    required String takeProfit,
    required String stopLoss,
    required String orderPrice,
    required String qty,
    required String coinOne,
    required String coinTwo,
    required String tradePair,
    required String side,
    required bool isAdd,
  }) {
    if (!isAdd) {
      controller.takeProfitController.text = takeProfit;
      controller.stopLossController.text = stopLoss;
    }
    return customAlert(
      context: context,
      title: isAdd
          ? AppLocalizations.of(context)!.addTpSl
          : AppLocalizations.of(context)!.editTpSl,
      onDismiss: () {
        controller.takeProfitController.clear();
        controller.stopLossController.clear();
      },
      widget: Consumer<FutureTradeController>(
        builder: (context, value, child) {
          controller = value;

          return Form(
            key: controller.addEditTPSLFormKey,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                StreamBuilder(
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
                              }
                            }
                          }
                        } catch (e) {
                          // Exception handling
                        }
                      } else {}
                    }

                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(15.sp),
                          child: Column(
                            children: [
                              customLinearListItems(
                                context: context,
                                key: AppLocalizations.of(context)!.orderPrice,
                                value: "$orderPrice $coinTwo",
                              ),
                              SizedBox(height: 12.sp),
                              customLinearListItems(
                                context: context,
                                key: AppLocalizations.of(context)!.qty,
                                value: "$qty $coinOne",
                              ),
                              SizedBox(height: 12.sp),
                              customLinearListItems(
                                context: context,
                                key: AppLocalizations.of(
                                  context,
                                )!.lastTradedPrice,
                                value:
                                    "${controller.lastPrice.toString()} $coinTwo",
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18.sp),
                        CustomTextFieldWidget(
                          line: 1,
                          controller: value.takeProfitController,
                          label: AppLocalizations.of(context)!.takeProfit,
                          hintText: "",
                          readOnly: false,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(right: 10.sp, top: 5.sp),
                            child: GestureDetector(
                              onTap: () {
                                value.setLivePriceController("tp");
                              },
                              child: CustomText(
                                label: AppLocalizations.of(context)!.last,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            AppFormatters(editingValidator: CryptoValidator()),
                          ],
                          onValidate: (val) {
                            if (val.toString().isEmpty &&
                                controller.stopLossController.text.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.takeProfitRequired;
                            } else if (controller.buySellTabIndex == 0 &&
                                double.parse(val.toString()) <=
                                    double.parse(orderPrice.toString())) {
                              return AppLocalizations.of(
                                context,
                              )!.takeProfitShouldBeGreaterThanLivePrice;
                            } else if (controller.buySellTabIndex == 1 &&
                                double.parse(val.toString()) >=
                                    double.parse(orderPrice.toString())) {
                              return AppLocalizations.of(
                                context,
                              )!.takeProfitShouldBeLessThanLivePrice;
                            }
                            // else if (double.parse(val.toString()) <
                            //     double.parse(controller.lastPrice.toString())) {
                            //   return "Take Profit must be greater than last traded price";
                            // }
                            return null;
                          },
                        ),
                        SizedBox(height: 18.sp),
                        CustomTextFieldWidget(
                          line: 1,
                          controller: controller.stopLossController,
                          label: AppLocalizations.of(context)!.stopLoss,
                          hintText: "",
                          readOnly: false,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            AppFormatters(editingValidator: CryptoValidator()),
                          ],
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(right: 10.sp, top: 5.sp),
                            child: GestureDetector(
                              onTap: () {
                                value.setLivePriceController("sl");
                              },
                              child: CustomText(
                                label: AppLocalizations.of(context)!.last,
                              ),
                            ),
                          ),
                          onValidate: (val) {
                            if (val.toString().isEmpty &&
                                controller.stopLossController.text.isEmpty) {
                              return AppLocalizations.of(
                                context,
                              )!.stopLossRequired;
                            } else if (val!.isNotEmpty) {
                              double slValue = double.parse(val.toString());
                              double entryPrice = controller.lastPrice!;

                              if (controller.buySellTabIndex == 0 &&
                                  slValue >= entryPrice) {
                                return AppLocalizations.of(
                                  context,
                                )!.stopLossShouldBeLessThanLivePrice;
                              } else if (controller.buySellTabIndex == 1 &&
                                  slValue <= entryPrice) {
                                return AppLocalizations.of(
                                  context,
                                )!.stopLossShouldBeGreaterThanLivePrice;
                              }
                            }
                            // else if (double.parse(val.toString()) >
                            //     double.parse(controller.lastPrice.toString())) {
                            //   return "Stop Loss must be less than last traded price";
                            // }

                            return null;
                          },
                        ),
                        SizedBox(height: 20.sp),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                label: AppLocalizations.of(context)!.cancel,
                                // color: AppColors.secondaryButton,
                                onTap: () {
                                  controller.takeProfitController.clear();
                                  controller.stopLossController.clear();
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            SizedBox(width: 15.sp),
                            Expanded(
                              child: CustomButton(
                                label: AppLocalizations.of(context)!.confirm,
                                onTap: () {
                                  if (controller.takeProfitController.text !=
                                          takeProfit &&
                                      controller.stopLossController.text !=
                                          stopLoss) {
                                    if (controller
                                        .addEditTPSLFormKey
                                        .currentState!
                                        .validate()) {
                                      controller
                                          .doUpdateTPSL(
                                            context: context,
                                            tradePair: tradePair,
                                            side: side,
                                            takeProfit: controller
                                                .takeProfitController
                                                .text,
                                            stopLoss: controller
                                                .stopLossController
                                                .text,
                                          )
                                          .whenComplete(() {
                                            if (controller.isSuccess) {
                                              Navigator.pop(context);
                                            }
                                          });
                                    }
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                CustomLoader(isLoading: controller.isLoading),
              ],
            ),
          );
        },
      ),
    );
  }

  closeLimitPositionAlert({
    required BuildContext context,
    required FutureTradeController controller,
    required String tradePairId,
    required String positionId,
    required String coinOne,
    required String coinTwo,
    required String price,
    required String amount,
    required String side,
  }) {
    controller.priceController.text = price;
    controller.amountController.text = amount;
    return customAlert(
      context: context,
      title: AppLocalizations.of(context)!.closeByLimit,
      onDismiss: () {
        controller.priceController.clear();
        controller.amountController.clear();
      },
      widget: Consumer<FutureTradeController>(
        builder: (context, value, child) {
          controller = value;

          return Form(
            key: controller.closeLimitFormKey,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Column(
                  children: [
                    CustomText(
                      label:
                          '${AppLocalizations.of(context)!.contractsWillClosedAt} ${controller.priceController.text} $coinTwo',
                      fontSize: 15.sp,
                      labelFontWeight: FontWeight.w500,
                      // fontColor: AppColors.secondaryText,
                    ),
                    SizedBox(height: 18.sp),
                    CustomTextFieldWidget(
                      line: 1,
                      controller: controller.priceController,
                      label:
                          "${AppLocalizations.of(context)!.closePriceBy} $coinTwo",
                      hintText: "",
                      readOnly: false,
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
                        if (val.toString().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.closePriceRequired;
                        } else if (double.parse(val.toString()) <= 0) {
                          return AppLocalizations.of(
                            context,
                          )!.closePriceShouldNotBeZero;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 15.sp),
                    CustomTextFieldWidget(
                      line: 1,
                      controller: controller.amountController,
                      label:
                          "${AppLocalizations.of(context)!.closeQtyBy} $coinOne",
                      hintText: "",
                      readOnly: false,
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
                        if (val.toString().isEmpty) {
                          return AppLocalizations.of(context)!.quantityRequired;
                        } else if (double.parse(val.toString()) <= 0) {
                          return AppLocalizations.of(
                            context,
                          )!.qtyShouldNotBeZero;
                        } else if (double.parse(val.toString()) >
                            double.parse(amount)) {
                          return "${AppLocalizations.of(context)!.closeQuantityCannotExceed} $amount $coinOne";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.sp),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: AppLocalizations.of(context)!.cancel,
                            // color: AppColors.secondaryButton,
                            onTap: () {
                              controller.priceController.clear();
                              controller.amountController.clear();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(width: 15.sp),
                        Expanded(
                          child: CustomButton(
                            label: AppLocalizations.of(context)!.confirm,
                            onTap: () {
                              if (controller.closeLimitFormKey.currentState!
                                  .validate()) {
                                controller
                                    .doCloseLimitPosition(
                                      context: context,
                                      side: side,
                                      tradePairId: tradePairId,
                                      positionId: positionId,
                                      price: controller.priceController.text,
                                      amount: controller.amountController.text,
                                    )
                                    .whenComplete(() {
                                      Navigator.pop(context);
                                    });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                CustomLoader(isLoading: controller.isLoading),
              ],
            ),
          );
        },
      ),
    );
  }

  closeMarketPositionAlert({
    required BuildContext context,
    required FutureTradeController controller,
    required String tradePairId,
    required String positionId,
    required String coinOne,
    required String amount,
    required String side,
  }) {
    controller.amountController.text = amount;
    return customAlert(
      context: context,
      title: AppLocalizations.of(context)!.closeByMarket,
      onDismiss: () {
        controller.amountController.clear();
      },
      widget: Consumer<FutureTradeController>(
        builder: (context, value, child) {
          controller = value;

          return Form(
            key: controller.closeMarketFormKey,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Column(
                  children: [
                    CustomText(
                      label: AppLocalizations.of(
                        context,
                      )!.contractClosedAtLastTradedPrice,
                      fontSize: 15.sp,
                      labelFontWeight: FontWeight.w500,
                      // fontColor: AppColors.secondaryText,
                    ),
                    SizedBox(height: 18.sp),
                    CustomTextFieldWidget(
                      line: 1,
                      controller: controller.amountController,
                      label:
                          "${AppLocalizations.of(context)!.closeQtyBy} $coinOne",
                      hintText: "",
                      readOnly: false,
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
                        if (val.toString().isEmpty) {
                          return AppLocalizations.of(context)!.qtyRequired;
                        } else if (double.parse(val.toString()) <= 0) {
                          return AppLocalizations.of(
                            context,
                          )!.qtyShouldNotBeZero;
                        } else if (double.parse(val.toString()) >
                            double.parse(amount)) {
                          return "${AppLocalizations.of(context)!.closeQuantityCannotExceed} $amount $coinOne";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.sp),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            label: AppLocalizations.of(context)!.cancel,
                            // color: AppColors.secondaryButton,
                            onTap: () {
                              controller.amountController.clear();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(width: 15.sp),
                        Expanded(
                          child: CustomButton(
                            label: AppLocalizations.of(context)!.confirm,
                            onTap: () {
                              if (controller.closeMarketFormKey.currentState!
                                  .validate()) {
                                controller
                                    .doCloseMarketPosition(
                                      context: context,
                                      side: side,
                                      tradePairId: tradePairId,
                                      positionId: positionId,
                                    )
                                    .whenComplete(() {
                                      Navigator.pop(context);
                                    });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                CustomLoader(isLoading: controller.isLoading),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: 10.sp,
        right: 10.sp,
        top: 13.sp,
        bottom: 10.sp,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            label: label,
            fontSize: 14.5.sp,
            labelFontWeight: FontWeight.w500,
          ),
          Expanded(
            child: CustomText(
              label: value,
              fontSize: 14.sp,
              align: TextAlign.end,
              labelFontWeight: FontWeight.bold,
              fontColour: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
