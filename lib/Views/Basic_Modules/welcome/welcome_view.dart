import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Basic_Modules/segmentedToggle/login_register.dart';
import 'package:zayroexchange/Views/Root/root_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

/// Refactored WelcomeView into smaller widgets for readability.
/// Preserves all original navigation and behavior.
class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  RootController controller = RootController();

  @override
  Widget build(BuildContext context) {
    return Consumer<RootController>(
      builder: (context, value, child) {
        controller = value;
        return Scaffold(
          body: Stack(
            children: [
              _MainBackground(),
              _OnboardingOverlay(),
              Language(),
              _CenteredContent(),
            ],
          ),
        );
      },
    );
  }
}

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  _LanguageState createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  RootController controller = RootController();

  @override
  Widget build(BuildContext context) {
    return Consumer<RootController>(
      builder: (context, value, child) {
        controller = value;

        return Positioned(
          top: 5.h,
          left: 75.w,
          right: 0,
          child: GestureDetector(
            onTap: () {
              showLanguageBottomSheet(context);
            },
            child: SvgPicture.asset(
              "assets/basic_icons/lang.svg",
              height: 4.5.h,
            ),
          ),
        );
      },
    );
  }

  void showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Consumer<RootController>(
          builder: (context, value, child) {
            controller = value;

            return Container(
              decoration: BoxDecoration(
                color: ThemeBackgroundColor.getBackgroundColor(context),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(18.sp),
                ),
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

                      /// Language List
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
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
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
      },
    );
  }
}

/// Full-screen static background image
class _MainBackground extends StatelessWidget {
  const _MainBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(AppBasicIcons.welcome, fit: BoxFit.cover),
    );
  }
}

/// Lower SVG overlay used for decorative background
class _OnboardingOverlay extends StatelessWidget {
  const _OnboardingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60.h,
      left: 0,
      right: 0,
      child: SvgPicture.asset(
        AppBasicIcons.onboardingBackground,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        width: 100.w,
        height: 45.h,
      ),
    );
  }
}

/// Centered title and action buttons sitting above the overlay
class _CenteredContent extends StatelessWidget {
  const _CenteredContent();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10.h,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          CustomText(
            align: TextAlign.center,
            label: AppLocalizations.of(context)!.welcomeSubText,
            fontSize: 22.sp,
            fontColour: Colors.white,
            labelFontWeight: FontWeight.bold,
          ),

          SizedBox(height: 15.sp),

          // Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              children: [
                // Login Button
                CustomButton(
                  label: AppLocalizations.of(context)!.login,
                  backgroundColor: Colors.white,
                  useDefaultGradient: false,
                  labelColor: Colors.black,
                  onTap: () async {
                    // <-- async added
                    AppNavigator.pushTo(
                      SegmentedToggleView(
                        appBarTitle: AppLocalizations.of(context)!.login,
                      ),
                    );
                  },
                ),

                SizedBox(height: 15.sp),

                // Register Button
                CustomButton(
                  label: AppLocalizations.of(context)!.register,
                  onTap: () async {
                    AppNavigator.pushTo(
                      SegmentedToggleView(
                        appBarTitle: AppLocalizations.of(context)!.register,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
