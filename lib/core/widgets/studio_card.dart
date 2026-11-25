import 'package:emychat/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class StudioCard extends StatelessWidget {
  const StudioCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.gradient,
    this.hoverable = false,
    this.radius = 12,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final bool hoverable;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isInteractive = hoverable || onTap != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        hoverColor: isInteractive ? AppColors.surfaceMuted : Colors.transparent,
        splashColor: onTap != null
            ? AppColors.primary.withValues(alpha: .06)
            : Colors.transparent,
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: gradient == null ? AppColors.surface : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}
