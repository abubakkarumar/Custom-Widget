import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/Basics/validation.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text_form_field.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/custom_progress_dialog.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordOne extends StatefulWidget {
  const ForgotPasswordOne({super.key});

  @override
  State<ForgotPasswordOne> createState() => _ForgotPasswordOneState();
}

class _ForgotPasswordOneState extends State<ForgotPasswordOne> {
  final forgotPasswordFirstKey = GlobalKey<FormState>();
  ForgotPasswordController forgotPasswordController = ForgotPasswordController();

  @override
  void initState() {
    Future.delayed(Duration.zero).whenComplete(() async {
      forgotPasswordController.clearAllFields();
      forgotPasswordController.diableAutoValidate();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    forgotPasswordController.diableAutoValidate();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgotPasswordController>(
      builder: (context, value, child) {
        forgotPasswordController = value;

        return  Stack(
          children: [
            CustomTotalPageFormat(
              appBarTitle: AppLocalizations.of(
                context,
              )!.forgotPasswordTitle,
              showBackButton: true,
              child: Form(
                key: forgotPasswordFirstKey,
                child: Center(child: uiView(context)),
              ),
            ),

            // Loader Layer
            CustomLoader(isLoading: forgotPasswordController.isLoading),
          ],
        );
      },
    );
  }

  uiView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.sp,),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: ThemeTextOneColor.getTextOneColor(context),
              fontSize: 14.5.sp,
            ),
            children: [
              TextSpan(
                text: AppLocalizations.of(context)!.enterEmailAddressAssociated,
              ),
              TextSpan(
                text: AppLocalizations.of(context)!.zayroAccount,
                style: TextStyle(
                  color: ThemeInversePrimaryColor.getInversePrimaryColor(
                    context,
                  ),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.sp),
        CustomTextFieldWidget(
          line: 1,
          label: AppLocalizations.of(context)!.emailAddress,
          labelTwo: "",
          controller: forgotPasswordController.emailController,
          hintText: AppLocalizations.of(context)!.emailAddressHintText,
          autoValidateMode: forgotPasswordController.emailAutoValidate,
          prefixIcon: Padding(
            padding: EdgeInsets.all(15.sp),
            child: SvgPicture.asset(AppThemeIcons.email(context)),
          ),
          readOnly: false,
          onValidate: (val) => AppValidations().email(context, val ?? ""),
        ),

        SizedBox(height: 20.sp),
        forgotPasswordController.isLoading == true
            ? CustomProgressDialog():
        CustomButton(
          label: AppLocalizations.of(context)!.submit,
          onTap: () async {
            forgotPasswordController.enableAutoValidate();
            if (forgotPasswordFirstKey.currentState!.validate()) {
              forgotPasswordController.requestForgotPassword(context);
            }
          },
        ),
      ],
    );
  }
}
