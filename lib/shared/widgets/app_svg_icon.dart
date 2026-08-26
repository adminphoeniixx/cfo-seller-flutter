import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders one of the prototype's inline-SVG icons (lifted verbatim into
/// `assets/icons/`) tinted to match the surrounding text/icon color, the
/// same way `fill="currentColor"` behaves in the HTML.
class AppSvgIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color color;

  const AppSvgIcon({
    super.key,
    required this.asset,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
