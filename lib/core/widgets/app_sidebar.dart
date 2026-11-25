import 'package:emychat/app/theme/app_colors.dart';
import 'package:emychat/core/constants/asset_constants.dart';
import 'package:emychat/core/utils/shell_scope.dart';
import 'package:emychat/core/widgets/status_badge.dart';
import 'package:emychat/features/inbox/controller/inbox_controller.dart';
import 'package:emychat/features/workspace/controller/workspace_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.collapsed,
    required this.current,
    required this.onToggle,
    required this.onSelect,
    required this.onLogout,
  });

  static const double expandedWidth = 260;
  static const double collapsedWidth = 72;

  final bool collapsed;
  final NavDestination current;
  final VoidCallback onToggle;
  final ValueChanged<NavDestination> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final inboxController = context.watch<InboxController?>();
    final unreadChats = inboxController?.stats.unreadConversations ?? 0;

    final workspaceController = context.watch<WorkspaceController?>();
    final workspaceName =
        workspaceController?.activeWorkspace?.name ?? 'EmyChat Workspace';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: collapsed ? collapsedWidth : expandedWidth,
      decoration: const BoxDecoration(
        color: AppColors.navBar,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 180;

          return ClipRect(
            child: Column(
              children: [
                // Top Brand / Workspace header
                _Brand(
                  compact: compact,
                  collapsed: collapsed,
                  workspaceName: workspaceName,
                  onToggle: onToggle,
                ),

                const Divider(color: AppColors.borderSubtle, height: 1),

                // Grouped Navigation
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 8 : 10,
                      vertical: 10,
                    ),
                    children: [
                      // GROUP 1: Workspace
                      if (!compact) const _GroupLabel('WORKSPACE'),
                      _NavItem(
                        destination: NavDestination.overview,
                        active: current == NavDestination.overview,
                        compact: compact,
                        onTap: () => onSelect(NavDestination.overview),
                      ),
                      _NavItem(
                        destination: NavDestination.inbox,
                        active: current == NavDestination.inbox,
                        compact: compact,
                        badge: unreadChats > 0 ? '$unreadChats' : null,
                        onTap: () => onSelect(NavDestination.inbox),
                      ),
                      _NavItem(
                        destination: NavDestination.channel,
                        active: current == NavDestination.channel,
                        compact: compact,
                        onTap: () => onSelect(NavDestination.channel),
                      ),
                      _NavItem(
                        destination: NavDestination.contacts,
                        active: current == NavDestination.contacts,
                        compact: compact,
                        onTap: () => onSelect(NavDestination.contacts),
                      ),

                      const SizedBox(height: 14),

                      // GROUP 2: Automation & AI
                      if (!compact) const _GroupLabel('AUTOMATION & AI'),
                      _NavItem(
                        destination: NavDestination.automations,
                        active: current == NavDestination.automations,
                        compact: compact,
                        onTap: () => onSelect(NavDestination.automations),
                      ),
                      _NavItem(
                        destination: NavDestination.analytics,
                        active: current == NavDestination.analytics,
                        compact: compact,
                        onTap: () => onSelect(NavDestination.analytics),
                      ),

                      const SizedBox(height: 14),

                      // GROUP 3: Management
                      if (!compact) const _GroupLabel('MANAGEMENT'),
                      _NavItem(
                        destination: NavDestination.billing,
                        active: current == NavDestination.billing,
                        compact: compact,
                        onTap: () => onSelect(NavDestination.billing),
                      ),
                      _NavItem(
                        destination: NavDestination.settings,
                        active: current == NavDestination.settings,
                        compact: compact,
                        onTap: () => onSelect(NavDestination.settings),
                      ),
                    ],
                  ),
                ),

                const Divider(color: AppColors.borderSubtle, height: 1),

                // Bottom: Workspace tier & Logout
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 8 : 10,
                    10,
                    compact ? 8 : 10,
                    12,
                  ),
                  child: Column(
                    children: [
                      if (!compact) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: const Row(
                            children: [
                              StatusBadge(
                                label: 'PRO',
                                type: StatusType.highlight,
                                isSmall: true,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Meta Cloud API',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      _ActionItem(
                        icon: RemixIcons.logout_box_r_line,
                        label: 'Log out',
                        compact: compact,
                        color: AppColors.textMuted,
                        onTap: onLogout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BRAND HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _Brand extends StatelessWidget {
  const _Brand({
    required this.compact,
    required this.collapsed,
    required this.workspaceName,
    required this.onToggle,
  });

  final bool compact;
  final bool collapsed;
  final String workspaceName;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 8 : 14, 14, compact ? 8 : 12, 14),
      child: compact
          ? Tooltip(
              message: 'Expand sidebar',
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(8),
                child: _buildLogo(),
              ),
            )
          : Row(
              children: [
                _buildLogo(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'EmyChat',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        workspaceName,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Collapse sidebar',
                  child: IconButton(
                    icon: const Icon(
                      RemixIcons.side_bar_line,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    onPressed: onToggle,
                    splashRadius: 16,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Image.asset(AssetConstants.aLogo, fit: BoxFit.contain),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GROUP LABEL
// ─────────────────────────────────────────────────────────────────────────────

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAVIGATION ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.active,
    required this.compact,
    required this.onTap,
    this.badge,
  });

  final NavDestination destination;
  final bool active;
  final bool compact;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = active
        ? AppColors.textPrimary
        : AppColors.textSecondary;
    final iconColor = active ? AppColors.accentPrimary : AppColors.textMuted;

    Widget item = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColors.surfaceMuted,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          margin: const EdgeInsets.symmetric(vertical: 1.5),
          height: 38,
          padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 10),
          decoration: BoxDecoration(
            color: active ? AppColors.surfaceMuted : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active
                  ? AppColors.arcticBlue.withValues(alpha: 0.35)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: compact
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(destination.icon, size: 17, color: iconColor),
              if (!compact) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: AppColors.accentPrimary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );

    if (compact) {
      item = Tooltip(
        message: destination.label,
        preferBelow: false,
        child: item,
      );
    }

    return item;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.compact,
    required this.onTap,
    this.color = AppColors.textSecondary,
  });

  final IconData icon;
  final String label;
  final bool compact;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget item = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: AppColors.surfaceMuted,
        child: Container(
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 10),
          child: Row(
            mainAxisAlignment: compact
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: color),
              if (!compact) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (compact) {
      item = Tooltip(message: label, preferBelow: false, child: item);
    }

    return item;
  }
}
