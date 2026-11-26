import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:emychat/app/theme/app_colors.dart';
import '../providers/analytics_provider.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/channel_volume_card_widget.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = context.watch<AnalyticsProvider>();
    final stats = analyticsProvider.stats;
    final channelVolume = analyticsProvider.channelVolume;

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
                          _buildRangeOption(analyticsProvider, '7 Days', '7d'),
                          _buildRangeOption(analyticsProvider, '30 Days', '30d'),
                          _buildRangeOption(analyticsProvider, '90 Days', '90d'),
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
                      children: stats.map((s) {
                        return StatCardWidget(
                          title: s.title,
                          value: s.value,
                          change: s.change,
                          isPositive: s.isPositive,
                          icon: s.icon,
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Channel Volume Card
                if (channelVolume != null)
                  ChannelVolumeCardWidget(
                    title: channelVolume.title,
                    totalVolume: channelVolume.totalVolume,
                    icon: channelVolume.icon,
                    iconColor: channelVolume.iconColor,
                    inbound: channelVolume.inbound,
                    outbound: channelVolume.outbound,
                    avgResponse: channelVolume.avgResponse,
                  )
                else
                  const ChannelVolumeCardWidget(
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

  Widget _buildRangeOption(AnalyticsProvider provider, String label, String key) {
    final isSelected = provider.selectedRange == key;
    return InkWell(
      onTap: () => provider.setSelectedRange(key),
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
