import 'dart:convert';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/future_trade_controller.dart';
import 'orderbook_future.dart';

class OrderBookUiFuture extends StatelessWidget {
  final FutureTradeController controller;
  final double remainingHeight;

  const OrderBookUiFuture({
    super.key,
    required this.controller,
    required this.remainingHeight,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ================= ORDER BOOK =================
        Expanded(
          child: _buildSocketOrderBook(),
        ),
      ],
    );
  }

  /// ================= SOCKET ORDER BOOK =================
  Widget _buildSocketOrderBook() {
    return StreamBuilder(
      stream: controller.orderbookStreamController!.stream,
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

        final topBids = bids.take(30).toList();
        final topAsks = asks.take(30).toList();

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
        return StreamBuilder(
          stream: controller.priceStreamController?.stream,
          builder: (context, snap) {
            if (controller.liquidityType == "bybit") {
              if (snap.hasData) {
                try {
                  final data = snap.data as Map<String, dynamic>;

                  if (data.isNotEmpty) {
                    final pair = controller.tradePair.toString();

                    if (data['data'] != null) {
                      if (data['data'].containsKey('symbol') &&
                          data['data']['symbol'].toString() == pair) {
                        if (data['data']['lastPrice'] != null) {
                          controller.lastPrice = double.parse(
                            data['data']['lastPrice'].toString(),
                          );
                          /// ✅ Call your method only the first time
                          if (!controller.firstEventHandled) {
                            controller.handleFirstEvent();
                            WidgetsBinding.instance.addPostFrameCallback((_,) {
                              controller.updatePriceTextForm(data['data']['lastPrice'].toString());
                            },
                            );
                          }
                        }

                        if (data['data']['price24hPcnt'] != null) {
                          controller.change24H =
                              (double.parse(
                                data['data']['price24hPcnt'].toString(),
                              )) *
                                  100;
                        }

                        if (data['data']['volume24h'] != null) {
                          controller.volume24H = double.parse(
                            data['data']['volume24h'].toString(),
                          );
                        }

                        if (data['data']['lowPrice24h'] != null) {
                          controller.low24H = double.parse(
                            data['data']['lowPrice24h'].toString(),
                          );
                        }
                        if (data['data']['markPrice'] != null) {
                          controller.markPrice = double.parse(
                            data['data']['markPrice'].toString(),
                          );
                        }




                      }
                    }
                  }
                } catch (e) {
                  //
                }
              } else {}
            }
        // return StreamBuilder<dynamic>(
        //   stream: controller.priceStreamController!.stream,
        //   builder: (context, snapshot) {
        //
        //     if (!snapshot.hasData || snapshot.data == null) {
        //       return const SizedBox();
        //     }
        //
        //     final Map<String, dynamic> parsed =
        //         snapshot.data as Map<String, dynamic>;
        //     final String type = parsed['type'];
        //     final data = parsed['data'];
        //     if (data == null || data is! Map<String, dynamic>) {
        //       return const SizedBox();
        //     }
        //
        //
        //     if(data['symbol'] == controller.coinOne+controller.coinTwo){
        //       // print("SYMBOL DATA ${data} ANDDD ${type}");
        //       controller.storedLivePrice = data['lastPrice']?.toString() ?? "0";
        //       controller.storedMarkPrice = data['markPrice']?.toString() ?? "0";
        //     }

            // final String lastPrice = data['lastPrice']?.toString() ?? "0";
            // final String markPrice = data['markPrice']?.toString() ?? "0";

            return OrderBookFuture(
              bids: bucketBids,
              asks: bucketAsks,
              livePrice: controller.lastPrice.toString(),
              markPrice: controller.change24H.toString(),
              rows: 30,
              type: "spot",
              side: controller.orderTypeController.text,
              remainHeight: remainingHeight,
              spreadPercent: controller.change24H,
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
  
  /// ================= ORDERBOOK PARSER =================
  void _parseOrderBook(String message) {
    try {
      final Map<String, dynamic> parsed =
          jsonDecode(message) as Map<String, dynamic>;

      final data = parsed['data'];
      if (data is! Map) return;
      if(data['s'] != controller.tradePair) return;

      // if(data['s'] != controller.tradePair) {
      //   controller.asksMap.clear();
      //   controller.bidsMap.clear();
      //   return;
      // }

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
