import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_no_records.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/future_trade_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class FuturePnLHistory extends StatefulWidget {
  const FuturePnLHistory({super.key});

  @override
  State<FuturePnLHistory> createState() => _FuturePnLHistoryState();
}

class _FuturePnLHistoryState extends State<FuturePnLHistory> {
  FutureTradeController controller = FutureTradeController();
  @override
  Widget build(BuildContext context) {
    return Consumer<FutureTradeController>(
      builder: (context, value, child) {
        controller = value;
        return futuresPnLHistoryList(context, controller);
      },
    );
  }

  futuresPnLHistoryList(
    BuildContext context,
    FutureTradeController controller,
  ) {
    return controller.futuresPnLHistoryList.isEmpty
        ? customNoRecordsFound(context)
        : ListView.builder(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 5.h,
            ),
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.futuresPnLHistoryList.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int i) {
              var list = controller.futuresPnLHistoryList[i];
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
}
