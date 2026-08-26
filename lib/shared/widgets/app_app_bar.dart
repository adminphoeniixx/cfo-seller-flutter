import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_typography.dart';
import 'app_svg_icon.dart';

/// Reproduces `.appbar`: chrome bar, 34x34 icon buttons, title/subtitle
/// stack, optional bell (with unread badge), account, and text "Save"
/// action. Deliberately not a Flutter `AppBar` — the prototype's chrome has
/// custom icon-button sizing that reproducing it directly is more faithful
/// to. Unlike the prototype (whose chrome is always near-black), this bar
/// follows the active theme: dark chrome + light text in dark mode, light
/// chrome + dark text in light mode — via `AppPalette.chrome`/`chromeFg`.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final bool closeStyle;
  final VoidCallback? onBack;
  final bool showBell;
  final int unreadCount;
  final VoidCallback? onBell;
  final bool showAccount;
  final VoidCallback? onAccount;
  final bool showSave;
  final VoidCallback? onSave;

  const AppAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.closeStyle = false,
    this.onBack,
    this.showBell = false,
    this.unreadCount = 0,
    this.onBell,
    this.showAccount = false,
    this.onAccount,
    this.showSave = false,
    this.onSave,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 58 : 52);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chromeIsDark =
        ThemeData.estimateBrightnessForColor(colors.chrome) == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: chromeIsDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Container(
        color: colors.chrome,
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 13),
        alignment: Alignment.centerLeft,
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              if (showBack)
                _IconButton(
                  icon: Icon(
                    closeStyle ? AppIcons.close : AppIcons.back,
                    color: colors.chromeFg,
                    size: 19,
                  ),
                  onTap: onBack,
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: showBack ? 6 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.barTitle.copyWith(
                          color: colors.chromeFg,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.barSubtitle.copyWith(
                              color: colors.chromeFg.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (showBell)
                _IconButton(
                  icon: AppSvgIcon(
                    asset: AppIcons.bellAsset,
                    size: 19,
                    color: colors.chromeFg,
                  ),
                  onTap: onBell,
                  badge: unreadCount > 0 ? '$unreadCount' : null,
                ),
              if (showAccount)
                _IconButton(
                  icon: Icon(
                    AppIcons.account,
                    color: colors.chromeFg,
                    size: 19,
                  ),
                  onTap: onAccount,
                ),
              if (showSave)
                TextButton(
                  onPressed: onSave,
                  style: TextButton.styleFrom(foregroundColor: colors.accent),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final String? badge;

  const _IconButton({required this.icon, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              icon,
              if (badge != null)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 15),
                    height: 15,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE51C00),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
