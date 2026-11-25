import 'package:emychat/app/theme/app_colors.dart';
import 'package:emychat/core/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedRange = '30d';

  @override
  Widget build(BuildContext context) {
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
                // Page Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analytics & Performance',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Real-time metrics for delivery latency, volume, and AI auto-resolution.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    // Range Switcher
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          _buildRangeOption('7 Days', '7d'),
                          _buildRangeOption('30 Days', '30d'),
                          _buildRangeOption('90 Days', '90d'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4 Metric cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 4;
                    if (constraints.maxWidth < 640) {
                      crossAxisCount = 2;
                    } else if (constraints.maxWidth < 1024) {
                      crossAxisCount = 2;
                    }

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.5,
                      children: const [
                        _StatCard(
                          title: 'Delivery Rate',
                          value: '99.4%',
                          change: '+0.3% vs last period',
                          isPositive: true,
                          icon: RemixIcons.checkbox_circle_line,
                        ),
                        _StatCard(
                          title: 'Response Latency',
                          value: '1.2s',
                          change: '-180ms faster',
                          isPositive: true,
                          icon: RemixIcons.speed_up_line,
                        ),
                        _StatCard(
                          title: 'AI Auto-Resolution',
                          value: '81.6%',
                          change: '+4.2% automated',
                          isPositive: true,
                          icon: RemixIcons.robot_line,
                        ),
                        _StatCard(
                          title: 'Total Messages',
                          value: '24,190',
                          change: '+18% growth',
                          isPositive: true,
                          icon: RemixIcons.chat_voice_line,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Channel Volume Card
                const _ChannelVolumeCard(
                  title: 'WhatsApp Automation Protocol',
                  totalVolume: '24,190 messages',
                  icon: RemixIcons.whatsapp_line,
                  iconColor: AppColors.whatsapp,
                  inbound: '13,730',
                  outbound: '10,460',
                  avgResponse: '1.1s',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRangeOption(String label, String key) {
    final isSelected = _selectedRange == key;
    return InkWell(
      onTap: () => setState(() => _selectedRange = key),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
  });

  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 16, color: AppColors.textMuted),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? AppColors.mint : AppColors.warning,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChannelVolumeCard extends StatelessWidget {
  const _ChannelVolumeCard({
    required this.title,
    required this.totalVolume,
    required this.icon,
    required this.iconColor,
    required this.inbound,
    required this.outbound,
    required this.avgResponse,
  });

  final String title;
  final String totalVolume;
  final IconData icon;
  final Color iconColor;
  final String inbound;
  final String outbound;
  final String avgResponse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      totalVolume,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const StatusBadge(
                label: 'Active Sync',
                type: StatusType.active,
                isSmall: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem('Inbound', inbound),
              _buildDetailItem('Outbound', outbound),
              _buildDetailItem('Avg Latency', avgResponse),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
