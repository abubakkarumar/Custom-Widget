import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_tab_bar.dart';
import 'package:zayroexchange/Utility/custom_text.dart';

import 'package:zayroexchange/Views/Bottom_Pages/Market/market_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';
import 'package:zayroexchange/l10n/app_localizations_en.dart';

import '../../../l10n/app_localizations.dart';
import 'all_trade_pairs.dart';

/// ==============================
/// SHOW SPOT TRADE PAIRS BOTTOMSHEET
/// ==============================

void showSpotTradePairs(BuildContext context, String type) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    isScrollControlled: true,
    backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
    ),
    builder: (_) {
      return SafeArea(
        child: Consumer2<SpotTradeController, MarketController>(
          builder: (context, spotController, marketController, _) {
            return SizedBox(
              height: 80.h,
              child: Stack(
                children: [
                  /// ================= MAIN CONTENT =================
                  Column(
                    children: [
                      /// -------- HEADER --------
                      Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              label: AppLocalizations.of(context)!.selectPair,
                              fontSize: 16.sp,
                              labelFontWeight: FontWeight.w600,
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

                      /// -------- TABS & CONTENT --------
                      Expanded(
                        child: TabView(
                          height: 5.h,
                          dividerHeight: 1,
                          tabs: spotController.pairTabs,
                          selectedIndex: spotController.selectedPairTab,
                          onTabChange: spotController.changePairTab,
                          views: const [
                            AllTradePairs(type: "fav"),
                            AllTradePairs(type: "all"),
                            AllTradePairs(type: "usdt"),
                            AllTradePairs(type: "link"),
                          ],
                        ),
                      ),
                    ],
                  ),

                  /// ================= LOADING OVERLAY =================
                  if (spotController.isLoading || marketController.isLoading)
                    const Positioned.fill(child: CustomLoader(isLoading: true)),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
