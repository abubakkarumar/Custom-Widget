// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Kyc/kyc_view.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/referral_controller.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/First_Step/referral_key_view.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'Second_Step/referral_black_frame_avatar.dart';
import 'Second_Step/referral_black_robot_avatar.dart';
import 'First_Step/referral_frame_view.dart';
import 'Second_Step/referral_gold_avatar.dart';
import 'First_Step/referral_robot_view.dart';
import 'Team/referral_teamwork_challenge_card.dart';
import 'Referral History/referral_history_view.dart';

class ReferralView extends StatefulWidget {
  final bool isSelectedFrom;
  const ReferralView({super.key, required this.isSelectedFrom});

  @override
  State<ReferralView> createState() => _ReferralViewState();
}

class _ReferralViewState extends State<ReferralView> {
  ReferralController controller = ReferralController();

  String linkCopyMessage = '';
  String codeCopyMessage = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).whenComplete(() async {
      controller.getReferralDetails(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReferralController>(
      builder: (context, value, child) {
        controller = value;
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () {
              return Future.delayed(Duration.zero).whenComplete(() async {
                controller.getReferralDetails(context);
              });
            },
            child: Stack(
              children: [
                CustomTotalPageFormat(
                  appBarTitle: AppLocalizations.of(context)!.referral,
                  showBackButton: true,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15.sp),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.yourInvitationCode,
                                ),
                                CustomButton(
                                  label: AppLocalizations.of(context)!.history,
                                  height: 3.h,
                                  width: 20.w,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.sp),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ReferralHistoryView(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            CustomTextFieldWidget(
                              hintText:
                                  AppLocalizations.of(context)!.copy +
                                  AppLocalizations.of(context)!.code,
                              line: 1,
                              label: "",
                              controller: controller.linkController,
                              readOnly: true,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  _copy(controller.linkController.text);
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 12.sp),
                                  child: SvgPicture.asset(
                                    AppBasicIcons.copy,
                                    height: 18.sp,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15.sp),
                            CustomText(
                              label: AppLocalizations.of(
                                context,
                              )!.referralSubText,
                              fontColour: ThemeTextOneColor.getTextOneColor(
                                context,
                              ),
                              fontSize: 14.5.sp,
                              labelFontWeight: FontWeight.w500,
                            ),
                            SizedBox(height: 15.sp),
                            Row(
                              children: [
                                Expanded(
                                  child: _InviteActionButton(
                                    icon: AppThemeIcons.linkReferral(context),
                                    label: AppLocalizations.of(context)!.link,
                                    onTap: () async {
                                      await _openAffiliateLink(
                                        controller.affiliateIdLink,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 15),

                                Expanded(
                                  child: _InviteActionButton(
                                    icon: AppThemeIcons.telegramReferral(
                                      context,
                                    ),
                                    label: AppLocalizations.of(
                                      context,
                                    )!.telegram,
                                    onTap: () async {
                                      await _shareToTelegram(
                                        controller.linkController.text,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: _InviteActionButton(
                                    icon: AppThemeIcons.whatsappReferral(
                                      context,
                                    ),
                                    label: AppLocalizations.of(
                                      context,
                                    )!.whatsApp,
                                    onTap: () async {
                                      await _shareToWhatsapp(
                                        controller.linkController.text,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15.sp),
                      _referralChestStack(context, controller),
                      SizedBox(height: 15.sp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _historyTab(
                            context,
                            AppLocalizations.of(context)!.keys,
                            0,
                          ),
                          SizedBox(width: 20.sp),
                          _historyTab(
                            context,
                            AppLocalizations.of(context)!.avatars,
                            1,
                          ),
                          SizedBox(width: 20.sp),
                          _historyTab(
                            context,
                            AppLocalizations.of(context)!.avatarFrames,
                            2,
                          ),
                        ],
                      ),

                      SizedBox(height: 8.sp),

                      /// 🔥 FULL WIDTH DIVIDER LINE
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: const Color(0xFF2A2D3E), // subtle line0
                      ),
                      SizedBox(height: 15.sp),
                      _tabSection(
                        child: IndexedStack(
                          index: controller.selectedTab,
                          children: [
                            ReferralKeysWidget(controller: controller),
                            ReferralRobotWidget(controller: controller),
                            ReferralFrameWidget(controller: controller),
                          ],
                        ),
                      ),

                      SizedBox(height: 14.sp),
                      ReferralPremiumSliderCard(controller: controller),
                      SizedBox(height: 14.sp),
                      ReferralBlackPremiumSliderCard(controller: controller),
                      SizedBox(height: 14.sp),
                      ReferralBlackRobotSliderCard(controller: controller),
                      SizedBox(height: 14.sp),
                      ReferralTeamworkChallengeCard(),
                    ],
                  ),
                ),

                // Loader overlay when controller.isLoading is true
                if (controller.isLoading)
                  CustomLoader(isLoading: controller.isLoading),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    CustomAnimationToast.show(
      message: AppLocalizations.of(context)!.copiedSuccessfully,
      type: ToastType.success,
      context: context,
    );
  }

  Future<void> _openAffiliateLink(String link) async {
    if (link.trim().isEmpty) {
      CustomAnimationToast.show(
        message: AppLocalizations.of(context)!.referralNotAvailable,
        type: ToastType.error,
        context: context,
      );
      return;
    }
    final String normalized = link.startsWith("http") ? link : "https://$link";
    final Uri? uri = Uri.tryParse(normalized);
    if (uri == null) {
      CustomAnimationToast.show(
        message: AppLocalizations.of(context)!.invalidReferralLink,
        type: ToastType.error,
        context: context,
      );
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      CustomAnimationToast.show(
        message: AppLocalizations.of(context)!.unableReferralLink,
        type: ToastType.error,
        context: context,
      );
    }
  }

  String _buildShareMessage(String codeOrLink) {
    return AppLocalizations.of(context)!.joinZayroReferralCode + codeOrLink;
  }

  Future<void> _shareToTelegram(String text) async {
    final String message = _buildShareMessage(text);
    final String encoded = Uri.encodeComponent(message);
    final Uri appUri = Uri.parse("tg://msg?text=$encoded");
    final Uri webUri = Uri.parse("https://t.me/share/url?url=$encoded");
    try {
      final bool launched = await launchUrl(
        appUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {
      // Fallback to web share if app not installed / intent fails.
    }
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _shareToWhatsapp(String text) async {
    final String message = _buildShareMessage(text);
    final String encoded = Uri.encodeComponent(message);
    final Uri appUri = Uri.parse("whatsapp://send?text=$encoded");
    final Uri webUri = Uri.parse("https://wa.me/?text=$encoded");
    try {
      final bool launched = await launchUrl(
        appUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {
      // Fallback to web share if app not installed / intent fails.
    }
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }

  /// 🔥 TAB WIDGET
  Widget _historyTab(BuildContext context, String title, int index) {
    final controller = context.watch<ReferralController>();
    final bool isSelected = controller.selectedTab == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: IntrinsicWidth(
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF3A8DFF)
                    : const Color(0xFF8A8FA3),
              ),
            ),

            SizedBox(height: 6.sp),

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 2,
              width: isSelected ? 30.sp : 0,
              decoration: BoxDecoration(
                color: const Color(0xFF3A8DFF),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _tabSection({required Widget child}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.sp),
    child: child,
  );
}

Widget _referralChestStack(
  BuildContext context,
  ReferralController controller,
) {
  final bool isKycVerified = controller.verifiedKyc == 1;
  final bool isBlueOpen = controller.blueOpened == 1;

  return Container(
    padding: EdgeInsets.all(10.sp),
    decoration: BoxDecoration(
      color: ThemeTextFormFillColor.getTextFormFillColor(context),
      borderRadius: BorderRadius.circular(15.sp),
      border: Border.all(
        color: ThemeOutLineColor.getOutLineColor(context),
        width: 5.sp,
      ),
    ),
    child: Column(
      children: [
        _stepItem(
          context,
          chestWidget: isBlueOpen
              ? ShakeOnAppear(
                  play: true,
                  loop: true,
                  child: SvgPicture.asset(
                    AppThemeIcons.referralBlueOpen(context),
                    height: 10.h,
                  ),
                )
              : SvgGlow(
                  assetPath: AppThemeIcons.referralBlueGlow(context),
                  height: 10.h,
                  glowColor: const Color(0xFF4699FF),
                  blurSigma: 30,
                  glowOpacity: 0.90,
                ),
          title: AppLocalizations.of(context)!.stepOne,
          desc: AppLocalizations.of(context)!.stepOneDesc,
          showLine: controller.redOpened == 1 || controller.goldOpened == 1
              ? true
              : false,
          count: 1,
          descWidget: Container(
            padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
              color: const Color(0xFF1E4D48),
              borderRadius: BorderRadius.circular(20.sp),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 14.sp,
                  color: const Color(0xFF55E0C6),
                ),
                SizedBox(width: 6.sp),
                CustomText(
                  label: AppLocalizations.of(context)!.verified,
                  fontSize: 13.sp,
                  labelFontWeight: FontWeight.w600,
                  fontColour: const Color(0xFF55E0C6),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 15.sp),
        _stepItem(
          context,
          chestWidget: controller.redOpened == 1
              ? ShakeOnAppear(
                  play: true,
                  loop: true,
                  child: SvgPicture.asset(
                    AppThemeIcons.referralRedOpen(context),
                    height: 10.h,
                  ),
                )
              : (isKycVerified
                    ? SvgGlow(
                        assetPath: AppThemeIcons.referralRedGlow(context),
                        height: 10.h,
                        glowColor: const Color(0xFFFF4C4C),
                        blurSigma: 30,
                        glowOpacity: 0.90,
                      )
                    : SvgPicture.asset(
                        AppThemeIcons.referralRedChest(context),
                        height: 10.h,
                      )),
          title: AppLocalizations.of(context)!.stepTwo,
          desc: AppLocalizations.of(context)!.stepTwoDesc,
          descWidget: isKycVerified
              ? Container(
                  padding: EdgeInsets.all(10.sp),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E4D48),
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14.sp,
                        color: const Color(0xFF55E0C6),
                      ),
                      SizedBox(width: 6.sp),
                      CustomText(
                        label: AppLocalizations.of(context)!.verified,
                        fontSize: 13.sp,
                        labelFontWeight: FontWeight.w600,
                        fontColour: const Color(0xFF55E0C6),
                      ),
                    ],
                  ),
                )
              : CustomButton(
                  height: 4.h,
                  labelFontSize: 14.sp,
                  width: 40.w,
                  label: AppLocalizations.of(context)!.completeVerification,
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (_) => const KycView()));
                  },
                ),
          showLine: controller.goldOpened == 1 ? true : false,
          count: 2,
        ),
        SizedBox(height: 15.sp),

        _stepItem(
          context,
          chestWidget: controller.goldOpened == 1
              ? ShakeOnAppear(
                  play: true,
                  loop: true,
                  child: SvgPicture.asset(
                    AppThemeIcons.referralGoldOpen(context),
                    height: 10.h,
                  ),
                )
              : (controller.redOpened == 1
                    ? SvgGlow(
                        assetPath: AppThemeIcons.referralGoldGlow(context),
                        height: 10.h,
                        glowColor: const Color(0xFFE2AA32),
                        blurSigma: 30,
                        glowOpacity: 0.90,
                      )
                    : SvgPicture.asset(
                        AppThemeIcons.referralGoldChest(context),
                        height: 10.h,
                      )),
          title: AppLocalizations.of(context)!.stepThree,
          desc: AppLocalizations.of(context)!.stepThreeDesc,
          showLine: false,
          count: 3,
        ),
      ],
    ),
  );
}

Widget _stepItem(
  BuildContext context, {
  required Widget chestWidget,
  required String title,
  required String desc,
  required bool showLine,
  required int count,
  Widget? descWidget,
}) {
  final double chestSize = 10.h;
  final double chestSlotWidth = chestSize + 8.sp;
  final double connectorTop = chestSize - 16.sp;
  final double connectorWidth = 9.sp;
  final double connectorHeight = 30.sp;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// 🔥 LEFT SIDE (CHEST + LINE)
      SizedBox(
        width: chestSlotWidth,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            /// CHEST
            SizedBox(
              height: chestSize,
              child: Center(child: chestWidget),
            ),

            /// CONNECTOR LINE (TOUCHING CHEST)
            if (showLine && count != 3)
              Positioned(
                top: connectorTop,
                child: Container(
                  width: connectorWidth,
                  height: connectorHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.sp),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF3A8DFF),
                        Color(0xFF7B2BFF),
                        Color(0xFFB000FF),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            if (!showLine && count != 3)
              Positioned(
                top: connectorTop,
                child: Container(
                  width: connectorWidth,
                  height: connectorHeight + 5.sp,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.sp),
                    color: ThemeOutLineColor.getOutLineColor(context),
                  ),
                ),
              ),
          ],
        ),
      ),

      /// 🔥 TEXT
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              label: title,
              fontSize: 15.sp,
              labelFontWeight: FontWeight.w600,
              fontColour: ThemeTextColor.getTextColor(context),
            ),
            if (desc.isNotEmpty)
              CustomText(
                label: desc,
                fontSize: 14.5.sp,
                lineSpacing: 5.sp,
                labelFontWeight: FontWeight.w400,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
              ),
            SizedBox(height: 10.sp),
            if (descWidget != null) descWidget,
          ],
        ),
      ),
    ],
  );
}

