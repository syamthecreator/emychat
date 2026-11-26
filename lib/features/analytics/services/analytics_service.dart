import 'package:remixicon/remixicon.dart';
import 'package:emychat/app/theme/app_colors.dart';
import 'package:emychat/core/network/api_client.dart';
import '../models/analytics_model.dart';

class AnalyticsService {
  AnalyticsService({this.apiClient});

  // ignore: unused_field
  final ApiClient? apiClient;

  Future<AnalyticsOverviewModel> fetchAnalyticsOverview(String range) async {
    // In production, queries backend API with range. Default strongly typed mock dataset:
    return AnalyticsOverviewModel(
      range: range,
      stats: const [
        MetricStatModel(
          title: 'Delivery Rate',
          value: '99.4%',
          change: '+0.3% vs last period',
          isPositive: true,
          icon: RemixIcons.checkbox_circle_line,
        ),
        MetricStatModel(
          title: 'Response Latency',
          value: '1.2s',
          change: '-180ms faster',
          isPositive: true,
          icon: RemixIcons.speed_up_line,
        ),
        MetricStatModel(
          title: 'AI Auto-Resolution',
          value: '81.6%',
          change: '+4.2% automated',
          isPositive: true,
          icon: RemixIcons.robot_line,
        ),
        MetricStatModel(
          title: 'Total Messages',
          value: '24,190',
          change: '+18% growth',
          isPositive: true,
          icon: RemixIcons.chat_voice_line,
        ),
      ],
      channelVolume: const ChannelVolumeModel(
        title: 'WhatsApp Automation Protocol',
        totalVolume: '24,190 messages',
        icon: RemixIcons.whatsapp_line,
        iconColor: AppColors.whatsapp,
        inbound: '13,730',
        outbound: '10,460',
        avgResponse: '1.1s',
      ),
    );
  }
}
