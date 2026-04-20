import 'package:flutter/material.dart';

class AppNavigator {
  static BuildContext? get context =>
      navigatorKey.currentState?.overlay?.context;

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static Future<dynamic>? pushTo(Widget page) {
    return navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static Future<dynamic>? replaceWith(Widget page) {
    return navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static void pop() {
    return navigatorKey.currentState?.pop();
  }

  static void popToRoot() {
    return navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }
  static Future<dynamic>? replaceAllWith(Widget page) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return null;

    return navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
          (route) => false,
    );
  }

  // static Future<dynamic>? replaceAllWith(Widget page) {
  //   final ctx = context;
  //   if (ctx == null) return null;
  //
  //   return Navigator.of(ctx, rootNavigator: true).pushAndRemoveUntil(
  //     MaterialPageRoute(builder: (_) => page),
  //         (route) => false,
  //   );
  // }
}
