import 'package:emychat/features/inbox/models/inbox_message_model.dart'
    show InboxMessageModel;

import '../models/inbox_conversation_model.dart';
import '../models/inbox_stats_model.dart';
import '../services/inbox_service.dart';

class InboxRepository {
  InboxRepository({required this.apiService});

  final InboxApiService apiService;

  Future<List<InboxConversationModel>> getConversations({
    String? channelType,
    String? channelId,
    String? status,
    String? search,
    String? tag,
    int limit = 50,
    int offset = 0,
  }) => apiService.getConversations(
    channelType: channelType,
    channelId: channelId,
    status: status,
    search: search,
    tag: tag,
    limit: limit,
    offset: offset,
  );

  Future<List<InboxMessageModel>> getMessages(
    String contactId, {
    int limit = 50,
    String? before,
  }) => apiService.getMessages(contactId, limit: limit, before: before);

  Future<InboxStatsModel> getStats({String? channelId, String? channelType}) =>
      apiService.getStats(channelId: channelId, channelType: channelType);

  Future<InboxMessageModel> sendMessage(
    String contactId, {
    String? text,
    String? mediaUrl,
    String? mediaType,
    String? replyToMetaMessageId,
    List<Map<String, String>>? quickReplies,
  }) => apiService.sendMessage(
    contactId,
    text: text,
    mediaUrl: mediaUrl,
    mediaType: mediaType,
    replyToMetaMessageId: replyToMetaMessageId,
    quickReplies: quickReplies,
  );
}
