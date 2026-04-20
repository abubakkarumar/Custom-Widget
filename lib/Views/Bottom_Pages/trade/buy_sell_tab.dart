import 'package:flutter/material.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../../../Utility/Colors/custom_theme_change.dart';

enum TradeType { buy, sell }

class TradeToggle extends StatefulWidget {
  final TradeType value;
  final ValueChanged<TradeType> onChanged;

  const TradeToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TradeToggle> createState() => _TradeToggleState();
}

class _TradeToggleState extends State<TradeToggle> {
  late TradeType selected;

  @override
  void initState() {
    super.initState();
    selected = widget.value;
  }

  void select(TradeType type) {
    if (type == selected) return;
    setState(() => selected = type);
    widget.onChanged(type);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(
          context,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [

          /// SLIDER (NO LAYOUT REBUILD)
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: selected == TradeType.buy
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: selected == TradeType.buy
                      ? const Color(0xff2EBD85)
                      : const Color(0xffF6465D),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),

          /// BUTTONS
          Row(
            children: [
              _item(AppLocalizations.of(context)!.buy, TradeType.buy),
              _item(AppLocalizations.of(context)!.sell, TradeType.sell),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(String text, TradeType type) {
    final isSelected = selected == type;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => select(type),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
