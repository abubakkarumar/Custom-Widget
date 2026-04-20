import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../custom_text.dart';

class OfflineOverlay extends StatelessWidget {
  const OfflineOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(15.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppThemeIcons.noInternet(context),
                width: 30.w,
                height: 20.h,
                fit: BoxFit.fitWidth,
              ),
              CustomText(
                label: AppLocalizations.of(context)!.youAreOffline,
                fontSize: 16.sp,
                labelFontWeight: FontWeight.bold,
              ),
              SizedBox(height: 12.sp),
              CustomText(
                label: AppLocalizations.of(context)!.willReconnectAutomatically,
                fontSize: 16.sp,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
