import 'dart:math' as math;
import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_otp_field.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/withdraw/withdraw_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class WithdrawView extends StatefulWidget {
  final String coinName;

  const WithdrawView({super.key, required this.coinName});

  @override
  State<WithdrawView> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends State<WithdrawView> {
  WithdrawController controller = WithdrawController();

  final withdrawKey = GlobalKey<FormState>();

  final int _index = 0;
  static const List<int> _percentages = [0, 25, 50, 75, 100];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      showWithdrawInfoDialog(context);
      controller.isConfirmWithdrawCalled = false;
      controller.isTermsAccepted = false;
      controller.addressController.clear();
      controller.resetPercentage(0);
      WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
      _initializeCoinSelection();
    });
  }

  void _notify() {
    final pct = _percentages[_index];
    final double totalBalance =
        double.tryParse(controller.freeBalanceStr.replaceAll(',', '')) ?? 0.0;

    final double amount = totalBalance * pct / 100.0;

    if (mounted) {
      controller.withdrawAmountController.text = amount == 0.0
          ? ''
          : amount.toString();
    }
  }

  Future<void> _initializeCoinSelection() async {
    try {
      debugPrint("Coin init -> ${widget.coinName}");
      controller.resetSelection();
      if (!mounted) return;
      await controller.getCoins(context);
      if (!mounted) return;

      final target = widget.coinName.toLowerCase();
      final matchIndex = controller.coinList.indexWhere((coin) {
        final symbol = coin.symbol.toLowerCase();
        final name = coin.name.toLowerCase();
        return symbol == target || name == target;
      });
      if (matchIndex == -1) return;

      final coin = controller.coinList[matchIndex];
      controller.selectCoin(coin);
      if (coin.network.isNotEmpty) controller.selectNetwork(coin.network.first);
      if (!mounted) return;
      await controller.getWithdrawDetails(context, widget.coinName);

      if (mounted) _notify(); // re-notify after details load
    } catch (e, st) {
      debugPrint("Error initializing coin selection: $e\n$st");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WithdrawController>(
      builder: (context, value, child) {
        controller = value;
        final String coinNameToShow =
            controller.selectedCoinSymbol ?? widget.coinName; // fallback

        return Scaffold(
          body: Stack(
            children: [
              CustomTotalPageFormat(
                appBarTitle: AppLocalizations.of(context)!.withdraw,
                showBackButton: true,
                child: Form(
                  key: withdrawKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.sp),
                      // ===== Select Crypto =====
                      _buildSectionLabel(
                        context: context,
                        title: AppLocalizations.of(context)!.selectCrypto,
                      ),
                      SizedBox(height: 10.sp),
                      _buildSelectCryptoField(context, controller),
                      SizedBox(height: 15.sp),

                      // ===== Select Network =====
                      _buildSectionLabel(
                        context: context,
                        title: AppLocalizations.of(context)!.selectNetwork,
                      ),
                      SizedBox(height: 10.sp),
                      _buildSelectNetworkField(context, controller),
                      SizedBox(height: 15.sp),

                      CustomTextFieldWidget(
                        hintText: AppLocalizations.of(context)!.enterAddress,
                        line: 1,
                        label: AppLocalizations.of(context)!.withdrawAddress,
                        controller: controller.addressController,
                        onValidate: (val) {
                          if (val.toString().isEmpty) {
                            return AppLocalizations.of(
                              context,
                            )!.withdrawAddressRequired;
                          }
                          return null;
                        },
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _copy(controller.addressController.text);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 12.sp),
                            child: SvgPicture.asset(
                              AppBasicIcons.copy,
                              height: 18.sp,
                            ),
                          ),
                        ),
                        onChanged: (value) {},
                        readOnly: false,
                      ),
                      SizedBox(height: 15.sp),

                      CustomTextFieldWidget(
                        hintText: AppLocalizations.of(
                          context,
                        )!.enterWithdrawAmount,
                        line: 1,
                        label: AppLocalizations.of(context)!.withdrawAmount,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        controller: controller.withdrawAmountController,
                        onChanged: (value) {
                          // keep controller totals updated live

                          controller.resetPercentage(0);

                          controller.setTotalWithdrawAmount();
                        },
                        onValidate: (val) {
                          if (val.toString().isEmpty) {
                            return AppLocalizations.of(
                              context,
                            )!.withdrawAmountRequired;
                          } else if (double.parse(
                                controller.availableBalance.toString(),
                              ) <
                              double.parse(val.toString())) {
                            return "${AppLocalizations.of(context)!.yourAvailableBalance} ${controller.availableBalance} ${controller.selectedCoin?.symbol}";
                          } else if (double.parse(
                                controller.minWithdrawLimit.toString(),
                              ) >
                              double.parse(val.toString())) {
                            return "${AppLocalizations.of(context)!.minWithdrawLimit} ${controller.minWithdrawLimit} ${controller.selectedCoin?.symbol}";
                          } else if (double.parse(
                                controller.maxWithdrawLimit.toString(),
                              ) <
                              double.parse(val.toString())) {
                            return "${AppLocalizations.of(context)!.maxWithdrawLimit} ${controller.maxWithdrawLimit} ${controller.selectedCoin?.symbol}";
                          }
                          return null;
                        },
                        readOnly: false,
                      ),
                      SizedBox(height: 15.sp),

                      if(controller.selectedCoin != null)
                      PercentageWithdrawPicker4(
                        totalBalance:
                            double.tryParse(
                              controller.freeBalanceStr.replaceAll(',', ''),
                            ) ??
                            0.0,
                        initialIndex: controller.selectedPercentage == 0
                            ? 0
                            : // ensure index falls into available options (0..4)
                              (WithdrawController.percentages.contains(
                                    controller.selectedPercentage,
                                  )
                                  ? WithdrawController.percentages.indexOf(
                                      controller.selectedPercentage,
                                    )
                                  : 0),
                        onChanged: (percent, amount) async {
                          if (percent > 0) {
                            controller.setSelectedPercentage(percent);
                            controller.setPercentageAmount(percent);
                            controller.setTotalWithdrawAmount();
                            debugPrint("Selected: $percent% | Amount: $amount");
                          }
                        },
                      ),

                      SizedBox(height: 15.sp),
                      controller.isLoading == true
                          ? CustomProgressDialog()
                          : CustomButton(
                              label: AppLocalizations.of(context)!.submit,
                              onTap: () async {
                                if (withdrawKey.currentState!.validate()) {
                                  controller.getTransactionStatus(context).whenComplete(() {
                                    print('Cponsfdm ${controller.verified2fa}');
                                    if (controller.verified2fa == '0') {
                                      controller.withDrawVerifyOtp(
                                        context,
                                        coinNameToShow,
                                      );
                                    } else {
                                      controller.withDrawVerifyOtp(context, coinNameToShow).whenComplete(() {
                                        if(controller.isConfirmWithdrawCalled == false){
                                          return;
                                        }
                                        customAlert(
                                          context: context,
                                          title: AppLocalizations.of(
                                            context,
                                          )!.withdrawalConfirmation,
                                          widget: Consumer<WithdrawController>(
                                            builder: (context, value, child)  {
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  CustomText(
                                                    label: value.withdrawVerifyMessage,
                                                    fontSize: 15.sp,
                                                    labelFontWeight: FontWeight.w200,
                                                    lineSpacing: 1.5,
                                                  ),
                                                  SizedBox(height: 15.sp),
                                                  CustomText(
                                                    label: AppLocalizations.of(
                                                      context,
                                                    )!.areYouSureWithdrawal,
                                                    labelFontWeight:
                                                        FontWeight.w400,
                                                    fontSize: 15.sp,
                                                    align: TextAlign.center,
                                                  ),
                                                  SizedBox(height: 15.sp),
                                                  PinField(
                                                    controller:
                                                    value.codeController,
                                                    validator: (val) =>
                                                        AppValidations()
                                                            .validateOtp(
                                                              context,
                                                              val ?? "",
                                                            ),
                                                  ),

                                                  SizedBox(height: 15.sp),
                                                  value.isLoading == true
                                                      ? CustomProgressDialog()
                                                      : Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Expanded(
                                                              child: CustomButton(
                                                                label:
                                                                    AppLocalizations.of(
                                                                      context,
                                                                    )!.confirm,
                                                                onTap: () async {
                                                                  print("click ");

                                                                  value
                                                                      .withDrawConfirm(
                                                                        context,
                                                                        coinNameToShow,
                                                                      )
                                                                      .whenComplete(() {

                                                                        // controller.getWithdrawDetails(
                                                                        //   context,
                                                                        //   coinNameToShow,
                                                                        // );
                                                                      });
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(width: 10.sp),
                                                            Expanded(
                                                              child: CancelButton(
                                                                label:
                                                                    AppLocalizations.of(
                                                                      context,
                                                                    )!.cancel,
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                ],
                                              );
                                            }
                                          ),
                                        );
                                      });
                                    }
                                  });
                                }
                              },
                            ),
                      SizedBox(height: 18.sp),
                      _withdrawDetails(
                        context: context,
                        title: AppLocalizations.of(context)!.minWithdraw,
                        subTitle:
                            "${controller.minimumWithdraw} $coinNameToShow",
                      ),

                      SizedBox(height: 15.sp),
                      _withdrawDetails(
                        context: context,
                        title: AppLocalizations.of(context)!.maxWithdraw,
                        subTitle:
                            "${controller.maximumWithdraw} $coinNameToShow",
                      ),

                      SizedBox(height: 15.sp),
                      _withdrawDetails(
                        context: context,
                        title: AppLocalizations.of(context)!.perDayWithdraw,
                        subTitle:
                            "${controller.perDayWithdraw} $coinNameToShow",
                      ),

                      SizedBox(height: 15.sp),
                      _withdrawDetails(
                        context: context,
                        title: AppLocalizations.of(context)!.withdrawFee,
                        subTitle:
                            "${controller.minimumWithdrawFee}${controller.withdrawFeeType.toLowerCase() == "fixed" ? coinNameToShow : controller.minimumWithdrawFee.isNotEmpty ? "%" : ""}",
                      ),

                      SizedBox(height: 15.sp),

                      _withdrawDetails(
                        context: context,
                        title: AppLocalizations.of(context)!.availableBalance,
                        subTitle: controller.freeBalanceStr,
                      ),
                    ],
                  ),
                ),
              ),

              /// Loader overlay
              if (controller.isLoading) const CustomLoader(isLoading: true),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  //  SMALL HELPER WIDGET BUILDERS
  // ---------------------------------------------------------------------------

  void showWithdrawInfoDialog(BuildContext context) {
    customAlert(
      context: context,
      onTapBack: () {
        Navigator.of(context).pop();
        // if (!controller.isTermsAccepted) {
        //   CustomAnimationToast.show(
        //     context: context,
        //     message: AppLocalizations.of(context)!.pleaseAcceptTerms,
        //     type: ToastType.error,
        //   );
        // } else {
        //   CustomAnimationToast.show(
        //     context: context,
        //     message: AppLocalizations.of(context)!.confirm,
        //     type: ToastType.error,
        //   );
        // }
      },
      title: AppLocalizations.of(context)!.importantNotice,
      widget: depositNoticeContent(context),
    );
  }

  Widget depositNoticeContent(BuildContext context) {
    final double boxSize = 20.0;

    return Consumer<WithdrawController>(
      builder: (context, value, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ================= NOTICE CARD =================
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  label: AppLocalizations.of(context)!.withdrawingFirstContent,
                  fontSize: 14.5.sp,
                  labelFontWeight: FontWeight.w500,
                ),
                SizedBox(height: 14.sp),

                _noticePoint(
                  context,
                  AppLocalizations.of(context)!.withdrawingSecondContent,
                ),
                _noticePoint(
                  context,
                  AppLocalizations.of(context)!.withdrawingThirdContent,
                ),
                _noticePoint(
                  context,
                  AppLocalizations.of(context)!.withdrawingFourthContent,
                ),
              ],
            ),

            SizedBox(height: 16.sp),

            /// ================= AGREEMENT TEXT =================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    value.toggleTermsAccepted();
                  },
                  child: Container(
                    width: boxSize,
                    height: boxSize,
                    decoration: BoxDecoration(
                      color: controller.isTermsAccepted
                          ? ThemePrimaryColor.getPrimaryColor(context)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: controller.isTermsAccepted
                            ? ThemeOutLineColor.getOutLineColor(context)
                            : Colors.grey.shade500,
                        width: 2.5.sp,
                      ),
                    ),
                    child: value.isTermsAccepted
                        ? Icon(
                            Icons.check,
                            size: boxSize - 6,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),

                SizedBox(width: 8),

                Flexible(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: ThemeTextOneColor.getTextOneColor(context),
                        fontSize: 14.sp,
                      ),
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)!.acknowledge,
                        ),
                        TextSpan(
                          text: AppLocalizations.of(
                            context,
                          )!.acknowledgeContent,
                          style: TextStyle(
                            color:
                                ThemeInversePrimaryColor.getInversePrimaryColor(
                                  context,
                                ),
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // controller.openTermsOfService(context);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 18.sp),

            /// ================= CONFIRM BUTTON =================
            controller.isLoading == true
                ? CustomProgressDialog()
                : CustomButton(
                    label: AppLocalizations.of(context)!.confirm,
                    height: 4.5.h,
                    onTap: () async {
                      if (!controller.isTermsAccepted) {
                        CustomAnimationToast.show(
                          context: context,
                          message: AppLocalizations.of(
                            context,
                          )!.pleaseAcceptTerms,
                          type: ToastType.error,
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
          ],
        );
      },
    );
  }

  Widget _noticePoint(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label: "•  ",
            fontSize: 16.sp,
            labelFontWeight: FontWeight.bold,
          ),
          Expanded(
            child: CustomText(
              label: text,
              fontSize: 14.sp,
              fontColour: ThemeTextOneColor.getTextOneColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel({
    required BuildContext context,
    required String title,
  }) {
    return CustomText(
      label: title,
      fontSize: 14.5.sp,
      labelFontWeight: FontWeight.bold,
      fontColour: ThemeTextColor.getTextColor(context),
    );
  }

  Widget _withdrawDetails({
    required BuildContext context,
    required String title,
    required String subTitle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          label: title,
          fontColour: ThemeTextOneColor.getTextOneColor(context),
          fontSize: 14.5.sp,
          labelFontWeight: FontWeight.w500,
        ),
        CustomText(
          label: subTitle.isEmpty ? "" : subTitle,
          fontSize: 14.sp,
          align: TextAlign.end,
          labelFontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    CustomAnimationToast.show(
      message: AppLocalizations.of(context)!.copiedSuccessfully,
      type: ToastType.success,
      context: context,
    );
  }

  /// Crypto selection field
  Widget _buildSelectCryptoField(
    BuildContext context,
    WithdrawController controller,
  ) {
    return GestureDetector(
      onTap: () => _openCoinSheet(context, controller),
      child: Container(
        height: 5.h,
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: ThemeTextFormFillColor.getTextFormFillColor(context),
          borderRadius: BorderRadius.circular(15.sp),
          border: Border.all(
            color: ThemeOutLineColor.getOutLineColor(context),
            width: 4.sp,
          ),
        ),
        child: Row(
          children: [
            // Coin icon
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child:
                  (controller.selectedCoin != null &&
                      controller.selectedCoin!.imageUrl.isNotEmpty)
                  ? SvgPicture.network(
                      controller.selectedCoin!.imageUrl,
                      key: ValueKey(controller.selectedCoin!.id),
                      height: 22.sp,
                      width: 22.sp,
                    )
                  : SizedBox(
                      key: const ValueKey('empty-coin'),
                      width: 22.sp,
                      height: 22.sp,
                    ),
            ),
            SizedBox(width: 10.sp),

            // Coin text
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: CustomText(
                    key: ValueKey(
                      controller.selectedCoin?.symbol ??
                          AppLocalizations.of(context)!.selectCrypto,
                    ),
                    label:
                        controller.selectedCoin?.symbol ??
                        AppLocalizations.of(context)!.selectCrypto,
                    fontSize: 15.sp,
                    labelFontWeight: FontWeight.w800,
                    fontColour: controller.selectedCoin == null
                        ? ThemeTextOneColor.getTextOneColor(context)
                        : ThemeTextColor.getTextColor(context),
                  ),
                ),
              ),
            ),

            SvgPicture.asset(
              AppThemeIcons.arrowDown(context),
              width: 10.sp,
              height: 10.sp,
            ),
          ],
        ),
      ),
    );
  }

  /// Network selection field
  Widget _buildSelectNetworkField(
    BuildContext context,
    WithdrawController controller,
  ) {
    return GestureDetector(
      onTap: () {
        if (controller.selectedCoin == null) {
          CustomAnimationToast.show(
            message: AppLocalizations.of(context)!.pleaseSelectCryptoFirst,
            context: context,
            type: ToastType.error,
          );
          return;
        }
        _openNetworkSheet(context, controller);
      },
      child: Container(
        height: 5.h,
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: ThemeTextFormFillColor.getTextFormFillColor(context),
          borderRadius: BorderRadius.circular(15.sp),
          border: Border.all(
            color: ThemeOutLineColor.getOutLineColor(context),
            width: 4.sp,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: CustomText(
                    key: ValueKey(controller.selectedNetwork),
                    label: controller.selectedNetwork.isNotEmpty
                        ? controller.selectedNetwork
                        : AppLocalizations.of(context)!.selectNetwork,
                    fontSize: 15.sp,
                    labelFontWeight: FontWeight.w800,
                    fontColour: (controller.selectedNetwork == "")
                        ? ThemeTextOneColor.getTextOneColor(context)
                        : ThemeTextColor.getTextColor(context),
                  ),
                ),
              ),
            ),
            SvgPicture.asset(
              AppThemeIcons.arrowDown(context),
              width: 10.sp,
              height: 10.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  BOTTOM SHEETS
  // ---------------------------------------------------------------------------

  /// COIN BOTTOM SHEET
  void _openCoinSheet(BuildContext context, WithdrawController controller) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.sp),
                Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        label: AppLocalizations.of(context)!.selectCrypto,
                        labelFontWeight: FontWeight.bold,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
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
                  child: controller.coinList.isEmpty
                      ? Center(
                          child: CustomText(
                            label: AppLocalizations.of(
                              context,
                            )!.noCoinsAvailable,
                            fontSize: 15.sp,
                            labelFontWeight: FontWeight.bold,
                            fontColour: ThemeTextColor.getTextColor(context),
                          ),
                        )
                      : ListView.builder(
                          itemCount: controller.coinList.length,
                          itemBuilder: (_, index) {
                            final coin = controller.coinList[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(10.sp),
                              onTap: () async {
                                if(coin.activeWithdraw == 0){
                                  CustomAnimationToast.show(
                                    message: AppLocalizations.of(context)!.withdrawalNotAvailableForThisCrypto,
                                    context: context,
                                    type: ToastType.error,
                                  );
                                  controller.resetPercentage(0);
                                  controller.resetSelection();
                                  Navigator.pop(sheetContext);
                                  return;

                                }else{
                                  controller.resetPercentage(0);
                                  controller.selectCoin(coin);
                                  Navigator.pop(sheetContext);

                                  bool isSuccess = await controller
                                      .getWithdrawDetails(context, coin.symbol);

                                  if (isSuccess && coin.network.isNotEmpty) {
                                    _openNetworkSheet(context, controller);
                                  }
                                }

                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 13.sp,
                                  right: 13.sp,
                                  top: 13.sp,
                                  bottom: 10.sp,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    (coin.imageUrl.isNotEmpty)
                                        ? SvgPicture.network(
                                            coin.imageUrl,
                                            height: 20.sp,
                                          )
                                        : SizedBox(width: 10.sp, height: 20),

                                    SizedBox(width: 10.sp),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            label: coin.symbol,
                                            maxLines: 1,
                                          ),
                                          CustomText(
                                            label: coin.name,
                                            fontColour:
                                                ThemeTextOneColor.getTextOneColor(
                                                  context,
                                                ),
                                            labelFontWeight: FontWeight.w500,
                                          ),
                                        ],
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

  /// NETWORK BOTTOM SHEET
  void _openNetworkSheet(BuildContext context, WithdrawController controller) {
    if (controller.selectedCoin == null) {
      CustomAnimationToast.show(
        message: AppLocalizations.of(context)!.pleaseSelectCryptoFirst,
        context: context,
        type: ToastType.error,
      );
      return;
    }

    final networks = controller.selectedCoin!.network;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15.sp),
                Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        label: AppLocalizations.of(context)!.selectNetwork,
                        labelFontWeight: FontWeight.bold,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
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
                  child: ListView.builder(
                    itemCount: networks.length,
                    itemBuilder: (_, index) {
                      final net = networks[index];
                      return GestureDetector(
                        onTap: () async {
                          controller.selectNetwork(net);
                          Navigator.pop(sheetContext);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 13.sp,
                            right: 13.sp,
                            top: 13.sp,
                            bottom: 10.sp,
                          ),
                          child: CustomText(
                            label: net,
                            labelFontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 15.sp),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ---------------------
/// Percentage picker widget
/// ---------------------
class PercentageWithdrawPicker4 extends StatefulWidget {
  final double totalBalance;
  final int initialIndex; // 0..4
  final void Function(int percent, double amount)? onChanged;
  final Color? backgroundColor;

  const PercentageWithdrawPicker4({
    super.key,
    required this.totalBalance,
    this.initialIndex = 0,
    this.onChanged,
    this.backgroundColor,
  });

  @override
  _PercentageWithdrawPicker4State createState() =>
      _PercentageWithdrawPicker4State();
}

class _PercentageWithdrawPicker4State extends State<PercentageWithdrawPicker4> {
  static const List<int> _percentages = [0, 25, 50, 75, 100];
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, _percentages.length - 1).toInt();
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  void _notify() {
    final int pct = _percentages[_index];
    final double amount = widget.totalBalance * pct / 100.0;
    widget.onChanged?.call(pct, amount);
  }

  void _setIndex(int newIndex) {
    final int safe = newIndex.clamp(0, _percentages.length - 1).toInt();
    if (safe == _index) return;
    setState(() => _index = safe);
    _notify();
  }

  @override
  void didUpdateWidget(covariant PercentageWithdrawPicker4 oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialIndex != widget.initialIndex) {
      final int newIndex = widget.initialIndex
          .clamp(0, _percentages.length - 1)
          .toInt();

      if (newIndex != _index) {
        setState(() {
          _index = newIndex;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color active = ThemeInversePrimaryColor.getInversePrimaryColor(
      context,
    );
    final Color inactive = ThemeTextOneColor.getTextOneColor(context);
    final Color borderactive = ThemeOutLineColor.getOutLineColor(context);
    final Color bg =
        widget.backgroundColor ??
        ThemeTextFormFillColor.getTextFormFillColor(context);

    const double trackHeight = 4;
    const double diamondSize = 15;
    const double topOffset = 15;
    const double overallHeight = 40;

    return SizedBox(
      height: overallHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double fullW = constraints.maxWidth;
          final int last = _percentages.length - 1;
          final double usableWidth = fullW - diamondSize;
          double markerCenterX(int i) =>
              (i / last) * usableWidth + (diamondSize / 2);

          final double activeWidth = (markerCenterX(_index) - markerCenterX(0))
              .clamp(0.0, fullW);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: topOffset,
                child: Container(
                  height: trackHeight,
                  decoration: BoxDecoration(
                    color: borderactive,
                    borderRadius: BorderRadius.circular(5.sp),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                left: markerCenterX(0),
                top: topOffset,
                width: activeWidth,
                height: trackHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: active,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              for (int i = 0; i < _percentages.length; i++)
                Positioned(
                  left: (markerCenterX(i) - (diamondSize / 2)).clamp(
                    0.0,
                    fullW,
                  ),
                  top: topOffset - (diamondSize / 2),
                  child: InkWell(
                    onTap: () => _setIndex(i),
                    borderRadius: BorderRadius.circular(40),
                    child: _OutlineOnlyDiamond(
                      size: diamondSize,
                      borderColor: i <= _index ? active : inactive,
                      strokeWidth: i == _index ? 2.4 : 1.6,
                      backgroundColor: bg,
                    ),
                  ),
                ),

              Positioned.fill(
                child: Center(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 0,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 18,
                      ),
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                    ),
                    child: Slider(
                      value: _index.toDouble(),
                      min: 0,
                      max: last.toDouble(),
                      divisions: last,
                      onChanged: (v) => _setIndex(v.round()),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OutlineOnlyDiamond extends StatelessWidget {
  final double size;
  final Color borderColor;
  final double strokeWidth;
  final Color backgroundColor;

  const _OutlineOnlyDiamond({
    required this.size,
    required this.borderColor,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: strokeWidth),
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }
}
