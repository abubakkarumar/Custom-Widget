import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_no_records.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import 'affiliate_controller.dart';

class AffiliateView extends StatefulWidget {
  final bool isSelectedFrom;
  const AffiliateView({super.key, required this.isSelectedFrom});

  @override
  State<AffiliateView> createState() => _AffiliateViewState();
}

class _AffiliateViewState extends State<AffiliateView> {
  AffiliateController controller = AffiliateController();

  @override
  void initState() {
    Future.delayed(Duration.zero).whenComplete(() {
      controller.getAffiliateDetails(context);
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    controller.resetData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AffiliateController>(
      builder: (context, value, _) {
        controller = value;
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () {
              return Future.delayed(Duration.zero).whenComplete(() async {
                controller.getAffiliateDetails(context);
              });
            },
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: _buildAffiliateBody(context),
                ),
                if (controller.isLoading) const CustomLoader(isLoading: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAffiliateBody(BuildContext context) {
    if (!widget.isSelectedFrom) {
      if (controller.affiliateStatus.isNotEmpty &&
          controller.affiliateStatus != 'null') {
        print("JLJLJL ${controller.isAffiliate} AND ${controller.statusText}");

        if (controller.isAffiliate == '1') {
          return affiliateFormUIApproved();
        } else if (controller.isAffiliate == '0' &&
            controller.statusText == 'pending') {
          return affiliateFormUIWhilePending();
        } else {
          return affiliateFormUI(context);
        }
      }
    }
    return affiliateFormUI(context);
  }

  Widget affiliateFormUI(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: controller.affiliateFormKey,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom+ 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 9.h),
              Image.asset(AppBasicIcons.affiliateContent),

              SizedBox(height: 15.sp),
              CustomText(
                label: AppLocalizations.of(context)!.joinTheZayroAffiliateProgram,
                fontSize: 16.sp,
                labelFontWeight: FontWeight.w600,
              ),

              SizedBox(height: 15.sp),

              _input(
                label: AppLocalizations.of(context)!.nickName,
                controller: controller.nickNameController,
                validator: (v) => AppValidations().nickName(context, v ?? ""),
              ),

              _dropdownField(
                label: AppLocalizations.of(context)!.yourAffiliateType,
                controller: controller.affiliateTypeController,
                onTap: () => _showBottomSheet(
                  context,
                  title: AppLocalizations.of(context)!.selectYourAffiliateType,
                  list: controller.affiliateTypeList(context),
                  onSelect: controller.setAffiliateTypeDetails,
                ),
              ),

              _dropdownField(
                label: AppLocalizations.of(context)!.language,
                controller: controller.languageController,
                onTap: () => _showBottomSheet(
                  context,
                  title: AppLocalizations.of(context)!.selectYourLanguage,
                  list: controller.languageList(context),
                  onSelect: controller.setLanguageTypeDetails,
                ),
              ),

              _input(
                label: AppLocalizations.of(context)!.contactInfo,
                controller: controller.contactInfoController,
                validator: (v) => AppValidations().contactInfo(context, v ?? ""),
              ),

              _dropdownField(
                label: AppLocalizations.of(
                  context,
                )!.whichCountryOrRegionDoYouPlanOnMarketingIn,
                controller: controller.countryController,
                onTap: () => _showBottomSheet(
                  context,
                  title: AppLocalizations.of(context)!.selectYourCountry,
                  list: controller.countryList(context),
                  onSelect: controller.setCountryTypeDetails,
                ),
              ),

              _dropdownField(
                label: AppLocalizations.of(context)!.primaryPromoPlatform,
                controller: controller.primaryPromoPlatformTypeController,
                onTap: () => _showBottomSheet(
                  context,
                  title: AppLocalizations.of(
                    context,
                  )!.selectPrimaryPromoPlatformType,
                  list: controller.promoPlatformList(context),
                  onSelect: controller.setPromoTypeDetails,
                ),
              ),

              _input(
                label: AppLocalizations.of(
                  context,
                )!.isThereAnythingElseThatYouWouldLikeToShare,
                controller: controller.anyAnwserController,
                validator: (v) => AppValidations().additionalCommentsValidator(
                  context,
                  v ?? "",
                ),
              ),

              _socialMediaPlatforms(controller, context),
              SizedBox(height: 15.sp),

              _dropdownField(
                label: AppLocalizations.of(
                  context,
                )!.howDidYouHearAboutZayroPlatform,
                controller: controller.zayroPlatformController,
                onTap: () => _showBottomSheet(
                  context,
                  title: AppLocalizations.of(context)!.selectYourZayroPlatform,
                  list: controller.zayroPlatformList(context),
                  onSelect: controller.setZayroPlatformTypeDetails,
                ),
              ),

              SizedBox(height: 15.sp),

              // if (controller.statusValue.toString() == 'Pending')
              controller.isLoading
                  ? const CustomProgressDialog()
                  :
              Row(
                children: [
                  Expanded(
                    child: CancelButton(
                      label: AppLocalizations.of(context)!.reset,
                      onTap: controller.resetData,
                    ),
                  ),
                  SizedBox(width: 18.sp),
                  Expanded(
                    child: CustomButton(
                      label: AppLocalizations.of(context)!.submit,
                      onTap: () {
                        if (controller.affiliateFormKey.currentState!
                            .validate()) {
                          controller.doSubmitAffiliateDetailsAPI(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget affiliateFormUIWhilePending() {
    return SingleChildScrollView(
      child: Form(
        key: controller.affiliateFormKey,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom+ 12.h),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 9.h),

                  Image.asset(AppBasicIcons.affiliateContent),

                  SizedBox(height: 15.sp),
                  CustomText(
                    label: AppLocalizations.of(
                      context,
                    )!.joinTheZayroAffiliateProgram,
                    fontSize: 16.sp,
                    labelFontWeight: FontWeight.w600,
                  ),

                  SizedBox(height: 15.sp),
                  _input(
                    label: AppLocalizations.of(context)!.nickName,
                    controller: controller.nickNameController,
                    readOnly: true,
                    validator: (v) => AppValidations().nickName(context, v ?? ""),
                  ),

                  _dropdownField(
                    label: AppLocalizations.of(context)!.yourAffiliateType,
                    controller: controller.affiliateTypeController,
                    onTap: () {},
                  ),

                  _dropdownField(
                    label: AppLocalizations.of(context)!.language,
                    controller: controller.languageController,
                    onTap: () {},
                  ),

                  _input(
                    label: AppLocalizations.of(context)!.contactInfo,
                    readOnly: true,
                    controller: controller.contactInfoController,
                    validator: (v) =>
                        AppValidations().contactInfo(context, v ?? ""),
                  ),

                  _dropdownField(
                    label: AppLocalizations.of(
                      context,
                    )!.whichCountryOrRegionDoYouPlanOnMarketingIn,
                    controller: controller.countryController,
                    onTap: () {},
                  ),

                  _dropdownField(
                    label: AppLocalizations.of(context)!.primaryPromoPlatform,
                    controller: controller.primaryPromoPlatformTypeController,
                    onTap: () {},
                  ),

                  _input(
                    label: AppLocalizations.of(
                      context,
                    )!.isThereAnythingElseThatYouWouldLikeToShare,
                    readOnly: true,
                    controller: controller.anyAnwserController,
                    lines: 5,
                    validator: (v) => AppValidations()
                        .additionalCommentsValidator(context, v ?? ""),
                  ),

                  SizedBox(height: 12.sp),
                  _socialMediaPlatforms(controller, context),
                  SizedBox(height: 15.sp),

                  _dropdownField(
                    label: AppLocalizations.of(
                      context,
                    )!.howDidYouHearAboutZayroPlatform,
                    controller: controller.zayroPlatformController,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget affiliateFormUIApproved() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        _statsSection(controller),
        SizedBox(height: 15.sp),

        CustomText(
          label: AppLocalizations.of(context)!.yourPortfolio,
          fontSize: 16.5.sp,
          labelFontWeight: FontWeight.bold,
        ),
        SizedBox(height: 15.sp),

        /// LINK
        CustomTextFieldWidget(
          label: AppLocalizations.of(context)!.link,
          controller: controller.linkController,
          readOnly: true,
          suffixIcon: controller.linkController.text.isNotEmpty?GestureDetector(
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
          ):SizedBox(),
          hintText: '',
        ),

        SizedBox(height: 15.sp),

        /// CODE
        CustomTextFieldWidget(
          label: AppLocalizations.of(context)!.code,
          controller: controller.codeController,
          readOnly: true,
          suffixIcon: controller.codeController.text.isNotEmpty?GestureDetector(
            onTap: () {
              _copy(controller.codeController.text);
            },
            child: Padding(
              padding: EdgeInsets.only(right: 12.sp),
              child: SvgPicture.asset(
                AppBasicIcons.copy,
                height: 18.sp,
              ),
            ),
          ):SizedBox(),
          hintText: '',
        ),

        SizedBox(height: 15.sp),

        /// TABS
        _tabHeader(controller),

        SizedBox(height: 15.sp),

        /// BODY
        controller.isDownline
            ? _downlineView(controller)
            : affiliateHistoryView(controller),
      ],
    );
  }

  // ============================================================
  // COMMON INPUT
  // ============================================================
  Widget _input({
    required String label,
    required TextEditingController controller,
    FormFieldValidator<String>? validator,
    AutovalidateMode? autoValidate,
    int lines = 1,
    bool? readOnly,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sp),
      child: CustomTextFieldWidget(
        label: label,
        controller: controller,
        line: lines,
        filled: true,
        autoValidateMode: autoValidate,
        onValidate: validator,
        hintText: '',
        readOnly: readOnly ?? false,
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.sp),
      child: CustomTextFieldWidget(
        label: label,
        controller: controller,
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
        onTap: onTap,
        hintText: '',
      ),
    );
  }

  // ============================================================
  // COMMON BOTTOM SHEET
  // ============================================================
  void _showBottomSheet(
    BuildContext context, {
    required String title,
    required List<String> list,
    required Function({required int id, required String type}) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            color: ThemeBackgroundColor.getBackgroundColor(context),
            border: Border.all(
              color: ThemeOutLineColor.getOutLineColor(context),
              width: 5.sp,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.sp),
              topRight: Radius.circular(20.sp),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 15.sp),

                /// 🔹 Header
                Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        label: title,
                        labelFontWeight: FontWeight.bold,
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
                ),

                SizedBox(height: 12.sp),
                Divider(
                  color: ThemeOutLineColor.getOutLineColor(context),
                  thickness: 6.sp,
                  height: 5.sp,
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      return GestureDetector(
                        onTap: () {
                          onSelect(id: i, type: list[i]);
                          AppNavigator.pop();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 13.sp,
                            right: 13.sp,
                            top: 13.sp,
                            bottom: 10.sp,
                          ),
                          child: CustomText(
                            label: list[i],
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
  }

  Widget _socialMediaPlatforms(
    AffiliateController controller,
    BuildContext context,
  ) {
    final locale = AppLocalizations.of(context)!;
    final platforms = controller.socialMediaPlatformsList(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label: locale.otherSocialMediaPlatforms,
          labelFontWeight: FontWeight.w500,
          fontSize: 15.sp,
        ),
        SizedBox(height: 12.sp),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: platforms.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 10,
            childAspectRatio: 3.5,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => controller.toggleSocialPlatform(index),
              child: Row(
                children: [
                  CheckboxBox(
                    isActive: controller.selectedSocialIndexes.contains(index),
                  ),
                  SizedBox(width: 8.sp),
                  Expanded(
                    child: CustomText(
                      label: platforms[index],
                      fontSize: 14.5.sp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // STATS
  // ------------------------------------------------------------
  Widget _statsSection(AffiliateController c) {
    return Consumer<AffiliateController>(
      builder: (context, value, _) {
        controller = value;
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    iconPath: AppThemeIcons.sponsorReferral(context),
                    title: AppLocalizations.of(context)!.yourSponsor,
                    value: controller.mySponsor,
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: StatCard(
                    iconPath: AppThemeIcons.downlineReferral(context),
                    title: AppLocalizations.of(context)!.totalDownline,
                    value: controller.directCount,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.sp),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    iconPath: AppThemeIcons.earningReferral(context),
                    title: "${AppLocalizations.of(context)!.totalEarnings} USD",
                    value: controller.totalEarnings,
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: StatCard(
                    iconPath: AppThemeIcons.earningTodayReferral(context),
                    title: "${AppLocalizations.of(context)!.earningsToday} USD",
                    value: controller.earningsToday,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // TAB HEADER
  // ------------------------------------------------------------
  Widget _tabHeader(AffiliateController c) {
    return Row(
      children: [
        _tabBtn(
          title: AppLocalizations.of(context)!.downlineInformation,
          active: c.isDownline,
          onTap: () {
            c.changeTab(true);
          },
        ),
        SizedBox(width: 25.sp),
        _tabBtn(
          title:
              "${AppLocalizations.of(context)!.affiliate} ${AppLocalizations.of(context)!.history}",
          active: !c.isDownline,
          onTap: () {
            c.changeTab(false);
          },
        ),
      ],
    );
  }

  Widget _tabBtn({
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.sp),
        alignment: Alignment.center,
        child: Column(
          children: [
            CustomText(
              label: title,
              labelFontWeight: FontWeight.w600,
              fontColour: active
                  ? ThemeInversePrimaryColor.getInversePrimaryColor(context)
                  : ThemeTextOneColor.getTextOneColor(context),
            ),
            SizedBox(height: 10.sp),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 3.sp,
              width: active ? 30.sp : 0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: ThemeInversePrimaryColor.getInversePrimaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DOWNLINE
  // ------------------------------------------------------------
  Widget _downlineView(AffiliateController c) {
    return Expanded(
      child: Container(
        child: c.directUsersList.isEmpty
            ? customNoRecordsFound(context)
            : ListView.builder(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10.h),
                itemCount: c.directUsersList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final item = c.directUsersList[index];

                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 15.sp),
                        padding: EdgeInsets.only(
                          left: 13.sp,
                          right: 13.sp,
                          top: 4.sp,
                          bottom: 10.sp,
                        ),
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
                          children: [
                            _row(
                              context,
                              AppLocalizations.of(context)!.userName,
                              item.username ?? "",
                            ),
                            _row(
                              context,
                              AppLocalizations.of(context)!.fullEarned,
                              item.totalUsd ?? "",
                            ),
                            _row(
                              context,
                              AppLocalizations.of(context)!.userStatus,
                              item.verifiedKyc == 1 ? "Verified" : "Pending",
                              valueColor: item.verifiedKyc == 1
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 10.sp, right: 10.sp, top: 13.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            label: label,
            fontSize: 14.5.sp,
            labelFontWeight: FontWeight.w500,
          ),
          Expanded(
            child: CustomText(
              label: value,
              fontSize: 14.sp,
              align: TextAlign.end,
              labelFontWeight: FontWeight.bold,
              fontColour: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HISTORY WITH LEVEL DROPDOWN
  // ------------------------------------------------------------
  Widget affiliateHistoryView(AffiliateController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            final level = index + 1;
            final isActive = c.selectedLevel == level;

            return GestureDetector(
              onTap: () => c.filterHistoryByLevel(level),
              child: Padding(
                padding: EdgeInsets.only(right: 18.sp),
                child: Column(
                  children: [
                    CustomText(
                      label: "Level $level",
                      fontSize: 16.sp,
                      fontColour: isActive
                          ? ThemeInversePrimaryColor.getInversePrimaryColor(
                              context,
                            )
                          : ThemeTextOneColor.getTextOneColor(context),
                      labelFontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    SizedBox(height: 8.sp),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 2,
                      width: isActive ? 55 : 0,
                      color: ThemeInversePrimaryColor.getInversePrimaryColor(
                        context,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),

        SizedBox(height: 15.sp),

        /// ================= HISTORY LIST =================
        c.filteredHistory.isEmpty
            ? customNoRecordsFound(context)
            : SizedBox(
                height: 25.h,
                child: ListView.builder(
                  itemCount: c.filteredHistory.length,
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final item = c.filteredHistory[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 15.sp),
                      padding: EdgeInsets.only(
                        left: 13.sp,
                        right: 13.sp,
                        top: 4.sp,
                        bottom: 10.sp,
                      ),
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
                        children: [
                          _row(
                            context,
                            AppLocalizations.of(context)!.dateTime,
                            item.createdAt ?? "",
                          ),
                          _row(
                            context,
                            AppLocalizations.of(context)!.creditedToken,
                            item.commissionUsd ?? "",
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  // ------------------------------------------------------------
  // COMMON
  // ------------------------------------------------------------

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    CustomAnimationToast.show(
      message: AppLocalizations.of(context)!.copiedSuccessfully,
      type: ToastType.success,
      context: context,
    );
  }
}

class StatCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String value;

  const StatCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.sp),
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(context),
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 4.sp,
        ),
      ),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, width: 24.sp, height: 24.sp),
          SizedBox(width: 12.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  label: title,
                  fontColour: ThemeTextOneColor.getTextOneColor(context),
                  labelFontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
                SizedBox(height: 10.sp),
                CustomText(
                  label: value,
                  fontSize: 15.sp,
                  labelFontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CheckboxBox extends StatelessWidget {
  final bool isActive;

  const CheckboxBox({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: isActive
            ? null
            : Border.all(color: Colors.grey.shade500, width: 2),
        gradient: isActive
            ? const LinearGradient(
                colors: [Colors.blueAccent, Colors.deepPurpleAccent],
              )
            : null,
      ),
      child: isActive
          ? const Icon(Icons.check, size: 15, color: Colors.white)
          : null,
    );
  }
}
