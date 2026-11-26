import 'package:emychat/features/channel/models/whatsapp_channel_model.dart';
import 'package:emychat/features/channel/services/channel_service.dart';

class ChannelRepository {
  ChannelRepository({required this.apiService});

  final ChannelApiService apiService;

  Future<List<WhatsAppChannelModel>> getWhatsAppChannels() =>
      apiService.getWhatsAppChannels();

  Future<Map<String, dynamic>> connectWhatsApp({
    String? channelId,
    String? phoneNumber,
  }) => apiService.connectWhatsApp(
    channelId: channelId,
    phoneNumber: phoneNumber,
  );

  Future<Map<String, dynamic>> getWhatsAppStatus(String channelId) =>
      apiService.getWhatsAppStatus(channelId);

  Future<void> disconnectWhatsApp(String channelId) =>
      apiService.disconnectWhatsApp(channelId);
}
