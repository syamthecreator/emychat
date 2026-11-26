import 'package:emychat/features/auth/providers/auth_provider.dart';
import 'package:emychat/features/pricing/providers/pricing_provider.dart';
import 'package:emychat/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/onboarding_stepper.dart';

import '../../../../core/network/api_client.dart';
import '../providers/workspace_creation_provider.dart';
import '../repositories/onboarding_repository.dart';
import '../services/onboarding_service.dart';

class WorkspaceCreationScreen extends StatelessWidget {
  const WorkspaceCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WorkspaceCreationProvider>(
      create: (ctx) => WorkspaceCreationProvider(
        onboardingRepository: OnboardingRepository(
          onboardingService: OnboardingService(
            apiClient: ctx.read<ApiClient>(),
          ),
        ),
      ),
      child: const _WorkspaceCreationView(),
    );
  }
}

class _WorkspaceCreationView extends StatelessWidget {
  const _WorkspaceCreationView();

  Future<void> _handleCreateWorkspace(BuildContext context) async {
    final provider = context.read<WorkspaceCreationProvider>();
    final wsController = context.read<WorkspaceController>();
    final auth = context.read<AuthController?>();
    final workspace = await provider.submitWorkspace(
      wsController,
      userId: auth?.userId,
    );

    if (!context.mounted) return;

    if (workspace != null) {
      Navigator.of(context).pushReplacementNamed(AppRouter.checkout);
    } else if (wsController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(wsController.errorMessage!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkspaceCreationProvider>();
    final formKey = provider.formKey;
    final wsNameCtrl = provider.wsNameCtrl;
    final businessNameCtrl = provider.businessNameCtrl;
    final slugCtrl = provider.slugCtrl;
    final selectedCategory = provider.selectedCategory;
    final selectedTimezone = provider.selectedTimezone;
    final selectedCountry = provider.selectedCountry;
    final categories = provider.categories;
    final timezones = provider.timezones;
    final countries = provider.countries;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 680;
    final wsController = context.watch<WorkspaceController>();
    final pricing = context.watch<PricingController>();
    final selectedPlan = pricing.selectedPlan;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 18 : 36,
            vertical: 36,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          AssetConstants.aLogo,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                RemixIcons.apps_2_fill,
                                color: AppColors.primary,
                                size: 18,
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'emy',
                              style: AppTextStyles.t(
                                20,
                                w: FontWeight.w700,
                                c: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: 'chat',
                              style: AppTextStyles.t(
                                20,
                                w: FontWeight.w700,
                                c: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Stepper (Step 1 of 3)
                  const OnboardingStepper(currentStep: 1),

                  const SizedBox(height: 28),

                  // Main Container Card
                  Container(
                    padding: EdgeInsets.all(isMobile ? 20 : 32),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  RemixIcons.building_4_line,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Create your Workspace',
                                      style: AppTextStyles.t(
                                        20,
                                        w: FontWeight.w700,
                                        c: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'A dedicated multi-tenant container for your team and automations.',
                                      style: AppTextStyles.t(
                                        12,
                                        c: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 20),

                          // Workspace Name
                          Text(
                            'WORKSPACE NAME',
                            style: AppTextStyles.t(
                              11,
                              w: FontWeight.w700,
                              c: AppColors.textSecondary,
                              ls: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: wsNameCtrl,
                            cursorColor: AppColors.primary,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. Acme Growth Fleet',
                              prefixIcon: const Icon(
                                RemixIcons.community_line,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter a workspace name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // Business Legal / Trading Name
                          Text(
                            'BUSINESS NAME',
                            style: AppTextStyles.t(
                              11,
                              w: FontWeight.w700,
                              c: AppColors.textSecondary,
                              ls: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: businessNameCtrl,
                            cursorColor: AppColors.primary,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. Acme Media Corp',
                              prefixIcon: const Icon(
                                RemixIcons.store_2_line,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your business or brand name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // Workspace Slug URL
                          Text(
                            'WORKSPACE URL / SLUG',
                            style: AppTextStyles.t(
                              11,
                              w: FontWeight.w700,
                              c: AppColors.textSecondary,
                              ls: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: slugCtrl,
                            cursorColor: AppColors.primary,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              prefixText: 'emychat.app/',
                              prefixStyle: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              hintText: 'acme-media',
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter a URL slug';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // Business Category Dropdown
                          Text(
                            'BUSINESS CATEGORY',
                            style: AppTextStyles.t(
                              11,
                              w: FontWeight.w700,
                              c: AppColors.textSecondary,
                              ls: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCategory,
                                isExpanded: true,
                                icon: const Icon(
                                  RemixIcons.arrow_down_s_line,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                dropdownColor: AppColors.surfaceVariant,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                                items: categories.map((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) provider.setCategory(val);
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Time Zone & Country
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PRIMARY TIMEZONE',
                                      style: AppTextStyles.t(
                                        11,
                                        w: FontWeight.w700,
                                        c: AppColors.textSecondary,
                                        ls: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedTimezone,
                                          isExpanded: true,
                                          icon: const Icon(
                                            RemixIcons.arrow_down_s_line,
                                            size: 16,
                                            color: AppColors.textSecondary,
                                          ),
                                          dropdownColor:
                                              AppColors.surfaceVariant,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 13,
                                          ),
                                          items: timezones.map((tz) {
                                            return DropdownMenuItem(
                                              value: tz,
                                              child: Text(
                                                tz,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              provider.setTimezone(val);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'COUNTRY',
                                      style: AppTextStyles.t(
                                        11,
                                        w: FontWeight.w700,
                                        c: AppColors.textSecondary,
                                        ls: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedCountry,
                                          isExpanded: true,
                                          icon: const Icon(
                                            RemixIcons.arrow_down_s_line,
                                            size: 16,
                                            color: AppColors.textSecondary,
                                          ),
                                          dropdownColor:
                                              AppColors.surfaceVariant,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 13,
                                          ),
                                          items: countries.map((c) {
                                            return DropdownMenuItem(
                                              value: c,
                                              child: Text(
                                                c,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              provider.setCountry(val);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Selected Plan Badge
                          if (selectedPlan != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    RemixIcons.shield_check_line,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Plan to link: ${selectedPlan.name} (${selectedPlan.maxConnectedAccounts} accounts, ${selectedPlan.monthlyMessages} msgs/mo)',
                                      style: AppTextStyles.t(
                                        12,
                                        w: FontWeight.w500,
                                        c: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: wsController.isCreating
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation(
                                        AppColors.primary,
                                      ),
                                    ),
                                  )
                                : GradientButton(
                                    label: 'Create Workspace & Proceed to Checkout',
                                    icon: RemixIcons.arrow_right_line,
                                    onTap: () =>
                                        _handleCreateWorkspace(context),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
