import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_list_items.dart';
import 'package:zayroexchange/Utility/custom_no_records.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Saving/savings_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../../../Utility/custom_button.dart';

class SavingHistory extends StatefulWidget {
  const SavingHistory({super.key});

  @override
  State<SavingHistory> createState() => _SavingHistoryState();
}

class _SavingHistoryState extends State<SavingHistory> {
  late SavingsController controller;

  @override
  void initState() {
    super.initState();
    controller = SavingsController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getStakeHistory(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsController>(
      builder: (context, value, child) {
        controller = value;

        return Scaffold(
          body: Stack(
            children: [
              /// ================= MAIN PAGE =================
              RefreshIndicator(
                onRefresh: () {
                  return controller.getStakeHistory(context);
                },
                child: CustomTotalPageFormat(
                  appBarTitle: AppLocalizations.of(context)!.savingHistory,
                  showBackButton: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.sp),

                      /// ================= TAB BAR =================
                      SizedBox(
                        height: 5.h,
                        child: ListView(
                        scrollDirection: Axis.horizontal,children: [
                          _savingTab(
                            context,
                            AppLocalizations.of(context)!.currentHolding,
                            0,
                          ),
                          _savingTab(
                            context,
                            AppLocalizations.of(context)!.historicalHolding,
                            1,
                          ),
                          _savingTab(
                            context,
                            AppLocalizations.of(context)!.cancelled,
                            2,
                          ),
                        ],),
                      ),


                      SizedBox(height: 20.sp),

                      /// ================= CONTENT =================
                      IndexedStack(
                        index: controller.selectedIndex,
                        children: [
                          _savingListUI(context, controller.userHistoryList,),
                          _savingListUI(
                            context,
                            controller.historicalHoldingList,
                          ),
                          _savingListUI(
                            context,
                            controller.cancelledHistoryList
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              /// ================= LOADER =================
              if (controller.isLoading)
                CustomLoader(isLoading: controller.isLoading),
            ],
          ),
        );
      },
    );
  }

  /// ================= TAB UI =================
  Widget _savingTab(BuildContext context, String title, int index) {
    final bool isSelected = controller.selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.changeTab(index),
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

  /// ================= LIST UI =================
  Widget _savingListUI(BuildContext context, List<UserStakingModel> listData) {
    if (listData.isEmpty) {
      return customNoRecordsFound(context);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listData.length,
      itemBuilder: (context, i) {
        UserStakingModel list = listData[i];

        return Container(
          margin: EdgeInsets.only(bottom: 15.sp),
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            color: ThemeTextFormFillColor.getTextFormFillColor(context),
            borderRadius: BorderRadius.circular(14.sp),
            border: Border.all(
              color: ThemeOutLineColor.getOutLineColor(context),
              width: 4.sp,
            ),
          ),
          child: Column(
            children: [
              customListItems(
                context: context,
                leadingKey: AppLocalizations.of(context)!.asset,

                leadingValue: list.coin ?? "",
                trailingKey: AppLocalizations.of(context)!.amount,
                trailingValue: list.stakedAmount ?? "",
              ),
              SizedBox(height: 15.sp),
              customListItems(
                context: context,
                leadingKey: AppLocalizations.of(context)!.planType,
                leadingValue: list.planType.toString(),
                trailingKey:  AppLocalizations.of(context)!.duration,
                trailingValue: list.planType.toString().toLowerCase() == "flexible"? "-" : list.duration ?? "",
              ),
              SizedBox(height: 15.sp),
              customListItems(
                context: context,
                leadingKey: list.status.toString() == '3' ? AppLocalizations.of(context)!.cancelledDate : AppLocalizations.of(context)!.unlockDate,
                leadingValue: list.unlockDate ?? "",
                trailingKey: AppLocalizations.of(context)!.interestReceived,
                trailingValue: list.interestReceived ?? "",
              ),
              SizedBox(height: 15.sp),

              customListItems(
                context: context,
                leadingKey: AppLocalizations.of(context)!.interestEstimated,
                leadingValue: list.interestEstimated ?? "",
                trailingKey: AppLocalizations.of(context)!.subscribeDate,
                trailingValue: list.subscribeDate ?? "",
              ),
              SizedBox(height: 15.sp),

              // customListItems(
              //   context: context,
              //   leadingKey: AppLocalizations.of(context)!.interestEstimated,
              //   leadingValue: list.interestEstimated ?? "",
              //   trailingKey: AppLocalizations.of(context)!.subscribeDate,
              //   trailingValue: list.subscribeDate ?? "",
              // ),
              // SizedBox(height: 15.sp),

              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomText(
                      label: AppLocalizations.of(context)!.status,
                      fontSize: 15.sp,
                      fontColour: ThemeTextOneColor.getTextOneColor(context!),
                    ),
                    SizedBox(height: 6.sp),

                    list.status.toString() != '3' ? list.planType.toString().toLowerCase() == "flexible"
                        ? CustomButton(
                            height: 4.5.h,
                            width: 20.w,
                            label: AppLocalizations.of(context)!.cancel,
                            onTap: () async {
                              controller.cancelStack(
                                context,
                                list.id.toString(),
                              );
                            },
                          )
                        : CustomText(
                            label: list.statusText ?? "",
                            fontSize: 15.5.sp,
                            labelFontWeight: FontWeight.bold,
                            fontColour: ThemeTextColor.getTextColor(context!),
                          )
                        : CustomText(
                      label: AppLocalizations.of(context)!.cancelled,
                      fontSize: 15.5.sp,
                      labelFontWeight: FontWeight.bold,
                      fontColour: Colors.red,
                    ),
                  ],
                ),
              ),

              // customListItems(
              //   context: context,
              //   leadingKey: AppLocalizations.of(context)!.status,
              //   leadingValue: list.statusText ?? "",
              // ),
            ],
          ),
        );
      },
    );
  }
}
