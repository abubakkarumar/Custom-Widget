import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Your Logo'**
  String get appName;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// No description provided for @welcomeSubText.
  ///
  /// In en, this message translates to:
  /// **'Trade Smarter. Faster.\nSafer. With Us.'**
  String get welcomeSubText;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @registerLoginDetailsText.
  ///
  /// In en, this message translates to:
  /// **'Please enter the details to register'**
  String get registerLoginDetailsText;

  /// No description provided for @loginDetailsText.
  ///
  /// In en, this message translates to:
  /// **'Please enter the details to login'**
  String get loginDetailsText;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Email address is required.'**
  String get emailAddressRequired;

  /// No description provided for @emailAddressFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format.'**
  String get emailAddressFormat;

  /// No description provided for @emailAddressHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get emailAddressHintText;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHintText;

  /// No description provided for @newPasswordHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get newPasswordHintText;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get passwordRequired;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New Password is required.'**
  String get newPasswordRequired;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordLength;

  /// No description provided for @passwordIncludeUpperLetter.
  ///
  /// In en, this message translates to:
  /// **'Include 1 uppercase letter'**
  String get passwordIncludeUpperLetter;

  /// No description provided for @passwordIncludeLowerLetter.
  ///
  /// In en, this message translates to:
  /// **'Include 1 lowercase letter'**
  String get passwordIncludeLowerLetter;

  /// No description provided for @passwordIncludeNumber.
  ///
  /// In en, this message translates to:
  /// **'Include 1 number'**
  String get passwordIncludeNumber;

  /// No description provided for @passwordIncludeSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'Include 1 special character (!@#\\\$%^&*)'**
  String get passwordIncludeSpecialCharacter;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password Requirements'**
  String get passwordRequirements;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'(Or)'**
  String get or;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @loginWithMPIN.
  ///
  /// In en, this message translates to:
  /// **'Login with MPIN'**
  String get loginWithMPIN;

  /// No description provided for @loginWithFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Login with Fingerprint'**
  String get loginWithFingerprint;

  /// No description provided for @loginWithFace.
  ///
  /// In en, this message translates to:
  /// **'Login with Face ID'**
  String get loginWithFace;

  /// No description provided for @pleaseRegister.
  ///
  /// In en, this message translates to:
  /// **'Please register'**
  String get pleaseRegister;

  /// No description provided for @securityVerification.
  ///
  /// In en, this message translates to:
  /// **'Security Verification'**
  String get securityVerification;

  /// No description provided for @inSecuritySettings.
  ///
  /// In en, this message translates to:
  /// **'in Security settings.'**
  String get inSecuritySettings;

  /// No description provided for @authenticateUsingBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Authenticate using biometrics'**
  String get authenticateUsingBiometrics;

  /// No description provided for @biometricsNotAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not available. Enable it from system settings.'**
  String get biometricsNotAvailableMessage;

  /// No description provided for @tooManyAttempt.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get tooManyAttempt;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed.'**
  String get authenticationFailed;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong! Please try again later.'**
  String get somethingWentWrong;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get username;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'User Name is required.'**
  String get usernameRequired;

  /// No description provided for @usernameRequiredFormat.
  ///
  /// In en, this message translates to:
  /// **'3–20 chars: Letters, Numbers, Dot, Underscore only.'**
  String get usernameRequiredFormat;

  /// No description provided for @enterYourUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterYourUsername;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your Confirm Password'**
  String get enterConfirmPassword;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required.'**
  String get confirmPasswordRequired;

  /// No description provided for @confirmPasswordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get confirmPasswordNotMatch;

  /// No description provided for @pleaseAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept terms and conditions to continue'**
  String get pleaseAcceptTerms;

  /// No description provided for @iHaveReadAgree.
  ///
  /// In en, this message translates to:
  /// **'I have read & agree to the '**
  String get iHaveReadAgree;

  /// No description provided for @termsService.
  ///
  /// In en, this message translates to:
  /// **'terms & Service'**
  String get termsService;

  /// No description provided for @enterEmailAddressAssociated.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address associated with '**
  String get enterEmailAddressAssociated;

  /// No description provided for @zayroAccount.
  ///
  /// In en, this message translates to:
  /// **'Zayro Account'**
  String get zayroAccount;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @youNewPasswordDifferent.
  ///
  /// In en, this message translates to:
  /// **'You new password must be different from previous password,'**
  String get youNewPasswordDifferent;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @enterVerificationCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification Code OTP is required.'**
  String get enterVerificationCodeRequired;

  /// No description provided for @enterVerificationCodeFormat.
  ///
  /// In en, this message translates to:
  /// **'Verification Code must be 6 digits.'**
  String get enterVerificationCodeFormat;

  /// No description provided for @ifYouReceiveClick.
  ///
  /// In en, this message translates to:
  /// **'If you didn’t receive a code.Click '**
  String get ifYouReceiveClick;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailVerification;

  /// No description provided for @registeredEmail.
  ///
  /// In en, this message translates to:
  /// **'Registered Email.'**
  String get registeredEmail;

  /// No description provided for @pleaseEnterDigitVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit verification code that was sent to '**
  String get pleaseEnterDigitVerificationCode;

  /// No description provided for @pleaseEnterGoogleDigitVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit Google verification code'**
  String get pleaseEnterGoogleDigitVerificationCode;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @verifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get verifyNow;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @personalizeYourProfileSettings.
  ///
  /// In en, this message translates to:
  /// **'Personalize your profile & settings'**
  String get personalizeYourProfileSettings;

  /// No description provided for @uploadImageSize.
  ///
  /// In en, this message translates to:
  /// **'Upload image size of up to (1MB)'**
  String get uploadImageSize;

  /// No description provided for @editImage.
  ///
  /// In en, this message translates to:
  /// **'Edit Image'**
  String get editImage;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @referral.
  ///
  /// In en, this message translates to:
  /// **'Referral'**
  String get referral;

  /// No description provided for @kycVerification.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification'**
  String get kycVerification;

  /// No description provided for @kycVerificationSubText.
  ///
  /// In en, this message translates to:
  /// **'Please submit your KYC for better use and usability.'**
  String get kycVerificationSubText;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @loginSettings.
  ///
  /// In en, this message translates to:
  /// **'Login Settings'**
  String get loginSettings;

  /// No description provided for @mpIN.
  ///
  /// In en, this message translates to:
  /// **'MPIN'**
  String get mpIN;

  /// No description provided for @mpINSubText.
  ///
  /// In en, this message translates to:
  /// **'Simple and safe PIN authentication.'**
  String get mpINSubText;

  /// No description provided for @facialRecognition.
  ///
  /// In en, this message translates to:
  /// **'Facial Recognition'**
  String get facialRecognition;

  /// No description provided for @facialRecognitionSubText.
  ///
  /// In en, this message translates to:
  /// **'Smart and reliable facial recognition.'**
  String get facialRecognitionSubText;

  /// No description provided for @fingerprintAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint Authentication'**
  String get fingerprintAuthentication;

  /// No description provided for @fingerprintAuthenticationSubText.
  ///
  /// In en, this message translates to:
  /// **'Secure and fast fingerprint verification.'**
  String get fingerprintAuthenticationSubText;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @bioHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Bio'**
  String get bioHintText;

  /// No description provided for @bioRequired.
  ///
  /// In en, this message translates to:
  /// **'Bio is required'**
  String get bioRequired;

  /// No description provided for @applicationSettings.
  ///
  /// In en, this message translates to:
  /// **'Application Settings'**
  String get applicationSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseYourPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language.'**
  String get chooseYourPreferredLanguage;

  /// No description provided for @colourTheme.
  ///
  /// In en, this message translates to:
  /// **'Colour Theme'**
  String get colourTheme;

  /// No description provided for @colourThemeSubText.
  ///
  /// In en, this message translates to:
  /// **'Customize your app appearance.'**
  String get colourThemeSubText;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @notificationSubText.
  ///
  /// In en, this message translates to:
  /// **'Stay updated with instant alerts.'**
  String get notificationSubText;

  /// No description provided for @selectAction.
  ///
  /// In en, this message translates to:
  /// **'Select Action'**
  String get selectAction;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @toClipboard.
  ///
  /// In en, this message translates to:
  /// **'to clipboard'**
  String get toClipboard;

  /// No description provided for @yourProfileDetails.
  ///
  /// In en, this message translates to:
  /// **'Your Profile Details'**
  String get yourProfileDetails;

  /// No description provided for @nickNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your Nick Name'**
  String get nickNameHint;

  /// No description provided for @nickName.
  ///
  /// In en, this message translates to:
  /// **'Nick Name'**
  String get nickName;

  /// No description provided for @nicknameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Nickname is required.'**
  String get nicknameIsRequired;

  /// No description provided for @nicknameFormat.
  ///
  /// In en, this message translates to:
  /// **'Nickname can contain letters, numbers, underscores, and dots only'**
  String get nicknameFormat;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Date Of Birth'**
  String get birthDate;

  /// No description provided for @birthDateHintText.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Date Of Birth'**
  String get birthDateHintText;

  /// No description provided for @minimumAge.
  ///
  /// In en, this message translates to:
  /// **'Minimum age requirement is'**
  String get minimumAge;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get year;

  /// No description provided for @youAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re Offline'**
  String get youAreOffline;

  /// No description provided for @willReconnectAutomatically.
  ///
  /// In en, this message translates to:
  /// **'The app will reconnect automatically once internet is available.'**
  String get willReconnectAutomatically;

  /// No description provided for @cannotConnectInternet.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to the internet. Please try again later.'**
  String get cannotConnectInternet;

  /// No description provided for @receivedTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Received timed out. Please retry again.'**
  String get receivedTimedOut;

  /// No description provided for @connectionTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please retry again.'**
  String get connectionTimedOut;

  /// No description provided for @sendTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Send timed out. Please retry again.'**
  String get sendTimedOut;

  /// No description provided for @responseBlank.
  ///
  /// In en, this message translates to:
  /// **'Response is null or blank.'**
  String get responseBlank;

  /// No description provided for @yourSecurityLevel.
  ///
  /// In en, this message translates to:
  /// **'Your Security Level : '**
  String get yourSecurityLevel;

  /// No description provided for @yourSecurityLevelSubText.
  ///
  /// In en, this message translates to:
  /// **'Protect your funds by improving account security'**
  String get yourSecurityLevelSubText;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note:'**
  String get note;

  /// No description provided for @noteSubText.
  ///
  /// In en, this message translates to:
  /// **'For your security, withdrawals will be temporarily unavailable for 24 hours after changing security settings'**
  String get noteSubText;

  /// No description provided for @changePasswordNoteSubText.
  ///
  /// In en, this message translates to:
  /// **'For your security, withdrawals will be temporarily unavailable for 24 hours after changing login change Password'**
  String get changePasswordNoteSubText;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @twoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication (2FA)'**
  String get twoFactorAuthentication;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @googleAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'Google Authenticator'**
  String get googleAuthenticator;

  /// No description provided for @googleAuthenticatorSubText.
  ///
  /// In en, this message translates to:
  /// **'Used to verify account logins, withdrawals etc.'**
  String get googleAuthenticatorSubText;

  /// No description provided for @googleAuthenticatorDetailText.
  ///
  /// In en, this message translates to:
  /// **'Install google authenticator app in your mobile and scan QR code (or) if you are unable to scan the QR code, please enter the code manually into the app.'**
  String get googleAuthenticatorDetailText;

  /// No description provided for @googleAuthenticatorNoteText.
  ///
  /// In en, this message translates to:
  /// **'Protect and save your private key properly in case of any login issues caused by switching or losing your phone.'**
  String get googleAuthenticatorNoteText;

  /// No description provided for @secretKey.
  ///
  /// In en, this message translates to:
  /// **'Secret Key'**
  String get secretKey;

  /// No description provided for @secretKeyCopy.
  ///
  /// In en, this message translates to:
  /// **'Secret key copied to clipboard!'**
  String get secretKeyCopy;

  /// No description provided for @enterSecretKey.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Secret Key Here'**
  String get enterSecretKey;

  /// No description provided for @twoFaAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'Cannot enable both Google 2FA and Email 2FA at the same time.'**
  String get twoFaAlertMessage;

  /// No description provided for @enableGoogleAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Enable Google Authenticator'**
  String get enableGoogleAuthentication;

  /// No description provided for @diableGoogleAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Disable Google Authenticator'**
  String get diableGoogleAuthentication;

  /// No description provided for @enableEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'Enable Email Verification'**
  String get enableEmailVerification;

  /// No description provided for @diableEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'Disable Email Verification'**
  String get diableEmailVerification;

  /// No description provided for @emailVerificationSubText.
  ///
  /// In en, this message translates to:
  /// **'Use this email for login, recovery and confirmation.'**
  String get emailVerificationSubText;

  /// No description provided for @identityVerification.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get identityVerification;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// No description provided for @antiPhishingCode.
  ///
  /// In en, this message translates to:
  /// **'Anti-Phishing Code'**
  String get antiPhishingCode;

  /// No description provided for @antiPhishingCodeSubText.
  ///
  /// In en, this message translates to:
  /// **'By setting up an Anti-Phishing Code, You will be able to tell if your notification...'**
  String get antiPhishingCodeSubText;

  /// No description provided for @recoveryKey.
  ///
  /// In en, this message translates to:
  /// **'Recovery Key (Recommended)'**
  String get recoveryKey;

  /// No description provided for @noRecoveryKeysFound.
  ///
  /// In en, this message translates to:
  /// **'No Recovery keys found'**
  String get noRecoveryKeysFound;

  /// No description provided for @confirmRecoveryKeys.
  ///
  /// In en, this message translates to:
  /// **'Confirm Recovery Key'**
  String get confirmRecoveryKeys;

  /// No description provided for @disableRecoveryKeys.
  ///
  /// In en, this message translates to:
  /// **'Disable Recovery Key'**
  String get disableRecoveryKeys;

  /// No description provided for @enterPassphraseNo.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Passphrase no'**
  String get enterPassphraseNo;

  /// No description provided for @enterRecoveryKey.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Recovery Key'**
  String get enterRecoveryKey;

  /// No description provided for @recoveryKeyIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Key is required'**
  String get recoveryKeyIsRequired;

  /// No description provided for @incorrectRecoveryKey.
  ///
  /// In en, this message translates to:
  /// **'Incorrect recovery key'**
  String get incorrectRecoveryKey;

  /// No description provided for @recoveryKeysCopied.
  ///
  /// In en, this message translates to:
  /// **'Recovery keys are Copied'**
  String get recoveryKeysCopied;

  /// No description provided for @recoveryKeysSubText.
  ///
  /// In en, this message translates to:
  /// **'Use only when you want to recover your account when you loose your device.'**
  String get recoveryKeysSubText;

  /// No description provided for @saveYourPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Save your Passphrase.'**
  String get saveYourPassphrase;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @iAcceptTheDeal.
  ///
  /// In en, this message translates to:
  /// **'I accept the deal'**
  String get iAcceptTheDeal;

  /// No description provided for @pleaseAcceptDeal.
  ///
  /// In en, this message translates to:
  /// **'Please accept the deal'**
  String get pleaseAcceptDeal;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Login Password'**
  String get loginPassword;

  /// No description provided for @forAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'For Account login'**
  String get forAccountLogin;

  /// No description provided for @freezeAccount.
  ///
  /// In en, this message translates to:
  /// **'Freeze Account'**
  String get freezeAccount;

  /// No description provided for @unFreezeAccount.
  ///
  /// In en, this message translates to:
  /// **'Unfreeze Account'**
  String get unFreezeAccount;

  /// No description provided for @freezeAccountVerification.
  ///
  /// In en, this message translates to:
  /// **'Freeze Account Verification'**
  String get freezeAccountVerification;

  /// No description provided for @unFreezeAccountVerification.
  ///
  /// In en, this message translates to:
  /// **'Unfreeze Account Verification'**
  String get unFreezeAccountVerification;

  /// No description provided for @freeze.
  ///
  /// In en, this message translates to:
  /// **'Freeze'**
  String get freeze;

  /// No description provided for @freezeAccountSubText.
  ///
  /// In en, this message translates to:
  /// **'Freeze your account to disable all functions immediately.'**
  String get freezeAccountSubText;

  /// No description provided for @wantFreezeAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to freeze your account'**
  String get wantFreezeAccount;

  /// No description provided for @wantUnFreezeAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unfreeze your account'**
  String get wantUnFreezeAccount;

  /// No description provided for @freezeAccountFollowingAutomatically.
  ///
  /// In en, this message translates to:
  /// **'After the account is frozen the following terms will be automatically executed:'**
  String get freezeAccountFollowingAutomatically;

  /// No description provided for @unFreezeAccountFollowingAutomatically.
  ///
  /// In en, this message translates to:
  /// **'After the account is unfrozen the following terms will be automatically executed:'**
  String get unFreezeAccountFollowingAutomatically;

  /// No description provided for @freezeAccountCheckBoxText.
  ///
  /// In en, this message translates to:
  /// **'I understand the consequences after freezing the account.'**
  String get freezeAccountCheckBoxText;

  /// No description provided for @freezeAccountSubTwo.
  ///
  /// In en, this message translates to:
  /// **'The uncompleted withdrawals will be cancelled.'**
  String get freezeAccountSubTwo;

  /// No description provided for @freezeAccountSubThree.
  ///
  /// In en, this message translates to:
  /// **'Pending orders will be cancelled.'**
  String get freezeAccountSubThree;

  /// No description provided for @freezeAccountSubFour.
  ///
  /// In en, this message translates to:
  /// **'The API will be disabled.'**
  String get freezeAccountSubFour;

  /// No description provided for @freezeAccountSubFive.
  ///
  /// In en, this message translates to:
  /// **'Trading and withdrawals will be disabled.'**
  String get freezeAccountSubFive;

  /// No description provided for @freezeAccountSubSix.
  ///
  /// In en, this message translates to:
  /// **'You can apply to unfreeze after 24 hours.'**
  String get freezeAccountSubSix;

  /// No description provided for @freezeAccountSubSeven.
  ///
  /// In en, this message translates to:
  /// **'If there are sub-accounts, they will also be frozen depending on your configuration.'**
  String get freezeAccountSubSeven;

  /// No description provided for @freezeAccountSubEight.
  ///
  /// In en, this message translates to:
  /// **'Zayro Exchange is not liable for any consequences or market outcomes.'**
  String get freezeAccountSubEight;

  /// No description provided for @selectReasonFreezeAccount.
  ///
  /// In en, this message translates to:
  /// **'Select a reason for freezing your account:'**
  String get selectReasonFreezeAccount;

  /// No description provided for @freezeAccountReasonOne.
  ///
  /// In en, this message translates to:
  /// **'Suspicious Logins'**
  String get freezeAccountReasonOne;

  /// No description provided for @freezeAccountReasonTwo.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized Transactions'**
  String get freezeAccountReasonTwo;

  /// No description provided for @freezeAccountReasonThree.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized withdrawals'**
  String get freezeAccountReasonThree;

  /// No description provided for @freezeAccountReasonFour.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized Transfer'**
  String get freezeAccountReasonFour;

  /// No description provided for @freezeAccountReasonFive.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get freezeAccountReasonFive;

  /// No description provided for @wantToFreezeAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to freeze your account?'**
  String get wantToFreezeAccount;

  /// No description provided for @wantToDisableFreezeAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to disable freeze your account?'**
  String get wantToDisableFreezeAccount;

  /// No description provided for @accountActivities.
  ///
  /// In en, this message translates to:
  /// **'Account Activities'**
  String get accountActivities;

  /// No description provided for @accountActivitiesSubText.
  ///
  /// In en, this message translates to:
  /// **'View login and security activity history.'**
  String get accountActivitiesSubText;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubOne.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you confirm that you have read and agree to the following.'**
  String get deleteAccountSubOne;

  /// No description provided for @deleteAccountSubTwo.
  ///
  /// In en, this message translates to:
  /// **'All trading capacities and login for your account will be disabled.'**
  String get deleteAccountSubTwo;

  /// No description provided for @deleteAccountSubThree.
  ///
  /// In en, this message translates to:
  /// **'All API Keys for your account will be deleted.'**
  String get deleteAccountSubThree;

  /// No description provided for @deleteAccountSubFour.
  ///
  /// In en, this message translates to:
  /// **'All devices for your account will be deleted.'**
  String get deleteAccountSubFour;

  /// No description provided for @deleteAccountSubFive.
  ///
  /// In en, this message translates to:
  /// **'All pending withdrawals will be cancelled.'**
  String get deleteAccountSubFive;

  /// No description provided for @deleteAccountSubSix.
  ///
  /// In en, this message translates to:
  /// **'All open orders will be cancelled.'**
  String get deleteAccountSubSix;

  /// No description provided for @deleteAccountUnderstandAgree.
  ///
  /// In en, this message translates to:
  /// **'I fully understand and agree to the above.'**
  String get deleteAccountUnderstandAgree;

  /// No description provided for @pleaseSelectReasonProceed.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason to proceed.'**
  String get pleaseSelectReasonProceed;

  /// No description provided for @pleaseAcceptCondition.
  ///
  /// In en, this message translates to:
  /// **'Please accept the conditions to proceed.'**
  String get pleaseAcceptCondition;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAccountSubText.
  ///
  /// In en, this message translates to:
  /// **'Warning: Once you delete your account, it cannot be recovered, and all your data will be permanently removed.'**
  String get deleteAccountSubText;

  /// No description provided for @deleteAccountNote.
  ///
  /// In en, this message translates to:
  /// **'Please DO NOT deposit any asset to a deleted account. If you do, your funds will be lost and cannot be retrieved.'**
  String get deleteAccountNote;

  /// No description provided for @deleteAccountStepOne.
  ///
  /// In en, this message translates to:
  /// **'Account cannot be merged after deletion.'**
  String get deleteAccountStepOne;

  /// No description provided for @deleteAccountStepTwo.
  ///
  /// In en, this message translates to:
  /// **'Delete your deposit address from wallet to avoid losses.'**
  String get deleteAccountStepTwo;

  /// No description provided for @deleteAccountStepThree.
  ///
  /// In en, this message translates to:
  /// **'Withdraw all assets before deletion or they may be permanently lost.'**
  String get deleteAccountStepThree;

  /// No description provided for @deleteAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'Account has been disabled due to:'**
  String get deleteAccountDisabled;

  /// No description provided for @deleteAccountReasonOne.
  ///
  /// In en, this message translates to:
  /// **'I don’t understand cryptocurrency and don’t want to trade anymore'**
  String get deleteAccountReasonOne;

  /// No description provided for @deleteAccountReasonTwo.
  ///
  /// In en, this message translates to:
  /// **'There is suspicious account activity. I would like to disable login for the account.'**
  String get deleteAccountReasonTwo;

  /// No description provided for @deleteAccountReasonThree.
  ///
  /// In en, this message translates to:
  /// **'I have another account already, so I want to delete this account'**
  String get deleteAccountReasonThree;

  /// No description provided for @deleteAccountReasonFour.
  ///
  /// In en, this message translates to:
  /// **'I don’t want to use Zayro Exchange anymore.'**
  String get deleteAccountReasonFour;

  /// No description provided for @deleteAccountReasonFive.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get deleteAccountReasonFive;

  /// No description provided for @createMPIN.
  ///
  /// In en, this message translates to:
  /// **'Create MPIN'**
  String get createMPIN;

  /// No description provided for @changeMPIN.
  ///
  /// In en, this message translates to:
  /// **'Change MPIN'**
  String get changeMPIN;

  /// No description provided for @enterMPIN.
  ///
  /// In en, this message translates to:
  /// **'Enter MPIN'**
  String get enterMPIN;

  /// No description provided for @forgotMPIN.
  ///
  /// In en, this message translates to:
  /// **'Forgot MPIN'**
  String get forgotMPIN;

  /// No description provided for @forgotMPinNumber.
  ///
  /// In en, this message translates to:
  /// **'Forgot your MPIN number?'**
  String get forgotMPinNumber;

  /// No description provided for @currentMpinRequired.
  ///
  /// In en, this message translates to:
  /// **'Current MPIN is required'**
  String get currentMpinRequired;

  /// No description provided for @mpinDigitLimit.
  ///
  /// In en, this message translates to:
  /// **'Current MPIN must be 6-digits'**
  String get mpinDigitLimit;

  /// No description provided for @incorrectCurrentMpin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect Current MPIN'**
  String get incorrectCurrentMpin;

  /// No description provided for @newMpinIsRequired.
  ///
  /// In en, this message translates to:
  /// **'New MPIN is required'**
  String get newMpinIsRequired;

  /// No description provided for @newMpinMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'New MPIN must be 6-digits'**
  String get newMpinMustBe6Digits;

  /// No description provided for @newMpinMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'New MPIN must be different from Current MPIN'**
  String get newMpinMustBeDifferent;

  /// No description provided for @confirmMpinIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm MPIN is required'**
  String get confirmMpinIsRequired;

  /// No description provided for @confirmMpinMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'Confirm MPIN must be 6-digits'**
  String get confirmMpinMustBe6Digits;

  /// No description provided for @mpinNotMatching.
  ///
  /// In en, this message translates to:
  /// **'New and Confirm MPIN do not match'**
  String get mpinNotMatching;

  /// No description provided for @accountActivity.
  ///
  /// In en, this message translates to:
  /// **'Account Activity'**
  String get accountActivity;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// No description provided for @iPAddress.
  ///
  /// In en, this message translates to:
  /// **'IP Address'**
  String get iPAddress;

  /// No description provided for @browser.
  ///
  /// In en, this message translates to:
  /// **'Browser'**
  String get browser;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @os.
  ///
  /// In en, this message translates to:
  /// **'OS'**
  String get os;

  /// No description provided for @whatAntiPhishingCode.
  ///
  /// In en, this message translates to:
  /// **'What in an Anti-Phishing Code?'**
  String get whatAntiPhishingCode;

  /// No description provided for @whatAntiPhishingCodeSubText.
  ///
  /// In en, this message translates to:
  /// **'An Anti-phishing is a code that protects against phishing attempts from fake Zayro Exchange website or email addresses.'**
  String get whatAntiPhishingCodeSubText;

  /// No description provided for @howDoesItWorks.
  ///
  /// In en, this message translates to:
  /// **'How does it works?'**
  String get howDoesItWorks;

  /// No description provided for @howDoesItWorksSubText.
  ///
  /// In en, this message translates to:
  /// **'Once you’ve set up your unique Anti-phishing code, it will be displayed on all genuine Zayro Exchange emails.'**
  String get howDoesItWorksSubText;

  /// No description provided for @yourAntiPhishingCode.
  ///
  /// In en, this message translates to:
  /// **'Your anti-phishing code is '**
  String get yourAntiPhishingCode;

  /// No description provided for @createAntiPhishingCode.
  ///
  /// In en, this message translates to:
  /// **'Create Anti-Phishing Code'**
  String get createAntiPhishingCode;

  /// No description provided for @regenerateAntiPhishingCode.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Anti-Phishing Code'**
  String get regenerateAntiPhishingCode;

  /// No description provided for @enterDigitOTPSentYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit OTP sent to your email:'**
  String get enterDigitOTPSentYourEmail;

  /// No description provided for @enterYourCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your code'**
  String get enterYourCode;

  /// No description provided for @codeIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Code is required'**
  String get codeIsRequired;

  /// No description provided for @codeMinLength.
  ///
  /// In en, this message translates to:
  /// **'Code must be at least 4 characters.'**
  String get codeMinLength;

  /// No description provided for @codeMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Code must be less than 30 characters.'**
  String get codeMaxLength;

  /// No description provided for @pleaseEnterCharacters.
  ///
  /// In en, this message translates to:
  /// **'Please enter 4-30 characters.'**
  String get pleaseEnterCharacters;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @antiPhishingCodeAfterEnablingIncluded.
  ///
  /// In en, this message translates to:
  /// **'After enabling, the code will be included in all genuine Zayro Exchange emails.'**
  String get antiPhishingCodeAfterEnablingIncluded;

  /// No description provided for @changeLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Change Login Password'**
  String get changeLoginPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Current Password'**
  String get enterCurrentPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Your New Password'**
  String get enterNewPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @currentMPin.
  ///
  /// In en, this message translates to:
  /// **'Current MPIN'**
  String get currentMPin;

  /// No description provided for @newMPin.
  ///
  /// In en, this message translates to:
  /// **'New MPIN'**
  String get newMPin;

  /// No description provided for @confirmMPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm MPIN'**
  String get confirmMPin;

  /// No description provided for @yourPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Your Portfolio'**
  String get yourPortfolio;

  /// No description provided for @link.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get link;

  /// No description provided for @linkCopiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Link Copied Successfully'**
  String get linkCopiedSuccessfully;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @codeCopiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Code Copied Successfully'**
  String get codeCopiedSuccessfully;

  /// No description provided for @downlineInformation.
  ///
  /// In en, this message translates to:
  /// **'Downline Information'**
  String get downlineInformation;

  /// No description provided for @referralHistory.
  ///
  /// In en, this message translates to:
  /// **'Referral History'**
  String get referralHistory;

  /// No description provided for @yourSponsor.
  ///
  /// In en, this message translates to:
  /// **'Your Sponsor'**
  String get yourSponsor;

  /// No description provided for @totalDownline.
  ///
  /// In en, this message translates to:
  /// **'Total Downline'**
  String get totalDownline;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @earningsToday.
  ///
  /// In en, this message translates to:
  /// **'Earnings Today'**
  String get earningsToday;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @fullEarned.
  ///
  /// In en, this message translates to:
  /// **'Full Earned'**
  String get fullEarned;

  /// No description provided for @userStatus.
  ///
  /// In en, this message translates to:
  /// **'User Status'**
  String get userStatus;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @creditedToken.
  ///
  /// In en, this message translates to:
  /// **'Credited Token'**
  String get creditedToken;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @zayroSupport.
  ///
  /// In en, this message translates to:
  /// **'Zayro Support'**
  String get zayroSupport;

  /// No description provided for @ticketID.
  ///
  /// In en, this message translates to:
  /// **'Ticket ID'**
  String get ticketID;

  /// No description provided for @askMeSomething.
  ///
  /// In en, this message translates to:
  /// **'Ask me something...'**
  String get askMeSomething;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @enterYourTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter YourTitle'**
  String get enterYourTitle;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @enterYourMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Message'**
  String get enterYourMessage;

  /// No description provided for @idDocument.
  ///
  /// In en, this message translates to:
  /// **'ID Document'**
  String get idDocument;

  /// No description provided for @maximumUploadMB.
  ///
  /// In en, this message translates to:
  /// **'(Maximum file upload size: 2 MB)'**
  String get maximumUploadMB;

  /// No description provided for @createTicket.
  ///
  /// In en, this message translates to:
  /// **'Create Ticket'**
  String get createTicket;

  /// No description provided for @opened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get opened;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get createdAt;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get firstNameRequired;

  /// No description provided for @firstNameInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid first name'**
  String get firstNameInvalidFormat;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @lastNameInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid last name'**
  String get lastNameInvalidFormat;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @expiryDateHintText.
  ///
  /// In en, this message translates to:
  /// **'Select expiry date'**
  String get expiryDateHintText;

  /// No description provided for @expiryDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Expiry date is required'**
  String get expiryDateRequired;

  /// No description provided for @expiryDateMustBeFuture.
  ///
  /// In en, this message translates to:
  /// **'Expiry date must be in the future'**
  String get expiryDateMustBeFuture;

  /// No description provided for @invalidDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid date format'**
  String get invalidDateFormat;

  /// No description provided for @documentNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Document number is required'**
  String get documentNumberRequired;

  /// No description provided for @documentNumberInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid document number'**
  String get documentNumberInvalidFormat;

  /// No description provided for @protectYourFunds.
  ///
  /// In en, this message translates to:
  /// **'Protect your Funds'**
  String get protectYourFunds;

  /// No description provided for @protectYourFundsSubText.
  ///
  /// In en, this message translates to:
  /// **'Your account security level is low. Please enable at least one more verification mode.'**
  String get protectYourFundsSubText;

  /// No description provided for @authenticatorAppRecommended.
  ///
  /// In en, this message translates to:
  /// **'Authenticator App (Recommended)'**
  String get authenticatorAppRecommended;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @enableFreeze.
  ///
  /// In en, this message translates to:
  /// **'Enable Freeze'**
  String get enableFreeze;

  /// No description provided for @disableFreeze.
  ///
  /// In en, this message translates to:
  /// **'Disable Freeze'**
  String get disableFreeze;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @buySell.
  ///
  /// In en, this message translates to:
  /// **'Buy/Sell'**
  String get buySell;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @kycWaitingAdminApproval.
  ///
  /// In en, this message translates to:
  /// **'KYC submitted successfully. Waiting for admin approval.'**
  String get kycWaitingAdminApproval;

  /// No description provided for @kycVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your KYC has been verified successfully'**
  String get kycVerifiedSuccessfully;

  /// No description provided for @kycVerifiedRejected.
  ///
  /// In en, this message translates to:
  /// **'The KYC verification has been rejected.'**
  String get kycVerifiedRejected;

  /// No description provided for @verifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify Identity'**
  String get verifyIdentity;

  /// No description provided for @normalKycVerification.
  ///
  /// In en, this message translates to:
  /// **'Normal KYC Verification'**
  String get normalKycVerification;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter first name'**
  String get enterFirstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter last name'**
  String get enterLastName;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get selectCountry;

  /// No description provided for @documentType.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get documentType;

  /// No description provided for @documentNumber.
  ///
  /// In en, this message translates to:
  /// **'Document Number'**
  String get documentNumber;

  /// No description provided for @enterDocumentNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter document number'**
  String get enterDocumentNumber;

  /// No description provided for @yyyyMmDd.
  ///
  /// In en, this message translates to:
  /// **'yyyy-MM-dd'**
  String get yyyyMmDd;

  /// No description provided for @idDocumentFront.
  ///
  /// In en, this message translates to:
  /// **'ID Document front'**
  String get idDocumentFront;

  /// No description provided for @idDocumentBack.
  ///
  /// In en, this message translates to:
  /// **'ID Document back'**
  String get idDocumentBack;

  /// No description provided for @clickChooseFiles.
  ///
  /// In en, this message translates to:
  /// **'Click to choose files'**
  String get clickChooseFiles;

  /// No description provided for @clickViewFiles.
  ///
  /// In en, this message translates to:
  /// **'Click to view file'**
  String get clickViewFiles;

  /// No description provided for @uploadRelevantDocumentsContinue.
  ///
  /// In en, this message translates to:
  /// **'Upload the relevant documents to continue!'**
  String get uploadRelevantDocumentsContinue;

  /// No description provided for @selectDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Select Document Type'**
  String get selectDocumentType;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @passport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get passport;

  /// No description provided for @drivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get drivingLicense;

  /// No description provided for @government_ID.
  ///
  /// In en, this message translates to:
  /// **'Government ID'**
  String get government_ID;

  /// No description provided for @depositHistory.
  ///
  /// In en, this message translates to:
  /// **'Deposit History'**
  String get depositHistory;

  /// No description provided for @withdrawHistory.
  ///
  /// In en, this message translates to:
  /// **'Withdraw History'**
  String get withdrawHistory;

  /// No description provided for @openOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'Open Order History'**
  String get openOrderHistory;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @selectCoin.
  ///
  /// In en, this message translates to:
  /// **'Select Coin'**
  String get selectCoin;

  /// No description provided for @noDepositHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No Deposit History Found'**
  String get noDepositHistoryFound;

  /// No description provided for @sender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get sender;

  /// No description provided for @receiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiver;

  /// No description provided for @tXHash.
  ///
  /// In en, this message translates to:
  /// **'TX Hash'**
  String get tXHash;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @receivedDepositAmount.
  ///
  /// In en, this message translates to:
  /// **'Received Deposit Amount'**
  String get receivedDepositAmount;

  /// No description provided for @noWithdrawHistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No Withdraw History Found'**
  String get noWithdrawHistoryFound;

  /// No description provided for @requestedAmount.
  ///
  /// In en, this message translates to:
  /// **'Requested Amount'**
  String get requestedAmount;

  /// No description provided for @withdrawFee.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Fee'**
  String get withdrawFee;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @spotAccount.
  ///
  /// In en, this message translates to:
  /// **'Spot Account'**
  String get spotAccount;

  /// No description provided for @futureAccount.
  ///
  /// In en, this message translates to:
  /// **'Future Account'**
  String get futureAccount;

  /// No description provided for @assetList.
  ///
  /// In en, this message translates to:
  /// **'Asset List'**
  String get assetList;

  /// No description provided for @searchCoin.
  ///
  /// In en, this message translates to:
  /// **'Search Coin...'**
  String get searchCoin;

  /// No description provided for @loadingCoins.
  ///
  /// In en, this message translates to:
  /// **'Loading coins...'**
  String get loadingCoins;

  /// No description provided for @noCoinsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No coins available'**
  String get noCoinsAvailable;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @freeBalance.
  ///
  /// In en, this message translates to:
  /// **'Free Balance'**
  String get freeBalance;

  /// No description provided for @lockedBalance.
  ///
  /// In en, this message translates to:
  /// **'Locked Balance'**
  String get lockedBalance;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance (Spot)'**
  String get availableBalance;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logOut;

  /// No description provided for @selectCrypto.
  ///
  /// In en, this message translates to:
  /// **'Select Crypto Coin'**
  String get selectCrypto;

  /// No description provided for @selectNetwork.
  ///
  /// In en, this message translates to:
  /// **'Select Network Coin'**
  String get selectNetwork;

  /// No description provided for @minimumDepositLimit.
  ///
  /// In en, this message translates to:
  /// **'Minimum Deposit Limit'**
  String get minimumDepositLimit;

  /// No description provided for @depositFees.
  ///
  /// In en, this message translates to:
  /// **'Deposit Fees'**
  String get depositFees;

  /// No description provided for @walletAddress.
  ///
  /// In en, this message translates to:
  /// **'Wallet Address'**
  String get walletAddress;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @depositMinutes.
  ///
  /// In en, this message translates to:
  /// **'Deposit may take from a few minutes to over 30 minutes.'**
  String get depositMinutes;

  /// No description provided for @copiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Copied Successfully'**
  String get copiedSuccessfully;

  /// No description provided for @enterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter Address'**
  String get enterAddress;

  /// No description provided for @withdrawAddress.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Address'**
  String get withdrawAddress;

  /// No description provided for @withdrawAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Address is required'**
  String get withdrawAddressRequired;

  /// No description provided for @enterWithdrawAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Withdraw Amount'**
  String get enterWithdrawAmount;

  /// No description provided for @withdrawAmount.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Amount'**
  String get withdrawAmount;

  /// No description provided for @withdrawAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Amount is required'**
  String get withdrawAmountRequired;

  /// No description provided for @yourAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Your available balance is'**
  String get yourAvailableBalance;

  /// No description provided for @minWithdrawLimit.
  ///
  /// In en, this message translates to:
  /// **'Min withdraw limit is'**
  String get minWithdrawLimit;

  /// No description provided for @maxWithdrawLimit.
  ///
  /// In en, this message translates to:
  /// **'Max withdraw limit is'**
  String get maxWithdrawLimit;

  /// No description provided for @withdrawalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Confirmation'**
  String get withdrawalConfirmation;

  /// No description provided for @areYouSureWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to confirm this withdrawal ?'**
  String get areYouSureWithdrawal;

  /// No description provided for @minWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Min Withdraw'**
  String get minWithdraw;

  /// No description provided for @maxWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Max Withdraw'**
  String get maxWithdraw;

  /// No description provided for @perDayWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Per Day Withdraw'**
  String get perDayWithdraw;

  /// No description provided for @pleaseSelectCryptoFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a crypto first'**
  String get pleaseSelectCryptoFirst;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Data Available'**
  String get noDataAvailable;

  /// No description provided for @coinDetails.
  ///
  /// In en, this message translates to:
  /// **'Coin Details'**
  String get coinDetails;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @marketChange.
  ///
  /// In en, this message translates to:
  /// **'24H Change :'**
  String get marketChange;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume :'**
  String get volume;

  /// No description provided for @balanceDetails.
  ///
  /// In en, this message translates to:
  /// **'Balance Details'**
  String get balanceDetails;

  /// No description provided for @affiliate.
  ///
  /// In en, this message translates to:
  /// **'Affiliate'**
  String get affiliate;

  /// No description provided for @marketList.
  ///
  /// In en, this message translates to:
  /// **'Market List'**
  String get marketList;

  /// No description provided for @totalValue.
  ///
  /// In en, this message translates to:
  /// **'Total value (USDT)'**
  String get totalValue;

  /// No description provided for @assetDetails.
  ///
  /// In en, this message translates to:
  /// **'Asset Details'**
  String get assetDetails;

  /// No description provided for @hotSpot.
  ///
  /// In en, this message translates to:
  /// **'Hot Spot'**
  String get hotSpot;

  /// No description provided for @topGainer.
  ///
  /// In en, this message translates to:
  /// **'Top Gainer'**
  String get topGainer;

  /// No description provided for @topLooser.
  ///
  /// In en, this message translates to:
  /// **'Top Looser'**
  String get topLooser;

  /// No description provided for @newListing.
  ///
  /// In en, this message translates to:
  /// **'New Listing'**
  String get newListing;

  /// No description provided for @selectHistoryType.
  ///
  /// In en, this message translates to:
  /// **'Select History Type'**
  String get selectHistoryType;

  /// No description provided for @fees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get fees;

  /// No description provided for @withdrawalAddress.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Address'**
  String get withdrawalAddress;

  /// No description provided for @favourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// No description provided for @twentyFourHigh.
  ///
  /// In en, this message translates to:
  /// **'24H High'**
  String get twentyFourHigh;

  /// No description provided for @twentyFourLow.
  ///
  /// In en, this message translates to:
  /// **'24H Low'**
  String get twentyFourLow;

  /// No description provided for @twentyFourVolume.
  ///
  /// In en, this message translates to:
  /// **'24H Volume'**
  String get twentyFourVolume;

  /// No description provided for @twentyFourTurnOver.
  ///
  /// In en, this message translates to:
  /// **'24H Turnover'**
  String get twentyFourTurnOver;

  /// No description provided for @twentyFourChange.
  ///
  /// In en, this message translates to:
  /// **'24H Change'**
  String get twentyFourChange;

  /// No description provided for @fundingRate.
  ///
  /// In en, this message translates to:
  /// **'Funding Rate'**
  String get fundingRate;

  /// No description provided for @countdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get countdown;

  /// No description provided for @orderType.
  ///
  /// In en, this message translates to:
  /// **'Order Type'**
  String get orderType;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @remainingOrAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining / Amount'**
  String get remainingOrAmount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @tradingFees.
  ///
  /// In en, this message translates to:
  /// **'Trading Fees'**
  String get tradingFees;

  /// No description provided for @orderTime.
  ///
  /// In en, this message translates to:
  /// **'Order Date & Time'**
  String get orderTime;

  /// No description provided for @avgFilledPrice.
  ///
  /// In en, this message translates to:
  /// **'Avg Filled Price'**
  String get avgFilledPrice;

  /// No description provided for @contracts.
  ///
  /// In en, this message translates to:
  /// **'Contracts'**
  String get contracts;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @entryPrice.
  ///
  /// In en, this message translates to:
  /// **'Entry Price'**
  String get entryPrice;

  /// No description provided for @exitPrice.
  ///
  /// In en, this message translates to:
  /// **'Exit Price'**
  String get exitPrice;

  /// No description provided for @tradeType.
  ///
  /// In en, this message translates to:
  /// **'Trade Type'**
  String get tradeType;

  /// No description provided for @closedPNL.
  ///
  /// In en, this message translates to:
  /// **'Closed P&L'**
  String get closedPNL;

  /// No description provided for @filledType.
  ///
  /// In en, this message translates to:
  /// **'Filled Type'**
  String get filledType;

  /// No description provided for @filledTime.
  ///
  /// In en, this message translates to:
  /// **'Filled Time'**
  String get filledTime;

  /// No description provided for @instrument.
  ///
  /// In en, this message translates to:
  /// **'Instrument'**
  String get instrument;

  /// No description provided for @positionHistory.
  ///
  /// In en, this message translates to:
  /// **'Position History'**
  String get positionHistory;

  /// No description provided for @orderTotal.
  ///
  /// In en, this message translates to:
  /// **'Order Total'**
  String get orderTotal;

  /// No description provided for @orderValue.
  ///
  /// In en, this message translates to:
  /// **'Order Value'**
  String get orderValue;

  /// No description provided for @filled.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get filled;

  /// No description provided for @filledOrQty.
  ///
  /// In en, this message translates to:
  /// **'Filled/Actual Qty'**
  String get filledOrQty;

  /// No description provided for @filledOrTotal.
  ///
  /// In en, this message translates to:
  /// **'Filled/Total'**
  String get filledOrTotal;

  /// No description provided for @filledPriceOrOrderPrice.
  ///
  /// In en, this message translates to:
  /// **'Filled Price/Order Price'**
  String get filledPriceOrOrderPrice;

  /// No description provided for @orderID.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderID;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @side.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get side;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allSide.
  ///
  /// In en, this message translates to:
  /// **'All Side'**
  String get allSide;

  /// No description provided for @allType.
  ///
  /// In en, this message translates to:
  /// **'All Type'**
  String get allType;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @transferHistory.
  ///
  /// In en, this message translates to:
  /// **'Transfer History'**
  String get transferHistory;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @assetAllocation.
  ///
  /// In en, this message translates to:
  /// **'Asset Allocation'**
  String get assetAllocation;

  /// No description provided for @spot.
  ///
  /// In en, this message translates to:
  /// **'Spot'**
  String get spot;

  /// No description provided for @future.
  ///
  /// In en, this message translates to:
  /// **'Futures'**
  String get future;

  /// No description provided for @futuresDescription.
  ///
  /// In en, this message translates to:
  /// **'Trade futures contracts in USDC'**
  String get futuresDescription;

  /// No description provided for @perpetualDescription.
  ///
  /// In en, this message translates to:
  /// **'Perpetual contracts in USDT & USDC'**
  String get perpetualDescription;

  /// No description provided for @copyTrade.
  ///
  /// In en, this message translates to:
  /// **'Copy Trade'**
  String get copyTrade;

  /// No description provided for @recentTrend.
  ///
  /// In en, this message translates to:
  /// **'Recent Trend'**
  String get recentTrend;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @spotStatement.
  ///
  /// In en, this message translates to:
  /// **'Spot Statement'**
  String get spotStatement;

  /// No description provided for @spotTradingFees.
  ///
  /// In en, this message translates to:
  /// **'Spot Trading Fees'**
  String get spotTradingFees;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @makerFee.
  ///
  /// In en, this message translates to:
  /// **'Maker Fee'**
  String get makerFee;

  /// No description provided for @takerFee.
  ///
  /// In en, this message translates to:
  /// **'Taker Fee'**
  String get takerFee;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @hideSmallBalances.
  ///
  /// In en, this message translates to:
  /// **'Hide Small Balances'**
  String get hideSmallBalances;

  /// No description provided for @simplifiesList.
  ///
  /// In en, this message translates to:
  /// **'Simplifies List'**
  String get simplifiesList;

  /// No description provided for @frozenBalance.
  ///
  /// In en, this message translates to:
  /// **'Frozen Balance'**
  String get frozenBalance;

  /// No description provided for @usdValuation.
  ///
  /// In en, this message translates to:
  /// **'USD Valuation'**
  String get usdValuation;

  /// No description provided for @estimateBalance.
  ///
  /// In en, this message translates to:
  /// **'Estimate Balance'**
  String get estimateBalance;

  /// No description provided for @todayPnl.
  ///
  /// In en, this message translates to:
  /// **'Today\'s PNL'**
  String get todayPnl;

  /// No description provided for @futuresStatement.
  ///
  /// In en, this message translates to:
  /// **'Futures Statement'**
  String get futuresStatement;

  /// No description provided for @fundingHistory.
  ///
  /// In en, this message translates to:
  /// **'Funding History'**
  String get fundingHistory;

  /// No description provided for @futuresTradingFees.
  ///
  /// In en, this message translates to:
  /// **'Futures Trading Fees'**
  String get futuresTradingFees;

  /// No description provided for @totalEquity.
  ///
  /// In en, this message translates to:
  /// **'Total Equity'**
  String get totalEquity;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @unrealizedPnl.
  ///
  /// In en, this message translates to:
  /// **'Unrealized PNL'**
  String get unrealizedPnl;

  /// No description provided for @positionMargin.
  ///
  /// In en, this message translates to:
  /// **'Position Margin'**
  String get positionMargin;

  /// No description provided for @orderMargin.
  ///
  /// In en, this message translates to:
  /// **'Order Margin'**
  String get orderMargin;

  /// No description provided for @availableMargin.
  ///
  /// In en, this message translates to:
  /// **'Available Margin'**
  String get availableMargin;

  /// No description provided for @futuresAccount.
  ///
  /// In en, this message translates to:
  /// **'Futures Account'**
  String get futuresAccount;

  /// No description provided for @assetTransfer.
  ///
  /// In en, this message translates to:
  /// **'Asset Transfer'**
  String get assetTransfer;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @crypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get crypto;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'Select an Option'**
  String get selectOption;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get priceRequired;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// No description provided for @amountShouldNotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Amount should not be zero'**
  String get amountShouldNotBeZero;

  /// No description provided for @priceShouldNotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Price should not be zero'**
  String get priceShouldNotBeZero;

  /// No description provided for @triggerPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Trigger Price is required'**
  String get triggerPriceRequired;

  /// No description provided for @triggerPriceShouldNotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Trigger Price should not be zero'**
  String get triggerPriceShouldNotBeZero;

  /// No description provided for @stopLossRequired.
  ///
  /// In en, this message translates to:
  /// **'Stop Loss is required'**
  String get stopLossRequired;

  /// No description provided for @stopLossShouldNotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Stop Loss should not be zero'**
  String get stopLossShouldNotBeZero;

  /// No description provided for @takeProfitRequired.
  ///
  /// In en, this message translates to:
  /// **'Take Profit is required'**
  String get takeProfitRequired;

  /// No description provided for @takeProfitShouldNotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Take Profit should not be zero'**
  String get takeProfitShouldNotBeZero;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required'**
  String get quantityRequired;

  /// No description provided for @quantityShouldNotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Quantity should not be zero'**
  String get quantityShouldNotBeZero;

  /// No description provided for @totalRequired.
  ///
  /// In en, this message translates to:
  /// **'Total is required'**
  String get totalRequired;

  /// No description provided for @totalShouldNotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Total should not be zero'**
  String get totalShouldNotBeZero;

  /// No description provided for @marketPrice.
  ///
  /// In en, this message translates to:
  /// **'Market Price'**
  String get marketPrice;

  /// No description provided for @pleaseWaitForKycSubmission.
  ///
  /// In en, this message translates to:
  /// **'Please wait for your KYC submission to unlock your account benefits.'**
  String get pleaseWaitForKycSubmission;

  /// No description provided for @marginBalance.
  ///
  /// In en, this message translates to:
  /// **'Margin Balance'**
  String get marginBalance;

  /// No description provided for @marginMode.
  ///
  /// In en, this message translates to:
  /// **'Margin Mode'**
  String get marginMode;

  /// No description provided for @isolatedDescription.
  ///
  /// In en, this message translates to:
  /// **'In isolated margin mode, a certain amount of margin will be added to the position. If the margin falls below the maintenance level, liquidation will take place. Meanwhile, you can choose to add or reduce the margin for the position.'**
  String get isolatedDescription;

  /// No description provided for @crossDescription.
  ///
  /// In en, this message translates to:
  /// **'In cross margin mode, margin will be shared across all positions. In the event of liquidation, traders might lose all the margin and positions settled using this asset.'**
  String get crossDescription;

  /// No description provided for @applyMarginMode.
  ///
  /// In en, this message translates to:
  /// **'Apply margin mode adjustment to all futures'**
  String get applyMarginMode;

  /// No description provided for @adjustLeverage.
  ///
  /// In en, this message translates to:
  /// **'Adjust Leverage'**
  String get adjustLeverage;

  /// No description provided for @adjustLeverageInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Maximum openable position at market price with the current leverage multiplier : 0 USDT'**
  String get adjustLeverageInstruction1;

  /// No description provided for @adjustLeverageInstruction2.
  ///
  /// In en, this message translates to:
  /// **'Maximum size at the current leverage : 23,42156 USDT'**
  String get adjustLeverageInstruction2;

  /// No description provided for @viewRiskLimits.
  ///
  /// In en, this message translates to:
  /// **'View risk limits'**
  String get viewRiskLimits;

  /// No description provided for @orderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmation'**
  String get orderConfirmation;

  /// No description provided for @perpetualClose.
  ///
  /// In en, this message translates to:
  /// **'Perpetual Close'**
  String get perpetualClose;

  /// No description provided for @contractClose.
  ///
  /// In en, this message translates to:
  /// **'Contract Close'**
  String get contractClose;

  /// No description provided for @estPNL.
  ///
  /// In en, this message translates to:
  /// **'Est. PNL'**
  String get estPNL;

  /// No description provided for @neverShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Never Show Again'**
  String get neverShowAgain;

  /// No description provided for @reversePosition.
  ///
  /// In en, this message translates to:
  /// **'Reverse Position'**
  String get reversePosition;

  /// No description provided for @orderPrice.
  ///
  /// In en, this message translates to:
  /// **'Order Price'**
  String get orderPrice;

  /// No description provided for @reverseDescription.
  ///
  /// In en, this message translates to:
  /// **'The system will close positions at market price, and open reverse positions at the same quantity at market price. Due to factors such as margins, market conditions and risk limits, this action might not be 100% successful.'**
  String get reverseDescription;

  /// No description provided for @closablePositions.
  ///
  /// In en, this message translates to:
  /// **'Closable Positions'**
  String get closablePositions;

  /// No description provided for @contractWillClosedAt.
  ///
  /// In en, this message translates to:
  /// **'Contract(s) will be closed at'**
  String get contractWillClosedAt;

  /// No description provided for @addTpSl.
  ///
  /// In en, this message translates to:
  /// **'Add TP/SL'**
  String get addTpSl;

  /// No description provided for @lastTradedPrice.
  ///
  /// In en, this message translates to:
  /// **'Last Traded Price'**
  String get lastTradedPrice;

  /// No description provided for @takeProfit.
  ///
  /// In en, this message translates to:
  /// **'Take Profit'**
  String get takeProfit;

  /// No description provided for @stopLoss.
  ///
  /// In en, this message translates to:
  /// **'Stop Loss'**
  String get stopLoss;

  /// No description provided for @pnlRate.
  ///
  /// In en, this message translates to:
  /// **'PNL Rate'**
  String get pnlRate;

  /// No description provided for @slTriggerPrice.
  ///
  /// In en, this message translates to:
  /// **'SL Trigger Price'**
  String get slTriggerPrice;

  /// No description provided for @lastPrice.
  ///
  /// In en, this message translates to:
  /// **'Last Price'**
  String get lastPrice;

  /// No description provided for @mainWallet.
  ///
  /// In en, this message translates to:
  /// **'Main Wallet'**
  String get mainWallet;

  /// No description provided for @fromAccountType.
  ///
  /// In en, this message translates to:
  /// **'From (Account Type)'**
  String get fromAccountType;

  /// No description provided for @toAccountType.
  ///
  /// In en, this message translates to:
  /// **'To (Account Type)'**
  String get toAccountType;

  /// No description provided for @transferType.
  ///
  /// In en, this message translates to:
  /// **'Transfer Type'**
  String get transferType;

  /// No description provided for @subAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Sub Account Info'**
  String get subAccountInfo;

  /// No description provided for @signInWith.
  ///
  /// In en, this message translates to:
  /// **'Sign In with'**
  String get signInWith;

  /// No description provided for @switchTo.
  ///
  /// In en, this message translates to:
  /// **'Switch to'**
  String get switchTo;

  /// No description provided for @signInSubAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign In Sub Account'**
  String get signInSubAccount;

  /// No description provided for @leverage.
  ///
  /// In en, this message translates to:
  /// **'Leverage'**
  String get leverage;

  /// No description provided for @triggerPrice.
  ///
  /// In en, this message translates to:
  /// **'Trigger Price'**
  String get triggerPrice;

  /// No description provided for @closeShort.
  ///
  /// In en, this message translates to:
  /// **'Close Short'**
  String get closeShort;

  /// No description provided for @areYouSureWantToCancel.
  ///
  /// In en, this message translates to:
  /// **'Are you sure want to cancel ?'**
  String get areYouSureWantToCancel;

  /// No description provided for @pnlHistory.
  ///
  /// In en, this message translates to:
  /// **'PNL History'**
  String get pnlHistory;

  /// No description provided for @exitType.
  ///
  /// In en, this message translates to:
  /// **'Exit Type'**
  String get exitType;

  /// No description provided for @tradeTime.
  ///
  /// In en, this message translates to:
  /// **'Trade Time'**
  String get tradeTime;

  /// No description provided for @indexPrice.
  ///
  /// In en, this message translates to:
  /// **'Index Price'**
  String get indexPrice;

  /// No description provided for @priceChart.
  ///
  /// In en, this message translates to:
  /// **'Price Chart'**
  String get priceChart;

  /// No description provided for @depthChart.
  ///
  /// In en, this message translates to:
  /// **'Depth Chart'**
  String get depthChart;

  /// No description provided for @cancelOrderConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure that you want to cancel this order?'**
  String get cancelOrderConfirmation;

  /// No description provided for @maximumPositionAtCurrentLeverage.
  ///
  /// In en, this message translates to:
  /// **'Maximum position at current leverage'**
  String get maximumPositionAtCurrentLeverage;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @initialMargin.
  ///
  /// In en, this message translates to:
  /// **'Initial Margin'**
  String get initialMargin;

  /// No description provided for @entryPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Entry Price is required'**
  String get entryPriceRequired;

  /// No description provided for @entryPriceShouldNotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Entry Price should not be zero'**
  String get entryPriceShouldNotBeZero;

  /// No description provided for @exitPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Exit Price is required'**
  String get exitPriceRequired;

  /// No description provided for @exitPriceShouldNotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Exit Price should not be zero'**
  String get exitPriceShouldNotBeZero;

  /// No description provided for @investmentTournament.
  ///
  /// In en, this message translates to:
  /// **'Investment Tournament'**
  String get investmentTournament;

  /// No description provided for @availableBalanceInArenaWallet.
  ///
  /// In en, this message translates to:
  /// **'Available Balance in Arena Wallet'**
  String get availableBalanceInArenaWallet;

  /// No description provided for @availableBalanceInMainWallet.
  ///
  /// In en, this message translates to:
  /// **'Available Balance in Main Wallet'**
  String get availableBalanceInMainWallet;

  /// No description provided for @league.
  ///
  /// In en, this message translates to:
  /// **'League'**
  String get league;

  /// No description provided for @winnerPlace.
  ///
  /// In en, this message translates to:
  /// **'Winner Place'**
  String get winnerPlace;

  /// No description provided for @priceAmount.
  ///
  /// In en, this message translates to:
  /// **'Price Amount'**
  String get priceAmount;

  /// No description provided for @estimatedBalance.
  ///
  /// In en, this message translates to:
  /// **'Estimated Balance'**
  String get estimatedBalance;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @nickNameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Your new nickname matches your current one. Please enter a different nickname.'**
  String get nickNameAlreadyExists;

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File is too large. Max size is 10MB'**
  String get fileTooLarge;

  /// No description provided for @signupTime.
  ///
  /// In en, this message translates to:
  /// **'Sign-up Time'**
  String get signupTime;

  /// No description provided for @kycStatus.
  ///
  /// In en, this message translates to:
  /// **'KYC Status'**
  String get kycStatus;

  /// No description provided for @wallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter the Amount'**
  String get enterAmount;

  /// No description provided for @linkGoogleAuth.
  ///
  /// In en, this message translates to:
  /// **'Link Google Authenticator'**
  String get linkGoogleAuth;

  /// No description provided for @enableLater.
  ///
  /// In en, this message translates to:
  /// **'Enable Later'**
  String get enableLater;

  /// No description provided for @protectYourFundsSubDetails.
  ///
  /// In en, this message translates to:
  /// **'Your account security level is low. Please enable at least one more verification mode.'**
  String get protectYourFundsSubDetails;

  /// No description provided for @securityReminder.
  ///
  /// In en, this message translates to:
  /// **'Security Reminder'**
  String get securityReminder;

  /// No description provided for @marketTrades.
  ///
  /// In en, this message translates to:
  /// **'Market Trades'**
  String get marketTrades;

  /// No description provided for @telegramLogin.
  ///
  /// In en, this message translates to:
  /// **'Telegram Login'**
  String get telegramLogin;

  /// No description provided for @fromDateToDateNotBeSame.
  ///
  /// In en, this message translates to:
  /// **'To Date is greater than or equal to From Date'**
  String get fromDateToDateNotBeSame;

  /// No description provided for @feeBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Fee Breakdown'**
  String get feeBreakdown;

  /// No description provided for @spotTradingFee.
  ///
  /// In en, this message translates to:
  /// **'Spot Trading Fee'**
  String get spotTradingFee;

  /// No description provided for @futuresTradingFee.
  ///
  /// In en, this message translates to:
  /// **'Futures Trading Fee'**
  String get futuresTradingFee;

  /// No description provided for @depositWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Deposit Withdrawal'**
  String get depositWithdrawal;

  /// No description provided for @allPairs.
  ///
  /// In en, this message translates to:
  /// **'All Pairs'**
  String get allPairs;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @whatIsAnAntiPhishingCode.
  ///
  /// In en, this message translates to:
  /// **'What is an anti-phishing code?'**
  String get whatIsAnAntiPhishingCode;

  /// No description provided for @whatIsAnAntiPhishingCodeAns.
  ///
  /// In en, this message translates to:
  /// **'An anti-phishing code is a string of characters that you can set to help distinguish between a genuine and a fraudulent Bitlon website/email.'**
  String get whatIsAnAntiPhishingCodeAns;

  /// No description provided for @whereTheAntiPhishingCodeAppear.
  ///
  /// In en, this message translates to:
  /// **'Where will the anti-phishing code appear?'**
  String get whereTheAntiPhishingCodeAppear;

  /// No description provided for @whereTheAntiPhishingCodeAppearAns.
  ///
  /// In en, this message translates to:
  /// **'Once you have set your anti-phishing code, all official email correspondences from Bitlon should contain an image of your anti-phishing code. If the code in the email does not match your actual code, you may have received a phishing email \n\n*As shown in the figure below'**
  String get whereTheAntiPhishingCodeAppearAns;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @enterYourGoogleVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter google authentication code'**
  String get enterYourGoogleVerificationCode;

  /// No description provided for @spotTradingFeeInfo.
  ///
  /// In en, this message translates to:
  /// **'These rates apply to most trading pairs. Actual fees may vary.'**
  String get spotTradingFeeInfo;

  /// No description provided for @depositFee.
  ///
  /// In en, this message translates to:
  /// **'Deposit Fee'**
  String get depositFee;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @minWithdrawalAmount.
  ///
  /// In en, this message translates to:
  /// **'Minimum Withdrawal Amount'**
  String get minWithdrawalAmount;

  /// No description provided for @token.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get token;

  /// No description provided for @aboutBitlon.
  ///
  /// In en, this message translates to:
  /// **'About Bitlon'**
  String get aboutBitlon;

  /// No description provided for @aboutUsParaOne.
  ///
  /// In en, this message translates to:
  /// **'Founded in 2025, Bitlon Global Sociedad de Responsabilidad Limitada is a next-generation global digital asset exchange established to redefine trust, transparency, and technology in cryptocurrency trading.'**
  String get aboutUsParaOne;

  /// No description provided for @aboutUsParaTwo.
  ///
  /// In en, this message translates to:
  /// **'Headquartered in San José, Escazú, Costa Rica, Bitlon operates under the El Salvador VASP (Virtual Asset Service Provider) License and holds MiCA (Markets in Crypto-Assets) compliance certification in the European Union, ensuring a secure and fully regulated trading environment for users worldwide.'**
  String get aboutUsParaTwo;

  /// No description provided for @ourVision.
  ///
  /// In en, this message translates to:
  /// **'Our Vision'**
  String get ourVision;

  /// No description provided for @ourVisionPara.
  ///
  /// In en, this message translates to:
  /// **'Guided by the philosophy “The Fortress of Finance — In Your Hands”, Bitlon aims to create a safe, transparent, and empowering digital-asset ecosystem. We are dedicated to transforming financial experiences and enabling users to trade freely, confidently, and intelligently within a modern Web3-driven landscape.'**
  String get ourVisionPara;

  /// No description provided for @coreValues.
  ///
  /// In en, this message translates to:
  /// **'Core Values'**
  String get coreValues;

  /// No description provided for @valueText.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valueText;

  /// No description provided for @margin.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get margin;

  /// No description provided for @openLong.
  ///
  /// In en, this message translates to:
  /// **'Open Long'**
  String get openLong;

  /// No description provided for @openShort.
  ///
  /// In en, this message translates to:
  /// **'Open Short'**
  String get openShort;

  /// No description provided for @feeLevel.
  ///
  /// In en, this message translates to:
  /// **'Fee Level'**
  String get feeLevel;

  /// No description provided for @maker.
  ///
  /// In en, this message translates to:
  /// **'Maker'**
  String get maker;

  /// No description provided for @taker.
  ///
  /// In en, this message translates to:
  /// **'Taker'**
  String get taker;

  /// No description provided for @openPositions.
  ///
  /// In en, this message translates to:
  /// **'Open Positions'**
  String get openPositions;

  /// No description provided for @openOrders.
  ///
  /// In en, this message translates to:
  /// **'Open Orders'**
  String get openOrders;

  /// No description provided for @tradingPair.
  ///
  /// In en, this message translates to:
  /// **'Trading Pair'**
  String get tradingPair;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @avgEntryPrice.
  ///
  /// In en, this message translates to:
  /// **'Avg. Entry Price'**
  String get avgEntryPrice;

  /// No description provided for @fairPrice.
  ///
  /// In en, this message translates to:
  /// **'Fair Price'**
  String get fairPrice;

  /// No description provided for @marginRatio.
  ///
  /// In en, this message translates to:
  /// **'Margin Ratio'**
  String get marginRatio;

  /// No description provided for @cross.
  ///
  /// In en, this message translates to:
  /// **'Cross'**
  String get cross;

  /// No description provided for @realizedPNL.
  ///
  /// In en, this message translates to:
  /// **'Realized PNL'**
  String get realizedPNL;

  /// No description provided for @marketCloseAll.
  ///
  /// In en, this message translates to:
  /// **'Market Close All'**
  String get marketCloseAll;

  /// No description provided for @flashClose.
  ///
  /// In en, this message translates to:
  /// **'Flash Close'**
  String get flashClose;

  /// No description provided for @tpsl.
  ///
  /// In en, this message translates to:
  /// **'TP/SL'**
  String get tpsl;

  /// No description provided for @reverse.
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get reverse;

  /// No description provided for @closeLong.
  ///
  /// In en, this message translates to:
  /// **'Close Long'**
  String get closeLong;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @estLiqPrice.
  ///
  /// In en, this message translates to:
  /// **'Est. Liq.price'**
  String get estLiqPrice;

  /// No description provided for @long.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get long;

  /// No description provided for @short.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get short;

  /// No description provided for @limitOrMarket.
  ///
  /// In en, this message translates to:
  /// **'Limit/Market'**
  String get limitOrMarket;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @tpTriggerPrice.
  ///
  /// In en, this message translates to:
  /// **'TP Trigger Price'**
  String get tpTriggerPrice;

  /// No description provided for @estimatedPnl.
  ///
  /// In en, this message translates to:
  /// **'Estimated PNL'**
  String get estimatedPnl;

  /// No description provided for @noRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No Records Found'**
  String get noRecordsFound;

  /// No description provided for @myOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'My Order History'**
  String get myOrderHistory;

  /// No description provided for @tradeHistory.
  ///
  /// In en, this message translates to:
  /// **'Trade History'**
  String get tradeHistory;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received Withdraw Amount'**
  String get received;

  /// No description provided for @atLeastOneUppercase.
  ///
  /// In en, this message translates to:
  /// **'At least One Uppercase'**
  String get atLeastOneUppercase;

  /// No description provided for @atLeastOneUppercaseEg.
  ///
  /// In en, this message translates to:
  /// **'(Ex: A,B,C..etc)'**
  String get atLeastOneUppercaseEg;

  /// No description provided for @atLeastOneLowercase.
  ///
  /// In en, this message translates to:
  /// **'At least One Lowercase'**
  String get atLeastOneLowercase;

  /// No description provided for @atLeastOneLowercaseEg.
  ///
  /// In en, this message translates to:
  /// **'(Ex: a,b,c..etc)'**
  String get atLeastOneLowercaseEg;

  /// No description provided for @atLeastNumericDigit.
  ///
  /// In en, this message translates to:
  /// **'At least Numeric Digit'**
  String get atLeastNumericDigit;

  /// No description provided for @atLeastNumericDigitEg.
  ///
  /// In en, this message translates to:
  /// **'(Ex: 1,2,3..etc)'**
  String get atLeastNumericDigitEg;

  /// No description provided for @atLeastOneSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'At least One Special Character'**
  String get atLeastOneSpecialCharacter;

  /// No description provided for @atLeastOneSpecialCharacterEg.
  ///
  /// In en, this message translates to:
  /// **'(!@#\\\$%^&*)'**
  String get atLeastOneSpecialCharacterEg;

  /// No description provided for @joinTheZayroAffiliateProgram.
  ///
  /// In en, this message translates to:
  /// **'Join the Zayro Affiliate Program'**
  String get joinTheZayroAffiliateProgram;

  /// No description provided for @yourAffiliateType.
  ///
  /// In en, this message translates to:
  /// **'Your Affiliate Type'**
  String get yourAffiliateType;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get contactInfo;

  /// No description provided for @whichCountryOrRegionDoYouPlanOnMarketingIn.
  ///
  /// In en, this message translates to:
  /// **'Which country or region do you plan on marketing in?'**
  String get whichCountryOrRegionDoYouPlanOnMarketingIn;

  /// No description provided for @primaryPromoPlatform.
  ///
  /// In en, this message translates to:
  /// **'Primary Promo Platform'**
  String get primaryPromoPlatform;

  /// No description provided for @isThereAnythingElseThatYouWouldLikeToShare.
  ///
  /// In en, this message translates to:
  /// **'Is there anything else that you would like to share?'**
  String get isThereAnythingElseThatYouWouldLikeToShare;

  /// No description provided for @howDidYouHearAboutZayroPlatform.
  ///
  /// In en, this message translates to:
  /// **'How did you hear about Zayro Platform?'**
  String get howDidYouHearAboutZayroPlatform;

  /// No description provided for @selectYourAffiliateType.
  ///
  /// In en, this message translates to:
  /// **'Select Your Affiliate Type'**
  String get selectYourAffiliateType;

  /// No description provided for @selectYourCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Your Country'**
  String get selectYourCountry;

  /// No description provided for @selectPrimaryPromoPlatformType.
  ///
  /// In en, this message translates to:
  /// **'Select Primary Promo Platform Type'**
  String get selectPrimaryPromoPlatformType;

  /// No description provided for @selectYourZayroPlatform.
  ///
  /// In en, this message translates to:
  /// **'Select Your Zayro Platform'**
  String get selectYourZayroPlatform;

  /// No description provided for @selectYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Your Language'**
  String get selectYourLanguage;

  /// No description provided for @otherSocialMediaPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Other Social Media Platforms'**
  String get otherSocialMediaPlatforms;

  /// No description provided for @twitter.
  ///
  /// In en, this message translates to:
  /// **'Twitter'**
  String get twitter;

  /// No description provided for @telegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get telegram;

  /// No description provided for @youTube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get youTube;

  /// No description provided for @discord.
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get discord;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @linkedIn.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get linkedIn;

  /// No description provided for @twitch.
  ///
  /// In en, this message translates to:
  /// **'Twitch'**
  String get twitch;

  /// No description provided for @blog.
  ///
  /// In en, this message translates to:
  /// **'Blog'**
  String get blog;

  /// No description provided for @cryptoInfluencerIndividual.
  ///
  /// In en, this message translates to:
  /// **'Crypto influencer (Individual)'**
  String get cryptoInfluencerIndividual;

  /// No description provided for @socialMediaInfluencerNonCryptoCommunity.
  ///
  /// In en, this message translates to:
  /// **'Social Media influencer (Non-Crypto Community)'**
  String get socialMediaInfluencerNonCryptoCommunity;

  /// No description provided for @developerTradingTools.
  ///
  /// In en, this message translates to:
  /// **'Developer / Trading Tools'**
  String get developerTradingTools;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @zayroWebSite.
  ///
  /// In en, this message translates to:
  /// **'Zayro WebSite'**
  String get zayroWebSite;

  /// No description provided for @anotherAffiliate.
  ///
  /// In en, this message translates to:
  /// **'Another Affiliate'**
  String get anotherAffiliate;

  /// No description provided for @zayroInstagram.
  ///
  /// In en, this message translates to:
  /// **'Zayro Instagram'**
  String get zayroInstagram;

  /// No description provided for @zayroTelegram.
  ///
  /// In en, this message translates to:
  /// **'Zayro Telegram'**
  String get zayroTelegram;

  /// No description provided for @india.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get india;

  /// No description provided for @usa.
  ///
  /// In en, this message translates to:
  /// **'USA'**
  String get usa;

  /// No description provided for @uk.
  ///
  /// In en, this message translates to:
  /// **'UK'**
  String get uk;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @additionalCommentsRequired.
  ///
  /// In en, this message translates to:
  /// **'Additional Comments is required.'**
  String get additionalCommentsRequired;

  /// No description provided for @additionalCommentsRequiredFormat.
  ///
  /// In en, this message translates to:
  /// **'3–20 chars: Letters, Numbers, Dot, Underscore only.'**
  String get additionalCommentsRequiredFormat;

  /// No description provided for @contactInfoRequired.
  ///
  /// In en, this message translates to:
  /// **'contact Info is required.'**
  String get contactInfoRequired;

  /// No description provided for @contactInfoRequiredFormat.
  ///
  /// In en, this message translates to:
  /// **'3–20 chars: Letters, Numbers, Dot, Underscore only.'**
  String get contactInfoRequiredFormat;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @perpetualTrade.
  ///
  /// In en, this message translates to:
  /// **'Perpetual Trade'**
  String get perpetualTrade;

  /// No description provided for @rewardsHub.
  ///
  /// In en, this message translates to:
  /// **'Rewards Hub'**
  String get rewardsHub;

  /// No description provided for @perpetualOpenOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'Perpetual Open Order History'**
  String get perpetualOpenOrderHistory;

  /// No description provided for @perpetualMyOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'Perpetual My Order History'**
  String get perpetualMyOrderHistory;

  /// No description provided for @perpetualClosedPnl.
  ///
  /// In en, this message translates to:
  /// **'Perpetual Closed P&L'**
  String get perpetualClosedPnl;

  /// No description provided for @selectPair.
  ///
  /// In en, this message translates to:
  /// **'Select Pair'**
  String get selectPair;

  /// No description provided for @positions.
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get positions;

  /// No description provided for @perpetual.
  ///
  /// In en, this message translates to:
  /// **'Perpetual'**
  String get perpetual;

  /// No description provided for @futures.
  ///
  /// In en, this message translates to:
  /// **'Futures'**
  String get futures;

  /// No description provided for @buyLong.
  ///
  /// In en, this message translates to:
  /// **'Buy/Long'**
  String get buyLong;

  /// No description provided for @sellShort.
  ///
  /// In en, this message translates to:
  /// **'Sell/Short'**
  String get sellShort;

  /// No description provided for @selectOrderType.
  ///
  /// In en, this message translates to:
  /// **'Select Order type'**
  String get selectOrderType;

  /// No description provided for @orderTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select order type'**
  String get orderTypeRequired;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @last.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get last;

  /// No description provided for @contactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetails;

  /// No description provided for @expirationDate.
  ///
  /// In en, this message translates to:
  /// **'Expiration Date'**
  String get expirationDate;

  /// No description provided for @markPrice.
  ///
  /// In en, this message translates to:
  /// **'Mark Price'**
  String get markPrice;

  /// No description provided for @openInterest.
  ///
  /// In en, this message translates to:
  /// **'Open Interest'**
  String get openInterest;

  /// No description provided for @adjustMarginMode.
  ///
  /// In en, this message translates to:
  /// **'Adjust Margin Mode'**
  String get adjustMarginMode;

  /// No description provided for @crossMarginMode.
  ///
  /// In en, this message translates to:
  /// **'Cross Margin Mode'**
  String get crossMarginMode;

  /// No description provided for @crossModeDescription.
  ///
  /// In en, this message translates to:
  /// **'All cross position under the same margin asset share the same asset cross margin balance in the event of liquidation, your asset full margin balance along with any remaining open positions under the asset may be forfeited.'**
  String get crossModeDescription;

  /// No description provided for @isolatedMarginMode.
  ///
  /// In en, this message translates to:
  /// **'Isolated Margin Mode'**
  String get isolatedMarginMode;

  /// No description provided for @isolatedModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your risk on individual positions by restricting the amount of margin allocated to each. If the margin ratio of a position reaches 100% the position will be liquidated. Margin can be added or removed from position using this mode.'**
  String get isolatedModeDescription;

  /// No description provided for @leverageWarning.
  ///
  /// In en, this message translates to:
  /// **'The current leverage is too high. There is a high risk of immediate liquidation. Please adjust your position'**
  String get leverageWarning;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @pleaseVerifyBeforeConfirming.
  ///
  /// In en, this message translates to:
  /// **'Please verify before confirming.'**
  String get pleaseVerifyBeforeConfirming;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @orderIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Order ID copied to clipboard!'**
  String get orderIdCopied;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @cancelMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel order?'**
  String get cancelMessage;

  /// No description provided for @editTpSl.
  ///
  /// In en, this message translates to:
  /// **'Edit TP/SL'**
  String get editTpSl;

  /// No description provided for @closeQuantityCannotExceed.
  ///
  /// In en, this message translates to:
  /// **'Close quantity cannot exceed'**
  String get closeQuantityCannotExceed;

  /// No description provided for @qtyRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required'**
  String get qtyRequired;

  /// No description provided for @qtyShouldNotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be greater than 0'**
  String get qtyShouldNotBeZero;

  /// No description provided for @closeQtyBy.
  ///
  /// In en, this message translates to:
  /// **'Close Qty by'**
  String get closeQtyBy;

  /// No description provided for @contractClosedAtLastTradedPrice.
  ///
  /// In en, this message translates to:
  /// **'Contract(s) will be closed at last traded price'**
  String get contractClosedAtLastTradedPrice;

  /// No description provided for @closeByMarket.
  ///
  /// In en, this message translates to:
  /// **'Close By Market'**
  String get closeByMarket;

  /// No description provided for @closePriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Close Price is required'**
  String get closePriceRequired;

  /// No description provided for @closePriceShouldNotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Close Price must be greater than 0'**
  String get closePriceShouldNotBeZero;

  /// No description provided for @closePriceBy.
  ///
  /// In en, this message translates to:
  /// **'Close Price by'**
  String get closePriceBy;

  /// No description provided for @contractsWillClosedAt.
  ///
  /// In en, this message translates to:
  /// **'Contract(s) will be closed at'**
  String get contractsWillClosedAt;

  /// No description provided for @closeByLimit.
  ///
  /// In en, this message translates to:
  /// **'Close By Limit'**
  String get closeByLimit;

  /// No description provided for @depositIntoAccount.
  ///
  /// In en, this message translates to:
  /// **'Deposit Funds into your Account'**
  String get depositIntoAccount;

  /// No description provided for @depositCrypto.
  ///
  /// In en, this message translates to:
  /// **'Deposit Crypto'**
  String get depositCrypto;

  /// No description provided for @depositCryptoDetails.
  ///
  /// In en, this message translates to:
  /// **'Already own cryptocurrency? Easily move your assets from external wallets or other trading platforms directly into your account using the deposit feature.'**
  String get depositCryptoDetails;

  /// No description provided for @express.
  ///
  /// In en, this message translates to:
  /// **'Express'**
  String get express;

  /// No description provided for @expressDetails.
  ///
  /// In en, this message translates to:
  /// **'Looking to purchase crypto instantly with cash? The Express option offers the quickest and most convenient way to get started.'**
  String get expressDetails;

  /// No description provided for @importantNotice.
  ///
  /// In en, this message translates to:
  /// **'Important Notice'**
  String get importantNotice;

  /// No description provided for @withdrawingFirstContent.
  ///
  /// In en, this message translates to:
  /// **'Please review the following guidelines before depositing or withdrawing digital assets:'**
  String get withdrawingFirstContent;

  /// No description provided for @withdrawingSecondContent.
  ///
  /// In en, this message translates to:
  /// **'Ensure your wallet address and selected network are entered correctly.'**
  String get withdrawingSecondContent;

  /// No description provided for @withdrawingThirdContent.
  ///
  /// In en, this message translates to:
  /// **'Avoid direct deposits or withdrawals from exchanges operating in high-risk or non-FATF-compliant countries. Using an intermediary wallet is recommended.'**
  String get withdrawingThirdContent;

  /// No description provided for @withdrawingFourthContent.
  ///
  /// In en, this message translates to:
  /// **'If such transactions occur, Zayro will not restrict your account but will notify you via email to help prevent future issues.'**
  String get withdrawingFourthContent;

  /// No description provided for @acknowledge.
  ///
  /// In en, this message translates to:
  /// **'I acknowledge and agree to the '**
  String get acknowledge;

  /// No description provided for @acknowledgeContent.
  ///
  /// In en, this message translates to:
  /// **'Deposit & Withdrawal Risk Notice.'**
  String get acknowledgeContent;

  /// No description provided for @yesterdayProfit.
  ///
  /// In en, this message translates to:
  /// **'Yesterday\'s Profit (USDT)'**
  String get yesterdayProfit;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get saving;

  /// No description provided for @growYour.
  ///
  /// In en, this message translates to:
  /// **'Grow your crypto daily, withdraw anytime!'**
  String get growYour;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @estAPR.
  ///
  /// In en, this message translates to:
  /// **'Est. APR'**
  String get estAPR;

  /// No description provided for @term.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get term;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @investNow.
  ///
  /// In en, this message translates to:
  /// **'Invest Now'**
  String get investNow;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @savingHistory.
  ///
  /// In en, this message translates to:
  /// **'Saving History'**
  String get savingHistory;

  /// No description provided for @currentHolding.
  ///
  /// In en, this message translates to:
  /// **'Current Holding'**
  String get currentHolding;

  /// No description provided for @historicalHolding.
  ///
  /// In en, this message translates to:
  /// **'Historical Holding'**
  String get historicalHolding;

  /// No description provided for @asset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get asset;

  /// No description provided for @pleaseEnterStackAmount.
  ///
  /// In en, this message translates to:
  /// **'Please Enter Stack Amount'**
  String get pleaseEnterStackAmount;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @yourCurrentInvestedAmount.
  ///
  /// In en, this message translates to:
  /// **'Your Current Invested Amount'**
  String get yourCurrentInvestedAmount;

  /// No description provided for @estimatedEarnings.
  ///
  /// In en, this message translates to:
  /// **'Estimated Earnings'**
  String get estimatedEarnings;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @subscriptionDate.
  ///
  /// In en, this message translates to:
  /// **'Subscription Date'**
  String get subscriptionDate;

  /// No description provided for @interestStartDate.
  ///
  /// In en, this message translates to:
  /// **'Interest Start Date'**
  String get interestStartDate;

  /// No description provided for @interestPeriod.
  ///
  /// In en, this message translates to:
  /// **'Interest Period'**
  String get interestPeriod;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @interestPaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Interest Payment Date'**
  String get interestPaymentDate;

  /// No description provided for @iHaveReadAgreedToThe.
  ///
  /// In en, this message translates to:
  /// **'I have read & agreed to the'**
  String get iHaveReadAgreedToThe;

  /// No description provided for @zayroSimpleEarnServiceTermsCondition.
  ///
  /// In en, this message translates to:
  /// **'Zayro Simple Earn Service Terms & Condition'**
  String get zayroSimpleEarnServiceTermsCondition;

  /// No description provided for @calculateYourCryptoEarnings.
  ///
  /// In en, this message translates to:
  /// **'Calculate your crypto earnings'**
  String get calculateYourCryptoEarnings;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get allProducts;

  /// No description provided for @chooseCrypto.
  ///
  /// In en, this message translates to:
  /// **'Choose Crypto'**
  String get chooseCrypto;

  /// No description provided for @investmentType.
  ///
  /// In en, this message translates to:
  /// **'Investment Type'**
  String get investmentType;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'APR'**
  String get apr;

  /// No description provided for @flexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get flexible;

  /// No description provided for @unlockDate.
  ///
  /// In en, this message translates to:
  /// **'Unlock Date'**
  String get unlockDate;

  /// No description provided for @estAPY.
  ///
  /// In en, this message translates to:
  /// **'Est. APY'**
  String get estAPY;

  /// No description provided for @interestReceived.
  ///
  /// In en, this message translates to:
  /// **'Interest Received'**
  String get interestReceived;

  /// No description provided for @interestEstimated.
  ///
  /// In en, this message translates to:
  /// **'Interest Estimated'**
  String get interestEstimated;

  /// No description provided for @subscribeDate.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Date'**
  String get subscribeDate;

  /// No description provided for @referralOption.
  ///
  /// In en, this message translates to:
  /// **'Referral Option'**
  String get referralOption;

  /// No description provided for @enterReferralId.
  ///
  /// In en, this message translates to:
  /// **'Enter Referral Id'**
  String get enterReferralId;

  /// No description provided for @takeProfitShouldBeGreaterThanLivePrice.
  ///
  /// In en, this message translates to:
  /// **'Take Profit must be the higher than the Last Traded Price.'**
  String get takeProfitShouldBeGreaterThanLivePrice;

  /// No description provided for @stopLossShouldBeLessThanLivePrice.
  ///
  /// In en, this message translates to:
  /// **'Stop Loss must be the lower than the Last Traded Price.'**
  String get stopLossShouldBeLessThanLivePrice;

  /// No description provided for @takeProfitShouldBeLessThanLivePrice.
  ///
  /// In en, this message translates to:
  /// **'Take Profit must be the lower than the Last Traded Price.'**
  String get takeProfitShouldBeLessThanLivePrice;

  /// No description provided for @stopLossShouldBeGreaterThanLivePrice.
  ///
  /// In en, this message translates to:
  /// **'Stop Loss must be the higher than the Last Traded Price.'**
  String get stopLossShouldBeGreaterThanLivePrice;

  /// No description provided for @nohistoryFound.
  ///
  /// In en, this message translates to:
  /// **'No History Found'**
  String get nohistoryFound;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark As Read'**
  String get markAsRead;

  /// No description provided for @planType.
  ///
  /// In en, this message translates to:
  /// **'Plan Type'**
  String get planType;

  /// No description provided for @cancelledDate.
  ///
  /// In en, this message translates to:
  /// **'Cancelled Date'**
  String get cancelledDate;

  /// No description provided for @tokenExpired.
  ///
  /// In en, this message translates to:
  /// **'Token expired. Please refresh or login again'**
  String get tokenExpired;

  /// No description provided for @pleaseUpload.
  ///
  /// In en, this message translates to:
  /// **'Please select an image to upload.'**
  String get pleaseUpload;

  /// No description provided for @mpinRequired.
  ///
  /// In en, this message translates to:
  /// **'MPIN is required'**
  String get mpinRequired;

  /// No description provided for @mpinMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'MPIN must be 6-digits'**
  String get mpinMustBe6Digits;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @tapBelowViewImage.
  ///
  /// In en, this message translates to:
  /// **'Tap below to view the uploaded image.'**
  String get tapBelowViewImage;

  /// No description provided for @pleaseSelectUpload.
  ///
  /// In en, this message translates to:
  /// **'Please select an option to upload'**
  String get pleaseSelectUpload;

  /// No description provided for @orView.
  ///
  /// In en, this message translates to:
  /// **'or view'**
  String get orView;

  /// No description provided for @theImage.
  ///
  /// In en, this message translates to:
  /// **'the image.'**
  String get theImage;

  /// No description provided for @imageSizeExceeds.
  ///
  /// In en, this message translates to:
  /// **'Image size exceeds the maximum allowed size of'**
  String get imageSizeExceeds;

  /// No description provided for @mb.
  ///
  /// In en, this message translates to:
  /// **'MB.'**
  String get mb;

  /// No description provided for @thisFileAppears.
  ///
  /// In en, this message translates to:
  /// **'This file appears to be encrypted.Please select another image.'**
  String get thisFileAppears;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @titleIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleIsRequired;

  /// No description provided for @titleMustLeastCharacters.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 5 characters'**
  String get titleMustLeastCharacters;

  /// No description provided for @titleExceedCharacters.
  ///
  /// In en, this message translates to:
  /// **'Title must not exceed 100 characters'**
  String get titleExceedCharacters;

  /// No description provided for @messageIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Message is required'**
  String get messageIsRequired;

  /// No description provided for @messageMustLeastCharacters.
  ///
  /// In en, this message translates to:
  /// **'Message must be at least 10 characters'**
  String get messageMustLeastCharacters;

  /// No description provided for @messageExceedCharacters.
  ///
  /// In en, this message translates to:
  /// **'Message must not exceed 1000 characters'**
  String get messageExceedCharacters;

  /// No description provided for @orderBookDepth.
  ///
  /// In en, this message translates to:
  /// **'Order book depth'**
  String get orderBookDepth;

  /// No description provided for @liqPrice.
  ///
  /// In en, this message translates to:
  /// **'Liq. Price'**
  String get liqPrice;

  /// No description provided for @leverageMaxAlert.
  ///
  /// In en, this message translates to:
  /// **'Leverage cannot exceed 100'**
  String get leverageMaxAlert;

  /// No description provided for @coin.
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get coin;

  /// No description provided for @selectWallet.
  ///
  /// In en, this message translates to:
  /// **'Select Wallet'**
  String get selectWallet;

  /// No description provided for @availableBalanceIs.
  ///
  /// In en, this message translates to:
  /// **'Your available amount is'**
  String get availableBalanceIs;

  /// No description provided for @transferDescription.
  ///
  /// In en, this message translates to:
  /// **'Transfers between Spot and Future are considered internal and completely free of charge. These transactions are executed instantly, so you can move your funds seamlessly.'**
  String get transferDescription;

  /// No description provided for @filledOrderTotal.
  ///
  /// In en, this message translates to:
  /// **'Filled / Order Total'**
  String get filledOrderTotal;

  /// No description provided for @filledOrderAmount.
  ///
  /// In en, this message translates to:
  /// **'Filled / Order Amount'**
  String get filledOrderAmount;

  /// No description provided for @spotMarketBuy.
  ///
  /// In en, this message translates to:
  /// **'Spot Market Buy'**
  String get spotMarketBuy;

  /// No description provided for @spotMarketSell.
  ///
  /// In en, this message translates to:
  /// **'Spot Market Sell'**
  String get spotMarketSell;

  /// No description provided for @spotLimitBuy.
  ///
  /// In en, this message translates to:
  /// **'Spot Limit Buy'**
  String get spotLimitBuy;

  /// No description provided for @spotLimitSell.
  ///
  /// In en, this message translates to:
  /// **'Spot Limit Sell'**
  String get spotLimitSell;

  /// No description provided for @depth.
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get depth;

  /// No description provided for @airdropDetails.
  ///
  /// In en, this message translates to:
  /// **'Airdrop Details'**
  String get airdropDetails;

  /// No description provided for @tokenName.
  ///
  /// In en, this message translates to:
  /// **'Token Name'**
  String get tokenName;

  /// No description provided for @uSDT.
  ///
  /// In en, this message translates to:
  /// **'USDT'**
  String get uSDT;

  /// No description provided for @airdropAmount.
  ///
  /// In en, this message translates to:
  /// **'Airdrop Amount'**
  String get airdropAmount;

  /// No description provided for @maxPerUser.
  ///
  /// In en, this message translates to:
  /// **'Max Per User'**
  String get maxPerUser;

  /// No description provided for @eligibility.
  ///
  /// In en, this message translates to:
  /// **'Eligibility'**
  String get eligibility;

  /// No description provided for @completeLeastTasks.
  ///
  /// In en, this message translates to:
  /// **'Complete At Least 3 Tasks'**
  String get completeLeastTasks;

  /// No description provided for @distributionDate.
  ///
  /// In en, this message translates to:
  /// **'Distribution Date'**
  String get distributionDate;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June 6, 2025'**
  String get june;

  /// No description provided for @rewardsRules.
  ///
  /// In en, this message translates to:
  /// **'Rewards Rules'**
  String get rewardsRules;

  /// No description provided for @rules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rules;

  /// No description provided for @eachParticipantVerification.
  ///
  /// In en, this message translates to:
  /// **'• Each participant must complete KYC verification.\n'**
  String get eachParticipantVerification;

  /// No description provided for @rewardsDistributedBasis.
  ///
  /// In en, this message translates to:
  /// **'• Rewards distributed on first-come basis.\n'**
  String get rewardsDistributedBasis;

  /// No description provided for @oneUserAllowed.
  ///
  /// In en, this message translates to:
  /// **'• One account per user allowed.\n'**
  String get oneUserAllowed;

  /// No description provided for @suspiciousActivityDisqualification.
  ///
  /// In en, this message translates to:
  /// **'• Suspicious activity leads to disqualification.\n'**
  String get suspiciousActivityDisqualification;

  /// No description provided for @rewardsDistributedDays.
  ///
  /// In en, this message translates to:
  /// **'• Rewards distributed within 7 days.\n'**
  String get rewardsDistributedDays;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsConditions;

  /// No description provided for @participationSubjectVerification1Approval.
  ///
  /// In en, this message translates to:
  /// **'Participation is subject to verification and approval. '**
  String get participationSubjectVerification1Approval;

  /// No description provided for @companyReservesCancelCampaign.
  ///
  /// In en, this message translates to:
  /// **'Company reserves the right to modify or cancel the campaign. '**
  String get companyReservesCancelCampaign;

  /// No description provided for @tokensOfficiallyListed.
  ///
  /// In en, this message translates to:
  /// **'Tokens have no monetary value until officially listed.'**
  String get tokensOfficiallyListed;

  /// No description provided for @assetsBalance.
  ///
  /// In en, this message translates to:
  /// **'Assets Balance'**
  String get assetsBalance;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @riskWarning.
  ///
  /// In en, this message translates to:
  /// **'Risk Warning'**
  String get riskWarning;

  /// No description provided for @riskWarningContent.
  ///
  /// In en, this message translates to:
  /// **'Cryptocurrency investments are subject to market risks. The value of tokens may fluctuate and past performance is not a guarantee of future returns. Zayro does not guarantee profits or specific outcomes. Always conduct your own research and consult with a financial advisor before making investment decisions.'**
  String get riskWarningContent;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// No description provided for @daysCountdown.
  ///
  /// In en, this message translates to:
  /// **'365 Days Countdown'**
  String get daysCountdown;

  /// No description provided for @addressNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Address not available'**
  String get addressNotAvailable;

  /// No description provided for @bioIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Bio is required'**
  String get bioIsRequired;

  /// No description provided for @bioTooShort.
  ///
  /// In en, this message translates to:
  /// **'Bio must be at least 5 characters'**
  String get bioTooShort;

  /// No description provided for @bioTooLong.
  ///
  /// In en, this message translates to:
  /// **'Bio must be less than 150 characters'**
  String get bioTooLong;

  /// No description provided for @bioInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid bio format'**
  String get bioInvalidFormat;

  /// No description provided for @kycRequiredGenerate.
  ///
  /// In en, this message translates to:
  /// **'KYC is required to generate a deposit address. Complete KYC'**
  String get kycRequiredGenerate;

  /// No description provided for @withdrawalNotAvailableForThisCrypto.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal is not available for this cryptocurrency. Please choose another one.'**
  String get withdrawalNotAvailableForThisCrypto;

  /// No description provided for @depositNotAvailableForThisCrypto.
  ///
  /// In en, this message translates to:
  /// **'Deposit is not available for this cryptocurrency. Please choose another one.'**
  String get depositNotAvailableForThisCrypto;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @welcomeZayroExchange.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Zayro Exchange'**
  String get welcomeZayroExchange;

  /// No description provided for @countryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a country'**
  String get countryRequired;

  /// No description provided for @documentTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a document type'**
  String get documentTypeRequired;

  /// No description provided for @documentTypeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid document type selected'**
  String get documentTypeInvalid;

  /// No description provided for @dateBirthRequired.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required'**
  String get dateBirthRequired;

  /// No description provided for @yourInvitationCode.
  ///
  /// In en, this message translates to:
  /// **'Your Invitation Code'**
  String get yourInvitationCode;

  /// No description provided for @referralSubText.
  ///
  /// In en, this message translates to:
  /// **'Share this code with friends. Referrals are counted only after full verification.'**
  String get referralSubText;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @keys.
  ///
  /// In en, this message translates to:
  /// **'Keys'**
  String get keys;

  /// No description provided for @avatars.
  ///
  /// In en, this message translates to:
  /// **'Avatars'**
  String get avatars;

  /// No description provided for @avatarFrames.
  ///
  /// In en, this message translates to:
  /// **'Avatar Frames'**
  String get avatarFrames;

  /// No description provided for @referralNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Referral Link Not Available'**
  String get referralNotAvailable;

  /// No description provided for @invalidReferralLink.
  ///
  /// In en, this message translates to:
  /// **'Invalid Referral Link'**
  String get invalidReferralLink;

  /// No description provided for @unableReferralLink.
  ///
  /// In en, this message translates to:
  /// **'Unable To Open Referral Link'**
  String get unableReferralLink;

  /// No description provided for @joinZayroReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Join Zayro with my referral code:'**
  String get joinZayroReferralCode;

  /// No description provided for @completeVerification.
  ///
  /// In en, this message translates to:
  /// **'Complete Kyc Verification'**
  String get completeVerification;

  /// No description provided for @stepOne.
  ///
  /// In en, this message translates to:
  /// **'Step 1 - Register & Verify Email'**
  String get stepOne;

  /// No description provided for @stepOneDesc.
  ///
  /// In en, this message translates to:
  /// **'Create your account and verify your email to receive a Blue Treasure Chest.'**
  String get stepOneDesc;

  /// No description provided for @stepTwo.
  ///
  /// In en, this message translates to:
  /// **'Step 2 - Verify Third-Party Account'**
  String get stepTwo;

  /// No description provided for @stepTwoDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete third-party verification to unlock a Red Treasure Chest.'**
  String get stepTwoDesc;

  /// No description provided for @stepThree.
  ///
  /// In en, this message translates to:
  /// **'Step 3 - Refer Friends'**
  String get stepThree;

  /// No description provided for @stepThreeDesc.
  ///
  /// In en, this message translates to:
  /// **'5 successful referrals gives you Gold Treasure Chest and a Gold Key.'**
  String get stepThreeDesc;

  /// No description provided for @blueFrame.
  ///
  /// In en, this message translates to:
  /// **'Basic Avatar\nBlue Frame'**
  String get blueFrame;

  /// No description provided for @blueFrameDec.
  ///
  /// In en, this message translates to:
  /// **'You can Find it on\nBlue Chest'**
  String get blueFrameDec;

  /// No description provided for @redFrame.
  ///
  /// In en, this message translates to:
  /// **'Advanced Red\nAvatar Frame'**
  String get redFrame;

  /// No description provided for @redFrameDec.
  ///
  /// In en, this message translates to:
  /// **'You can Find it on\nRed Chest'**
  String get redFrameDec;

  /// No description provided for @goldFrame.
  ///
  /// In en, this message translates to:
  /// **'Advanced Golden\nAvatar Frame'**
  String get goldFrame;

  /// No description provided for @goldFrameDec.
  ///
  /// In en, this message translates to:
  /// **'You can Find it on\nGold Chest'**
  String get goldFrameDec;

  /// No description provided for @blueKey.
  ///
  /// In en, this message translates to:
  /// **'Blue Key'**
  String get blueKey;

  /// No description provided for @blueKeyDec.
  ///
  /// In en, this message translates to:
  /// **'Complete 1 successful referral to get Blue Key'**
  String get blueKeyDec;

  /// No description provided for @redKey.
  ///
  /// In en, this message translates to:
  /// **'Red Key'**
  String get redKey;

  /// No description provided for @redKeyDec.
  ///
  /// In en, this message translates to:
  /// **'Complete 2 more successful referral to get Red Key'**
  String get redKeyDec;

  /// No description provided for @goldKey.
  ///
  /// In en, this message translates to:
  /// **'Gold Key'**
  String get goldKey;

  /// No description provided for @goldKeyDec.
  ///
  /// In en, this message translates to:
  /// **'Complete 2 more successful referral to get Gold Key'**
  String get goldKeyDec;

  /// No description provided for @blueRobot.
  ///
  /// In en, this message translates to:
  /// **'Advanced Blue Robot\nAvatar'**
  String get blueRobot;

  /// No description provided for @blueRobotDec.
  ///
  /// In en, this message translates to:
  /// **'You can find it on blue chest'**
  String get blueRobotDec;

  /// No description provided for @redRobot.
  ///
  /// In en, this message translates to:
  /// **'Advanced Red Robot\nAvatar'**
  String get redRobot;

  /// No description provided for @redRobotDec.
  ///
  /// In en, this message translates to:
  /// **'You can find it on Red chest'**
  String get redRobotDec;

  /// No description provided for @legendaryBlackRobotAvatarFrame.
  ///
  /// In en, this message translates to:
  /// **'Legendary Black Samurai Robot Avatar Frame'**
  String get legendaryBlackRobotAvatarFrame;

  /// No description provided for @blackFragments.
  ///
  /// In en, this message translates to:
  /// **'Black Fragments'**
  String get blackFragments;

  /// No description provided for @legendaryBlackAvatarFrame.
  ///
  /// In en, this message translates to:
  /// **'Legendary Black Samurai Avatar Frame'**
  String get legendaryBlackAvatarFrame;

  /// No description provided for @legendaryBlackRobotAvatar.
  ///
  /// In en, this message translates to:
  /// **'Legendary Black Samurai Robot Avatar'**
  String get legendaryBlackRobotAvatar;

  /// No description provided for @rareGoldenRobotAvatar.
  ///
  /// In en, this message translates to:
  /// **'Rare Golden Robot Avatar'**
  String get rareGoldenRobotAvatar;

  /// No description provided for @goldFragments.
  ///
  /// In en, this message translates to:
  /// **'Gold Fragments'**
  String get goldFragments;

  /// No description provided for @rareGoldRobotAvatar.
  ///
  /// In en, this message translates to:
  /// **'Rare Gold Robot Avatar'**
  String get rareGoldRobotAvatar;

  /// No description provided for @collect.
  ///
  /// In en, this message translates to:
  /// **'Collect'**
  String get collect;

  /// No description provided for @moreFragments.
  ///
  /// In en, this message translates to:
  /// **'More Fragments'**
  String get moreFragments;

  /// No description provided for @goldFragmentsAchieve.
  ///
  /// In en, this message translates to:
  /// **' Gold Fragments to Achieve:'**
  String get goldFragmentsAchieve;

  /// No description provided for @rareGoldenChest.
  ///
  /// In en, this message translates to:
  /// **'Rare Golden Robot Avatar'**
  String get rareGoldenChest;

  /// No description provided for @blackFragmentsAchieve.
  ///
  /// In en, this message translates to:
  /// **'Black Fragments to Achieve:'**
  String get blackFragmentsAchieve;

  /// No description provided for @blackFragmentsAchieveSub.
  ///
  /// In en, this message translates to:
  /// **'Legendary Black Samurai Robot Avatar Frame'**
  String get blackFragmentsAchieveSub;

  /// No description provided for @blackFragmentsAchieveSubTwo.
  ///
  /// In en, this message translates to:
  /// **'This is a featured reward from the Golden Chest'**
  String get blackFragmentsAchieveSubTwo;

  /// No description provided for @inviteRobotAvatarFragments.
  ///
  /// In en, this message translates to:
  /// **'Invite 3 Friends and earn'**
  String get inviteRobotAvatarFragments;

  /// No description provided for @blackSamuraiRobotAvatar.
  ///
  /// In en, this message translates to:
  /// **'Black Samurai Robot Avatar Fragments'**
  String get blackSamuraiRobotAvatar;

  /// No description provided for @theTeamworkChallenge.
  ///
  /// In en, this message translates to:
  /// **'The 90-Day Teamwork Challenge'**
  String get theTeamworkChallenge;

  /// No description provided for @viperStrike.
  ///
  /// In en, this message translates to:
  /// **'ViperStrike_99'**
  String get viperStrike;

  /// No description provided for @youHaveOpened.
  ///
  /// In en, this message translates to:
  /// **'You have opened 2 Rare \n Gold Chest opened'**
  String get youHaveOpened;

  /// No description provided for @otherParticipants.
  ///
  /// In en, this message translates to:
  /// **'Other Participants'**
  String get otherParticipants;

  /// No description provided for @earnKeysRewardsContent.
  ///
  /// In en, this message translates to:
  /// **'Earn keys by completing successful referrals. Higher-tier keys unlock better rewards.'**
  String get earnKeysRewardsContent;

  /// No description provided for @earnFrameRewardsContent.
  ///
  /// In en, this message translates to:
  /// **'Avatar frames are found in chests. Progress resets automatically after unlocking a Golden Chest.'**
  String get earnFrameRewardsContent;

  /// No description provided for @earnRobotRewardsContent.
  ///
  /// In en, this message translates to:
  /// **'Avatars can be obtained from chests. Higher-tier chests contain rarer avatars.'**
  String get earnRobotRewardsContent;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
