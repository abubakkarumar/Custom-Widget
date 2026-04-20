import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Basics/custom_loader.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_otp_field.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/template.dart';
import 'package:zayroexchange/Views/Root/new_root/root_page.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'mpin_forgot_view.dart';
import 'mpin_login_controller.dart';

class MPINLoginView extends StatefulWidget {
  const MPINLoginView({super.key});

  @override
  State<MPINLoginView> createState() => _MPINLoginViewState();
}

class _MPINLoginViewState extends State<MPINLoginView> {
  MPINLoginController controller = MPINLoginController();
  final mpinKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).whenComplete(() async {
      controller.resetData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.diableAutoValidate();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MPINLoginController>(
      builder: (context, value, child) {
        controller = value;

        return Stack(
          children: [
            CustomTotalPageFormat(
              appBarTitle: AppLocalizations.of(context)!.loginWithMPIN,
              showBackButton: true,
              child: Form(
                key: mpinKey,
                child: Center(child: uI(context, controller)),
              ),
            ),

            // Loader Layer
            CustomLoader(isLoading: controller.isLoading),
          ],
        );
      },
    );
  }

  uI(BuildContext context, MPINLoginController controller) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label: AppLocalizations.of(context)!.enterMPIN,
            labelFontWeight: FontWeight.w500,
            fontSize: 15.sp,
          ),
          SizedBox(height: 10.sp),
          PinField(
            controller: controller.mPinController,
            validator: (val) {
              if (val!.isEmpty) {
                return AppLocalizations.of(context)!.mpinRequired;
              } else if (val.toString().length != 6) {
                return AppLocalizations.of(context)!.mpinMustBe6Digits;
              }
              return null;
            },
          ),
          SizedBox(height: 18.sp),
          GestureDetector(
            onTap: () {
              AppNavigator.pushTo(MPinForgotView());
            },
            child: CustomText(
              label: AppLocalizations.of(context)!.forgotMPinNumber,
              labelFontWeight: FontWeight.w500,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 20.sp),
          CustomButton(
            label: AppLocalizations.of(context)!.login,
            onTap: () async {
              controller.enableAutoValidate();
              if (mpinKey.currentState!.validate()) {
                controller.doLoginMPin(context).whenComplete(() {
                  if (controller.isSuccess) {
                    AppNavigator.pushTo(const RootScreen());
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
