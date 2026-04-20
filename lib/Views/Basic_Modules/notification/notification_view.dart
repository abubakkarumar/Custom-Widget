import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_no_records.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import 'notification_controller.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  NotificationController controller = NotificationController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      controller.getNotifications(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationController>(
      builder: (context, value, child) {
        controller = value;
        return Scaffold(
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () {
                  return  Future.delayed(Duration.zero).whenComplete(() async {
                    controller.getNotifications(context);
                  });
                },
                child: CustomTotalPageFormat(
                  appBarTitle: AppLocalizations.of(context)!.notification,
                  showBackButton: true,
                  child: Column(
                    children: [
                      SizedBox(height: 10.sp),

                      /// 🔹 Clear All Row
                      if (controller.notificationList.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                controller.clearNotificationDetails(context);
                              },
                              child: CustomText(
                                label: AppLocalizations.of(context)!.markAsRead,
                                fontSize: 15.sp,
                                labelFontWeight: FontWeight.bold,
                                fontColour: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 15.sp),

                      notificationActivity(context, controller),
                    ],
                  ),
                ),
              ),

              if (controller.isLoading)
                CustomLoader(isLoading: controller.isLoading),
            ],
          ),
        );
      },
    );
  }

  Widget notificationActivity(
    BuildContext context,
    NotificationController controller,
  ) {
    return controller.notificationList.isEmpty
        ? customNoRecordsFound(context)
        : ListView.builder(
            itemCount: controller.notificationList.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),

            itemBuilder: (BuildContext context, int i) {
              final list = controller.notificationList[i];

              return Dismissible(
                key: Key(list.id),

                direction: DismissDirection.endToStart, // swipe right -> left

                background: Container(color: Colors.transparent), // REQUIRED

                secondaryBackground: Container(

                  margin: EdgeInsets.only(bottom: 14.sp),
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(14.sp),
                  ),

                  alignment: Alignment.centerRight,

                  child: Icon(Icons.delete, color: Colors.white),
                ),

                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    print("Edit");
                  } else {
                    print("Delete");
                    controller.clearOnDismiss(i);
                    controller.clearDetails(context, list.id);
                  }
                },

                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: (){

                      controller.clearOnDismiss(i);
                      controller.clearDetails(context, list.id);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 14.sp),
                      padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        color: ThemeTextFormFillColor.getTextFormFillColor(context),
                        borderRadius: BorderRadius.circular(14.sp),
                        border: Border.all(
                          color: ThemeOutLineColor.getOutLineColor(context),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔴 Unread Dot
                          Padding(
                            padding: EdgeInsets.only(top: 6.sp),
                            child: Container(
                              width: 10.sp,
                              height: 10.sp,
                              decoration: BoxDecoration(
                                color: list.isRead
                                    ? Colors.transparent
                                    : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          SizedBox(width: 12.sp),

                          /// 📝 Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Title
                                CustomText(
                                  label: list.title,
                                  fontSize: 15.sp,
                                  labelFontWeight: FontWeight.w600,
                                ),

                                SizedBox(height: 10.sp),

                                /// Message
                                CustomText(
                                  label: list.message,
                                  fontSize: 14.5.sp,
                                  fontColour: Colors.grey.shade400,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                SizedBox(height: 10.sp),

                                /// Date
                                CustomText(
                                  label: list.createdAt,
                                  fontSize: 14.sp,
                                  fontColour: Colors.grey.shade500,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}
