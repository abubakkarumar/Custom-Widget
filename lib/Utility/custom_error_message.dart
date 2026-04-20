import 'package:flutter/material.dart';

import 'custom_alertbox.dart';

class AppToast {
  static void show({
    required BuildContext context,
    String? message,
    ToastType type = ToastType.success,
    dynamic parsedResponse,
    List<String>? errorKeys,
  }) {
    String finalMessage = message ?? "";

    /// 🔹 If backend parsed response is provided
    if (parsedResponse != null && errorKeys != null) {
      for (var key in errorKeys) {
        print("Error Data${parsedResponse['data']}");
        print("Error Data Key$key");
        if (parsedResponse['data'].toString().contains(key)) {
          finalMessage += parsedResponse['data'][key]
              .toString()
              .replaceAll('null', '')
              .replaceAll('[', '')
              .replaceAll(']', '');
        }
      }

      type = ToastType.error;
    }

    /// 🔹 If message exists, show toast
    if (finalMessage.isNotEmpty) {
      CustomAnimationToast.show(
        context: context,
        message: finalMessage,
        type: type,
      );
    }
  }
}
