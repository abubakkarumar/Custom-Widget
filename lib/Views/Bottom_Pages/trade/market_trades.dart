import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/number_formator.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class MarketTrades extends StatelessWidget {
  const MarketTrades({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SpotTradeController>(
      builder: (context, controller, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: controller.spotOrderBookStreamController != null
                  ? StreamBuilder(
                      stream: controller.spotOrderBookStreamController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          try {
                            final parsed =
                                jsonDecode(snapshot.data as String)
                                    as Map<String, dynamic>;
                            // Parse tradehistory
                            final tradeHistory =
                                parsed['book']?['tradehistory'] as List?;
                            if (tradeHistory != null) {
                              controller.marketTradesList.clear();
                              for (final trade in tradeHistory) {
                                if (trade is Map) {
                                  controller.marketTradesList.add(trade);
                                }
                              }
                            }
                          } catch (_) {
                            // ignore malformed frames
                          }
                        }
                        // Show marketTradesList
                        return Column(
                          children: [
                            // Header row with fixed widths for alignment
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 4,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: CustomText(
                                      label:
                                          "${AppLocalizations.of(context)!.price} (${controller.selectedCoinTwo})",
                                      // role: TextRole.bodyMedium,
                                      fontColour: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                      align: TextAlign.left,
                                      fontSize: 12.px,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: CustomText(
                                      label:
                                          "${AppLocalizations.of(context)!.amount} (${controller.selectedCoinOne})",
                                      // role: TextRole.bodyMedium,
                                      fontColour: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                      align: TextAlign.center,
                                      fontSize: 12.px,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: CustomText(
                                      label: AppLocalizations.of(
                                        context,
                                      )!.dateTime,
                                      // role: TextRole.bodyMedium,
                                      fontColour: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                      align: TextAlign.right,
                                      fontSize: 12.px,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: controller.marketTradesList.length,
                                itemBuilder: (context, index) {
                                  final trade =
                                      controller.marketTradesList[index];
                                  final double price =
                                      double.tryParse('${trade['p']}') ?? 0.0;
                                  final double volume =
                                      double.tryParse('${trade['v']}') ?? 0.0;
                                  final String side = (trade['S'] ?? '')
                                      .toString();
                                  final String ts = trade['ts'] ?? '';
                                  final DateTime time =
                                      DateTime.tryParse(ts)?.toLocal() ??
                                      DateTime.now();
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: CustomText(
                                            label:
                                                '${numberFormatter(price.toString())}',
                                            fontColour:
                                                side.toLowerCase() == 'buy'
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.tertiary
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                            fontSize: 12.px,
                                            align: TextAlign.left,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: CustomText(
                                            label: volume.toStringAsFixed(6),
                                            align: TextAlign.center,
                                            fontColour: Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                            fontSize: 12.px,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: CustomText(
                                            label:
                                                '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} '
                                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}',
                                            align: TextAlign.right,
                                            fontColour: Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                            fontSize: 12.px,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : const SizedBox(),
            ),
          ],
        );
      },
    );
  }
}
