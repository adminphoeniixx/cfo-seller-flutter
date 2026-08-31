import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_typography.dart';

/// One photo tile's presentation state — deliberately decoupled from
/// `DraftImage` so this widget doesn't depend on the products feature.
class MediaTile {
  final String? localPath;
  final String? networkUrl;
  final bool uploading;
  final bool failed;

  const MediaTile({this.localPath, this.networkUrl, this.uploading = false, this.failed = false});
}

/// Reproduces `.media`/`.tile`: 4-column photo grid, cover badge on tile 0,
/// remove (×) and make-cover (★) mini-buttons, dashed "add" tile, and an
/// upload spinner overlay while a tile is uploading.
class AppMediaGrid extends StatelessWidget {
  final List<MediaTile> tiles;
  final int maxTiles;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onMakeCover;

  /// Long-press drag to reorder — index 0 stays the cover, per the spec's
  /// "long-press/drag to reorder; order in the array *is* the display
  /// order." Optional so callers that don't support reordering (none, today)
  /// can omit it without breaking.
  final void Function(int from, int to)? onReorder;

  const AppMediaGrid({
    super.key,
    required this.tiles,
    this.maxTiles = 10,
    required this.onAdd,
    required this.onRemove,
    required this.onMakeCover,
    this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: tiles.length < maxTiles ? tiles.length + 1 : tiles.length,
      itemBuilder: (context, i) {
        if (i == tiles.length) {
          return _AddTile(onTap: onAdd);
        }
        final tile = tiles[i];
        final photo = _PhotoTile(
          tile: tile,
          isCover: i == 0,
          onRemove: () => onRemove(i),
          onMakeCover: i > 0 ? () => onMakeCover(i) : null,
        );

        if (onReorder == null) return photo;

        return DragTarget<int>(
          onWillAcceptWithDetails: (details) => details.data != i,
          onAcceptWithDetails: (details) => onReorder!(details.data, i),
          builder: (context, candidates, _) => LongPressDraggable<int>(
            data: i,
            feedback: SizedBox(
              width: 70,
              height: 70,
              child: Opacity(opacity: 0.85, child: photo),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: photo),
            child: candidates.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.colors.action, width: 2),
                    ),
                    child: photo,
                  )
                : photo,
          ),
        );
      },
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface2,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: DottedBorder(
          color: colors.ink3,
          child: Icon(AppIcons.add, color: colors.ink3, size: 22),
        ),
      ),
    );
  }
}

/// Minimal dashed-border box — avoids pulling in a package for one tile.
class DottedBorder extends StatelessWidget {
  final Color color;
  final Widget child;

  const DottedBorder({super.key, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color),
      child: Center(child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addRRect(rrect);
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => oldDelegate.color != color;
}

class _PhotoTile extends StatelessWidget {
  final MediaTile tile;
  final bool isCover;
  final VoidCallback onRemove;
  final VoidCallback? onMakeCover;

  const _PhotoTile({
    required this.tile,
    required this.isCover,
    required this.onRemove,
    this.onMakeCover,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface2,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (tile.networkUrl != null)
            Image.network(tile.networkUrl!, fit: BoxFit.cover)
          else if (tile.localPath != null && !kIsWeb)
            Image.file(File(tile.localPath!), fit: BoxFit.cover)
          else
            Icon(Icons.image_outlined, color: colors.ink3),
          if (tile.uploading)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ),
          if (tile.failed)
            Container(
              color: Colors.black.withValues(alpha: 0.45),
              alignment: Alignment.center,
              child: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            ),
          if (isCover)
            Positioned(
              top: 3,
              left: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: colors.ink, borderRadius: BorderRadius.circular(5)),
                child: Text(
                  'COVER',
                  style: AppTypography.pill.copyWith(color: colors.surface, fontSize: 8),
                ),
              ),
            ),
          Positioned(
            top: 2,
            right: 2,
            child: _MiniButton(icon: Icons.close_rounded, onTap: onRemove),
          ),
          if (onMakeCover != null)
            Positioned(
              bottom: 2,
              right: 2,
              child: _MiniButton(icon: Icons.star_rounded, onTap: onMakeCover!),
            ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.58),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 19,
          height: 19,
          child: Icon(icon, size: 12, color: Colors.white),
        ),
      ),
    );
  }
}
