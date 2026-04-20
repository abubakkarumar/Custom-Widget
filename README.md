# Custom-Widget Utility Guide

This README is focused only on the reusable utilities used in this Custom-Widget codebase.

## Scope

The project has many app screens and feature modules, but this document covers utility layers inside:

- `lib/Utility/Basics`
- `lib/Utility/internet_connection`
- `lib/Utility/global_state`
- `lib/Utility/Colors`
- `lib/Utility/Images`
- Reusable UI helpers inside `lib/Utility/*.dart`

## Utility Architecture

### 1) Core services (`lib/Utility/Basics`)

- `services.dart`
  - Central `Dio` client setup.
  - Adds auth token and language headers.
  - Handles common network errors and 401 redirect flow.
- `api_endpoints.dart`
  - API path constants and socket URL constants.
- `local_data.dart`
  - Local key-value storage helper around `GetStorage`.
  - Includes helpers for token, profile data, settings, security flags.
- `app_secure_storage.dart`
  - Secure storage wrapper for sensitive keys.
- `app_navigator.dart`
  - Centralized navigation helper.
- `app_providers.dart`
  - Provider registration for app-level `ChangeNotifier` classes.
- `validation.dart`, `handle_error.dart`, `api_loggers.dart`
  - Validation rules, API error formatting, and request logging helpers.
- `custom_loader.dart`
  - Shared loading indicator utility.

### 2) Connectivity utilities (`lib/Utility/internet_connection`)

- `connection_handler.dart`
  - `ConnectivityGate` wrapper.
  - Shows offline overlay when internet is unavailable.
  - Handles initialization delay to avoid false offline flash at startup.
- `no_internet_connection.dart`
  - Shared offline UI component.

### 3) Global cache utilities (`lib/Utility/global_state`)

- `global_providers.dart` (Riverpod)
  - `tradePairsProvider`
  - `walletSummaryProvider`
  - `orderHistoryProvider`
- Uses `AsyncNotifier` for shared cross-screen cache.
- Reduces duplicate API requests by reusing loaded data.

### 4) Theme and asset helpers

- `lib/Utility/Colors/custom_theme_change.dart`
  - Theme-aware color getters.
- `lib/Utility/Images/custom_theme_change.dart`
  - Theme-aware image/icon path mapping.
- `lib/Utility/Images/dark_image.dart`, `light_image.dart`
  - Centralized image/icon constants.

### 5) Reusable widget utilities

Common reusable UI helpers available in `lib/Utility/`:

- `custom_button.dart`
- `custom_text.dart`
- `custom_text_form_field.dart`
- `custom_tab_bar.dart`
- `custom_actionbar.dart`
- `custom_tooltip.dart`
- `custom_alertbox.dart`
- `custom_otp_field.dart`
- `custom_list_items.dart`
- `custom_no_records.dart`
- `no_data_layout.dart`
- `number_formator.dart`
- `template.dart`

These components are used across multiple feature screens to keep UI behavior and styling consistent.

## Utility Stack Used

Based on imports in utility-related code:

- Networking: `dio`
- State: `provider`, `flutter_riverpod`
- Storage: `get_storage`, `flutter_secure_storage`
- Connectivity: `observe_internet_connectivity`
- UI support: `responsive_sizer`, `flutter_svg`, `pinput`
- Security/crypto support: `local_auth`, `basic_utils`, `pointycastle`

## How To Reuse These Utilities

1. Keep utility files framework-agnostic where possible.
2. Inject app-specific API URLs/keys from config, not hardcoded constants.
3. Use `AppServices` for all network calls instead of creating new Dio clients.
4. Reuse `AppStorage` and `AppSecureStorage` wrappers for all local persistence.
5. Use shared utility widgets to maintain consistent UI/UX.

## Notes

- This repository snapshot currently has only `lib/` source files.
- If you want to run it as a standalone Flutter app, add missing root/project files (`pubspec.yaml`, assets, and platform folders).
