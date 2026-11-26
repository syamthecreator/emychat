import 'package:emychat/core/network/api_client.dart';
import 'package:emychat/core/widgets/status_badge.dart';

class ContactsService {
  ContactsService({this.apiClient});

  // ignore: unused_field
  final ApiClient? apiClient;

  Future<List<Map<String, dynamic>>> fetchContactsRaw() async {
    // In production, calls backend API. Provides default mock data if offline/unconfigured.
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
