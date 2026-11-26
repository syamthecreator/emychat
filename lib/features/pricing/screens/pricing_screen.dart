import 'package:emychat/features/pricing/providers/pricing_provider.dart';
import 'package:emychat/features/pricing/widgets/billing_cycle_toggle.dart';
import 'package:emychat/features/pricing/widgets/compact_pricing_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/controller/theme_provider.dart';
import '../../../../core/widgets/public_footer.dart';
import '../../../../core/widgets/public_navbar.dart';
import '../models/pricing_plan_model.dart';
import '../widgets/pricing_faq_tile.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  void _onChoosePlan(BuildContext context, PricingPlanModel plan) {
    context.read<PricingController>().selectPlan(plan);
    Navigator.of(context).pushNamed(AppRouter.register, arguments: plan.slug);
  }

  @override
  Widget build(BuildContext context) {
    final pricing = context.watch<PricingController>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isDesktop = screenWidth >= 1020;

    final bgColor = isDark ? AppColors.deepNavy : AppColors.lightBackground;
    final textTitleColor = isDark
        ? AppColors.crispWhite
        : AppColors.lightTextPrimary;
    final textSubColor = isDark
        ? AppColors.silver
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const PublicNavbar(currentRoute: '/pricing'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Ultra-Compact Page Header (Designed to keep pricing cards completely above the fold)
            Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppColors.heroGradient
                    : AppColors.softSilverBlueGradient,
              ),
              padding: EdgeInsets.fromLTRB(
                isMobile ? 18 : 32,
                isMobile ? 24 : 36,
                isMobile ? 18 : 32,
                isMobile ? 16 : 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCardMuted
                              : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Text(
                          'PLANS & PRICING',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.arcticBlue
                                : AppColors.sapphireBlue,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Simple, Scalable Pricing for Modern Messaging',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 34,
                          fontWeight: FontWeight.w800,
                          color: textTitleColor,
                          letterSpacing: -0.8,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: Text(
                          'Choose the ideal capacity for your WhatsApp numbers and AI automations. Scale up or pause at any time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: textSubColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Sleek Segmented Billing Cycle Switcher
                      BillingCycleToggle(
                        isYearly: pricing.isYearly,
                        onChanged: (yearly) => pricing.toggleBilling(yearly),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. High-Density, Balanced Pricing Cards (Visible above the fold on Desktop)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isDesktop ? 32 : 24),
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: isDesktop
                      ? IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final plan in pricing.plans)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: CompactPricingCard(
                                      plan: plan,
                                      isYearly: pricing.isYearly,
                                      onSelect: () =>
                                          _onChoosePlan(context, plan),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            for (final plan in pricing.plans)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: CompactPricingCard(
                                  plan: plan,
                                  isYearly: pricing.isYearly,
                                  onSelect: () => _onChoosePlan(context, plan),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 52),

            // 3. Feature Comparison Table
            _FeatureComparisonSection(
              plans: pricing.plans,
              isMobile: isMobile,
              isDark: isDark,
              onChoosePlan: (plan) => _onChoosePlan(context, plan),
            ),

            const SizedBox(height: 56),

            // 4. FAQ Section
            _FaqSection(isMobile: isMobile, isDark: isDark),

            const SizedBox(height: 56),

            // 5. Footer
            const PublicFooter(),
          ],
        ),
      ),
    );
  }
}

class _FeatureComparisonSection extends StatelessWidget {
  const _FeatureComparisonSection({
    required this.plans,
    required this.isMobile,
    required this.isDark,
    required this.onChoosePlan,
  });

