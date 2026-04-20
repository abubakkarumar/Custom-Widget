import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'support_controller.dart';

class ChatView extends StatefulWidget {
  final String ticketId;
  final String subject;
  final int closedStatus;

  const ChatView({
    super.key,
    required this.ticketId,
    required this.subject,
    required this.closedStatus,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  SupportController controller = SupportController();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).whenComplete(() async {
      controller.getSupportChat(context, widget.ticketId);
    });

    /// Auto-scroll listener
    controller.scrollController.addListener(() {
      if (controller.scrollController.position.pixels ==
          controller.scrollController.position.maxScrollExtent) {}
    });
  }

  @override
  void dispose() {
    controller.chatList.clear();
    controller.ticketImageURL = "";
    super.dispose();
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (controller.scrollController.hasClients) {
        controller.scrollController.animateTo(
          controller.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupportController>(
      builder: (context, value, child) {
        controller = value;
        scrollToBottom();
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0, // <<< important
              surfaceTintColor: Colors.transparent, // <<< prevent color changes
              automaticallyImplyLeading: false,

              title: CustomText(
                label: AppLocalizations.of(context)!.chat,
                fontSize: 18.sp,
                fontColour: ThemeTextColor.getTextColor(context),
                labelFontWeight: FontWeight.bold,
              ),
              leading: GestureDetector(
                onTap: () => AppNavigator.pop(),
                child: Padding(
                  padding: EdgeInsets.only(left: 14.sp),
                  child: SvgPicture.asset(
                    AppThemeIcons.backArrow(context),
                    width: 20.sp,
                    height: 20.sp,
                  ),
                ),
              ),
            ),

            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.sp,
                          vertical: 10.sp,
                        ),
                        child: chatUI(context, controller),
                      ),
                    ),
                  ],
                ),

                if (controller.isLoading) CustomLoader(isLoading: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget chatUI(BuildContext context, SupportController controller) {
    return Column(
      children: [
        /// Top Info Box
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.sp),
            color: ThemeTextFormFillColor.getTextFormFillColor(context),
            border: Border.all(
              width: 2.5.sp,
              color: ThemeOutLineColor.getOutLineColor(context),
            ),
          ),
          child: Row(
            children: [
              ClipOval(
                child: SvgPicture.asset(
                  AppThemeIcons.chatProfile(context),
                  height: 5.h,
                ),
              ),
              SizedBox(width: 15.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      label: AppLocalizations.of(context)!.zayroSupport,
                      fontSize: 14.sp,
                      labelFontWeight: FontWeight.w600,
                      fontColour:
                          ThemeInversePrimaryColor.getInversePrimaryColor(
                            context,
                          ),
                    ),
                    SizedBox(height: 6.sp),
                    CustomText(label: "(${widget.subject})", fontSize: 14.sp),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomText(
                    label: AppLocalizations.of(context)!.ticketID,
                    fontSize: 14.sp,
                    labelFontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 6.sp),
                  CustomText(label: widget.ticketId, fontSize: 14.sp),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 6.sp),

        Expanded(
          child: SingleChildScrollView(
            controller: controller.scrollController,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 0.sp,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                /// Show uploaded image if exists
                controller.ticketImageURL.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          showImageViewer(
                            context,
                            Image.network(
                              controller.ticketImageURL,
                              fit: BoxFit.cover,
                            ).image,
                            doubleTapZoomable: true,
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.sp,
                            horizontal: 5.h + 12.sp,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.sp),
                            child: Image.network(
                              controller.ticketImageURL,
                              height: 15.h,
                              errorBuilder: (c, o, s) => Container(
                                color: Colors.red,
                                height: 15.h,
                                width: 100.w,
                                child: const Center(
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),

                /// Chat Bubble List
                ListView.builder(
                  padding: EdgeInsets.only(top: 15.sp),
                  itemCount: controller.chatList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    var list = controller.chatList[i];
                    return list.replyMessage.toString() != ""
                        ? adminBubble(list)
                        : userBubble(list);
                  },
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 12.sp),

        widget.closedStatus == 0 ? const SizedBox() : chatInputField(context),
      ],
    );
  }

  /// Admin Bubble
  Widget adminBubble(list) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 15.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4.h,
              width: 4.h,
              padding: EdgeInsets.all(5.sp),
              decoration: BoxDecoration(
                color:
                    ThemeSurfaceContainerLowColor.getSurfaceContainerLowColor(
                      context,
                    ),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: SvgPicture.asset(
                  SupportDarkIcon.chatAdminProfile,
                  height: 4.h,
                ),
              ),
            ),
            SizedBox(width: 12.sp),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 65.w),
                  padding: EdgeInsets.all(15.sp),
                  decoration: BoxDecoration(
                    color: ThemeOnSecondary.getOnSecondary(context),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15.sp),
                      bottomLeft: Radius.circular(15.sp),
                      bottomRight: Radius.circular(15.sp),
                    ),
                  ),
                  child: CustomText(
                    label: list.replyMessage.toString(),
                    fontSize: 15.sp,
                    labelFontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.sp),
                CustomText(
                  label: list.createdAt.toString(),
                  fontSize: 12.sp,
                  fontColour: ThemeTextOneColor.getTextOneColor(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// User Message Bubble
  Widget userBubble(list) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(bottom: 15.sp),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 65.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.sp,
                    vertical: 12.sp,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeBackgroundColor.getBackgroundColor(context),
                    border: Border.all(
                      color: ThemeOutLineColor.getOutLineColor(context),
                      width: 4.5.sp,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.sp),
                      bottomLeft: Radius.circular(15.sp),
                      bottomRight: Radius.circular(12.sp),
                    ),
                  ),
                  child: CustomText(
                    label: list.message.toString(),
                    fontSize: 14.5.sp,
                    labelFontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.sp),
                CustomText(
                  label: list.createdAt.toString(),
                  fontSize: 13.sp,
                  fontColour: ThemeTextOneColor.getTextOneColor(context),
                ),
              ],
            ),
            SizedBox(width: 12.sp),
            profileImage(context),
          ],
        ),
      ),
    );
  }

  /// Chat Input Box
  Widget chatInputField(BuildContext context) {
    return CustomTextFieldWidget(
      readOnly: false,
      height: 6.h,
      line: 1,
      inputFormatters: [NoLeadingSpaceFormatter()],
      controller: controller.messageController,
      hintText: AppLocalizations.of(context)!.askMeSomething,
      suffixIcon: GestureDetector(
        onTap: () {
          if (controller.messageController.text.isNotEmpty) {
            controller
                .doSendMessage(
                  context,
                  widget.ticketId,
                  controller.messageController.text,
                )
                .whenComplete(
                  () => controller.getSupportChat(context, widget.ticketId),
                );
            scrollToBottom();
          }
        },
        child: Padding(
          padding: EdgeInsets.only(right: 10.sp),
          child: Image.asset(SupportDarkIcon.sendPng, height: 4.h),
        ),
      ),
    );
  }

  /// User Profile Image
  Widget profileImage(BuildContext context) {
    String? profile = AppStorage.getProfileImage();

    if (profile == null || profile.contains(".svg")) {
      return Image.asset(
        AppBasicIcons.profile,
        width: 25.sp,
        height: 25.sp,
        fit: BoxFit.contain,
      );
    }

    return Container(
      height: 5.h,
      width: 5.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(profile),
          onError: (o, s) {},
        ),
      ),
    );
  }
}
