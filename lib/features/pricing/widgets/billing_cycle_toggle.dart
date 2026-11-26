import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/controller/theme_provider.dart';

/// Ultra Premium Midnight Sapphire Billing Cycle Segmented Switcher
class BillingCycleToggle extends StatelessWidget {
  const BillingCycleToggle({
    super.key,
    required this.isYearly,
    required this.onChanged,
  });

  final bool isYearly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider?>();
    final isDark =
        themeProvider?.isDarkMode(context) ??
        (Theme.of(context).brightness == Brightness.dark);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCardMuted,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleItem(
            label: 'Monthly Billing',
            isSelected: !isYearly,
            isDark: isDark,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 3),
          _ToggleItem(
            label: 'Annual Billing',
            badgeText: 'SAVE 20%',
            badgeIcon: RemixIcons.percent_line,
            isSelected: isYearly,
            isDark: isDark,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  const _ToggleItem({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    this.badgeText,
    this.badgeIcon,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final String? badgeText;
  final IconData? badgeIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: isSelected && isDark ? AppColors.ctaGradient : null,
          color: isSelected
              ? (isDark ? null : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.sapphireBlue)
                    : (isDark
                          ? AppColors.silver
                          : AppColors.lightTextSecondary),
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.22)
                      : (isDark
                            ? AppColors.arcticBlue.withValues(alpha: 0.15)
                            : const Color(0xFFE0E7FF)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeText!,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.arcticBlue
                              : AppColors.sapphireBlue),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
