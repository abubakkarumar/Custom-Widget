// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/Referral%20History/referral_history_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class ReferralHistoryView extends StatefulWidget {
  const ReferralHistoryView({super.key});

  @override
  State<ReferralHistoryView> createState() => _ReferralHistoryViewState();
}

class _ReferralHistoryViewState extends State<ReferralHistoryView> {
  ReferralHistoryController controller = ReferralHistoryController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).whenComplete(() async {
      controller.getReferralHistory(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<ReferralHistoryController>(
        builder: (context, value, _) {
          controller = value;
          return Scaffold(
            body: Stack(
              children: [
                CustomTotalPageFormat(
                  appBarTitle: AppLocalizations.of(context)!.referralHistory,
                  showBackButton: true,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.sp),
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
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: CustomText(
                                    label: AppLocalizations.of(
                                      context,
                                    )!.dateTime,
                                    fontSize: 14.sp,
                                    labelFontWeight: FontWeight.w600,
                                    fontColour:
                                        ThemeTextOneColor.getTextOneColor(
                                          context,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: CustomText(
                                    label: AppLocalizations.of(
                                      context,
                                    )!.username,
                                    align: TextAlign.right,
                                    fontSize: 14.sp,
                                    labelFontWeight: FontWeight.w600,
                                    fontColour:
                                        ThemeTextOneColor.getTextOneColor(
                                          context,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.sp),
                            Container(
                              height: 1,
                              width: double.infinity,
                              color: ThemeOutLineColor.getOutLineColor(context),
                            ),
                            SizedBox(height: 6.sp),
                            if (controller.historyList.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.sp),
                                child: CustomText(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.noRecordsFound,
                                  fontSize: 13.5.sp,
                                  fontColour: ThemeTextOneColor.getTextOneColor(
                                    context,
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.historyList.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: ThemeOutLineColor.getOutLineColor(
                                    context,
                                  ),
                                ),
                                itemBuilder: (context, index) {
                                  final item = controller.historyList[index];
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.sp,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: CustomText(
                                            label: item.date ?? '',
                                            fontSize: 13.5.sp,
                                            fontColour:
                                                ThemeTextColor.getTextColor(
                                                  context,
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: CustomText(
                                            label: item.name ?? '',
                                            align: TextAlign.right,
                                            fontSize: 13.5.sp,
                                            labelFontWeight: FontWeight.w600,
                                            fontColour:
                                                ThemeTextColor.getTextColor(
                                                  context,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (controller.isLoading)
                  CustomLoader(isLoading: controller.isLoading),
              ],
            ),
          );
        },
      ),
    );
  }
}
