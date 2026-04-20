import 'dart:convert';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';

import 'chart_order_book.dart';


class ChartOrderBook extends StatelessWidget {
  final SpotTradeController controller;


  const ChartOrderBook({
    super.key,
    required this.controller,

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
        final List<OBLevelKChart> bids =
        controller.bidsMap.entries
            .map((e) => OBLevelKChart(price: e.key, qty: e.value))
            .toList()
          ..sort((a, b) => b.price.compareTo(a.price));

        final List<OBLevelKChart> asks =
        controller.asksMap.entries
            .map((e) => OBLevelKChart(price: e.key, qty: e.value))
            .toList()
          ..sort((a, b) => a.price.compareTo(b.price));

        final topBids = bids.take(50).toList();
        final topAsks = asks.take(50).toList();

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

            return KChartOrderBook(
              bids: topBids,
              asks: topAsks,
              livePrice: controller.storedLivePrice,
              markPrice: controller.storedMarkPrice,
              rows: 40,
              type: "spot",
              side: controller.selectedType,
              remainHeight: 1,
              spreadPercent: controller.percentChange * 100,
            );
          },
        );
      },
    );
  }

  List<OBLevelKChart> buildPriceGroupedLevels(
      List<OBLevelKChart> levels,
      double step,
      bool isBid,
      ) {
    if (levels.isEmpty || step <= 0) return [];

    final Map<double, double> grouped = {};

    for (final level in levels) {
      final bucketPrice = normalizePrice(level.price, step, isBid);

      grouped[bucketPrice] = (grouped[bucketPrice] ?? 0) + level.qty;
    }

    final result = grouped.entries
        .map((e) => OBLevelKChart(price: e.key, qty: e.value))
        .toList();

    // If this depth does not exist in current order book range,
    // avoid showing a misleading single aggregated row.
    if (result.length < 2) return [];

    result.sort((a, b) =>
    isBid ? b.price.compareTo(a.price) : a.price.compareTo(b.price));

    return result.take(50).toList();
  }


  double normalizePrice(double price, double step, bool isBid) {
    final decimals = decimalsFromStep(step);
    final factor = Math.pow(10, decimals);

    double bucket;

    if (isBid) {
      bucket = (price / step).floor() * step;
    } else {
      bucket = (price / step).ceil() * step;
    }

    /// remove floating garbage
    return (bucket * factor).round() / factor;
  }
  int decimalsFromStep(double step) {
    String text = step.toString();

    if (!text.contains('.')) return 0;

    return text.split('.')[1].length;
  }


  /// ================= INTERNAL ORDER BOOK =================
  Widget _buildInternalOrderBook() {
    // final bucketBids = buildPriceGroupedLevels(
    //   controller.internalBuyList,
    //   controller.quantityDepth,
    //   true,
    // );
    //
    // final bucketAsks = buildPriceGroupedLevels(
    //   controller.internalSellList,
    //   controller.quantityDepth,
    //   false,
    // );

    return KChartOrderBook(
      bids: controller.internalBuyListKChart,
      asks: controller.internalSellListKChart,
      livePrice: controller.selectedLivePrice,
      markPrice: "0",
      rows: 40,
      type: "spot",
      side: controller.selectedType,
      remainHeight: 1,
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
