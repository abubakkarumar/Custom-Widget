import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:zayroexchange/Utility/custom_alertbox.dart';
import 'package:zayroexchange/Utility/custom_error_message.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/withdraw/withdraw_api.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

/// Controller for Withdraw view.
///
/// - Holds form controllers (address, amount)
/// - Loads coin list and withdraw details via WithdrawApi
/// - Computes fee / total withdrawable amount
class WithdrawController with ChangeNotifier {
  final WithdrawApi provider = WithdrawApi();

  // Text controllers for address and amount
  final TextEditingController addressController = TextEditingController();
  final TextEditingController withdrawAmountController =
      TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool isTermsAccepted = false;

  void toggleTermsAccepted() {
    isTermsAccepted = !isTermsAccepted;
    notifyListeners();
  }

  // Currently selected coin / network
  CoinModel? selectedCoin;
  String selectedNetwork = "";

  // Optional UI-only symbol (kept for compatibility)
  String? selectedCoinSymbol;

  // Percentages: 0,25,50,75,100
  static const List<int> percentages = [0, 25, 50, 75, 100];

  bool isLoading = false;
  void setLoader(bool val) {
    if (isLoading == val) return;
    isLoading = val;
    notifyListeners();
  }

  // UI state
  int selectedPercentage = 0;
  int tabIndex = 0;

  double availableBalance = 0.0;
  double withdrawFee = 0.0;
  double minWithdrawLimit = 0.0;
  double maxWithdrawLimit = double.infinity;
  double totalWithdrawAmount = 0.0;

  String freeBalanceStr = "";
  String settingsNetwork = "";
  String minimumWithdrawFee = "";
  String withdrawFeeType = "";
  String minimumWithdraw = "";
  String maximumWithdraw = "";
  String perDayWithdraw = "";

  String transactionId = "";
  String verifiedKyc = "";
  String verified2fa = "";
  String withdrawVerifyMessage = "";
  String createdAt = "";
  String updatedAt = "";

  // Coin list from API
  List<CoinModel> coinList = [];

  int percentageResetVersion = 0;
  bool isConfirmWithdrawCalled = false;

  void resetPercentagePicker() {
    percentageResetVersion++;
    selectedPercentage = 0;
    notifyListeners();
  }

  // -----------------------------
  // State setters & computations
  // -----------------------------

  /// Reset coin + network selection.
  void resetSelection() {
    selectedCoin = null;
    selectedNetwork = "";
    selectedCoinSymbol = null;
    addressController.clear();
    withdrawAmountController.clear();
    isConfirmWithdrawCalled = false;
    minimumWithdraw = "";
    maximumWithdraw = "";
    perDayWithdraw = "";
    minimumWithdrawFee = '';
    withdrawFeeType = "";
    freeBalanceStr = "";
    withdrawVerifyMessage = "";

    notifyListeners();
  }

  void selectCoin(CoinModel coin) {
    selectedCoin = coin;
    selectedCoinSymbol = coin.symbol;
    selectedNetwork = "";
    freeBalanceStr = "";
    availableBalance = 0.0;
    withdrawAmountController.text = "";
    _computeTotalWithdrawAmount(noNotify: true);
    notifyListeners();
  }

  void selectNetwork(String network) {
    // Clear address when network changes/gets selected to avoid stale address usage.
    addressController.clear();
    selectedNetwork = network;
    notifyListeners();
  }

  /// Sets selected percentage (0..100) and recomputes amount/total.
  void setSelectedPercentage(int val) {
    final newVal = val.clamp(0, 100);
    if (selectedPercentage == newVal) return;
    selectedPercentage = newVal;
    setPercentageAmount(selectedPercentage);
    // setPercentageAmount calls notifyListeners()
  }

  resetPercentage(int val) {
    selectedPercentage = val;
    notifyListeners();
  }

