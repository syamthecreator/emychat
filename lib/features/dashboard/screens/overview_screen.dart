import 'package:emychat/app/theme/app_colors.dart';
import 'package:emychat/core/utils/shell_scope.dart';
import 'package:emychat/core/widgets/app_button.dart';
import 'package:emychat/core/widgets/status_badge.dart';
import 'package:emychat/features/channel/providers/channel_provider.dart';
import 'package:emychat/features/contacts/providers/contacts_provider.dart';
import 'package:emychat/features/inbox/providers/inbox_provider.dart';
import 'package:emychat/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../automation/providers/automation_provider.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workspaceController = context.watch<WorkspaceController?>();
    final activeWorkspace = workspaceController?.activeWorkspace;
    final workspaceName = activeWorkspace?.name ?? 'Workspace';

    final inboxController = context.watch<InboxController?>();
    final channelController = context.watch<ChannelController?>();
    final automationProvider = context.watch<AutomationProvider?>();
    final contactsProvider = context.watch<ContactsProvider?>();

    final unreadChats = inboxController?.stats.unreadConversations ?? 0;
    final openChats = inboxController?.stats.totalConversations ??
        (inboxController?.conversations.length ?? 0);
    final totalContacts = contactsProvider?.allContacts.length ??
        (inboxController?.conversations.length ?? 0);
    final activeAutomations = automationProvider?.items.where((a) => a.isActive).length ??
        (automationProvider?.items.length ?? 0);

    final isWhatsappConnected = channelController?.isWhatsAppConnected ?? false;

    final connectedChannelsCount = channelController?.totalConnectedChannels ??
        (isWhatsappConnected ? 1 : 0);

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
                // Top Page Header
                _buildHeader(context, workspaceName),
                const SizedBox(height: 20),

                // Reconnect alert if channel is disconnected
                if (!isWhatsappConnected)
                  _buildChannelAlert(
                    context,
                    isWhatsappConnected: isWhatsappConnected,
                  ),

                if (!isWhatsappConnected) const SizedBox(height: 20),

                // 6 Metrics Grid
                _buildMetricsGrid(
                  context,
                  unreadChats: unreadChats,
                  openChats: openChats,
                  totalContacts: totalContacts,
                  activeAutomations: activeAutomations,
                  connectedChannelsCount: connectedChannelsCount,
                ),
                const SizedBox(height: 24),

                // Responsive row: Channel Health & Getting Started Checklist
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 960;
                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildChannelHealthCard(
                              context,
                              isWhatsappConnected: isWhatsappConnected,
                              channelController: channelController,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 4,
                            child: _buildChecklistCard(
                              context,
                              isWhatsappConnected: isWhatsappConnected,
                              activeAutomations: activeAutomations,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildChannelHealthCard(
                            context,
                            isWhatsappConnected: isWhatsappConnected,
                            channelController: channelController,
                          ),
                          const SizedBox(height: 20),
                          _buildChecklistCard(
                            context,
                            isWhatsappConnected: isWhatsappConnected,
                            activeAutomations: activeAutomations,
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String workspaceName) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;

        return Row(
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Overview — $workspaceName',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const StatusBadge(
                        label: 'Live Production',
                        type: StatusType.highlight,
                        isSmall: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Unified omnichannel messaging, customer conversations, and automation health.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            AppButton.primary(
              label: 'Open Inbox',
              icon: RemixIcons.chat_3_line,
              size: AppButtonSize.sm,
              onPressed: () {
                ShellScope.of(context).goTo(NavDestination.inbox);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildChannelAlert(
    BuildContext context, {
    required bool isWhatsappConnected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(RemixIcons.alert_line, color: AppColors.warning, size: 18),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Action required: WhatsApp channel needs connection or QR pairing.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          AppButton.secondary(
            label: 'Connect Channel',
            size: AppButtonSize.sm,
            onPressed: () {
              ShellScope.of(context).goTo(NavDestination.channel);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(
    BuildContext context, {
    required int unreadChats,
    required int openChats,
    required int totalContacts,
    required int activeAutomations,
    required int connectedChannelsCount,
  }) {
    final items = [
      _MetricData(
        label: 'Total Contacts',
        value: totalContacts.toString(),
        subtext: 'Persistent CRM records',
        icon: RemixIcons.user_3_line,
        destination: NavDestination.contacts,
      ),
      _MetricData(
        label: 'Open Chats',
        value: openChats.toString(),
        subtext: 'Requiring attention',
        icon: RemixIcons.time_line,
        destination: NavDestination.inbox,
      ),
      _MetricData(
        label: 'Unread Chats',
        value: unreadChats.toString(),
        subtext: 'Awaiting team reply',
        icon: RemixIcons.chat_3_line,
        destination: NavDestination.inbox,
        highlight: unreadChats > 0,
      ),
      _MetricData(
        label: 'Active Automations',
        value: activeAutomations.toString(),
        subtext: 'Live trigger workflows',
        icon: RemixIcons.flashlight_line,
        destination: NavDestination.automations,
      ),
      _MetricData(
        label: 'Messages (30d)',
        value: '14,820',
        subtext: 'Inbound & outbound',
        icon: RemixIcons.pulse_line,
        destination: NavDestination.analytics,
      ),
      _MetricData(
        label: 'Channel Health',
        value: '$connectedChannelsCount / 2',
        subtext: '$connectedChannelsCount channels online',
        icon: RemixIcons.broadcast_line,
        destination: NavDestination.channel,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 6;
        if (constraints.maxWidth < 640) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 1024) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildMetricCard(context, item);
          },
        );
      },
    );
  }

  Widget _buildMetricCard(BuildContext context, _MetricData item) {
    return InkWell(
      onTap: () => ShellScope.of(context).goTo(item.destination),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.highlight
                ? AppColors.accentPrimary.withValues(alpha: 0.35)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Icon(
                    item.icon,
                    size: 15,
                    color: item.highlight
                        ? AppColors.accentPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                if (item.highlight)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.accentPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.subtext,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelHealthCard(
    BuildContext context, {
    required bool isWhatsappConnected,
    required ChannelController? channelController,
  }) {
    final whatsappPhone =
        channelController?.primaryWhatsAppAccount?.displayPhoneNumber ??
        '+1 555-0199 • Active session';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected Channels',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Real-time status of connected customer channels',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              AppButton.ghost(
                label: 'Manage',
                icon: RemixIcons.arrow_right_s_line,
                size: AppButtonSize.sm,
                onPressed: () {
                  ShellScope.of(context).goTo(NavDestination.channel);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // WhatsApp Channel Tile
          _buildChannelRow(
            icon: RemixIcons.whatsapp_line,
            iconColor: AppColors.whatsapp,
            title: 'WhatsApp Business',
            subtitle: isWhatsappConnected
                ? whatsappPhone
                : 'QR code pairing disconnected',
            status: isWhatsappConnected ? 'Active' : 'Offline',
            statusType: isWhatsappConnected
                ? StatusType.active
                : StatusType.disconnected,
            onAction: () => ShellScope.of(context).goTo(NavDestination.channel),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String status,
    required StatusType statusType,
    required VoidCallback onAction,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: iconColor.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        StatusBadge(label: status, type: statusType, isSmall: true),
      ],
    );
  }

  Widget _buildChecklistCard(
    BuildContext context, {
    required bool isWhatsappConnected,
    required int activeAutomations,
  }) {
    final items = [
      _ChecklistItem(
        title: 'Connect WhatsApp Channel',
        done: isWhatsappConnected,
        onTap: () => ShellScope.of(context).goTo(NavDestination.channel),
      ),
      _ChecklistItem(
        title: 'Verify inbound test conversation',
        done: true,
        onTap: () => ShellScope.of(context).goTo(NavDestination.inbox),
      ),
      _ChecklistItem(
        title: 'Create welcome automation rule',
        done: activeAutomations > 0,
        onTap: () => ShellScope.of(context).goTo(NavDestination.automations),
      ),
      _ChecklistItem(
        title: 'Review CRM customer records',
        done: true,
        onTap: () => ShellScope.of(context).goTo(NavDestination.contacts),
      ),
      _ChecklistItem(
        title: 'Configure workspace settings & team',
        done: false,
        onTap: () => ShellScope.of(context).goTo(NavDestination.settings),
      ),
    ];

    final completed = items.where((i) => i.done).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Onboarding Checklist',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$completed / ${items.length} completed',
                style: const TextStyle(
                  color: AppColors.mint,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: completed / items.length,
              backgroundColor: AppColors.surfaceMuted,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mint),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 14),
          for (final item in items) ...[
            InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      item.done
                          ? RemixIcons.checkbox_circle_fill
                          : RemixIcons.checkbox_blank_circle_line,
                      size: 16,
                      color: item.done ? AppColors.mint : AppColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: item.done
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontSize: 12.5,
                          decoration: item.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    const Icon(
                      RemixIcons.arrow_right_s_line,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.destination,
    this.highlight = false,
  });

  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final NavDestination destination;
  final bool highlight;
}

class _ChecklistItem {
  const _ChecklistItem({
    required this.title,
    required this.done,
    required this.onTap,
  });

  final String title;
  final bool done;
  final VoidCallback onTap;
}
