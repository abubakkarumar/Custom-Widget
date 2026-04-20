import 'package:flutter/material.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'light_image.dart';

class ThemeIcon {
  static String get({
    required BuildContext context,
    required String light,
    required String dark,
  }) {
    final brightness = Theme.of(context).brightness;

    // Debug print
    // debugPrint("ThemeIcon.get → brightness: $brightness");

    return brightness == Brightness.light ? light : dark;
  }
}

class AppThemeIcons {
  // -------------------- Auth Icons --------------------

  static String noInternet(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppBasicIcons.lightNoInternet,
    dark: AppBasicIcons.darkNoInternet,
  );

  static String userName(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightImages.username,
    dark: AppDarkImages.username,
  );

  static String backArrow(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightImages.backArrow,
    dark: AppDarkImages.backArrow,
  );

  static String email(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightImages.emailIcon,
    dark: AppDarkImages.emailIcon,
  );

  static String password(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightImages.passwordIcon,
    dark: AppDarkImages.passwordIcon,
  );

  // -------------------- Bottom Navigation --------------------

  static String dashboardBottom(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppBottomIcons.dashboardLightInactive,
    dark: AppBottomIcons.dashboardInactive,
  );

  static String historyBottom(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppBottomIcons.historyLightInactive,
    dark: AppBottomIcons.historyInactive,
  );

  static String marketBottom(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppBottomIcons.marketLightInactive,
    dark: AppBottomIcons.marketInactive,
  );

  static String tradeBottom(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppBottomIcons.tradeLightInactive,
    dark: AppBottomIcons.tradeInactive,
  );

  static String walletBottom(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppBottomIcons.walletLightInactive,
    dark: AppBottomIcons.walletInactive,
  );
  ////Side Navigation Icons
  static String sideNav(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSideIcons.sideNav,
    dark: AppDarkSideIcons.sideNav,
  );

  static String sideMenuProfile(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSideIcons.profile,
    dark: AppDarkSideIcons.profile,
  );

  static String sideMenuSecurity(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSideIcons.security,
    dark: AppDarkSideIcons.security,
  );

  static String sideMenuReferral(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSideIcons.referral,
    dark: AppDarkSideIcons.referral,
  );
  static String sideMenuKycVerification(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSideIcons.kycVerification,
    dark: AppDarkSideIcons.kycVerification,
  );
  static String sideMenuSupport(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSideIcons.support,
    dark: AppDarkSideIcons.support,
  );
  static String sideMenuMPin(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSideIcons.mPin,
    dark: AppDarkSideIcons.mPin,
  );
  static String sideMenuFacialRecognition(BuildContext context) =>
      ThemeIcon.get(
        context: context,
        light: AppLightSideIcons.facialRecognition,
        dark: AppDarkSideIcons.facialRecognition,
      );

  static String sideMenuFingerprintAuthentication(BuildContext context) =>
      ThemeIcon.get(
        context: context,
        light: AppLightSideIcons.fingerprintAuthentication,
        dark: AppDarkSideIcons.fingerprintAuthentication,
      );

  static String sideMenuUserName(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSideIcons.userName,
    dark: AppDarkSideIcons.userName,
  );

  static String sideMenuEmail(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSideIcons.email,
    dark: AppDarkSideIcons.email,
  );
  static String sideMenuBio(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSideIcons.bio,
    dark: AppDarkSideIcons.bio,
  );
  static String sideMenuLanguage(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSideIcons.language,
    dark: AppDarkSideIcons.language,
  );

  static String getThemeSvg(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSideIcons.colourTheme,
    dark: AppDarkSideIcons.colourTheme,
  );

  static String sideMenuNotification(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSideIcons.notification,
    dark: AppDarkSideIcons.notification,
  );
  //////////////////////////////Security////////////////////////////////////////////////////
  static String securityGoogle(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSecurityIcons.googleAuthentication,
    dark: AppDarkSecurityIcons.googleAuthentication,
  );

  static String securityGoogleAuthAlert(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSecurityIcons.googleAuthAlert,
    dark: AppDarkSecurityIcons.googleAuthAlert,
  );
  static String securityEmail(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSecurityIcons.emailVerification,
    dark: AppDarkSecurityIcons.emailVerification,
  );

  static String securityKycVerification(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSecurityIcons.kycVerification,
    dark: AppDarkSecurityIcons.kycVerification,
  );

  static String securityAntiPhishing(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSecurityIcons.antiPhishing,
    dark: AppDarkSecurityIcons.antiPhishing,
  );

