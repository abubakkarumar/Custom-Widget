import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/no_data_layout.dart';
import 'package:zayroexchange/Utility/number_formator.dart';
import 'package:zayroexchange/Views/Bottom_Pages/History/history_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';
import '../../../../l10n/app_localizations.dart';
import 'custom_progress_dialog.dart';

Widget customTabOrders({
  required BuildContext context,
  required SpotTradeController controller,
}) {
  return Column(
    children: [
      /// ================= TAB BAR =================
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _tabItem(
            context,
            "${AppLocalizations.of(context)!.openOrders} (${controller.openOrderHistoryList.length})",
            0,
            controller,
          ),
          _tabItem(
            context,
            AppLocalizations.of(context)!.myOrderHistory,
            1,
            controller,
          ),
        ],
      ),

      /// ================= CONTENT =================
      // IndexedStack(
      //   index: controller.selectedTab,
      //   children: [
      if (controller.selectedTab == 0) getOpenOrderHistory(controller, context),
      if (controller.selectedTab == 1) getOrderHistory(context, controller),
      //   ],
      // ),
    ],
  );
}

Widget getOpenOrderHistory(
  SpotTradeController controller,
  BuildContext context,
) {
  if (controller.openOrderHistoryList.isEmpty) {
    return const NoDataLayout();
  }

  return ListView.builder(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).padding.bottom + 5.h,
    ),
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: controller.openOrderHistoryList.length,
    itemBuilder: (context, index) {
      final item = controller.openOrderHistoryList[index];
      return _OpenOrderItem(item: item, controller: controller);
    },
  );
}

class _OpenOrderItem extends StatelessWidget {
  final dynamic item;
  final SpotTradeController controller;

