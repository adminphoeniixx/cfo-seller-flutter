import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_svg_icon.dart';

class AppTabItem {
  final String label;
  final String iconAsset;
  const AppTabItem({required this.label, required this.iconAsset});
}

/// Reproduces `.tabbar`: surface bg, top border, 4 tabs (Home/Orders/
/// Products/Money), 21px icons, 10px labels, action-blue active state.
/// Icons render the prototype's actual SVG paths via [AppSvgIcon].
class AppBottomNavigation extends StatelessWidget {
  final List<AppTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(4, 7, 4, 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppSvgIcon(
                          asset: items[i].iconAsset,
                          size: 21,
                          color: i == currentIndex
                              ? colors.action
                              : colors.ink3,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[i].label,
                          style:
                              (i == currentIndex
                                      ? AppTypography.tabLabelOn
                                      : AppTypography.tabLabel)
                                  .copyWith(
                                    color: i == currentIndex
                                        ? colors.action
                                        : colors.ink3,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
