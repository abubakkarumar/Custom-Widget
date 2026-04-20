import 'dart:convert';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/wallet_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';
import 'orderbook.dart';

class OrderBookUiSpot extends StatelessWidget {
  final SpotTradeController controller;
  final WalletController walletController;
  final double remainingHeight;

  const OrderBookUiSpot({
    super.key,
    required this.controller,
    required this.walletController,
    required this.remainingHeight,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNormalLiquidity =
        controller.selectedLiquiditySymbol.toString().toLowerCase() == "normal";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ================= ORDER BOOK =================
        Expanded(
          child: isNormalLiquidity
              ? _buildInternalOrderBook()
              : _buildSocketOrderBook(),
        ),
      ],
    );
  }

  /// ================= SOCKET ORDER BOOK =================
  Widget _buildSocketOrderBook() {
    return StreamBuilder(
      stream: controller.spotOrderBookStreamController.stream,
      builder: (context, snapshot) {
        /// -------- PARSE SOCKET DATA --------
        if (snapshot.hasData && snapshot.data != null) {
          _parseOrderBook(snapshot.data as String);
        }

        /// -------- BUILD ORDERBOOK LISTS --------
        final List<OBLevel> bids =
            controller.bidsMap.entries
                .map((e) => OBLevel(price: e.key, qty: e.value))
                .toList()
              ..sort((a, b) => b.price.compareTo(a.price));

        final List<OBLevel> asks =
            controller.asksMap.entries
                .map((e) => OBLevel(price: e.key, qty: e.value))
                .toList()
              ..sort((a, b) => a.price.compareTo(b.price));

        final topBids = bids.take(10).toList();
        final topAsks = asks.take(10).toList();


        final bucketBids = buildPriceGroupedLevels(
          bids,
          controller.quantityDepth,
          true,
        );

        final bucketAsks = buildPriceGroupedLevels(
          asks,
          controller.quantityDepth,
          false,
        );



        /// -------- LIVE PRICE STREAM --------
        return StreamBuilder<dynamic>(
          stream: controller.spotStreamController.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const SizedBox();
            }

            final Map<String, dynamic> parsed =
                snapshot.data as Map<String, dynamic>;

            final data = parsed['data'];
            if (data == null || data is! Map<String, dynamic>) {
              return const SizedBox();
            }
            if(data['symbol'] == controller.selectedCoinOne+controller.selectedCoinTwo){
              controller.storedLivePrice = data['lastPrice']?.toString() ?? "0";
              controller.storedMarkPrice = data['markPrice']?.toString() ?? "0";
            }

            // final String lastPrice = data['lastPrice']?.toString() ?? "0";
            // final String markPrice = data['markPrice']?.toString() ?? "0";

            return OrderBook(
              bids: bucketBids,
              asks: bucketAsks,
              livePrice: controller.storedLivePrice,
              markPrice: controller.storedMarkPrice,
              rows: 10,
              type: "spot",
              side: controller.selectedType,
              remainHeight: remainingHeight,
              spreadPercent: controller.percentChange * 100,
            );
          },
        );
      },
    );
  }

  // List<OBLevel> buildPriceGroupedLevels(
  //     List<OBLevel> levels,
  //     double step,
  //     bool isBid,
  //     ) {
  //   if (levels.isEmpty || step <= 0) return [];
  //
  //   final Map<double, double> grouped = {};
  //
  //   for (final level in levels) {
  //     final bucketPrice = normalizePrice(level.price, step, isBid);
  //
  //     grouped[bucketPrice] = (grouped[bucketPrice] ?? 0) + level.qty;
  //   }
  //
  //   final result = grouped.entries
  //       .map((e) => OBLevel(price: e.key, qty: e.value))
  //       .toList();
  //
  //   // If this depth does not exist in current order book range,
  //   // avoid showing a misleading single aggregated row.
  //   if (result.length < 2) return [];
  //
  //   result.sort((a, b) =>
  //   isBid ? b.price.compareTo(a.price) : a.price.compareTo(b.price));
  //
  //   return result.take(10).toList();
  // }


  // ─── in orderbook_ui_spot.dart ────────────────────────────────────────────

  /// Builds aggregated (bucketed) price levels for the order book.
  ///
  /// [levels]  – sorted raw OBLevel list (bids desc, asks asc)
  /// [step]    – the grouping step size selected by the user (e.g. 0.1, 1, 10)
  /// [isBid]   – true for bids (floor to bucket), false for asks (ceil to bucket)
  List<OBLevel> buildPriceGroupedLevels(
      List<OBLevel> levels,
      double step,
      bool isBid,
      ) {
    if (levels.isEmpty || step <= 0) return [];

    // ── Work in integer space to avoid all floating-point drift ──────────────
    final int decimals = decimalsFromStep(step);
    final int factor   = _pow10(decimals);        // e.g. step=0.1 → factor=10
    final int stepInt  = (step * factor).round(); // e.g. 0.1 → 1, 10.0 → 10

    final Map<int, double> grouped = {}; // key = bucket as integer, value = qty

    for (final level in levels) {
      // Skip invalid entries
      if (level.price <= 0 || level.qty <= 0) continue;

      final int priceInt = (level.price * factor).round();

      // Integer floor / ceil  – exact, no floating-point error
      final int bucketInt = isBid
          ? (priceInt ~/ stepInt) * stepInt          // floor
          : ((priceInt + stepInt - 1) ~/ stepInt) * stepInt; // ceiling

      // Skip the zero-bucket that was causing the phantom "0" row
      if (bucketInt <= 0) continue;

      grouped[bucketInt] = (grouped[bucketInt] ?? 0) + level.qty;
    }

    if (grouped.isEmpty) return [];

    // Convert back to double prices and sort
    final result = grouped.entries
        .map((e) => OBLevel(price: e.key / factor, qty: e.value))
        .toList()
      ..sort((a, b) =>
      isBid ? b.price.compareTo(a.price) : a.price.compareTo(b.price));

    return result.take(10).toList();
  }

  /// Safe integer power-of-10 helper (avoids double pow() imprecision)
  int _pow10(int exp) {
    int result = 1;
    for (int i = 0; i < exp; i++) result *= 10;
    return result;
  }

  /// Returns the number of decimal places in [step].
  int decimalsFromStep(double step) {
    final String text = step.toString();
    if (!text.contains('.')) return 0;
    // Trim trailing zeros that Dart appends (e.g. "10.0" → 0 decimals)
    final String frac = text.split('.')[1].replaceAll(RegExp(r'0+$'), '');
    return frac.isEmpty ? 0 : frac.length;
  }


  // int decimalsFromStep(double step) {
  //   String text = step.toString();
  //
  //   if (!text.contains('.')) return 0;
  //
  //   return text.split('.')[1].length;
  // }


  /// ================= INTERNAL ORDER BOOK =================
  Widget _buildInternalOrderBook() {
    final bucketBids = buildPriceGroupedLevels(
      controller.internalBuyList,
      controller.quantityDepth,
      true,
    );

    final bucketAsks = buildPriceGroupedLevels(
      controller.internalSellList,
      controller.quantityDepth,
      false,
    );

    return OrderBook(
      bids: bucketBids,
      asks: bucketAsks,
      livePrice: controller.selectedLivePrice,
      markPrice: "0",
      rows: 10,
      type: "spot",
      side: controller.selectedType,
      remainHeight: remainingHeight,
      spreadPercent: controller.percentageInternal,
    );
  }

  /// ================= ORDERBOOK PARSER =================
  void _parseOrderBook(String message) {
    try {
      final Map<String, dynamic> parsed =
          jsonDecode(message) as Map<String, dynamic>;

      final data = parsed['data'];

      if (data is! Map) return;

      if(data['s'] != controller.selectedCoinOne+controller.selectedCoinTwo) return;

      /// -------- ASKS --------
      final asks = data['a'];
      if (asks is List) {
        for (final level in asks) {
          if (level is! List || level.length < 2) continue;

          final double price = double.tryParse(level[0].toString()) ?? 0;
          final double qty = double.tryParse(level[1].toString()) ?? 0;

          if (price <= 0) continue;

          if (qty == 0) {
            controller.asksMap.remove(price);
          } else {
            controller.asksMap[price] = qty;
          }
        }
      }

      /// -------- BIDS --------
      final bids = data['b'];
      if (bids is List) {
        for (final level in bids) {
          if (level is! List || level.length < 2) continue;

          final double price = double.tryParse(level[0].toString()) ?? 0;
          final double qty = double.tryParse(level[1].toString()) ?? 0;

          if (price <= 0) continue;

          if (qty == 0) {
            controller.bidsMap.remove(price);
          } else {
            controller.bidsMap[price] = qty;
          }
        }
      }
    } catch (e) {
      debugPrint("OrderBook parse error: $e");
    }
  }
}
