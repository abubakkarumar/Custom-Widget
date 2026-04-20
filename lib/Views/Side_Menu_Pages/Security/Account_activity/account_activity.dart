import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_list_items.dart';
import 'package:zayroexchange/Utility/custom_no_records.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class AccountActivityView extends StatefulWidget {
  const AccountActivityView({super.key});

  @override
  State<AccountActivityView> createState() => _AccountActivityViewState();
}

class _AccountActivityViewState extends State<AccountActivityView> {
  SecurityController controller = SecurityController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      controller.getLoginActivity(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityController>(
      builder: (context, value, child) {
        controller = value;
        return  Stack(
          alignment: Alignment.center,
          children: [
            CustomTotalPageFormat(
              appBarTitle: AppLocalizations.of(context)!.accountActivities,
              showBackButton: true,
              child: controller.accountActivityList.isEmpty
                  ? customNoRecordsFound(context)
                  : ListView.builder(
                scrollDirection: Axis.vertical,
                physics: const ScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 15.sp),
                itemCount: controller.accountActivityList.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int i) {
                  var list = controller.accountActivityList[i];
                  return Container(
                    margin: EdgeInsets.only(bottom: 15.sp),
                    padding: EdgeInsets.all(15.sp),
                    decoration: BoxDecoration(
                      color:
                      ThemeTextFormFillColor.getTextFormFillColor(
                        context,
                      ),
                      borderRadius: BorderRadius.circular(14.sp),
                      border: Border.all(
                        color: ThemeOutLineColor.getOutLineColor(
                          context,
                        ),
                        width: 4.sp,
                      ),
                    ),
                    child: Column(
                      children: [
                        customListItems(
                          context: context,
                          leadingKey: AppLocalizations.of(
                            context,
                          )!.device,
                          leadingValue: list.device.toString(),
                          trailingKey: AppLocalizations.of(
                            context,
                          )!.dateTime,
                          trailingValue: list.date,
                        ),
                        SizedBox(height: 15.sp),
                        customListItems(
                          context: context,
                          leadingKey: AppLocalizations.of(
                            context,
                          )!.iPAddress,
                          leadingValue: list.ip.toString(),
                          trailingKey: AppLocalizations.of(
                            context,
                          )!.browser,
                          trailingValue: list.browser,
                        ),
                        SizedBox(height: 15.sp),
                        customListItems(
                          context: context,
                          leadingKey: AppLocalizations.of(
                            context,
                          )!.location,
                          leadingValue: list.device.toString(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// Loader overlay
            CustomLoader(isLoading: controller.isLoading),
          ],
        );
      },
    );
  }

  securityActivity(BuildContext context, SecurityController controller) {
    return controller.securityActivityList.isEmpty
        ? customNoRecordsFound(context)
        : ListView.builder(
            scrollDirection: Axis.vertical,
            physics: const ScrollPhysics(),
            itemCount: controller.securityActivityList.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int i) {
              var list = controller.securityActivityList[i];
              return Container(
                margin: EdgeInsets.only(top: 15.sp),
                padding: EdgeInsets.all(15.sp),
                child: Column(
                  children: [
                    customListItems(
                      context: context,
                      leadingKey: AppLocalizations.of(context)!.device,
                      leadingValue: list.type.toString(),
                      trailingKey: AppLocalizations.of(context)!.os,
                      trailingValue: list.os,
                    ),
                    SizedBox(height: 15.sp),
                    customListItems(
                      context: context,
                      leadingKey: AppLocalizations.of(context)!.iPAddress,
                      leadingValue: list.ip.toString(),
                      trailingKey: AppLocalizations.of(context)!.browser,
                      trailingValue: list.browser,
                    ),
                  ],
                ),
              );
            },
          );
  }
}
