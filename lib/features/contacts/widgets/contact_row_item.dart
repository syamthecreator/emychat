import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:emychat/app/theme/app_colors.dart';
import 'package:emychat/core/widgets/status_badge.dart';
import '../models/contact_model.dart';

class ContactRowItem extends StatelessWidget {
  const ContactRowItem({super.key, required this.contact});

  final ContactModel contact;

  @override
  Widget build(BuildContext context) {
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
                    contact.name.isNotEmpty
                        ? contact.name.substring(0, 1).toUpperCase()
                        : '?',
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
                        contact.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        contact.handle,
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
              contact.lastActive,
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
                label: contact.status,
                type: contact.statusType,
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
