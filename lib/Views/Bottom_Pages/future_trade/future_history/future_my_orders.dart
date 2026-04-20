import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../../../../Utility/Colors/custom_theme_change.dart';
import '../../../../Utility/custom_no_records.dart';
import '../../../../Utility/custom_text.dart';
import '../future_trade/future_trade_controller.dart';
import '../future_trade/future_trade_view.dart' show CustomTabView;

class FutureMyOrders extends StatefulWidget {
  const FutureMyOrders({super.key});

  @override
  State<FutureMyOrders> createState() => _FutureMyOrdersState();
}

class _FutureMyOrdersState extends State<FutureMyOrders> {
  FutureTradeController controller = FutureTradeController();
  @override
  Widget build(BuildContext context) {
    return Consumer<FutureTradeController>(
      builder: (context, value, child) {
        controller = value;
        print("MMMM ${controller.futuresMyOrdersList.length}");
        return CustomTabView(
          length: 2,
          isScrollable: true,
          listName: [
            Tab(text: AppLocalizations.of(context)!.limitOrMarket),
            Tab(text: AppLocalizations.of(context)!.tpsl),
          ],
          functions: [
            futuresMyOrdersList(context, controller),
            futuresMyOrdersTPSLList(context, controller),
          ],
        );
      },
    );
  }

  futuresMyOrdersList(BuildContext context, FutureTradeController controller) {
    return controller.futuresMyOrdersList.isEmpty
        ? customNoRecordsFound(context)
        : ListView.builder(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 5.h,
            ),
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.futuresMyOrdersList.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int i) {
              var list = controller.futuresMyOrdersList[i];
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
                      list.tradePair.toString(),
                    ),
                    _row(
                      context,
                      AppLocalizations.of(context)!.filledOrTotal,
                      "${list.filled.toString()}/${list.total.toString()}",
                    ),
                    _row(
                      context,
                      AppLocalizations.of(context)!.filledPriceOrOrderPrice,
                      "${list.filledPrice.toString()}/${list.orderType == "2" ? "Market" : list.orderPrice.toString()}",
                    ),
                    _row(
                      context,
                      AppLocalizations.of(context)!.tradeType,
                      (list.side ?? "").toLowerCase() == "buy"
                          ? AppLocalizations.of(context)!.openLong
                          : AppLocalizations.of(context)!.openShort,
                      valueColor: (list.side ?? "").toLowerCase() == "buy"
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.error,
                    ),
                    _row(
                      context,
                      AppLocalizations.of(context)!.orderType,
                      list.orderType == "1"
                          ? AppLocalizations.of(context)!.limit
                          : AppLocalizations.of(context)!.market,
                    ),
                    txHashRow(
                      context,
                      AppLocalizations.of(context)!.orderID,
                      list.orderId.toString(),
                    ),
                    _row(
                      context,
                      AppLocalizations.of(context)!.status,
                      list.status.toString(),
                    ),
                    _row(
                      context,
                      AppLocalizations.of(context)!.dateTime,
                      list.dateTime.toString(),
                    ),
                  ],
                ),
              );
            },
          );
  }

  futuresMyOrdersTPSLList(
    BuildContext context,
    FutureTradeController controller,
  ) {
    return controller.futuresMyOrdersTPSLList.isEmpty
        ? customNoRecordsFound(context)
        : ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.futuresMyOrdersTPSLList.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int i) {
              var list = controller.futuresMyOrdersTPSLList[i];
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
                      list.tradePair.toString(),
                    ),
                    _row(
                      context,
                      AppLocalizations.of(context)!.filledOrQty,
                      "${list.filled.toString()}/${list.qty.toString()}",
                    ),
                    _row(
                      context,
                      AppLocalizations.of(context)!.triggerPrice,
                      list.takeProfit != "0"
                          ? ">=${list.takeProfit}${list.takeProfitBy != "" ? "(${list.takeProfitBy})" : ""}"
                          : ">=${list.stopLoss}${list.stopLossBy != "" ? "(${list.stopLossBy})" : ""}",
                    ),
                    _row(
                      context,
                      AppLocalizations.of(context)!.filledPriceOrOrderPrice,
                      "${list.filledPrice.toString() == "0" ? "--" : list.filledPrice.toString()}/${list.orderType == "2" ? "Market" : list.orderPrice.toString()}",
                    ),

                    _row(
                      context,
                      AppLocalizations.of(context)!.tradeType,
                      (list.side ?? "").toLowerCase() == "buy"
                          ? AppLocalizations.of(context)!.closeShort
                          : AppLocalizations.of(context)!.closeLong,
                      valueColor: (list.side ?? "").toLowerCase() == "buy"
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.error,
                    ),
                    txHashRow(
                      context,
                      AppLocalizations.of(context)!.orderID,
                      list.orderId.toString(),
                    ),
                    _row(
                      context,
                      AppLocalizations.of(context)!.status,
                      list.status.toString(),
                    ),
                    _row(
                      context,
                      AppLocalizations.of(context)!.dateTime,
                      list.dateTime.toString(),
                    ),
                  ],
                ),
              );
            },
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
        top: 10.sp,
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
}
