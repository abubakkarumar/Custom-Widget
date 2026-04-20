import 'dart:convert';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/future_trade_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/kchart_orderbook.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';

import '../../trade/chart_order_book.dart';
import '../../trade/orderbook.dart';
import 'chart_order_book_future.dart';


class ChartOrderBook extends StatelessWidget {
  final FutureTradeController controller;


  const ChartOrderBook({
    super.key,
    required this.controller,

  });

  @override
  Widget build(BuildContext context) {
    final bool isNormalLiquidity =
        controller.liquidityType.toString().toLowerCase() == "normal";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ================= ORDER BOOK =================
        Expanded(
          child:
          // isNormalLiquidity
          //     ? _buildInternalOrderBook()
          //     :
          _buildSocketOrderBook(),
        ),
      ],
    );
  }

  /// ================= SOCKET ORDER BOOK =================
  Widget _buildSocketOrderBook() {
    return StreamBuilder(
      stream: controller.futureOrderBookStreamController.stream,
      builder: (context, snapshot) {
        /// -------- PARSE SOCKET DATA --------
        if (snapshot.hasData && snapshot.data != null) {
          _parseOrderBook(snapshot.data as String);
        }

        /// -------- BUILD ORDERBOOK LISTS --------
        final List<OBLevelKChartFuture> bids =
        controller.bidsMap.entries
            .map((e) => OBLevelKChartFuture(price: e.key, qty: e.value))
            .toList()
          ..sort((a, b) => b.price.compareTo(a.price));

        final List<OBLevelKChartFuture> asks =
        controller.asksMap.entries
            .map((e) => OBLevelKChartFuture(price: e.key, qty: e.value))
            .toList()
          ..sort((a, b) => a.price.compareTo(b.price));

        final topBids = bids.take(50).toList();
        final topAsks = asks.take(50).toList();

        /// -------- LIVE PRICE STREAM --------
        return StreamBuilder<dynamic>(
          stream: controller.priceStreamController!.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const SizedBox();
            }

            try {
              final data = snapshot.data as Map<String, dynamic>;

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

            return KChartOrderBookFuture(
              bids: topBids,
              asks: topAsks,
              livePrice: controller.lastPrice.toString(),
              markPrice: controller.markPrice.toString(),
              rows: 40,
              type: "spot",
              side: controller.orderTypeController.text,
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



  /// ================= ORDERBOOK PARSER =================
  void _parseOrderBook(String message) {
    try {
      final Map<String, dynamic> parsed =
      jsonDecode(message) as Map<String, dynamic>;

      final data = parsed['data'];
      if (data is! Map) return;

      if(data['s'] != controller.coinOne+controller.coinTwo) return;

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
