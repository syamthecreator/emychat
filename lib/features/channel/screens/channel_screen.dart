import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/ghost_button.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/responsive_grid.dart';
import '../../../core/widgets/studio_card.dart';
import '../../../core/widgets/studio_icon_box.dart';
import '../../../core/widgets/studio_page.dart';
import '../../../core/widgets/studio_page_heading.dart';
import '../../../core/widgets/studio_pill.dart';
import '../models/whatsapp_channel_model.dart';
import '../providers/channel_provider.dart';
import '../widgets/whatsapp_connect_dialog.dart';

class ChannelScreen extends StatelessWidget {
  const ChannelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger initial load once if not yet loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ChannelController>();
      if (!controller.hasLoadedOnce && !controller.isLoading) {
        controller.loadChannels();
      }
    });

    final channelController = context.watch<ChannelController>();

    Future<void> syncChannels() async {
      final controller = context.read<ChannelController>();
      await controller.syncChannels();

      if (!context.mounted) return;

      if (controller.errorMessage != null) {
        AppSnackBar.error(context, controller.errorMessage!);
      } else {
        AppSnackBar.success(
          context,
          controller.successMessage ?? 'Channels synchronized successfully',
        );
      }
    }

    void copyToClipboard(String text, String label) {
      Clipboard.setData(ClipboardData(text: text));
      AppSnackBar.info(context, '$label copied to clipboard');
    }

    void showWhatsAppDisconnectDialog(String channelId, String name) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          title: Row(
            children: [
              const StudioIconBox(
                RemixIcons.error_warning_line,
                AppColors.error,
                size: 38,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Disconnect WhatsApp',
                  style: AppTextStyles.t(18, w: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to disconnect $name? '
            'This will gracefully unlink the session from your WhatsApp account.',
            style: AppTextStyles.t(14, c: AppColors.textSecondary, h: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.t(14, c: AppColors.textSecondary),
              ),
            ),
            GradientButton(
              label: 'Disconnect',
              icon: RemixIcons.shut_down_line,
              onTap: () async {
                Navigator.of(dialogContext).pop();

                final success = await context
                    .read<ChannelController>()
                    .disconnectWhatsApp(channelId);

                if (!context.mounted) return;

                if (success) {
                  AppSnackBar.success(context, 'WhatsApp channel disconnected');
                } else {
                  AppSnackBar.error(
                    context,
                    context.read<ChannelController>().errorMessage ??
                        'Failed to disconnect WhatsApp channel',
                  );
                }
              },
            ),
          ],
        ),
      );
    }

    void showWhatsAppConnectModal({String? channelId, String? phoneNumber}) {
      showDialog(
        context: context,
        builder: (dialogContext) => WhatsAppConnectDialog(
          initialChannelId: channelId,
          initialPhoneNumber: phoneNumber,
        ),
      );
    }

    final whatsAppAccounts = channelController.whatsAppAccounts;
    final isWaConnected = channelController.isWhatsAppConnected;
    final primaryWaAccount = channelController.primaryWhatsAppAccount;
    final isSyncing = channelController.isSyncing;

    return StudioPage(
      children: [
        // 1. Top Action Bar
        StudioPageHeading(
          actions: [
            GhostButton(
              label: isSyncing ? 'Syncing...' : 'Sync Channels',
              icon: RemixIcons.refresh_line,
              onTap: isSyncing ? null : syncChannels,
            ),
            GradientButton(
              label: 'Connect WhatsApp',
              icon: RemixIcons.add_line,
              onTap: () => showWhatsAppConnectModal(),
            ),
          ],
        ),

        // 2. Real Channel Hero Overview Banner
        _ChannelHeroBanner(
          waConnected: isWaConnected,
          waHandle: primaryWaAccount?.displayPhoneNumber ?? 'Not connected',
          waCount: whatsAppAccounts.length,
          isSyncing: isSyncing,
          onConnectTap: () => showWhatsAppConnectModal(),
          onSyncTap: isSyncing ? null : syncChannels,
        ),

        const SizedBox(height: 12),

        // 3. Main Connected Channel Cards (Real values only)
        if (channelController.isLoading && !channelController.hasLoadedOnce)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else
          ResponsiveGrid(
            minItemWidth: 440,
            maxColumns: 2,
            spacing: 20,
            children: [
              if (whatsAppAccounts.isNotEmpty)
                ...whatsAppAccounts.map(
                  (waChannel) => _WhatsAppChannelCard(
                    channel: waChannel,
                    onDisconnect: () => showWhatsAppDisconnectDialog(
                      waChannel.id,
                      waChannel.displayName,
                    ),
                    onCopyId: (id) => copyToClipboard(id, 'WhatsApp ID'),
                    onSync: isSyncing ? null : syncChannels,
                    onReconnect: () => showWhatsAppConnectModal(
                      channelId: waChannel.id,
                      phoneNumber: waChannel.phoneNumber,
                    ),
                  ),
                )
              else
                _EmptyWhatsAppChannelCard(
                  onConnect: () => showWhatsAppConnectModal(),
                ),
            ],
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  CHANNEL HERO BANNER
// ════════════════════════════════════════════════════════════════════════════

class _ChannelHeroBanner extends StatelessWidget {
  const _ChannelHeroBanner({
    required this.waConnected,
    required this.waHandle,
    required this.waCount,
    required this.isSyncing,
    required this.onConnectTap,
    required this.onSyncTap,
  });

  final bool waConnected;
  final String waHandle;
  final int waCount;
  final bool isSyncing;
  final VoidCallback onConnectTap;
  final VoidCallback? onSyncTap;

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      hoverable: false,
      padding: const EdgeInsets.all(26),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: .14),
          const Color(0xFF0E1726),
          const Color(0xFF070C15),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth > 880;
          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StudioPill(
                    waConnected
                        ? '$waCount WhatsApp Active'
                        : 'No Channels Connected',
                    color: waConnected
                        ? AppColors.waColor
                        : AppColors.textMuted,
                    icon: waConnected
                        ? RemixIcons.checkbox_circle_line
                        : RemixIcons.links_line,
                  ),
                  const StudioPill(
                    'WhatsApp Web Protocol',
                    color: AppColors.accent,
                    icon: RemixIcons.cloud_line,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'WhatsApp Channel Management',
                style: AppTextStyles.t(28, w: FontWeight.w700, ls: -.8),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect and manage your WhatsApp accounts via QR Code multi-device protocol to automate conversations, customer journeys, and support in real time.',
                style: AppTextStyles.t(
                  14.5,
                  c: AppColors.textSecondary,
                  h: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  GradientButton(
                    label: 'Connect WhatsApp',
                    icon: RemixIcons.add_circle_line,
                    onTap: onConnectTap,
                  ),
                  GhostButton(
                    label: isSyncing ? 'Syncing...' : 'Sync Channels',
                    icon: RemixIcons.refresh_line,
                    onTap: onSyncTap,
                  ),
                ],
              ),
            ],
          );

          final summaryBox = Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: .08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Channel Status',
                      style: AppTextStyles.t(14, w: FontWeight.w700),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: waConnected
                            ? AppColors.success
                            : AppColors.textMuted,
                        shape: BoxShape.circle,
                        boxShadow: waConnected
                            ? [
                                BoxShadow(
                                  color: AppColors.success.withValues(
                                    alpha: .7,
                                  ),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _StatusMiniRow(
                  icon: RemixIcons.whatsapp_line,
                  color: AppColors.waColor,
                  label: 'WhatsApp',
                  value: waConnected ? waHandle : 'Disconnected',
                ),
                const SizedBox(height: 10),
                const _StatusMiniRow(
                  icon: RemixIcons.shield_check_line,
                  color: AppColors.primary,
                  label: 'Auth Method',
                  value: 'Multi-Device QR Code',
                ),
                const SizedBox(height: 10),
                const _StatusMiniRow(
                  icon: RemixIcons.flashlight_line,
                  color: AppColors.waColor,
                  label: 'Anti-Ban Engine',
                  value: 'Active & Enforced',
                ),
              ],
            ),
          );

          return isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 28),
                    summaryBox,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [left, const SizedBox(height: 24), summaryBox],
                );
        },
      ),
    );
  }
}

