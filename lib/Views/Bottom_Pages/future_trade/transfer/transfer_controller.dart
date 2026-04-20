import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'transfer_api.dart';

class TransferController extends ChangeNotifier {
  TransferAPI provider = TransferAPI();
  final formKey = GlobalKey<FormState>();

  TextEditingController fromWalletController = TextEditingController();
  TextEditingController toWalletController = TextEditingController();
  TextEditingController coinController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  double availableBalance = 0.0;

  bool isLoading = false;
  bool isSuccess = false;

  List<String> walletTypeList = ['Spot', 'Futures'];
  List<String> coinList = ['USDT', 'USDC'];

  setLoader(bool value) {
    isLoading = value;
    notifyListeners();
  }

  setCoin({required String coinVal}) {
    coinController.text = coinVal;
    notifyListeners();
  }

  resetData() {
    amountController.clear();
    fromWalletController.text = walletTypeList[0].toString();
    toWalletController.text = walletTypeList[1].toString();
    notifyListeners();
  }



  changeWalletType() {
    if (fromWalletController.text == walletTypeList[0].toString()) {
      fromWalletController.text = walletTypeList[1].toString();

      toWalletController.text = walletTypeList[0].toString();

    } else {
      fromWalletController.text = walletTypeList[0].toString();

      toWalletController.text = walletTypeList[1].toString();

    }
    amountController.clear();
    getWalletBalance();
    notifyListeners();

  }


  setFromWallet(String type) {
    fromWalletController.text = type;

    if (fromWalletController.text == walletTypeList[0].toString()) {

      toWalletController.text = walletTypeList[1].toString();

    } else {

      toWalletController.text = walletTypeList[0].toString();

    }
    amountController.clear();
    getWalletBalance();
    notifyListeners();
  }

  setToWallet(String type) {
    toWalletController.text = type;

    if (toWalletController.text == walletTypeList[0].toString()) {

      fromWalletController.text = walletTypeList[1].toString();

    } else {

      fromWalletController.text = walletTypeList[0].toString();

    }
    amountController.clear();
    getWalletBalance();
    notifyListeners();
  }
  Future getWalletBalance() async {
    setLoader(true);
    await provider
        .getWalletBalance(
            fromWallet: fromWalletController.text.toLowerCase(),
            coin: coinController.text)
        .then((value) {
      final parsed = json.decode(value.toString());
      setLoader(false);

      if (parsed['success'] == true) {
        availableBalance =
            double.parse(parsed['data']['fromBalance'].toString());
        notifyListeners();
      }
      // else {
      //   CustomFlutterToast.show(
      //       message: parsed['message'].toString(), context: context);
      // }
    }).catchError((e) {});
    notifyListeners();
  }

  Future doTransfer(BuildContext context) async {
    setLoader(true);
    await provider
        .doTransfer(
            coin: coinController.text,
            amount: amountController.text,
            fromWallet: fromWalletController.text.toLowerCase(),
            toWallet: toWalletController.text.toLowerCase())
        .then((value) async {
      setLoader(false);
      final parsed = json.decode(value.toString());
      isSuccess = parsed['success'];
      if (parsed['success'] == true) {
        if (parsed['data'] != []) {
          Fluttertoast.showToast(
              msg: parsed['message'].toString());

          setLoader(false);
        }
      } else {
        Fluttertoast.showToast(
            msg: parsed['message'].toString());
        var errorMessage = "";
        List<String> keyList = <String>[
          'coin_id',
          'amount',
          'from_wallet',
          'to_wallet',
          'error',
        ];
        for (var key in keyList) {
          if (parsed['data'].toString().contains(key)) {
            errorMessage += parsed['data'][key]
                .toString()
                .replaceAll('[', '')
                .replaceAll('null', '')
                .replaceAll(']', '');
          }
        }
        Fluttertoast.showToast(msg: errorMessage);
      }
    }).catchError((e) {
      setLoader(false);
    });
    notifyListeners();
  }
}

class CryptoCurrenciesList {
  final int? id;
  final String? coin, coinName, coinImage, coinType;

  CryptoCurrenciesList({
    this.id,
    this.coin,
    this.coinName,
    this.coinImage,
    this.coinType,
  });
}
