import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zayroexchange/Utility/Basics/local_data.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';

class AppValidations {
  String? username(BuildContext context, String value) {
    final trimmed = value.trim();
    final isValid = RegExp(r'^[a-zA-Z0-9._]{3,20}$').hasMatch(trimmed);

    if (trimmed.isEmpty) {
      return AppLocalizations.of(context)!.usernameRequired;
    }
    if (!isValid) {
      return AppLocalizations.of(context)!.usernameRequiredFormat;
    }
    return null;
  }

  String? email(BuildContext context, String text) {
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regExp = RegExp(pattern);

    if (text.trim().isEmpty) {
      return AppLocalizations.of(context)!.emailAddressRequired;
    } else if (!regExp.hasMatch(text.trim())) {
      return AppLocalizations.of(context)!.emailAddressFormat;
    }
    return null;
  }

  String? newPassword(BuildContext context, String text) {
    final password = text.trim();

    if (password.isEmpty) {
      return AppLocalizations.of(context)!.passwordRequired;
    }
    if (password.length < 8) {
      return AppLocalizations.of(context)!.passwordLength;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return AppLocalizations.of(context)!.passwordIncludeUpperLetter;
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return AppLocalizations.of(context)!.passwordIncludeLowerLetter;
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return AppLocalizations.of(context)!.passwordIncludeNumber;
    }
    if (!RegExp(r'[!@#$%^&*]').hasMatch(password)) {
      return AppLocalizations.of(context)!.passwordIncludeSpecialCharacter;
    }

    return null; // All validations passed
  }

  String? validateNewPassword(BuildContext context, String text) {
    final password = text.trim();

    if (password.isEmpty) {
      return AppLocalizations.of(context)!.newPasswordRequired;
    }
    if (password.length < 8) {
      return AppLocalizations.of(context)!.passwordLength;
    }
    if (!RegExp(r'^(?=.*[A-Z])').hasMatch(password)) {
      return AppLocalizations.of(context)!.passwordIncludeUpperLetter;
    }
    if (!RegExp(r'^(?=.*[a-z])').hasMatch(password)) {
      return AppLocalizations.of(context)!.passwordIncludeLowerLetter;
    }
    if (!RegExp(r'^(?=.*\d)').hasMatch(password)) {
      return AppLocalizations.of(context)!.passwordIncludeNumber;
    }
    if (!RegExp(r'^(?=.*[!@#\$%\^&\*])').hasMatch(password)) {
      return AppLocalizations.of(context)!.passwordIncludeSpecialCharacter;
    }

    return null; // Passed all validations
  }

  String? confirmPassword(
    BuildContext context,
    String original,
    String confirm,
  ) {
    final originalTrimmed = original.trim();
    final confirmTrimmed = confirm.trim();

    if (confirmTrimmed.isEmpty) {
      return AppLocalizations.of(context)!.confirmPasswordRequired;
    }
    if (originalTrimmed != confirmTrimmed) {
      return AppLocalizations.of(context)!.confirmPasswordNotMatch;
    }

    return null; // Passwords match
  }

  String? validateOtp(BuildContext context, String text) {
    final otp = text.trim();
    final regExp = RegExp(r'^\d{4,6}$');

    if (otp.isEmpty) {
      return AppLocalizations.of(context)!.enterVerificationCodeRequired;
    }
    if (!regExp.hasMatch(otp)) {
      return AppLocalizations.of(context)!.enterVerificationCodeFormat;
    }

    return null;
  }

  String? nickName(BuildContext context, String text) {
    // const pattern = r'^[A-Za-z0-9._]+$';
    // final regExp = RegExp(pattern);
    const pattern = r'^[A-Za-z0-9._ ]+$';
    final regExp = RegExp(pattern);

    final value = text.trim();

    if (value.isEmpty) {
      return AppLocalizations.of(context)!.nicknameIsRequired;
    }
    if (!regExp.hasMatch(value)) {
      return AppLocalizations.of(
        context,
      )!.nicknameFormat; // add in localization OR use direct string
    }

    return null;
  }

