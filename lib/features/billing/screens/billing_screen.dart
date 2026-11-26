import 'package:emychat/features/pricing/screens/pricing_screen.dart';
import 'package:emychat/features/subscription/providers/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../widgets/usage_meter_widget.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subController = context.watch<SubscriptionController?>();
    final activeSub = subController?.activeSubscription;
    final planName = activeSub?.planName ?? 'Growth Plan';
    final planPrice = activeSub != null ? '\$${activeSub.amount}' : '\$79';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Billing & Subscription',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Manage your subscription tier, billing period, and platform resource limits.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    AppButton.primary(
                      text: 'Upgrade Plan',
                      icon: RemixIcons.vip_crown_line,
                      size: AppButtonSize.sm,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PricingScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Current Plan Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  planName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const StatusBadge(
                                  label: 'Active',
                                  type: StatusType.active,
                                  isSmall: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Renews automatically on Dec 15, 2026 via card on file.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$planPrice / month',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Text(
                            'Billed monthly, cancel anytime',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Resource Usage Meters
                const Text(
                  'Resource Entitlements & Usage',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 900;
                    if (isDesktop) {
                      return const Row(
                        children: [
                          Expanded(
                            child: UsageMeterWidget(
                              label: 'Connected Channels',
                              used: 2,
                              max: 5,
                              unit: 'channels',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: UsageMeterWidget(
                              label: 'AI Automation Tokens',
                              used: 124000,
                              max: 300000,
                              unit: 'tokens',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: UsageMeterWidget(
                              label: 'Monthly Conversations',
                              used: 840,
                              max: 2500,
                              unit: 'conversations',
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Column(
                        children: [
                          UsageMeterWidget(
                            label: 'Connected Channels',
                            used: 2,
                            max: 5,
                            unit: 'channels',
                          ),
                          SizedBox(height: 10),
                          UsageMeterWidget(
                            label: 'AI Automation Tokens',
                            used: 124000,
                            max: 300000,
                            unit: 'tokens',
                          ),
                          SizedBox(height: 10),
                          UsageMeterWidget(
                            label: 'Monthly Conversations',
                            used: 840,
                            max: 2500,
                            unit: 'conversations',
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Invoices Table
                const Text(
                  'Recent Invoices',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          color: AppColors.surfaceMuted,
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'INVOICE ID',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'DATE',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'AMOUNT',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'STATUS',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 30),
                            ],
                          ),
                        ),
                        _buildInvoiceRow(
                          'INV-2026-1102',
                          'Nov 15, 2026',
                          '\$79.00',
                          'Paid',
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 1),
                        _buildInvoiceRow(
                          'INV-2026-1014',
                          'Oct 15, 2026',
                          '\$79.00',
                          'Paid',
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
    );
  }

  Widget _buildInvoiceRow(
    String id,
    String date,
    String amount,
    String status,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              id,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              amount,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                label: 'Paid',
                type: StatusType.active,
                isSmall: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              RemixIcons.download_line,
              color: AppColors.textMuted,
              size: 16,
            ),
            onPressed: () {},
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}
