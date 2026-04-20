import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Basic_Modules/two_fa/twofa_controller.dart';
import 'package:zayroexchange/Views/Basic_Modules/two_fa/twofa_view.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Kyc/kyc_view.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/Account_activity/account_activity.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/ChangePassword/change_password.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/Freeze_account/freeze_account_view.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_controller.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_level.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'Anti-Phishing_Code/anti_phishing_code_view.dart';
import 'Delete_Account/delete_account_view.dart';
import 'Google_TwoFa/google_2fa_view.dart';
import 'MPin/mpin_view.dart';
import 'Recovery_Key/recovery_key.dart';

class SecurityView extends StatefulWidget {
  const SecurityView({super.key});

  @override
  State<SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> {
  SecurityController controller = SecurityController();
  TwoFAController twoFAController = TwoFAController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      controller.getUserDetails(context).whenComplete(() {
        if (AppStorage.getTwofaStatus() == 0) {
          protectYourFundsAlert(context, controller);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SecurityController, TwoFAController>(
      builder: (context, value, value1, child) {
        controller = value;
        twoFAController = value1;

        return Scaffold(
          body: Stack(
            children: [
              CustomTotalPageFormat(
                appBarTitle: AppLocalizations.of(context)!.security,
                showBackButton: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// SECURITY LEVEL BOX
                    Container(
                      padding: EdgeInsets.only(
                        left: 13.sp,
                        right: 13.sp,
                        top: 13.sp,
                        bottom: 10.sp,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 4.sp,
                          color: controller.securityLevel == 0
                              ? Theme.of(context).colorScheme.error
                              : controller.securityLevel == 1
                              ? Colors.yellow
                              : Theme.of(context).colorScheme.tertiary,
                        ),
                        borderRadius: BorderRadius.circular(12.sp),
                        color: controller.securityLevel == 0
                            ? Theme.of(
                                context,
                              ).colorScheme.error.withOpacity(0.1)
                            : controller.securityLevel == 1
                            ? Colors.yellow.withOpacity(0.1)
                            : Theme.of(
                                context,
                              ).colorScheme.tertiary.withOpacity(0.1),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            controller.securityLevel == 0
                                ? AppBasicIcons.securityLevelLow
                                : controller.securityLevel == 1
                                ? AppBasicIcons.securityLevelMedium
                                : AppBasicIcons.securityLevelHigh,
                            height: 7.h,
                          ),
                          SizedBox(width: 15.sp),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  label:
                                      "${AppLocalizations.of(context)!.yourSecurityLevel} ${controller.securityLevelStatus}",
                                  fontSize: 15.sp,
                                  labelFontWeight: FontWeight.bold,
                                ),
                                SizedBox(height: 10.sp),
                                CustomText(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.yourSecurityLevelSubText,
                                  fontColour: ThemeTextOneColor.getTextOneColor(context),
                                  fontSize: 14.sp,
                                  labelFontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15.sp),

                    /// NOTE CARD
                    noteContainer(context, controller),

                    SizedBox(height: 15.sp),

                    /// GOOGLE 2FA
                    CustomText(
                      label: AppLocalizations.of(
                        context,
                      )!.twoFactorAuthentication,
                      fontSize: 15.5.sp,
                    ),
                    SizedBox(height: 15.sp),
                    items(
                      context: context,
                      color: AppStorage.getTwofaStatus() == 1,
                      title: AppLocalizations.of(context)!.googleAuthenticator,
                      subTitle: AppLocalizations.of(
                        context,
                      )!.googleAuthenticatorSubText,
                      leadingImage: AppThemeIcons.securityGoogle(context),
                      buttonLabel: AppStorage.getTwofaStatus() == 1
                          ? AppLocalizations.of(context)!.disable
                          : AppLocalizations.of(context)!.enable,
                      onTap: () async {
                        if (AppStorage.getTwofaStatus() == 2) {
                          CustomAnimationToast.show(
                            message: AppLocalizations.of(
                              context,
                            )!.twoFaAlertMessage,
                            type: ToastType.error,
                            context: context,
                          );
                        } else {
                          if (AppStorage.getTwofaStatus() == 0) {
                            customAlert(
                              context: context,
                              title: AppLocalizations.of(
                                context,
                              )!.enableGoogleAuthentication,
                              onTapBack: () {
                                AppNavigator.pop();
                                controller.googleOTPController.clear();
                              },
                              widget: const SingleChildScrollView(
                                child: GoogleTwoFAView(),
                              ),
                              onDismiss: () {
                                controller.googleOTPController.clear();
                              },
                            );
                          } else {
                            custom2FAVerification(
                              context: context,
                              title: AppLocalizations.of(
                                context,
                              )!.diableGoogleAuthentication,
                              isResendCodeNeeded: false,
                              isEmailOrGoogle: false,
                              onSubmit: () {
                                if (twoFAController.formKey.currentState!
                                    .validate()) {
                                  if (AppStorage.getTwofaStatus() == 1) {
                                    twoFAController.setLoader(true);
                                    controller
                                        .doDisableGoogle2Fa(
                                          context,
                                          twoFAController.verificationCode.text,
                                        )
                                        .then((value) {
                                          if (!mounted) return;
                                          twoFAController.setLoader(false);
                                        });
                                  }
                                }
                              },
                            );
                          }
                        }
                      },
                    ),

                    SizedBox(height: 13.sp),

                    /// EMAIL 2FA
                    items(
                      context: context,
                      color: AppStorage.getTwofaStatus() == 2,
                      title: AppLocalizations.of(context)!.emailVerification,
                      subTitle: AppLocalizations.of(
                        context,
                      )!.emailVerificationSubText,
                      leadingImage: AppThemeIcons.securityEmail(context),
                      buttonLabel: AppStorage.getTwofaStatus() == 2
                          ? AppLocalizations.of(context)!.disable
                          : AppLocalizations.of(context)!.enable,
                      onTap: () async {
                        if (AppStorage.getTwofaStatus() == 1) {
                          CustomAnimationToast.show(
                            message: AppLocalizations.of(
                              context,
                            )!.twoFaAlertMessage,
                            type: ToastType.error,
                            context: context,
                          );
                        } else {
                          custom2FAVerification(
                            context: context,
                            title: AppStorage.getTwofaStatus() == 0
                                ? AppLocalizations.of(
                                    context,
                                  )!.enableEmailVerification
                                : AppLocalizations.of(
                                    context,
                                  )!.diableEmailVerification,
                            isResendCodeNeeded: true,
                            isEmailOrGoogle: true,
                            onResend: () async {
                              twoFAController.setLoader(true);
                              controller
                                  .getEmailVerificationCode(context)
                                  .whenComplete(() {
                                    if (!mounted) return;
                                    twoFAController.setLoader(false);
                                  });
                            },
                            onInit: () async {
                              twoFAController.setLoader(true);
                              controller
                                  .getEmailVerificationCode(context)
                                  .whenComplete(() {
                                    if (!mounted) return;
                                    twoFAController.setLoader(false);
                                  });
                            },
                            onSubmit: () async {
                              if (twoFAController.formKey.currentState!
                                  .validate()) {
                                twoFAController.setLoader(true);

                                if (AppStorage.getTwofaStatus() != 2) {
                                  controller
                                      .doEnableEmail2FA(
                                        context: context,
                                        otp: twoFAController
                                            .verificationCode
                                            .text,
                                      )
                                      .whenComplete(() {
                                        twoFAController.setLoader(false);
                                        Navigator.pop(context);
                                      });
                                } else {
                                  controller
                                      .doDisableEmail2Fa(
                                        context,
                                        twoFAController.verificationCode.text,
                                      )
                                      .whenComplete(() {
                                        twoFAController.setLoader(false);
                                        Navigator.pop(context);
                                      });
                                }
                              }
                            },
                          );
                        }
                      },
                    ),

                    SizedBox(height: 13.sp),

                    /// -------- OTHER SECURITY OPTIONS --------
                    CustomText(
                      label: AppLocalizations.of(context)!.identityVerification,
                      fontSize: 15.5.sp,
                    ),
                    SizedBox(height: 13.sp),

                    SecurityOptionTile(
                      buttonText: controller.kyStatus == 1 ? AppLocalizations.of(context)!.approved : AppLocalizations.of(context)!.view,
                      buttonColor: controller.kyStatus == 1 ?Theme.of(context).colorScheme.tertiary: null,
                      buttonTextColor: controller.kyStatus == 1 ? Colors.white : null,
                      image: AppThemeIcons.securityKycVerification(context),
                      title: AppLocalizations.of(context)!.kycVerification,
                      description: AppLocalizations.of(
                        context,
                      )!.kycVerificationSubText,
                      isToggleType: false,
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KycView(),
                          ),
                        ).then((value) {
                          controller.getUserDetails(context);
                        },);
                      },
                    ),

                    SizedBox(height: 13.sp),

                    CustomText(
                      label: AppLocalizations.of(context)!.accountActivities,
                      fontSize: 15.5.sp,
                    ),

                    SizedBox(height: 13.sp),
                    SecurityOptionTile(
                      buttonText: AppLocalizations.of(context)!.manage,
                      image: AppThemeIcons.securityAntiPhishing(context),
                      title: AppLocalizations.of(context)!.antiPhishingCode,
                      description: AppLocalizations.of(
                        context,
                      )!.antiPhishingCodeSubText,
                      isToggleType: false,
                      onTap: () async {
                        customAlert(
                          context: context,
                          title: AppLocalizations.of(context)!.antiPhishingCode,
                          onTapBack: () {
                            Navigator.of(context).pop();
                          },
                          widget: AntiPhishingCodeView(parentContext: context,),
                        );
                      },
                    ),

                    SizedBox(height: 13.sp),

                    items(
                      context: context,
                      color: AppStorage.getRecoveryStatus() == 1,
                      title: AppLocalizations.of(context)!.recoveryKey,
                      subTitle: AppLocalizations.of(
                        context,
                      )!.saveYourPassphrase,
                      leadingImage: AppThemeIcons.securityRecovery(context),
                      buttonLabel: AppStorage.getRecoveryStatus() == 1
                          ? AppLocalizations.of(context)!.enabled
                          : AppLocalizations.of(context)!.enable,
                      onTap: () async {
                        if (AppStorage.getRecoveryStatus() == 0) {
                          recoveryKeyAlert(context);
                        }
                      },
                    ),

                    SizedBox(height: 13.sp),

                    SecurityOptionTile(
                      buttonText: AppLocalizations.of(context)!.change,
                      image: AppThemeIcons.securityLoginPassword(context),
                      title: AppLocalizations.of(context)!.loginPassword,
                      description: AppLocalizations.of(
                        context,
                      )!.forAccountLogin,
                      isToggleType: false,
                      onTap: () async {
                        customAlert(
                          context: context,
                          title: AppLocalizations.of(
                            context,
                          )!.changeLoginPassword,
                          onTapBack: () {
                            AppNavigator.pop();
                          },
                          widget: ChangePasswordView(),
                        );
                      },
                    ),
                    SizedBox(height: 13.sp),

                    SecurityOptionTile(
                      buttonText: AppStorage.getMPINStatus() == 0
                          ? AppLocalizations.of(context)!.create
                          : AppLocalizations.of(context)!.change,
                      image: AppThemeIcons.sideMenuMPin(context),
                      title: AppLocalizations.of(context)!.mpIN,
                      description: AppLocalizations.of(context)!.mpINSubText,
                      isToggleType: false,
                      onTap: () async {
                        AppNavigator.pushTo(MPinView());
                      },
                    ),

                    SizedBox(height: 13.sp),

                    SecurityOptionTile(
                      buttonText: controller.freezeAccountStatus == 0
                          ? AppLocalizations.of(context)!.enableFreeze
                          : AppLocalizations.of(context)!.disableFreeze,
                      image: AppThemeIcons.securityFreezeAccount(context),
                      title: AppLocalizations.of(context)!.freezeAccount,
                      description: AppLocalizations.of(
                        context,
                      )!.freezeAccountSubText,
                      onTap: () async {
                        AppNavigator.pushTo(FreezeAccountView());
                      },
                      isToggleType: false,
                    ),

                    SizedBox(height: 13.sp),

                    SecurityOptionTile(
                      buttonText: AppLocalizations.of(context)!.view,
                      image: AppThemeIcons.securityAccountActivities(context),
                      title: AppLocalizations.of(context)!.accountActivities,
                      description: AppLocalizations.of(
                        context,
                      )!.accountActivitiesSubText,
                      onTap: () async {
                        AppNavigator.pushTo(AccountActivityView());
                      },
                      isToggleType: false,
                    ),

                    SizedBox(height: 13.sp),

                    /// DELETE ACCOUNT
                    Container(
                      padding: EdgeInsets.all(14.sp),
                      decoration: BoxDecoration(
                        color: ThemeTextFormFillColor.getTextFormFillColor(
                          context,
                        ),
                        borderRadius: BorderRadius.circular(12.sp),
                        border: Border.all(
                          color: ThemeOutLineColor.getOutLineColor(context),
                          width: 5.sp,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  AppThemeIcons.securityDeleteAccount(context),
                                  width: 25.sp,
                                  height: 25.sp,
                                ),
                                SizedBox(width: 12.sp),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.deleteAccount,
                                        labelFontWeight: FontWeight.w600,
                                      ),
                                      SizedBox(height: 10.sp),
                                      CustomText(
                                        label: AppLocalizations.of(
                                          context,
                                        )!.deleteAccountSubText,
                                        fontColour:
                                            ThemeTextOneColor.getTextOneColor(
                                              context,
                                            ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 15.sp),
                          GestureDetector(
                            onTap: () {
                              AppNavigator.pushTo(DeleteAccountView());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15.sp,
                                vertical: 10.sp,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(10.sp),
                              ),
                              child: CustomText(
                                label: AppLocalizations.of(context)!.delete,
                                fontColour: Colors.white,
                                fontSize: 15.sp,
                                labelFontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (controller.isLoading)
                CustomLoader(isLoading: controller.isLoading),
            ],
          ),
        );
      },
    );
  }

  Widget recoveryKeyAlert(BuildContext context) {
    return customAlert(
      context: context,
      title: AppLocalizations.of(context)!.recoveryKey,
      onTapBack: () {
        AppNavigator.pop();
      },
      widget: RecoveryKeyView(),
    );
  }
}
