import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import 'custom_text.dart';

///---------------- NO RECORDS WIDGET ----------------///
Widget customNoRecordsFound(BuildContext context) {
  return Center(
    child: Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon(Icons.folder_off_rounded, size: 55.sp, color: Colors.grey),
        SizedBox(height: 12.sp),
        CustomText(
          label: AppLocalizations.of(context)!.noRecordsFound,
          fontSize: 16.sp,
          labelFontWeight: FontWeight.w600,
        ),
      ],
    ),
  );
}
