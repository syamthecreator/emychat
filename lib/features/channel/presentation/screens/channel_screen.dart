import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/ghost_button.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/studio_card.dart';
import '../../../../core/widgets/studio_icon_box.dart';
import '../../../../core/widgets/studio_page.dart';
import '../../../../core/widgets/studio_page_heading.dart';
import '../../../../core/widgets/studio_pill.dart';
import '../../controller/channel_controller.dart';
import '../../data/models/whatsapp_channel_model.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({super.key});

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChannelController>().loadChannels();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        if (channelController.isLoading && whatsAppAccounts.isEmpty)
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
                  children: [
                    left,
                    const SizedBox(height: 24),
                    summaryBox,
                  ],
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
//  WHATSAPP CONNECT MODAL (QR CODE & PAIRING CODE)
// ════════════════════════════════════════════════════════════════════════════

class WhatsAppConnectDialog extends StatefulWidget {
  const WhatsAppConnectDialog({
    super.key,
    this.initialChannelId,
    this.initialPhoneNumber,
  });

  final String? initialChannelId;
  final String? initialPhoneNumber;

  @override
  State<WhatsAppConnectDialog> createState() => _WhatsAppConnectDialogState();
}

class _WhatsAppConnectDialogState extends State<WhatsAppConnectDialog> {
  int _selectedTab = 0; // 0 = QR Code, 1 = Phone Pairing Code
  bool _isLoading = true;
  String? _errorMessage;
  String? _channelId;
  String? _status;
  String? _qrCodeBase64;
  String? _pairingCode;
  Timer? _pollTimer;
  WhatsAppChannelModel? _connectedChannel;

  final _phoneController = TextEditingController();
  bool _isRequestingPairing = false;

  @override
  void initState() {
    super.initState();
    _channelId = widget.initialChannelId;
    if (widget.initialPhoneNumber != null &&
        widget.initialPhoneNumber!.isNotEmpty) {
      _phoneController.text = widget.initialPhoneNumber!;
    }
    _startSession();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _startSession({String? phoneNumber}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = context.read<ChannelController>();
      final res = await controller.connectWhatsApp(
        channelId: _channelId,
        phoneNumber: phoneNumber,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _channelId = res['channelId'] as String?;
        _status = res['status'] as String? ?? 'SCAN_QR';
        _qrCodeBase64 = res['qrCodeBase64'] as String?;
        _pairingCode = res['pairingCode'] as String?;
      });

      _startPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('ApiException: ', '');
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_channelId == null || !mounted) {
        timer.cancel();
        return;
      }

      try {
        final controller = context.read<ChannelController>();
        final res = await controller.getWhatsAppStatus(_channelId!);

        if (!mounted) return;

        final status = res['status'] as String?;
        final qr = res['qrCodeBase64'] as String?;
        final pair = res['pairingCode'] as String?;

        if (qr != null && qr != _qrCodeBase64) {
          setState(() => _qrCodeBase64 = qr);
        }
        if (pair != null && _pairingCode == null) {
          setState(() => _pairingCode = pair);
        }

        if (status == 'CONNECTED') {
          timer.cancel();
          setState(() {
            _status = 'CONNECTED';
            if (res['channel'] != null) {
              _connectedChannel = WhatsAppChannelModel.fromJson(
                Map<String, dynamic>.from(res['channel'] as Map),
              );
            }
          });

          // Refresh channel state in background
          controller.loadChannels();

          // Gracefully close dialog after 1.5s
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.of(context).pop(true);
              AppSnackBar.success(
                context,
                'WhatsApp connected successfully as ${_connectedChannel?.displayName ?? 'Device'}!',
              );
            }
          });
        }
      } catch (_) {}
    });
  }

  Uint8List? _decodeQrBytes(String? dataUrl) {
    if (dataUrl == null || dataUrl.isEmpty) return null;
    try {
      final commaIdx = dataUrl.indexOf(',');
      final cleanBase64 = commaIdx != -1
          ? dataUrl.substring(commaIdx + 1)
          : dataUrl;
      return base64Decode(cleanBase64.replaceAll(RegExp(r'\s+'), ''));
    } catch (e) {
      debugPrint('QR decode error: $e');
      return null;
    }
  }

  Future<void> _requestPairingCode({bool forceNew = false}) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppSnackBar.error(
        context,
        'Please enter your phone number with country code',
      );
      return;
    }

    if (forceNew) {
      setState(() => _pairingCode = null);
    }

    setState(() => _isRequestingPairing = true);
    await _startSession(phoneNumber: phone);
    if (mounted) {
      setState(() => _isRequestingPairing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _status == 'CONNECTED';

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
                      _connectedChannel != null
                          ? 'Linked as ${_connectedChannel!.displayName} (${_connectedChannel!.displayPhoneNumber})'
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
                          index: 0,
                          icon: RemixIcons.qr_code_line,
                          label: 'Scan QR Code',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _tabButton(
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
                child: _selectedTab == 0 ? _buildQrTab() : _buildPairingTab(),
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
    required int index,
    required IconData icon,
    required String label,
  }) {
    final active = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
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

  Widget _buildQrTab() {
    final qrBytes = _decodeQrBytes(_qrCodeBase64);

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
          child: _isLoading
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
              : _errorMessage != null
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
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _startSession(),
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
                    onTap: _isLoading ? null : () => _startSession(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPairingTab() {
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
                controller: _phoneController,
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
              label: _isRequestingPairing ? 'Generating...' : 'Get Code',
              icon: RemixIcons.key_line,
              onTap: _isRequestingPairing ? null : _requestPairingCode,
            ),
          ],
        ),
        if (_pairingCode != null) ...[
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
                  _pairingCode!,
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
                        Clipboard.setData(ClipboardData(text: _pairingCode!));
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
                      onTap: _isRequestingPairing
                          ? null
                          : () => _requestPairingCode(forceNew: true),
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
