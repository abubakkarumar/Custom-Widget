import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:k_chart_plus/k_chart_widget.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_depth_chart_webview.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';

import '../../../Utility/Colors/custom_theme_change.dart';
import '../../../Utility/custom_text.dart';
import '../../../l10n/app_localizations.dart';
import 'live_price_row.dart';
import 'order_book_on_chart_page.dart';

class KChartPage extends StatefulWidget {
  const KChartPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<KChartPage> createState() => _KChartPageState();
}

class _KChartPageState extends State<KChartPage> {
  SpotTradeController controller = SpotTradeController();
  @override
  void initState() {
    Future.delayed(Duration.zero).whenComplete(() {
      controller.changeChartColor(context, false);
      controller.setupChartStyle();
      controller.chartInit();
    });

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // controller.closeTimer();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return  Consumer<SpotTradeController>(
        builder: (context, value, child) {
          controller = value;
          return ListView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom+10),
            shrinkWrap: true,
            physics: ScrollPhysics(),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.sp),
                child: Row(
                  children: [
                    SizedBox(
                      width: 65.w,
                      child: LivePriceRow(
                        livePrice: controller.selectedLiquiditySymbol.toLowerCase() == "normal" ? controller.selectedLivePrice.toString() : controller.storedLivePrice,
                        secondaryPrice: "",
                        fontSize: 25.px,
                        type: "all",
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          _infoColumn(
                            context,
                          AppLocalizations.of(context)!.twentyFourHigh,
                            controller.selectedLiquiditySymbol.toString().toLowerCase() ==
                                "normal"
                                ? controller.highPrice24hInternal
                                : controller.highPrice24h,
                          ),
                          SizedBox(width: 15.sp),
                          _infoColumn(
                            context,
                            AppLocalizations.of(context)!.twentyFourLow,
                            controller.selectedLiquiditySymbol.toString().toLowerCase() ==
                                "normal"
                                ? controller.lowPrice24hInternal
                                : controller.lowPrice24h,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              buildChartToolbar(), // 🔥 this is the toolbar
              SizedBox(height: 10.sp,),
              Stack(children: <Widget>[
                Column(
                  children: [
                    controller.isDepthChartEnabled ?
                    SizedBox(
                      height: 60.h,
                      width: double.infinity,
                      // color: Colors.white,
                      child: Stack(
                        children: [
                          ClipRect(
                              child:
                              SpotDepthChartView(pair: "${controller.selectedCoinOne}_${controller.selectedCoinTwo}",)
                          ),
                        ],
                      ),
                    )

                        :
                    Stack(
                      // alignment: Alignment.center,
                      children: [
                        KChartWidget(
                          controller.datas,
                          controller.chartStyle,
                          controller.chartColors,
                          mBaseHeight: 250,
                          fixedLength: 1,
                          isTrendLine: false,
                          mainStateLi: controller.mainStateLi.toSet(),
                          volHidden: controller.volHidden,
                          secondaryStateLi: controller.secondaryStateLi.toSet(),
                          timeFormat: TimeFormat.YEAR_MONTH_DAY,
                        ),

                        Align(
                          alignment: Alignment.topRight,
                          child: Opacity(
                            opacity: 0.3,
                            child: Padding(
                              padding: EdgeInsets.only(top:10.sp, right: 10.sp),
                              child: SvgPicture.asset(
                                height: 3.h, AppBasicIcons.logo,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if(controller.isDepthChartEnabled == false)
                      Column(children: [
                        Divider(color: ThemeSurfaceContainerLowColor.getSurfaceContainerLowColor(context),
                        thickness: 0.5,),
                        Center(child: buildUnifiedControlButtons()),
                        Divider(color: ThemeSurfaceContainerLowColor.getSurfaceContainerLowColor(context),
                          thickness: 0.5,),
                      ],),

                    Column(
                      children: [
                        SizedBox(height: 50.h,width:90.w,child: ChartOrderBook(controller: controller,)),
                      ],
                    )
                  ],
                ),
              ]),
            ],
          );
        }
    );
  }

  Widget _infoColumn(BuildContext context, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          label: title,
          fontColour: ThemeTextOneColor.getTextOneColor(context),
          labelFontWeight: FontWeight.w400,
          fontSize: 13.sp,
        ),
        CustomText(label: value, labelFontWeight: FontWeight.bold, fontSize: 13.sp,),
      ],
    );
  }

  Widget buildChartToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Row(
            children: [
              CustomToolbarText(AppLocalizations.of(context)!.time,),
              SizedBox(width: 10),
              ...['5m','15m', '1h', '4h', '1D'].map((label) => GestureDetector(
                onTap:(){
                  controller.changeInterval(label, context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CustomToolbarText(label, isActive: label == controller.selectedTime),
                ),
              )),

              SizedBox(width: 10),
              InkWell(
                onTap: (){
                  controller.setDepthChart(!controller.isDepthChartEnabled,);
                  // controller.setChartEnabled(
                  //   !controller.isDepthChartEnabled,
                  //   'depth',
                  // );
                },
                child: CustomToolbarText(AppLocalizations.of(context)!.depth,
                isActive: controller.isDepthChartEnabled,
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
  Widget CustomToolbarText(String label, {bool isActive = false}) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: isActive ? ThemeTextColor.getTextColor(context) : ThemeTextOneColor.getTextOneColor(context)
      ),
    );
  }

  Widget buildVolButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: buildButton(
            context: context,
            title: 'VOL',
            isActive: !controller.volHidden,
            onPress: () {
              controller.volHidden = !controller.volHidden;
              setState(() {});
            }),
      ),
    );
  }

  Widget buildMainButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10,
        runSpacing: 10,
        children: MainState.values.map((e) {
          bool isActive = controller.mainStateLi.contains(e);
          return buildButton(
            context: context,
            title: e.name,
            isActive: isActive,
            onPress: () {
              if (isActive) {
                controller.mainStateLi.remove(e);
              } else {
                controller.mainStateLi.add(e);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget buildSecondButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10,
        runSpacing: 5,
        children: SecondaryState.values.map((e) {
          bool isActive = controller.secondaryStateLi.contains(e);
          return buildButton(
            context: context,
            title: e.name,
            isActive: controller.secondaryStateLi.contains(e),
            onPress: () {
              if (isActive) {
                controller.secondaryStateLi.remove(e);
              } else {
                controller.secondaryStateLi.add(e);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget buildButton({
    required BuildContext context,
    required String title,
    required isActive,
    required Function onPress,
  }) {
    late Color? bgColor, txtColor;
    if (isActive) {
      bgColor = Theme.of(context).primaryColor.withOpacity(.15);
      txtColor = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;
    } else {
      bgColor = Colors.transparent;
      txtColor = Theme.of(context).brightness == Brightness.light ?
      Colors.grey.withOpacity(.75) : Colors.grey.withOpacity(.75);
    }
    return InkWell(
      onTap: () {
        onPress();
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: txtColor,
              fontWeight: FontWeight.bold,
            fontSize: 14.sp
          ),
          textAlign: TextAlign.center,

        ),
      ),
    );
  }

  Widget buildUnifiedControlButtons() {
    List<Widget> buttons = [];

    // VOL Button
    buttons.add(
      buildButton(
        context: context,
        title: 'VOL',
        isActive: !controller.volHidden,
        onPress: () {
          controller.volHidden = !controller.volHidden;
          setState(() {});
        },
      ),
    );

    // Main State Buttons
    // for (var e in MainState.values) {
    //   buttons.add(
    //     buildButton(
    //       context: context,
    //       title: e.name,
    //       isActive: controller.mainStateLi.contains(e),
    //       onPress: () {
    //         controller.mainStateLi.contains(e);
    //         setState(() {});
    //       },
    //     ),
    //   );
    // }

    // Main State Buttons
    for (var e in MainState.values) {
      bool isActive = controller.mainStateLi.contains(e);

      buttons.add(
        buildButton(
          context: context,
          title: e.name,
          isActive: isActive,
          onPress: () {
            if (isActive) {
              controller.mainStateLi.remove(e);
            } else {
              controller.mainStateLi.add(e);
            }
            setState(() {});
          },
        ),
      );
    }

    // Secondary State Buttons
    for (var e in SecondaryState.values) {
      bool isActive = controller.secondaryStateLi.contains(e);
      buttons.add(
        buildButton(
          context: context,
          title: e.name,
          isActive: isActive,
          onPress: () {
            if (isActive) {
              controller.secondaryStateLi.remove(e);
            } else {
              controller.secondaryStateLi.add(e);
            }
            setState(() {});
          },
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      height: 20.sp, // adjust as needed
      padding: EdgeInsets.symmetric(vertical: 8.sp),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: buttons,
      ),
    );
  }
}