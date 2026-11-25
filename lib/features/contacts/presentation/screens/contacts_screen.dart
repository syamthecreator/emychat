import 'package:emychat/app/theme/app_colors.dart';
import 'package:emychat/core/widgets/app_button.dart';
import 'package:emychat/core/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  String _selectedChannelFilter = 'all';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allContacts = const [
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

  @override
  Widget build(BuildContext context) {
    final filtered = _allContacts.where((c) {
      final matchesChannel =
          _selectedChannelFilter == 'all' ||
          c['channel'] == _selectedChannelFilter;
      final matchesSearch =
          _searchQuery.isEmpty ||
          (c['name'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (c['handle'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesChannel && matchesSearch;
    }).toList();

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
                // Top Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contacts & Leads',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Unified directory of contacts acquired across WhatsApp.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AppButton.primary(
                      label: 'Add Contact',
                      icon: RemixIcons.user_add_line,
                      size: AppButtonSize.sm,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Controls row: Search and Filter Pills
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 600;
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSearchField(),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildFilterPill('All', 'all'),
                                const SizedBox(width: 6),
                                _buildFilterPill('WhatsApp', 'whatsapp'),
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: _buildSearchField()),
                          const SizedBox(width: 12),
                          _buildFilterPill('All', 'all'),
                          const SizedBox(width: 6),
                          _buildFilterPill('WhatsApp', 'whatsapp'),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Table
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final tableWidth = constraints.maxWidth < 780
                            ? 780.0
                            : constraints.maxWidth;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: tableWidth,
                            child: Column(
                              children: [
                                // Header row
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 11,
                                  ),
                                  color: AppColors.surfaceMuted,
                                  child: const Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'CONTACT',
                                          style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'CHANNEL',
                                          style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'LAST ACTIVE',
                                          style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'STATUS',
                                          style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 40),
                                    ],
                                  ),
                                ),

                                // List of items
                                for (int i = 0; i < filtered.length; i++) ...[
                                  if (i > 0)
                                    const Divider(
                                      color: AppColors.borderSubtle,
                                      height: 1,
                                    ),
                                  _buildContactRow(filtered[i]),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          const Icon(
            RemixIcons.search_line,
            color: AppColors.textMuted,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              decoration: const InputDecoration(
                hintText: 'Search by name or handle...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String title, String key) {
    final isSelected = _selectedChannelFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedChannelFilter = key),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.border : Colors.transparent,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(Map<String, dynamic> c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Contact info with avatar initials
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surfaceMuted,
                  child: Text(
                    (c['name'] as String).substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['name'] as String,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        c['handle'] as String,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Channel icon and label
          const Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  RemixIcons.whatsapp_line,
                  size: 15,
                  color: AppColors.whatsapp,
                ),
                SizedBox(width: 6),
                Text(
                  'WhatsApp',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),

          // Last active
          Expanded(
            flex: 2,
            child: Text(
              c['lastActive'] as String,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),

          // Status Badge
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                label: c['status'] as String,
                type: c['statusType'] as StatusType,
                isSmall: true,
              ),
            ),
          ),

          // Quick action icon
          IconButton(
            icon: const Icon(
              RemixIcons.more_2_line,
              color: AppColors.textMuted,
              size: 16,
            ),
            onPressed: () {},
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}
