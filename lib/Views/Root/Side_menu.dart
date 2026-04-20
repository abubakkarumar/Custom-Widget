// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/app_secure_storage.dart';
import 'package:zayroexchange/Utility/Basics/biometric_key_service.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/Images/light_image.dart';
import 'package:zayroexchange/Utility/custom_actionbar.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Bottom_Pages/RewardsHub/rewards_hub_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/future_trade_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';
import 'package:zayroexchange/Views/Root/root_controller.dart';
import 'package:zayroexchange/Views/Root/side_menu_usage.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Profile/profile_view.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_view.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Support/support_view.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'package:zayroexchange/material_theme/theme_controller.dart';

class SideMenuView extends StatefulWidget {
  const SideMenuView({super.key});

  @override
  State<SideMenuView> createState() => _SideMenuViewState();
}

class _SideMenuViewState extends State<SideMenuView> {
  // controller will be replaced by the Provider value inside build
  late RootController controller;
  ThemeController themeController = ThemeController();
  SpotTradeController spotTradeController = SpotTradeController();
  FutureTradeController futureTradeController = FutureTradeController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThemeController>().resolveSystemTheme(context);
      controller.getProfile(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<
      RootController,
      ThemeController,
      SpotTradeController,
      FutureTradeController
    >(
      builder: (context, rootController, value1, spotVal, FutureVal, child) {
        controller = rootController;
        themeController = value1;
        spotTradeController = spotVal;
        futureTradeController = FutureVal;
        return Stack(
          children: [
            CustomTotalPageFormat(
              appBarTitle: AppLocalizations.of(context)!.accountSettings,
              showBackButton: true,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: Column(
                  children: [
                    ProfileHeaderExact(
                      name: controller.userName,
                      uid: controller.profileUid,
                      avatarAsset: controller.profileImageUrl, // optional
                      verified: controller.isVerified,
                      controller: controller,
                      onEdit: () => _showImagePicker(context, controller),
                    ),
                    SizedBox(height: 15.sp),
                    Column(
                      children: [
                        /// ------------------- GENERAL SETTINGS -------------------
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.sp),
                            border: Border.all(
                              color: ThemeOutLineColor.getOutLineColor(context),
                              width: 5.sp,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(15.sp),
                                child: CustomText(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.generalSettings,
                                  fontSize: 15.sp,
                                  fontColour: ThemeTextColor.getTextColor(
                                    context,
                                  ),
                                  labelFontWeight: FontWeight.bold,
                                ),
                              ),
                              Divider(
                                color: ThemeOutLineColor.getOutLineColor(
                                  context,
                                ),
                                thickness: 6.sp,
                                height: 5.sp,
                              ),

                              CustomSideMenu(
                                subTitle: AppLocalizations.of(context)!.profile,
                                sideImage: AppThemeIcons.sideMenuProfile(
                                  context,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ProfileView(),
                                    ),
                                  );
                                },
                                navImage: AppThemeIcons.sideNav(context),
                              ),
                              CustomSideMenu(
                                subTitle: AppLocalizations.of(
                                  context,
                                )!.security,
                                sideImage: AppThemeIcons.sideMenuSecurity(
                                  context,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SecurityView(),
                                    ),
                                  );
                                },
                                navImage: AppThemeIcons.sideNav(context),
                              ),
                              CustomSideMenu(
                                subTitle: AppLocalizations.of(
                                  context,
                                )!.rewardsHub,
                                sideImage: AppThemeIcons.sideMenuReferral(
                                  context,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RewardsHubView(),
                                    ),
                                  );
                                },
                                navImage: AppThemeIcons.sideNav(context),
                              ),
                              /* CustomSideMenu(
                                subTitle: AppLocalizations.of(
                                  context,
                                )!.kycVerification,
                                sideImage: AppThemeIcons.sideMenuKycVerification(
                                  context,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const KycView(),
                                    ),
                                  );
                                },
                                navImage: AppThemeIcons.sideNav(context),
                              ),*/
                              CustomSideMenu(
                                subTitle: AppLocalizations.of(context)!.support,
                                sideImage: AppThemeIcons.sideMenuSupport(
                                  context,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SupportView(),
                                    ),
                                  );
                                },
                                navImage: AppThemeIcons.sideNav(context),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 18.sp),

                        /// ------------------- LOGIN SETTINGS -------------------
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.sp),
                            border: Border.all(
                              color: ThemeOutLineColor.getOutLineColor(context),
                              width: 5.sp,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(15.sp),
                                child: CustomText(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.loginSettings,
                                  fontSize: 15.5.sp,
                                  fontColour: ThemeTextColor.getTextColor(
                                    context,
                                  ),
                                  labelFontWeight: FontWeight.bold,
                                ),
                              ),
                              Divider(
                                color: ThemeOutLineColor.getOutLineColor(
                                  context,
                                ),
                                thickness: 6.sp,
                                height: 5.sp,
                              ),

