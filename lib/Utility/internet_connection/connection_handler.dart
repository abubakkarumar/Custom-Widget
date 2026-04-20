// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'dart:async';

class ConnectivityGate extends StatefulWidget {
  final Widget child;
  final SystemUiOverlayStyle overlayStyle;
  final Widget offlineOverlay;

  const ConnectivityGate({
    super.key,
    required this.child,
    required this.overlayStyle,
    required this.offlineOverlay,
  });

  @override
  State<ConnectivityGate> createState() => _ConnectivityGateState();
}

class _ConnectivityGateState extends State<ConnectivityGate> {
  bool _initialized = false; // we have received at least one value
  bool _isOnline = true; // current connectivity
  bool _wasOnline = true; // to detect transitions
  Timer?
  _initializationTimer; // timer to avoid showing offline overlay on app start

  void _onCameOnline() {
    print("back to online");
  }

  @override
  void dispose() {
    _initializationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InternetConnectivityBuilder(
      child: widget.child,
      connectivityBuilder: (context, hasInternet, appChild) {
        if (!_initialized) {
          if (hasInternet == true) {
            // Good connection on first read: initialize immediately.
            _initializationTimer?.cancel();
            _initialized = true;
            _isOnline = true;
          } else {
            _initializationTimer ??= Timer(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _initialized = true;
                  _isOnline = false;
                });
              }
            });
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: widget.overlayStyle,
              child: Stack(children: [appChild!]),
            );
          }
        } else {
          _isOnline = hasInternet == true;
        }
        if (_isOnline && !_wasOnline) {
          _onCameOnline();
        }
        _wasOnline = _isOnline;
        final showOfflineBanner = _initialized && !_isOnline;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: widget.overlayStyle,
          child: Stack(
            children: [
              appChild!,
              if (showOfflineBanner == true) widget.offlineOverlay,
            ],
          ),
        );
      },
    );
  }
}
