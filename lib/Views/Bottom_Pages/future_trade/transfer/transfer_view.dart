import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/custom_bottom_sheet.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/formatter.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/future_trade_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/transfer/transfer_controller.dart';
import 'package:zayroexchange/l10n/app_localizations_en.dart';

import '../../../../l10n/app_localizations.dart';

class TransferView extends StatefulWidget {
  String type;
  TransferView({super.key, required this.type});

  @override
  State<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends State<TransferView> {
  TransferController controller = TransferController();
  FutureTradeController futureTradeController = FutureTradeController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).whenComplete(() async {
      controller.resetData();
      controller.setCoin(coinVal: widget.type == "wallet" ? "USDT" : futureTradeController.coinTwo);
      controller.getWalletBalance();

    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransferController, FutureTradeController>(
        builder: (context, value, value1, child) {
      controller = value;
      futureTradeController = value1;
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          uI(context, controller),
          CustomLoader(isLoading: controller.isLoading)
        ],
      );
    });
  }

  uI(BuildContext context, TransferController controller) {
    return Form(
      key: controller.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFieldWidget(
            label: AppLocalizations.of(context)!.from,
            controller: controller.fromWalletController,
            hintText: "",
            readOnly: true,
            suffixIcon: Icon(Icons.arrow_drop_down_outlined, size: 10.sp,),
            // SvgPicture.asset(
            //   AppImages.dropDown,
            //   height: 10.sp,
            // ),
            onTap: () {
              walletType(
                  context: context, controller: controller, walletType: 1);
            },
          ),
          SizedBox(
            height: 15.sp,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                label: AppLocalizations.of(context)!.to,
                fontSize: 16.sp,
                labelFontWeight: FontWeight.w500,
                // fontColor: AppColors.primaryText,
              ),
              CustomGestureButton(
                onTap: () {
                  controller.changeWalletType();
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 15.sp, bottom: 5.sp),
                  child: Icon(Icons.swap_vert,size: 22.sp,)
                  // SvgPicture.asset(
                  //   AppImages.transferSwap,
                  //   height: 22.sp,
                  //   width: 22.sp,
                  // ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 14.sp,
          ),
          CustomTextFieldWidget(
            controller: controller.toWalletController,
            hintText: "",
            suffixIcon: Icon(Icons.arrow_drop_down_outlined, size: 10.sp,),
            // SvgPicture.asset(
            //   AppImages.dropDown,
            //   height: 10.sp,
            // ),
            readOnly: true,
            onTap: () {
              walletType(
                  context: context, controller: controller, walletType: 2);
            },
          ),
          SizedBox(
            height: 15.sp,
          ),
          CustomTextFieldWidget(
            label: AppLocalizations.of(context)!.coin,
            controller: controller.coinController,
            hintText: "",
            suffixIcon: Icon(Icons.arrow_drop_down),
            readOnly: true,
            onTap: () {
              selectCoin(
                  context: context, controller: controller);
            },

          ),
          SizedBox(
            height: 15.sp,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                label: AppLocalizations.of(context)!.amount,
                fontSize: 16.sp,
                labelFontWeight: FontWeight.w500,
                // fontColour: AppColors.primaryText,
              ),
              CustomText(
                label: "${controller.availableBalance} ${controller.coinController.text} ${AppLocalizations.of(context)!.available}",
                fontSize: 14.5.sp,
                labelFontWeight: FontWeight.w400,
                align: TextAlign.start,
                // fontColour: AppColors.secondaryText,
              ),
            ],
          ),
          SizedBox(
            height: 14.sp,
          ),
          CustomTextFieldWidget(
            controller: controller.amountController,
            hintText: "",
            readOnly: false,
            line: 1,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              AppFormatters(editingValidator: CryptoValidator())
            ],
            suffixIcon: CustomGestureButton(
              onTap: () {

                  controller.amountController.text = controller.availableBalance.toString();

              },
              child: Padding(
                padding: EdgeInsets.only(right: 10.sp),
                child: CustomText(
                  label: AppLocalizations.of(context)!.max,
                  fontSize: 16.sp,
                  labelFontWeight: FontWeight.w400,
                  // fontColour: AppColors.primaryText,
                ),
              ),
            ),
            onValidate: (val) {
              if (val!.isEmpty) {
                return AppLocalizations.of(context)!.amountRequired;
              } else if (double.parse(val) <= 0) {
                return AppLocalizations.of(context)!.amountShouldNotBeZero;
              } else if (double.parse(val) > controller.availableBalance) {
                return '${AppLocalizations.of(context)!.availableBalanceIs} ${controller.availableBalance}';
              }
              return null;
            },
          ),

          SizedBox(
            height: 18.sp,
          ),
          CustomText(
            label:
                AppLocalizations.of(context)!.transferDescription,
            fontSize: 14.5.sp,
            labelFontWeight: FontWeight.w400,
            align: TextAlign.center,
            // fontColour: AppColors.secondaryText,
          ),
          SizedBox(
            height: 18.sp,
          ),
          CustomButton(
            label: AppLocalizations.of(context)!.transfer,
            onTap: () {
              controller.doTransfer(context).whenComplete(() {
                if (controller.isSuccess) {
                  futureTradeController.getTradePairDetails();
                  Navigator.pop(context);
                }
              });
            },
          )
        ],
      ),
    );
  }

  walletType(
      {required BuildContext context,
      required TransferController controller,
      required int walletType}) {
    return customBottomSheet(
        context: context,
        height: 30.h,
        title: AppLocalizations.of(context)!.selectWallet,
        child: Consumer<TransferController>(builder: (context, value, child) {
          controller = value;
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.walletTypeList.length,
            itemBuilder: (context, i) {
              return ListTile(
                title: CustomText(
                  label: controller.walletTypeList[i].toString(),
                  labelFontWeight: FontWeight.w500,
                  fontSize: 17.sp,
                  // fontColor: AppColors.primaryText,
                ),
                onTap: () {
                  if (walletType == 1) {
                    controller.setFromWallet(
                        controller.walletTypeList[i].toString());
                  } else {
                    controller
                        .setToWallet(controller.walletTypeList[i].toString());
                  }

                  Navigator.pop(context);
                },
              );
            },
          );
        }));
  }

  selectCoin(
      {required BuildContext context, required TransferController controller,}) {
    return customBottomSheet(
        context: context,
        height: 30.h,
        title: AppLocalizations.of(context)!.searchCoin,
        child: Consumer<TransferController>(builder: (context, value, child) {
          controller = value;
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.coinList.length,
            itemBuilder: (context, i) {
              return ListTile(
                title: CustomText(
                  label: controller.coinList[i].toString(),
                  labelFontWeight: FontWeight.w500,
                  fontSize: 17.sp,
                  // fontColor: AppColors.primaryText,
                ),
                onTap: () {
                  controller.setCoin(coinVal: controller.coinList[i].toString());
                  controller.getWalletBalance();
                  Navigator.pop(context);
                },
              );
            },
          );
        }));
  }

}
