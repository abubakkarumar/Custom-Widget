// ignore_for_file: file_names

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/*class CustomLoader extends StatelessWidget {
  final bool isLoading;
  const CustomLoader({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isLoading,
      child: Center(
        child: SizedBox(
          height: 40.h,
          width: 40.w,
          child: Image.asset("assets/basic_icons/zayro_loader_animation.gif"),
        ),
      ),
    );
  }
}*/

class CustomLoader extends StatelessWidget {
  final bool isLoading;
  const CustomLoader({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isLoading ? 1.0 : 0.0,
        child: IgnorePointer(
          ignoring: isLoading,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            tween: Tween<double>(
              begin: isLoading ? 0.0 : 5.0,
              end: isLoading ? 5.0 : 0.0,
            ),
            builder: (context, blurValue, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                child: AbsorbPointer(
                  absorbing: isLoading,
                  child: Center(
                    child: Image.asset(
                      "assets/basic_icons/zayro_loader_animation.gif",
                      height: 8.h,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
