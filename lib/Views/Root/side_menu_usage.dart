import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:zayroexchange/Utility/Colors/custom_theme_change.dart';
import 'package:zayroexchange/Utility/Images/dark_image.dart';
import 'package:zayroexchange/Utility/Images/light_image.dart';
import 'package:zayroexchange/Utility/custom_button.dart';
import 'package:zayroexchange/Utility/custom_text.dart';
import 'package:zayroexchange/l10n/app_localizations.dart';
import '../../material_theme/theme_controller.dart';

/// Profile header (exact look)
class ProfileHeaderExact extends StatelessWidget {
  final String? name;
  final String uid;
  final String? avatarAsset;
  final VoidCallback? onEdit;
  final VoidCallback? onCopyUid;
  final bool verified;

  /// IMPORTANT – controller must be passed
  final dynamic controller;

  const ProfileHeaderExact({
    super.key,
    required this.name,
    required this.uid,
    required this.controller,
    this.avatarAsset,
    this.onEdit,
    this.onCopyUid,
    this.verified = true,
  });

  @override
  Widget build(BuildContext context) {
    const double avatarSizePx = 60;

    final bool hasName = (name ?? '').trim().isNotEmpty;
    final bool hasUid = uid.trim().isNotEmpty;
    final bool hasAvatar = (avatarAsset ?? '').trim().isNotEmpty;

    return Container(
      padding: EdgeInsets.all(15.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(
            context,
          ),
          width: 3.5.sp,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// ----------------------------
          ///  PROFILE IMAGE / PLACEHOLDER
          /// ----------------------------
          ClipOval(
            child: SizedBox(
              width: avatarSizePx,
              height: avatarSizePx,
              child: controller.profileImageUrl?.isNotEmpty == true
                  ? profileImage(context)
                  : profilePlaceHolder(context),
            ),
          ),

          SizedBox(width: 10.sp),

          /// ----------------------------
          ///      MIDDLE TEXT COLUMN
          /// ----------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// NAME + VERIFIED
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        hasName ? name! : "Example",
                        style: TextStyle(fontSize: 16.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 5.sp),

                    if (verified && hasName)
                      SvgPicture.asset(
                        AppBasicIcons.verifiedCircle,
                        width: 18.sp,
                        height: 18.sp,
                      ),
                  ],
                ),

                SizedBox(height: 8.sp),

                /// UID BOX
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasUid ? "UID: $uid" : "User Id",
                      style: TextStyle(
                        color: ThemeTextOneColor.getTextOneColor(context),
                        fontSize: 14.5.sp,
                      ),
                    ),
                    SizedBox(width: 10.sp),
                    GestureDetector(
                      onTap: hasUid
                          ? (onCopyUid ?? () => _copyUid(context))
                          : null,
                      child: SvgPicture.asset(
                        AppBasicIcons.copy,
                        width: 16.sp,
                        height: 16.sp,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.sp),

                Text(
                  AppLocalizations.of(context)!.personalizeYourProfileSettings,
                  style: TextStyle(
                    color: ThemeTextOneColor.getTextOneColor(context),
                    fontWeight: FontWeight.w500,
                    fontSize: 13.sp,
                  ),
                ),

                SizedBox(height: 8.sp),

                Text(
                  AppLocalizations.of(context)!.uploadImageSize,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5.sp,
                  ),
                ),
              ],
            ),
          ),


          /// ----------------------------
          ///      EDIT BUTTON
          /// ----------------------------
          Opacity(
            opacity: hasAvatar || hasName || hasUid ? 1.0 : 0.6,
            child: _GradientButton(
              onTap: onEdit,
              label: AppLocalizations.of(context)!.editImage,
              icon: Icons.edit,
            ),
          ),
        ],
      ),
    );
  }

  /// PLACEHOLDER IMAGE (SAFE)
  Widget profilePlaceHolder(BuildContext context) {
    if (controller.profilePictureFile != null) {
      return Image.file(
        File(controller.profilePictureFile!.path),
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
        controller.profileImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => profilePlaceHolder(context),
        loadingBuilder: (_, child, loading) {
          if (loading == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      ),
    );
  }

  void _copyUid(BuildContext context) {
    Clipboard.setData(ClipboardData(text: uid));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(
          label:
              AppLocalizations.of(context)!.copied +
              uid +
              AppLocalizations.of(context)!.toClipboard,
        ),
      ),
    );
  }
}

