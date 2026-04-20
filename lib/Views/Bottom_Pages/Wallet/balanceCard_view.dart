import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/wallet_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

// ================== SPOT BALANCE CARD ==================

class SpotBalanceCard extends StatefulWidget {
  final WalletController controller;
  final double usdBalance;
  final double eurBalance;
  final String currency;

  const SpotBalanceCard({
    super.key,
    required this.controller,
    required this.usdBalance,
    required this.eurBalance,
    this.currency = 'USD',
  });

  @override
  State<SpotBalanceCard> createState() => _SpotBalanceCardState();
}

class _SpotBalanceCardState extends State<SpotBalanceCard> {
  late String _selectedCurrency;

  final Map<String, String> _currencySymbols = {
    'USD': r'$',
    'EUR': '€',
  };

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.currency;
  }

  double _amount() =>
      _selectedCurrency == 'EUR'
          ? widget.eurBalance
          : widget.usdBalance;

  @override
  Widget build(BuildContext context) {
    final bool hide = widget.controller.hideBalance;
    final String symbol = _currencySymbols[_selectedCurrency] ?? '';

    return SizedBox(
      height: 20.h,
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset(
            AppThemeIcons.walletOverviewContent(context),
            fit: BoxFit.cover,
            width: 100.w,
          ),
          Positioned(
            left: 15.sp,
            top: 3.5.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomText(
                      label:
                      AppLocalizations.of(context)!.availableBalance,
                      fontSize: 16.sp,
                      fontColour: Colors.white,
                      labelFontWeight: FontWeight.bold,
                    ),
                    IconButton(
                      icon: Icon(
                        hide
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      onPressed: () =>
                          widget.controller.setHideBalance(!hide),
                    ),
                  ],
                ),
                Row(
                  children: [
                    CustomText(
                      label: hide
                          ? '********'
                          : '$symbol ${_amount().toStringAsFixed(2)}',
                      fontSize: 16.5.sp,
                      fontColour: Colors.white,
                      labelFontWeight: FontWeight.bold,
                    ),
                    SizedBox(width: 12.sp),
                    DropdownButton<String>(
                      value: _selectedCurrency,
                      underline: const SizedBox(),
                      dropdownColor: const Color(0xFF1B232D),
                      items: const ['USD', 'EUR']
                          .map(
                            (c) => DropdownMenuItem(
                          value: c,
                          child: CustomText(
                            label: c,
                            fontColour: Colors.white,
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _selectedCurrency = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================== FUTURE BALANCE CARD ==================

class FutureBalanceCard extends StatefulWidget {
  final WalletController controller;
  final double usdBalance;
  final double btcBalance;
  final String currency;

  const FutureBalanceCard({
    super.key,
    required this.controller,
    required this.usdBalance,
    required this.btcBalance,
    this.currency = 'USD',
  });

  @override
  State<FutureBalanceCard> createState() => _FutureBalanceCardState();
}

class _FutureBalanceCardState extends State<FutureBalanceCard> {
  late String _selectedCurrency;

  final Map<String, String> _currencySymbols = {
    'USD': r'$',
    'BTC': '₿',
  };

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.currency;
  }

  double _amount() =>
      _selectedCurrency == 'BTC'
          ? widget.btcBalance
          : widget.usdBalance;

  @override
  Widget build(BuildContext context) {
    final bool hide = widget.controller.hideBalance;
    final String symbol = _currencySymbols[_selectedCurrency] ?? '';

    return SizedBox(
      height: 20.h,
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset(
            AppThemeIcons.walletOverviewContent(context),
            fit: BoxFit.cover,
            width: 100.w,
          ),
          Positioned(
            left: 15.sp,
            top: 3.5.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomText(
                      label:"futureBalance",
                      fontSize: 16.sp,
                      fontColour: Colors.white,
                      labelFontWeight: FontWeight.bold,
                    ),
                    IconButton(
                      icon: Icon(
                        hide
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      onPressed: () =>
                          widget.controller.setHideBalance(!hide),
                    ),
                  ],
                ),
                Row(
                  children: [
                    CustomText(
                      label: hide
                          ? '********'
                          : '$symbol ${_amount().toStringAsFixed(
                        _selectedCurrency == 'BTC' ? 6 : 2,
                      )}',
                      fontSize: 16.5.sp,
                      fontColour: Colors.white,
                      labelFontWeight: FontWeight.bold,
                    ),
                    SizedBox(width: 12.sp),
                    DropdownButton<String>(
                      value: _selectedCurrency,
                      underline: const SizedBox(),
                      dropdownColor: const Color(0xFF1B232D),
                      items: const ['USD', 'BTC']
                          .map(
                            (c) => DropdownMenuItem(
                          value: c,
                          child: CustomText(
                            label: c,
                            fontColour: Colors.white,
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _selectedCurrency = val);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
