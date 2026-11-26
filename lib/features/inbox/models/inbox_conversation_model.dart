import 'inbox_message_model.dart';

class InboxConversationModel {
  final String id;
  final String channelType; // 'WHATSAPP'
  final String channelId;
  final String? jid;
  final String? phoneNumber;
  final String? username;
  final String? name;
  final String? profilePic;
  final List<String> tags;
  final int unreadCount;
  final String? lastMessageText;
  final String? lastMessageType;
  final DateTime? lastMessageAt;
  final bool isArchived;
  final bool isPinned;
  final String? notes;
  final String? channelUsername;
  final int messagesCount;
  final List<InboxMessageModel> messages;

  const InboxConversationModel({
    required this.id,
    this.channelType = 'WHATSAPP',
    this.channelId = '',
    this.jid,
    this.phoneNumber,
    this.username,
    this.name,
    this.profilePic,
    this.tags = const [],
    this.unreadCount = 0,
    this.lastMessageText,
    this.lastMessageType,
    this.lastMessageAt,
    this.isArchived = false,
    this.isPinned = false,
    this.notes,
    this.channelUsername,
    this.messagesCount = 0,
    this.messages = const [],
  });

  bool get isWhatsApp => true;

  // Display helpers
  String get contactName {
    if (name != null && name!.trim().isNotEmpty) {
      return name!.trim();
    }
    if (username != null && username!.trim().isNotEmpty) {
      return username!.trim();
    }
    if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) {
      return phoneNumber!.trim();
    }
    if (jid != null && jid!.trim().isNotEmpty) {
      return jid!.split('@').first;
    }
    return 'Unknown Contact';
  }

  String get handle {
    if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) {
      return phoneNumber!.trim();
    }
    if (username != null && username!.trim().isNotEmpty) {
      final u = username!.trim();
      return u.startsWith('@') ? u : '@$u';
    }
    if (jid != null && jid!.trim().isNotEmpty) {
      return jid!.split('@').first;
    }
    return '';
  }

  String get channel => 'WhatsApp';

  String get preview => lastMessageText?.trim() ?? 'No messages yet';

  String get timeAgo {
    if (lastMessageAt == null) return '';
    final diff = DateTime.now().difference(lastMessageAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final m = lastMessageAt!.month;
    final d = lastMessageAt!.day;
    return '$d/${m < 10 ? '0$m' : m}';
  }

  String get initials {
    final cn = contactName;
    if (cn.isEmpty) return '?';
    final parts = cn.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return cn[0].toUpperCase();
  }

  factory InboxConversationModel.mock({
    required String id,
    String? name,
    String? phoneNumber,
    String? preview,
    int unreadCount = 0,
    List<String> tags = const [],
    DateTime? lastMessageAt,
    bool isPinned = false,
    List<InboxMessageModel> messages = const [],
  }) {
    return InboxConversationModel(
      id: id,
      channelType: 'WHATSAPP',
      name: name,
      phoneNumber: phoneNumber,
      lastMessageText: preview,
      unreadCount: unreadCount,
      tags: tags,
      lastMessageAt: lastMessageAt ?? DateTime.now(),
      isPinned: isPinned,
      messages: messages,
    );
  }

  factory InboxConversationModel.fromJson(Map<String, dynamic> json) {
    // Handle channel info
    String? chUsername;
    if (json['channel'] is Map) {
      final ch = json['channel'] as Map;
      chUsername =
          ch['username']?.toString() ??
          ch['name']?.toString() ??
          ch['phoneNumber']?.toString();
    }

    final rawTags = json['tags'];
    List<String> parsedTags = [];
    if (rawTags is List) {
      parsedTags = rawTags.map((t) => t.toString()).toList();
    }

    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    final parsedMessages = rawMessages
        .whereType<Map<String, dynamic>>()
        .map(InboxMessageModel.fromJson)
        .toList();

    final countMap = json['_count'] as Map<String, dynamic>?;
    final parsedMessagesCount =
        (countMap?['messages'] as num?)?.toInt() ?? parsedMessages.length;

    return InboxConversationModel(
      id: json['id']?.toString() ?? '',
      channelType: json['channelType']?.toString() ?? 'WHATSAPP',
      channelId: json['channelId']?.toString() ?? '',
      jid: json['jid']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      username: json['username']?.toString() ?? json['handle']?.toString(),
      name: json['name']?.toString() ?? json['contactName']?.toString(),
      profilePic: json['profilePic']?.toString(),
      tags: parsedTags,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      lastMessageText:
          json['lastMessageText']?.toString() ?? json['preview']?.toString(),
      lastMessageType: json['lastMessageType']?.toString(),
      lastMessageAt: DateTime.tryParse(json['lastMessageAt']?.toString() ?? ''),
      isArchived: json['isArchived'] == true,
      isPinned: json['isPinned'] == true,
      notes: json['notes']?.toString(),
      channelUsername: chUsername,
      messagesCount: parsedMessagesCount,
      messages: parsedMessages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channelType': channelType,
      'channelId': channelId,
      'jid': jid,
      'phoneNumber': phoneNumber,
      'username': username,
      'name': name,
      'profilePic': profilePic,
      'tags': tags,
      'unreadCount': unreadCount,
      'lastMessageText': lastMessageText,
      'lastMessageType': lastMessageType,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'isArchived': isArchived,
      'isPinned': isPinned,
      'notes': notes,
      'channelUsername': channelUsername,
      'messagesCount': messagesCount,
      'messages': messages.map((m) => m.toJson()).toList(),
      // Legacy compatibility
      'contactName': contactName,
      'handle': handle,
      'channel': channel,
    };
  }

  InboxConversationModel copyWith({
    String? id,
    String? channelType,
    String? channelId,
    String? jid,
    String? phoneNumber,
    String? username,
    String? name,
    String? profilePic,
    List<String>? tags,
    int? unreadCount,
    String? lastMessageText,
    String? lastMessageType,
    DateTime? lastMessageAt,
    bool? isArchived,
    bool? isPinned,
    String? notes,
    String? channelUsername,
    int? messagesCount,
    List<InboxMessageModel>? messages,
  }) {
    return InboxConversationModel(
      id: id ?? this.id,
      channelType: channelType ?? this.channelType,
      channelId: channelId ?? this.channelId,
      jid: jid ?? this.jid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      tags: tags ?? this.tags,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      notes: notes ?? this.notes,
      channelUsername: channelUsername ?? this.channelUsername,
      messagesCount: messagesCount ?? this.messagesCount,
      messages: messages ?? this.messages,
    );
  }
}
