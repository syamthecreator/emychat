import 'package:emychat/features/pricing/models/pricing_plan_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/controller/theme_provider.dart';

class CompactPricingCard extends StatelessWidget {
  const CompactPricingCard({
    super.key,
    required this.plan,
    required this.isYearly,
    required this.onSelect,
    this.width,
  });

  final PricingPlanModel plan;
  final bool isYearly;
  final VoidCallback onSelect;
  final double? width;

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(0)}M';
    }
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider?>();
    final isDark =
        themeProvider?.isDarkMode(context) ??
        (Theme.of(context).brightness == Brightness.dark);

    final price = isYearly ? plan.yearlyMonthlyEquivalent : plan.monthlyPrice;

    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final cardBorder = plan.isPopular
        ? (isDark ? AppColors.arcticBlue : AppColors.sapphireBlue)
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);
    final titleColor = isDark
        ? AppColors.crispWhite
        : AppColors.lightTextPrimary;
    final taglineColor = isDark
        ? AppColors.silver
        : AppColors.lightTextSecondary;

    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cardBorder,
          width: plan.isPopular ? 1.6 : 1.0,
        ),
        boxShadow: plan.isPopular
            ? [
                BoxShadow(
                  color:
                      (isDark ? AppColors.arcticBlue : AppColors.sapphireBlue)
                          .withValues(alpha: isDark ? 0.16 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Plan Name & Popular Badge Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                plan.name,
                style: TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: -0.3,
                ),
              ),
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.ctaGradient,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.arcticBlue.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCardMuted
                        : AppColors.lightCardMuted,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorderSubtle
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    plan.slug == 'starter' ? 'STARTER' : 'PRO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.silver
                          : AppColors.lightTextSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          // 2. Short Plan Description (Fixed height for strict row baseline alignment)
          SizedBox(
            height: 32,
            child: Text(
              plan.tagline,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: taglineColor,
                height: 1.35,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 12),

          // 3 & 4. Price & Billing Frequency
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$$price',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: -1.0,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/month',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.silver
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Billing Cycle Note
          Text(
            isYearly
                ? 'Billed annually at \$${plan.yearlyPrice}/yr (Save \$${plan.annualSavings})'
                : 'Billed monthly, cancel anytime',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isYearly ? FontWeight.w600 : FontWeight.w400,
              color: isYearly
                  ? (isDark ? AppColors.arcticBlue : const Color(0xFF15803D))
                  : (isDark ? AppColors.silver : AppColors.lightTextMuted),
            ),
          ),

          const SizedBox(height: 14),

          // 5. Primary CTA Button (Strictly aligned across all 3 cards)
          SizedBox(
            width: double.infinity,
            height: 38,
            child: plan.isPopular
                ? Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.ctaGradient,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sapphireBlue.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            plan.ctaText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(RemixIcons.arrow_right_line, size: 14),
                        ],
                      ),
                    ),
                  )
                : OutlinedButton(
                    onPressed: onSelect,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: titleColor,
                      backgroundColor: isDark
                          ? AppColors.darkCardMuted.withValues(alpha: 0.5)
                          : Colors.white,
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : const Color(0xFFCBD5E1),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      plan.ctaText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 14),
          Divider(
            color: isDark
                ? AppColors.darkBorderSubtle
                : const Color(0xFFEEEEEE),
            height: 1,
          ),
          const SizedBox(height: 12),

          // 6. Most Important Included Features
          Text(
            'KEY CAPABILITIES',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.arcticBlue : AppColors.sapphireBlue,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 8),

          _FeatureItem(
            icon: RemixIcons.message_3_line,
            title: '${_formatNumber(plan.monthlyMessages)} Messages / month',
            isHighlighted: true,
            isDark: isDark,
          ),
          _FeatureItem(
            icon: RemixIcons.smartphone_line,
            title: plan.maxConnectedAccounts >= 999
                ? 'Unlimited connected channels'
                : '${plan.maxConnectedAccounts} Connected account${plan.maxConnectedAccounts > 1 ? 's' : ''}',
            isDark: isDark,
          ),
          _FeatureItem(
            icon: RemixIcons.whatsapp_line,
            title: plan.whatsappIncluded
                ? 'WhatsApp Web QR Multi-Device'
                : 'WhatsApp not included',
            isEnabled: plan.whatsappIncluded,
            isDark: isDark,
          ),
          _FeatureItem(
            icon: RemixIcons.magic_line,
            title: plan.aiAutomationIncluded
                ? 'AI-Powered Auto Chat Assistant'
                : 'Standard keyword auto-replies',
            isEnabled: plan.aiAutomationIncluded,
            isHighlighted: plan.aiAutomationIncluded,
            isDark: isDark,
          ),
          _FeatureItem(
            icon: RemixIcons.team_line,
            title: plan.maxTeamMembers >= 999
                ? 'Unlimited team workspace seats'
                : '${plan.maxTeamMembers} Team member seat${plan.maxTeamMembers > 1 ? 's' : ''}',
            isDark: isDark,
          ),

          const SizedBox(height: 2),
        ],
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: card);
    }
    return card;
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.isDark,
    this.isEnabled = true,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String title;
  final bool isDark;
  final bool isEnabled;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: isEnabled
                  ? (isHighlighted
                        ? (isDark
                              ? AppColors.arcticBlue.withValues(alpha: 0.2)
                              : const Color(0xFFE0E7FF))
                        : (isDark
                              ? AppColors.darkCardMuted
                              : const Color(0xFFF1F5F9)))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Icon(
              isEnabled ? RemixIcons.check_line : RemixIcons.close_line,
              size: 11,
              color: isEnabled
                  ? (isHighlighted
                        ? (isDark
                              ? AppColors.arcticBlue
                              : AppColors.sapphireBlue)
                        : (isDark ? AppColors.silver : const Color(0xFF475569)))
                  : (isDark
                        ? AppColors.silver.withValues(alpha: 0.4)
                        : const Color(0xFFAAAAAA)),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                color: isEnabled
                    ? (isHighlighted
                          ? (isDark
                                ? AppColors.crispWhite
                                : AppColors.lightTextPrimary)
                          : (isDark
                                ? AppColors.silver
                                : AppColors.lightTextSecondary))
                    : (isDark
                          ? AppColors.silver.withValues(alpha: 0.4)
                          : const Color(0xFFAAAAAA)),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
