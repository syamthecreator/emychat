import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emychat/app/routes/app_router.dart';
import 'package:emychat/core/controller/core_ui_provider.dart';
import 'package:emychat/core/controller/theme_provider.dart';
import 'package:emychat/core/network/api_client.dart';
import 'package:emychat/core/network/auth_token_manager.dart';
import 'package:emychat/core/services/auth_api_service.dart';
import 'package:emychat/core/services/subscription_api_service.dart';
import 'package:emychat/core/services/workspace_api_service.dart';
import 'package:emychat/core/utils/shell_scope.dart';
import 'package:emychat/core/widgets/status_badge.dart';
import 'package:emychat/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:emychat/features/auth/controllers/auth_controller.dart';
import 'package:emychat/features/automation/controller/automation_provider.dart';
import 'package:emychat/features/billing/presentation/screens/billing_screen.dart';
import 'package:emychat/features/channel/controller/channel_controller.dart';
import 'package:emychat/features/channel/service/channel_api_service.dart';
import 'package:emychat/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:emychat/features/dashboard/presentation/screens/overview_screen.dart';
import 'package:emychat/features/inbox/controller/inbox_controller.dart';
import 'package:emychat/features/inbox/service/inbox_api_service.dart';
import 'package:emychat/features/pricing/controller/pricing_controller.dart';
import 'package:emychat/features/pricing/data/models/pricing_plan_model.dart';
import 'package:emychat/features/pricing/presentation/widgets/compact_pricing_card.dart';
import 'package:emychat/features/landing/presentation/screens/landing_screen.dart';
import 'package:emychat/features/settings/presentation/screens/settings_screen.dart';
import 'package:emychat/features/subscription/controller/subscription_controller.dart';
import 'package:emychat/features/workspace/controller/workspace_controller.dart';
import 'package:emychat/features/workspace/data/models/workspace_model.dart';

class MockSubscriptionApiService extends SubscriptionApiService {
  MockSubscriptionApiService({required super.apiClient});

  @override
  Future<List<PricingPlanModel>> getPlans() async {
    return PricingPlanModel.defaultPlans;
  }
}

class MockWorkspaceApiService extends WorkspaceApiService {
  MockWorkspaceApiService({required super.apiClient});

  @override
  Future<List<WorkspaceModel>> getMyWorkspaces() async {
    return [
      WorkspaceModel(
        id: 'ws-1',
        name: 'Auren Production',
        businessName: 'Auren Corp',
        slug: 'auren-prod',
        ownerId: 'user-1',
        createdAt: DateTime.now(),
      ),
    ];
  }
}

