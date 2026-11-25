import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/controller/theme_provider.dart';
import 'interactive_phone_demo.dart';

class WhatsAppShowcase extends StatelessWidget {
  const WhatsAppShowcase({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider?>();
    final isDark = themeProvider?.isDarkMode(context) ??
        (Theme.of(context).brightness == Brightness.dark);
    final screenWidth = MediaQuery.of(context).size.width;

    final titleColor = isDark ? AppColors.crispWhite : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.silver : AppColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.deepOceanGradient : AppColors.softSilverBlueGradient,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 24 : 32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            children: [
              // Section Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: isDark ? 0.15 : 0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF25D366).withValues(alpha: isDark ? 0.35 : 0.30),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(RemixIcons.whatsapp_fill, size: 13, color: Color(0xFF25D366)),
                    SizedBox(width: 5),
                    Text(
                      'WHATSAPP AUTOMATION ENGINE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF25D366),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Title (Preserves exact match for test: 'Direct Multi-Device WhatsApp Automation')
              Text(
                'Direct Multi-Device WhatsApp Automation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 22 : 32,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Text(
                  'Link your existing WhatsApp number in seconds via QR code. Reply instantly to customer questions, share catalogs, and qualify leads 24/7.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 12.5 : 14,
                    color: subColor,
                    height: 1.4,
                  ),
                ),
              ),

              SizedBox(height: isMobile ? 20 : 28),

              // Showcase Content: Phone Demo + 4 Minimal Capability Cards
              if (isMobile)
                Column(
                  children: [
                    InteractivePhoneDemo(
                      platform: PhoneDemoPlatform.whatsapp,
                      width: min(290.0, screenWidth - 32),
                      height: 430,
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureCards(context, isDark: isDark, isMobile: true),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      flex: 5,
                      child: Center(
                        child: InteractivePhoneDemo(
                          platform: PhoneDemoPlatform.whatsapp,
                          width: 295,
                          height: 480,
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                    Expanded(
                      flex: 6,
                      child: _buildFeatureCards(context, isDark: isDark, isMobile: false),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCards(BuildContext context, {required bool isDark, required bool isMobile}) {
    final features = [
      (
        RemixIcons.qr_code_line,
        '30-Second Web QR Link',
        'Pair directly using WhatsApp Linked Devices. Keep your phone number without waiting for Meta business verification.',
      ),
      (
        RemixIcons.flashlight_line,
        'Sub-Second AI Auto Replies',
        'Instant answers for services, product pricing, and opening hours with context-aware responses.',
      ),
      (
        RemixIcons.list_check_2,
        'Interactive Buttons & Lists',
        'Send structured menus, quick-reply chips, and product cards that reduce customer typing effort.',
      ),
      (
        RemixIcons.user_follow_line,
        'Automatic CRM Capture',
        'Every incoming phone number, contact name, and requirement is organized directly into your CRM directory.',
      ),
    ];

    return Column(
      children: [
        for (final (icon, title, desc) in features) ...[
          Container(
            margin: EdgeInsets.only(bottom: isMobile ? 8 : 10),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 14,
              vertical: isMobile ? 10 : 11,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 16, color: const Color(0xFF25D366)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.crispWhite : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.silver : AppColors.lightTextSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 8),

        // CTA Row
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.ctaGradient,
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sapphireBlue.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouter.pricing);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Connect WhatsApp',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 5),
                    Icon(RemixIcons.arrow_right_line, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
