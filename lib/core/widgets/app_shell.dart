import 'package:emychat/app/routes/app_router.dart';
import 'package:emychat/core/controller/core_ui_provider.dart';
import 'package:emychat/core/utils/shell_scope.dart';
import 'package:emychat/core/widgets/app_sidebar.dart';
import 'package:emychat/core/widgets/app_top_bar.dart';
import 'package:emychat/core/widgets/logout_confirm_dialog.dart';
import 'package:emychat/features/analytics/screens/analytics_screen.dart';
import 'package:emychat/features/billing/screens/billing_screen.dart';
import 'package:emychat/features/channel/screens/channel_screen.dart';
import 'package:emychat/features/contacts/screens/contacts_screen.dart';
import 'package:emychat/features/dashboard/screens/overview_screen.dart';
import 'package:emychat/features/inbox/screens/inbox_screen.dart';
import 'package:emychat/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../app/theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/automation/screens/automation_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialDestination});

  final NavDestination? initialDestination;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeDestination();
  }

  /// Initializes navigation from the supplied destination or OAuth callback.
  void _initializeDestination() {
    NavDestination? destination = widget.initialDestination;

    if (destination == null) {
      try {
        final uri = Uri.base;
        final href = uri.toString();

        if (uri.queryParameters['tab'] == 'channel' ||
            uri.queryParameters.containsKey('connected') ||
            uri.fragment.contains('channel') ||
            href.contains('tab=channel') ||
            href.contains('connected=true')) {
          destination = NavDestination.channel;
        }
      } catch (e) {
        debugPrint('AppShell URL initialization error: $e');
      }
    }

    if (destination == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CoreUiProvider>().goTo(destination!);
    });
  }

  /// Handles logout with confirmation.
  Future<void> _logout() async {
    final confirmed = await LogoutConfirmDialog.show(context);
    if (!confirmed || !mounted) return;

    await context.read<AuthController>().signOut();

    if (!mounted) return;

    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRouter.auth, (route) => false);
  }

  /// Returns the selected page.
  Widget _page(NavDestination destination) {
    return switch (destination) {
      NavDestination.overview => const OverviewScreen(),
      NavDestination.inbox => const InboxScreen(),
      NavDestination.channel => const ChannelScreen(),
      NavDestination.contacts => const ContactsScreen(),
      NavDestination.automations => const AutomationsScreen(),
      NavDestination.analytics => const AnalyticsScreen(),
      NavDestination.billing => const BillingScreen(),
      NavDestination.settings => const SettingsScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoreUiProvider>(
      builder: (context, core, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 720;
        final collapsed = core.isSidebarCollapsed(screenWidth);

        return ShellScope(
          goTo: (dest) {
            core.goTo(dest);
            if (isMobile && _scaffoldKey.currentState?.isDrawerOpen == true) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            drawer: isMobile
                ? Drawer(
                    backgroundColor:
                        Theme.of(context).cardTheme.color ?? AppColors.navBar,
                    child: SafeArea(
                      child: AppSidebar(
                        collapsed: false,
                        current: core.currentDestination,
                        onToggle: () => Navigator.of(context).pop(),
                        onSelect: (dest) {
                          core.goTo(dest);
                          Navigator.of(context).pop();
                        },
                        onLogout: _logout,
                      ),
                    ),
                  )
                : null,
            body: Stack(
              children: [
                Row(
                  children: [
                    if (!isMobile)
                      AppSidebar(
                        collapsed: collapsed,
                        current: core.currentDestination,
                        onToggle: () => core.toggleSidebar(screenWidth),
                        onSelect: core.goTo,
                        onLogout: _logout,
                      ),

                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 6,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.borderSubtle,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: AppTopBar(
                              destination: core.currentDestination,
                              notificationCount: 1,
                              onBellTap: core.toggleNotifications,
                              onMenuTap: isMobile
                                  ? () =>
                                        _scaffoldKey.currentState?.openDrawer()
                                  : null,
                            ),
                          ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: KeyedSubtree(
                                key: ValueKey(core.currentDestination),
                                child: _page(core.currentDestination),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Notification overlay.
                if (core.showNotifications) ...[
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: core.closeNotifications,
                      child: const SizedBox.expand(),
                    ),
                  ),

                  const Positioned(
                    top: 68,
                    right: 20,
                    child: _NotificationPanel(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationPanel extends StatelessWidget {
  const _NotificationPanel();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        RemixIcons.checkbox_circle_line,
        AppColors.mint,
        'WhatsApp Session Active',
        'Inbound webhooks receiving events at 99.4% SLA',
        '2m',
      ),
      (
        RemixIcons.notification_3_line,
        AppColors.warning,
        'WhatsApp Session Health',
        'Linked multi-device session active and synced',
        '1h',
      ),
      (
        RemixIcons.chat_3_line,
        AppColors.accentPrimary,
        '3 unread conversations',
        'Awaiting human agent reply in unified inbox',
        '3h',
      ),
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * -6),
          child: child,
        ),
      ),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'Mark all read',
                    style: TextStyle(
                      color: AppColors.accentPrimary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: 4),
            for (final (icon, color, title, body, time) in items)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, size: 15, color: color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                time,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            body,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
