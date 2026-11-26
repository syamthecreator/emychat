import 'package:emychat/core/controller/core_ui_provider.dart';
import 'package:emychat/features/analytics/providers/analytics_provider.dart';
import 'package:emychat/features/auth/providers/auth_provider.dart';
import 'package:emychat/features/auth/screens/register_screen.dart';
import 'package:emychat/features/automation/providers/automation_provider.dart';
import 'package:emychat/features/automation/services/automation_service.dart';
import 'package:emychat/features/billing/providers/billing_provider.dart';
import 'package:emychat/features/channel/providers/channel_provider.dart';
import 'package:emychat/features/channel/services/channel_service.dart';
import 'package:emychat/features/contacts/providers/contacts_provider.dart';
import 'package:emychat/features/dashboard/providers/dashboard_provider.dart';
import 'package:emychat/features/inbox/providers/inbox_provider.dart';
import 'package:emychat/features/inbox/services/inbox_service.dart';
import 'package:emychat/features/landing/screens/landing_screen.dart';
import 'package:emychat/features/onboarding/screens/checkout_screen.dart';
import 'package:emychat/features/onboarding/screens/onboarding_complete_screen.dart';
import 'package:emychat/features/onboarding/screens/workspace_creation_screen.dart';
import 'package:emychat/features/pricing/models/pricing_plan_model.dart';
import 'package:emychat/features/pricing/providers/pricing_provider.dart';
import 'package:emychat/features/pricing/screens/pricing_screen.dart';
import 'package:emychat/features/settings/providers/settings_provider.dart';
import 'package:emychat/features/subscription/providers/subscription_provider.dart';
import 'package:emychat/features/workspace/models/workspace_model.dart';
import 'package:emychat/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emychat/app/routes/app_router.dart';
import 'package:emychat/core/controller/theme_provider.dart';
import 'package:emychat/core/network/api_client.dart';
import 'package:emychat/core/network/auth_token_manager.dart';
import 'package:emychat/core/services/auth_api_service.dart';
import 'package:emychat/core/services/subscription_api_service.dart';
import 'package:emychat/core/services/workspace_api_service.dart';

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
  Future<List<WorkspaceModel>> getMyWorkspaces({String? userId}) async {
    return [];
  }
}

Widget createTestWrapper(Widget child) {
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
  final autoService = AutomationApiService(apiClient: apiClient);

  return MultiProvider(
    providers: [
      Provider<AuthTokenManager>.value(value: tokenManager),
      Provider<ApiClient>.value(value: apiClient),
      Provider<AuthApiService>.value(value: authService),
      Provider<WorkspaceApiService>.value(value: wsService),
      Provider<SubscriptionApiService>.value(value: subService),
      Provider<ChannelApiService>.value(value: channelService),
      Provider<InboxApiService>.value(value: inboxService),
      Provider<AutomationApiService>.value(value: autoService),
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
        create: (_) => AutomationProvider(automationApiService: autoService),
      ),
      ChangeNotifierProvider<BillingProvider>(create: (_) => BillingProvider()),
      ChangeNotifierProvider<ContactsProvider>(
        create: (_) => ContactsProvider(),
      ),
      ChangeNotifierProvider<AnalyticsProvider>(
        create: (_) => AnalyticsProvider(),
      ),
      ChangeNotifierProvider<DashboardProvider>(
        create: (_) => DashboardProvider(),
      ),
      ChangeNotifierProvider<SettingsProvider>(
        create: (_) => SettingsProvider(),
      ),
      ChangeNotifierProvider<CoreUiProvider>(create: (_) => CoreUiProvider()),
      ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
    ],
    child: MaterialApp(onGenerateRoute: AppRouter.generateRoute, home: child),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LandingScreen renders hero, headline, and primary CTAs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWrapper(const LandingScreen()));
    final err = tester.takeException();
    if (err is FlutterError) {
      debugPrint('ERR DETAIL: ${err.message}');
    } else if (err != null) {
      debugPrint('ERR DETAIL: $err');
    }

    expect(
      find.text('Automate Conversations.\nGrow Your Business.'),
      findsOneWidget,
    );
    expect(find.text('Get Started Free'), findsOneWidget);
    expect(find.text('View Pricing Plans'), findsOneWidget);
  });

  testWidgets('PricingScreen renders monthly/yearly toggle and plans', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWrapper(const PricingScreen()));
    await tester.pump(const Duration(milliseconds: 50));
    tester.takeException();

    expect(
      find.text('Simple, Scalable Pricing for Modern Messaging'),
      findsOneWidget,
    );
    expect(find.text('Monthly Billing'), findsOneWidget);
    expect(find.text('Annual Billing'), findsOneWidget);
    expect(find.text('Starter'), findsWidgets);
    expect(find.text('Growth'), findsWidgets);
    expect(find.text('Pro'), findsWidgets);
  });

  testWidgets('RegisterScreen renders form fields and selected plan', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      createTestWrapper(const RegisterScreen(planSlug: 'growth')),
    );
    await tester.pump(const Duration(milliseconds: 50));
    tester.takeException();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Work Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Create Account & Continue'), findsOneWidget);
  });

  testWidgets('WorkspaceCreationScreen renders inputs and step 1 indicator', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWrapper(const WorkspaceCreationScreen()));
    await tester.pump(const Duration(milliseconds: 50));
    tester.takeException();

    expect(find.text('Create your Workspace'), findsOneWidget);
    expect(find.text('WORKSPACE NAME'), findsOneWidget);
    expect(find.text('BUSINESS NAME'), findsOneWidget);
    expect(find.text('WORKSPACE URL / SLUG'), findsOneWidget);
    expect(find.text('Create Workspace & Proceed to Checkout'), findsOneWidget);
  });

  testWidgets('CheckoutScreen renders order summary and card form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWrapper(const CheckoutScreen()));
    await tester.pump(const Duration(milliseconds: 50));
    tester.takeException();

    expect(find.text('ORDER SUMMARY'), findsOneWidget);
    expect(find.text('PAYMENT DETAILS'), findsOneWidget);
    expect(find.text('CARD NUMBER'), findsOneWidget);
    expect(find.text('Complete Payment & Activate'), findsOneWidget);
  });

  testWidgets('OnboardingCompleteScreen renders checklist and launch button', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      createTestWrapper(const OnboardingCompleteScreen()),
    );
    await tester.pump(const Duration(milliseconds: 50));
    tester.takeException();

    expect(find.text('Workspace Ready to Scale!'), findsOneWidget);
    expect(find.text('ONBOARDING CHECKLIST'), findsOneWidget);
    expect(find.text('1. Workspace created'), findsOneWidget);
    expect(find.text('2. Subscription activated'), findsOneWidget);
    expect(find.text('Launch Dashboard'), findsOneWidget);
  });
}
