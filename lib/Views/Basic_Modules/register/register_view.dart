import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Utility/custom_tooltip.dart';
import 'package:zayroexchange/Views/Basic_Modules/email_verfication/email_verification_view.dart';
import 'package:zayroexchange/Views/Basic_Modules/register/register_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // Keep a reference here; Consumer will update it in build.
  RegisterController controller = RegisterController();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).whenComplete(() async {});
  }

  @override
  void dispose() {
    super.dispose();
    controller.diableAutoValidate();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterController>(
      builder: (context, value, child) {
        controller = value;
        return Form(
          key: registerFormKey,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFieldWidget(
                  label: AppLocalizations.of(context)!.username,
                  line: 1,
                  autoValidateMode: controller.userNameAutoValidate,
                  controller: controller.userNameController,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: SvgPicture.asset(AppThemeIcons.userName(context)),
                  ),
                  hintText: AppLocalizations.of(context)!.enterYourUsername,
                  readOnly: false,
                  onValidate: (val) =>
                      AppValidations().username(context, val ?? ""),
                ),
                SizedBox(height: 2.h),
                CustomTextFieldWidget(
                  label: AppLocalizations.of(context)!.emailAddress,
                  line: 1,
                  autoValidateMode: controller.emailAutoValidate,
                  controller: controller.emailController,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: SvgPicture.asset(AppThemeIcons.email(context)),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    FilteringTextInputFormatter.deny(RegExp(r'[A-Z]')),
                  ],
                  hintText: AppLocalizations.of(context)!.emailAddressHintText,
                  readOnly: false,
                  onValidate: (val) =>
                      AppValidations().email(context, val ?? ""),
                ),
                SizedBox(height: 2.h),
                CustomTextFieldWidget(
                  label: AppLocalizations.of(context)!.password,
                  line: 1,
                  autoValidateMode: controller.passwordAutoValidate,
                  controller: controller.passwordController,
                  obscure: !controller.isPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: ThemeTextOneColor.getTextOneColor(context),
                      size: 18.sp,
                    ),
                    onPressed: () {
                      controller.isPasswordFunc();
                    },
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: SvgPicture.asset(AppThemeIcons.password(context)),
                  ),
                  hintText: AppLocalizations.of(context)!.passwordHintText,
                  readOnly: false,
                  onValidate: (val) =>
                      AppValidations().newPassword(context, val ?? ""),
                ),
                _buildInfoIcon(
                  isOpen: controller.isPassNotesOpen,
                  toggle: () {
                    controller.isPassNotesOpen = !controller.isPassNotesOpen;
                    controller.isPassNotesOpen
                        ? showPasswordTooltip(
                            context,
                            AppLocalizations.of(context)!.passwordRequirements,
                          )
                        : removePasswordTooltip();
                  },
                ),
                CustomTextFieldWidget(
                  label: AppLocalizations.of(context)!.confirmPassword,
                  line: 1,
                  autoValidateMode: controller.confirmPasswordAutoValidate,
                  controller: controller.confirmPasswordController,
                  obscure: !controller.isConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: ThemeTextOneColor.getTextOneColor(context),
                      size: 18.sp,
                    ),
                    onPressed: () {
                      controller.isConfirmPasswordFunc();
                    },
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(15.sp),
                    child: SvgPicture.asset(AppThemeIcons.password(context)),
                  ),
                  hintText: AppLocalizations.of(context)!.enterConfirmPassword,
                  readOnly: false,
                  onValidate: (val) => AppValidations().confirmPassword(
                    context,
                    controller.confirmPasswordController.text,
                    val ?? "",
                  ),
                ),
                SizedBox(height: 2.h),
                CustomTextFieldWidget(
                  label: AppLocalizations.of(context)!.referralOption,
                  line: 1,
                  autoValidateMode: controller.referralIdAutoValidate,
                  controller: controller.referralIdController,
                  hintText: AppLocalizations.of(context)!.enterReferralId,
                  readOnly: false,
                ),
                SizedBox(height: 2.h),
                AgreeTermsWithController(
                  onLinkTap: () {
                    // open terms page
                  },
                ),
                SizedBox(height: 2.h),
                CustomButton(
                  label: AppLocalizations.of(context)!.createAccount,
                  onTap: () async {
                    controller.enableAutoValidate();
                    if (registerFormKey.currentState!.validate()) {
                      if (!controller.isTermsAccepted) {
                        CustomAnimationToast.show(
                          context: context,
                          message: AppLocalizations.of(
                            context,
                          )!.pleaseAcceptTerms,
                          type: ToastType.error,
                        );
                      } else {
                        controller.doRegister(context).whenComplete(() {
                          if (controller.successIndex == 1) {
                            AppNavigator.pushTo(EmailVerification());
                          }
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildInfoIcon({required bool isOpen, required VoidCallback toggle}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: toggle,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Icon(Icons.info_outline, color: Colors.grey, size: 18.sp),
      ),
    ),
  );
}

class AgreeTermsWithController extends StatelessWidget {
  final VoidCallback? onLinkTap;
  const AgreeTermsWithController({this.onLinkTap, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RegisterController>(context);
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
                ? Icon(Icons.check, size: boxSize - 6, color: Colors.white)
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
                  TextSpan(text: AppLocalizations.of(context)!.iHaveReadAgree),
                  TextSpan(
                    text: AppLocalizations.of(context)!.termsService,
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
