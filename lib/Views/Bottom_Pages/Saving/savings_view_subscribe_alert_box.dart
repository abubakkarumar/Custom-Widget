import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Saving/savings_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../trade/custom_progress_dialog.dart';

savingsSubscribeAlert(
  BuildContext context,
  SavingsController controller,
  StakeProductsModel item,
) {
  // final GlobalKey<FormState> savingFormKey = GlobalKey<FormState>();
  return customAlert(
    context: context,
    title: '${AppLocalizations.of(context)!.subscribe} ${item.coin}',
    onTapBack: () {
      AppNavigator.pop();
      controller.restData();
    },
    widget: Consumer<SavingsController>(
      builder: (context, value, child) {
        controller = value;
        var selectedPlan = item.plans.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- COIN LIST ----------
            SizedBox(
              height: 9.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: item.plans.length,
                itemBuilder: (context, index) {
                  final StakePlan plan = item.plans[index];
                  final bool isSelected = value.selectedPlanIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(right: 15.sp),
                    child: GestureDetector(
                      onTap: () {
                        value.restData();
                        value.changePlanTab(context, index);

                      },
                      child: Container(
                        width: 30.w,
                        padding: EdgeInsets.all(10.sp),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ThemeOutLineColor.getOutLineColor(context)
                              : ThemeTextFormFillColor.getTextFormFillColor(
                                  context,
                                ),
                          borderRadius: BorderRadius.circular(15.sp),
                          border: Border.all(
                            width: 5.sp,
                            color: isSelected
                                ? const Color(0xFF007FFF)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            plan.stakeType == 'flexible'
                                ? CustomText(
                                    label: plan.stakeType,
                                    fontSize: 15.sp,
                                    fontColour: isSelected
                                        ? const Color(0xFF007FFF)
                                        : Colors.grey,
                                  )
                                : CustomText(
                                    label: '${plan.duration} ${AppLocalizations.of(context)!.days}',
                                    fontSize: 15.sp,
                                    fontColour: isSelected
                                        ? const Color(0xFF007FFF)
                                        : Colors.grey,
                                  ),
                            SizedBox(height: 15.sp),
                            CustomText(
                              label: '${plan.rate} %',
                              fontSize: 14.5.sp,
                              labelFontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20.sp),

            CustomTextFieldWidget(
              line: 1,
              label: AppLocalizations.of(context)!.amount,
              onChanged: (text) {
                Future.delayed(Duration.zero).whenComplete(() {
                  if(double.parse(value.savingAmountController.text) > double.parse(item.plans[value.selectedPlanIndex].maxLimit)){
                    _showErrorToast(context, "Entered Amount should be equal or lesser than Maximum Amount");
                  }else if(double.parse(value.savingAmountController.text) < double.parse(item.plans[value.selectedPlanIndex].minLimit)){
                    _showErrorToast(context, "Entered Amount should be equal or greater than Minimum Amount");

                  }else {
                    value.onAmountChanged(
                      context,
                      text,
                      item.plans[value.selectedPlanIndex].id,
                    );
                  }
                });

              },

              controller: value.savingAmountController,
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
              ),
              // inputFormatters: [
              //   FilteringTextInputFormatter.allow(
              //     RegExp(r'^\d{0,8}(\.\d{0,8})?'),
              //   ),
              //   // DecimalTextInputFormatter(),
              // ],
              readOnly: false,
              filled: true,
              suffixIcon: GestureDetector(
                onTap: () {
                  value.savingAmountController.text =
                      item.plans[value.selectedPlanIndex].balance;
                  Future.delayed(Duration.zero).whenComplete(() {
                    if(double.parse(value.savingAmountController.text) > double.parse(item.plans[value.selectedPlanIndex].maxLimit)){
                      _showErrorToast(context, "Entered Amount should be equal or lesser than Maximum Amount");
                    }else if(double.parse(value.savingAmountController.text) < double.parse(item.plans[value.selectedPlanIndex].minLimit)){
                      _showErrorToast(context, "Entered Amount should be equal or greater than Minimum Amount");

                    }else{
                      value.doStakePreviewCalculationAPI(
                        context,
                        item.plans[value.selectedPlanIndex].id,
                        value.savingAmountController.text,
                      );
                    }

                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 15.sp),
                  child: CustomText(
                    label: '| Max | ${item.coin}',
                    fontSize: 15.sp,
                    labelFontWeight: FontWeight.bold,
                  ),
                ),
              ),
              hintText: '',
              onValidate: (value) {
                if (value!.isEmpty) {
                  return AppLocalizations.of(context)!.pleaseEnterStackAmount;
                }
                return null;
              },
            ),
            SizedBox(height: 15.sp),
            Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                label:
                    AppLocalizations.of(context)!.min+' ${item.plans[value.selectedPlanIndex].minLimit} ${item.coin} · '+
                        AppLocalizations.of(context)!.max+' ${item.plans[value.selectedPlanIndex].maxLimit} ${item.coin}',
                // 'Min 20.00000000 LTC ·Max 300.00000000 LTC',
                fontSize: 15.sp,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
                labelFontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.sp),
            Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                label:
                    '${AppLocalizations.of(context)!.available} ${item.plans[value.selectedPlanIndex].balance} ${item.coin}',
                fontSize: 15.sp,
                fontColour: ThemeTextOneColor.getTextOneColor(context),
                labelFontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.sp),

            /// ---------- TAB AREA ----------
            Column(
              children: [
                Row(
                  children: [
                    _tabItem(AppLocalizations.of(context)!.summary, 0, context, value),
                    SizedBox(width: 20.sp),
                    _tabItem(AppLocalizations.of(context)!.timeline, 1, context, value),
                  ],
                ),

                SizedBox(height: 15.sp),

                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: value.selectedIndex == 0
                      ? summaryUI(context, value, item)
                      : timeLineUI(context, value, item, selectedPlan),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            AgreeTermsWithController(
              onLinkTap: () {
                // open terms page
              },
            ),
            SizedBox(height: 12.sp),
            // animated expanding area (buttons)
            // AnimatedSize handles height transitions, AnimatedOpacity fades content in/out.
            value.isLoading == true ? CustomProgressDialog() :
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 50),
                child: Padding(
                  padding: EdgeInsets.only(top: 12.sp),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: 1.0,
                    curve: Curves.easeInOut,
                    child:  value.isLoading
                        ? const CustomProgressDialog()
                        :CustomButton(
                      label: AppLocalizations.of(context)!.confirm,
                      onTap: () async {
                        // if (savingFormKey.currentState!.validate()) {
                        if (value.savingAmountController.text.isEmpty) {
                          _showErrorToast(context, AppLocalizations.of(context)!.pleaseEnterStackAmount);
                        } else if (value.isTermsAccepted == false) {
                          _showErrorToast(
                            context,
                            AppLocalizations.of(context)!.pleaseAcceptTerms,
                          );
                        } else {
                          value.doSaveStakeSubmitAPI(
                            context,
                            item.plans[value.selectedPlanIndex].stakeType=='fixed'?item.plans[value.selectedPlanIndex].duration: 'flexible',
                            'onetime',
                            item
                                .plans[value.selectedPlanIndex]
                                .interestPayment,
                            item
                                .plans[value.selectedPlanIndex]
                                .interestStart,
                            item.plans[value.selectedPlanIndex].id,
                          );
                        }

                        // }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
    // ),
  );
}

Widget _tabItem(
  String title,
  int index,
  BuildContext context,
  SavingsController controller,
) {
  final isSelected = controller.selectedIndex == index;

  return GestureDetector(
    onTap: () => controller.changeTab(index),
    child: Column(
      children: [
        CustomText(
          label: title,
          fontColour: isSelected
              ? ThemeInversePrimaryColor.getInversePrimaryColor(context)
              : ThemeTextColor.getTextColor(context),
        ),
        SizedBox(height: 8.sp),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 2,
          width: isSelected ? 55 : 0,
          color: ThemeInversePrimaryColor.getInversePrimaryColor(context),
        ),
      ],
    ),
  );
}

Widget summaryUI(
  BuildContext context,
  SavingsController controller,
  StakeProductsModel item,
  // StakePlan selectedPlan,
) {
  String safeValue(
    dynamic value, {
    int decimal = 6,
    String fallback = '0.000000',
  }) {
    if (value == null) return fallback;

    final str = value.toString().trim();
    if (str.isEmpty) return fallback;

    final num? parsed = num.tryParse(str);
    if (parsed == null) return fallback;

    return parsed.toStringAsFixed(decimal);
  }

  return Column(
    children: [
      _row(
        AppLocalizations.of(context)!.yourCurrentInvestedAmount,
        '${controller.savingAmountController.text.isNotEmpty ? controller.savingAmountController.text : '0'} ${item.coin}',
      ),
      _row(
        AppLocalizations.of(context)!.estimatedEarnings+' (${item.coin}/'+AppLocalizations.of(context)!.day+")",
        '${safeValue(controller.stakePreviewDaily)} ${item.coin}',
        valueColor: const Color(0xFF00C48D),
      ),
      _row(
        AppLocalizations.of(context)!.term,
        item.plans[controller.selectedPlanIndex].stakeType.toString(),
      ),
      _row(AppLocalizations.of(context)!.estAPR, '${item.plans[controller.selectedPlanIndex].rate}%'),
    ],
  );
}

//
Widget timeLineUI(
  BuildContext context,
  SavingsController controller,
  StakeProductsModel item,
  StakePlan selectedPlan,
) {
  return Column(
    children: [
      _row(
        AppLocalizations.of(context)!.subscriptionDate,
        item.plans[controller.selectedPlanIndex].subscriptionDate,
      ),
      _row(
        AppLocalizations.of(context)!.interestStartDate,
        item.plans[controller.selectedPlanIndex].interestStart,
      ),
      _row(AppLocalizations.of(context)!.interestPeriod, AppLocalizations.of(context)!.daily),
      _row(
        AppLocalizations.of(context)!.interestPaymentDate,
        item.plans[controller.selectedPlanIndex].interestPayment,
      ),
    ],
  );
}

// Widget timeLineUI(
//   BuildContext context,
//   SavingsController controller,
//   StakeProductsModel item,
//   StakePlan selectedPlan,
// ) {
//   String safeDateTime(
//       String? value, {
//         String fallback = '-',
//       }) {
//     if (value == null) return fallback;
//
//     final v = value.trim();
//     if (v.isEmpty) return fallback;
//
//     return v;
//   }
//   // String addDaysToNow(
//   //     int days, {
//   //       String format = 'yyyy-MM-dd HH:mm:ss',
//   //     }) {
//   //   final DateTime now = DateTime.now();
//   //   final DateTime futureDate = now.add(Duration(days: days));
//   //
//   //   String two(int n) => n.toString().padLeft(2, '0');
//   //
//   //   return '${futureDate.year}-'
//   //       '${two(futureDate.month)}-'
//   //       '${two(futureDate.day)} '
//   //       '${two(futureDate.hour)}:'
//   //       '${two(futureDate.minute)}:'
//   //       '${two(futureDate.second)}';
//   // }
//
//   return Column(
//     children: [
//       _row(
//         'Subscription Date', safeDateTime(controller.subscriptionDate)
//       ),
//       _row('Interest Start Date', safeDateTime(controller.interestStart)),
//       _row('Interest Period', safeDateTime(controller.interestPeriod)),
//       _row('Interest Payment Date', safeDateTime(controller.interestPayment)),
//     ],
//   );
// }

Widget _row(String title, String value, {Color? valueColor}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 12.sp),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          label: title,
          fontSize: 15.sp,
          labelFontWeight: FontWeight.bold,
        ),
        CustomText(
          label: value,
          fontSize: 15.sp,
          fontColour: valueColor,
          labelFontWeight: FontWeight.bold,
        ),
      ],
    ),
  );
}

class AgreeTermsWithController extends StatelessWidget {
  final VoidCallback? onLinkTap;
  const AgreeTermsWithController({this.onLinkTap, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SavingsController>(context);
    final double boxSize = 20.0;

    return GestureDetector(
      onTap: () {
        controller.toggleTermsAccepted();
      },
      behavior: HitTestBehavior.translucent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: controller.isTermsAccepted
                  ? ThemePrimaryColor.getPrimaryColor(context)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: controller.isTermsAccepted
                    ? ThemeOutLineColor.getOutLineColor(context)
                    : Colors.grey.shade500,
                width: 2.5.sp,
              ),
            ),
            child: controller.isTermsAccepted
                ? Icon(
                    Icons.check,
                    size: boxSize - 6,
                    color: Colors.white,
                  )
                : null,

          ),
          SizedBox(width: 8),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: ThemeTextOneColor.getTextOneColor(context),
                  fontSize: 14.sp,
                ),
                children: [
                  TextSpan(text: AppLocalizations.of(context)!.iHaveReadAgreedToThe),
                  TextSpan(
                    text: " "+AppLocalizations.of(context)!.zayroSimpleEarnServiceTermsCondition,
                    style: TextStyle(
                      color: ThemeInversePrimaryColor.getInversePrimaryColor(
                        context,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          onLinkTap ??
                          () {
                            // fallback: open page or handle navigation
                          },
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

void _showErrorToast(BuildContext context, String message) {
  CustomAnimationToast.show(
    context: context,
    message: message,
    type: ToastType.error,
  );
}
