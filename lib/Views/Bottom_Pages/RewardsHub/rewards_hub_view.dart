import 'dart:async';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'package:zayroexchange/l10n/app_localizations_en.dart';

class RewardsHubView extends StatefulWidget {
  const RewardsHubView({super.key});

  @override
  State<RewardsHubView> createState() => _RewardsHubViewState();
}

class _RewardsHubViewState extends State<RewardsHubView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomTotalPageFormat(
          appBarTitle: AppLocalizations.of(context)!.rewardsHub,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.sp),

              /// ---------------- Banner ----------------
              AppStorage.getLanguage() == 'cn'
                  ? Image.asset(
                      AppThemeIcons.rewardsZhContent(context),
                      width: 100.w,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      AppThemeIcons.rewardsContent(context),
                      width: 100.w,
                      fit: BoxFit.cover,
                    ),

              SizedBox(height: 2.h),

              /// ---------------- Countdown ----------------
              const CountdownWidget(),

              SizedBox(height: 2.h),

              /// ---------------- Airdrop ----------------
              _sectionTitle(AppLocalizations.of(context)!.airdropDetails),
              SizedBox(height: 15.sp),
              _infoCard(context, [
                _infoRow(AppLocalizations.of(context)!.tokenName, "USDT"),
                _infoRow(
                  AppLocalizations.of(context)!.airdropAmount,
                  "100,000 USDT",
                ),
                _infoRow(
                  AppLocalizations.of(context)!.maxPerUser,
                  "10,000 USDT",
                ),
                _infoRow(
                  AppLocalizations.of(context)!.eligibility,
                  AppLocalizations.of(context)!.completeLeastTasks,
                ),
                _infoRow(
                  AppLocalizations.of(context)!.distributionDate,
                  AppLocalizations.of(context)!.june,
                ),
              ]),

              SizedBox(height: 3.h),

              /// ---------------- Rewards Rules ----------------
              _sectionTitle(AppLocalizations.of(context)!.rewardsRules),
              SizedBox(height: 15.sp),
              _rewardCard(context),
              _rewardCard(context),
              _rewardCard(context),
              _rewardCard(context),
              _rewardCard(context),

              /// ---------------- Rules ----------------
              _sectionTitle(AppLocalizations.of(context)!.rules),
              SizedBox(height: 15.sp),
              _textCard(context, [
                AppLocalizations.of(context)!.eachParticipantVerification,
                AppLocalizations.of(context)!.rewardsDistributedBasis,
                AppLocalizations.of(context)!.oneUserAllowed,
                AppLocalizations.of(
                  context,
                )!.suspiciousActivityDisqualification,
                AppLocalizations.of(context)!.rewardsDistributedDays,
              ]),

              SizedBox(height: 3.h),

              /// ---------------- Terms ----------------
              _sectionTitle(AppLocalizations.of(context)!.termsConditions),
              SizedBox(height: 15.sp),
              _textCard(context, [
                AppLocalizations.of(
                  context,
                )!.participationSubjectVerification1Approval,
                AppLocalizations.of(context)!.companyReservesCancelCampaign,
                AppLocalizations.of(context)!.tokensOfficiallyListed,
              ]),

              SizedBox(height: 3.h),

              /// ---------------- Risk ----------------
              _riskWarning(context),
            ],
          ),
        ),
      ),
    );
  }

  // =================== UI COMPONENTS ===================

  Widget _sectionTitle(String title) {
    return CustomText(
      label: title,
      fontSize: 15.sp,
      labelFontWeight: FontWeight.w600,
    );
  }

  Widget _infoCard(BuildContext context, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: _cardDecoration(context),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            label: title,
            fontSize: 14.sp,
            fontColour: ThemeTextOneColor.getTextOneColor(context),
          ),
          CustomText(
            label: value,
            fontSize: 14.5.sp,
            fontColour: ThemeTextColor.getTextColor(context),
            labelFontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _rewardCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.sp),
      child: Container(
        padding: EdgeInsets.all(14.sp),
        decoration: _cardDecoration(context),
        child: Column(
          children: [
            _infoRow(
              AppLocalizations.of(context)!.assetsBalance,
              "10,000 ≥ 100",
            ),
            SizedBox(height: 10.sp),
            _infoRow(AppLocalizations.of(context)!.rewards, "20 USDT"),
          ],
        ),
      ),
    );
  }

  Widget _textCard(BuildContext context, List<String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: texts.map((text) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.sp),
          child: CustomText(
            label: text,
            fontSize: 15.sp,
            labelFontWeight: FontWeight.w400,
          ),
        );
      }).toList(),
    );
  }

  Widget _riskWarning(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(context),
        borderRadius: BorderRadius.circular(14.sp),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label: AppLocalizations.of(context)!.riskWarning,
            fontSize: 15.sp,
            fontColour: Colors.redAccent,
            labelFontWeight: FontWeight.bold,
          ),
          SizedBox(height: 1.h),
          CustomText(
            label: AppLocalizations.of(context)!.riskWarningContent,
            fontSize: 14.5.sp,
            fontColour: ThemeTextOneColor.getTextOneColor(context),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: ThemeBackgroundColor.getBackgroundColor(context),
      borderRadius: BorderRadius.circular(14.sp),
      border: Border.all(color: ThemeOutLineColor.getOutLineColor(context)),
    );
  }
}

/// =======================================================
/// =================== COUNTDOWN WIDGET ==================
/// =======================================================

class CountdownWidget extends StatefulWidget {
  const CountdownWidget({super.key});

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Timer _timer;
  Duration remaining = const Duration(days: 365);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (remaining.inSeconds > 0) {
          remaining -= const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeBox(
                context,
                AppLocalizations.of(context)!.day,
                remaining.inDays,
              ),
              _timeBox(
                context,
                AppLocalizations.of(context)!.hours,
                remaining.inHours % 24,
              ),
              _timeBox(
                context,
                AppLocalizations.of(context)!.minutes,
                remaining.inMinutes % 60,
              ),
              _timeBox(
                context,
                AppLocalizations.of(context)!.seconds,
                remaining.inSeconds % 60,
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          CustomText(
            label: AppLocalizations.of(context)!.daysCountdown,
            fontSize: 12.sp,
          ),
        ],
      ),
    );
  }

  Widget _timeBox(BuildContext context, String label, int value) {
    return Container(
      width: 18.w,
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: ThemeBackgroundColor.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(14.sp),
        border: Border.all(color: ThemeOutLineColor.getOutLineColor(context)),
      ),
      child: Column(
        children: [
          CustomText(
            label: value.toString().padLeft(2, '0'),
            fontSize: 18.sp,
            labelFontWeight: FontWeight.bold,
          ),
          SizedBox(height: 6.sp),
          CustomText(label: label, fontSize: 11.sp),
        ],
      ),
    );
  }
}
