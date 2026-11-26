import 'package:emychat/features/channel/models/whatsapp_channel_model.dart';
import 'package:emychat/features/channel/providers/channel_provider.dart';
import 'package:emychat/features/channel/services/channel_service.dart';
import 'package:flutter_test/flutter_test.dart';

class MockChannelApiService implements ChannelApiService {
  int callCount = 0;
  List<WhatsAppChannelModel> mockChannels = [];

  @override
  Future<List<WhatsAppChannelModel>> getWhatsAppChannels() async {
    callCount++;
    return mockChannels;
  }

  @override
  Future<Map<String, dynamic>> connectWhatsApp({
    String? channelId,
    String? phoneNumber,
  }) async {
    return {'channelId': 'mock-id', 'status': 'SCAN_QR'};
  }

  @override
  Future<Map<String, dynamic>> getWhatsAppStatus(String channelId) async {
    return {'status': 'SCAN_QR'};
  }

  @override
  Future<void> disconnectWhatsApp(String channelId) async {}
}

void main() {
  group('ChannelController Stability Tests', () {
    late MockChannelApiService mockApi;
    late ChannelController controller;

    setUp(() {
      mockApi = MockChannelApiService();
      controller = ChannelController(channelApiService: mockApi);
    });

    test('loadChannels on empty response marks hasLoadedOnce and does not glitch', () async {
      expect(controller.hasLoadedOnce, isFalse);
      expect(controller.isLoading, isFalse);
      expect(controller.whatsAppAccounts, isEmpty);

      await controller.loadChannels();

      expect(mockApi.callCount, equals(1));
      expect(controller.hasLoadedOnce, isTrue);
      expect(controller.isLoading, isFalse);
      expect(controller.whatsAppAccounts, isEmpty);

      // Second call without force should be silent and not re-enter full loading
      await controller.loadChannels();
      expect(mockApi.callCount, equals(2));
      expect(controller.hasLoadedOnce, isTrue);
      expect(controller.isLoading, isFalse);
    });

    test('reset clears accounts and resets hasLoadedOnce flag', () async {
      await controller.loadChannels();
      expect(controller.hasLoadedOnce, isTrue);

      controller.reset();
      expect(controller.hasLoadedOnce, isFalse);
      expect(controller.whatsAppAccounts, isEmpty);
      expect(controller.isLoading, isFalse);
    });
  });
}
