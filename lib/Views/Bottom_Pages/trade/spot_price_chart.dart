import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';

class SpotPriceChartView extends StatefulWidget {
  final String pair;
  const SpotPriceChartView({super.key, required this.pair});

  @override
  State<SpotPriceChartView> createState() => _SpotPriceChartViewState();
}

class _SpotPriceChartViewState extends State<SpotPriceChartView>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Consumer<SpotTradeController>(
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainer, // match dark trading UI

          body: InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri("${ApiEndpoints.SPOT_PRICE_CHART_URL}${widget.pair}"),

              headers: {
                // example: auth header if your chart is private
                // "Authorization": "Bearer YOUR_TOKEN",
              },
            ),
            initialSettings: InAppWebViewSettings(
              transparentBackground: true,
              supportZoom: true,
              javaScriptEnabled: true,
              preferredContentMode: UserPreferredContentMode.MOBILE,
              displayZoomControls: true,
              builtInZoomControls: true,
              networkAvailable: true,
              loadWithOverviewMode: true,
              useWideViewPort: true,
              enableViewportScale: true,
            ),
            gestureRecognizers: {
              Factory<HorizontalDragGestureRecognizer>(
                () => HorizontalDragGestureRecognizer(),
              ),
              Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
              ),
            },
            onWebViewCreated: (controller) {
              value.setPriceWebController(controller);
            },
            //     onLoadStop: (controller, url) async {
            //       // Example: inject JS to style chart dark mode or change symbol
            //       await controller.evaluateJavascript(source: """
            //   try {
            //     window.setPair && window.setPair('BTCUSDT');
            //     document.body.style.backgroundColor = '#393C4E';
            //   } catch(e) { }
            // """);
            //     },
            //     shouldOverrideUrlLoading: (controller, navAction) async {
            //       // Block unwanted redirects/popups
            //       final uri = navAction.request.url;
            //       if (uri != null && !uri.toString().contains("your-chart-page.app.com")) {
            //         return NavigationActionPolicy.CANCEL;
            //       }
            //       return NavigationActionPolicy.ALLOW;
            //     },
          ),
        );
      },
    );
  }
}
