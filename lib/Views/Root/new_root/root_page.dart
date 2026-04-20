import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/Views/Basic_Modules/notification/notification_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Affiliate/affiliate_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Dashboard/dashboard_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/History/history_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Market/market_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Saving/savings_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/wallet_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/future_trade_view.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_page.dart';
import 'package:zayroexchange/Views/Root/Side_menu.dart';
import 'package:zayroexchange/Views/Root/root_controller.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/referral_view.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

import 'show_trade_menu.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin {
  late RootController rootController;
  late SpotTradeController spotTradeController;
  late final List<Widget?> _pages;
  late final Map<int, Key> _pageKeys;
  int? _lastPageIndex;

  bool state = false;
  void toggle() {
    setState(() {
      state = !state;
    });
  }

  double get turns => state ? 1 : 0;

  @override
  void initState() {
    super.initState();
    _pages = List<Widget?>.filled(9, null);
    _pages[0] = const DashboardView();
    _pageKeys = Map<int, Key>.fromEntries(
      List.generate(9, (i) => MapEntry(i, ValueKey('page-$i'))),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<RootController>();
      controller.changeTabIndex(0);
      controller.loadInitData();
      controller.setRotateRepeatVertical(false);
      controller.notificationCount(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RootController, SpotTradeController>(
      builder: (context, controller, sController, _) {
        rootController = controller;
        spotTradeController = sController;
        final currentIndex = controller.currentPageIndex;
        if (_lastPageIndex != currentIndex) {
          if (currentIndex == 8) {
            // Recreate SavingsView only when opening it.
            _pageKeys[8] = UniqueKey();
            _pages[8] = null;
          }
          _lastPageIndex = currentIndex;
        }
        _ensurePage(controller.currentPageIndex);
        return PopScope(
          canPop: false,
          child: Scaffold(
            key: controller.scaffoldKey,
            backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
            extendBodyBehindAppBar: true,
            endDrawer: SideMenuView(),

            /// ★ Custom Dynamic AppBar Here
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(6.5.h),
              child: _buildDynamicAppBar(context),
            ),

            body: Stack(
              alignment: Alignment.center,
              children: [
                // Container(
                //   color: ThemeBackgroundColor.getBackgroundColor(context),
                // ),

                AbsorbPointer(
                  absorbing: controller.isLoading,
                  child: Opacity(
                    opacity: controller.isLoading ? 0.4 : 1,
                    child: Column(
                      children: [
                        Expanded(
                          child: IndexedStack(
                            index: controller.currentPageIndex,
                            children: List.generate(
                              _pages.length,
                              (index) =>
                                  _pages[index] ?? const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            extendBody: true,
            bottomNavigationBar: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [

                /// 🔥 Background + Border
                CustomPaint(
                  painter: BottomNavBorderPainter(
                    borderColor: ThemeOutLineColor.getOutLineColor(context),
                    backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
                  ),
                  child: SizedBox(
                    height: 12.h,
                    child: ClipPath(
                      clipper: BottomNavClipper(),
                      child: Container(
                        padding: EdgeInsets.only(bottom:MediaQuery.of(context).padding.bottom,left: 15.sp,right: 15.sp),
                        color: ThemeBackgroundColor.getBackgroundColor(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _navItem(
                              context: context,
                              index: 0,
                              currentIndex: controller.currentPageIndex,
                              onTap: () => controller.changeTabIndex(0),
                              activeIcon: controller.activeIcons[0],
                              inactiveIcon:
                              controller.getInactiveIcons(context)[0],
                            ),

                            _navItem(
                              context: context,
                              index: 1,
                              currentIndex: controller.currentPageIndex,
                              onTap: () => controller.changeTabIndex(1),
                              activeIcon: controller.activeIcons[1],
                              inactiveIcon:
                              controller.getInactiveIcons(context)[1],
                            ),

                            SizedBox(width: 60), // space for center

                            _navItem(
                              context: context,
                              index: 3,
                              currentIndex: controller.currentPageIndex,
                              onTap: () => controller.changeTabIndex(3),
                              activeIcon: controller.activeIcons[3],
                              inactiveIcon:
                              controller.getInactiveIcons(context)[3],
                            ),

                            _navItem(
                              context: context,
                              index: 4,
                              currentIndex: controller.currentPageIndex,
                              onTap: () => controller.changeTabIndex(4),
                              activeIcon: controller.activeIcons[4],
                              inactiveIcon:
                              controller.getInactiveIcons(context)[4],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                /// 🔥 CENTER TRADE BUTTON (UNCHANGED FUNCTION)
                Positioned(
                  top: 8,
                  child: _centerTradeButton(context),
                ),
              ],
            ),


          ),
        );
      },
    );
  }

  void _ensurePage(int index) {
    _pages[index] ??= _buildPage(index);
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const DashboardView();
      case 1:
        return const MarketView();
      case 2:
        return SpotTradePage(
          type: "root",
          isFromArena: false,
          isNew: rootController.isNewSpot,
        );
      case 3:
        return const WalletView();
      case 4:
        return const HistoryView();
      case 5:
        return FutureTradeView();
      case 6:
        return ReferralView(isSelectedFrom: false);
      case 7:
        return AffiliateView(isSelectedFrom: false);
      case 8:
        return SavingsView(key: _pageKeys[8]);
      default:
        return const DashboardView();
    }
  }

  /// PLACEHOLDER IMAGE (SAFE)
  Widget profilePlaceHolder(BuildContext context) {
    if (rootController.profilePictureFile != null) {
      return Image.file(
        File(rootController.profilePictureFile!.path),
        fit: BoxFit.cover,
      );
    }

    return Center(
      child: Image.asset(
        AppBasicIcons.profile,
        width: 30.sp,
        height: 30.sp,
        fit: BoxFit.contain,
      ),
    );
  }

  /// NETWORK IMAGE WITH FAILSAFE
  Widget profileImage(BuildContext context) {
    return ClipOval(
      child: Image.network(
        rootController.profileImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => profilePlaceHolder(context),
        loadingBuilder: (_, child, loading) {
          if (loading == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      ),
    );
  }

  /// ========================= AppBar Logic ===============================
  AppBar _buildDynamicAppBar(BuildContext context) {
    const double avatarSizePx = 50;
    bool isDashboard = rootController.tabIndex == 0;
    bool isTrade = rootController.tabIndex == 2;
    final titleColor = ThemeTextColor.getTextColor(context);

    return AppBar(
      backgroundColor: ThemeBackgroundColor.getBackgroundColor(context),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0, // <<< important
      surfaceTintColor: Colors.transparent, // <<< prevent color changes
      automaticallyImplyLeading: false,

      title: isDashboard
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: avatarSizePx,
                        height: avatarSizePx,
                        child: rootController.profileImageUrl.isNotEmpty == true
                            ? profileImage(context)
                            : profilePlaceHolder(context),
                      ),
                    ),
                    SizedBox(width: 12.sp),
                    CustomText(
                      label:
                          "${AppLocalizations.of(context)!.hello} " +
                          AppStorage.getUserName(),
                      fontSize: 17.sp,
                      labelFontWeight: FontWeight.w600,
                      fontColour: titleColor,
                    ),
                  ],
                ),
                 GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationView(),
                      ),
                    ).then((value) {
                      rootController.notificationCount(context);
                    });
                  },
                  child: SvgPicture.asset(
                    rootController.notificationCountValue == 0
                        ? AppThemeIcons.notificationWithoutDot(context)
                        : AppThemeIcons.notification(context),
                    width: 22.sp,
                    height: rootController.notificationCountValue == 0
                        ? 19.sp
                        : 24.5.sp,
                  ),
                ),
              ],
            )
          : isTrade
          ? CustomText(
              label:
                  "${spotTradeController.selectedCoinOne} / ${spotTradeController.selectedCoinTwo}",
              fontSize: 18.sp,
              labelFontWeight: FontWeight.w700,
              fontColour: titleColor,
            )
          : CustomText(
              label: rootController.screenNames(
                context,
              )[rootController.tabIndex],
              fontSize: 18.sp,
              labelFontWeight: FontWeight.w600,
              fontColour: titleColor,
            ),

      actions: isDashboard
          ? [ IconButton(
        icon: Icon(Icons.menu, size: 22.sp, color: titleColor),
        onPressed: () =>
            rootController.scaffoldKey.currentState?.openEndDrawer(),
      ),]
          : [
              IconButton(
                icon: Icon(Icons.menu, size: 22.sp, color: titleColor),
                onPressed: () =>
                    rootController.scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
    );
  }

  Widget _navItem({
    required BuildContext context,
    required int index,
    required VoidCallback onTap,
    required Widget activeIcon,
    required Widget inactiveIcon,
    required int currentIndex,
  }) {
    final isActive = currentIndex == index;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isActive ? 10.sp : 5.sp),
        decoration: isActive
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeInversePrimaryColor.getInversePrimaryColor(context),
                    ThemeButtonColor.getButtonColor(context),
                  ],
                ),
                borderRadius: BorderRadius.circular(15.sp),
              )
            : BoxDecoration(
                borderRadius: BorderRadius.circular(12.sp),
                color: ThemeBackgroundColor.getBackgroundColor(
                  context,
                ).withOpacity(0.18),
              ),
        child: isActive
            ? SizedBox(height: 20.sp, width: 20.sp, child: activeIcon)
            : SizedBox(height: 25.sp, width: 25.sp, child: inactiveIcon),
      ),
    );
  }

  Widget _centerTradeButton(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -25),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (rootController.isTradeMenuOpen) {
            toggle();
            showTradeMenu(context).then((_) => toggle());
          } else {
            rootController.handleTradeClick(true);
            spotTradeController.clearSelectedPair();
            rootController.setCenterPage(2,"new");
          }
        },
        child: AnimatedRotation(
          turns: turns,
          duration: const Duration(milliseconds: 300),
          curve: Curves.decelerate,
          child: AnimatedContainer(
            width: 56,
            height: 56,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(vertical: 13.sp, horizontal: 8.sp),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.sp),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeInversePrimaryColor.getInversePrimaryColor(context),
                  ThemeButtonColor.getButtonColor(context),
                ],
              ),
            ),
            child: AnimatedRotation(
              turns: rootController.isRepeatVertical ? 0.25 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _getCenterIcon(rootController.selectedCenterIndex),
                size: 26,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCenterIcon(int index) {
    switch (index) {
      case 2:
        return Icons.repeat;
      case 3:
        return Icons.calendar_today_outlined;
      case 4:
        return Icons.repeat;
      default:
        return Icons.repeat;
    }
  }
}

