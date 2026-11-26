import 'package:emychat/features/auth/providers/auth_provider.dart';
import 'package:emychat/features/automation/services/automation_service.dart';
import 'package:emychat/features/channel/providers/channel_provider.dart';
import 'package:emychat/features/channel/services/channel_service.dart';
import 'package:emychat/features/inbox/providers/inbox_provider.dart';
import 'package:emychat/features/pricing/providers/pricing_provider.dart';
import 'package:emychat/features/splash/providers/splash_provider.dart';
import 'package:emychat/features/subscription/providers/subscription_provider.dart';
import 'package:emychat/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/automation/providers/automation_provider.dart';
import '../features/inbox/services/inbox_service.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import '../core/controller/core_ui_provider.dart';
import '../core/controller/theme_provider.dart';
import '../core/network/api_client.dart';
import '../core/network/auth_token_manager.dart';
import '../core/services/auth_api_service.dart';
import '../core/services/subscription_api_service.dart';
import '../core/services/workspace_api_service.dart';
import '../features/analytics/providers/analytics_provider.dart';
import '../features/billing/providers/billing_provider.dart';
import '../features/contacts/providers/contacts_provider.dart';
import '../features/contacts/repositories/contacts_repository.dart';
import '../features/contacts/services/contacts_service.dart';
import '../features/dashboard/providers/dashboard_provider.dart';
import '../features/settings/providers/settings_provider.dart';

class EmeyChat extends StatelessWidget {
  const EmeyChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthTokenManager>(create: (_) => AuthTokenManager()),
        Provider<ApiClient>(
          create: (context) =>
              ApiClient(tokenManager: context.read<AuthTokenManager>()),
        ),
        Provider<AuthApiService>(
          create: (context) => AuthApiService(
            apiClient: context.read<ApiClient>(),
            tokenManager: context.read<AuthTokenManager>(),
          ),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) =>
              AuthController(authApiService: context.read<AuthApiService>())
                ..initialize(),
        ),
        Provider<WorkspaceApiService>(
          create: (context) => WorkspaceApiService(
            apiClient: context.read<ApiClient>(),
            tokenManager: context.read<AuthTokenManager>(),
          ),
        ),
        ChangeNotifierProvider<WorkspaceController>(
          create: (context) => WorkspaceController(
            workspaceApiService: context.read<WorkspaceApiService>(),
          )..loadWorkspaces(),
        ),
        Provider<SubscriptionApiService>(
          create: (context) =>
              SubscriptionApiService(apiClient: context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<SubscriptionController>(
          create: (context) => SubscriptionController(
            subscriptionApiService: context.read<SubscriptionApiService>(),
          ),
        ),
        ChangeNotifierProvider<PricingController>(
          create: (context) => PricingController(
            subscriptionApiService: context.read<SubscriptionApiService>(),
          ),
        ),
        Provider<ChannelApiService>(
          create: (context) =>
              ChannelApiService(apiClient: context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<ChannelController>(
          create: (context) => ChannelController(
            channelApiService: context.read<ChannelApiService>(),
          ),
        ),
        ChangeNotifierProvider<CoreUiProvider>(create: (_) => CoreUiProvider()),
        Provider<InboxApiService>(
          create: (context) =>
              InboxApiService(apiClient: context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<InboxController>(
          create: (context) => InboxController(
            inboxApiService: context.read<InboxApiService>(),
            tokenManager: context.read<AuthTokenManager>(),
          ),
        ),
        ChangeNotifierProvider<SplashController>(
          create: (context) => SplashController(
            tokenManager: context.read<AuthTokenManager>(),
            authController: context.read<AuthController>(),
          ),
        ),
        Provider<AutomationApiService>(
          create: (context) =>
              AutomationApiService(apiClient: context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<AutomationProvider>(
          create: (context) => AutomationProvider(
            automationApiService: context.read<AutomationApiService>(),
          ),
        ),
        ChangeNotifierProvider<BillingProvider>(
          create: (_) => BillingProvider(),
        ),
        ChangeNotifierProvider<ContactsProvider>(
          create: (context) => ContactsProvider(
            contactsRepository: ContactsRepository(
              contactsService: ContactsService(
                apiClient: context.read<ApiClient>(),
              ),
            ),
          ),
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
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'EmyChat',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            initialRoute: AppRouter.landing,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
