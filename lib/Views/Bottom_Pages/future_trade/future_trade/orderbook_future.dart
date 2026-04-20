// order_book.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Utility/number_formator.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/future_trade_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/live_price_row_future.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import '../../../../Utility/Colors/custom_theme_change.dart';
import '../../../../Utility/Images/custom_theme_change.dart';
import '../../../../Utility/Images/dark_image.dart';


/// ==============================
/// ORDER BOOK MODELS
/// ==============================

class OBLevel {
  final double price;
  final double qty;

  const OBLevel({required this.price, required this.qty});
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
    this.bidBar = const Color(0x4026A69A),
    this.askBar = const Color(0x40EF5350),
    this.spreadText = const Color(0xFF9AA4B2),
  });
}

/// ==============================
/// ORDER BOOK MAIN WIDGET
/// ==============================

class OrderBookFuture extends StatelessWidget {
  final List<OBLevel> bids;
  final List<OBLevel> asks;
  final int rows;
  final bool cumulative;
  final int priceDigits;
  final int qtyDigits;
  final void Function(String side, OBLevel level, int index)? onSelect;
  final OrderBookTheme theme;
  final String livePrice;
  final String markPrice;
  final String type;
  final String side;
  final double remainHeight;
  final double spreadPercent;

  const OrderBookFuture({
    super.key,
    required this.bids,
    required this.asks,
    required this.livePrice,
    required this.markPrice,
    required this.type,
    required this.side,
    required this.remainHeight,
    required this.spreadPercent,
    this.rows = 12,
    this.cumulative = false,
    this.priceDigits = 2,
    this.qtyDigits = 4,
    this.onSelect,
    this.theme = const OrderBookTheme(),
  });

  List<OBLevel> _top(List<OBLevel> list) => list.take(rows).toList();

  List<OBLevel> _cumulate(List<OBLevel> levels) {
    double acc = 0;
    return levels.map((l) {
      acc += l.qty;
      return OBLevel(price: l.price, qty: acc);
    }).toList();
  }

