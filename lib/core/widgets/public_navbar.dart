import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../app/routes/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../constants/asset_constants.dart';
import '../controller/theme_provider.dart';

class PublicNavbar extends StatelessWidget implements PreferredSizeWidget {
  const PublicNavbar({
    super.key,
    this.currentRoute = '/',
    this.selectedTab,
    this.onTabSelected,
  });

  final String currentRoute;
  final int? selectedTab;
  final ValueChanged<int>? onTabSelected;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isAuth = auth.isAuthenticated;
    final themeProvider = context.watch<ThemeProvider?>();
    final isDark =
        themeProvider?.isDarkMode(context) ??
        (Theme.of(context).brightness == Brightness.dark);
    final navBg = isDark ? AppColors.midnightNavy : Colors.white;
    final navBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textTitleColor = isDark
        ? AppColors.crispWhite
        : AppColors.lightTextPrimary;
    final textSubtitleColor = isDark
        ? AppColors.silver
        : AppColors.lightTextSecondary;

    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: navBg,
        border: Border(bottom: BorderSide(color: navBorder, width: 1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          final isSmallMobile = constraints.maxWidth < 420;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. Brand Logo & Title
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          if (onTabSelected != null) {
                            onTabSelected!(0);
                          } else if (currentRoute != AppRouter.landing) {
                            Navigator.of(context)
                                .pushReplacementNamed(AppRouter.landing);
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: isSmallMobile
                                    ? 26
                                    : (isMobile ? 28 : 32),
                                height: isSmallMobile
                                    ? 26
                                    : (isMobile ? 28 : 32),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  gradient: isDark
                                      ? AppColors.ctaGradient
                                      : null,
                                  color: isDark ? null : AppColors.sapphireBlue,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.arcticBlue.withValues(
                                        alpha: isDark ? 0.3 : 0.15,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  AssetConstants.aLogo,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        RemixIcons.apps_2_fill,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                ),
                              ),
                              SizedBox(
                                width: isSmallMobile ? 5 : (isMobile ? 7 : 10),
                              ),
                              Flexible(
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'emy',
                                        style: TextStyle(
                                          fontSize: isSmallMobile
                                              ? 15
                                              : (isMobile ? 16 : 18.5),
                                          fontWeight: FontWeight.w800,
                                          color: textTitleColor,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'chat',
                                        style: TextStyle(
                                          fontSize: isSmallMobile
                                              ? 15
                                              : (isMobile ? 16 : 18.5),
                                          fontWeight: FontWeight.w600,
                                          color: textSubtitleColor,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 2. Interactive Tab Navigation (Desktop / Wide Tablet)
                    if (constraints.maxWidth >= 920)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightCardMuted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorderSubtle
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTabItem(
                              context,
                              label: 'Features',
                              index: 0,
                              isDark: isDark,
                            ),
                            _buildTabItem(
                              context,
                              label: 'Pricing',
                              index: 1,
                              isDark: isDark,
                            ),
                            _buildTabItem(
                              context,
                              label: 'WhatsApp',
                              index: 2,
                              icon: RemixIcons.whatsapp_line,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),

                    // 3. Right Action Buttons & Theme Switcher
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Sleek Theme Mode Switcher
                        InkWell(
                          onTap: () => themeProvider?.toggleTheme(),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: isSmallMobile ? 28 : (isMobile ? 32 : 36),
                            height: isSmallMobile ? 28 : (isMobile ? 32 : 36),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkCardMuted
                                  : AppColors.lightCardMuted,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                            ),
                            child: Icon(
                              isDark
                                  ? RemixIcons.sun_line
                                  : RemixIcons.moon_line,
                              size: isSmallMobile ? 13 : (isMobile ? 14 : 16),
                              color: isDark
                                  ? AppColors.arcticBlue
                                  : AppColors.sapphireBlue,
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallMobile ? 3 : (isMobile ? 4 : 8)),

                        if (isAuth) ...[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(AppRouter.dashboard);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.sapphireBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Dashboard',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ] else ...[
                          TextButton(
                            onPressed: () {
                              if (currentRoute != AppRouter.login) {
                                Navigator.of(context)
                                    .pushNamed(AppRouter.login);
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: textTitleColor,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallMobile
                                    ? 6
                                    : (isMobile ? 8 : 12),
                                vertical: isSmallMobile ? 6 : 8,
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: isSmallMobile
                                    ? 12
                                    : (isMobile ? 12.5 : 13),
                                fontWeight: FontWeight.w600,
                                color: textTitleColor,
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallMobile ? 4 : 6),
                          Container(
                            height: isSmallMobile ? 30 : 36,
                            decoration: BoxDecoration(
                              gradient: AppColors.ctaGradient,
                              borderRadius: BorderRadius.circular(7),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.sapphireBlue.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (onTabSelected != null) {
                                  onTabSelected!(1); // Go to pricing
                                } else {
                                  Navigator.of(context)
                                      .pushNamed(AppRouter.pricing);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallMobile
                                      ? 8
                                      : (isMobile ? 12 : 16),
                                  vertical: isSmallMobile ? 6 : 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                isSmallMobile ? 'Start' : 'Get Started',
                                style: TextStyle(
                                  fontSize: isSmallMobile
                                      ? 11.5
                                      : (isMobile ? 12.5 : 13),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context, {
    required String label,
    required int index,
    required bool isDark,
    IconData? icon,
  }) {
    final activeIndex =
        selectedTab ??
        (currentRoute == AppRouter.pricing || currentRoute == '/pricing'
            ? 1
            : 0);
    final isSelected = activeIndex == index;

    final activeColor = isDark ? AppColors.arcticBlue : AppColors.sapphireBlue;
    final activeBg = isDark ? AppColors.darkBorder : Colors.white;

    return InkWell(
      onTap: () {
        if (onTabSelected != null) {
          onTabSelected!(index);
        } else if (index == 1) {
          if (currentRoute != AppRouter.pricing && currentRoute != '/pricing') {
            Navigator.of(context).pushNamed(AppRouter.pricing);
          }
        } else {
          Navigator.of(context).pushReplacementNamed(AppRouter.landing);
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected && !isDark
              ? Border.all(color: AppColors.lightBorder)
              : null,
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected
                    ? activeColor
                    : (isDark
                          ? AppColors.silver
                          : AppColors.lightTextSecondary),
              ),
              const SizedBox(width: 5),
            ],
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
          ],
        ),
      ),
    );
  }
}
