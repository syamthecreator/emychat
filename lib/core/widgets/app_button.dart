import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, ghost, danger, mint, outline }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    String? label,
    String? text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.height,
    this.size = AppButtonSize.md,
  }) : label = label ?? text ?? '';

  const AppButton.primary({
    super.key,
    String? label,
    String? text,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.height,
    this.size = AppButtonSize.md,
  })  : label = label ?? text ?? '',
        variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    String? label,
    String? text,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.height,
    this.size = AppButtonSize.md,
  })  : label = label ?? text ?? '',
        variant = AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    String? label,
    String? text,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.height,
    this.size = AppButtonSize.md,
  })  : label = label ?? text ?? '',
        variant = AppButtonVariant.outline;

  const AppButton.ghost({
    super.key,
    String? label,
    String? text,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.height,
    this.size = AppButtonSize.md,
  })  : label = label ?? text ?? '',
        variant = AppButtonVariant.ghost;

  const AppButton.danger({
    super.key,
    String? label,
    String? text,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.height,
    this.size = AppButtonSize.md,
  })  : label = label ?? text ?? '',
        variant = AppButtonVariant.danger;

  const AppButton.mint({
    super.key,
    String? label,
    String? text,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.height,
    this.size = AppButtonSize.md,
  })  : label = label ?? text ?? '',
        variant = AppButtonVariant.mint;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool fullWidth;
  final double? height;
  final AppButtonSize size;

  double get _resolvedHeight {
    if (height != null) return height!;
    return switch (size) {
      AppButtonSize.sm => 34,
      AppButtonSize.md => 40,
      AppButtonSize.lg => 48,
    };
  }

  double get _fontSize {
    return switch (size) {
      AppButtonSize.sm => 12.5,
      AppButtonSize.md => 13.5,
      AppButtonSize.lg => 15,
    };
  }

  EdgeInsets get _padding {
    return switch (size) {
      AppButtonSize.sm => const EdgeInsets.symmetric(horizontal: 12),
      AppButtonSize.md => const EdgeInsets.symmetric(horizontal: 16),
      AppButtonSize.lg => const EdgeInsets.symmetric(horizontal: 22),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    Color backgroundColor;
    Color textColor;
    Border? border;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = isEnabled ? AppColors.sapphireBlue : AppColors.surfaceMuted;
        textColor = Colors.white;
        border = null;
        break;

      case AppButtonVariant.secondary:
        backgroundColor = AppColors.surface;
        textColor = isEnabled ? AppColors.textPrimary : AppColors.textMuted;
        border = Border.all(color: AppColors.border, width: 1);
        break;

      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = isEnabled ? AppColors.textPrimary : AppColors.textMuted;
        border = Border.all(color: AppColors.border, width: 1);
        break;

      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        textColor = isEnabled ? AppColors.textSecondary : AppColors.textMuted;
        border = null;
        break;

      case AppButtonVariant.danger:
        backgroundColor = AppColors.error.withValues(alpha: 0.12);
        textColor = isEnabled ? AppColors.error : AppColors.textMuted;
        border = Border.all(
          color: AppColors.error.withValues(alpha: 0.25),
          width: 1,
        );
        break;

      case AppButtonVariant.mint:
        backgroundColor = AppColors.mint;
        textColor = const Color(0xFF090C0B);
        border = null;
        break;
    }

    Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: size == AppButtonSize.sm ? 14 : 16, color: textColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: 8),
          Icon(
            trailingIcon,
            size: size == AppButtonSize.sm ? 14 : 16,
            color: textColor,
          ),
        ],
      ],
    );

    return SizedBox(
      height: _resolvedHeight,
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          hoverColor: variant == AppButtonVariant.primary
              ? Colors.white.withValues(alpha: 0.12)
              : AppColors.surfaceMuted,
          child: Container(
            padding: _padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: border,
            ),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}
