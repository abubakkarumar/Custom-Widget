import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Support/chat_view.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Support/create_support.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Support/support_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  SupportController controller = SupportController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).whenComplete(() async {
      controller.getSupportTickets(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupportController>(
      builder: (context, value, child) {
        controller = value;

        return Stack(
          children: [
            CustomTotalPageFormat(
              appBarTitle: AppLocalizations.of(context)!.support,
              showBackButton: true,
              child: RefreshIndicator(
                onRefresh: () async {
                  controller.getSupportTickets(context);
                },
                child: Column(
                  children: [
                    /// ===== TOP FIXED BUTTON =====
                    GestureDetector(
                      onTap: () {
                        createTicket(context, controller);
                      },
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: 1.0,
                        child: Container(
                          height: 5.5.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: ThemeTextColor.getTextColor(context),
                            borderRadius: BorderRadius.circular(25.sp),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppThemeIcons.createTicket(context),
                                height: 2.5.h,
                              ),
                              SizedBox(width: 12.sp),
                              CustomText(
                                label: AppLocalizations.of(context)!.createTicket,
                                fontSize: 15.5.sp,
                                labelFontWeight: FontWeight.bold,
                                fontColour:ThemeBackgroundColor.getBackgroundColor(context)
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.sp),

                    /// ===== SCROLLABLE LIST =====
                    SizedBox(
                      height: 80.h,
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 20.sp),
                        itemCount: controller.ticketList.length,
                        itemBuilder: (context, index) {
                          final item = controller.ticketList[index];

                          return TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: Duration(milliseconds: 600 + (index * 80)),
                            curve: Curves.easeOut,
                            builder: (_, double value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 40 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 20.sp),
                              child: TicketCard(
                                ticketId: item.ticketId ?? "",
                                subject: item.subject ?? "",
                                status: item.status.toString() == "1"
                                    ? AppLocalizations.of(context)!.opened
                                    : AppLocalizations.of(context)!.closed,
                                createdAt: item.createdAt ?? "",
                                onChatTap: () {
                                  AppNavigator.pushTo(
                                    ChatView(
                                      ticketId: item.ticketId.toString(),
                                      subject: item.subject.toString(),
                                      closedStatus: int.parse(item.status ?? "1"),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (controller.isLoading)
              CustomLoader(isLoading: controller.isLoading),
          ],
        );
      },
    );
  }

  createTicket(BuildContext context, SupportController controller) {
    return customAlert(
      context: context,
      title: AppLocalizations.of(context)!.createTicket,
      onTapBack: () {
        AppNavigator.pop();
        controller.resetData();
      },
      widget: const SingleChildScrollView(child: CreateTicketView()),
      onDismiss: () {},
    );
  }
}

class TicketCard extends StatelessWidget {
  final String ticketId;
  final String subject;
  final String status;
  final String createdAt;
  final VoidCallback onChatTap;

  const TicketCard({
    super.key,
    required this.ticketId,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(context),
        borderRadius: BorderRadius.circular(15.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 5.sp,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          /// Ticket ID AND Subject Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Date & Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    label: AppLocalizations.of(context)!.ticketID,
                    fontColour: ThemeTextOneColor.getTextOneColor(context),
                    labelFontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 10.sp),
                  CustomText(
                    label: ticketId,
                    labelFontWeight: FontWeight.w500,
                    fontColour: ThemeTextColor.getTextColor(context),
                  ),
                ],
              ),

              /// Credited Token
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomText(
                    label: AppLocalizations.of(context)!.createdAt,
                    fontColour: ThemeTextOneColor.getTextOneColor(context),
                    labelFontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 10.sp),
                  CustomText(
                    label: createdAt,
                    fontColour: ThemeTextColor.getTextColor(context),
                    labelFontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 15.sp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    label: AppLocalizations.of(context)!.subject,
                    fontColour: ThemeTextOneColor.getTextOneColor(context),
                    labelFontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 10.sp),
                  CustomText(
                    label: subject,
                    fontColour: ThemeTextColor.getTextColor(context),
                    labelFontWeight: FontWeight.w500,
                  ),
                ],
              ),

              /// Credited Token
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomText(
                    label: AppLocalizations.of(context)!.status,
                    fontColour: ThemeTextOneColor.getTextOneColor(context),
                    labelFontWeight: FontWeight.w500,
                  ),
                  SizedBox(height: 10.sp),
                  CustomText(
                    label: status,
                    fontColour: status.toString() == "Opened"
                        ? Colors.green
                        : Colors.red,
                    labelFontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 15.sp),

          /// CHAT BUTTON
          GestureDetector(
            onTap: onChatTap,
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color:ThemeOutLineColor.getOutLineColor(context),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppThemeIcons.chat(context),
                    height: 2.5.h,
                  ),
                  SizedBox(width: 10.sp),
                  CustomText(
                    label: AppLocalizations.of(context)!.chat,
                    labelFontWeight: FontWeight.w600,
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
