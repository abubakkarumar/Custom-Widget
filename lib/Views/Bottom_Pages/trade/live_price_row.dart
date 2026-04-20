import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/number_formator.dart';

class LivePriceRow extends StatefulWidget {
  final String livePrice;
  final String secondaryPrice;
  // final OrderBookTheme theme;
  final double fontSize;
  final String type;

  const LivePriceRow({
    super.key,
    required this.livePrice,
    required this.secondaryPrice,
    // required this.theme,
    this.fontSize = 11,
    this.type = "all",
  });

  @override
  State<LivePriceRow> createState() => LivePriceRowState();
}

class LivePriceRowState extends State<LivePriceRow> {
  double? _previous;
  bool? _isUp; // true = green, false = red, null = neutral
  OrderBookTheme theme = const OrderBookTheme();

  double _parse(String v) {
    final cleaned = v.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    _previous = _parse(widget.livePrice);
  }

  @override
  void didUpdateWidget(covariant LivePriceRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.livePrice != widget.livePrice) {
      final current = _parse(widget.livePrice);

      if (_previous != null) {
        if (current > _previous!) {
          _isUp = true;
        } else if (current < _previous!) {
          _isUp = false;
        }
      }

      _previous = current;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Color liveColor;

    if (_isUp == null) {
      liveColor = theme.askText;
      // liveColor = ThemeTextColor.getTextColor(context);
    } else {
      liveColor = _isUp! ? theme.bidText : theme.askText;
    }

    IconData arrow = (_isUp ?? true)
        ? Icons.arrow_upward
        : Icons.arrow_downward;
    return widget.type == "all"
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomText(
                    label: numberFormatter(widget.livePrice, decimal: 1),
                    fontColour: liveColor,
                    fontSize: widget.fontSize.px,
                    labelFontWeight: FontWeight.bold,
                  ),
                  Icon(arrow, size: 13, color: liveColor),
                ],
              ),
              Expanded(
                child: CustomText(
                  label: widget.secondaryPrice.isNotEmpty ? "${widget.secondaryPrice}%" : "",
                      // "≈ \$${numberFormatter(widget.secondaryPrice.toString(), decimal: 1)}",
                  fontSize: widget.fontSize.px,
                  labelFontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  align: TextAlign.end,
                  fontColour: liveColor,
                ),
              ),
            ],
          )
        : CustomText(
            label: numberFormatter(widget.livePrice, decimal: 1),
            fontColour: liveColor,
            fontSize: 20.px,
            labelFontWeight: FontWeight.bold,
            align: TextAlign.start,
          );
  }
}

class OrderBookTheme {
  final Color bg;
  final Color text;
  final Color divider;
  final Color bidText;
  final Color askText;
  final Color bidBar;
  final Color askBar;
  final Color spreadText;

  const OrderBookTheme({
    this.bg = const Color(0xFF0B0F16),
    this.text = const Color(0xFFD1D4DC),
    this.divider = const Color(0xFF1F2940),
    this.bidText = const Color(0xFF26A69A),
    this.askText = const Color(0xFFEF5350),
    this.bidBar = const Color(0x4026A69A), // 25% alpha
    this.askBar = const Color(0x40EF5350),
    this.spreadText = const Color(0xFF9AA4B2),
  });
}
