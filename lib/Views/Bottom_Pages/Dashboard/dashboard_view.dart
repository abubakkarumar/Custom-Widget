// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Bottom_Pages/RewardsHub/rewards_hub_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/deposit/deposit_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/withdraw/withdraw_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';
import 'package:zayroexchange/Views/Root/root_controller.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/referral_view.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'dashboard_controller.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late DashboardController controller;
  late RootController rootController;
  late SpotTradeController spotTradeController;
  bool _didFetch = false;

  // =============================
  // SOCKET UPDATE
  // =============================
  void _updateFromSocket(dynamic data, List list) {
    if (data == null) return;

    final parsed = jsonDecode(data);
    final symbol = parsed["data"]['symbol']?.toString();

    final index = list.indexWhere((e) => "${e.coinOne}${e.coinTwo}" == symbol);

    if (index == -1) return;

    list[index].last =
        (double.tryParse(parsed["data"]['lastPrice'] ?? "0") ?? 0)
            .toStringAsFixed(2);

    list[index].volume =
        (double.tryParse(parsed["data"]['volume24h'] ?? "0") ?? 0)
            .toStringAsFixed(2);

    list[index].exchange =
        ((double.tryParse(parsed["data"]['price24hPcnt'] ?? "0") ?? 0) * 100)
            .toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      controller = context.read<DashboardController>();
      rootController = context.read<RootController>();
      spotTradeController = context.read<SpotTradeController>();

      if (_didFetch) return;
      _didFetch = true;
      depositInfoContent(context);
      controller.getDashboardData(context);
      controller.getUserDetails(context);
      controller.getMarketOverview(context);
      rootController.notificationCount(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<DashboardController, RootController, SpotTradeController>(
      builder: (_, value, rController, sController, __) {
        controller = value;
        rootController = rController;
        spotTradeController = sController;
        return SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () {
                    return Future.delayed(Duration.zero).whenComplete(() async {
                      controller.getDashboardData(context);
                      controller.getUserDetails(context);
                      controller.getMarketOverview(context);
                      rootController.notificationCount(context);
                    });
                  },
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// TOP BANNER
                        AppStorage.getLanguage() == 'cn'
                            ? Image.asset(
                                AppThemeIcons.dashboardZhContent(context),
                                width: 100.w,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                AppThemeIcons.dashboardContent(context),
                                width: 100.w,
                                fit: BoxFit.cover,
                              ),

                        SizedBox(height: 15.sp),

                        CustomText(
                          label: AppLocalizations.of(context)!.balanceDetails,
                          fontSize: 15.sp,
                          labelFontWeight: FontWeight.bold,
                        ),

                        SizedBox(height: 12.sp),

                        TotalValueCard(
                          isHidden: controller.isHiddenBalance,
                          amountUSD: controller.walletBalanceUSD,
                          btcValue: controller.walletBalanceBTC,
                          onHideTap: controller.toggleBalance,
                          onAssetDetailsTap: () {
                            rootController.changeTabIndex(3);
                          },
                        ),

                        SizedBox(height: 18.sp),

                        /// ACTION BUTTONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            dashboardAction(
                              AppLocalizations.of(context)!.deposit,
                              AppThemeIcons.dashboardDeposit(context),
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const DepositView(coinName: ""),
                                ),
                              ),
                            ),
                            dashboardAction(
                              AppLocalizations.of(context)!.withdraw,
                              AppThemeIcons.dashboardWithdraw(context),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const WithdrawView(coinName: ""),
                                  ),
                                );
                              },
                            ),
                            dashboardAction(
                              AppLocalizations.of(context)!.referral,
                              AppThemeIcons.dashboardReferral(context),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ReferralView(isSelectedFrom: true),
                                  ),
                                );
                              },
                            ),
                            dashboardAction(
                              AppLocalizations.of(context)!.rewardsHub,
                              AppThemeIcons.dashboardAffiliate(context),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RewardsHubView(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 15.sp),

                        CustomText(
                          label: AppLocalizations.of(context)!.marketList,
                          fontSize: 16.sp,
                          labelFontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 12.sp),

                        /// Dotted Divider
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.sp),
                          child: DottedDivider(
                            color: ThemeTextOneColor.getTextOneColor(context),
                          ),
                        ),
                        SizedBox(height: 15.sp),

                        _tabs(),

                        /// ✅ FIXED MARKET SECTION
                        _marketSection(),
                      ],
                    ),
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

  depositInfoContent(BuildContext context) {
    customAlert(
      context: context,
      title: AppLocalizations.of(context)!.depositIntoAccount,
      widget: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.sp),
              border: Border.all(
                color: ThemeOutLineColor.getOutLineColor(context),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  label: AppLocalizations.of(context)!.depositCrypto,
                  fontSize: 15.sp,
                  labelFontWeight: FontWeight.w600,
                ),
                SizedBox(height: 12.sp),
                CustomText(
                  label: AppLocalizations.of(context)!.depositCryptoDetails,
                  fontSize: 14.5.sp,
                  fontColour: ThemeTextOneColor.getTextOneColor(context),
                  labelFontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          SizedBox(height: 15.sp),
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.sp),
              border: Border.all(
                color: ThemeOutLineColor.getOutLineColor(context),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  label: AppLocalizations.of(context)!.express,
                  fontSize: 16.sp,
                  labelFontWeight: FontWeight.w600,
                ),
                SizedBox(height: 12.sp),
                CustomText(
                  label: AppLocalizations.of(context)!.expressDetails,
                  fontSize: 14.5.sp,
                  fontColour: ThemeTextOneColor.getTextOneColor(context),
                  labelFontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
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
              padding: EdgeInsets.symmetric(horizontal: 14.sp),
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
      return _marketList(controller.hotSpotList);
    } else if (controller.selectedIndex == 1) {
      return _marketList(controller.topGainersList);
    } else if (controller.selectedIndex == 2) {
      return _marketList(controller.topLosersList);
    } else {
      return _marketList(controller.newList);
    }
  }

  // =============================
  // MARKET LIST (SAFE)
  // =============================
  Widget _marketList(List list) {
    if (list.isEmpty) {
      return Center(
        child: CustomText(
          label: AppLocalizations.of(context)!.noDataAvailable,
        ),
      );
    }

    controller.hotSpotList.sort(
      (a, b) => double.parse(b.exchange).compareTo(double.parse(a.exchange)),
    );

    controller.topGainersList.sort(
      (a, b) => double.parse(b.exchange).compareTo(double.parse(a.exchange)),
    );

    controller.newList.sort(
      (a, b) => double.parse(b.exchange).compareTo(double.parse(a.exchange)),
    );

    controller.topLosersList.sort(
      (a, b) => double.parse(a.exchange).compareTo(double.parse(b.exchange)),
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: CustomText(
                labelFontWeight: FontWeight.bold,
                label: AppLocalizations.of(context)!.tradingPair,
                fontSize: 15.sp,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
              ),
            ),
            SizedBox(width: 17.sp),
            Expanded(
              flex: 2,
              child: CustomText(
                labelFontWeight: FontWeight.bold,
                label: AppLocalizations.of(context)!.price,
                fontSize: 15.sp,
                align: TextAlign.start,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
              ),
            ),
            Expanded(
              flex: 2,
              child: CustomText(
                labelFontWeight: FontWeight.bold,
                label: AppLocalizations.of(context)!.twentyFourChange,
                fontSize: 15.sp,
                align: TextAlign.end,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.sp),
        ListView.builder(
          itemCount: list.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
                    // rootController.changeTabIndex(2);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.sp),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: RichText(
                            text: TextSpan(
                              text: item.coinOne,
                              style: TextStyle(
                                color: ThemeTextColor.getTextColor(context),
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                              children: [
                                TextSpan(
                                  text: " / ${item.coinTwo}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: ThemeTextOneColor.getTextOneColor(
                                      context,
                                    ),
                                    fontSize: 14.5.sp,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: CustomText(
                                label: item.last,
                                labelFontWeight: FontWeight.bold,
                                align: TextAlign.start,
                                fontSize: 15.sp,
                              ),
                        ),
                        SizedBox(width: 25.sp),

                        /// ✅ FIXED HERE
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.all(10.sp),
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
                                  fontSize: 14.sp,
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
      ],
    );
  }

  Widget dashboardAction(String title, String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(icon, height: 25.5.sp),
          SizedBox(height: 10.sp),
          CustomText(label: title, fontSize: 14.5.sp,labelFontWeight: FontWeight.bold,),
        ],
      ),
    );
  }
}

