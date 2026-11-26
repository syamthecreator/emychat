import 'package:emychat/core/widgets/status_badge.dart';

class ContactModel {
  const ContactModel({
    required this.name,
    required this.channel,
    required this.handle,
    required this.status,
    required this.statusType,
    required this.lastActive,
    this.tags = const [],
  });

  final String name;
  final String channel;
  final String handle;
  final String status;
  final StatusType statusType;
  final String lastActive;
  final List<String> tags;

  ContactModel copyWith({
    String? name,
    String? channel,
    String? handle,
    String? status,
    StatusType? statusType,
    String? lastActive,
    List<String>? tags,
  }) {
    return ContactModel(
      name: name ?? this.name,
      channel: channel ?? this.channel,
      handle: handle ?? this.handle,
      status: status ?? this.status,
      statusType: statusType ?? this.statusType,
      lastActive: lastActive ?? this.lastActive,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'channel': channel,
      'handle': handle,
      'status': status,
      'statusType': statusType.name,
      'lastActive': lastActive,
      'tags': tags,
    };
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      name: json['name']?.toString() ?? '',
      channel: json['channel']?.toString() ?? 'whatsapp',
      handle: json['handle']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      statusType: json['statusType'] is StatusType
          ? json['statusType'] as StatusType
          : StatusType.active,
      lastActive: json['lastActive']?.toString() ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }
}