  String? validateCurrentMpin(BuildContext context, String text) {
    final value = text.trim();

    if (value.isEmpty) {
      return AppLocalizations.of(context)!.currentMpinRequired;
    }
    if (value.length != 6) {
      return AppLocalizations.of(context)!.mpinDigitLimit;
    }
    if (value != AppStorage.getMPIN()) {
      return AppLocalizations.of(context)!.incorrectCurrentMpin;
    }

    return null;
  }

  String? validateNewMPIN(BuildContext context, String text) {
    final value = text.trim();

    if (value.isEmpty) {
      return AppLocalizations.of(context)!.newMpinIsRequired;
    }
    if (value.length != 6) {
      return AppLocalizations.of(context)!.newMpinMustBe6Digits;
    }
    if (value == AppStorage.getMPIN()) {
      return AppLocalizations.of(context)!.newMpinMustBeDifferent;
    }

    return null;
  }

  String? validateConfirmMPIN(
    BuildContext context,
    String text,
    String newMPIN,
  ) {
    final value = text.trim();

    if (value.isEmpty) {
      return AppLocalizations.of(context)!.confirmMpinIsRequired;
    }
    if (value.length != 6) {
      return AppLocalizations.of(context)!.confirmMpinMustBe6Digits;
    }
    if (value != newMPIN) {
      return AppLocalizations.of(context)!.mpinNotMatching;
    }

    return null;
  }

  String? bioRequired(BuildContext context, String text) {
    final value = text.trim();

    // Bio required
    if (value.isEmpty) {
      return AppLocalizations.of(context)!.bioIsRequired;
    }

    // Optional: length validation
    if (value.length < 5) {
      return AppLocalizations.of(context)!.bioTooShort;
    }

    if (value.length > 150) {
      return AppLocalizations.of(context)!.bioTooLong;
    }

    return null;
  }

  String? validateForgotNewMPIN(
      BuildContext context,
      String text,
      ) {
    final value = text.trim();

    if (value.isEmpty) {
      return AppLocalizations.of(context)!.newMpinIsRequired;
    }
    if (value.length != 6) {
      return AppLocalizations.of(context)!.newMpinMustBe6Digits;
    }

    return null;
  }

  String? validateForgotConfirmMPIN(
      BuildContext context,
      String text,
      String newMPIN,
      ) {
    final value = text.trim();

    if (value.isEmpty) {
      return AppLocalizations.of(context)!.confirmMpinIsRequired;
    }
    if (value.length != 6) {
      return AppLocalizations.of(context)!.confirmMpinMustBe6Digits;
    }
    if (value != newMPIN) {
      return AppLocalizations.of(context)!.mpinNotMatching;
    }

    return null;
  }

  String? validateCode(BuildContext context, String text) {
    final value = text.trim();

    if (value.isEmpty) {
      return AppLocalizations.of(context)!.codeIsRequired;
    }
    if (value.length < 4) {
      return AppLocalizations.of(context)!.codeMinLength;
    }
    if (value.length > 30) {
      return AppLocalizations.of(context)!.codeMaxLength;
    }

    return null;
  }

  String? validateRecoveryKey(
      BuildContext context,
      String text,
      String actualKey,
      ) {
    final value = text.trim();

    if (value.isEmpty) {
      return AppLocalizations.of(context)!.recoveryKeyIsRequired;
    }
    if (value != actualKey) {
      return AppLocalizations.of(context)!.incorrectRecoveryKey;
    }

    return null;
  }