class BottomNavBorderPainter extends CustomPainter {
  final Color borderColor;
  final Color backgroundColor;

  BottomNavBorderPainter({
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = buildBottomNavPath(size);

    /// 🔥 1️⃣ Fill Background
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(path, fillPaint);

    /// 🔥 2️⃣ Draw ONLY Top Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..isAntiAlias = true;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant BottomNavBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}


class BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return buildBottomNavPath(size);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


Path buildBottomNavPath(Size size) {
  final path = Path();

  double notchRadius = 40;
  double notchDepth = 35;
  double center = size.width / 2;

  path.moveTo(0, 0);

  // Left straight
  path.lineTo(center - notchRadius - 20, 0);

  // Left curve down
  path.quadraticBezierTo(
    center - notchRadius,
    0,
    center - notchRadius + 10,
    notchDepth,
  );

  // Center arc
  path.arcToPoint(
    Offset(center + notchRadius - 10, notchDepth),
    radius: Radius.circular(notchRadius),
    clockwise: false,
  );

  // Right curve up
  path.quadraticBezierTo(
    center + notchRadius,
    0,
    center + notchRadius + 20,
    0,
  );

  // Right straight
  path.lineTo(size.width, 0);

  // Close bottom
  path.lineTo(size.width, size.height);
  path.lineTo(0, size.height);
  path.close();

  return path;
}