  final List<PricingPlanModel> plans;
  final bool isMobile;
  final bool isDark;
  final ValueChanged<PricingPlanModel> onChoosePlan;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark
        ? AppColors.crispWhite
        : AppColors.lightTextPrimary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardMuted : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  'DETAILED BREAKDOWN',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.arcticBlue
                        : AppColors.sapphireBlue,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Compare All Features Across Tiers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: isMobile ? 650 : 1050,
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          isDark
                              ? AppColors.midnightNavy
                              : const Color(0xFFF1F5F9),
                        ),
                        horizontalMargin: 20,
                        columnSpacing: 24,
                        columns: [
                          DataColumn(
                            label: Text(
                              'Feature & Capability',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                            ),
                          ),
                          for (final p in plans)
                            DataColumn(
                              label: Center(
                                child: Text(
                                  p.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: p.isPopular
                                        ? (isDark
                                              ? AppColors.arcticBlue
                                              : AppColors.sapphireBlue)
                                        : (isDark
                                              ? AppColors.silver
                                              : const Color(0xFF475569)),
                                  ),
                                ),
                              ),
                            ),
                        ],
                        rows: [
                          _buildRow('WhatsApp Web QR Code Sync', [
                            '1 Number',
                            'Up to 3 Numbers',
                            'Up to 10 Numbers',
                          ]),
                          _buildRow('Monthly Automation Messages', [
                            '5,000 /mo',
                            '25,000 /mo',
                            'Unlimited',
                          ]),
                          _buildRow('Team Collaboration Seats', [
                            '1 Seat',
                            '3 Seats',
                            'Unlimited',
                          ]),
                          _buildCheckRow('Anti-Ban Browser Emulation', [
                            true,
                            true,
                            true,
                          ]),
                          _buildCheckRow('Keyword Auto-Responder', [
                            true,
                            true,
                            true,
                          ]),
                          _buildCheckRow('Interactive Quick Menu Buttons', [
                            true,
                            true,
                            true,
                          ]),
                          _buildCheckRow('Unified Live Team Inbox', [
                            true,
                            true,
                            true,
                          ]),
                          _buildCheckRow('AI Contextual Reasoning & FAQs', [
                            false,
                            true,
                            true,
                          ]),
                          _buildCheckRow('Custom AI Fine-Tuning & Persona', [
                            false,
                            false,
                            true,
                          ]),
                          _buildCheckRow('Webhooks & Developer REST API', [
                            false,
                            false,
                            true,
                          ]),
                          _buildRow('Support SLA', [
                            'Standard Email',
                            'Priority Chat & Email',
                            'Dedicated Account Manager',
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(String title, List<String> values) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.crispWhite : AppColors.lightTextPrimary,
            ),
          ),
        ),
        for (final val in values)
          DataCell(
            Text(
              val,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.silver : AppColors.lightTextSecondary,
              ),
            ),
          ),
      ],
    );
  }

  DataRow _buildCheckRow(String title, List<bool> checks) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.crispWhite : AppColors.lightTextPrimary,
            ),
          ),
        ),
        for (final check in checks)
          DataCell(
            Center(
              child: Icon(
                check ? RemixIcons.check_line : RemixIcons.close_line,
                size: 16,
                color: check
                    ? (isDark ? AppColors.arcticBlue : AppColors.sapphireBlue)
                    : (isDark ? AppColors.darkBorder : const Color(0xFFCCCCCC)),
              ),
            ),
          ),
      ],
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection({required this.isMobile, required this.isDark});

  final bool isMobile;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark
        ? AppColors.crispWhite
        : AppColors.lightTextPrimary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardMuted : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  'FREQUENTLY ASKED QUESTIONS',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.arcticBlue
                        : AppColors.sapphireBlue,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Everything You Need to Know',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 24),
              PricingFaqTile(
                question: 'Can I keep using WhatsApp on my physical phone?',
                answer: 'Yes, 100%! EmyChat connects via official WhatsApp Web multi-device protocol. Your personal or business WhatsApp continues working on your phone without interruption.',
                isDark: isDark,
              ),
              PricingFaqTile(
                question: 'How does Anti-Ban protection work?',
                answer: 'Our engine identifies to WhatsApp servers using genuine Mac OS Google Chrome signatures, implements randomized natural human typing pauses (1.0–1.8s), and verifies recipient JIDs before dispatching messages.',
                isDark: isDark,
              ),
              PricingFaqTile(
                question: 'Can I switch or cancel my plan at any time?',
                answer: 'Yes. Upgrades and downgrades are prorated immediately. You can cancel with a single click in your workspace settings with no lock-in.',
                isDark: isDark,
              ),
              PricingFaqTile(
                question: 'Do you offer custom enterprise limits?',
                answer: 'Yes. If your messaging fleet exceeds 50,000 conversations/mo or requires multiple dedicated WhatsApp multi-device sockets, contact our team for custom infrastructure.',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
