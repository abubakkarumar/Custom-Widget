import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/Animation_pages/referral_badges.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/referral_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class ReferralPremiumSliderCard extends StatefulWidget {
  final ReferralController controller;

  const ReferralPremiumSliderCard({super.key, required this.controller});

  @override
  State<ReferralPremiumSliderCard> createState() =>
      _ReferralPremiumSliderCardState();
}

class _ReferralPremiumSliderCardState extends State<ReferralPremiumSliderCard> {
  bool isOpen = true;

  void _toggle() {
    setState(() {
      isOpen = !isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int current = widget.controller.goldFragments;
    final int total = 10;
    return Container(
      padding: EdgeInsets.all(15.sp),
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
          GestureDetector(
            onTap: _toggle,
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    label: AppLocalizations.of(context)!.rareGoldenRobotAvatar,
                    fontSize: 15.5.sp,
                    labelFontWeight: FontWeight.w600,
                    fontColour: ThemeTextColor.getTextColor(context),
                  ),
                ),
                AnimatedRotation(
                  turns: isOpen ? 0.0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    size: 22.sp,
                    color: ThemeTextOneColor.getTextOneColor(context),
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            crossFadeState: isOpen
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 220),
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.sp),
                CustomText(
                  label:
                      "${AppLocalizations.of(context)!.collect} "
                      " $total ${AppLocalizations.of(context)!.goldFragmentsAchieve}",
                  align: TextAlign.start,
                  labelFontWeight: FontWeight.w300,
                  fontSize: 15.sp,
                ),
                SizedBox(height: 10.sp),
                CustomText(
                  label:
                      "1 ${AppLocalizations.of(context)!.rareGoldenChest}",
                  align: TextAlign.start,
                  labelFontWeight: FontWeight.bold,
                  lineSpacing: 5.sp,
                  fontSize: 16.sp,
                ),
                SizedBox(height: 10.sp),
                CustomText(
                  label: AppLocalizations.of(
                    context,
                  )!.blackFragmentsAchieveSubTwo,
                  align: TextAlign.start,
                  labelFontWeight: FontWeight.w500,
                  lineSpacing: 5.sp,
                  fontSize: 15.sp,
                ),
                SizedBox(height: 15.sp),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _InfoCard(
                        title: AppLocalizations.of(context)!.goldFragments,
                        badge: "$current/$total",
                        showCheck: false,
                        iconPath: AppThemeIcons.referralGoldCoin(context),
                      ),
                    ),
                    SizedBox(width: 12.sp),
                    Expanded(
                      flex: 3,
                      child: _InfoCard(
                        title: AppLocalizations.of(
                          context,
                        )!.rareGoldenChest,
                        showCheck: current == 10 ? true : false,
                        iconPath: AppThemeIcons.referralGoldRobot(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.sp),
                PremiumStepSlider(current: current, total: total),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String? badge;
  final bool showCheck;
  final String? description;
  final String iconPath;

  const _InfoCard({
    required this.title,
    required this.iconPath,
    this.badge,
    this.showCheck = false,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final Widget badgeWidget = badge != null
        ? ReferralCountBadge(label: badge!, size: 22.sp, fontSize: 12.sp)
        : (showCheck
              ? Align(
                  alignment: Alignment.topRight,
                  child: ReferralTickBadge(size: 20.sp),
                )
              : const SizedBox.shrink());
    final Alignment badgeAlignment = showCheck
        ? Alignment.topRight
        : Alignment.topLeft;

    return Container(
      constraints: BoxConstraints(minHeight: 15.h),
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: ThemeOutLineColor.getOutLineColor(context),
        borderRadius: BorderRadius.circular(16.sp),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(alignment: badgeAlignment, child: badgeWidget),

          /// ICON
          SvgPicture.asset(iconPath, height: 30.sp, width: 30.sp),

          SizedBox(height: 15.sp),
          CustomText(
            label: title,
            align: TextAlign.center,
            labelFontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

class PremiumStepSlider extends StatefulWidget {
  final int current;
  final int total;

  const PremiumStepSlider({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  State<PremiumStepSlider> createState() => _PremiumStepSliderState();
}

class _PremiumStepSliderState extends State<PremiumStepSlider> {
  @override
  Widget build(BuildContext context) {
    final double current = widget.current.clamp(0, widget.total).toDouble();
    final double total = widget.total.toDouble();
    final double progress = total == 0 ? 0 : current / total;
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            return SizedBox(
              height: 28,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 12,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F17),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 12,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: width * progress,
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF007FFF),
                            Color(0xFF623EF8),
                            Color(0xFFBF00FF),
                          ],
                          stops: [0.0, 0.35, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  ...List.generate(widget.total + 1, (index) {
                    final double percent = widget.total == 0
                        ? 0
                        : index / widget.total;
                    return Positioned(
                      left: width * percent - 0.75,
                      top: 8,
                      child: Container(
                        width: 1.5,
                        height: 14,
                        color: const Color(0xFF2E2E3A),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "${widget.current}/${widget.total}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