  const _OpenOrderItem({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final baseCoin = item.symbol.toString().split('/')[0];
    final quoteCoin = item.symbol.toString().split('/')[1];
    final isBuy = item.side.toString().toLowerCase() == 'buy';

    return Padding(
      padding: EdgeInsets.all(12.sp),
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: ThemeTextFormFillColor.getTextFormFillColor(context),
          borderRadius: BorderRadius.circular(12.sp),
          border: Border.all(
            color: ThemeOutLineColor.getOutLineColor(context),
            width: 4.sp,
          ),
        ),
        child: Column(
          children: [
            _row(
              context,
              AppLocalizations.of(context)!.tradingPair,
              item.symbol,
              valueColor: ThemeTextColor.getTextColor(context),
            ),
            _row(
              context,
              AppLocalizations.of(context)!.orderType,
              item.orderType,
              valueColor: ThemeTextColor.getTextColor(context),
            ),
            _row(
              context,
              AppLocalizations.of(context)!.direction,
              item.side,
              valueColor: isBuy
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.error,
            ),
            _row(
              context,
              valueColor: ThemeTextColor.getTextColor(context),
              AppLocalizations.of(context)!.price,
              "${numberFormatter(item.price.toString())} $quoteCoin",
            ),
            _row(
              context,
              valueColor: ThemeTextColor.getTextColor(context),
              AppLocalizations.of(context)!.remainingOrAmount,
              "${item.remainingQty} / ${item.qty} $baseCoin",
            ),
            _row(
              context,
              valueColor: ThemeTextColor.getTextColor(context),
              AppLocalizations.of(context)!.total,
              "${numberFormatter(item.orderValue.toString())} $quoteCoin",
            ),
            _row(
              context,
              valueColor: ThemeTextColor.getTextColor(context),
              AppLocalizations.of(context)!.orderTime,
              item.createdAt.toString(),
            ),
            _actionRow(context),
          ],
        ),
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
      padding: EdgeInsets.symmetric(vertical: 10.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(label: label, fontSize: 13.5.px),
          Expanded(
            child: CustomText(
              label: value,
              fontSize: 12.px,
              align: TextAlign.end,
              labelFontWeight: FontWeight.w700,
              fontColour: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            label: AppLocalizations.of(context)!.action,
            fontSize: 13.5.px,
          ),
          SizedBox(
            width: 30.w,
            height: 4.h,
            child: CustomButton(
              onTap: () {
                cancelDetailsBottomSheet(context, controller, item);
              },
              label: AppLocalizations.of(context)!.cancel,
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
Widget getOrderHistory(BuildContext context, SpotTradeController controller) {
  if (controller.orderHistoryList.isEmpty) {
    return historyEmpty(context, AppLocalizations.of(context)!.noRecordsFound);
  }

  return ListView.builder(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).padding.bottom + 5.h,
    ),
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    itemCount: controller.orderHistoryList.length,
    itemBuilder: (context, index) {
      final item = controller.orderHistoryList[index];
      return Padding(
        padding: EdgeInsets.only(
          left: 10.sp,
          right: 10.sp,
          top: 13.sp,
          bottom: 10.sp,
        ),
        child: _OrderHistoryItem(item: item),
      );
    },
  );
}

class _OrderHistoryItem extends StatelessWidget {
  final OrderHistoryModel item;

  const _OrderHistoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final baseCoin = item.symbol.toString().split('/')[0];
    final quoteCoin = item.symbol.toString().split('/')[1];
    final isBuy = item.side.toString().toLowerCase() == 'buy';
    final _ = item.orderType.toString().toLowerCase() == 'limit';
    final isCancelled =
        item.orderStatus.toString().trim().toLowerCase() == 'cancelled';

    return Container(
      padding: EdgeInsets.only(
        left: 10.sp,
        right: 10.sp,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(
            context,
            AppLocalizations.of(context)!.tradingPair,
            item.symbol.toString(),
          ),
          Divider(color: ThemeOutLineColor.getOutLineColor(context)),

          _row(
            context,
            AppLocalizations.of(context)!.orderType,
            item.orderType.toString(),
          ),

          _row(
            context,
            AppLocalizations.of(context)!.direction,
            item.side.toString(),
            valueColor: isBuy
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.error,
          ),
          _row(
            context,
            AppLocalizations.of(context)!.filledOrderAmount,
            "${item.filledVolume} / ${item.qty} $baseCoin",
          ),

          _row(
            context,
            AppLocalizations.of(context)!.filledOrderTotal,
            "${item.filledValue} / ${item.orderValue} $quoteCoin",
          ),

          _row(
            context,
            AppLocalizations.of(context)!.tradingFees,
            "${item.fee} $baseCoin",
          ),
          _row(
            context,
            AppLocalizations.of(context)!.orderTime,
            item.createdAt.toString(),
          ),
          _row(
            context,
            AppLocalizations.of(context)!.orderID,
            "${item.orderId}",
          ),

          _row(
            context,
            AppLocalizations.of(context)!.status,
            item.orderStatus.toString(),
            valueColor: isCancelled
                ? Theme.of(context).colorScheme.error
                : ThemeTextColor.getTextColor(context),
          ),
        ],
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

void cancelDetailsBottomSheet(
  BuildContext context,
  SpotTradeController controller,
  OrderHistoryModel item,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
    ),
    builder: (_) {
      return Consumer<SpotTradeController>(
        builder: (context, value, child) {
          return SizedBox(
            height: 20.h,
            child: Padding(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        label: AppLocalizations.of(
                          context,
                        )!.cancelOrderConfirmation,
                        labelFontWeight: FontWeight.bold,
                      ),
                    /*  GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: SvgPicture.asset(
                          AppBasicIcons.close,
                          height: 20.sp,
                        ),
                      ),*/
                    ],
                  ),
                  SizedBox(height: 20.sp),

                  value.isLoading == true
                      ? CustomProgressDialog()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CancelButton(
                              label: AppLocalizations.of(context)!.cancel,
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                            CustomButton(
                              width: 38.w,
                              label: AppLocalizations.of(context)!.submit,
                              onTap: () {
                                value.cancelOrder(
                                  context: context,
                                  id: item.orderId.toString(),
                                  type: item.side.toString().toLowerCase(),
                                );
                              },
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

/*
getOrderHistory(BuildContext context, SpotTradeController controller) {
  return Column(
    children: [
      Card(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Column(
          children: [
            SizedBox(height: 10.sp),
            controller.orderHistoryList.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.orderHistoryList.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int i) {
                      var item = controller.orderHistoryList[i];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.sp),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 100.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.tradingPair,
                                        fontSize: 12.px,
                                      ),
                                      CustomText(
                                        label: item.symbol.toString(),
                                        labelFontWeight: FontWeight.w500,
                                        fontSize: 12.px,
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 15.sp),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.orderType,
                                        fontSize: 12.px,
                                      ),
                                      CustomText(
                                        label: item.orderType.toString(),
                                        labelFontWeight: FontWeight.w500,
                                        fontSize: 12.px,
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 15.sp),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.direction,
                                        fontSize: 12.px,
                                      ),
                                      CustomText(
                                        label: item.side.toString(),
                                        labelFontWeight: FontWeight.w500,
                                        fontSize: 12.px,
                                        fontColour:
                                            item.side
                                                    .toString()
                                                    .toLowerCase() ==
                                                'buy'
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.tertiary
                                            : Theme.of(
                                                context,
                                              ).colorScheme.error,
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 15.sp),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label:
                                            "${AppLocalizations.of(context)!.avgFilledPrice} / ${AppLocalizations.of(context)!.orderPrice}",
                                        fontSize: 12.px,
                                      ),
                                      Expanded(
                                        child: CustomText(
                                          label:
                                              "${numberFormatter(item.avgPrice.toString())} / ${item.orderType.toString().toLowerCase() == "limit" ? numberFormatter(item.price.toString()) : AppLocalizations.of(context)!.marketPrice} ${item.symbol.toString().split('/')[1]}",
                                          labelFontWeight: FontWeight.w500,
                                          fontSize: 12.px,
                                          align: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 15.sp),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.remainingOrAmount,
                                        fontSize: 12.px,
                                      ),
                                      Expanded(
                                        child: CustomText(
                                          label:
                                              "${item.remainingQty.toString()} / ${item.qty.toString()} ${item.symbol.toString().split('/')[0]}",
                                          labelFontWeight: FontWeight.w500,
                                          fontSize: 12.px,
                                          align: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 15.sp),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label:
                                            "${AppLocalizations.of(context)!.filled} / ${AppLocalizations.of(context)!.orderValue}",
                                        fontSize: 12.px,
                                      ),
                                      Expanded(
                                        child: CustomText(
                                          label:
                                              "${numberFormatter(item.value.toString())} / ${item.orderType.toString().toLowerCase() == "limit" ? numberFormatter(item.orderValue.toString()) : AppLocalizations.of(context)!.marketPrice} ${item.symbol.toString().split('/')[1]}",
                                          labelFontWeight: FontWeight.w500,
                                          fontSize: 12.px,
                                          align: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 15.sp),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.tradingFees,
                                        fontSize: 12.px,
                                      ),
                                      Expanded(
                                        child: CustomText(
                                          label:
                                              "${item.fee.toString()} ${item.symbol.toString().split('/')[0]}",
                                          labelFontWeight: FontWeight.w500,
                                          fontSize: 12.px,
                                          align: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 15.sp),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.orderTime,
                                        fontSize: 12.px,
                                      ),
                                      Expanded(
                                        child: CustomText(
                                          label: item.createdAt.toString(),
                                          labelFontWeight: FontWeight.w500,
                                          fontSize: 12.px,
                                          align: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 15.sp),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.status,
                                        fontSize: 12.px,
                                      ),
                                      // Container(
                                      //   padding: EdgeInsets.only(
                                      //     left: 10.sp,
                                      //     right: 10.sp,
                                      //     top: 5.sp,
                                      //     bottom: 5.sp,
                                      //   ),
                                      //   decoration: BoxDecoration(
                                      //     fontColour: const Color(0xFFE6F5EF),
                                      //     borderRadius: BorderRadius.circular(12.sp),
                                      //   ),
                                      //   child:
                                      CustomText(
                                        label: item.orderStatus.toString(),
                                        fontColour:
                                            item.orderStatus
                                                    .toString()
                                                    .trim()
                                                    .toLowerCase() ==
                                                "cancelled"
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.error
                                            : Theme.of(
                                                context,
                                              ).colorScheme.primaryFixed,
                                      ),
                                      // ),
                                    ],
                                  ),

                                  Divider(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerLow,
                                    thickness: 4.sp,
                                  ),
                                  //
                                  // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                                  //   CustomText(
                                  //      AppLocalizations.of(context)!.type,
                                  //     color: Theme.of(context).colorScheme.tertiary,
                                  //   ),
                                  //   CustomTextBodyLarge(
                                  //      "Test",
                                  //     color: Theme.of(context).colorScheme.primary,
                                  //   ),
                                  // ],)
                                ],
                              ),
                            ),
                            SizedBox(height: 15.sp),
                          ],
                        ),
                      );
                    },
                  )
                : NoDataLayout(),
          ],
        ),
      ),
      SizedBox(height: 10.h),
    ],
  );
}
*/

// ================= TAB ITEM =================
Widget _tabItem(
  BuildContext context,
  String title,
  int index,
  SpotTradeController controller,
) {
  final isSelected = controller.selectedTab == index;

  return Expanded(
    child: GestureDetector(
      onTap: () => controller.changeTab(index, context),
      child: Column(
        children: [
          CustomText(
            label: title,
            labelFontWeight: FontWeight.w600,
            fontColour: isSelected
                ? ThemeTextColor.getTextColor(context)
                : ThemeTextOneColor.getTextOneColor(context),
          ),
          SizedBox(height: 8.sp),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 4,
            width: isSelected ? 40.sp : 0,
            decoration: BoxDecoration(
              color: ThemeInversePrimaryColor.getInversePrimaryColor(context),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    ),
  );
}
