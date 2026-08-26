import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';

/// Reproduces `.field`: uppercase small label above the input, surface
/// background, 1px border that turns `--action` blue with a focus ring.
class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? placeholder;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final Iterable<String>? autofillHints;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.autofillHints,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () => setState(() => _focused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.rMd,
        border: Border.all(
          color: hasError
              ? colors.critical
              : _focused
              ? colors.action
              : colors.line,
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: _focused && !hasError
            ? [
                BoxShadow(
                  color: colors.action.withValues(alpha: 0.14),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label.toUpperCase(),
            style: AppTypography.fieldLabel.copyWith(color: colors.ink3),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            autofillHints: widget.autofillHints,
            style: AppTypography.fieldValue.copyWith(color: colors.ink),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: widget.placeholder,
              hintStyle: AppTypography.fieldValue.copyWith(color: colors.ink3),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 6),
            Text(
              widget.errorText!,
              style: AppTypography.bodySmall.copyWith(
                color: colors.critical,
                height: 1.25,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Reproduces `.field.tap`: a field-shaped row that opens a picker instead
/// of accepting direct text input.
class AppTapField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color? valueColor;

  const AppTapField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: AppRadius.rMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rMd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: AppRadius.rMd,
            border: Border.all(color: colors.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: AppTypography.fieldLabel.copyWith(
                        color: colors.ink3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTypography.fieldValue.copyWith(
                        color: valueColor ?? colors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(AppIcons.chevronRight, color: colors.ink3, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
