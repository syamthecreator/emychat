import 'dart:math';

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
import '../providers/landing_provider.dart';
import '../repositories/landing_repository.dart';
import '../services/landing_service.dart';
import '../../../../core/network/api_client.dart';
import '../widgets/interactive_phone_demo.dart';
import '../widgets/whatsapp_showcase.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LandingProvider>(
      create: (ctx) => LandingProvider(
        landingRepository: LandingRepository(
          landingService: LandingService(apiClient: ctx.read<ApiClient>()),
        ),
        initialTab: initialTab,
      ),
      child: const _LandingView(),
    );
  }
}

class _LandingView extends StatefulWidget {
  const _LandingView();

  @override
  State<_LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<_LandingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PricingController>().loadPlans();
    });
  }

  void _onSelectTab(int index) {
    context.read<LandingProvider>().selectTab(index);
  }

  @override
  Widget build(BuildContext context) {
    final landing = context.watch<LandingProvider>();
    final activeTab = landing.activeTab;
    final scrollController = landing.scrollController;
    final themeProvider = context.watch<ThemeProvider?>();
    final isDark =
        themeProvider?.isDarkMode(context) ??
        (Theme.of(context).brightness == Brightness.dark);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final bgColor = isDark ? AppColors.deepNavy : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PublicNavbar(
        currentRoute: '/',
        selectedTab: activeTab,
        onTabSelected: _onSelectTab,
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            // Responsive mobile tabs bar (visible on mobile viewports <768px)
            if (screenWidth < 768)
              _buildMobileTabBar(isDark: isDark, activeTab: activeTab),

            // Dynamic Content Section that switches without reloading the page or navbar
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey('tab_${activeTab}_dark_$isDark'),
                child: _buildTabContent(
                  isMobile,
                  isDark: isDark,
                  activeTab: activeTab,
                  scrollController: scrollController,
                ),
              ),
            ),

            // Persistent Minimal Footer
            const PublicFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTabBar({required bool isDark, required int activeTab}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorder,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildMobileTabChip(
              'Features',
              0,
              isDark: isDark,
              activeTab: activeTab,
            ),
            const SizedBox(width: 6),
            _buildMobileTabChip(
              'Pricing',
              1,
              isDark: isDark,
              activeTab: activeTab,
            ),
            const SizedBox(width: 6),
            _buildMobileTabChip(
              'WhatsApp',
              2,
              icon: RemixIcons.whatsapp_line,
              isDark: isDark,
              activeTab: activeTab,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTabChip(
    String label,
    int index, {
    required bool isDark,
    required int activeTab,
    IconData? icon,
  }) {
    final isSelected = activeTab == index;
    return InkWell(
      onTap: () => _onSelectTab(index),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.arcticBlue : AppColors.sapphireBlue)
              : (isDark ? AppColors.darkCard : AppColors.lightCardMuted),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.arcticBlue : AppColors.sapphireBlue)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected
                    ? (isDark ? AppColors.midnightNavy : Colors.white)
                    : (isDark
                          ? AppColors.silver
                          : AppColors.lightTextSecondary),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.midnightNavy : Colors.white)
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

  Widget _buildTabContent(
    bool isMobile, {
    required bool isDark,
    required int activeTab,
    required ScrollController scrollController,
  }) {
    switch (activeTab) {
      case 0:
        return _buildFeaturesAndOverviewTab(isMobile, isDark: isDark);
      case 1:
        return _buildPricingTab(isMobile, isDark: isDark);
      case 2:
        return WhatsAppShowcase(isMobile: isMobile);
      default:
        return _buildFeaturesAndOverviewTab(isMobile, isDark: isDark);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 0: FEATURES & MAIN HOMEPAGE OVERVIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFeaturesAndOverviewTab(bool isMobile, {required bool isDark}) {
    return Column(
      children: [
        // 1. Ultra Premium Integrated Hero Section (With Live Responsive Simulation)
        _buildHeroSection(isMobile, isDark: isDark),

        // 2. WhatsApp Automation Platform Teaser
        _buildPlatformTabsTeaser(isMobile, isDark: isDark),

        // 3. Core Features Grid
        _buildCoreFeaturesSection(isMobile, isDark: isDark),

        // 4. Final CTA Banner
        _buildFinalCtaSection(isMobile, isDark: isDark),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HERO SECTION (INTEGRATED RESPONSIVE 2-COLUMN ON DESKTOP, CLEAN STACK ON MOBILE)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeroSection(bool isMobile, {required bool isDark}) {
    final titleColor = isDark
        ? AppColors.crispWhite
        : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.silver : AppColors.lightTextSecondary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 980;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.heroGradient
            : AppColors.softSilverBlueGradient,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : (isDesktop ? 36 : 24),
        vertical: isMobile ? 24 : (isDesktop ? 36 : 30),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Column: Headline, Copy, CTAs, Trust points
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroEyebrow(isDark),
                          const SizedBox(height: 16),
                          Text(
                            'Turn Every Conversation\nInto a Customer.',
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              letterSpacing: -1.2,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Text(
                              'Automate WhatsApp conversations, respond instantly, and grow your business with AI-powered messaging.',
                              style: TextStyle(
                                fontSize: 14.5,
                                color: subColor,
                                height: 1.45,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _buildHeroCtas(
                            false,
                            isDark: isDark,
                            titleColor: titleColor,
                            subColor: subColor,
                          ),
                          const SizedBox(height: 18),
                          _buildHeroTrustRow(isDark, subColor),
                          const SizedBox(height: 12),
                          _buildHeroSignInLink(isDark, subColor),
                        ],
                      ),
                    ),
                    const SizedBox(width: 36),
                    // Right Column: Realistic Interactive Phone Demo
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 250,
                              height: 400,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.arcticBlue.withValues(
                                      alpha: isDark ? 0.16 : 0.08,
                                    ),
                                    blurRadius: 70,
                                    spreadRadius: 15,
                                  ),
                                ],
                              ),
                            ),
                            const InteractivePhoneDemo(
                              platform: PhoneDemoPlatform.neutral,
                              width: 295,
                              height: 480,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildHeroEyebrow(isDark),
                    const SizedBox(height: 14),
                    Text(
                      'Turn Every Conversation\nInto a Customer.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 28 : 36,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        letterSpacing: -0.8,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 540),
                      child: Text(
                        'Automate WhatsApp conversations, respond instantly, and grow your business with AI-powered messaging.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14.5,
                          color: subColor,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildHeroCtas(
                      isMobile,
                      isDark: isDark,
                      titleColor: titleColor,
                      subColor: subColor,
                    ),
                    const SizedBox(height: 14),
                    _buildHeroSignInLink(isDark, subColor),
                    const SizedBox(height: 22),
                    InteractivePhoneDemo(
                      platform: PhoneDemoPlatform.neutral,
                      width: min(290.0, screenWidth - 32),
                      height: 430,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeroEyebrow(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4.5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardMuted : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.arcticBlue.withValues(alpha: isDark ? 0.12 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            RemixIcons.sparkling_fill,
            size: 13,
            color: isDark ? AppColors.arcticBlue : AppColors.sapphireBlue,
          ),
          const SizedBox(width: 7),
          Text(
            'Automate Conversations.\nGrow Your Business.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.crispWhite : AppColors.lightTextPrimary,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCtas(
    bool isMobile, {
    required bool isDark,
    required Color titleColor,
    required Color subColor,
  }) {
    return Wrap(
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
      spacing: 10,
      runSpacing: 8,
      children: [
        // Primary Gradient CTA: Get Started Free
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.ctaGradient,
            borderRadius: BorderRadius.circular(7),
            boxShadow: [
              BoxShadow(
                color: AppColors.sapphireBlue.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => _onSelectTab(1),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get Started Free',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 5),
                Icon(RemixIcons.arrow_right_line, size: 14),
              ],
            ),
          ),
        ),

        // Secondary CTA: View Pricing Plans
        OutlinedButton(
          onPressed: () => _onSelectTab(1),
          style: OutlinedButton.styleFrom(
            foregroundColor: subColor,
            backgroundColor: isDark
                ? AppColors.darkCardMuted.withValues(alpha: 0.5)
                : Colors.transparent,
            side: BorderSide(
              color: isDark
                  ? AppColors.darkBorderSubtle
                  : const Color(0xFFCBD5E1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          child: const Text(
            'View Pricing Plans',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),

        // Tertiary CTA: Explore Features
        OutlinedButton(
          onPressed: () {
            context.read<LandingProvider>().scrollController.animateTo(
              isMobile ? 480 : 540,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: titleColor,
            backgroundColor: isDark
                ? AppColors.darkCard.withValues(alpha: 0.7)
                : Colors.white,
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                RemixIcons.play_circle_line,
                size: 15,
                color: isDark ? AppColors.arcticBlue : AppColors.sapphireBlue,
              ),
              const SizedBox(width: 5),
              const Text(
                'Explore Features',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroTrustRow(bool isDark, Color subColor) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              RemixIcons.flashlight_fill,
              size: 12,
              color: AppColors.arcticBlue,
            ),
            const SizedBox(width: 4),
            Text(
              '< 800ms Latency',
              style: TextStyle(
                fontSize: 11,
                color: subColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text('•', style: TextStyle(color: subColor.withValues(alpha: 0.5))),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              RemixIcons.qr_code_line,
              size: 12,
              color: Color(0xFF25D366),
            ),
            const SizedBox(width: 4),
            Text(
              '30s QR Link',
              style: TextStyle(
                fontSize: 11,
                color: subColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text('•', style: TextStyle(color: subColor.withValues(alpha: 0.5))),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              RemixIcons.shield_check_line,
              size: 12,
              color: AppColors.arcticBlue,
            ),
            const SizedBox(width: 4),
            Text(
              'Meta Verified',
              style: TextStyle(
                fontSize: 11,
                color: subColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroSignInLink(bool isDark, Color subColor) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Already an active customer? ',
          style: TextStyle(fontSize: 12, color: subColor),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(AppRouter.login);
          },
          child: Text(
            'Sign In',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.arcticBlue : AppColors.sapphireBlue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PLATFORM TABS TEASER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPlatformTabsTeaser(bool isMobile, {required bool isDark}) {
    final titleColor = isDark
        ? AppColors.crispWhite
        : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.silver : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy : const Color(0xFFF8FAFC),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorder,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 36,
        vertical: isMobile ? 28 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            children: [
              Text(
                'Two Channels. One Unified AI Engine.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 20 : 26,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Select a channel to explore its dedicated automated capabilities.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: subColor),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  InkWell(
                    onTap: () => _onSelectTab(2),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF25D366).withValues(alpha: 0.12)
                            : const Color(0xFFF7FDF9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF25D366)
                              .withValues(alpha: isDark ? 0.4 : 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            RemixIcons.whatsapp_fill,
                            color: Color(0xFF25D366),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'WhatsApp Automation',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF25D366),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            RemixIcons.arrow_right_line,
                            color: Color(0xFF25D366),
                            size: 13,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CORE FEATURES SECTION (DEEP SAPPHIRE OCEAN / SOFT SILVER)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCoreFeaturesSection(bool isMobile, {required bool isDark}) {
    final titleColor = isDark
        ? AppColors.crispWhite
        : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.silver : AppColors.lightTextSecondary;

    final features = [
      (
        RemixIcons.robot_line,
        'AI-Powered Auto Replies',
        'Recognize customer intent instantly and generate natural, contextual replies in sub-second latency.',
      ),
      (
        RemixIcons.whatsapp_line,
        'WhatsApp Web QR Engine',
        'Connect directly via Baileys socket. Keep your existing phone number with zero Meta setup hurdles.',
      ),
      (
        RemixIcons.flashlight_line,
        'Smart Keyword Triggers',
        'Trigger automated responses, lead capture flows, and media attachments immediately on keyword match.',
      ),
      (
        RemixIcons.inbox_line,
        'Unified Shared Inbox',
        'Consolidate every WhatsApp chat into one collaborative workspace for your team.',
      ),
      (
        RemixIcons.contacts_book_line,
        'Automatic Lead Capture',
        'Capture contact names, phone numbers, and inquiry details into persistent CRM records automatically.',
      ),
      (
        RemixIcons.flow_chart,
        'Smart Conversation Workflows',
        'Build custom branching logic for off-hours replies, discount code delivery, and lead qualification.',
      ),
      (
        RemixIcons.user_shared_line,
        'Human-in-the-Loop Handoff',
        'AI pauses automatically when your human team responds, ensuring a seamless experience.',
      ),
      (
        RemixIcons.line_chart_line,
        'Real-Time Analytics',
        'Track inbound volume, average response times, and AI automation resolution rate in live charts.',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.deepOceanGradient : null,
        color: isDark ? null : const Color(0xFFF8FAFC),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 36,
        vertical: isMobile ? 48 : 68,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
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
                  'ENGINE CAPABILITIES',
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
                'Everything You Need To Scale Conversations',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 24 : 34,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: -0.6,
                ),
              ),

              const SizedBox(height: 36),

              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 640
                      ? 1
                      : (constraints.maxWidth < 1000 ? 2 : 4);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: features.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: constraints.maxWidth < 640
                          ? 1.9
                          : (constraints.maxWidth < 1000 ? 1.55 : 1.35),
                    ),
                    itemBuilder: (context, index) {
                      final (icon, title, desc) = features[index];
                      final isNarrow = constraints.maxWidth < 640;
                      return Container(
                        padding: EdgeInsets.all(isNarrow ? 14 : 18),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.03,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.arcticBlue.withValues(
                                        alpha: 0.12,
                                      )
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                size: 17,
                                color: isDark
                                    ? AppColors.arcticBlue
                                    : AppColors.sapphireBlue,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: isNarrow ? 13 : 14,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              desc,
                              style: TextStyle(
                                fontSize: isNarrow ? 11 : 12,
                                color: subColor,
                                height: 1.35,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FINAL CALL TO ACTION BANNER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFinalCtaSection(bool isMobile, {required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.deepNavy : Colors.white,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 36,
        vertical: isMobile ? 48 : 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 22 : 44,
              vertical: isMobile ? 32 : 48,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sapphireBlue.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Start Automating Conversations Today',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: const Text(
                    'Connect WhatsApp in 30 seconds via QR Code with zero setup hurdles.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.silver,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.ctaGradient,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.arcticBlue.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _onSelectTab(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Get Started Now',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(RemixIcons.arrow_right_line, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1: PRICING SECTION (DYNAMIC THEME SUPPORT)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPricingTab(bool isMobile, {required bool isDark}) {
    final pricing = context.watch<PricingController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1020;

    final titleColor = isDark
        ? AppColors.crispWhite
        : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.silver : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.heroGradient
            : AppColors.softSilverBlueGradient,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
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
                  'PRICING & ENTITLEMENTS',
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
                  color: titleColor,
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
                    color: subColor,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Segmented Toggle
              BillingCycleToggle(
                isYearly: pricing.isYearly,
                onChanged: (yearly) => pricing.toggleBilling(yearly),
              ),

              const SizedBox(height: 24),

              // 3 Pricing Cards (Uniform height & perfectly aligned)
              if (isDesktop)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final plan in pricing.plans)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: CompactPricingCard(
                              plan: plan,
                              isYearly: pricing.isYearly,
                              onSelect: () {
                                pricing.selectPlan(plan);
                                Navigator.of(context).pushNamed(
                                  AppRouter.register,
                                  arguments: plan.slug,
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    for (final plan in pricing.plans)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CompactPricingCard(
                          plan: plan,
                          isYearly: pricing.isYearly,
                          onSelect: () {
                            pricing.selectPlan(plan);
                            Navigator.of(context).pushNamed(
                              AppRouter.register,
                              arguments: plan.slug,
                            );
                          },
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