  static String securityRecovery(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSecurityIcons.recovery,
    dark: AppDarkSecurityIcons.recovery,
  );

  static String mPinVerified(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSecurityIcons.mPinVerified,
    dark: AppDarkSecurityIcons.mPinVerified,
  );

  static String mPinVerifiedCh(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSecurityIcons.mPinVerifiedCh,
    dark: AppDarkSecurityIcons.mPinVerifiedCh,
  );

  static String securityLoginPassword(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSecurityIcons.loginPassword,
    dark: AppDarkSecurityIcons.loginPassword,
  );

  static String securityFreezeAccount(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSecurityIcons.freezeAccount,
    dark: AppDarkSecurityIcons.freezeAccount,
  );

  static String securityAccountActivities(BuildContext context) =>
      ThemeIcon.get(
        context: context,
        light: AppLightSecurityIcons.accountActivities,
        dark: AppDarkSecurityIcons.accountActivities,
      );

  static String securityDeleteAccount(BuildContext context) => ThemeIcon.get(
    context: context,
    light: AppLightSecurityIcons.deleteAccount,
    dark: AppDarkSecurityIcons.deleteAccount,
  );

  static String affiliateBottomIcons(BuildContext context) => ThemeIcon.get(
    context: context,
    light: BottomSheetLightIcons.affiliateBottomLightIcons,
    dark: BottomSheetDarkIcons.affiliateBottomDarkIcons,
  );
  static String perpetualBottomIcons(BuildContext context) => ThemeIcon.get(
    context: context,
    light: BottomSheetLightIcons.perpetualBottomLightIcons,
    dark: BottomSheetDarkIcons.perpetualBottomDarkIcons,
  );
  static String referralBottomIcons(BuildContext context) => ThemeIcon.get(
    context: context,
    light: BottomSheetLightIcons.referralBottomLightIcons,
    dark: BottomSheetDarkIcons.referralBottomDarkIcons,
  );
  static String spotBottomIcons(BuildContext context) => ThemeIcon.get(
    context: context,
    light: BottomSheetLightIcons.spotBottomLightIcons,
    dark: BottomSheetDarkIcons.spotBottomDarkIcons,
  );
  static String savingBottomIcons(BuildContext context) => ThemeIcon.get(
    context: context,
    light: BottomSheetLightIcons.savingBottomLightIcons,
    dark: BottomSheetDarkIcons.savingBottomDarkIcons,
  );

  ////////////////////////////// Referral ////////////////////////////////////////////////////

  static String downlineReferral(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.downlineReferral,
    dark: ReferralDarkIcon.downlineReferral,
  );

  static String earningReferral(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.earningReferral,
    dark: ReferralDarkIcon.earningReferral,
  );

  static String earningTodayReferral(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.earningTodayReferral,
    dark: ReferralDarkIcon.earningTodayReferral,
  );
  static String sponsorReferral(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.sponsorReferral,
    dark: ReferralDarkIcon.sponsorReferral,
  );

  static String linkReferral(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.linkReferral,
    dark: ReferralDarkIcon.linkReferral,
  );

  static String telegramReferral(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.telegramReferral,
    dark: ReferralDarkIcon.telegramReferral,
  );

  static String whatsappReferral(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.whatsappReferral,
    dark: ReferralDarkIcon.whatsappReferral,
  );

  ////////////////////////////// BLUE ////////////////////////////////////////////////////
  static String referralBlueChest(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralBlueChest,
    dark: ReferralDarkIcon.referralBlueChest,
  );

  static String referralBlueOpen(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralBlueOpen,
    dark: ReferralDarkIcon.referralBlueOpen,
  );

  static String referralBlueGlow(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralBlueGlow,
    dark: ReferralDarkIcon.referralBlueGlow,
  );

  static String referralBlueKey(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralBlueKey,
    dark: ReferralDarkIcon.referralBlueKey,
  );

  static String referralBlueRobot(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralBlueRobot,
    dark: ReferralDarkIcon.referralBlueRobot,
  );

  static String referralBlueFrame(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralBlueFrame,
    dark: ReferralDarkIcon.referralBlueFrame,
  );

  ////////////////////////////// GOLD ////////////////////////////////////////////////////

  static String referralGoldChest(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralGoldChest,
    dark: ReferralDarkIcon.referralGoldChest,
  );

  static String referralGoldOpen(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralGoldOpen,
    dark: ReferralDarkIcon.referralGoldOpen,
  );