  String? firstName(BuildContext context, String value) {
    final trimmed = value.trim();
    final isValid = RegExp(r'^[a-zA-Z]{2,30}$').hasMatch(trimmed);

    if (trimmed.isEmpty) {
      return AppLocalizations.of(context)!.firstNameRequired;
    }
    if (!isValid) {
      return AppLocalizations.of(context)!.firstNameInvalidFormat;
    }
    return null;
  }
  String? lastName(BuildContext context, String value) {
    final trimmed = value.trim();
    final isValid = RegExp(r'^[a-zA-Z]{2,30}$').hasMatch(trimmed);

    if (trimmed.isEmpty) {
      return AppLocalizations.of(context)!.lastNameRequired;
    }
    if (!isValid) {
      return AppLocalizations.of(context)!.lastNameInvalidFormat;
    }
    return null;
  }
  String? countryValidator(BuildContext context, String? value) {
    final trimmed = value?.trim() ?? "";

    if (trimmed.isEmpty) {
      return AppLocalizations.of(context)!.countryRequired;
    }

    return null;
  }
  String? documentTypeValidator(BuildContext context, String? value) {
    final trimmed = value?.trim() ?? "";

    const validDocumentTypes = [
      "passport",
      "driving_license",
      "government_id",
    ];

    if (trimmed.isEmpty) {
      return AppLocalizations.of(context)!.documentTypeRequired;
    }

    if (!validDocumentTypes.contains(trimmed)) {
      return AppLocalizations.of(context)!.documentTypeInvalid;
    }

    return null;
  }

  String? documentNumber(BuildContext context, String value) {
    final trimmed = value.trim();

    // Alphanumeric + optional hyphen, 5–30 chars (Passport / ID safe format)
    final isValid = RegExp(r'^[a-zA-Z0-9-]{5,30}$').hasMatch(trimmed);

    if (trimmed.isEmpty) {
      return AppLocalizations.of(context)!.documentNumberRequired;
    }

    if (!isValid) {
      return AppLocalizations.of(context)!.documentNumberInvalidFormat;
    }

    return null;
  }
  String? additionalCommentsValidator(BuildContext context, String? value) {
    final text = value?.trim() ?? "";

    // Required
    if (text.isEmpty) {
      return AppLocalizations.of(context)!.additionalCommentsRequired;
    }

    // Minimum length
    if (text.length < 3) {
      return AppLocalizations.of(context)!.additionalCommentsRequiredFormat;
    }

    // Maximum length (optional)
    if (text.length > 250) {
      return AppLocalizations.of(context)!.additionalCommentsRequiredFormat;
    }

    // Allow letters, numbers, spaces and basic symbols
    final regExp = RegExp(r'^[a-zA-Z0-9 .,!?@#\-_\n]+$');

    if (!regExp.hasMatch(text)) {
      return AppLocalizations.of(context)!.additionalCommentsRequiredFormat;
    }

    return null;
  }

  String? contactInfo(BuildContext context, String value) {
    // final trimmed = value.trim();
    // final isValid = RegExp(r'^[a-zA-Z0-9._]{3,20}$').hasMatch(trimmed);
    final trimmed = value.trim();
    final isValid = RegExp(r'^[a-zA-Z0-9._ ]{3,20}$').hasMatch(trimmed);


    if (trimmed.isEmpty) {
      return AppLocalizations.of(context)!.contactInfoRequired;
    }
    if (!isValid) {
      return AppLocalizations.of(context)!.contactInfoRequiredFormat;
    }
    return null;
  }
  String? ticketTitle(BuildContext context, String text) {
    final value = text.trim();

    if (value.isEmpty) {
      return AppLocalizations.of(context)!.titleIsRequired;
    } else if (value.length < 5) {
      return AppLocalizations.of(context)!.titleMustLeastCharacters;
    } else if (value.length > 100) {
      return AppLocalizations.of(context)!.titleExceedCharacters;
    }

    return null;
  }
  String? ticketMessage(BuildContext context, String text) {
    final value = text.trim();

    if (value.isEmpty) {
      return AppLocalizations.of(context)!.messageIsRequired;
    } else if (value.length < 10) {
      return AppLocalizations.of(context)!.messageMustLeastCharacters;
    } else if (value.length > 1000) {
      return AppLocalizations.of(context)!.messageExceedCharacters;
    }

    return null;
  }
}



class NumericTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    final regex = RegExp(r'^-?\d*\.?\d{0,2}$');

    if (!regex.hasMatch(text)) {
      return oldValue;
    }

    return newValue;
  }

}

class NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.startsWith(' ')) {
      return oldValue;
    }
    return newValue;
  }
}