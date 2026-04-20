import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:provider/provider.dart' as pv;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_DataOfBirth.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/number_formator.dart';
import 'package:zayroexchange/Utility/global_state/global_providers.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/future_trade_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import '../../../Utility/custom_alertbox.dart';
import '../../../Utility/custom_no_records.dart';
import 'history_controller.dart';

class HistoryView extends rp.ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  rp.ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends rp.ConsumerState<HistoryView> {
  late HistoryController controller;
  late FutureTradeController futureTradeController;
  bool _didFetch = false;
  bool _pairsSynced = false;
  bool _ordersSynced = false;

  @override
  void initState() {
    super.initState();

    controller = pv.Provider.of<HistoryController>(context, listen: false);
    futureTradeController = pv.Provider.of<FutureTradeController>(
      context,
      listen: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_didFetch) return;
      _didFetch = true;
      controller.getDepositHistory(context, "");
      controller.selectedTab = 0;

      controller.getCoins(context);
      futureTradeController.getTradePairs(context);
      ref.read(tradePairsProvider.future);
      ref.read(orderHistoryProvider.future);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tradePairsAsync = ref.watch(tradePairsProvider);
    if (tradePairsAsync.hasValue && !_pairsSynced) {
      controller.applyTradePairsFromGlobal(tradePairsAsync.value!);
      _pairsSynced = true;
    }

    final openOrdersAsync = ref.watch(orderHistoryProvider);
    if (openOrdersAsync.hasValue && !_ordersSynced) {
      controller.applyOpenOrdersFromGlobal(openOrdersAsync.value!);
      _ordersSynced = true;
    }

    return pv.Consumer2<HistoryController, FutureTradeController>(
      builder: (context, value, fController, child) {
        controller = value;
        futureTradeController = fController;

        return SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                Column(
                  children: [
                    /// ================= TAB BAR =================
                    SizedBox(height: 12.sp),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _historyTab(
                            context,
                            AppLocalizations.of(context)!.depositHistory,
                            0,
                          ),
                          _historyTab(
                            context,
                            AppLocalizations.of(context)!.withdrawHistory,
                            1,
                          ),
                          _historyTab(
                            context,
                            AppLocalizations.of(context)!.transferHistory,
                            2,
                          ),
                          _historyTab(
                            context,
                            AppLocalizations.of(context)!.tradeHistory,
                            3,
                          ),
                          _historyTab(
                            context,
                            "${AppLocalizations.of(context)!.openOrders} (${controller.openOrderHistoryList.length})",
                            4,
                          ),

                          _historyTab(
                            context,
                            AppLocalizations.of(
                              context,
                            )!.perpetualOpenOrderHistory,
                            5,
                          ),

                          _historyTab(
                            context,
                            AppLocalizations.of(
                              context,
                            )!.perpetualMyOrderHistory,
                            6,
                          ),

                          _historyTab(
                            context,
                            AppLocalizations.of(context)!.perpetualClosedPnl,
                            7,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15.sp),

                    /// ================= FILTER =================
                    Padding(
                      padding: EdgeInsets.only(
                        left: 13.sp,
                        right: 13.sp,
                        bottom: 10.sp,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomDateSelect(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.startDate,
                                  dateText: controller.startDateController,
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.yyyyMmDd,
                                  onTap: () => _openDatePicker(true),
                                ),
                              ),
                              SizedBox(width: 12.sp),
                              Expanded(
                                child: CustomDateSelect(
                                  label: AppLocalizations.of(context)!.endDate,
                                  dateText: controller.endDateController,
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.yyyyMmDd,
                                  onTap: () => _openDatePicker(false),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 18.sp),

                          controller.selectedTab == 2
                              ? _transferCoinSelector()
                              : controller.selectedTab == 3 ||
                                    controller.selectedTab == 4
                              ? _tradeCoinSelector()
                              : (controller.selectedTab == 5 ||
                                    controller.selectedTab == 6 ||
                                    controller.selectedTab == 7)
                              ? _futureTradeCoinSelector()
                              : _coinSelector(),

                          SizedBox(height: 18.sp),

                          Row(
                            children: [
                              Expanded(
                                child: _actionButton(
                                  AppLocalizations.of(context)!.reset,
                                  Color(0xffF6465D),
                                  () => controller.clearFilters(
                                    context,
                                    futureTradeController,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.sp),
                              Expanded(
                                child: CustomButton(
                                  label: AppLocalizations.of(context)!.submit,
                                  onTap: () {
                                    controller.submitHistory(
                                      context,
                                      controller.selectedCoin?.symbol ?? "",
                                      controller.selectedTradePair,
                                      futureTradeController,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// ================= CONTENT =================
                    Expanded(
                      child: IndexedStack(
                        index: controller.selectedTab,
                        children: [
                          depositHistoryUI(context),
                          withdrawUI(context),
                          transferHistoryUI(context),
                          tradeOrderHistoryUI(context),
                          openOrderHistoryUI(context),

                          futuresOpenOrdersList(context, futureTradeController),
                          futuresMyOrdersList(context),
                          futuresPnLHistoryList(context),
                        ],
                      ),
                    ),
                  ],
                ),

                if (controller.isLoading) const CustomLoader(isLoading: true),
              ],
            ),
          ),
        );
      },
    );
  }

  cancelOrderAlert(
    BuildContext context,
    FutureTradeController controller,
    String id,
  ) {
    return customAlert(
      context: context,
      title: AppLocalizations.of(context)!.cancelOrder,
      widget: pv.Consumer<FutureTradeController>(
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
                  controller.isLoading
                      ? const CustomProgressDialog()
                      : Row(
                          children: [
                            Expanded(
                              child: CancelButton(
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

  /* ======================================================================
                          DEPOSIT HISTORY
====================================================================== */
  Widget depositHistoryUI(BuildContext context) {
    if (controller.depositHistoryList.isEmpty) {
      return historyEmpty(
        context,
        AppLocalizations.of(context)!.noDepositHistoryFound,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: controller.depositHistoryList.length,
      itemBuilder: (_, i) {
        return Padding(
          padding: EdgeInsets.only(
            left: 13.sp,
            right: 13.sp,
            top: 13.sp,
            bottom: 15.sp,
          ),
          child: depositHistoryCard(context, controller.depositHistoryList[i]),
        );
      },
    );
  }

  Widget depositHistoryCard(BuildContext context, DepositHistoryModel item) {
    final statusUI = getStatusUI(context, item.status.toString());

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.imageUrl.isNotEmpty)
                SvgPicture.network(item.imageUrl, height: 22.sp),
              SizedBox(width: 13.sp),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    label: item.coinName,
                    fontSize: 15.sp,
                    labelFontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8.sp),
                  CustomText(
                    label: item.coin,
                    fontSize: 14.sp,
                    labelFontWeight: FontWeight.w400,
                    fontColour: ThemeTextOneColor.getTextOneColor(context),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.sp),
          Divider(
            color: ThemeOutLineColor.getOutLineColor(context),
            thickness: 6.sp,
            height: 5.sp,
          ),
          _row(context, AppLocalizations.of(context)!.sender, item.sender),
          _row(
            context,
            AppLocalizations.of(context)!.receiver,
            item.receiver.isEmpty ? "------" : item.receiver,
          ),
          txHashRow(context, AppLocalizations.of(context)!.tXHash, item.txnId),
          _row(context, AppLocalizations.of(context)!.deposit, item.total),
          _row(context, AppLocalizations.of(context)!.depositFees, item.fee),
          _row(
            context,
            AppLocalizations.of(context)!.receivedDepositAmount,
            item.amount,
          ),
          _row(context, AppLocalizations.of(context)!.dateTime, item.createdAt),
          _row(
            context,
            AppLocalizations.of(context)!.status,
            statusUI.text,
            valueColor: statusUI.color,
          ),
        ],
      ),
    );
  }

  /* ======================================================================
                          WITHDRAW HISTORY
====================================================================== */

  Widget withdrawUI(BuildContext context) {
    if (controller.withdrawHistoryList.isEmpty) {
      return historyEmpty(
        context,
        AppLocalizations.of(context)!.noWithdrawHistoryFound,
      );
    }

    return ListView.builder(
      itemCount: controller.withdrawHistoryList.length,
      itemBuilder: (_, i) {
        return Padding(
          padding: EdgeInsets.all(15.sp),
          child: withdrawHistoryCard(
            context,
            controller.withdrawHistoryList[i],
          ),
        );
      },
    );
  }

  Widget withdrawHistoryCard(BuildContext context, WithdrawHistoryModel item) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(context),
        borderRadius: BorderRadius.circular(15.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 4.sp,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= HEADER =================
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    label: item.coin,
                    labelFontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ],
          ),

          Divider(color: ThemeOutLineColor.getOutLineColor(context)),

          /// ================= DETAILS =================
          txHashRow(
            context,
            AppLocalizations.of(context)!.receiver,
            item.receiver,
          ),

          _row(
            context,
            AppLocalizations.of(context)!.requestedAmount,
            item.amount,
          ),

          _row(context, AppLocalizations.of(context)!.withdrawFee, item.fee),

          _row(context, AppLocalizations.of(context)!.received, item.total),

          _row(context, AppLocalizations.of(context)!.dateTime, item.createdAt),

          /// ================= STATUS =================
          _row(
            context,
            AppLocalizations.of(context)!.status,
            item.status == 1
                ? AppLocalizations.of(context)!.completed
                : item.status == 2
                ? AppLocalizations.of(context)!.rejected
                : AppLocalizations.of(context)!.pending,
            valueColor: item.status == 1
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }
  /* ======================================================================
                          TRANSFER HISTORY
====================================================================== */

  Widget transferHistoryUI(BuildContext context) {
    if (controller.transferHistoryList.isEmpty) {
      return historyEmpty(
        context,
        AppLocalizations.of(context)!.noRecordsFound,
      );
    }

    return ListView.builder(
      itemCount: controller.transferHistoryList.length,
      itemBuilder: (_, i) {
        return Padding(
          padding: EdgeInsets.all(15.sp),
          child: transferHistoryCard(
            context,
            controller.transferHistoryList[i],
          ),
        );
      },
    );
  }

  Widget transferHistoryCard(BuildContext context, TransferHistoryModel item) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(context),
        borderRadius: BorderRadius.circular(15.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 4.sp,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= HEADER =================
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    label: item.currency,
                    labelFontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ],
          ),

          Divider(color: ThemeOutLineColor.getOutLineColor(context)),

          /// ================= DETAILS =================
          _row(context, AppLocalizations.of(context)!.from, item.from),

          _row(context, AppLocalizations.of(context)!.to, item.to),

          _row(context, AppLocalizations.of(context)!.amount, item.amount),

          _row(
            context,
            AppLocalizations.of(context)!.status,
            item.type.isNotEmpty ? AppLocalizations.of(context)!.completed : "",
            valueColor: item.type.isNotEmpty
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.error,
          ),

          _row(context, AppLocalizations.of(context)!.dateTime, item.createdAt),
        ],
      ),
    );
  }

  /* ======================================================================
                          Trade ORDER HISTORY
====================================================================== */

  tradeOrderHistoryUI(BuildContext context) {
    if (controller.tradeOrderHistoryList.isEmpty) {
      return historyEmpty(
        context,
        AppLocalizations.of(context)!.noRecordsFound,
      );
    }

    return ListView.builder(
      itemCount: controller.tradeOrderHistoryList.length,
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.only(
          left: 10.sp,
          right: 10.sp,
          top: 13.sp,
          bottom: 10.sp,
        ),
        child: tradeCoinHistoryCard(
          context,
          controller.tradeOrderHistoryList[i],
        ),
      ),
    );
  }

  Widget tradeCoinHistoryCard(
    BuildContext context,
    TradeOrderHistoryModel item,
  ) {
    final baseCoin = item.symbol.toString().split('/')[0];
    final quoteCoin = item.symbol.toString().split('/')[1];

    final bool isBuy = item.side.toString().toLowerCase() == 'buy';

    final bool isCancelled =
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
          /// ================= HEADER =================
          _row(
            context,
            AppLocalizations.of(context)!.tradingPair,
            item.symbol.toString(),
          ),

          Divider(color: ThemeOutLineColor.getOutLineColor(context)),

          /// ================= ORDER DETAILS =================
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
            item.orderId.toString(),
          ),
          _row(
            context,
            AppLocalizations.of(context)!.total,
            item.orderValue.toString(),
          ),

          /// ================= STATUS =================
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

  /* ======================================================================
                          OPEN ORDER HISTORY
====================================================================== */

  Widget openOrderHistoryUI(BuildContext context) {
    if (controller.openOrderHistoryList.isEmpty) {
      return historyEmpty(
        context,
        AppLocalizations.of(context)!.noRecordsFound,
      );
    }

    return ListView.builder(
      itemCount: controller.openOrderHistoryList.length,
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.only(
          left: 13.sp,
          right: 13.sp,
          top: 13.sp,
          bottom: 10.sp,
        ),
        child: openOrderItem(context, controller.openOrderHistoryList[i]),
      ),
    );
  }

  Widget openOrderItem(BuildContext context, OrderHistoryModel item) {
    final baseCoin = item.symbol.toString().split('/')[0];
    final quoteCoin = item.symbol.toString().split('/')[1];
    final bool isBuy = item.side.toString().toLowerCase() == 'buy';

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(
            context,
            AppLocalizations.of(context)!.tradingPair,
            item.symbol.toString(),
          ),

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
            AppLocalizations.of(context)!.price,
            "${numberFormatter(item.price.toString())} $quoteCoin",
          ),

          _row(
            context,
            AppLocalizations.of(context)!.remainingOrAmount,
            "${item.remainingQty} / ${item.qty} $baseCoin",
          ),

          _row(
            context,
            AppLocalizations.of(context)!.total,
            "${numberFormatter(item.orderValue.toString())} $quoteCoin",
          ),

          _row(
            context,
            AppLocalizations.of(context)!.orderTime,
            item.createdAt.toString(),
          ),

          /// ================= ACTION =================
          _openOrderActionRow(context, item),
        ],
      ),
    );
  }

  Widget _openOrderActionRow(BuildContext context, OrderHistoryModel item) {
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
              label: AppLocalizations.of(context)!.cancel,
              onTap: () {
                cancelDetailsBottomSheet(context, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  void cancelDetailsBottomSheet(BuildContext context, OrderHistoryModel item) {
    final _ = pv.Provider.of<HistoryController>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      builder: (_) {
        return pv.Consumer<HistoryController>(
          builder: (context, value, child) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(15.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          label: AppLocalizations.of(
                            context,
                          )!.cancelOrderConfirmation,
                          labelFontWeight: FontWeight.bold,
                        ),
                        // GestureDetector(
                        //   onTap: () => Navigator.pop(context),
                        //   child: SvgPicture.asset(
                        //     AppBasicIcons.close,
                        //     height: 20.sp,
                        //   ),
                        // ),
                      ],
                    ),

                    SizedBox(height: 20.sp),

                    value.isLoading
                        ? const CustomProgressDialog()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CancelButton(
                                label: AppLocalizations.of(context)!.cancel,
                                onTap: () => Navigator.pop(context),
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

  /* ======================================================================
                          Futures HISTORY
====================================================================== */

  ///Future Open orders
  futuresOpenOrdersList(
    BuildContext context,
    FutureTradeController fcontroller,
  ) {
    return Container(
      child: controller.futuresOpenOrdersList.isEmpty
          ? customNoRecordsFound(context)
          : ListView.builder(
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.futuresOpenOrdersList.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int i) {
                var list = controller.futuresOpenOrdersList[i];
                return Column(
                  children: [
                    SizedBox(height: 18.sp),
                    Container(
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
                            valueColor: list.status.toString() == "0"
                                ? Theme.of(context).colorScheme.tertiary
                                : Theme.of(context).colorScheme.error,
                          ),
                          _row(
                            context,
                            AppLocalizations.of(context)!.orderTime,
                            list.dateTime.toString(),
                          ),
                          SizedBox(height: 15.sp),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                label: AppLocalizations.of(context)!.action,
                                labelFontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                                // fontColor: AppColors.secondaryText,
                              ),
                              SizedBox(height: 6.sp),
                              CustomButton(
                                onTap: () {
                                  cancelOrderAlert(
                                    context,
                                    futureTradeController,
                                    list.id.toString(),
                                  );
                                },
                                label: AppLocalizations.of(context)!.cancel,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  ///Future My Orders
  futuresMyOrdersList(BuildContext context) {
    return controller.futuresMyOrdersList.isEmpty
        ? customNoRecordsFound(context)
        : ListView.builder(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.symmetric(horizontal: 6.sp),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.futuresMyOrdersList.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int i) {
              var list = controller.futuresMyOrdersList[i];
              return Column(
                children: [
                  SizedBox(height: 15.sp),
                  Container(
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
                        CustomText(
                          label: list.tradePair.toString(),
                          labelFontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: 10.sp),
                        Divider(
                          color: ThemeOutLineColor.getOutLineColor(context),
                        ),
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
                  ),
                ],
              );
            },
          );
  }

  ///Future PNL Orders
  futuresPnLHistoryList(BuildContext context) {
    return controller.futuresPnLHistoryList.isEmpty
        ? customNoRecordsFound(context)
        : ListView.builder(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.symmetric(horizontal: 6.sp),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.futuresPnLHistoryList.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int i) {
              var list = controller.futuresPnLHistoryList[i];
              return Column(
                children: [
                  SizedBox(height: 18.sp),
                  Container(
                    margin: EdgeInsets.only(bottom: 15.sp),
                    padding: EdgeInsets.all(12.sp),
                    decoration: BoxDecoration(
                      color: ThemeTextFormFillColor.getTextFormFillColor(
                        context,
                      ),
                      borderRadius: BorderRadius.circular(12.sp),
                      border: Border.all(
                        color: ThemeOutLineColor.getOutLineColor(context),
                        width: 4.sp,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          label: list.tradePair.toString(),
                          labelFontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: 10.sp),
                        Divider(
                          color: ThemeOutLineColor.getOutLineColor(context),
                        ),
                        _row(
                          context,
                          AppLocalizations.of(context)!.contracts,
                          list.tradePair.toString(),
                        ),
                        _row(
                          context,
                          AppLocalizations.of(context)!.qty,
                          list.qty.toString(),
                        ),
                        _row(
                          context,
                          AppLocalizations.of(context)!.entryPrice,
                          list.entryPrice.toString(),
                        ),
                        _row(
                          context,
                          AppLocalizations.of(context)!.exitPrice,
                          list.exitPrice.toString(),
                        ),
                        _row(
                          context,
                          AppLocalizations.of(context)!.exitType,
                          list.exitType.toString(),
                        ),
                        _row(
                          context,
                          AppLocalizations.of(context)!.tradeType,
                          (list.side ?? "").toLowerCase() == "buy"
                              ? AppLocalizations.of(context)!.closeLong
                              : AppLocalizations.of(context)!.closeShort,
                          valueColor: (list.side ?? "").toLowerCase() == "buy"
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.error,
                        ),
                        _row(
                          context,
                          AppLocalizations.of(context)!.closedPNL,
                          list.closedPnL.toString(),
                        ),
                        _row(
                          context,
                          AppLocalizations.of(context)!.dateTime,
                          list.dateTime.toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
  }

  /* ======================================================================
                          USED FUNCTION
====================================================================== */

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

  // ================= TAB ITEM =================
  Widget _historyTab(BuildContext context, String title, int index) {
    final bool isSelected = controller.selectedTab == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.changeTab(index, context, futureTradeController),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(
              label: title,
              maxLines: 1,
              align: TextAlign.center,
              labelFontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontColour: isSelected
                  ? ThemeTextColor.getTextColor(context)
                  : ThemeTextOneColor.getTextOneColor(context),
            ),

            SizedBox(height: 10.sp),

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 3,
              width: isSelected ? 30.sp : 0,
              decoration: BoxDecoration(
                color: ThemeInversePrimaryColor.getInversePrimaryColor(context),
                borderRadius: BorderRadius.circular(20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DATE PICKER =================
  Future<void> _openDatePicker(bool isStart) async {
    final today = DateTime.now();

    final firstDate = isStart
        ? DateTime(2000)
        : (controller.startDate ?? DateTime(2000));

    DateTime initialDate = isStart
        ? (controller.startDate ?? today)
        : (controller.endDate ?? controller.startDate ?? today);

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: today,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: ThemeInversePrimaryColor.getInversePrimaryColor(context),
              surface: ThemeBackgroundColor.getBackgroundColor(context),
              onPrimary: Colors.white,
              onSurface: ThemeTextColor.getTextColor(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      isStart ? controller.setStartDate(picked) : controller.setEndDate(picked);
    }
  }

  // ================= COIN SELECTOR =================
  Widget _coinSelector() {
    return GestureDetector(
      onTap: _openCoinSheet,
      child: _selectorBox(
        controller.selectedCoin?.symbol ??
            AppLocalizations.of(context)!.selectCoin,
      ),
    );
  }

  Widget _tradeCoinSelector() {
    return GestureDetector(
      onTap: _openTradeCoinSheet,
      child: _selectorBox(
        controller.selectedTradeCoin == null
            ? AppLocalizations.of(context)!.selectCoin
            : "${controller.selectedTradeCoin!.coinOne}/${controller.selectedTradeCoin!.coinTwo}",
      ),
    );
  }

  Widget _transferCoinSelector() {
    return GestureDetector(
      onTap: _openTransferCoinSheet,
      child: _selectorBox(controller.selectedTransferPair),
    );
  }

  Widget _futureTradeCoinSelector() {
    return GestureDetector(
      onTap: _openFutureTradeCoinSheet,
      child: _selectorBox(
        controller.selectedFutureTradePair == null
            ? AppLocalizations.of(context)!.selectPair
            : "${controller.selectedFutureTradePair!.coinOne}/${controller.selectedFutureTradePair!.coinTwo}",
      ),
    );
  }

  Widget _selectorBox(String label) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(context),
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 4.sp,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(label: label),
          Icon(
            Icons.keyboard_arrow_down,
            color: ThemeTextOneColor.getTextOneColor(context),
          ),
        ],
      ),
    );
  }

  // ================= BUTTON =================
  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 5.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.sp),
        ),
        child: CustomText(
          label: label,
          labelFontWeight: FontWeight.w600,
          fontColour: Colors.white,
        ),
      ),
    );
  }

  // ================= COIN SHEET =================
  void _openCoinSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            color: ThemeBackgroundColor.getBackgroundColor(context),
            border: Border.all(
              color: ThemeOutLineColor.getOutLineColor(context),
              width: 5.sp,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.sp),
              topRight: Radius.circular(20.sp),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 15.sp),

                /// 🔹 Header
                Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        label: AppLocalizations.of(context)!.selectCoin,
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
                ),

                SizedBox(height: 12.sp),
                Divider(
                  color: ThemeOutLineColor.getOutLineColor(context),
                  thickness: 6.sp,
                  height: 5.sp,
                ),

                /// ================= COIN LIST =================
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.coinList.length,
                    itemBuilder: (_, index) {
                      final coin = controller.coinList[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(10.sp),
                        onTap: () {
                          controller.setSelectedCoin(coin);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 13.sp,
                            right: 13.sp,
                            top: 13.sp,
                            bottom: 10.sp,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.network(coin.imageUrl, height: 22.sp),
                              SizedBox(width: 15.sp),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    label: coin.symbol,
                                    labelFontWeight: FontWeight.bold,
                                  ),
                                  SizedBox(height: 4.sp),
                                  CustomText(
                                    label: coin.name,
                                    fontColour:
                                        ThemeTextOneColor.getTextOneColor(
                                          context,
                                        ),
                                    labelFontWeight: FontWeight.w400,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openTradeCoinSheet() {
    if (controller.tradePairList.isEmpty) {
      controller.getTradePairs(context);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return pv.Consumer<HistoryController>(
          builder: (context, historyController, __) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                color: ThemeBackgroundColor.getBackgroundColor(context),
                border: Border.all(
                  color: ThemeOutLineColor.getOutLineColor(context),
                  width: 5.sp,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.sp),
                  topRight: Radius.circular(20.sp),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 15.sp),

                    /// 🔹 Header
                    Padding(
                      padding: EdgeInsets.all(12.sp),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            label: AppLocalizations.of(context)!.selectPair,
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
                    ),
                    SizedBox(height: 12.sp),
                    Divider(
                      color: ThemeOutLineColor.getOutLineColor(context),
                      thickness: 6.sp,
                      height: 5.sp,
                    ),

                    Expanded(
                      child: historyController.tradePairList.isEmpty
                          ? customNoRecordsFound(context)
                          : ListView.builder(
                              itemCount: controller.tradePairList.length,
                              itemBuilder: (_, index) {
                                final coin = controller.tradePairList[index];

                                return InkWell(
                                  borderRadius: BorderRadius.circular(10.sp),
                                  onTap: () {
                                    controller.setSelectedTradeCoin(coin);
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 13.sp,
                                      right: 13.sp,
                                      top: 13.sp,
                                      bottom: 10.sp,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          label: coin.coinOne.toString(),
                                          labelFontWeight: FontWeight.bold,
                                        ),
                                        SizedBox(width: 4.sp),
                                        CustomText(label: "/"),
                                        CustomText(
                                          label: coin.coinTwo.toString(),
                                          labelFontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
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

  void _openTransferCoinSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            color: ThemeBackgroundColor.getBackgroundColor(context),
            border: Border.all(
              color: ThemeOutLineColor.getOutLineColor(context),
              width: 5.sp,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.sp),
              topRight: Radius.circular(20.sp),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 15.sp),

                /// 🔹 Header
                Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        label: AppLocalizations.of(context)!.selectCoin,
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
                ),
                SizedBox(height: 12.sp),
                Divider(
                  color: ThemeOutLineColor.getOutLineColor(context),
                  thickness: 6.sp,
                  height: 5.sp,
                ),

                /// ================= TRADE PAIR LIST =================
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.transferCoinList.length,
                    itemBuilder: (_, index) {
                      final coin = controller.transferCoinList[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(10.sp),
                        onTap: () {
                          controller.setSelectedTransferPair(coin);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 13.sp,
                            right: 13.sp,
                            top: 13.sp,
                            bottom: 10.sp,
                          ),
                          child: CustomText(label: coin, maxLines: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openFutureTradeCoinSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            color: ThemeBackgroundColor.getBackgroundColor(context),
            border: Border.all(
              color: ThemeOutLineColor.getOutLineColor(context),
              width: 5.sp,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.sp),
              topRight: Radius.circular(20.sp),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 15.sp),

                /// 🔹 Header
                Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        label: AppLocalizations.of(context)!.selectPair,
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
                ),

                SizedBox(height: 12.sp),
                Divider(
                  color: ThemeOutLineColor.getOutLineColor(context),
                  thickness: 6.sp,
                  height: 5.sp,
                ),

                /// ================= TRADE PAIR LIST =================
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        futureTradeController.perpetualTradePairsList.length,
                    itemBuilder: (_, index) {
                      final coin =
                          futureTradeController.perpetualTradePairsList[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(10.sp),
                        onTap: () {
                          controller.setSelectedFutureTradeCoin(coin);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 13.sp,
                            right: 13.sp,
                            top: 13.sp,
                            bottom: 10.sp,
                          ),
                          child: Row(
                            children: [
                              SvgPicture.network(
                                coin.coinOneImage.toString(),
                                height: 20.sp,
                              ),
                              SizedBox(width: 10.sp),

                              Expanded(
                                child: CustomText(
                                  label: "${coin.coinOne}/${coin.coinTwo}",
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ======================================================================
                          COMMON WIDGETS
====================================================================== */

Widget historyEmpty(BuildContext context, String text) {
  return Center(
    child: CustomText(
      label: text,
      fontColour: ThemeTextOneColor.getTextOneColor(context),
    ),
  );
}

StatusUI getStatusUI(BuildContext context, String status) {
  switch (status) {
    case '1':
      return StatusUI(
        AppLocalizations.of(context)!.completed,
        Theme.of(context).colorScheme.tertiary, // success
      );

    case '2':
      return StatusUI(
        AppLocalizations.of(context)!.rejected,
        Theme.of(context).colorScheme.error, // error
      );

    case '0':
    default:
      return StatusUI(
        AppLocalizations.of(context)!.pending,
        Theme.of(context).colorScheme.error, // pending
      );
  }
}