  /// Compute amount from percentage & availableBalance, write to text controller,
  /// then compute total withdraw amount (after fee).
  void setPercentageAmount(int percentage) {
    selectedPercentage = percentage.clamp(0, 100);

    // If availableBalance is zero but we have a freeBalanceStr from API, try parsing it
    if (availableBalance == 0.0 && freeBalanceStr.isNotEmpty) {
      availableBalance =
          double.tryParse(freeBalanceStr.replaceAll(',', '')) ?? 0.0;
    }

    final double amount = (selectedPercentage / 100.0) * availableBalance;

    // precision: use tabIndex to decide decimals (keeps your previous logic)
    final int precision = tabIndex == 0 ? 8 : 2;
    final String formatted = amount.toStringAsFixed(precision);

    // Only update controller if value changed (avoid unnecessary cursor jumps)
    if (withdrawAmountController.text != formatted) {
      withdrawAmountController.text = formatted;
    }

    // Recalculate total (no notify yet)
    _computeTotalWithdrawAmount(noNotify: true);

    notifyListeners();
  }

  /// Recompute totalWithdrawAmount using withdrawAmountController.text and fee.
  /// Set `noNotify` to true to avoid notifying listeners (internal usage).
  void _computeTotalWithdrawAmount({bool noNotify = false}) {
    final amount = double.tryParse(withdrawAmountController.text) ?? 0.0;

    double newTotal = 0.0;

    if (amount <= 0.0) {
      newTotal = 0.0;
    } else {
      // enforce min/max constraints
      final meetsBounds =
          (amount >= minWithdrawLimit) && (amount <= maxWithdrawLimit);

      if (!meetsBounds) {
        // If amount is out of bounds, consider total zero (you can change behavior)
        newTotal = 0.0;
      } else {
        if (withdrawFeeType.toLowerCase() == 'fixed') {
          // fixed fee deducted from amount
          newTotal = (amount - withdrawFee).clamp(0.0, double.infinity);
        } else {
          // treat withdrawFee as percent (e.g. withdrawFee = 1.5 => 1.5%)
          final feePercent = withdrawFee;
          final feeValue = amount * feePercent / 100.0;
          newTotal = (amount - feeValue).clamp(0.0, double.infinity);
        }
      }
    }

    // notify only on change (or when caller wants notification)
    if (totalWithdrawAmount != newTotal) {
      totalWithdrawAmount = newTotal;
      if (!noNotify) notifyListeners();
    } else if (!noNotify) {
      notifyListeners();
    }
  }

  /// Public wrapper to recompute and notify.
  void setTotalWithdrawAmount() {
    _computeTotalWithdrawAmount(noNotify: false);
  }

  // -------------------------------
  // Networking / API calls
  // -------------------------------