  Color livePriceColor(BuildContext context) {
    final live = double.tryParse(livePrice.replaceAll(',', '')) ?? 0.0;

    final mark =
        double.tryParse(markPrice.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

    if (live > mark) return theme.bidText;
    if (live < mark) return theme.askText;
    return Theme.of(context).colorScheme.onPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final topBids = _top(bids);
    final topAsks = _top(asks);

    final cBids = cumulative ? _cumulate(topBids) : topBids;
    final cAsks = cumulative ? _cumulate(topAsks) : topAsks;

    final maxQty = [
      ...cBids.map((e) => e.qty),
      ...cAsks.map((e) => e.qty),
      1.0,
    ].reduce((a, b) => a > b ? a : b);

    return Consumer<FutureTradeController>(
      builder: (context, controller, _) {
        return Column(
          children: [
            /// ================= ASK SIDE =================
            if (controller.orderBookType == 0 || controller.orderBookType == 2)
              Expanded(
                child: _OrderBookSection(
                  side: 'ask',
                  levels: cAsks,
                  maxQty: maxQty,
                  theme: theme,
                  priceDigits: priceDigits,
                  qtyDigits: qtyDigits,
                  onSelect: onSelect,
                  type: type,
                  sideVal: side,
                  coinOne: controller.coinOne,
                  coinTwo: controller.coinTwo,
                  reverse: true,
                  headerShow: true,
                ),
              ),

            if (controller.orderBookType == 0) SizedBox(height: 10.sp),

            /// ================= LIVE PRICE =================
            LivePriceRowFuture(
              livePrice: livePrice,
              secondaryPrice: spreadPercent.toString(),
              fontSize: 15.px,
              type: "all",
            ),

            if (controller.orderBookType == 0) SizedBox(height: 10.sp),

            /// ================= BID SIDE =================
            if (controller.orderBookType == 0 || controller.orderBookType == 1)
              Expanded(
                child: _OrderBookSection(
                  side: 'bid',
                  levels: cBids,
                  maxQty: maxQty,
                  theme: theme,
                  priceDigits: priceDigits,
                  qtyDigits: qtyDigits,
                  onSelect: onSelect,
                  type: type,
                  sideVal: side,
                  coinOne: controller.coinOne,
                  coinTwo: controller.coinTwo,
                  headerShow: controller.orderBookType == 1 ? true : false,
                ),
              ),

            SizedBox(height: 15.sp),

            /// ================= BUY / SELL PERCENT =================
            _BuySellPercentRow(bids: cBids, asks: cAsks, theme: theme),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      selectOrderDepthBottomSheet(context);
                    },
                    child: Container(padding: EdgeInsets.only(top: 5.sp, bottom: 5.sp, left: 12.sp, right: 12.sp),
                      decoration: BoxDecoration(color: ThemeTextFormFillColor.getTextFormFillColor(context,), borderRadius: BorderRadius.all(Radius.circular(10.sp))),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                        CustomText(label: controller.quantityDepth.toString(), labelFontWeight: FontWeight.bold,fontSize: 14.5.sp,),
                        Icon(Icons.arrow_drop_down, color: ThemeTextColor.getTextColor(context), size: 18.sp,)
                      ],),),
                  ),
                ),

                GestureDetector(
                  onTap: () => controller.setSelectedOrderBookType(controller.orderBookType),
                  child: Container(
                    padding: EdgeInsets.all(10.sp),
                    child:

                    SvgPicture.asset(controller.orderBookType == 2 ? AppThemeIcons.valuesRed(context) : controller.orderBookType == 1 ? AppThemeIcons.valuesGreen(context) : AppThemeIcons.valuesRedGreen(context), height: 18.sp),
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }
  void selectOrderDepthBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
      ),
      builder: (_) {
        return Consumer<FutureTradeController>(
            builder: (context, value, child) {
              return SizedBox(
                height: 40.h,
                width: 100.w,
                child: Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            label: AppLocalizations.of(context)!.orderBookDepth,
                            labelFontWeight: FontWeight.bold,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: SvgPicture.asset(
                              AppBasicIcons.close,
                              height: 20.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.sp),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: value.quantityDepthList.length,
                          itemBuilder: (context, index) {
                            return
                              InkWell(
                                onTap: (){
                                  value.changeQuantityDepth(value.quantityDepthList[index]);
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(15.sp),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(label: value.quantityDepthList[index].toString()),
                                      if(value.quantityDepth == value.quantityDepthList[index])
                                        Icon(Icons.done, color: Theme.of(context).colorScheme.onPrimary,size: 14.sp,)
                                    ],
                                  ),
                                ),
                              );
                          })

                    ],
                  ),
                ),
              );
            }
        );
      },
    );
  }
}

/// ==============================
/// HEADER
/// ==============================

class _HeaderRow extends StatelessWidget {
  final String coinOne;
  final String coinTwo;

  const _HeaderRow({required this.coinOne, required this.coinTwo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.sp),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                label: AppLocalizations.of(context)!.price,
                fontSize: 13.px,
              ),
              CustomText(
                label: AppLocalizations.of(context)!.amount,
                fontSize: 13.px,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(label: "($coinTwo)", fontSize: 12.px),
              CustomText(label: "($coinOne)", fontSize: 12.px),
            ],
          ),
        ],
      ),
    );
  }
}

/// ==============================
/// ORDER BOOK SECTION
/// ==============================

class _OrderBookSection extends StatelessWidget {
  final String side;
  final List<OBLevel> levels;
  final double maxQty;
  final OrderBookTheme theme;
  final int priceDigits;
  final int qtyDigits;
  final void Function(String, OBLevel, int)? onSelect;
  final String type;
  final String sideVal;
  final String coinOne;
  final String coinTwo;
  final bool reverse;final bool headerShow;