Widget createRedesignTestWrapper(Widget child, {NavDestination? destination}) {
  final tokenManager = AuthTokenManager();
  final apiClient = ApiClient(tokenManager: tokenManager);
  final authService = AuthApiService(
    apiClient: apiClient,
    tokenManager: tokenManager,
  );
  final wsService = MockWorkspaceApiService(apiClient: apiClient);
  final subService = MockSubscriptionApiService(apiClient: apiClient);
  final channelService = ChannelApiService(apiClient: apiClient);
  final inboxService = InboxApiService(apiClient: apiClient);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<CoreUiProvider>(
        create: (_) => CoreUiProvider(initialDestination: destination),
      ),
      ChangeNotifierProvider<AuthController>(
        create: (_) => AuthController(authApiService: authService),
      ),
      ChangeNotifierProvider<PricingController>(
        create: (_) => PricingController(subscriptionApiService: subService),
      ),
      ChangeNotifierProvider<WorkspaceController>(
        create: (_) => WorkspaceController(workspaceApiService: wsService),
      ),
      ChangeNotifierProvider<SubscriptionController>(
        create: (_) =>
            SubscriptionController(subscriptionApiService: subService),
      ),
      ChangeNotifierProvider<ChannelController>(
        create: (_) => ChannelController(channelApiService: channelService),
      ),
      ChangeNotifierProvider<InboxController>(
        create: (_) => InboxController(inboxApiService: inboxService),
      ),
      ChangeNotifierProvider<AutomationProvider>(
        create: (_) => AutomationProvider(),
      ),
      ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
    ],
    child: MaterialApp(
      onGenerateRoute: AppRouter.generateRoute,
      home: ShellScope(goTo: (_) {}, child: child),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Auren Connect Minimalist SaaS Redesign Tests', () {
    testWidgets('StatusBadge renders label and color dot indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'Active',
              type: StatusType.active,
              showDot: true,
            ),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets(
      'OverviewScreen renders metrics, channel health, and checklist',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          createRedesignTestWrapper(const OverviewScreen()),
        );
        await tester.pump();

        expect(find.textContaining('Overview —'), findsOneWidget);
        expect(find.text('Live Production'), findsOneWidget);
        expect(find.text('Open Inbox'), findsOneWidget);
        expect(find.text('Total Contacts'), findsOneWidget);
        expect(find.text('Open Chats'), findsOneWidget);
        expect(find.text('Active Automations'), findsOneWidget);
        expect(find.text('Connected Channels'), findsOneWidget);
        expect(find.text('Onboarding Checklist'), findsOneWidget);
      },
    );

    testWidgets('ContactsScreen renders header, search, and filter pills', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createRedesignTestWrapper(const ContactsScreen()),
      );
      await tester.pump();

      expect(find.text('Contacts & Leads'), findsOneWidget);
      expect(find.text('Add Contact'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('WhatsApp'), findsWidgets);
      expect(find.text('Instagram'), findsWidgets);
      expect(find.text('Rohan Sharma'), findsOneWidget);
    });

    testWidgets('AnalyticsScreen renders metrics and volume cards', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createRedesignTestWrapper(const AnalyticsScreen()),
      );
      await tester.pump();

      expect(find.text('Analytics & Performance'), findsOneWidget);
      expect(find.text('Delivery Rate'), findsOneWidget);
      expect(find.text('Response Latency'), findsOneWidget);
      expect(find.text('AI Auto-Resolution'), findsOneWidget);
      expect(find.text('Total Messages'), findsOneWidget);
      expect(find.text('WhatsApp Business API'), findsOneWidget);
      expect(find.text('Instagram Direct API'), findsOneWidget);
    });

    testWidgets('BillingScreen renders subscription tier and resource meters', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createRedesignTestWrapper(const BillingScreen()));
      await tester.pump();

      expect(find.text('Billing & Subscription'), findsOneWidget);
      expect(find.text('Upgrade Plan'), findsOneWidget);
      expect(find.text('Resource Entitlements & Usage'), findsOneWidget);
      expect(find.text('Recent Invoices'), findsOneWidget);
    });

    testWidgets('SettingsScreen renders workspace profile and webhook config', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createRedesignTestWrapper(const SettingsScreen()),
      );
      await tester.pump();

      expect(find.text('Workspace Settings'), findsOneWidget);
      expect(find.text('General Profile'), findsOneWidget);
      expect(find.text('Meta Cloud API Webhook'), findsOneWidget);
    });

    testWidgets(
      'CompactPricingCard renders key capabilities and aligned CTAs',
      (tester) async {
        final plan = PricingPlanModel.defaultPlans.first; // Starter
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: CompactPricingCard(
                  plan: plan,
                  isYearly: false,
                  onSelect: () {},
                  width: 340,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Starter'), findsOneWidget);
        expect(find.text('\$29'), findsOneWidget);
        expect(find.text('/month'), findsOneWidget);
        expect(find.text('Billed monthly, cancel anytime'), findsOneWidget);
        expect(find.text('Get Started'), findsOneWidget);
        expect(find.text('KEY CAPABILITIES'), findsOneWidget);
        expect(find.textContaining('Messages / month'), findsOneWidget);
      },
    );

    testWidgets('LandingScreen tab switching switches views cleanly', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createRedesignTestWrapper(const LandingScreen()));
      await tester.pump();

      expect(
        find.text('Turn Every Conversation\nInto a Customer.'),
        findsOneWidget,
      );

      // Switch to Pricing tab
      await tester.tap(find.text('Pricing').first);
      await tester.pumpAndSettle();

      expect(
        find.text('Simple, Scalable Pricing for Modern Messaging'),
        findsOneWidget,
      );
      expect(find.text('Growth'), findsWidgets);
      // PricingController defaults to annual billing (_isYearly = true) => $64/mo equivalent for Growth ($768 / 12)
      expect(find.text('\$64'), findsWidgets);

      // Tap Monthly Billing toggle
      await tester.tap(find.text('Monthly Billing'));
      await tester.pumpAndSettle();
      expect(find.text('\$79'), findsWidgets);

      // Switch to WhatsApp tab
      await tester.tap(find.text('WhatsApp').first);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Direct Multi-Device WhatsApp Automation'),
        findsOneWidget,
      );

      // Switch to Instagram tab
      await tester.tap(find.text('Instagram').first);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Turn Instagram Followers Into Paying Customers'),
        findsOneWidget,
      );
    });

    testWidgets(
      'LandingScreen renders responsive layouts across 375px, 390px, 768px, and 1280px without errors',
      (tester) async {
        final viewports = [
          const Size(375, 667), // iPhone SE
          const Size(390, 844), // iPhone 13/14
          const Size(768, 1024), // iPad portrait
          const Size(1280, 800), // Standard desktop
        ];

        for (final vp in viewports) {
          await tester.pumpWidget(const SizedBox());
          tester.view.physicalSize = vp;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            createRedesignTestWrapper(const LandingScreen()),
          );
          await tester.pump();

          final err = tester.takeException();
          expect(err, isNull, reason: 'No layout overflow on $vp');
        }
        tester.view.resetPhysicalSize();
      },
    );
  });
}
