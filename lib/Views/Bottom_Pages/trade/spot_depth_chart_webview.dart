import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import 'package:zayroexchange/Utility/Basics/api_endpoints.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';

import '../../../material_theme/theme_controller.dart';

class SpotDepthChartView extends StatefulWidget {
  final String pair;

  const SpotDepthChartView({super.key, required this.pair});

  @override
  State<SpotDepthChartView> createState() => _SpotDepthChartViewState();
}

class _SpotDepthChartViewState extends State<SpotDepthChartView> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<SpotTradeController,ThemeController>(
      builder: (context, controller, themeController, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,

          body: InAppWebView(
            /// ================= INITIAL URL =================
            initialUrlRequest: URLRequest(
              url: WebUri("${ApiEndpoints.SPOT_DEPTH_CHART_URL}${widget.pair}&mode=${themeController.themeMode == ThemeMode.system ? Theme.of(context).brightness == Brightness.dark ? "dark" : "light" : themeController.themeMode == ThemeMode.dark ? "dark" : "light"}"),
            ),

            /// ================= WEB SETTINGS =================
            initialSettings: InAppWebViewSettings(
              transparentBackground: true,
              javaScriptEnabled: true,
              supportZoom: true,
              builtInZoomControls: true,
              displayZoomControls: true,
              preferredContentMode: UserPreferredContentMode.MOBILE,
              networkAvailable: true,
              loadWithOverviewMode: true,
              useWideViewPort: true,
              enableViewportScale: true,
            ),

            /// ================= GESTURES =================
            gestureRecognizers: {
              Factory<HorizontalDragGestureRecognizer>(
                () => HorizontalDragGestureRecognizer(),
              ),
              Factory<VerticalDragGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
              ),
            },

            /// ================= WEBVIEW CREATED =================
            onWebViewCreated: (webController) {
              debugPrint(
                "Depth Chart URL → ${ApiEndpoints.SPOT_DEPTH_CHART_URL}${widget.pair}",
              );
              controller.setDepthWebController(webController);
            },
          ),
        );
      },
    );
  }
}
