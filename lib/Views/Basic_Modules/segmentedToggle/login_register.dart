// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Basic_Modules/login/login_controller.dart';
import 'package:zayroexchange/Views/Basic_Modules/login/login_view.dart';
import 'package:zayroexchange/Views/Basic_Modules/register/register_controller.dart';
import 'package:zayroexchange/Views/Basic_Modules/register/register_view.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import 'login_register_controller.dart';

class SegmentedToggleView extends StatefulWidget {
  final String appBarTitle;

  const SegmentedToggleView({super.key, required this.appBarTitle});

  @override
  State<SegmentedToggleView> createState() => _SegmentedToggleViewState();
}

class _SegmentedToggleViewState extends State<SegmentedToggleView> {
  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      final segController = Provider.of<SegmentedToggleController>(
        context,
        listen: false,
      );

      final registerText = AppLocalizations.of(context)!.register.toLowerCase();
      if (widget.appBarTitle.toLowerCase() == registerText) {
        segController.toggle(context, true);
        Provider.of<RegisterController>(context, listen: false).resetData();
      } else {
        segController.toggle(context, false);
        Provider.of<LoginController>(context, listen: false).resetData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Duration animDur = Duration(milliseconds: 180);

    // Outer scaffold background comes from your theme helper
    final Color scaffoldBg = ThemeBackgroundColor.getBackgroundColor(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Consumer3<SegmentedToggleController, RegisterController, LoginController>(
        builder: (context, segController, regController, logController, _) {
          final bool isRegister = segController.isRegister;
          final bool isLoading = isRegister
              ? regController.isLoading
              : logController.isLoading;

          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 15.sp, bottom: MediaQuery.of(context).padding.bottom + 15.sp, left: 15.sp, right: 15.sp),
            child: Stack(
              children: [
                // Main content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Centered Header
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 6.sp),
                        child: CustomText(
                          label: segController.title,
                          fontSize: 18.sp,
                          labelFontWeight: FontWeight.w700,
                          fontColour: ThemeTextColor.getTextColor(context),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Subtitle
                    Center(
                      child: CustomText(
                        label: !isRegister
                            ? AppLocalizations.of(context)!.loginDetailsText
                            : AppLocalizations.of(
                                context,
                              )!.registerLoginDetailsText,
                        fontSize: 14.5.sp,
                        labelFontWeight: FontWeight.w700,
                        fontColour: ThemeTextOneColor.getTextOneColor(
                          context,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // ===== Toggle Pill (centered) =====
                    Center(
                      child: Container(
                        // Pill container width - adjust as needed
                        width: 100.w,
                        height: 6.h,
                        padding: EdgeInsets.all(10.sp),
                        decoration: BoxDecoration(
                          color: ThemeBackgroundColor.getBackgroundColor(
                            context,
                          ),
                          borderRadius: BorderRadius.circular(30.sp),
                          border: Border.all(
                            color: ThemeOutLineColor.getOutLineColor(context),
                            width: 3.sp,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Animated sliding selected background
                            AnimatedAlign(
                              alignment: isRegister
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              duration: animDur,
                              curve: Curves.easeInOut,
                              child: Container(
                                width:
                                    (85.w - 6.sp) /
                                    2, // half of outer width minus some padding
                                height: 5.h,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 3.sp,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      ThemeTextFormFillColor.getTextFormFillColor(
                                        context,
                                      ),
                                  borderRadius: BorderRadius.circular(24.sp),
                                  border: Border.all(
                                    color: ThemeOutLineColor.getOutLineColor(
                                      context,
                                    ),
                                    width: 3.sp,
                                  ),
                                ),
                              ),
                            ),

                            // The two tappable labels
                            Row(
                              children: [
                                // Register
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!isRegister) {
                                        segController.toggle(context, true);
                                        regController.resetData();
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: double.infinity,
                                      color: Colors.transparent,
                                      child: AnimatedDefaultTextStyle(
                                        duration: animDur,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: isRegister
                                              ? ThemeTextColor.getTextColor(
                                                  context,
                                                )
                                              : ThemeTextOneColor.getTextOneColor(
                                                  context,
                                                ),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.register,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Login
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isRegister) {
                                        segController.toggle(context, false);
                                        logController.resetData();
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: double.infinity,
                                      color: Colors.transparent,
                                      child: AnimatedDefaultTextStyle(
                                        duration: animDur,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: !isRegister
                                              ? ThemeTextColor.getTextColor(
                                                  context,
                                                )
                                              : ThemeTextOneColor.getTextOneColor(
                                                  context,
                                                ),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!.login,
                                        ),
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

                    SizedBox(height: 3.h),

                    // ===== Pages (Register / Login) =====
                    Expanded(
                      child: Stack(
                        children: [
                          // Register page
                          Offstage(
                            offstage: !isRegister,
                            child: TickerMode(
                              enabled: isRegister,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: const RegisterView(),
                              ),
                            ),
                          ),

                          // Login page
                          Offstage(
                            offstage: isRegister,
                            child: TickerMode(
                              enabled: !isRegister,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: const LoginView(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Loader overlay
                CustomLoader(isLoading: isLoading),
              ],
            ),
          );
        },
      ),
    );
  }
}
