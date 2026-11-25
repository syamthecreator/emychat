import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

enum NavDestination {
  overview,
  inbox,
  channel,
  contacts,
  automations,
  analytics,
  billing,
  settings,
}

extension NavDestinationX on NavDestination {
  String get label => switch (this) {
    NavDestination.overview => 'Overview',
    NavDestination.inbox => 'Inbox',
    NavDestination.channel => 'Channels',
    NavDestination.contacts => 'Contacts',
    NavDestination.automations => 'Automations',
    NavDestination.analytics => 'Analytics',
    NavDestination.billing => 'Billing',
    NavDestination.settings => 'Settings',
  };

  IconData get icon => switch (this) {
    NavDestination.overview => RemixIcons.dashboard_line,
    NavDestination.inbox => RemixIcons.chat_3_line,
    NavDestination.channel => RemixIcons.broadcast_line,
    NavDestination.contacts => RemixIcons.contacts_book_line,
    NavDestination.automations => RemixIcons.flashlight_line,
    NavDestination.analytics => RemixIcons.line_chart_line,
    NavDestination.billing => RemixIcons.bank_card_line,
    NavDestination.settings => RemixIcons.settings_4_line,
  };

  String get blurb => switch (this) {
    NavDestination.overview => 'Omnichannel messaging overview and workspace health.',
    NavDestination.inbox => 'Every conversation in one unified shared inbox.',
    NavDestination.channel => 'Connect and monitor WhatsApp channels.',
    NavDestination.contacts => 'Unified customer contacts and CRM directory.',
    NavDestination.automations => 'Automated replies, keyword triggers, and workflows.',
    NavDestination.analytics => 'Messaging volume, response latency, and delivery stats.',
    NavDestination.billing => 'Subscription tier, usage limits, and payment details.',
    NavDestination.settings => 'Workspace preferences, security, and credentials.',
  };
}

class ShellScope extends InheritedWidget {
  const ShellScope({super.key, required this.goTo, required super.child});

  final ValueChanged<NavDestination> goTo;

  static ShellScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShellScope>();
    assert(scope != null, 'ShellScope not found in widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(ShellScope oldWidget) => goTo != oldWidget.goTo;
}