  static String referralGoldGlow(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralGoldGlow,
    dark: ReferralDarkIcon.referralGoldGlow,
  );

  static String referralGoldKey(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralGoldKey,
    dark: ReferralDarkIcon.referralGoldKey,
  );

  static String referralGoldRobot(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralGoldRobot,
    dark: ReferralDarkIcon.referralGoldRobot,
  );

  static String referralGoldFrame(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralGoldFrame,
    dark: ReferralDarkIcon.referralGoldFrame,
  );

  ////////////////////////////// RED ////////////////////////////////////////////////////

  static String referralRedChest(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralRedChest,
    dark: ReferralDarkIcon.referralRedChest,
  );

  static String referralRedOpen(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralRedOpen,
    dark: ReferralDarkIcon.referralRedOpen,
  );

  static String referralRedGlow(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralRedGlow,
    dark: ReferralDarkIcon.referralRedGlow,
  );

  static String referralRedKey(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralRedKey,
    dark: ReferralDarkIcon.referralRedKey,
  );

  static String referralRedFrame(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralRedFrame,
    dark: ReferralDarkIcon.referralRedFrame,
  );

  static String referralRedRobot(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralRedRobot,
    dark: ReferralDarkIcon.referralRedRobot,
  );

  ////////////////////////////// BLACK ////////////////////////////////////////////////////

  static String referralBlackCoin(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralBlackCoin,
    dark: ReferralDarkIcon.referralBlackCoin,
  );

  static String referralBlackFrame(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralBlackFrame,
    dark: ReferralDarkIcon.referralBlackFrame,
  );
  static String referralBlackRobot(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralBlackRobot,
    dark: ReferralDarkIcon.referralBlackRobot,
  );

  ////////////////////////////// COUNT ////////////////////////////////////////////////////

  static String referralKeyCount(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralKeyCount,
    dark: ReferralDarkIcon.referralKeyCount,
  );

  static String referralGoldCoin(BuildContext context) => ThemeIcon.get(
    context: context,
    light: ReferralLightIcon.referralGoldCoin,
    dark: ReferralDarkIcon.referralGoldCoin,
  );

  ////////////////////////////// Support ////////////////////////////////////////////////////

  static String chat(BuildContext context) => ThemeIcon.get(
    context: context,
    light: SupportLightIcon.chat,
    dark: SupportDarkIcon.chat,
  );

  static String createTicket(BuildContext context) => ThemeIcon.get(
    context: context,
    light: SupportDarkIcon.createTicket,
    dark: SupportLightIcon.createTicket,
  );
  static String filter(BuildContext context) => ThemeIcon.get(
    context: context,
    light: SupportLightIcon.filter,
    dark: SupportDarkIcon.filter,
  );
  static String chatProfile(BuildContext context) => ThemeIcon.get(
    context: context,
    light: SupportLightIcon.chatProfile,
    dark: SupportDarkIcon.chatProfile,
  );

  ////////////////////////////// Dashboard ////////////////////////////////////////////////////
  static String notification(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DashboardLightIcon.notification,
    dark: DashboardDarkIcon.notification,
  );

  static String notificationWithoutDot(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DashboardDarkIcon.notificationWithoutDot,
    dark: DashboardLightIcon.notificationWithoutDot,
  );

  static String dashboardContent(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DashboardLightIcon.dashboardContent,
    dark: DashboardDarkIcon.dashboardContent,
  );

  static String dashboardZhContent(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DashboardLightIcon.dashboardZhContent,
    dark: DashboardDarkIcon.dashboardZhContent,
  );
  static String dashboardDeposit(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DashboardLightIcon.dashboardDeposit,
    dark: DashboardDarkIcon.dashboardDeposit,
  );
  static String dashboardWithdraw(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DashboardLightIcon.dashboardWithdraw,
    dark: DashboardDarkIcon.dashboardWithdraw,
  );
  static String dashboardReferral(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DashboardLightIcon.dashboardReferral,
    dark: DashboardDarkIcon.dashboardReferral,
  );
  static String dashboardAffiliate(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DashboardLightIcon.dashboardAffiliate,
    dark: DashboardDarkIcon.dashboardAffiliate,
  );

  ////////////////////////////// Wallet ////////////////////////////////////////////////////

  static String walletOverviewContent(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DashboardLightIcon.walletOverviewContent,
    dark: DashboardDarkIcon.walletOverviewContent,
  );
  static String walletSearch(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DashboardLightIcon.walletSearch,
    dark: DashboardDarkIcon.walletSearch,
  );

