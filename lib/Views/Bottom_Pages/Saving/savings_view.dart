import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_no_records.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Saving/saving_history.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Saving/savings_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Saving/savings_view_subscribe_alert_box.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class SavingsView extends StatefulWidget {
  const SavingsView({super.key});

  @override
  State<SavingsView> createState() => _SavingsViewState();
}

class _SavingsViewState extends State<SavingsView>
    with TickerProviderStateMixin {
  SavingsController controller = SavingsController();
  final PageController _trendPageController = PageController(
    viewportFraction: 0.7,
  );
  late AnimationController _iconAnimController;
  final Map<int, int> _selectedPlanByCoin = {};

  @override
  void initState() {
    print("Init savings");
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _iconAnimController.forward();
    Future.delayed(Duration.zero).whenComplete(() {
      controller.doGetStakeProductsAPI(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _iconAnimController.dispose();
    controller.clearData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsController>(
      builder: (context, value, child) {
        controller = value;
        return Scaffold(
          body: SafeArea(
            child:
            RefreshIndicator(
            onRefresh: () {
          return Future.delayed(Duration.zero).whenComplete(() async {
            controller.doGetStakeProductsAPI(context);
          });
        },
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(15.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppStorage.getLanguage() == 'cn'
                              ? Image.asset(
                                  AppThemeIcons.savingZhContent(context),
                                  width: 100.w,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  AppThemeIcons.savingContent(context),
                                  width: 100.w,
                                  fit: BoxFit.cover,
                                ),
                          SizedBox(height: 20.sp),
                          GestureDetector(
                            onTap: () {
                              controller.setIsSelectColorFeild(true);
                            },
                            child: Container(
                              padding: EdgeInsets.all(15.sp),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.sp),
                                border: Border.all(
                                  color: controller.isSelectColorFeild == true
                                      ? ThemeOutLineColor.getOutLineColor(context)
                                      : Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CustomText(
                                            label: AppLocalizations.of(
                                              context,
                                            )!.totalValue,
                                            fontSize: 15.sp,
                                            labelFontWeight: FontWeight.w600,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              controller.isHidden
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              size: 18.sp,
                                            ),
                                            onPressed: () {
                                              controller.setHidden(true);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label: controller.isHidden
                                            ? "****"
                                            : "\$ ${controller.profitTotalUSDTValue}",
                                        fontColour:
                                            controller.isSelectColorFeild == true
                                            ? ThemeTextColor.getTextColor(context)
                                            : Theme.of(
                                                context,
                                              ).colorScheme.tertiary,
                                        fontSize: 18.sp,
                                        labelFontWeight: FontWeight.bold,
                                      ),
                                      SizedBox(width: 10.sp),
                                      CustomText(
                                        label: controller.isHidden
                                            ? "****"
                                            : controller.profitTotalUsdValue,
                                        fontSize: 16.sp,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15.sp),
                          GestureDetector(
                            onTap: () {
                              controller.setIsSelectColorFeild(false);
                            },
                            child: Container(
                              padding: EdgeInsets.all(15.sp),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.sp),
                                border: Border.all(
                                  color: controller.isSelectColorFeild == false
                                      ? ThemeOutLineColor.getOutLineColor(context)
                                      : Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CustomText(
                                            label: AppLocalizations.of(
                                              context,
                                            )!.yesterdayProfit,
                                            fontSize: 15.sp,
                                            labelFontWeight: FontWeight.w600,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              controller.isSecendHidden
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              size: 18.sp,
                                            ),
                                            onPressed: () {
                                              controller.setSecendHidden(true);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        label: controller.isSecendHidden
                                            ? "****"
                                            : "\$ ${controller.profitYesterdayUSDTValue}",
                                        fontSize: 18.sp,
                                        fontColour:
                                            controller.isSelectColorFeild == false
                                            ? ThemeTextColor.getTextColor(context)
                                            : Color(0xFF00AF89),
                                        labelFontWeight: FontWeight.bold,
                                      ),
                                      SizedBox(width: 10.sp),
                                      CustomText(
                                        label: controller.isSecendHidden
                                            ? "****"
                                            : controller.profitYesterdayUsdValue,
                                        fontSize: 16.sp,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20.sp),
                          Row(
                            children: [

                              Expanded(
                                child: CustomText(
                                  label: AppLocalizations.of(context)!.growYour,
                                  fontColour:
                                      ThemeTextColor.getTextColor(context),
                                  fontSize: 14.5.sp,
                                  labelFontWeight: FontWeight.bold,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 10.sp),
                             CustomButton(
                                      width: 25.w,
                                      height: 4.h,
                                      labelFontSize: 14.sp,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.sp),
                                      ),
                                      label: AppLocalizations.of(
                                        context,
                                      )!.viewHistory,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SavingHistory(),
                                          ),
                                        );
                                      },
                                    ),
                              // GestureDetector(
                              //   onTap: () {
                              //     Navigator.of(context).push(
                              //       MaterialPageRoute(
                              //         builder: (context) => SavingHistory(),
                              //       ),
                              //     );
                              //   },
                              //   child: CustomText(
                              //     label: AppLocalizations.of(
                              //       context,
                              //     )!.viewHistory,
                              //     fontColour:
                              //         ThemeInversePrimaryColor.getInversePrimaryColor(
                              //           context,
                              //         ),
                              //     fontSize: 14.5.sp,
                              //     labelFontWeight: FontWeight.bold,
                              //   ),
                              // ),
                            ],
                          ),
                          SizedBox(height: 18.sp),
                          _investListUI(),

                          SizedBox(height: 15.sp),
                          CustomText(
                            label: AppLocalizations.of(
                              context,
                            )!.calculateYourCryptoEarnings,
                            fontColour: ThemeTextColor.getTextColor(context),
                            fontSize: 17.sp,
                            labelFontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 15.sp),
                          _calculateCryptoUI(),
                          SizedBox(height: 15.sp),
                          CustomText(
                            label: AppLocalizations.of(context)!.allProducts,
                            fontColour: ThemeTextColor.getTextColor(context),
                            fontSize: 17.sp,
                            labelFontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 15.sp),
                          _allProductsUI(),
                        ],
                      ),
                    ),
                  ),

                  if (controller.isLoading)
                    CustomLoader(isLoading: controller.isLoading),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _investListUI() {
    return Column(
      children: [
        // controller.stakeProductsList.length > 3?
        SizedBox(
          height: 30.h,
          child: ListView.builder(
            controller: _trendPageController,
            scrollDirection: Axis.horizontal,
            itemCount: controller.stakeProductsList.take(3).length,
            itemBuilder: (context, index) {
              final animation = CurvedAnimation(
                parent: _iconAnimController,
                curve: Interval(
                  index / controller.stakeProductsList.take(3).length,
                  1,
                  curve: Curves.easeOutBack,
                ),
              );
              final coinModel = controller.stakeProductsList
                  .take(3)
                  .toList()[index];

              // SAFETY CHECK
              if (coinModel.plans.isEmpty) {
                return const SizedBox();
              }

              final int selectedPlanIndex =
                  _selectedPlanByCoin[index] ?? 0;
              final int safePlanIndex = selectedPlanIndex.clamp(
                0,
                coinModel.plans.length - 1,
              );
              final StakePlan item = coinModel.plans[safePlanIndex];

              // ✅ PROGRESS CALCULATION
              final int currentStep = controller.stakingFilledToStep(
                item.stakingFilled,
                6,
              );

              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: Padding(
                    padding: EdgeInsets.only(right: 15.sp),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 65.w),
                      child: Container(
                        padding: EdgeInsets.all(15.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.sp),
                          border: Border.all(
                            color: ThemeOutLineColor.getOutLineColor(context),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                if (item.image.isNotEmpty)
                                  SizedBox(
                                    height: 22.sp,
                                    width: 22.sp,
                                    child: SvgPicture.network(
                                      item.image,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                if (item.image.isNotEmpty)
                                  SizedBox(width: 12.sp),
                                Expanded(
                                  child: CustomText(
                                    label: item.crypto,
                                    fontSize: 14.5.sp,
                                    fontColour:
                                        ThemeTextOneColor.getTextOneColor(
                                          context,
                                        ),
                                    labelFontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10.sp),

                            // dotted divider
                            DottedDivider(),

                            SizedBox(height: 15.sp),

                            SizedBox(
                              height: 9.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: coinModel.plans.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: 10.sp),
                                itemBuilder: (context, planIndex) {
                                  final plan = coinModel.plans[planIndex];
                                  final bool isSelected =
                                      planIndex == safePlanIndex;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedPlanByCoin[index] = planIndex;
                                      });
                                    },
                                    child: Container(
                                      width: 45.w,
                                      padding: EdgeInsets.all(12.sp),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.sp),
                                        border: Border.all(
                                          color: isSelected
                                              ? ThemeInversePrimaryColor
                                                  .getInversePrimaryColor(
                                                    context,
                                                  )
                                              : ThemeOutLineColor
                                                  .getOutLineColor(context),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            label:
                                                '${plan.rate} % ${AppLocalizations.of(context)!.estAPR}',
                                            fontSize: 13.sp,
                                            labelFontWeight: FontWeight.bold,
                                          ),
                                          SizedBox(height: 6.sp),
                                          CustomText(
                                            label: plan.stakeType == 'flexible'
                                                ? plan.stakeType
                                                : '${plan.duration} ${AppLocalizations.of(context)!.days}',
                                            fontSize: 12.5.sp,
                                            labelFontWeight: FontWeight.w500,
                                          ),
                                          SizedBox(height: 6.sp),
                                          CustomText(
                                            label:
                                                '${plan.maxLimit} Max',
                                            fontSize: 12.5.sp,
                                            labelFontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            SizedBox(height: 12.sp),

                            /// -------- PROGRESS ----------
                            LinearProgressBar(
                              maxSteps: 6,
                              progressType:
                                  LinearProgressBar.progressTypeLinear,
                              currentStep: currentStep,
                              progressColor:
                                  ThemeInversePrimaryColor.getInversePrimaryColor(
                                    context,
                                  ),
                              backgroundColor:
                                  ThemeSurfaceContainerLowColor.getSurfaceContainerLowColor(
                                    context,
                                  ),
                              borderRadius: BorderRadius.circular(25),
                            ),

                            SizedBox(height: 10.sp),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomText(
                                  label: item.stakingFilled,
                                  fontSize: 14.5.sp,
                                  labelFontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                            SizedBox(height: 12.sp),
                            // animated expanding area (buttons)
                            // AnimatedSize handles height transitions, AnimatedOpacity fades content in/out.
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: controller.isLoading
                                  ? const CustomProgressDialog()
                                  : CustomButton(
                                      height: 4.5.h,
                                      label: AppLocalizations.of(
                                        context,
                                      )!.investNow,
                                      onTap: () async {

                                          controller.changePlanTab(
                                            context,
                                            safePlanIndex,
                                          );
                                          savingsSubscribeAlert(
                                            context,
                                            controller,
                                            coinModel,
                                          );

                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 15.sp),

        // Page indicator (auto updates based on index)
        Center(
          child: SmoothPageIndicator(
            controller: _trendPageController,
            count: controller.stakeProductsList.length,
            effect: ExpandingDotsEffect(
              dotHeight: 10,
              dotWidth: 12,
              spacing: 6,
              expansionFactor: 2.5,
              activeDotColor: ThemeInversePrimaryColor.getInversePrimaryColor(
                context,
              ),
              dotColor: ThemeOutLineColor.getOutLineColor(context),
              radius: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _calculateCryptoUI() {
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
        SizedBox(
          // height: 30.h,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.sp),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(15.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.sp),
                  border: Border.all(
                    color: ThemeOutLineColor.getOutLineColor(context),
                    width: 5.sp,
                  ),
                ),
                child: Column(
                  children: [
                    CustomTextFieldWidget(
                      label: AppLocalizations.of(context)!.chooseCrypto,
                      controller: controller.chooseCryptoController,
                      readOnly: true,
                      filled: true,
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 15.sp),
                        child: SvgPicture.asset(
                          AppThemeIcons.arrowDown(context),
                          width: 10.sp,
                          height: 10.sp,
                        ),
                      ),
                      onTap: () {
                        _showChooseCryptoTypeBottomSheet(context);
                      },
                      hintText: AppLocalizations.of(context)!.selectCoin,
                    ),
                    controller.selectItem != null
                        ? SizedBox(height: 15.sp)
                        : SizedBox.shrink(),
                    controller.selectItem != null
                        ? CustomTextFieldWidget(
                            label: AppLocalizations.of(context)!.investmentType,
                            controller: controller.investmentTypeController,
                            readOnly: true,
                            filled: true,
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 15.sp),
                              child: SvgPicture.asset(
                                AppThemeIcons.arrowDown(context),
                                width: 10.sp,
                                height: 10.sp,
                              ),
                            ),
                            onTap: () {
                              _showInvestmentTypeBottomSheet(context);
                            },
                            hintText: '',
                          )
                        : SizedBox.shrink(),
                    controller.selectItem != null
                        ? SizedBox(height: 15.sp)
                        : SizedBox.shrink(),
                    controller.selectItem != null
                        ? CustomTextFieldWidget(
                            label: AppLocalizations.of(context)!.plan,
                            controller: controller.planController,
                            readOnly: true,
                            filled: true,
                            suffixIcon: Padding(
                              padding: EdgeInsets.only(right: 15.sp),
                              child: SvgPicture.asset(
                                AppThemeIcons.arrowDown(context),
                                width: 10.sp,
                                height: 10.sp,
                              ),
                            ),
                            onTap: () {
                              _showPlanTypeBottomSheet(context);
                            },
                            hintText: '',
                          )
                        : SizedBox.shrink(),
                    controller.selectItem != null
                        ? SizedBox(height: 20.sp)
                        : SizedBox.shrink(),

                    controller.selectItem != null
                        ? CustomTextFieldWidget(
                            line: 1,
                            label: AppLocalizations.of(context)!.amount,
                            onChanged: (text) {
                              controller.onCalculationAmountChanged(
                                context,
                                text,
                                controller.planListID.toString(),
                              );
                            },

                            controller: controller.calculateAmountController,
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
                            hintText: '',
                            onValidate: (value) {
                              if (value!.isEmpty) {
                                return AppLocalizations.of(
                                  context,
                                )!.pleaseEnterStackAmount;
                              }
                              return null;
                            },
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: 15.sp),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        label:
                            "${AppLocalizations.of(context)!.min} ${controller.planListMinLimit} - ${AppLocalizations.of(context)!.max} ${controller.planListMaxLimit}",
                        // 'Min ${controller.planListMinLimit.toString()} -'
                        // 'Max ${controller.planListMaxLimit.toString()}',
                        fontSize: 15.sp,
                        fontColour: ThemeTextOneColor.getTextOneColor(context),
                        labelFontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        label:
                            '${AppLocalizations.of(context)!.estimatedEarnings} / ${AppLocalizations.of(context)!.day}',
                        fontSize: 15.sp,
                        fontColour: ThemeTextOneColor.getTextOneColor(context),
                        labelFontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          label:
                              '+ ${safeValue(controller.calculationPreviewDaily)} ${controller.coinValue}',
                          fontSize: 18.sp,
                          fontColour: Theme.of(context).colorScheme.tertiary,
                          labelFontWeight: FontWeight.bold,
                        ),
                        CustomText(
                          label:
                              '${AppLocalizations.of(context)!.apr} ${controller.planListRate} %',
                          fontSize: 15.sp,
                          fontColour: ThemeTextOneColor.getTextOneColor(
                            context,
                          ),
                          labelFontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    SizedBox(height: 15.sp),
                    if (controller.selectItem != null)
                      controller.isLoading
                          ? const CustomProgressDialog()
                          : CustomButton(
                              height: 4.5.h,
                              label: AppLocalizations.of(context)!.investNow,
                              onTap: () async {
                                // controller.changePlanTab(context, 0);
                                if (controller
                                    .calculateAmountController
                                    .text
                                    .isEmpty) {
                                  _showErrorToast(
                                    context,
                                    AppLocalizations.of(
                                      context,
                                    )!.pleaseEnterStackAmount,
                                  );
                                } else {

                                    controller.stakePreviewDaily = '';
                                    savingsSubscribeAlert(
                                      context,
                                      controller,
                                      controller.selectItem!,
                                    );

                                }
                              },
                            ),
                    // balances (right aligned)
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _allProductsUI() {
    return controller.stakeProductsList.isEmpty
        ? Center(
            child: CustomText(
              label: controller.isLoading
                  ? AppLocalizations.of(context)!.loadingCoins
                  : AppLocalizations.of(context)!.noCoinsAvailable,
              fontSize: 15.sp,
              labelFontWeight: FontWeight.w600,
            ),
          )
        : RefreshIndicator(
            onRefresh: () async {
              controller.doGetStakeProductsAPI(context);
            },
            child: ListView.builder(
              itemCount: controller.stakeProductsList.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (_, index) {
                final coinModel = controller.stakeProductsList[index];

                // SAFETY CHECK
                if (coinModel.plans.isEmpty) {
                  return const SizedBox();
                }

                // ✅ USE FIRST PLAN OF EACH COIN
                final StakePlan item = coinModel.plans[0];
                final bool isExpanded = controller.expandedIndex == index;

                return Padding(
                  padding: EdgeInsets.only(bottom: 15.sp),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.sp),
                      onTap: () => controller.toggleExpand(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.all(12.sp),
                        decoration: BoxDecoration(
                          color: ThemeTextFormFillColor.getTextFormFillColor(
                            context,
                          ),

                          border: Border.all(
                            width: isExpanded ? 5.sp : 5.sp,
                            color: isExpanded
                                ? ThemeOutLineColor.getOutLineColor(context)
                                : ThemeOutLineColor.getOutLineColor(context),
                          ),
                          borderRadius: BorderRadius.circular(12.sp),
                          // Subtle elevation effect when expanded
                          boxShadow: isExpanded
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 14.sp,
                                    offset: Offset(0, 6.sp),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 22.sp,
                                      width: 22.sp,
                                      child: SvgPicture.network(
                                        item.image,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    SizedBox(width: 15.sp),
                                    CustomText(
                                      label: item.crypto,
                                      fontSize: 15.sp,
                                      labelFontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),

                                AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Icon(
                                    Icons.expand_more,
                                    color: ThemeTextColor.getTextColor(context),
                                    size: 22.sp,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10.sp),

                            // dotted divider
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.sp),
                              child: DottedDivider(
                                dashWidth: 5.sp,
                                color: ThemeTextOneColor.getTextOneColor(
                                  context,
                                ),
                              ),
                            ),
                            SizedBox(height: 15.sp),

                            // balances (right aligned)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      label: AppLocalizations.of(context)!.term,
                                      fontSize: 15.sp,
                                      fontColour:
                                          ThemeTextOneColor.getTextOneColor(
                                            context,
                                          ),
                                      labelFontWeight: FontWeight.bold,
                                    ),
                                    CustomText(
                                      label: item.stakeType,
                                      fontSize: 15.sp,
                                      labelFontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.sp),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      label: AppLocalizations.of(
                                        context,
                                      )!.estAPR,
                                      fontSize: 15.sp,
                                      fontColour:
                                          ThemeTextOneColor.getTextOneColor(
                                            context,
                                          ),
                                      labelFontWeight: FontWeight.bold,
                                    ),
                                    CustomText(
                                      label: '${item.rate} %',
                                      fontSize: 15.sp,
                                      fontColour: Theme.of(
                                        context,
                                      ).colorScheme.tertiary,
                                      labelFontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.sp),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      label: AppLocalizations.of(
                                        context,
                                      )!.duration,
                                      fontSize: 15.sp,
                                      fontColour:
                                          ThemeTextOneColor.getTextOneColor(
                                            context,
                                          ),
                                      labelFontWeight: FontWeight.bold,
                                    ),
                                    CustomText(
                                      label: item.duration,
                                      fontSize: 15.sp,
                                      labelFontWeight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.sp),
                              ],
                            ),
                            SizedBox(height: 15.sp),

                            isExpanded
                                ? SizedBox(
                                    // height: MediaQuery.of(context).size.height * 0.2,
                                    child: ListView.builder(
                                      itemCount: coinModel.plans.length,
                                      scrollDirection: Axis.vertical,
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (_, index) {
                                        final StakePlan itemTwo =
                                            coinModel.plans[index];

                                        return Container(
                                          padding: EdgeInsets.all(15.sp),
                                          decoration: BoxDecoration(
                                            color:
                                                ThemeTextFormFillColor.getTextFormFillColor(
                                                  context,
                                                ),
                                            borderRadius: BorderRadius.circular(
                                              15.sp,
                                            ),
                                            border: Border.all(
                                              color:
                                                  ThemeOutLineColor.getOutLineColor(
                                                    context,
                                                  ),
                                              width: 5.sp,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomText(
                                                    label: AppLocalizations.of(
                                                      context,
                                                    )!.term,
                                                    fontSize: 15.sp,
                                                    fontColour:
                                                        ThemeTextOneColor.getTextOneColor(
                                                          context,
                                                        ),
                                                    labelFontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  CustomText(
                                                    label: itemTwo.stakeType,
                                                    fontSize: 15.sp,
                                                    labelFontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 12.sp),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomText(
                                                    label: AppLocalizations.of(
                                                      context,
                                                    )!.estAPR,
                                                    fontSize: 15.sp,
                                                    fontColour:
                                                        ThemeTextOneColor.getTextOneColor(
                                                          context,
                                                        ),
                                                    labelFontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  CustomText(
                                                    label:
                                                        '${double.parse(itemTwo.minLimit.toString()).toStringAsFixed(2)}Min-${double.parse(itemTwo.maxLimit).toStringAsFixed(2)}Max',
                                                    fontSize: 15.sp,
                                                    labelFontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 12.sp),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CustomText(
                                                    label: AppLocalizations.of(
                                                      context,
                                                    )!.duration,
                                                    fontSize: 15.sp,
                                                    fontColour:
                                                        ThemeTextOneColor.getTextOneColor(
                                                          context,
                                                        ),
                                                    labelFontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  CustomText(
                                                    label: itemTwo.duration,
                                                    fontSize: 15.sp,
                                                    labelFontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 12.sp),
                                              // animated expanding area (buttons)
                                              // AnimatedSize handles height transitions, AnimatedOpacity fades content in/out.
                                              AnimatedSize(
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeInOut,
                                                child: ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                        maxHeight: 50,
                                                      ),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 12.sp,
                                                    ),
                                                    child: AnimatedOpacity(
                                                      duration: const Duration(
                                                        milliseconds: 250,
                                                      ),
                                                      opacity: 1.0,
                                                      curve: Curves.easeInOut,
                                                      child:
                                                          controller.isLoading
                                                          ? const CustomProgressDialog()
                                                          : CustomButton(
                                                              label:
                                                                  AppLocalizations.of(
                                                                    context,
                                                                  )!.subscribe,
                                                              onTap: () async {

                                                                  controller
                                                                      .changePlanTab(
                                                                    context,
                                                                    0,
                                                                  );
                                                                  savingsSubscribeAlert(
                                                                    context,
                                                                    controller,
                                                                    coinModel,
                                                                  );



                                                              },
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  void _showChooseCryptoTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      builder: (_) {
        return Consumer<SavingsController>(
          builder: (context, value, child) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(15.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          label: AppLocalizations.of(context)!.selectCoin,
                          fontSize: 16.sp,
                          labelFontWeight: FontWeight.bold,
                          fontColour: ThemeTextColor.getTextColor(context),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset(
                            AppBasicIcons.close,
                            height: 20.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.sp),

                    Expanded(
                      child: value.isLoading
                          ? const CustomProgressDialog()
                          : controller.stakeProductsList.isEmpty
                          ? customNoRecordsFound(context)
                          : ListView.builder(
                              itemCount: controller.stakeProductsList.length,
                              padding: EdgeInsets.all(15.sp),
                              itemBuilder: (BuildContext context, int i) {
                                final list = controller.stakeProductsList[i];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  onTap: () async {
                                    controller.coinListModule(context, list);
                                    Navigator.pop(context);
                                  },
                                  title: CustomText(
                                    label: list.coin,
                                    fontSize: 15.sp,
                                    labelFontWeight: FontWeight.bold,
                                    fontColour: ThemeTextColor.getTextColor(
                                      context,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showInvestmentTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      builder: (_) {
        return Consumer<SavingsController>(
          builder: (context, value, child) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(15.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          label: AppLocalizations.of(context)!.investmentType,
                          fontSize: 16.sp,
                          labelFontWeight: FontWeight.bold,
                          fontColour: ThemeTextColor.getTextColor(context),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset(
                            AppBasicIcons.close,
                            height: 20.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.sp),

                    Expanded(
                      child: value.isLoading
                          ? const CustomProgressDialog()
                          : controller.stakeTypeList.isEmpty
                          ? customNoRecordsFound(context)
                          : ListView.builder(
                              itemCount: controller.stakeTypeList.length,
                              itemBuilder: (BuildContext context, int i) {
                                final list = controller.stakeTypeList[i];

                                // SAFETY CHECK
                                if (list.isEmpty) {
                                  return const SizedBox();
                                }
                                return InkWell(
                                  onTap: () {
                                    controller.updateInvestmentType(list);

                                    Navigator.pop(context);
                                  },
                                  child: CustomText(
                                    label: list ?? '',
                                    fontSize: 16.sp,
                                    labelFontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPlanTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      builder: (_) {
        return Consumer<SavingsController>(
          builder: (context, value, child) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(15.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          label: AppLocalizations.of(context)!.plan,
                          fontSize: 16.sp,
                          labelFontWeight: FontWeight.bold,
                          fontColour: ThemeTextColor.getTextColor(context),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset(
                            AppBasicIcons.close,
                            height: 20.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.sp),

                    Expanded(
                      child: value.isLoading
                          ? const CustomProgressDialog()
                          : value.stakeProductsList.isEmpty
                          ? customNoRecordsFound(context)
                          : ListView.builder(
                              itemCount:
                                  value.investmentStakeType.toLowerCase() ==
                                      'flexible'
                                  ? value.flexibleDurationList.length
                                  : value.fixedDurationList.length,
                              itemBuilder: (BuildContext context, int i) {
                                final StakePlan payList;
                                if (value.investmentStakeType.toLowerCase() ==
                                    'flexible') {
                                  payList = value.flexibleDurationList[i];
                                } else {
                                  payList = value.fixedDurationList[i];
                                }

                                return InkWell(
                                  onTap: () {
                                    value.planListModule(context, payList);
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 15.sp),
                                    child: CustomText(
                                      label:
                                          payList.stakeType.toLowerCase() ==
                                              'fixed'
                                          ? '${payList.duration} days-${payList.rate} %' ??
                                                ''
                                          : "${AppLocalizations.of(context)!.flexible} - ${payList.rate} %",
                                      fontSize: 16.sp,
                                      labelFontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
