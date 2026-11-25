import 'package:emychat/app/theme/app_colors.dart';
import 'package:emychat/core/controller/theme_provider.dart';
import 'package:emychat/core/utils/shell_scope.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.destination,
    required this.notificationCount,
    required this.onBellTap,
    this.onMenuTap,
    this.onNewCampaign,
  });

  final NavDestination destination;
  final int notificationCount;
  final VoidCallback onBellTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNewCampaign;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final showSearch = c.maxWidth > 840;
        final showMobileMenu = c.maxWidth < 720 && onMenuTap != null;

        return SizedBox(
          height: 56,
          child: Row(
            children: [
              if (showMobileMenu) ...[
                IconButton(
                  icon: const Icon(
                    RemixIcons.menu_line,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: onMenuTap,
                  splashRadius: 20,
                  tooltip: 'Open navigation',
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      destination.blurb,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (showSearch) ...[
                const SizedBox(width: 16),
                const SizedBox(width: 280, child: _SearchBox()),
              ],
              const SizedBox(width: 12),
              // Theme Mode Toggle
              Builder(
                builder: (context) {
                  final themeProvider = context.watch<ThemeProvider>();
                  final isDark = themeProvider.isDarkMode(context);
                  return InkWell(
                    onTap: () => themeProvider.toggleTheme(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        isDark ? RemixIcons.sun_line : RemixIcons.moon_line,
                        size: 16,
                        color: isDark
                            ? AppColors.arcticBlue
                            : AppColors.sapphireBlue,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _BellButton(count: notificationCount, onTap: onBellTap),
            ],
          ),
        );
      },
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            RemixIcons.search_line,
            size: 15,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
              cursorColor: AppColors.accentPrimary,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search conversations or rules...',
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12.5,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Text(
              '⌘K',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                RemixIcons.notification_3_line,
                size: 17,
                color: AppColors.textSecondary,
              ),
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.accentPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
