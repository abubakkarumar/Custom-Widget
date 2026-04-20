import 'package:provider/provider.dart';
import 'package:zayroexchange/Views/Basic_Modules/email_verfication/email_verification_controller.dart';
import 'package:zayroexchange/Views/Basic_Modules/forgot_password/forgot_password_controller.dart';
import 'package:zayroexchange/Views/Basic_Modules/login/login_controller.dart';
import 'package:zayroexchange/Views/Basic_Modules/login/mpin_login/mpin_login_controller.dart';
import 'package:zayroexchange/Views/Basic_Modules/notification/notification_controller.dart';
import 'package:zayroexchange/Views/Basic_Modules/register/register_controller.dart';
import 'package:zayroexchange/Views/Basic_Modules/segmentedToggle/login_register_controller.dart';
import 'package:zayroexchange/Views/Basic_Modules/two_fa/twofa_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Affiliate/affiliate_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Dashboard/dashboard_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/History/history_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Market/market_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Saving/savings_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/deposit/deposit_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/wallet_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/Wallet/withdraw/withdraw_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/future_trade/future_trade_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/future_trade/transfer/transfer_controller.dart';
import 'package:zayroexchange/Views/Bottom_Pages/trade/spot_trade_controller.dart';
import 'package:zayroexchange/Views/Root/root_controller.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Kyc/kyc_controller.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Profile/profile_controller.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Referral/referral_controller.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Security/security_controller.dart';
import 'package:zayroexchange/Views/Side_Menu_Pages/Support/support_controller.dart';
import 'package:zayroexchange/material_theme/theme_controller.dart';

final basicProviders = [
  ChangeNotifierProvider<RegisterController>(
    create: (context) => RegisterController(),
  ),
  ChangeNotifierProvider<LoginController>(
    create: (context) => LoginController(),
  ),
  ChangeNotifierProvider<TwoFAController>(
    create: (context) => TwoFAController(),
  ),
  ChangeNotifierProvider<ThemeController>(create: (_) => ThemeController()),

  ChangeNotifierProvider<EmailVerificationController>(
    create: (_) => EmailVerificationController(),
  ),

  ChangeNotifierProvider<SegmentedToggleController>(
    create: (_) => SegmentedToggleController(),
  ),

  ChangeNotifierProvider<ForgotPasswordController>(
    create: (_) => ForgotPasswordController(),
  ),

  ChangeNotifierProvider<RootController>(create: (_) => RootController()),

  ChangeNotifierProvider<ProfileController>(create: (_) => ProfileController()),

  ChangeNotifierProvider<SecurityController>(
    create: (_) => SecurityController(),
  ),

  ChangeNotifierProvider<SupportController>(create: (_) => SupportController()),

  ChangeNotifierProvider<MPINLoginController>(
    create: (_) => MPINLoginController(),
  ),
  ChangeNotifierProvider<DashboardController>(
    create: (_) => DashboardController(),
  ),

  ChangeNotifierProvider<ReferralController>(
    create: (_) => ReferralController(),
  ),
  ChangeNotifierProvider<KycController>(create: (_) => KycController()),
];

final walletProviders = [
  ChangeNotifierProvider<WalletController>(
    create: (context) => WalletController(),
  ),
  ChangeNotifierProvider<DepositController>(
    create: (context) => DepositController(),
  ),
  ChangeNotifierProvider<WithdrawController>(
    create: (context) => WithdrawController(),
  ),
  ChangeNotifierProvider<HistoryController>(
    create: (context) => HistoryController(),
  ),
];

final spotProviders = [
  ChangeNotifierProvider<MarketController>(create: (_) => MarketController()),
  ChangeNotifierProvider<FutureTradeController>(
    create: (_) => FutureTradeController(),
  ),
  ChangeNotifierProvider<SpotTradeController>(
    create: (context) => SpotTradeController(),
  ),
  ChangeNotifierProvider<TransferController>(
    create: (context) => TransferController(),
  ),
  ChangeNotifierProvider<AffiliateController>(
    create: (context) => AffiliateController(),
  ),
  ChangeNotifierProvider<SavingsController>(
    create: (context) => SavingsController(),
  ),
  ChangeNotifierProvider<NotificationController>(
    create: (context) => NotificationController(),
  ),
];