  const _OrderBookSection({
    required this.side,
    required this.levels,
    required this.maxQty,
    required this.theme,
    required this.priceDigits,
    required this.qtyDigits,
    required this.onSelect,
    required this.type,
    required this.sideVal,
    required this.coinOne,
    required this.coinTwo,
    this.reverse = false,
    this.headerShow = true
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(headerShow)
        _HeaderRow(coinOne: coinOne, coinTwo: coinTwo),
        Expanded(
          child: ListView.builder(
            reverse: reverse,
            padding: EdgeInsets.zero,
            itemCount: levels.length,
            itemBuilder: (_, i) => _OrderRow(
              side: side,
              i: i,
              price: levels[i].price,
              qty: levels[i].qty,
              maxQty: maxQty,
              rowWidth: MediaQuery.of(context).size.width,
              priceDigits: priceDigits,
              qtyDigits: qtyDigits,
              textColor: side == 'bid' ? theme.bidText : theme.askText,
              qtyTextColor: theme.text,
              barColor: side == 'bid' ? theme.bidBar : theme.askBar,
              flashColor: side == 'bid'
                  ? const Color(0x3326A69A)
                  : const Color(0x33EF5350),
              onPress: onSelect,
              type: type,
              sideVal: sideVal,
            ),
          ),
        ),
      ],
    );
  }
}

/// ==============================
/// ORDER ROW
/// ==============================

class _OrderRow extends StatefulWidget {
  final String side;
  final int i;
  final double price;
  final double qty;
  final double maxQty;
  final double rowWidth;
  final int priceDigits;
  final int qtyDigits;
  final Color textColor;
  final Color qtyTextColor;
  final Color barColor;
  final Color flashColor;
  final String type;
  final String sideVal;
  final void Function(String, OBLevel, int)? onPress;

  const _OrderRow({
    required this.side,
    required this.i,
    required this.price,
    required this.qty,
    required this.maxQty,
    required this.rowWidth,
    required this.priceDigits,
    required this.qtyDigits,
    required this.textColor,
    required this.qtyTextColor,
    required this.barColor,
    required this.flashColor,
    required this.type,
    required this.sideVal,
    this.onPress,
  });

  @override
  State<_OrderRow> createState() => _OrderRowState();
}

class _OrderRowState extends State<_OrderRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashCtrl;
  late final Animation<double> _flashOpacity;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _flashOpacity = Tween(begin: 1.0, end: 0.0).animate(_flashCtrl);
  }

  @override
  void didUpdateWidget(covariant _OrderRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.qty != widget.qty) {
      _flashCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = (widget.qty / widget.maxQty) * widget.rowWidth;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Container(
        height: 20.sp,
        margin: EdgeInsets.only(top: 10.sp),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: width.clamp(0, widget.rowWidth),
              decoration: BoxDecoration(
                color: widget.barColor,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(4),
                ),
              ),
            ),
            FadeTransition(
              opacity: _flashOpacity,
              child: Container(color: widget.flashColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: CustomText(
                      label: numberFormatter(widget.price.toString()),
                      fontSize: 12.px,
                      fontColour: widget.textColor,
                    ),
                  ),
                  CustomText(
                    label: widget.qty.toStringAsFixed(widget.qtyDigits),
                    fontSize: 12.px,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap() {
    final controller = context.read<FutureTradeController>();

    controller.setBuySellTabIndex(widget.side == 'ask' ? 0 : 1);

    if (widget.sideVal.toLowerCase() == "limit") {
      controller.updatePriceTextForm(widget.price.toString());
    }
    controller.updateQuantityTextForm(widget.qty.toString());
    controller.getValueCost();
    // controller.getTotalAmount(amount: widget.qty.toString(), context: context);

    widget.onPress?.call(
      widget.side,
      OBLevel(price: widget.price, qty: widget.qty),
      widget.i,
    );
  }
}

/// ==============================
/// BUY / SELL PERCENT ROW
/// ==============================

class _BuySellPercentRow extends StatelessWidget {
  final List<OBLevel> bids;
  final List<OBLevel> asks;
  final OrderBookTheme theme;

  const _BuySellPercentRow({
    required this.bids,
    required this.asks,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final totalBid = bids.fold(0.0, (s, e) => s + e.qty);
    final totalAsk = asks.fold(0.0, (s, e) => s + e.qty);
    final total = totalBid + totalAsk;

    final buyPercent = total == 0 ? 0 : (totalBid / total) * 100;
    final sellPercent = total == 0 ? 0 : (totalAsk / total) * 100;

    return SizedBox(
      height: 20.sp,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            label: 'B ${buyPercent.toStringAsFixed(2)}%',
            fontColour: theme.bidText,
            labelFontWeight: FontWeight.w600,
          ),
          CustomText(
            label: 'S ${sellPercent.toStringAsFixed(2)}%',
            fontColour: theme.askText,
            labelFontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
