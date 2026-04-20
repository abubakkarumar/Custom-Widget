import 'package:flutter/material.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class SegmentedToggleController with ChangeNotifier {
  bool isRegister = true;
  String title = "";

  /// Loader State
  bool isLoading = false;

  /// Set loader with notification
  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void toggle(BuildContext context, bool value) {
    isRegister = value;
    if (isRegister == true) {
      title =  AppLocalizations.of(context)!.register;
    } else {
      title =  AppLocalizations.of(context)!.login;
    }
    notifyListeners();
  }
}
