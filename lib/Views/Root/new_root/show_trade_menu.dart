import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';
import 'package:zayroexchange/Views/Root/root_controller.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

/// Shows the custom trade menu as a modal dialog
Future<void> showTradeMenu(BuildContext context) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Trade Menu',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SafeArea(child: TradeBottomSheet());
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class TradeBottomSheet extends StatefulWidget {
  const TradeBottomSheet({super.key});

  @override
  State<TradeBottomSheet> createState() => _TradeBottomSheetState();
}

class _TradeBottomSheetState extends State<TradeBottomSheet>
    with TickerProviderStateMixin {
  late final AnimationController _closeController;
  late final Animation<double> _closeAnim;
  late final AnimationController _menuController;
  late final Animation<Offset> _menuAnim;
  late final Animation<double> _rotationAnim;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _menuAnim = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _menuController, curve: Curves.easeOutCubic),
        );

    _closeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _closeAnim = CurvedAnimation(
      parent: _closeController,
      curve: Curves.easeOutCubic,
    );
    _rotationAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _closeController, curve: Curves.decelerate),
    );

    // Play menu first, then close button with slight delay for a staggered effect
    _menuController.forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) _closeController.forward();
    });
  }

  @override
  void dispose() {
    _closeController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  Future<void> _closeWithAnimation(BuildContext context) async {
    // reverse close button, then reverse menu, then pop
    await _closeController.reverse();
    await _menuController.reverse();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.55;
    const double kNotchDepth = 150;
    const double kCloseButtonRadius = 26;

    return Consumer2<RootController, SpotTradeController>(
      builder: (context, value,sController, child) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              /// MATERIAL IS REQUIRED
              Material(
                color: Colors.transparent,
                child: ClipPath(
                  clipper: BottomNotchClipper(),
                  child: SlideTransition(
                    position: _menuAnim,
                    child: Container(
                      width: 95.w,
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: ThemeBackgroundColor.getBackgroundColor(context),
                        border: Border.all(
                          color: ThemeOutLineColor.getOutLineColor(context),
                          width: 6.sp,
                        ),
                      ),
                      padding: EdgeInsets.all(15.sp),

                      // color: const Color(0xFF1C1C1E),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            menuItem(
                              AppThemeIcons.spotBottomIcons(context),
                              AppLocalizations.of(context)!.buySell,
                              () {
                                sController.clearSelectedPair();
                                value.handleTradeClick(true);
                                value.setCenterPage(2,'new');
                                _closeWithAnimation(context);
                                Navigator.pop(context);
                              },
                              context,
                              selected: value.currentPageIndex == 2,
                            ),
                            menuItem(
                              AppThemeIcons.perpetualBottomIcons(context),
                              AppLocalizations.of(context)!.perpetualTrade,
                              () {
                                value.setCenterPage(5,'yes');
                                _closeWithAnimation(context);
                                Navigator.pop(context);
                              },
                              context,
                              selected: value.currentPageIndex == 5,
                            ),
                            menuItem(
                              AppThemeIcons.referralBottomIcons(context),
                              AppLocalizations.of(context)!.referral,
                              () {
                                value.setCenterPage(6,'yes');
                                _closeWithAnimation(context);
                                Navigator.pop(context);
                              },
                              context,
                              selected: value.currentPageIndex == 6,
                            ),
                            menuItem(
                              AppThemeIcons.affiliateBottomIcons(context),
                              AppLocalizations.of(context)!.affiliate,
                              () {
                                value.setCenterPage(7,'yes');
                                _closeWithAnimation(context);
                                Navigator.pop(context);
                              },
                              context,
                              selected: value.currentPageIndex == 7,
                            ),
                            menuItem(
                              AppThemeIcons.savingBottomIcons(context),
                              AppLocalizations.of(context)!.saving,
                              () {
                                value.setCenterPage(8,'yes');
                                _closeWithAnimation(context);
                                Navigator.pop(context);
                              },
                              context,
                              selected: value.currentPageIndex == 8,
                            ),
                            const SizedBox(height: 12),
                            // Center(
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       Icon(
                            //         Icons.edit_outlined,
                            //         color: Colors.grey,
                            //         size: 14,
                            //       ),
                            //       SizedBox(width: 10.sp),
                            //       Text(
                            //         "Edit",
                            //         style: const TextStyle(color: Colors.grey),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// CLOSE BUTTON (OUTSIDE) — animated with rotation
              Positioned(
                bottom: kNotchDepth / 2 - kCloseButtonRadius,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_closeAnim, _rotationAnim]),
                  builder: (context, _) {
                    final double translateY = (1 - _closeAnim.value) * 40;
                    final double scale = 0.8 + 0.2 * _closeAnim.value;
                    return Transform.translate(
                      offset: Offset(0, translateY),
                      child: Transform.scale(
                        scale: scale,
                        child: AnimatedRotation(
                          turns: _rotationAnim.value,
                          curve: Curves.decelerate,
                          duration: const Duration(milliseconds: 300),
                          child: AnimatedContainer(
                            width: 50,
                            height: 50,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.sp),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  ThemeInversePrimaryColor.getInversePrimaryColor(
                                    context,
                                  ),
                                  ThemeButtonColor.getButtonColor(context),
                                ],
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () => _closeWithAnimation(context),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BottomNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 20;
    const double notchWidth = 95;
    const double notchDepth = 80;

    final double center = size.width / 2;

    final path = Path();

    // ─── TOP LEFT ───
    path.moveTo(radius, 0);
    path.quadraticBezierTo(0, 0, 0, radius);

    // left side
    path.lineTo(0, size.height - notchDepth - radius);

    // ─── BOTTOM LEFT RADIUS ───
    path.quadraticBezierTo(
      0,
      size.height - notchDepth,
      radius,
      size.height - notchDepth,
    );

    // left flat to notch
    path.lineTo(center - notchWidth / 2, size.height - notchDepth);

    // 🔥 notch curve
    path.quadraticBezierTo(
      center,
      size.height,
      center + notchWidth / 2,
      size.height - notchDepth,
    );

    // right flat
    path.lineTo(size.width - radius, size.height - notchDepth);

    // ─── BOTTOM RIGHT RADIUS ───
    path.quadraticBezierTo(
      size.width,
      size.height - notchDepth,
      size.width,
      size.height - notchDepth - radius,
    );

    // right side
    path.lineTo(size.width, radius);

    // ─── TOP RIGHT ───
    path.quadraticBezierTo(size.width, 0, size.width - radius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget menuItem(
  String svgPath,
  String title,
  VoidCallback onTap,
  BuildContext context, {
  bool selected = false,
}) {
  return ListTile(
    onTap: onTap,
    leading: SvgPicture.asset(
      svgPath,
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(
        ThemeTextColor.getTextColor(context),
        BlendMode.srcIn,
      ),
    ),
    title: CustomText(label: title, fontSize: 16),
    trailing: selected
        ? Icon(Icons.check, color: ThemeTextColor.getTextColor(context))
        : null,
  );
}