                              /*

                                CustomSideMenu(
                                  subTitle: AppLocalizations.of(context)!.mpIN,
                                  sideImage: AppThemeIcons.sideMenuMPin(
                                    context,
                                  ),
                                  subText: AppLocalizations.of(context,)!.mpINSubText,
                                  onTap: () {},
                                  navImage: AppThemeIcons.sideNav(context),
                                  onToggleOn: () {},
                                  onToggleOff: () {},
                                ),
                  */
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 13.sp,
                                  right: 13.sp,
                                  top: 13.sp,
                                  bottom: 10.sp,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    /// LEFT SECTION
                                    Row(
                                      children: [
                                        /// Icon Box
                                        SvgPicture.asset(
                                          Platform.isAndroid
                                              ? AppThemeIcons.sideMenuFingerprintAuthentication(
                                                  context,
                                                )
                                              : AppThemeIcons.sideMenuFacialRecognition(
                                                  context,
                                                ),
                                          width: 22.sp,
                                          height: 22.sp,
                                        ),

                                        SizedBox(width: 14.sp),

                                        /// Title + Subtitle
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomText(
                                              label: Platform.isAndroid
                                                  ? AppLocalizations.of(
                                                      context,
                                                    )!.fingerprintAuthentication
                                                  : AppLocalizations.of(
                                                      context,
                                                    )!.facialRecognition,
                                              fontSize: 16.sp,
                                              labelFontWeight: FontWeight.w700,
                                            ),

                                            SizedBox(height: 8.sp),
                                            CustomText(
                                              label: Platform.isAndroid
                                                  ? AppLocalizations.of(
                                                      context,
                                                    )!.fingerprintAuthenticationSubText
                                                  : AppLocalizations.of(
                                                      context,
                                                    )!.facialRecognitionSubText,
                                              fontSize: 14.sp,
                                              fontColour:
                                                  ThemeTextOneColor.getTextOneColor(
                                                    context,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    GradientToggle(
                                      value:
                                          AppStorage.getBiometricStatus() == 1,
                                      onChanged: (value) async {
                                        if (AppStorage.getBiometricStatus() ==
                                                null ||
                                            AppStorage.getBiometricStatus() ==
                                                0) {
                                          await BiometricKeyService.generateAndStoreKeys();

                                          final privateKey =
                                              await AppSecureStorage.getPrivateKey();
                                          final publicKey =
                                              await AppSecureStorage.getPublicKey();

                                          await controller
                                              .authenticateBiometric(context)
                                              .whenComplete(() {
                                                if (controller.isSuccess) {
                                                  controller
                                                      .doEnableBiometricAuth(
                                                        context,
                                                      );
                                                }
                                              });

                                          print(' Private Key: $privateKey');
                                          print(' Public Key: $publicKey');
                                        } else {
                                          await controller
                                              .authenticateBiometric(context)
                                              .whenComplete(() {
                                                if (controller.isSuccess) {
                                                  controller
                                                      .doDisableBiometricAuth(
                                                        context,
                                                      );
                                                }
                                              });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              // CustomSideMenu(
                              //          subTitle: Platform.isAndroid ? AppLocalizations.of(
                              //            context,
                              //          )!.fingerprintAuthentication :  AppLocalizations.of(
                              //            context,
                              //          )!.facialRecognition,
                              //          subText: Platform.isAndroid ? AppLocalizations.of(
                              //            context,
                              //          )!.fingerprintAuthenticationSubText :  AppLocalizations.of(
                              //            context,
                              //          )!.facialRecognitionSubText,
                              //          sideImage:  Platform.isAndroid ?  AppThemeIcons.sideMenuFingerprintAuthentication(
                              //            context,
                              //          ) :
                              //              AppThemeIcons.sideMenuFacialRecognition(
                              //                context,
                              //              ),
                              //          onTap: () async {
                              //            if (AppStorage.getBiometricStatus() == null || AppStorage.getBiometricStatus() == 0) {
                              //
                              //              await BiometricKeyService.generateAndStoreKeys();
                              //
                              //              // final privateKey = await AppSecureStorage.getPrivateKey();
                              //              // final publicKey = await AppSecureStorage.getPublicKey();
                              //
                              //              controller.authenticateBiometric(context).whenComplete(() {
                              //                if (controller.isSuccess) {
                              //                  controller.doEnableBiometricAuth(context);
                              //                }
                              //              });
                              //
                              //              // print(' Private Key: $privateKey');
                              //              // print(' Public Key: $publicKey');
                              //
                              //
                              //
                              //
                              //
                              //            }
                              //            else {
                              //              controller.authenticateBiometric(context).whenComplete(() {
                              //                if (controller.isSuccess) {
                              //                  controller.doDisableBiometricAuth(context);
                              //                }
                              //              });
                              //            }
                              //
                              //          },
                              //          navImage: AppThemeIcons.sideNav(context),
                              //          onToggleOn: () {
                              //          },
                              //          onToggleOff: () {},
                              //        ),
                            ],
                          ),
                        ),

                        SizedBox(height: 18.sp),

                        /// ------------------- PERSONAL DETAILS -------------------
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.sp),
                            border: Border.all(
                              color: ThemeOutLineColor.getOutLineColor(context),
                              width: 5.sp,
                            ),
                          ),
                          child: Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(15.sp),
                                    child: CustomText(
                                      label: AppLocalizations.of(
                                        context,
                                      )!.personalDetails,
                                      fontSize: 15.sp,
                                      fontColour: ThemeTextColor.getTextColor(
                                        context,
                                      ),
                                      labelFontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Divider(
                                    color: ThemeOutLineColor.getOutLineColor(
                                      context,
                                    ),
                                    thickness: 6.sp,
                                    height: 5.sp,
                                  ),

                                  CustomSideMenu(
                                    isPressed: false,
                                    subTitle: AppLocalizations.of(
                                      context,
                                    )!.username,
                                    subText: controller.userName,
                                    sideImage: AppThemeIcons.sideMenuUserName(
                                      context,
                                    ),
                                    onTap: () {},
                                    navImage: AppThemeIcons.sideNav(context),
                                  ),
                                  CustomSideMenu(
                                    isPressed: false,
                                    subTitle: AppLocalizations.of(
                                      context,
                                    )!.emailAddress,
                                    subText: controller.userEmailId,
                                    sideImage: AppThemeIcons.sideMenuEmail(
                                      context,
                                    ),
                                    onTap: () {},
                                    navImage: AppThemeIcons.sideNav(context),
                                  ),
                                  CustomSideMenu(
                                    isPressed: false,
                                    subTitle: AppLocalizations.of(context)!.bio,
                                    subText: controller.bio,
                                    sideImage: AppThemeIcons.sideMenuBio(
                                      context,
                                    ),
                                    onTap: () {},
                                    navImage: AppThemeIcons.sideNav(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 18.sp),

                        /// ------------------- APPLICATION SETTINGS -------------------
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.sp),
                            border: Border.all(
                              color: ThemeOutLineColor.getOutLineColor(context),
                              width: 5.sp,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(15.sp),
                                child: CustomText(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.applicationSettings,
                                  fontSize: 16.sp,
                                  fontColour: ThemeTextColor.getTextColor(
                                    context,
                                  ),
                                  labelFontWeight: FontWeight.bold,
                                ),
                              ),
                              Divider(
                                color: ThemeOutLineColor.getOutLineColor(
                                  context,
                                ),
                                thickness: 6.sp,
                                height: 5.sp,
                              ),

                              /// LANGUAGE — only box (no arrow, no toggle)
                              CustomSideMenu(
                                countryImage: controller.flag,
                                countryName: controller.locale.languageCode
                                    .toUpperCase(),
                                subTitle: AppLocalizations.of(
                                  context,
                                )!.language,
                                subText: AppLocalizations.of(
                                  context,
                                )!.chooseYourPreferredLanguage,
                                sideImage: AppThemeIcons.sideMenuLanguage(
                                  context,
                                ),
                                isPressed: true,
                                navImage: AppThemeIcons.sideNav(context),
                                onTap: () {
                                  showLanguageBottomSheet(context);
                                },
                              ),

                              Padding(
                                padding: EdgeInsets.only(
                                  left: 15.sp,
                                  right: 15.sp,
                                  top: 15.sp,
                                  bottom: 10.sp,
                                ),
                                child: Row(
                                  children: [
                                    // left icon
                                    Center(
                                      child: SvgPicture.asset(
                                        AppThemeIcons.getThemeSvg(context),
                                        width: 22.5.sp,
                                        height: 22.5.sp,
                                      ),
                                    ),

                                    SizedBox(width: 14.sp),
                                    // title + subtitle
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            label: AppLocalizations.of(
                                              context,
                                            )!.colourTheme,
                                            fontSize: 15.5.sp,
                                            labelFontWeight: FontWeight.w700,
                                          ),
                                          SizedBox(height: 8.sp),
                                          CustomText(
                                            label: AppLocalizations.of(
                                              context,
                                            )!.colourThemeSubText,
                                            fontSize: 14.5.sp,
                                            fontColour:
                                                ThemeTextOneColor.getTextOneColor(
                                                  context,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Consumer<ThemeController>(
                                      builder: (context, themeController, _) {
                                        final bool isDark =
                                            themeController.themeMode ==
                                            ThemeMode.dark;
                                        return GestureDetector(
                                          onTap: () {
                                            final nextMode = isDark
                                                ? ThemeMode.light
                                                : ThemeMode.dark;
                                            themeController.changeTheme(
                                              nextMode,
                                            );
                                            spotTradeController
                                                .changeChartColor(
                                                  context,
                                                  true,
                                                );
                                            spotTradeController.reOpenFutureTrade(context);
                                            futureTradeController
                                                .changeChartColor(
                                                  context,
                                                  true,
                                                );
                                            futureTradeController.reOpenFutureTrade(context);
                                            print("call two");
                                          },
                                          child: Container(
                                            height: 4.5.h,
                                            width: 20.w,
                                            padding: EdgeInsets.all(10.sp),
                                            decoration: BoxDecoration(
                                              color:
                                                  ThemeTextFormFillColor.getTextFormFillColor(
                                                    context,
                                                  ),
                                              borderRadius:
                                                  BorderRadius.circular(15.sp),
                                              border: Border.all(
                                                color:
                                                    ThemeOutLineColor.getOutLineColor(
                                                      context,
                                                    ),
                                                width: 5.sp,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // DARK ICON
                                                SvgPicture.asset(
                                                  isDark
                                                      ? AppDarkSideIcons
                                                            .inActive
                                                      : AppDarkSideIcons.active,
                                                  width: 22.sp,
                                                  height: 22.sp,
                                                ),

                                                // LIGHT ICON
                                                SvgPicture.asset(
                                                  isDark
                                                      ? AppLightSideIcons.active
                                                      : AppLightSideIcons
                                                            .inActive,
                                                  width: 22.sp,
                                                  height: 22.sp,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              /* CustomSideMenu(
                                subTitle: AppLocalizations.of(
                                  context,
                                )!.notification,
                                subText: AppLocalizations.of(
                                  context,
                                )!.notificationSubText,
                                sideImage: AppThemeIcons.sideMenuNotification(
                                  context,
                                ),
                                onTap: () {},
                                navImage: AppThemeIcons.sideNav(context),
                              ),*/
                            ],
                          ),
                        ),
                        SizedBox(height: 15.sp),
                        GestureDetector(
                          onTap: () async {
                            customAlert(
                              context: context,
                              widget: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: CustomText(
                                      label: AppLocalizations.of(
                                        context,
                                      )!.areYouSureLogout,
                                      labelFontWeight: FontWeight.w400,
                                      fontSize: 14.5.sp,
                                    ),
                                  ),
                                  SizedBox(height: 20.sp),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: CancelButton(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.no,
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 12.sp),
                                      Expanded(
                                        child: CustomButton(
                                          label: AppLocalizations.of(
                                            context,
                                          )!.yes,
                                          onTap: () async {
                                            AppNavigator.pop();
                                            final selectedLanguage =
                                                AppStorage.getLanguage();
                                            print(
                                              "selectedLanguage $selectedLanguage",
                                            );
                                            await GetStorage().erase();

                                            if (selectedLanguage != null) {
                                              AppStorage.storeLanguage(
                                                selectedLanguage,
                                              );
                                              print(
                                                "selectedLanguage $selectedLanguage",
                                              );
                                            }

                                            AppNavigator.popToRoot();
                                            // AppNavigator.pushTo(const LoginView());
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              title: AppLocalizations.of(context)!.logOut,
                            );
                          },
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 150),
                            opacity: 1.0,
                            child: Container(
                              height: 5.5.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: ThemeTextColor.getTextColor(context),
                                borderRadius: BorderRadius.circular(25.sp),
                              ),
                              alignment: Alignment.center,
                              child: CustomText(
                                label: AppLocalizations.of(context)!.logOut,
                                fontSize: 15.5.sp,
                                labelFontWeight: FontWeight.bold,
                                fontColour: Theme.of(
                                  context,
                                ).colorScheme.surface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Loader overlay when controller.isLoading is true
            if (controller.isLoading)
              CustomLoader(isLoading: controller.isLoading),
          ],
        );
      },
    );
  }

  void showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 🔥 IMPORTANT
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: ThemeBackgroundColor.getBackgroundColor(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.sp)),
            border: Border.all(
              color: ThemeOutLineColor.getOutLineColor(context),
              width: 5.sp,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 13.sp,
                right: 13.sp,
                top: 13.sp,
                bottom: 10.sp,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        label: AppLocalizations.of(context)!.language,
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

                  SizedBox(height: 15.sp),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.sp),
                    child: DottedDivider(
                      color: ThemeTextOneColor.getTextOneColor(context),
                    ),
                  ),

                  SizedBox(height: 5.sp),

                  /// 🔹 Language List
                  ...List.generate(controller.languages.length, (index) {
                    final lang = controller.languages[index];
                    final isSelected =
                        controller.locale.languageCode == lang.lan;

                    return ListTile(
                      contentPadding: EdgeInsets.only(
                        left: 13.sp,
                        right: 13.sp,
                        top: 13.sp,
                        bottom: 0.sp,
                      ),

                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText(
                            label: "${index + 1}.",
                            labelFontWeight: FontWeight.bold,
                          ),
                          SizedBox(width: 15.sp),
                          SvgPicture.asset(lang.flag, width: 20.sp),
                        ],
                      ),
                      title: CustomText(
                        label: lang.name,
                        labelFontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w200,
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        controller.setLocale(
                          Locale.fromSubtags(languageCode: lang.lan),
                        );
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImagePicker(BuildContext context, RootController controller) {
    customActionAlertBox(
      context,
      AppLocalizations.of(context)!.selectAction,
      18.h,
      () async {
        Navigator.pop(context);
        final picker = ImagePicker();
        final image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 20,
        );
        if (image != null) {
          controller.setProfilePicture(image);
          controller.updateProfilePicture(context);
        }
      },
      () async {
        Navigator.pop(context);
        final picker = ImagePicker();
        final image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 20,
        );
        if (image != null) {
          controller.setProfilePicture(image);
          controller.updateProfilePicture(context);
        }
      },
      AppLocalizations.of(context)!.camera,
      AppLocalizations.of(context)!.gallery,
    );
  }
}
