import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/app_navigator.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';

class LoginSuccessAnimationView extends StatefulWidget {
  final Widget nextPage;

  const LoginSuccessAnimationView({super.key, required this.nextPage});

  @override
  State<LoginSuccessAnimationView> createState() =>
      _LoginSuccessAnimationViewState();
}

class _LoginSuccessAnimationViewState extends State<LoginSuccessAnimationView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          AppNavigator.replaceWith(widget.nextPage);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:ThemeBackgroundColor.getBackgroundColor(context),
      body: Center(
        child: SvgPicture.asset(
          AppBasicIcons.logo,
          width: 55.w,
          height: 55.w,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