class _InviteActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final void Function()? onTap;

  const _InviteActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007FFF), Color(0xFF623EF8), Color(0xFFBF00FF)],
            stops: [0.0, 0.35, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(12.sp)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon),
            SizedBox(width: 10.sp),
            CustomText(
              label: label,
              fontSize: 15.sp,
              labelFontWeight: FontWeight.w500,
              fontColour: ThemeButtonTextColor.getButtonTextColor(context),
            ),
          ],
        ),
      ),
    );
  }
}

class ShakeOnAppear extends StatefulWidget {
  final Widget child;
  final bool play;
  final Duration duration;
  final double offset;
  final int shakes;
  final bool loop;

  const ShakeOnAppear({
    super.key,
    required this.child,
    required this.play,
    this.duration = const Duration(milliseconds: 2000),
    this.offset = 3,
    this.shakes = 3,
    this.loop = false,
  });

  @override
  State<ShakeOnAppear> createState() => _ShakeOnAppearState();
}

class _ShakeOnAppearState extends State<ShakeOnAppear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _wasPlaying = widget.play;
    if (widget.play) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.loop) {
          _controller.repeat();
        } else {
          _controller.forward(from: 0);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant ShakeOnAppear oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !_wasPlaying) {
      if (widget.loop) {
        _controller.repeat();
      } else {
        _controller.forward(from: 0);
      }
    } else if (!widget.play && _wasPlaying) {
      _controller.stop();
    }
    _wasPlaying = widget.play;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;
        final double dy =
            math.sin(t * math.pi * 2 * widget.shakes) * widget.offset;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}

class GlowWrapper extends StatelessWidget {
  final Widget child;
  final Color color;
  final double blur;
  final double spread;
  final double opacity;
  final EdgeInsets padding;

  const GlowWrapper({
    super.key,
    required this.child,
    required this.color,
    this.blur = 16,
    this.spread = 2,
    this.opacity = 0.65,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity),
            blurRadius: blur,
            spreadRadius: spread,
          ),
        ],
      ),
      child: child,
    );
  }
}

class SvgGlow extends StatelessWidget {
  final String assetPath;
  final double height;
  final Color glowColor;
  final double blurSigma;
  final double glowOpacity;

  const SvgGlow({
    super.key,
    required this.assetPath,
    required this.height,
    required this.glowColor,
    this.blurSigma = 8,
    this.glowOpacity = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                glowColor.withOpacity(glowOpacity),
                BlendMode.srcATop,
              ),
              child: SvgPicture.asset(assetPath, height: height),
            ),
          ),
          SvgPicture.asset(assetPath, height: height),
        ],
      ),
    );
  }
}
