import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Reproduces `.tags`: wrap of removable chips plus a trailing text field
/// that commits a new tag on Enter or comma.
class AppTagInput extends StatelessWidget {
  final List<String> tags;
  final TextEditingController controller;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const AppTagInput({
    super.key,
    required this.tags,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final t in tags)
                  Container(
                    padding: const EdgeInsets.only(left: 8, right: 2, top: 3, bottom: 3),
                    decoration: BoxDecoration(
                      color: colors.surface2,
                      border: Border.all(color: colors.line),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t, style: AppTypography.chip.copyWith(color: colors.ink2)),
                        InkWell(
                          onTap: () => onRemove(t),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(Icons.close_rounded, size: 14, color: colors.ink3),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        TextField(
          controller: controller,
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.endsWith(',')) {
                onAdd(newValue.text);
                return TextEditingValue.empty;
              }
              return newValue;
            }),
          ],
          onSubmitted: onAdd,
          textInputAction: TextInputAction.done,
          style: AppTypography.fieldValue.copyWith(color: colors.ink),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            hintText: 'Add a tag and press Enter',
            hintStyle: AppTypography.fieldValue.copyWith(color: colors.ink3),
          ),
        ),
      ],
    );
  }
}