/// Gradient button used on right
class _GradientButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final IconData icon;

  const _GradientButton({this.onTap, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 4.h,
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.sp),
          gradient: LinearGradient(
            colors: [
              Color(0xFF007FFF),
              Color(0xFF623EF8),
              Color(0xFFBF00FF),
            ],
            stops: [0.0, 0.35, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppBasicIcons.editIcon,
              width: 15.sp,
              height: 15.sp,
            ),
            SizedBox(width: 12.sp),
            CustomText(
              label: label,
              fontSize: 14.sp,
              fontColour: ThemeButtonTextColor.getButtonTextColor(context),
              labelFontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////

/// Colour Theme Tile with theme toggle
class ColourThemeTile extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const ColourThemeTile({
    super.key,
    required this.iconPath,
    this.title = 'Colour Theme',
    this.subtitle = 'Customize your app appearance.',
    this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    ThemeOutLineColor.getOutLineColor(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(15.sp),
        child: Row(
          children: [
            // left icon
            Center(
              child: SvgPicture.asset(iconPath, width: 25.sp, height: 25.sp),
            ),

            SizedBox(width: 14.sp),
            // title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    label: title,
                    fontSize: 16.sp,
                    labelFontWeight: FontWeight.w700,
                  ),
                  SizedBox(height: 3.sp),
                  CustomText(
                    label: subtitle,
                    fontSize: 13.sp,
                    fontColour: ThemeTextOneColor.getTextOneColor(context),
                  ),
                ],
              ),
            ),

            // trailing toggle widget that switches theme on tap
            const ThemeToggleExample(),
          ],
        ),
      ),
    );
  }
}

/// Theme Toggle Button used in Colour Theme Tile
class ThemeToggleExample extends StatefulWidget {
  const ThemeToggleExample({super.key});

  @override
  State<ThemeToggleExample> createState() => _ThemeToggleExampleState();
}

