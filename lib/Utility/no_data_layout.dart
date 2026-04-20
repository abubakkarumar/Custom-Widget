import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../l10n/app_localizations.dart';
import 'custom_text.dart';

class NoDataLayout extends StatelessWidget {
  const NoDataLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SvgPicture.asset(AppIcons.noDataFoundIcon.get(context), height: 15.h,),
          SizedBox(height: 20.sp),
          CustomText(label:AppLocalizations.of(context)!.noRecordsFound,
            ),
          SizedBox(height: 20.sp),
        ],
      ),
    );
  }
}
