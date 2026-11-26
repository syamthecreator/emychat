import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/studio_icon_box.dart';
import '../../../../core/widgets/studio_pill.dart';
import '../providers/channel_provider.dart';
import '../providers/whatsapp_connect_provider.dart';

class WhatsAppConnectDialog extends StatelessWidget {
  const WhatsAppConnectDialog({
    super.key,
    this.initialChannelId,
    this.initialPhoneNumber,
  });

  final String? initialChannelId;
  final String? initialPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WhatsAppConnectProvider>(
      create: (dialogCtx) => WhatsAppConnectProvider(
        channelController: dialogCtx.read<ChannelController>(),
        initialChannelId: initialChannelId,
        initialPhoneNumber: initialPhoneNumber,
        onConnectedSuccess: (connectedChannel) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (dialogCtx.mounted) {
              Navigator.of(dialogCtx).pop(true);
              AppSnackBar.success(
                dialogCtx,
                'WhatsApp connected successfully as ${connectedChannel?.displayName ?? 'Device'}!',
              );
            }
          });
        },
      ),
      child: const _WhatsAppConnectDialogContent(),
    );
  }
}

class _WhatsAppConnectDialogContent extends StatelessWidget {
  const _WhatsAppConnectDialogContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WhatsAppConnectProvider>();
    final isConnected = provider.isConnected;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1420),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .6),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 20, 20),
              child: Row(
                children: [
                  const StudioIconBox(
                    RemixIcons.whatsapp_line,
                    AppColors.waColor,
                    size: 42,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Link WhatsApp Account',
                          style: AppTextStyles.t(18, w: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'WhatsApp Web Linked Device · Multi-Device Protocol',
                          style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      RemixIcons.close_line,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.border, height: 1),

            if (isConnected) ...[
              // Connected Success View
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.waColor.withValues(alpha: .15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.waColor, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          RemixIcons.checkbox_circle_fill,
                          size: 42,
                          color: AppColors.waColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'WhatsApp Connected!',
                      style: AppTextStyles.t(20, w: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      provider.connectedChannel != null
                          ? 'Linked as ${provider.connectedChannel!.displayName} (${provider.connectedChannel!.displayPhoneNumber})'
                          : 'Your device session is now active and ready for automation.',
                      style: AppTextStyles.t(13.5, c: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const StudioPill(
                      '🛡️ Anti-Ban Shield Active',
                      color: AppColors.waColor,
                      icon: RemixIcons.shield_check_line,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Tab Switcher (QR Code vs Phone Number)
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _tabButton(
                          context: context,
                          index: 0,
                          icon: RemixIcons.qr_code_line,
                          label: 'Scan QR Code',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _tabButton(
                          context: context,
                          index: 1,
                          icon: RemixIcons.phone_line,
                          label: 'Pair with Phone',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Content
              Padding(
                padding: const EdgeInsets.all(28),
                child: provider.selectedTab == 0
                    ? _buildQrTab(context, provider)
                    : _buildPairingTab(context, provider),
              ),

              // Bottom Security Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF090E17),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      RemixIcons.shield_keyhole_line,
                      size: 16,
                      color: AppColors.waColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '10 Anti-Ban Rules Enforced · Real macOS Chrome Fingerprint · No bulk scraping',
                        style: AppTextStyles.t(11.5, c: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final provider = context.watch<WhatsAppConnectProvider>();
    final active = provider.selectedTab == index;
    return InkWell(
      onTap: () => provider.selectTab(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.waColor.withValues(alpha: .15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: active
              ? Border.all(color: AppColors.waColor.withValues(alpha: .4))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: active ? AppColors.waColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.t(
                12.5,
                w: active ? FontWeight.w700 : FontWeight.w500,
                c: active ? AppColors.waColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrTab(BuildContext context, WhatsAppConnectProvider provider) {
    final qrBytes = provider.decodeQrBytes();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // QR Code Box
        Container(
          width: 220,
          height: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: provider.isLoading
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.waColor),
                      SizedBox(height: 12),
                      Text(
                        'Generating QR...',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : provider.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        RemixIcons.error_warning_line,
                        color: AppColors.error,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.errorMessage!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => provider.startSession(),
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : qrBytes != null
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.memory(
                      qrBytes,
                      width: 196,
                      height: 196,
                      fit: BoxFit.contain,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        RemixIcons.whatsapp_fill,
                        color: AppColors.waColor,
                        size: 28,
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(color: AppColors.waColor),
                ),
        ),

        const SizedBox(width: 24),

        // Steps instructions
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to scan with phone:',
                style: AppTextStyles.t(14, w: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _instructionStep('1', 'Open WhatsApp on your phone'),
              _instructionStep('2', 'Tap Settings (iOS) or Menu ⋮ (Android)'),
              _instructionStep('3', 'Tap Linked Devices > Link a Device'),
              _instructionStep('4', 'Point camera at the QR code to scan'),
              const SizedBox(height: 14),
              Row(
                children: [
                  GhostButton(
                    label: 'Refresh QR',
                    icon: RemixIcons.refresh_line,
                    onTap: provider.isLoading
                        ? null
                        : () => provider.startSession(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPairingTab(
    BuildContext context,
    WhatsAppConnectProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Link with phone number instead:',
          style: AppTextStyles.t(14, w: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your WhatsApp number including country code to receive an 8-digit pairing code.',
          style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: provider.phoneController,
                style: AppTextStyles.t(14),
                decoration: InputDecoration(
                  hintText: 'e.g. +91 98765 43210',
                  hintStyle: AppTextStyles.t(13, c: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceVariant.withValues(alpha: .5),
                  prefixIcon: const Icon(
                    RemixIcons.phone_line,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.waColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GradientButton(
              label: provider.isRequestingPairing
                  ? 'Generating...'
                  : 'Get Code',
              icon: RemixIcons.key_line,
              onTap: provider.isRequestingPairing
                  ? null
                  : () => provider.requestPairingCode(
                      onError: (msg) => AppSnackBar.error(context, msg),
                    ),
            ),
          ],
        ),
        if (provider.pairingCode != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.waColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.waColor.withValues(alpha: .3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      RemixIcons.shield_check_line,
                      size: 14,
                      color: AppColors.waColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Your 8-Digit Pairing Code (Valid for 10 min):',
                      style: AppTextStyles.t(
                        12,
                        c: AppColors.waColor,
                        w: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  provider.pairingCode!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GhostButton(
                      label: 'Copy Code',
                      icon: RemixIcons.file_copy_line,
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: provider.pairingCode!),
                        );
                        AppSnackBar.info(
                          context,
                          'Pairing code copied to clipboard',
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    GhostButton(
                      label: 'Get New Code',
                      icon: RemixIcons.refresh_line,
                      onTap: provider.isRequestingPairing
                          ? null
                          : () => provider.requestPairingCode(
                              forceNew: true,
                              onError: (msg) => AppSnackBar.error(context, msg),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'A notification has been sent to your phone. Tap it or open WhatsApp > Linked Devices > Link with phone number instead, and enter this code.',
                  style: AppTextStyles.t(12, c: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _instructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.waColor.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.waColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.t(12.5, c: AppColors.textSecondary, h: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
