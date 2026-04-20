import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../../../../Utility/Basics/custom_loader.dart';
import '../../../../Utility/Colors/custom_theme_change.dart';
import '../../../../Utility/custom_alertbox.dart';
import '../../../../Utility/custom_button.dart';
import '../../../../Utility/custom_no_records.dart';
import '../../../../Utility/custom_text.dart';
import '../future_trade/future_trade_controller.dart';

class FutureOpenOrders extends StatefulWidget {
  const FutureOpenOrders({super.key});

  @override
  State<FutureOpenOrders> createState() => _FutureOpenOrdersState();
}

class _FutureOpenOrdersState extends State<FutureOpenOrders> {
  FutureTradeController controller = FutureTradeController();
  @override
  Widget build(BuildContext context) {
    return Consumer<FutureTradeController>(
      builder: (context, value, child) {
        controller = value;
        return futuresOpenOrdersList(context, controller);
      },
    );
  }

  futuresOpenOrdersList(
    BuildContext context,
    FutureTradeController controller,
  ) {
    return Container(
      child: controller.futuresOpenOrdersList.isEmpty
          ? customNoRecordsFound(context)
          : ListView.builder(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 5.h,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.futuresOpenOrdersList.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int i) {
                var list = controller.futuresOpenOrdersList[i];
                return Container(
                  margin: EdgeInsets.only(bottom: 15.sp),
                  padding: EdgeInsets.only(
                    left: 13.sp,
                    right: 13.sp,
                    top: 13.sp,
                    bottom: 10.sp,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeTextFormFillColor.getTextFormFillColor(context),
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
                      _row(
                        context,
                        AppLocalizations.of(context)!.instrument,
                        list.instrument.toString(),
                      ),

                      _row(
                        context,
                        AppLocalizations.of(context)!.qty,
                        list.qty.toString(),
                      ),
                      txHashRow(
                        context,
                        AppLocalizations.of(context)!.orderID,
                        list.orderId.toString(),
                      ),
                      _row(
                        context,
                        AppLocalizations.of(context)!.orderPrice,
                        list.orderPrice.toString(),
                      ),
                      _row(
                        context,
                        AppLocalizations.of(context)!.filledOrTotal,
                        "${list.filled.toString()}/${list.remaining.toString()}",
                      ),
                      _row(
                        context,
                        AppLocalizations.of(context)!.tpsl,
                        "${list.takeProfit.toString() == "0" ? "--" : list.takeProfit.toString()}/${list.stopLoss.toString() == "0" ? "--" : list.stopLoss.toString()}",
                        valueColor:
                            list.tradeType.toString().toLowerCase() == "buy"
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.error,
                      ),
                      _row(
                        context,
                        AppLocalizations.of(context)!.tradeType,
                        list.tradeType.toString().toLowerCase() == "buy"
                            ? AppLocalizations.of(context)!.openLong
                            : AppLocalizations.of(context)!.openShort,
                      ),
                      _row(
                        context,
                        AppLocalizations.of(context)!.orderType,
                        list.orderType == "1"
                            ? AppLocalizations.of(context)!.limit
                            : AppLocalizations.of(context)!.market,
                      ),
                      _row(
                        context,
                        AppLocalizations.of(context)!.status,
                        list.status.toString() == "0"
                            ? AppLocalizations.of(context)!.active
                            : AppLocalizations.of(context)!.cancelled,
                      ),
                      _row(
                        context,
                        AppLocalizations.of(context)!.orderTime,
                        list.dateTime.toString(),
                      ),
                      SizedBox(height: 15.sp,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            label: AppLocalizations.of(context)!.action,
                            labelFontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                            // fontColor: AppColors.secondaryText,
                          ),
                          CustomButton(
                            onTap: () {
                              cancelOrderAlert(
                                context,
                                controller,
                                list.id.toString(),
                              );
                            },
                            label: AppLocalizations.of(context)!.cancel,
                            width: 25.w,
                            borderRadius: BorderRadius.circular(20.sp),
                          ),
                        ],
                      ),
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

  String shortHash(String hash, {int head = 8, int tail = 8}) {
    if (hash.length <= head + tail) return hash;
    return "${hash.substring(0, head)}......${hash.substring(hash.length - tail)}";
  }

  Widget txHashRow(BuildContext context, String label, String fullHash) {
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

          GestureDetector(
            onTap: () => copy(fullHash),
            child: Row(
              children: [
                CustomText(
                  label: shortHash(fullHash),
                  fontSize: 14.sp,
                  align: TextAlign.end,
                  labelFontWeight: FontWeight.bold,
                ),
                SizedBox(width: 10.sp),
                SvgPicture.asset(AppBasicIcons.copy),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  cancelOrderAlert(
    BuildContext context,
    FutureTradeController controller,
    String id,
  ) {
    return customAlert(
      context: context,
      title: AppLocalizations.of(context)!.cancelOrder,
      widget: Consumer<FutureTradeController>(
        builder: (context, value, child) {
          controller = value;
          return Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Column(
                children: [
                  CustomText(
                    label: AppLocalizations.of(context)!.cancelMessage,
                    fontSize: 15.sp,
                    labelFontWeight: FontWeight.w500,
                    // fontColor: AppColors.primaryText,
                  ),
                  SizedBox(height: 20.sp),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: AppLocalizations.of(context)!.cancel,
                          // color: AppColors.secondaryButton,
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
                            controller
                                .doCancelOpenOrder(
                                  context: context,
                                  orderId: id.toString(),
                                )
                                .whenComplete(() {
                                  Navigator.pop(context);
                                });
                          },
                        ),
                      ),
                    ],
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
}
