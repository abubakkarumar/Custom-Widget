import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_image_capture.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/deposit/deposit_controller.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Kyc/kyc_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../../../../Utility/Basics/local_data.dart';

class DepositView extends StatefulWidget {
  final String coinName;

  const DepositView({super.key, required this.coinName});

  @override
  State<DepositView> createState() => _DepositViewState();
}

class _DepositViewState extends State<DepositView> {
  DepositController controller = DepositController();
  KycController kycController = KycController();
  final GlobalKey imageCaptureKey = GlobalKey();

  bool _networkConfirmed = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      controller.resetSelection();
      await controller.getCoins(context);
      kycController.getKYCDetails(context);

      final target = widget.coinName.toLowerCase();
      final index = controller.coinList.indexWhere(
        (c) =>
            c.symbol.toLowerCase() == target || c.name.toLowerCase() == target,
      );

      if (index != -1) {
        controller.selectCoin(controller.coinList[index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DepositController, KycController>(
      builder: (_, value, kController, __) {
        controller = value;
        kycController = kController;
        return Scaffold(
          body: Stack(
            children: [
              CustomTotalPageFormat(
                appBarTitle: AppLocalizations.of(context)!.deposit,
                showBackButton: true,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (AppStorage.getKYCStatus() != 1)
                      noteContainer(context, controller,AppLocalizations.of(context)!.kycRequiredGenerate),

                      SizedBox(height: 15.sp),
                      _section(AppLocalizations.of(context)!.selectCrypto),
                      SizedBox(height: 10.sp),
                      _buildSelectCryptoField(context),

                      SizedBox(height: 15.sp),

                      /// NETWORK SECTION
                      FadeSlide(
                        visible: controller.selectedCoin != null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _section(
                              AppLocalizations.of(context)!.selectNetwork,
                            ),
                            SizedBox(height: 10.sp),
                            _buildSelectNetworkField(context),
                          ],
                        ),
                      ),

                      /// ADDRESS + QR
                      FadeSlide(
                        visible:
                            _networkConfirmed &&
                            controller.addressController.text.isNotEmpty &&
                            controller.addressQRCode.isNotEmpty,
                        child: Column(
                          children: [
                            SizedBox(height: 15.sp),
                            _buildWalletAddressField(context),
                            SizedBox(height: 15.sp),
                            _buildQrAndButtonsSection(context),
                            SizedBox(height: 15.sp),
                            _row(
                              AppLocalizations.of(context)!.minimumDepositLimit,
                              "${controller.minimumDeposit} ${controller.selectedCoin?.symbol}",
                            ),
                            SizedBox(height: 15.sp),
                            _row(
                              AppLocalizations.of(context)!.depositFees,
                              "${controller.minimumDepositFee} %",
                            ),
                            SizedBox(height: 15.sp),
                            noteContainer(context, controller,AppLocalizations.of(context)!.depositMinutes),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (controller.isLoading) const CustomLoader(isLoading: true),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // FADE + SLIDE ANIMATION (PROFESSIONAL)
  // ---------------------------------------------------------------------------

  Widget FadeSlide({required bool visible, required Widget child}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, -0.08),
          end: Offset.zero,
        ).animate(animation);

        final fade = Tween<double>(begin: 0, end: 1).animate(animation);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: visible
          ? Container(key: const ValueKey(true), child: child)
          : const SizedBox(key: ValueKey(false)),
    );
  }

  // ---------------------------------------------------------------------------
  // UI HELPERS
  // ---------------------------------------------------------------------------

  Widget _section(String title) {
    return CustomText(
      label: title,
      fontSize: 14.5.sp,
      labelFontWeight: FontWeight.bold,
      fontColour: ThemeTextColor.getTextColor(context),
    );
  }

  Widget _row(String key, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(label: key),
        CustomText(label: value),
      ],
    );
  }

  Widget _box(Widget child) {
    return Container(
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
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // FIELDS
  // ---------------------------------------------------------------------------

  Widget _buildSelectCryptoField(BuildContext context) {
    return GestureDetector(
      onTap: () => _openCoinSheet(context),
      child: _box(
        Row(
          children: [
            if (controller.selectedCoin != null)
              SvgPicture.network(
                controller.selectedCoin!.imageUrl,
                height: 20.sp,
              ),
            SizedBox(width: 10.sp),
            Expanded(
              child: CustomText(
                label:
                    controller.selectedCoin?.symbol ??
                    AppLocalizations.of(context)!.selectCrypto,
                fontSize: 15.sp,
                labelFontWeight: FontWeight.w700,
              ),
            ),
            SvgPicture.asset(AppThemeIcons.arrowDown(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectNetworkField(BuildContext context) {
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
        _openNetworkSheet(context);
      },
      child: _box(
        Row(
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
            SvgPicture.asset(AppThemeIcons.arrowDown(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletAddressField(BuildContext context) {
    return CustomTextFieldWidget(
      hintText: "",
      label: AppLocalizations.of(context)!.walletAddress,
      controller: controller.addressController,
      readOnly: true,
      suffixIcon: GestureDetector(
        onTap: () => _copy(controller.addressController.text),
        child: Padding(
          padding: EdgeInsets.only(right: 12.sp),
          child: SvgPicture.asset(AppBasicIcons.copy, height: 18.sp),
        ),
      ),
    );
  }

  Widget _buildQrAndButtonsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 4.sp,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RepaintBoundary(
            key: imageCaptureKey,
            child: Image.network(controller.addressQRCode, height: 40.sp),
          ),
          GestureDetector(
            onTap: () => _copy(controller.addressController.text),
            child: Row(
              children: [
                SvgPicture.asset(AppThemeIcons.copyCode(context)),
                SizedBox(width: 10.sp),
                CustomText(label: AppLocalizations.of(context)!.copy),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                CustomImageCapture.captureAndSave(imageCaptureKey, context),
            child: Row(
              children: [
                SvgPicture.asset(AppThemeIcons.downloadQrCode(context)),
                SizedBox(width: 10.sp),
                CustomText(label: AppLocalizations.of(context)!.download),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget noteContainer(BuildContext context, DepositController controller,String label) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: ThemeNoteColor.getNoteColorColor(context),
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: const Color(0xFF5d9cf7), width: 5.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label: AppLocalizations.of(context)!.note,
            labelFontWeight: FontWeight.bold,
            fontColour: ThemeInversePrimaryColor.getInversePrimaryColor(
              context,
            ),
            fontSize: 16.sp,
          ),
          SizedBox(height: 10.sp),
          CustomText(
            label: label,
            labelFontWeight: FontWeight.w400,
            fontSize: 14.sp,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UTIL
  // ---------------------------------------------------------------------------

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    CustomAnimationToast.show(
      message: AppLocalizations.of(context)!.copiedSuccessfully,
      type: ToastType.success,
      context: context,
    );
  }
  // ---------------------------------------------------------------------------
  // BOTTOM SHEETS
  // ---------------------------------------------------------------------------

  void _openCoinSheet(BuildContext context) {
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
                              onTap: () {
        if(coin.activeDeposit == 0){
        CustomAnimationToast.show(
        message: AppLocalizations.of(context)!.depositNotAvailableForThisCrypto,
        context: context,
        type: ToastType.error,
        );
        controller.resetSelection();
        setState(() {
          _networkConfirmed = true;
        });
        Navigator.pop(sheetContext);
        return;

        }else {
          controller.selectCoin(coin);
          Navigator.pop(sheetContext);
          if (mounted) {
            Future.delayed(Duration.zero, () {
              if (coin.network.isNotEmpty) {
                _openNetworkSheet(context);
              }
            });
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

  void _openNetworkSheet(BuildContext context) {
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
              mainAxisSize: MainAxisSize.min,
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

                /// ✅ THIS FIXES THE ERROR
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(15.sp),
                    itemCount: networks.length,
                    itemBuilder: (_, i) {
                      final net = networks[i];

                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          setState(() {
                            _networkConfirmed = false;
                          });
                          controller.selectNetwork(net);
                          await controller.getDepositDetails(
                            context,
                            controller.selectedCoin!.symbol,
                            i,
                            net,
                          );
                          if (controller.addressController.text.isNotEmpty &&
                              controller.addressQRCode.isNotEmpty) {
                            setState(() {
                              _networkConfirmed = true;
                            });
                          }
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
              ],
            ),
          ),
        );
      },
    );
  }
}
