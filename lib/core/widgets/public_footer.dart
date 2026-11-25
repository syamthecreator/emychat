import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../app/routes/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../constants/asset_constants.dart';

class PublicFooter extends StatelessWidget {
  const PublicFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.midnightNavy,
        border: Border(top: BorderSide(color: AppColors.darkBorderSubtle)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: 56,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              if (isMobile) ...[
                _buildBrandColumn(context),
                const SizedBox(height: 36),
                _buildLinksRow(context),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildBrandColumn(context)),
                    Expanded(flex: 2, child: _buildProductLinks(context)),
                    Expanded(flex: 2, child: _buildChannelLinks(context)),
                    Expanded(flex: 2, child: _buildLegalLinks(context)),
                  ],
                ),
              ],
              const SizedBox(height: 48),
              const Divider(color: AppColors.darkBorderSubtle),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      '© 2026 EmyChat Inc. All rights reserved. Ultra Premium Midnight Sapphire automation.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.silver,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.arcticBlue,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.arcticBlue.withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'All Systems Operational',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.silver,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: AppColors.ctaGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.arcticBlue.withValues(alpha: 0.25),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(5),
              child: Image.asset(
                AssetConstants.aLogo,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  RemixIcons.apps_2_fill,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'emy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.crispWhite,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextSpan(
                    text: 'chat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.silver,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Unified WhatsApp conversational automation platform. Manage high-converting customer journeys and intelligent AI workflows at scale.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.silver,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _SocialIcon(icon: RemixIcons.twitter_x_line, onTap: () {}),
            const SizedBox(width: 12),
            _SocialIcon(icon: RemixIcons.github_line, onTap: () {}),
            const SizedBox(width: 12),
            _SocialIcon(icon: RemixIcons.linkedin_line, onTap: () {}),
            const SizedBox(width: 12),
            _SocialIcon(icon: RemixIcons.whatsapp_line, onTap: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildLinksRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildProductLinks(context)),
        Expanded(child: _buildChannelLinks(context)),
        Expanded(child: _buildLegalLinks(context)),
      ],
    );
  }

  Widget _buildProductLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PRODUCT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.arcticBlue,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 14),
        _FooterLink(
          label: 'Overview',
          onTap: () {
            Navigator.of(context).pushReplacementNamed(AppRouter.landing);
          },
        ),
        _FooterLink(
          label: 'Features',
          onTap: () {
            Navigator.of(context).pushReplacementNamed(AppRouter.landing);
          },
        ),
        _FooterLink(
          label: 'Pricing Plans',
          onTap: () {
            Navigator.of(context).pushNamed(AppRouter.pricing);
          },
        ),
        _FooterLink(
          label: 'Roadmap & Changelog',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildChannelLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHANNELS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.arcticBlue,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 14),
        _FooterLink(
          label: 'WhatsApp Web Automation',
          onTap: () {
            Navigator.of(context).pushReplacementNamed(AppRouter.landing);
          },
        ),
        _FooterLink(
          label: 'AI Intent Engine',
          onTap: () {},
        ),
        _FooterLink(
          label: 'Dedicated Inbox',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildLegalLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'COMPANY & TRUST',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.arcticBlue,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 14),
        _FooterLink(label: 'Security Overview', onTap: () {}),
        _FooterLink(label: 'Privacy Policy', onTap: () {}),
        _FooterLink(label: 'Terms of Service', onTap: () {}),
        _FooterLink(label: 'Meta Cloud API Compliance', onTap: () {}),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.silver,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkBorderSubtle),
        ),
        child: Icon(
          icon,
          size: 15,
          color: AppColors.silver,
        ),
      ),
    );
  }
}
