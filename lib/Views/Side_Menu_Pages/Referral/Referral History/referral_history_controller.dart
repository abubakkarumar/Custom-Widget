import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/referral_api.dart';

class ReferralHistoryModel {
  final String? name;
  final String? email;
  final String? date;
  final int? level;
  final bool? isEligible;

  ReferralHistoryModel({
    this.name,
    this.email,
    this.date,
    this.level,
    this.isEligible,
  });
}

class ReferralHistoryController extends ChangeNotifier {
  final ReferralApi provider = ReferralApi();

  bool isLoading = false;
  final List<ReferralHistoryModel> historyList = [];

  void setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> getReferralHistory(BuildContext context) async {
    setLoader(true);

    try {
      final value = await provider.getReferalHistory();
      final parsed = json.decode(value.toString());
      setLoader(false);
      if (parsed["success"] == true) {
        historyList.clear();
        if (parsed['data'].toString() != "[]") {
          for (final data in parsed['data']) {
            final invitee = data['invitee'] ?? {};
            historyList.add(
              ReferralHistoryModel(
                name: invitee['user_name'].toString(),
                email: invitee['email'].toString(),
                date: data['date_time'].toString(),
                level: int.tryParse(data['level'].toString()),
                isEligible: data['is_eligible'] == true,
              ),
            );
          }
        }
        notifyListeners();
      } else {
        if (!context.mounted) return;
        AppToast.show(context: context, parsedResponse: parsed, errorKeys: [
          "error",
        ]);
      }
    } catch (e) {
      setLoader(false);
      AppToast.show(
        context: context,
        message: e.toString(),
        type: ToastType.error,
      );
    }
  }
}
