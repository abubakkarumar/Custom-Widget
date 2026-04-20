import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../Utility/custom_button.dart';
import '../../../../Utility/custom_text.dart';


customListItems({
  BuildContext? context,
  String? leadingKey,
  String? leadingValue,
  Color? leadingValueColor,
  String? trailingKey,
  String? trailingValue,
  Color? trailingValueColor,
  bool? isLeadingCopy,
  bool? isTrailingCopy,
  void Function()? onCopyLeading,
  void Function()? onCopyTrailing,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: Padding(
          padding:  EdgeInsets.only(right: 15.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomText(
                label: leadingKey ?? "",
                labelFontWeight: FontWeight.w400,
                fontSize: 14.sp,
                // fontColor: AppColors.secondaryText,
              ),
              SizedBox(height: 6.sp),
              Row(
                children: [
                  Expanded(
                    child: CustomText(
                      label: leadingValue ?? "",
                      labelFontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      fontColour: leadingValueColor,
                      align: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  if (isLeadingCopy ?? false)
                  SizedBox(width: 8.sp,),
                  if (isLeadingCopy ?? false)
                    CustomGestureButton(onTap: onCopyLeading ?? () {}, child:
                        Icon(Icons.copy, size: 20.sp,)
                    // SvgPicture.asset(AppImages.copy, height: 20.sp,)

                    )
                ],
              ),
            ],
          ),
        ),
      ),

      if (trailingKey != null && trailingValue != null)
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText(
                label: trailingKey,
                labelFontWeight: FontWeight.w400,
                fontSize: 14.sp,
                // fontColor: AppColors.secondaryText,
              ),
              SizedBox(height: 6.sp),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: CustomText(
                      label: trailingValue,
                      labelFontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      // fontColor: trailingValueColor ?? AppColors.primaryText,
                      align: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  if (isTrailingCopy ?? false)
                  SizedBox(width: 8.sp,),
                  if (isTrailingCopy ?? false)
                    CustomGestureButton(onTap: onCopyTrailing  ?? () {}, child:
  Icon(Icons.copy, size: 20.sp,)
                    // SvgPicture.asset(AppImages.copy, height: 20.sp,)
                    )

                ],
              ),
            ],
          ),
        ),
    ],
  );
}


// customLinearListItems({
//   required String key,
//   required String value,
//   bool useFlexible = true,
//   Color? keyColor,
//   Color? valueColor,
// }) {
//   return Row(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       CustomText(
//         label: key,
//         fontWeight: FontWeight.w400,
//         fontSize: 13.5.sp,
//         fontColor: keyColor ?? AppColors.secondaryText,
//       ),
//       useFlexible
//           ? Expanded(
//               child: CustomText(
//                 label: value,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14.sp,
//                 fontColor: valueColor ?? AppColors.primaryText,
//                 softWrap: true,
//                 align: TextAlign.end,
//               ),
//             )
//           : Expanded(
//               flex: 3,
//               child: CustomText(
//                 label: value,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14.sp,
//                 fontColor: valueColor ?? AppColors.primaryText,
//                 overflow: TextOverflow.ellipsis,
//                 softWrap: false,
//                 align: TextAlign.end,
//               ),
//             ),
//     ],
//   );
// }
