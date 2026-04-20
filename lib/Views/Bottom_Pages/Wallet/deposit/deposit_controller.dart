import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import 'deposit_api.dart';

class DepositController with ChangeNotifier {
  DepositApi provider = DepositApi();
  final TextEditingController addressController = TextEditingController();

  bool isLoading = false;

  setLoader(bool val) {
    isLoading = val;
    notifyListeners();
  }

  List<CoinModel> coinList = [];

  CoinModel? selectedCoin;

  String addressQRCode = "";
  String selectedNetwork = "";

  void resetSelection() {
    selectedCoin = null;
    selectedNetwork = "";

    addressController.clear();
        addressQRCode = "";
    notifyListeners();
  }

  void selectCoin(CoinModel coin) {
    selectedCoin = coin;
    // reset network when coin changes
    selectedNetwork = "";
    notifyListeners();
  }

  void selectNetwork(String network) {
    selectedNetwork = network;
    notifyListeners();
  }

  // your getCoins(...) from the question (unchanged except loader name)
  Future<void> getCoins(BuildContext context) async {
    setLoader(true);
    await provider
        .getCoinList()
        .then((value) {
          setLoader(false);
          final parsed = json.decode(value.toString());

          if (parsed["success"] == true) {
            coinList.clear();

            if (parsed["data"].toString() != "[]") {
              for (var data in parsed["data"]) {
                coinList.add(
                  CoinModel(
                    id: data["id"] is int
                        ? data["id"]
                        : int.tryParse(data["id"]?.toString() ?? '0') ?? 0,

                    name: data["name"]?.toString() ?? "",
                    symbol: data["symbol"]?.toString() ?? "",
                    type: data["type"]?.toString() ?? "",
                    decimalPlaces: data["decimal_places"] is int
                        ? data["decimal_places"]
                        : int.tryParse(
                                data["decimal_places"]?.toString() ?? '0',
                              ) ??
                              0,
                    imageUrl: data["image_url"]?.toString() ?? "",

                    activeDeposit: (data['settings'] != null && data['settings'].runtimeType == List<dynamic>) ?
                    data['settings'].toString() != "[]" ?
                    data['settings'][0]['activate_deposit'] : 1 : 0,
                    activeWithdraw: (data['settings'] != null && data['settings'].runtimeType == List<dynamic>) ?
                    data['settings'].toString() != "[]" ?
                    data['settings'][0]['activate_withdraw'] : 1 : 0,

                    /// ✅ Extract networks from settings
                    network:
                        (data["settings"] as List<dynamic>?)
                            ?.map((e) => e["network"]?.toString())
                            .whereType<String>()
                            .toList() ??
                        [],
                  ),
                );
              }
            }
            notifyListeners();
          } else {
            if (!context.mounted) return;
            _showParsedError(context, parsed, ["error"]);
          }
        })
        .catchError((e) {
          setLoader(false);
          AppToast.show(
            context: context,
            message: e.toString(),
            type: ToastType.error,
          );
        });
  }

  double minimumDepositFee = 0.0;
  String minimumDeposit = "";

  Future<void> getDepositDetails(
    BuildContext context,
    String symbol,
    int index,
    String networkValue,
  ) async {
    setLoader(true);

    try {
      final value = await provider.getDepositDetails({"symbol": symbol});
      final parsed = json.decode(value.toString());
      setLoader(false);

      if (parsed["success"] == true) {
        final wallet = parsed["data"]?["wallet"];

        if (wallet != null) {
          /// -----------------------
          /// 1️⃣  Extract address data
          /// -----------------------
          final addressList = wallet["address"] as List? ?? [];

          String network = "";
          String address = "";
          String qrcode = "";
          print("ADDRESS LIST $addressList");
          if (addressList.isNotEmpty) {
            final addr = addressList[index];
            for (var element in addressList) {
              print("Addressnetwork ${element['network'].toString().toLowerCase()} AND ${networkValue.toLowerCase()}");
              if (element['network'].toString().toLowerCase() ==
                  networkValue.toLowerCase()) {
                print("ADDRESS LIST NETWORK ${addr["network"]}");
                network = element["network"]?.toString() ?? "";
                address = element["address"]?.toString() ?? "";
                qrcode = element["qrcode"]?.toString() ?? "";
              }
            }
          }else{
            _showErrorToast(context, AppLocalizations.of(context)!.addressNotAvailable);
          }

          selectedNetwork = network;
          addressController.text = address;
          addressQRCode = qrcode;

          /// -----------------------
          /// 2️⃣  Extract settings data
          /// -----------------------
          final settingsList = wallet["settings"] as List? ?? [];

          double minimumDepositFee = 0.0;
          String minimumDeposit = "";

          if (settingsList.isNotEmpty) {
            final settings = settingsList[0];

            minimumDepositFee = (settings["minimum_deposit_fee"] ?? 0)
                .toDouble();

            minimumDeposit = settings["minimum_deposit"]?.toString() ?? "";
          }

          /// Save extracted values to controller (add these fields in your controller)
          this.minimumDepositFee = minimumDepositFee;
          this.minimumDeposit = minimumDeposit;

          debugPrint("Minimum Deposit Fee ----> $minimumDepositFee");
          debugPrint("Minimum Deposit --------> $minimumDeposit");
        }

        // _showSuccessToast(context, parsed['message']);
        notifyListeners();
      } else {
        if (!context.mounted) return;
        _showParsedError(context, parsed, ['symbol', 'error']);
        Navigator.pop(context);
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

  /*
  void _showSuccessToast(BuildContext context, String message) {
    CustomAnimationToast.show(
      context: context,
      message: message,
      type: ToastType.success,
    );
  }
*/

  void _showErrorToast(BuildContext context, String message) {
    CustomAnimationToast.show(
      context: context,
      message: message,
      type: ToastType.error,
    );
  }

  void _showParsedError(
    BuildContext context,
    dynamic parsed,
    List<String> keys,
  ) {
    String errorMessage = "";
    for (var key in keys) {
      if (parsed['data'].toString().contains(key)) {
        errorMessage += parsed['data'][key]
            .toString()
            .replaceAll('null', '')
            .replaceAll('[', '')
            .replaceAll(']', '');
      }
    }
    if (errorMessage.isNotEmpty) {
      _showErrorToast(context, errorMessage);
    }
  }
}

class CoinModel {
  final int id;
  final String name;
  final String symbol;
  final String type;
  final int decimalPlaces;
  final List<String> network;
  final String imageUrl;

  // Optional dummy values for now – you can replace with real API later
  final String price;
  final String change;
  final int activeDeposit;
  final int activeWithdraw;

  bool isFavorite;

  CoinModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.type,
    required this.decimalPlaces,
    required this.network,
    required this.imageUrl,
    this.price = "48,750.30",
    this.change = "+3.5%",
    this.isFavorite = false,
    this.activeDeposit = 1,
    this.activeWithdraw = 1,
  });
}
