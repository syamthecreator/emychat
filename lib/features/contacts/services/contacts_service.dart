import 'package:flutter/foundation.dart';
import 'package:emychat/core/network/api_client.dart';
import 'package:emychat/core/widgets/status_badge.dart';

class ContactsService {
  ContactsService({this.apiClient});

  final ApiClient? apiClient;

  Future<List<Map<String, dynamic>>> fetchContactsRaw() async {
    if (apiClient != null) {
      try {
        final response = await apiClient!.get(
          '/inbox/conversations',
          requiresAuth: true,
        );
        if (response['success'] == true &&
            response['data'] is Map &&
            response['data']['conversations'] is List) {
          final convs = response['data']['conversations'] as List;
          return convs.map((c) {
            final m = Map<String, dynamic>.from(c as Map);
            final name = m['contactName']?.toString() ??
                m['name']?.toString() ??
                m['phoneNumber']?.toString() ??
                'Unknown Contact';
            final handle = m['phoneNumber']?.toString() ??
                m['handle']?.toString() ??
                '';
            final lastActive = m['lastMessageAt'] != null
                ? m['lastMessageAt'].toString()
                : 'Just now';
            final tagsRaw = m['tags'];
            final tags = tagsRaw is List
                ? tagsRaw.map((t) => t.toString()).toList()
                : <String>['Lead'];
            final unread =
                m['unreadCount'] is int ? m['unreadCount'] as int : 0;
            return {
              'name': name,
              'channel': 'whatsapp',
              'handle': handle,
              'status': unread > 0 ? 'Pending' : 'Active',
              'statusType': unread > 0 ? StatusType.pending : StatusType.active,
              'lastActive': lastActive,
              'tags': tags,
            };
          }).toList();
        }
      } catch (e) {
        debugPrint('ContactsService.fetchContactsRaw error: $e');
      }
    }

    // Default sample contacts for offline / unconfigured demo
    return const [
      {
        'name': 'Rohan Sharma',
        'channel': 'whatsapp',
        'handle': '+91 98765 43210',
        'status': 'Active',
        'statusType': StatusType.active,
        'lastActive': '5m ago',
        'tags': ['Lead', 'High Value'],
      },
      {
        'name': 'Priya Patel',
        'channel': 'whatsapp',
        'handle': '+91 98111 22334',
        'status': 'Active',
        'statusType': StatusType.active,
        'lastActive': '24m ago',
        'tags': ['Customer', 'VIP'],
      },
      {
        'name': 'Amit Verma',
        'channel': 'whatsapp',
        'handle': '+91 91234 56789',
        'status': 'Pending',
        'statusType': StatusType.pending,
        'lastActive': '2h ago',
        'tags': ['Inquiry'],
      },
      {
        'name': 'Sneha Rao',
        'channel': 'whatsapp',
        'handle': '+91 98444 55667',
        'status': 'Closed',
        'statusType': StatusType.closed,
        'lastActive': '1d ago',
        'tags': ['Support'],
      },
      {
        'name': 'Vikram Malhotra',
        'channel': 'whatsapp',
        'handle': '+91 99887 76655',
        'status': 'Active',
        'statusType': StatusType.active,
        'lastActive': '3d ago',
        'tags': ['Enterprise'],
      },
    ];
  }
}