  /// Fetch coin list. Clears loader on exit.
  Future<void> getCoins(BuildContext context) async {
    setLoader(true);
    try {
      final value = await provider.getCoinList();
      setLoader(false);
      // provider.getCoinList() should return a JSON string or map-like object
      final parsed = json.decode(value.toString());

      if (parsed is Map && parsed["success"] == true) {
        coinList.clear();
        final data = parsed["data"];
        if (data is List && data.isNotEmpty) {
          for (var item in data) {
            // Defensive access of fields
            coinList.add(
              CoinModel(
                id: item["id"] is int
                    ? item["id"]
                    : int.tryParse(item["id"]?.toString() ?? '0') ?? 0,

                name: item["name"]?.toString() ?? "",
                symbol: item["symbol"]?.toString() ?? "",
                type: item["type"]?.toString() ?? "",

                decimalPlaces: item["decimal_places"] is int
                    ? item["decimal_places"]
                    : int.tryParse(item["decimal_places"]?.toString() ?? '0') ??
                          0,

                /// ✅ Extract network list from settings
                network:
                    (item["settings"] as List<dynamic>?)
                        ?.map((e) => e["network"]?.toString())
                        .whereType<String>()
                        .toList() ??
                    [],

                activeDeposit: (item['settings'] != null && item['settings'].runtimeType == List<dynamic>) ?
                item['settings'].toString() != "[]" ?
                item['settings'][0]['activate_deposit'] : 1 : 0,
                activeWithdraw: (item['settings'] != null && item['settings'].runtimeType == List<dynamic>) ?
                item['settings'].toString() != "[]" ?
                item['settings'][0]['activate_withdraw'] : 1 : 0,

                imageUrl: item["image_url"]?.toString() ?? "",
              ),
            );
          }
        }
        notifyListeners();
      } else {
        if (!context.mounted) return;
        _showParsedError(context, parsed, ["error"]);
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

  Future<void> getTransactionStatus(BuildContext context) async {
    setLoader(true);
    try {
      final value = await provider.getTransactionStatus();
      setLoader(false);
      final parsed = json.decode(value.toString());

      if (parsed is Map<String, dynamic> && parsed["success"] == true) {
        final data = parsed["data"] as Map<String, dynamic>?;

        if (data != null) {
          transactionId = data["id"]?.toString() ?? "";
          verifiedKyc = data["verified_kyc"]?.toString() ?? "0";
          verified2fa = data["verified_2fa"]?.toString() ?? "0";
          createdAt = data["created_at"]?.toString() ?? "";
          updatedAt = data["updated_at"]?.toString() ?? "";
        }

        notifyListeners();
      } else {
        print("Tfa disable");
        verified2fa = "-1";
        notifyListeners();
        if (!context.mounted) return;
        _showParsedError(context, parsed, ["error"]);
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

  /// Fetch withdraw details (balances, fees) for a given symbol.
  Future<bool> getWithdrawDetails(BuildContext context, String symbol) async {
    setLoader(true);

    try {
      final value = await provider.getWithdrawDetails({"symbol": symbol});
      setLoader(false);

      final parsed = json.decode(value.toString());

      if (parsed is Map && parsed["success"] == true) {
        final wallet = parsed["data"]?["wallet"];

        if (wallet != null && wallet is Map) {
          freeBalanceStr = wallet["free_balance"]?.toString() ?? "";
          availableBalance =
              double.tryParse(freeBalanceStr.replaceAll(',', '')) ?? 0.0;

          final settingsList = wallet["settings"];
          final List settingsArr = (settingsList is List) ? settingsList : [];

          if (settingsArr.isNotEmpty && settingsArr[0] is Map) {
            final settings = settingsArr[0] as Map;

            settingsNetwork = settings["network"]?.toString() ?? "";
            minimumWithdrawFee =
                settings["minimum_withdraw_fee"]?.toString() ?? "";
            withdrawFeeType = settings["withdraw_fee_type"]?.toString() ?? "";
            minimumWithdraw = settings["minimum_withdraw"]?.toString() ?? "";
            maximumWithdraw = settings["maximum_withdraw"]?.toString() ?? "";
            perDayWithdraw = settings["per_day_withdraw"]?.toString() ?? "";

            withdrawFee =
                double.tryParse(minimumWithdrawFee.replaceAll(',', '')) ?? 0.0;

            minWithdrawLimit =
                double.tryParse(minimumWithdraw.replaceAll(',', '')) ?? 0.0;

            if (maximumWithdraw.trim().isNotEmpty) {
              maxWithdrawLimit =
                  double.tryParse(maximumWithdraw.replaceAll(',', '')) ??
                  double.infinity;
            } else {
              maxWithdrawLimit = double.infinity;
            }
          }

          _computeTotalWithdrawAmount(noNotify: true);
          notifyListeners();

          return true; // ✅ SUCCESS
        } else {
          if (!context.mounted) return false;
          _showParsedError(context, parsed, ['symbol', 'error']);
          return false; // ❌ No wallet
        }
      } else {
        if (!context.mounted) return false;
        Navigator.pop(context);
        _showParsedError(context, parsed, ['symbol', 'error']);
        return false; // ❌ success == false (like 2FA error)
      }
    } catch (e) {
      setLoader(false);

      if (context.mounted) {
        AppToast.show(
          context: context,
          message: e.toString(),
          type: ToastType.error,
        );
      }

      return false; // ❌ Exception
    }
  }

  Future<void> withDrawVerifyOtp(BuildContext context, String symbol) async {
    withdrawVerifyMessage = "";
    setLoader(true);

    try {
      final value = await provider.withDrawVerifyOtp({
        "symbol": symbol,
        "network": selectedNetwork,
        "amount": withdrawAmountController.text,
        "to_address":
            //"1fTqJrQ2GnRnv8BN4xgvKfJ7HwEP8crsL"
            addressController.text,
      });

      setLoader(false);

      final parsed = json.decode(value.toString());

      if (parsed['success'] == true) {
        withdrawVerifyMessage = (parsed['message'] ?? "").toString();
        isConfirmWithdrawCalled = true;
        codeController.clear();
        if (verified2fa == '0') {
          addressController.clear();
          withdrawAmountController.clear();
          getWithdrawDetails(context, symbol);
        }
        notifyListeners();
        _showSuccessToast(context, parsed['message']);
      } else {
        withdrawVerifyMessage = "";
        isConfirmWithdrawCalled = false;
        _showParsedError(context, parsed, [
          'symbol',
          'network',
          'amount',
          'to_address',
          'error',
        ]);
        codeController.clear();
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

  Future<void> withDrawConfirm(BuildContext context, String symbol) async {
    setLoader(true);

    try {
      final value = await provider.withDrawConfirm({
        "symbol": symbol,
        "network": selectedNetwork,
        "amount": withdrawAmountController.text,
        "to_address": addressController.text,
        "otp": codeController.text,
      });

      setLoader(false);

      final parsed = json.decode(value.toString());

      if (parsed['success'] == true) {
        _showSuccessToast(context, parsed['message']);
        withdrawAmountController.clear();
        addressController.clear();
        Navigator.pop(
          context,
        );
      } else {
        _showParsedError(context, parsed, [
          'symbol',
          'network',
          'amount',
          'to_address',
          'otp',
          'error',
        ]);
        codeController.clear();
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

  // -------------------------------
  // Toast helpers
  // -------------------------------

  void _showSuccessToast(BuildContext context, String message) {
    if (message.isEmpty) return;
    CustomAnimationToast.show(
      context: context,
      message: message,
      type: ToastType.success,
    );
  }

  void _showErrorToast(BuildContext context, String message) {
    if (message.isEmpty) return;
    CustomAnimationToast.show(
      context: context,
      message: message,
      type: ToastType.error,
    );
  }

  /// Attempt to extract useful message fields from API error payload and show toast.
  void _showParsedError(
    BuildContext context,
    dynamic parsed,
    List<String> keys,
  ) {
    String errorMessage = "";
    try {
      if (parsed is Map && parsed['data'] != null) {
        final data = parsed['data'];
        for (var key in keys) {
          if (data is Map && data.containsKey(key) && data[key] != null) {
            errorMessage += data[key]
                .toString()
                .replaceAll('null', '')
                .replaceAll('[', '')
                .replaceAll(']', '');
          } else {
            // fallback: if parsed contains key at root level
            if (parsed.containsKey(key) && parsed[key] != null) {
              errorMessage += parsed[key]
                  .toString()
                  .replaceAll('null', '')
                  .replaceAll('[', '')
                  .replaceAll(']', '');
            }
          }
        }
      } else if (parsed is Map && parsed.containsKey('message')) {
        errorMessage = parsed['message']?.toString() ?? "";
      }
    } catch (_) {
      // ignore parsing errors
    }
    if (errorMessage.isNotEmpty) {
      _showErrorToast(context, errorMessage);
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    withdrawAmountController.dispose();
    super.dispose();
  }
}

/// Simple model for Coin items returned from API.
class CoinModel {
  final int id;
  final String name;
  final String symbol;
  final String type;
  final int decimalPlaces;
  final List<String> network;
  final String imageUrl;

  // Optional display values
  final String price;
  final String change;

  bool isFavorite;
  final int activeDeposit;
  final int activeWithdraw;

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