/// ================= TOTAL VALUE CARD =================

class TotalValueCard extends StatelessWidget {
  final bool isHidden;
  final String amountUSD;
  final String btcValue;
  final VoidCallback onHideTap;
  final VoidCallback onAssetDetailsTap;

  const TotalValueCard({
    super.key,
    required this.isHidden,
    required this.amountUSD,
    required this.btcValue,
    required this.onHideTap,
    required this.onAssetDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12.sp, right: 12.sp, bottom: 12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 5.5.sp,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomText(
                    label: AppLocalizations.of(context)!.totalValue,
                    fontSize: 15.sp,
                    labelFontWeight: FontWeight.w600,
                  ),
                  IconButton(
                    color: ThemeTextOneColor.getTextOneColor(context),
                    icon: Icon(
                      isHidden ? Icons.visibility_off : Icons.visibility,
                      size: 18.sp,
                    ),
                    onPressed: onHideTap,
                  ),
                ],
              ),
              GestureDetector(
                onTap: onAssetDetailsTap,
                child: Row(
                  children: [
                    CustomText(
                      label: AppLocalizations.of(context)!.assetDetails,
                      fontSize: 15.sp,
                      labelFontWeight: FontWeight.bold,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14.sp,
                      color: ThemeTextOneColor.getTextOneColor(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              CustomText(
                label: isHidden ? "****" : "\$$amountUSD",
                fontSize: 16.sp,
                labelFontWeight: FontWeight.bold,
              ),
              SizedBox(width: 10.sp),
              Expanded(
                child: CustomText(
                  label: isHidden ? "**** BTC" : "= $btcValue BTC",
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
