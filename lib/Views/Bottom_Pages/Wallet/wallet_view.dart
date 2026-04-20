import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/deposit/deposit_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/wallet_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/withdraw/withdraw_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/transfer/transfer_view.dart';
import 'package:zayroexchange/Views/Root/root_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class WalletView extends rp.ConsumerStatefulWidget {
  const WalletView({super.key});

  @override
  rp.ConsumerState<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends rp.ConsumerState<WalletView> {
  late WalletController controller;
  late RootController rootController;
  int _lastObservedPageIndex = -1;

  void _refreshWalletData() {
    controller.getWalletDetails(context);
    controller.getFutureWalletDetails(context);
  }

  void _handleRootPageChange() {
    if (!mounted) return;
    final currentPageIndex = rootController.currentPageIndex;
    if (currentPageIndex == 3 && _lastObservedPageIndex != 3) {
      _refreshWalletData();
    }
    _lastObservedPageIndex = currentPageIndex;
  }

  @override
  void initState() {
    super.initState();
    controller = context.read<WalletController>();
    rootController = context.read<RootController>();
    _lastObservedPageIndex = rootController.currentPageIndex;
    rootController.addListener(_handleRootPageChange);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted && rootController.currentPageIndex == 3) {
        _refreshWalletData();
      }
    });
  }

  @override
  void dispose() {
    rootController.removeListener(_handleRootPageChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletController>(
      builder: (context, value, child) {
        controller = value;
        return SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 16.sp,
                    left: 16.sp,
                    right: 16.sp,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ========== ACCOUNT SWITCH PILL ==========
                      Container(
                        height: 6.h, // pill height
                        decoration: BoxDecoration(
                          color: ThemeBackgroundColor.getBackgroundColor(
                            context,
                          ),
                          borderRadius: BorderRadius.circular(15.sp),
                          border: Border.all(
                            color: ThemeOutLineColor.getOutLineColor(context),
                            width: 5.sp,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Spot option
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10.sp),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      controller.isSpotSelected = true;
                                      controller.getWalletDetails(context);
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeInOut,
                                    decoration: BoxDecoration(
                                      color: controller.isSpotSelected
                                          ? ThemeTextFormFillColor.getTextFormFillColor(
                                              context,
                                            )
                                          : ThemeBackgroundColor.getBackgroundColor(
                                              context,
                                            ),
                                      borderRadius: BorderRadius.circular(
                                        15.sp,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      AppLocalizations.of(context)!.spotAccount,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: controller.isSpotSelected
                                            ? ThemeTextColor.getTextColor(
                                                context,
                                              )
                                            : ThemeTextOneColor.getTextOneColor(
                                                context,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Future option
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(10.sp),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      controller.isSpotSelected = false;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeInOut,
                                    decoration: BoxDecoration(
                                      color: !controller.isSpotSelected
                                          ? ThemeTextFormFillColor.getTextFormFillColor(
                                              context,
                                            )
                                          : ThemeBackgroundColor.getBackgroundColor(
                                              context,
                                            ),
                                      borderRadius: BorderRadius.circular(
                                        15.sp,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.futureAccount,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: !controller.isSpotSelected
                                            ? ThemeTextColor.getTextColor(
                                                context,
                                              )
                                            : ThemeTextOneColor.getTextOneColor(
                                                context,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.sp),
                      Expanded(
                        child: Stack(
                          children: [
                            // Spot Page
                            Visibility(
                              visible: controller.isSpotSelected,
                              maintainState: true,
                              maintainAnimation: true,
                              child: ui(context, controller),
                            ),

                            // Future Page (placeholder)
                            Visibility(
                              visible: !controller.isSpotSelected,
                              maintainState: true,
                              maintainAnimation: true,
                              child: futureWalletUi(context, controller),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Loader overlay
                if (controller.isLoading) const CustomLoader(isLoading: true),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget ui(BuildContext context, WalletController controller) {
  return Column(
    children: [
      // ================== BALANCE CARD ==================
      SpotBalanceCard(
        controller: controller,
        usdBalance: controller.totalUsdValue,
        eurBalance: controller.totalEurValue,
        //btcValue: 0,
        currency: 'USD',
      ),

      SizedBox(height: 12.sp),

      // ================== HEADER ==================
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            label: AppLocalizations.of(context)!.assetList,
            fontSize: 16.sp,
            labelFontWeight: FontWeight.w600,
          ),
          Row(
            children: [
              CustomButton(
                width: 22.w,
                height: 4.h,
                borderRadius: BorderRadius.all(Radius.circular(12.sp)),
                label: AppLocalizations.of(context)!.transfer,
                onTap: () {
                  transferAlert(context, controller);
                },
              ),
              SizedBox(width: 12.sp),
              GestureDetector(
                onTap: () {
                  controller.toggleSearch();
                },
                child: SvgPicture.asset(AppThemeIcons.walletSearch(context)),
              ),
            ],
          ),
        ],
      ),
      SizedBox(height: 15.sp),

      // ================== SEARCH FIELD ==================
      if (controller.isSearchVisible) ...[
        SizedBox(height: 2.sp),
        CustomTextFieldWidget(
          hintText: AppLocalizations.of(context)!.searchCoin,
          controller: controller.searchController,
          onChanged: (value) {
            if (value.isEmpty) {
              controller.searchController.clear();
              controller.toggleSearch();
            } else {
              controller.filterCoins(value);
            }
          },
          readOnly: false,
        ),
        SizedBox(height: 18.sp),
      ],

      // ================== COIN LIST ==================
      Expanded(
        child: controller.walletDetailsList.isEmpty
            ? Center(
                child: CustomText(
                  label: controller.isLoading
                      ? AppLocalizations.of(context)!.loadingCoins
                      : AppLocalizations.of(context)!.noCoinsAvailable,
                  fontSize: 15.sp,
                  labelFontWeight: FontWeight.w600,
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  controller.getWalletDetails(context);
                },
                child: ListView.builder(
                  itemCount: controller.walletDetailsList.length,
                  itemBuilder: (_, index) {
                    final coin = controller.walletDetailsList[index];
                    final bool isExpanded = controller.expandedIndex == index;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 15.sp),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.sp),
                          onTap: () => controller.toggleExpand(index),
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 13.sp,
                              right: 13.sp,
                              top: 13.sp,
                              bottom: 15.sp,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  ThemeTextFormFillColor.getTextFormFillColor(
                                    context,
                                  ),
                              borderRadius: BorderRadius.circular(15.sp),
                              border: Border.all(
                                width: 5.sp,
                                color: ThemeOutLineColor.getOutLineColor(
                                  context,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (coin.imageUrl.isNotEmpty)
                                      SvgPicture.network(
                                        coin.imageUrl,
                                        height: 22.sp,
                                      ),
                                    SizedBox(width: 13.sp),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            label: coin.symbol,
                                            fontSize: 15.sp,
                                            labelFontWeight: FontWeight.bold,
                                          ),
                                          SizedBox(height: 6.sp),
                                          CustomText(
                                            label: coin.name,
                                            fontSize: 14.sp,
                                            labelFontWeight: FontWeight.w400,
                                            fontColour:
                                                ThemeTextOneColor.getTextOneColor(
                                                  context,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // chevron with rotation animation
                                    AnimatedRotation(
                                      turns: isExpanded ? 0.5 : 0.0,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: Icon(
                                        Icons.expand_more,
                                        color:
                                            ThemeTextOneColor.getTextOneColor(
                                              context,
                                            ),
                                        size: 20.sp,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 15.sp),
                                Divider(
                                  color: ThemeOutLineColor.getOutLineColor(
                                    context,
                                  ),
                                  thickness: 6.sp,
                                  height: 5.sp,
                                ),
                                // ================= BALANCES =================
                                SizedBox(height: 15.sp),

                                // balances (right aligned)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.balance,
                                          fontColour:
                                              ThemeTextOneColor.getTextOneColor(
                                                context,
                                              ),
                                          fontSize: 14.5.sp,
                                          labelFontWeight: FontWeight.w500,
                                        ),
                                        CustomText(
                                          label: controller.hideBalance
                                              ? '********'
                                              : formatToThree(coin.balance),
                                          fontSize: 14.sp,
                                          align: TextAlign.end,
                                          labelFontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.sp),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.freeBalance,
                                          fontColour:
                                              ThemeTextOneColor.getTextOneColor(
                                                context,
                                              ),
                                          fontSize: 14.5.sp,
                                          labelFontWeight: FontWeight.w500,
                                        ),
                                        CustomText(
                                          label: controller.hideBalance
                                              ? '********'
                                              : formatToThree(coin.freeBalance),
                                          fontSize: 14.sp,
                                          align: TextAlign.end,
                                          labelFontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.sp),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.lockedBalance,
                                          fontColour:
                                              ThemeTextOneColor.getTextOneColor(
                                                context,
                                              ),
                                          fontSize: 14.5.sp,
                                          labelFontWeight: FontWeight.w500,
                                        ),
                                        CustomText(
                                          label: controller.hideBalance
                                              ? '********'
                                              : formatToThree(
                                                  coin.escrowBalance,
                                                ),
                                          fontSize: 14.sp,
                                          align: TextAlign.end,
                                          labelFontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                isExpanded
                                    ? SizedBox(height: 15.sp)
                                    : SizedBox(),

                                // animated expanding area (buttons)
                                // AnimatedSize handles height transitions, AnimatedOpacity fades content in/out.
                                ConstrainedBox(
                                  constraints: isExpanded
                                      ? BoxConstraints()
                                      : const BoxConstraints(maxHeight: 0),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 12.sp),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Deposit
                                        if (coin.activeDeposit == 1)
                                          Expanded(
                                            child: _actionButton(
                                              AppLocalizations.of(
                                                context,
                                              )!.deposit,
                                              Color(0xffF6465D),
                                              () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DepositView(
                                                        coinName: coin.symbol,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),

                                        SizedBox(width: 12.sp),
                                        if (coin.activeWithdraw == 1)
                                          // Withdraw
                                          Expanded(
                                            child: _actionButton(
                                              AppLocalizations.of(
                                                context,
                                              )!.withdraw,
                                              Color(0xff2EBD85),
                                              () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      WithdrawView(
                                                        coinName: coin.symbol,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    ],
  );
}

transferAlert(BuildContext context, WalletController controller) {
  return customAlert(
    context: context,
    title: AppLocalizations.of(context)!.transfer,
    onDismiss: () {
      print("ONDISMISS");
      controller.getWalletDetails(context);
      controller.getFutureWalletDetails(context);
    },
    widget: TransferView(type: "wallet"),
  );
}

Widget futureWalletUi(BuildContext context, WalletController controller) {
  return Column(
    children: [
      // ================== FUTURE BALANCE CARD ==================
      FutureBalanceCard(
        controller: controller,
        usdBalance: controller.totalFutureUsdValue,
        btcBalance: controller.totalFutureBtcValue,
        currency: 'USD',
      ),

      // ================== HEADER ==================
      SizedBox(height: 12.sp),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            label: AppLocalizations.of(context)!.futureAccount,
            fontSize: 16.sp,
            labelFontWeight: FontWeight.w600,
          ),
          Row(
            children: [
              SizedBox(
                width: 30.w,
                child: CustomButton(
                  label: AppLocalizations.of(context)!.transfer,
                  onTap: () {
                    transferAlert(context, controller);
                  },
                ),
              ),
              SizedBox(width: 12.sp),
              GestureDetector(
                onTap: () {
                  controller.futureToggleSearch();
                },
                child: SvgPicture.asset(AppThemeIcons.walletSearch(context)),
              ),
            ],
          ),
        ],
      ),
      SizedBox(height: 15.sp),

      // ================== SEARCH ==================
      if (controller.isFutureSearchVisible) ...[
        SizedBox(height: 2.sp),
        CustomTextFieldWidget(
          hintText: AppLocalizations.of(context)!.searchCoin,
          controller: controller.futureSearchController,
          onChanged: (value) {
            if (value.isEmpty) {
              controller.futureSearchController.clear();
              controller.futureToggleSearch();
            } else {
              controller.futureFilterCoins(value);
            }
          },
          readOnly: false,
        ),
        SizedBox(height: 18.sp),
      ],

      // ================== COIN LIST ==================
      Expanded(
        child: controller.futureWalletList.isEmpty
            ? Center(
                child: CustomText(
                  label: controller.isLoading
                      ? AppLocalizations.of(context)!.loadingCoins
                      : AppLocalizations.of(context)!.noCoinsAvailable,
                  fontSize: 15.sp,
                  labelFontWeight: FontWeight.w600,
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await controller.getFutureWalletDetails(context);
                },
                child: ListView.builder(
                  itemCount: controller.futureWalletList.length,
                  itemBuilder: (_, index) {
                    final coin = controller.futureWalletList[index];

                    return Padding(
                      padding: EdgeInsets.only(bottom: 15.sp),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.sp),
                        onTap: () => controller.toggleExpand(index),
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 13.sp,
                            right: 13.sp,
                            top: 13.sp,
                            bottom: 15.sp,
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
                            children: [
                              // ================= COIN HEADER =================
                              Row(
                                children: [
                                  if (coin.imageUrl.isNotEmpty)
                                    SvgPicture.network(
                                      coin.imageUrl,
                                      height: 22.sp,
                                    ),
                                  SizedBox(width: 13.sp),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          label: coin.symbol,
                                          fontSize: 15.sp,
                                          labelFontWeight: FontWeight.bold,
                                        ),
                                        SizedBox(height: 6.sp),
                                        CustomText(
                                          label: coin.name,
                                          fontSize: 14.sp,
                                          labelFontWeight: FontWeight.w400,
                                          fontColour:
                                              ThemeTextOneColor.getTextOneColor(
                                                context,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 12.sp),

                              Divider(
                                color: ThemeOutLineColor.getOutLineColor(
                                  context,
                                ),
                                thickness: 6.sp,
                                height: 5.sp,
                              ),
                              // ================= BALANCES =================
                              SizedBox(height: 15.sp),
                              _futureRow(
                                context,
                                AppLocalizations.of(context)!.balance,
                                controller.hideBalance
                                    ? '********'
                                    : formatToThree(coin.totalBalance),
                              ),
                              SizedBox(height: 15.sp),
                              _futureRow(
                                context,
                                AppLocalizations.of(context)!.lockedBalance,
                                controller.hideBalance
                                    ? '********'
                                    : formatToThree(coin.escrowBalance),
                              ),

                              /*        // ================= ACTIONS =================
                        AnimatedSize(
                          duration:
                          const Duration(milliseconds: 300),
                          child: isExpanded
                              ? Padding(
                            padding:
                            EdgeInsets.only(top: 14.sp),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _futureButton(
                                    context,
                                    label:
                                    AppLocalizations.of(
                                        context)!
                                        .transfer,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error,
                                    onTap: () {},
                                  ),
                                ),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: _futureButton(
                                    context,
                                    label:
                                    AppLocalizations.of(
                                        context)!
                                        .copy,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary,
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          )
                              : const SizedBox(),
                        ),*/
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    ],
  );
}

Widget _futureRow(BuildContext context, String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      CustomText(
        label: label,
        fontColour: ThemeTextOneColor.getTextOneColor(context),
        fontSize: 14.5.sp,
        labelFontWeight: FontWeight.w500,
      ),
      CustomText(
        label: value,
        fontSize: 14.sp,
        align: TextAlign.end,
        labelFontWeight: FontWeight.bold,
      ),
    ],
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
        borderRadius: BorderRadius.circular(15.sp),
      ),
      child: CustomText(
        label: label,
        labelFontWeight: FontWeight.w600,
        fontColour: Colors.white,
      ),
    ),
  );
}
// ================== HELPERS ==================

String formatToThree(String value) {
  if (value.isEmpty) return '0.0000';
  final double number = double.tryParse(value) ?? 0.0;
  return number.toStringAsFixed(6);
}

// ================== SPOT BALANCE CARD WIDGET ==================

class SpotBalanceCard extends StatefulWidget {
  final WalletController controller;
  final double usdBalance;
  final double eurBalance;
  //final double btcValue;
  final String currency;

  const SpotBalanceCard({
    super.key,
    required this.controller,
    required this.usdBalance,
    required this.eurBalance,
    //required this.btcValue,
    this.currency = 'USD',
  });

  @override
  State<SpotBalanceCard> createState() => _SpotBalanceCardState();
}

class _SpotBalanceCardState extends State<SpotBalanceCard> {
  late String _selectedCurrency;
  final Map<String, String> _currencySymbols = {'USD': r'$', 'EUR': '€'};

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.currency.isNotEmpty ? widget.currency : 'USD';
  }

  @override
  void didUpdateWidget(covariant SpotBalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if controller instance changed, ensure selected currency persists or resets as needed
    if (oldWidget.currency != widget.currency) {
      _selectedCurrency = widget.currency;
    }
  }

  String _formatAmount(double value) => value.toStringAsFixed(2);

  double _getCurrentAmount() {
    if (_selectedCurrency == 'EUR') return widget.eurBalance;
    return widget.usdBalance;
  }

  @override
  Widget build(BuildContext context) {
    // read hide state from controller (this will rebuild when controller notifies)
    final bool hide = widget.controller.hideBalance;
    final String symbol = _currencySymbols[_selectedCurrency] ?? '';
    final double amount = _getCurrentAmount();

    return SizedBox(
      height: 20.h,
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset(
            AppThemeIcons.walletOverviewContent(context),
            fit: BoxFit.cover,
            width: 100.w,
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(left: 15.sp, top: 1.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE + VISIBILITY TOGGLE
                  Row(
                    children: [
                      CustomText(
                        label: AppLocalizations.of(context)!.availableBalance,
                        fontSize: 16.sp,
                        fontColour: Colors.white,
                        labelFontWeight: FontWeight.bold,
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          hide
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // toggle via controller so whole page updates
                          widget.controller.setHideBalance(!hide);
                        },
                      ),
                    ],
                  ),

                  // AMOUNT + CURRENCY DROPDOWN
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// AMOUNT
                      Text(
                        hide ? '********' : '\$${_formatAmount(amount)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12.sp),

                      /// CAPSULE DROPDOWN
                      Container(
                        height: 4.5.h,
                        padding: EdgeInsets.symmetric(horizontal: 14.sp),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2A38), // dark capsule color
                          borderRadius: BorderRadius.circular(10.sp),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1.2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCurrency,
                            isDense: true,
                            iconSize: 16.sp,
                            dropdownColor: const Color(0xFF1E2A38),
                            borderRadius: BorderRadius.circular(10.sp),
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18.sp,
                              color: Colors.white,
                            ),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            items: const ['USD', 'EUR'].map((code) {
                              return DropdownMenuItem<String>(
                                value: code,
                                child: Text(
                                  code,
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _selectedCurrency = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== FUTURE BALANCE CARD WIDGET ==================

class FutureBalanceCard extends StatefulWidget {
  final WalletController controller;
  final double usdBalance;
  final double btcBalance;
  final String currency;

  const FutureBalanceCard({
    super.key,
    required this.controller,
    required this.usdBalance,
    required this.btcBalance,
    this.currency = 'USD',
  });

  @override
  State<FutureBalanceCard> createState() => _FutureBalanceCardState();
}

class _FutureBalanceCardState extends State<FutureBalanceCard> {
  late String _selectedCurrency;

  final Map<String, String> _currencySymbols = {'USD': r'$', 'BTC': '₿'};

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.currency.isNotEmpty ? widget.currency : 'USD';
  }

  @override
  void didUpdateWidget(covariant FutureBalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currency != widget.currency) {
      _selectedCurrency = widget.currency;
    }
  }

  String _formatAmount(double value) => _selectedCurrency == 'BTC'
      ? value.toStringAsFixed(6)
      : value.toStringAsFixed(2);

  double _getCurrentAmount() {
    if (_selectedCurrency == 'BTC') return widget.btcBalance;
    return widget.usdBalance;
  }

  @override
  Widget build(BuildContext context) {
    final bool hide = widget.controller.hideBalance;
    final String symbol = _currencySymbols[_selectedCurrency] ?? '';
    final double amount = _getCurrentAmount();

    return SizedBox(
      height: 20.h,
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset(
            AppThemeIcons.walletOverviewContent(context),
            fit: BoxFit.cover,
            width: 100.w,
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(left: 15.sp, top: 3.5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= TITLE + HIDE =================
                  Row(
                    children: [
                      CustomText(
                        label: AppLocalizations.of(context)!.futureAccount,
                        fontSize: 16.sp,
                        fontColour: Colors.white,
                        labelFontWeight: FontWeight.bold,
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          hide
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          widget.controller.setHideBalance(!hide);
                        },
                      ),
                    ],
                  ),

                  // ================= AMOUNT + DROPDOWN =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomText(
                        label: hide
                            ? '********'
                            : '$symbol ${_formatAmount(amount)}',
                        fontSize: 16.5.sp,
                        fontColour: Colors.white,
                        labelFontWeight: FontWeight.bold,
                      ),
                      SizedBox(width: 12.sp),
                      Container(
                        height: 4.5.h,
                        padding: EdgeInsets.symmetric(horizontal: 14.sp),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2A38), // dark capsule color
                          borderRadius: BorderRadius.circular(10.sp),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1.2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCurrency,
                            isDense: true,
                            iconSize: 16.sp,
                            dropdownColor:
                                ThemeTextFormFillColor.getTextFormFillColor(
                                  context,
                                ),
                            borderRadius: BorderRadius.circular(10.sp),
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18.sp,
                              color: Colors.white,
                            ),

                            items: const ['USD', 'BTC'].map((code) {
                              return DropdownMenuItem<String>(
                                value: code,
                                child: Center(
                                  child: CustomText(
                                    label: code,
                                    fontColour: Colors.white,
                                    labelFontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _selectedCurrency = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
