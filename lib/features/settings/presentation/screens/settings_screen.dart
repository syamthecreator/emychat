import 'package:emychat/app/theme/app_colors.dart';
import 'package:emychat/core/controller/theme_provider.dart';
import 'package:emychat/core/widgets/app_button.dart';
import 'package:emychat/core/widgets/status_badge.dart';
import 'package:emychat/features/workspace/controller/workspace_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _webhookController;

  @override
  void initState() {
    super.initState();
    final ws = context.read<WorkspaceController?>()?.activeWorkspace;
    _nameController = TextEditingController(text: ws?.name ?? 'My Workspace');
    _webhookController = TextEditingController(
      text: 'https://api.emychat.com/webhooks/events',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _webhookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Workspace Settings',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Manage organization details, webhooks, and channel security credentials.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),

                // Workspace Profile Section
                _buildSection(
                  title: 'General Profile',
                  description:
                      'Basic identifying information for this workspace.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Workspace Name',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13.5,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.only(top: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppButton.primary(
                          text: 'Save Changes',
                          size: AppButtonSize.sm,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Appearance & Theme Section
                _buildSection(
                  title: 'Interface Appearance & Theme',
                  description: 'Switch between Ultra Premium Midnight Sapphire, Arctic Silver, or follow your OS preference.',
                  child: Builder(
                    builder: (context) {
                      final themeProvider = context.watch<ThemeProvider>();
                      final mode = themeProvider.themeMode;

                      Widget themeOption({
                        required String title,
                        required String subtitle,
                        required IconData icon,
                        required ThemeMode targetMode,
                      }) {
                        final isSelected = mode == targetMode;
                        return Expanded(
                          child: InkWell(
                            onTap: () => themeProvider.setThemeMode(targetMode),
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 140),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.surfaceMuted
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.arcticBlue
                                      : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    icon,
                                    size: 18,
                                    color: isSelected
                                        ? AppColors.arcticBlue
                                        : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          title,
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          subtitle,
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      RemixIcons.checkbox_circle_fill,
                                      size: 16,
                                      color: AppColors.arcticBlue,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 600;
                          if (isNarrow) {
                            return Column(
                              children: [
                                themeOption(
                                  title: 'Midnight Sapphire',
                                  subtitle: 'Dark Theme',
                                  icon: RemixIcons.moon_line,
                                  targetMode: ThemeMode.dark,
                                ),
                                const SizedBox(height: 8),
                                themeOption(
                                  title: 'Arctic Silver',
                                  subtitle: 'Light Theme',
                                  icon: RemixIcons.sun_line,
                                  targetMode: ThemeMode.light,
                                ),
                                const SizedBox(height: 8),
                                themeOption(
                                  title: 'System Default',
                                  subtitle: 'Auto Match OS',
                                  icon: RemixIcons.computer_line,
                                  targetMode: ThemeMode.system,
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              themeOption(
                                title: 'Midnight Sapphire',
                                subtitle: 'Dark Theme',
                                icon: RemixIcons.moon_line,
                                targetMode: ThemeMode.dark,
                              ),
                              const SizedBox(width: 10),
                              themeOption(
                                title: 'Arctic Silver',
                                subtitle: 'Light Theme',
                                icon: RemixIcons.sun_line,
                                targetMode: ThemeMode.light,
                              ),
                              const SizedBox(width: 10),
                              themeOption(
                                title: 'System Default',
                                subtitle: 'Auto Match OS',
                                icon: RemixIcons.computer_line,
                                targetMode: ThemeMode.system,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Webhook Settings
                _buildSection(
                  title: 'WhatsApp Automation Webhook',
                  description: 'Endpoint receiving inbound events for WhatsApp automations.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Inbound Event URL',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.inputFill,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _webhookController,
                                readOnly: true,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                RemixIcons.file_copy_line,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () {},
                              tooltip: 'Copy URL',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          StatusBadge(
                            label: 'Verification Active',
                            type: StatusType.active,
                            isSmall: true,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Token hash validated with Meta App Dashboard.',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