  ////////////////////////////// Deposit ////////////////////////////////////////////////////

  static String arrowDown(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DepositDarkIcon.arrowDown,
    dark: DepositLightIcon.arrowDown,
  );
  static String copy(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DepositLightIcon.copy,
    dark: DepositDarkIcon.copy,
  );
  static String copyCode(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DepositLightIcon.copyCode,
    dark: DepositDarkIcon.copyCode,
  );
  static String downloadQrCode(BuildContext context) => ThemeIcon.get(
    context: context,
    light: DepositLightIcon.downloadQrCode,
    dark: DepositDarkIcon.downloadQrCode,
  );

  ////////////////////////////// Trade Module ////////////////////////////////////////////////////

  static String areaChartActive(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.areaChartActive,
    dark: TradeDarkIcon.areaChartActive,
  );
  static String areaChartInActive(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.areaChartInActive,
    dark: TradeDarkIcon.areaChartInActive,
  );
  static String candleChartActive(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.candleChartActive,
    dark: TradeDarkIcon.candleChartActive,
  );
  static String candleChartInActive(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.candleChartInActive,
    dark: TradeDarkIcon.candleChartInActive,
  );
  static String downRed(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.downRed,
    dark: TradeDarkIcon.downRed,
  );
  static String favActive(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.favActive,
    dark: TradeDarkIcon.favActive,
  );
  static String favInActive(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.favInActive,
    dark: TradeDarkIcon.favInActive,
  );
  static String greenUpDir(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.greenUpDir,
    dark: TradeDarkIcon.greenUpDir,
  );

  static String plusMiniBlue(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.plusMiniBlue,
    dark: TradeDarkIcon.plusMiniBlue,
  );
  static String valuesGreen(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.valuesGreen,
    dark: TradeDarkIcon.valuesGreen,
  );
  static String valuesRed(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.valuesRed,
    dark: TradeDarkIcon.valuesRed,
  );
  static String valuesRedGreen(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.valuesRedGreen,
    dark: TradeDarkIcon.valuesRedGreen,
  );
  static String buyActiveBg(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.buyActiveBg,
    dark: TradeDarkIcon.buyActiveBg,
  );
  static String buyInActiveBg(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.buyInActiveBg,
    dark: TradeDarkIcon.buyInActiveBg,
  );
  static String sellActiveBg(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.sellActiveBg,
    dark: TradeDarkIcon.sellActiveBg,
  );
  static String sellInActiveBg(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.sellInActiveBg,
    dark: TradeDarkIcon.sellInActiveBg,
  );

  static String tabLine(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.tabLine,
    dark: TradeDarkIcon.tabLine,
  );

  static String tradeDepthChat(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.depthChart,
    dark: TradeDarkIcon.depthChart,
  );

  static String tradePriceChat(BuildContext context) => ThemeIcon.get(
    context: context,
    light: TradeLightIcon.priceChart,
    dark: TradeDarkIcon.priceChart,
  );

  static String selectedSpotTradeDepthChart(BuildContext context) =>
      ThemeIcon.get(
        context: context,
        light: TradeLightIcon.selectedDepthChart,
        dark: TradeDarkIcon.selectedDepthChart,
      );

  static String selectedSpotTradePriceChart(BuildContext context) =>
      ThemeIcon.get(
        context: context,
        light: TradeLightIcon.selectedPriceChart,
        dark: TradeDarkIcon.selectedPriceChart,
      );

  ////////////////////////////// Rewards Hub ////////////////////////////////////////////////////

  static String rewardsContent(BuildContext context) => ThemeIcon.get(
    context: context,
    light: RewardsLightHub.rewardsContent,
    dark: RewardsDarkHub.rewardsContent,
  );
  static String rewardsZhContent(BuildContext context) => ThemeIcon.get(
    context: context,
    light: RewardsLightHub.rewardsZhContent,
    dark: RewardsDarkHub.rewardsZhContent,
  ); ////////////////////////////// Saving Hub ////////////////////////////////////////////////////

  static String savingContent(BuildContext context) => ThemeIcon.get(
    context: context,
    light: SavingLight.savingContent,
    dark: SavingDark.savingContent,
  );
  static String savingZhContent(BuildContext context) => ThemeIcon.get(
    context: context,
    light: SavingLight.savingZhContent,
    dark: SavingDark.savingZhContent,
  );
}
