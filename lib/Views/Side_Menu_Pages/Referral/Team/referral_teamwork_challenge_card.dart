import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class ReferralTeamworkChallengeCard extends StatefulWidget {
  const ReferralTeamworkChallengeCard({super.key});

  @override
  State<ReferralTeamworkChallengeCard> createState() =>
      _ReferralTeamworkChallengeCardState();
}

class _ReferralTeamworkChallengeCardState
    extends State<ReferralTeamworkChallengeCard> {
  final List<String> participants = const [
    "IronClad_X",
    "QuantumDrift",
    "QuantumDrift",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(context),
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 5.sp,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label: AppLocalizations.of(context)!.theTeamworkChallenge,
            fontSize: 16.sp,
            labelFontWeight: FontWeight.w600,
            fontColour: ThemeTextColor.getTextColor(context),
          ),
          SizedBox(height: 12.sp),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AvatarCircle(),
              SizedBox(width: 15.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      label: AppLocalizations.of(context)!.viperStrike,
                      fontSize: 15.sp,
                      labelFontWeight: FontWeight.w600,
                      fontColour: ThemeTextColor.getTextColor(context),
                    ),
                    SizedBox(height: 6.sp),
                    CustomText(
                      label: AppLocalizations.of(context)!.youHaveOpened,
                      fontSize: 14.sp,
                      lineSpacing: 4.5.sp,
                      fontColour: ThemeTextOneColor.getTextOneColor(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.sp),
          CustomText(
            label: AppLocalizations.of(context)!.otherParticipants,
            fontSize: 15.sp,
            labelFontWeight: FontWeight.w600,
            fontColour: ThemeTextColor.getTextColor(context),
          ),
          SizedBox(height: 10.sp),
          ...participants.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 6.sp),
              child: CustomText(
                label: "${entry.key + 1}. ${entry.value}",
                fontSize: 14.5.sp,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.sp,
      width: 30.sp,
      decoration: BoxDecoration(
        color: ThemeOutLineColor.getOutLineColor(context),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 28.sp,
        color: ThemeTextOneColor.getTextOneColor(context),
      ),
    );
  }
}