class _ThemeToggleExampleState extends State<ThemeToggleExample> {
  // Local state reflects provider theme mode
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    final themeMode = Provider.of<ThemeController>(
      context,
      listen: false,
    ).themeMode;
    isDarkMode = themeMode == ThemeMode.dark;
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      Provider.of<ThemeController>(
        context,
        listen: false,
      ).changeTheme(isDarkMode ? ThemeMode.dark : ThemeMode.light);
    });
  }

  @override
  Widget build(BuildContext context) {
    final background = ThemeOutLineColor.getOutLineColor(context);

    return GestureDetector(
      onTap: _toggleTheme,
      child: Container(
        height: 4.5.h,
        padding: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(15.sp),
          border: Border.all(
            width: 4.sp,
            color: ThemeOutLineColor.getOutLineColor(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              padding: EdgeInsets.all(6.5.sp),
              duration: const Duration(milliseconds: 200),
              width: 22.sp,
              height: 22.sp,
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 12.sp),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.transparent : Colors.white24,
                borderRadius: BorderRadius.circular(12.sp),
              ),
              child: SvgPicture.asset(
                // show filled active icon when dark, else show dark inactive (you can swap as needed)
                isDarkMode
                    ? AppDarkSideIcons.active
                    : AppDarkSideIcons.inActive,
                width: 20.sp,
                height: 20.sp,
              ),
            ),

            AnimatedContainer(
              padding: EdgeInsets.all(6.5.sp),
              duration: const Duration(milliseconds: 200),
              width: 22.sp,
              height: 22.sp,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.sp),
                color: isDarkMode ? null : Colors.transparent,
              ),
              child: SvgPicture.asset(
                // complementary icon (light variants)
                isDarkMode
                    ? AppLightSideIcons.inActive
                    : AppLightSideIcons.active,
                width: 20.sp,
                height: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/////////////////////////////////////////////////////////////////////////////

/// Custom Side Menu Tile with optional toggle or navigation arrow
class CustomSideMenu extends StatefulWidget {
  final String subTitle;
  final String? subText;
  final String sideImage;
  final String navImage;
  final bool? isPressed;
  final String? countryImage;
  final String? countryName;
  final VoidCallback onTap;
  final VoidCallback? onToggleOn;
  final VoidCallback? onToggleOff;

  const CustomSideMenu({
    super.key,
    required this.subTitle,
    required this.sideImage,
    required this.navImage,
    this.subText,
    this.countryImage,
    this.countryName,
    required this.onTap,
    this.onToggleOn,
    this.onToggleOff,
    this.isPressed,
  });

  @override
  State<CustomSideMenu> createState() => _CustomSideMenuState();
}

class _CustomSideMenuState extends State<CustomSideMenu> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return CustomGestureButton(
      onTap: widget.onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 13.sp,right: 13.sp,top: 13.sp,bottom: 10.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// LEFT SECTION
            Row(
              children: [
                /// Icon Box
                SvgPicture.asset(widget.sideImage, width: 22.sp, height: 22.sp),

                SizedBox(width: 14.sp),

                /// Title + Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      label: widget.subTitle,
                      fontSize: 15.5.sp,
                      labelFontWeight: FontWeight.w700,
                    ),
                    if (widget.subText != null &&
                        widget.subText!.isNotEmpty) ...[
                      SizedBox(height: 8.sp),
                      CustomText(
                        label: widget.subText!,
                        fontSize: 14.5.sp,
                        fontColour: ThemeTextOneColor.getTextOneColor(context),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            /// RIGHT SECTION
            if (widget.subTitle == AppLocalizations.of(context)!.language) ...[
              LanguageBox(
                flagImage: widget.countryImage ?? "",
                langCode: widget.countryName ?? "",
              ),
            ] else ...[
              if (widget.isPressed == false)
                const SizedBox()
              else if (widget.onToggleOn == null && widget.onToggleOff == null)
                SvgPicture.asset(widget.navImage, width: 23.sp, height: 23.sp)
              else
                GradientToggle(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() => isSwitched = value);

                    if (value) {
                      widget.onToggleOn?.call();
                    } else {
                      widget.onToggleOff?.call();
                    }
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}
///////////////////////////////////////////////////////////////////////

/// Gradient Toggle Button
class GradientToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const GradientToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<GradientToggle> createState() => _GradientToggleState();
}

class _GradientToggleState extends State<GradientToggle>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: Container(
        width: 28.sp,
        height: 22.sp,
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.sp),
          gradient: widget.value
              ? LinearGradient(
                  colors: [
                    ThemeInversePrimaryColor.getInversePrimaryColor(context),
                    ThemeButtonColor.getButtonColor(context),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: widget.value
              ? null
              : ThemeTextFormFillColor.getTextFormFillColor(context),
          border: Border.all(
            color: ThemeOutLineColor.getOutLineColor(context),
            width: 5.sp,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: widget.value
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              border: Border.all(
                color: ThemeOutLineColor.getOutLineColor(context),
              ),
              shape: BoxShape.circle,
              color: ThemeTextColor.getTextColor(context),
            ),
          ),
        ),
      ),
    );
  }
}
///////////////////////////////////////////////////////////////////////

/// Language Box used in Language Side Menu Tile
class LanguageBox extends StatelessWidget {
  final String flagImage; // PNG/SVG/Network
  final String langCode;

  const LanguageBox({
    super.key,
    required this.flagImage,
    required this.langCode,
  });

  bool _isNetwork(String path) {
    return path.startsWith("http://") || path.startsWith("https://");
  }

  bool _isSvg(String path) {
    return path.toLowerCase().endsWith(".svg");
  }

  Widget _loadImage(String path) {
    // Network SVG
    if (_isNetwork(path) && _isSvg(path)) {
      return SvgPicture.network(
        path,
        width: 15.sp,
        height: 15.sp,
        placeholderBuilder: (context) =>
            const CircularProgressIndicator(strokeWidth: 1),
      );
    }

    // Network PNG/JPG
    if (_isNetwork(path)) {
      return Image.network(
        path,
        width: 15.sp,
        height: 15.sp,
        errorBuilder: (_, __, ___) => const Icon(Icons.error),
      );
    }

    // Asset SVG
    if (_isSvg(path)) {
      return SvgPicture.asset(path, width: 15.sp, height: 15.sp);
    }

    // Asset PNG/JPG
    return Image.asset(
      path,
      width: 15.sp,
      height: 15.sp,
      errorBuilder: (_, __, ___) => const Icon(Icons.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4.5.h,
      width: 20.w,
      decoration: BoxDecoration(
        color: ThemeTextFormFillColor.getTextFormFillColor(context),
        borderRadius: BorderRadius.circular(15.sp),
        border: Border.all(
          color: ThemeOutLineColor.getOutLineColor(context),
          width: 5.sp,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _loadImage(flagImage),
          SizedBox(width: 10.sp),
          CustomText(
            label: langCode,
            fontSize: 14.5.sp,
            labelFontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////
