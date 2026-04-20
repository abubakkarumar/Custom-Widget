// ignore_for_file: file_names, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Views/Basic_Modules/welcome/welcome_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      _initSplashLogic();
    });
  }

  void _initSplashLogic() {
    AppNavigator.replaceWith(WelcomeView());
  }

  @override
  Widget build(BuildContext context) {
    print("SPLASH REBUILDING");

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(AppBasicIcons.splashScreenPng),
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            AppBasicIcons.logo,
            height: 10.h,
            width: 80.w,
          ),
        ),
      ),
    );
  }
}
