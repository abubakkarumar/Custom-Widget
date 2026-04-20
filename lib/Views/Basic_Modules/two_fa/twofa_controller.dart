
import 'package:flutter/material.dart';

class TwoFAController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  TextEditingController verificationCode = TextEditingController();

  bool isLoading = false;

  setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  resetData() {
    verificationCode.clear();
    notifyListeners();
  }

}