class _StatusMiniRow extends StatelessWidget {
  const _StatusMiniRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.t(12.5, c: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.t(12.5, w: FontWeight.w600),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  WHATSAPP CHANNEL CARD
// ════════════════════════════════════════════════════════════════════════════

class _WhatsAppChannelCard extends StatelessWidget {
  const _WhatsAppChannelCard({
    required this.channel,
    required this.onDisconnect,
    required this.onCopyId,
    required this.onSync,
    this.onReconnect,
  });

  final WhatsAppChannelModel channel;
  final VoidCallback onDisconnect;
  final void Function(String) onCopyId;
  final VoidCallback? onSync;
  final VoidCallback? onReconnect;

  @override
  Widget build(BuildContext context) {
    final isConnected = channel.isConnected;

    return StudioCard(
      hoverable: true,
      padding: const EdgeInsets.all(28),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.waColor.withValues(alpha: .08),
          const Color(0xFF0E1726),
          const Color(0xFF070C15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              if (channel.profilePic != null && channel.profilePic!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    channel.profilePic!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const StudioIconBox(
                          RemixIcons.whatsapp_line,
                          AppColors.waColor,
                          size: 48,
                        ),
                  ),
                )
              else
                const StudioIconBox(
                  RemixIcons.whatsapp_line,
                  AppColors.waColor,
                  size: 48,
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            channel.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.t(18, w: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StudioPill(
                          isConnected ? 'Connected' : channel.status,
                          color: isConnected
                              ? AppColors.waColor
                              : AppColors.warning,
                          icon: isConnected
                              ? RemixIcons.checkbox_circle_line
                              : RemixIcons.loader_4_line,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channel.displayPhoneNumber,
                      style: AppTextStyles.t(13, c: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  RemixIcons.shut_down_line,
                  size: 20,
                  color: AppColors.error,
                ),
                tooltip: 'Disconnect Channel',
                onPressed: onDisconnect,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Metadata Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: .06)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _IdCopyItem(
                    label: 'PHONE NUMBER',
                    value: channel.displayPhoneNumber,
                    onCopy: () => onCopyId(channel.phoneNumber ?? ''),
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: Colors.white.withValues(alpha: .08),
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                ),
                Expanded(
                  child: _IdCopyItem(
                    label: 'PROTOCOL',
                    value: 'Multi-Device QR',
                    onCopy: () => onCopyId('Multi-Device Web Protocol'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Feature Badges
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StudioPill('Anti-Ban Protection', color: AppColors.waColor),
              StudioPill('Interactive Menus', color: AppColors.primary),
              StudioPill('Full Media Support', color: AppColors.accent),
              StudioPill('Zero Fees', color: AppColors.success),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isConnected && onReconnect != null) ...[
                GradientButton(
                  label: 'Reconnect',
                  icon: RemixIcons.refresh_line,
                  onTap: onReconnect,
                ),
                const SizedBox(width: 8),
              ],
              GhostButton(
                label: 'Sync Now',
                icon: RemixIcons.refresh_line,
                onTap: onSync,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  EMPTY WHATSAPP CHANNEL CARD
// ════════════════════════════════════════════════════════════════════════════

class _EmptyWhatsAppChannelCard extends StatelessWidget {
  const _EmptyWhatsAppChannelCard({required this.onConnect});

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      hoverable: false,
      padding: const EdgeInsets.all(28),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.waColor.withValues(alpha: .06),
          const Color(0xFF0E1726),
          const Color(0xFF070C15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StudioIconBox(
                RemixIcons.whatsapp_line,
                AppColors.waColor,
                size: 46,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WhatsApp (Linked Device)',
                      style: AppTextStyles.t(17, w: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Multi-Device QR Code · Instant Connection',
                      style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const StudioPill(
                'Instant',
                color: AppColors.waColor,
                icon: RemixIcons.flashlight_line,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Link your physical WhatsApp or WhatsApp Business app in 15 seconds. Keep your phone number with zero Meta developer setup hurdles.',
            style: AppTextStyles.t(13.5, c: AppColors.textSecondary, h: 1.45),
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: 'Scan QR Code to Connect',
            icon: RemixIcons.qr_code_line,
            onTap: onConnect,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  HELPER ITEM
// ════════════════════════════════════════════════════════════════════════════

class _IdCopyItem extends StatelessWidget {
  const _IdCopyItem({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.t(11.5, c: AppColors.textMuted)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.t(12.5, w: FontWeight.w600),
              ),
            ),
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  RemixIcons.file_copy_line,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
