import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../models/phone_demo_model.dart';
import '../providers/phone_demo_provider.dart';

export '../models/phone_demo_model.dart';

class InteractivePhoneDemo extends StatelessWidget {
  const InteractivePhoneDemo({
    super.key,
    this.platform = PhoneDemoPlatform.neutral,
    this.width = 295,
    this.height = 480,
    this.autoPlay = true,
  });

  final PhoneDemoPlatform platform;
  final double width;
  final double height;
  final bool autoPlay;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PhoneDemoProvider>(
      create: (_) => PhoneDemoProvider(platform: platform, autoPlay: autoPlay),
      child: _PhoneDemoView(
        platform: platform,
        width: width,
        height: height,
      ),
    );
  }
}

class _PhoneDemoView extends StatelessWidget {
  const _PhoneDemoView({
    required this.platform,
    required this.width,
    required this.height,
  });

  final PhoneDemoPlatform platform;
  final double width;
  final double height;

  Color _getHeaderBgColor() {
    switch (platform) {
      case PhoneDemoPlatform.whatsapp:
        return const Color(0xFF128C7E);
      case PhoneDemoPlatform.neutral:
        return const Color(0xFF0F172A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhoneDemoProvider>();
    final isCompact = height < 520;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0C1017),
        borderRadius: BorderRadius.circular(isCompact ? 28 : 34),
        border: Border.all(
          color: const Color(0xFF1E293B),
          width: isCompact ? 3 : 4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isCompact ? 25 : 30),
        child: Column(
          children: [
            // Top Notch / Status Bar
            _buildStatusBar(isCompact),

            // Chat App Header
            _buildChatHeader(context, provider, isCompact),

            // Message Canvas
            Expanded(
              child: _buildChatCanvas(provider, isCompact),
            ),

            // Bottom Input Bar
            _buildInputBar(isCompact),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(bool isCompact) {
    return Container(
      height: isCompact ? 26 : 32,
      color: _getHeaderBgColor(),
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 14 : 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            '9:41',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          Container(
            width: isCompact ? 60 : 70,
            height: isCompact ? 14 : 16,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(RemixIcons.signal_tower_fill, size: 10, color: Colors.white),
              SizedBox(width: 3),
              Icon(RemixIcons.wifi_line, size: 10, color: Colors.white),
              SizedBox(width: 3),
              Icon(RemixIcons.battery_2_charge_line, size: 11, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatHeader(
    BuildContext context,
    PhoneDemoProvider provider,
    bool isCompact,
  ) {
    final bgColor = _getHeaderBgColor();
    final isWhatsApp = platform == PhoneDemoPlatform.whatsapp;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(RemixIcons.arrow_left_s_line, size: 18, color: Colors.white),
          const SizedBox(width: 2),
          Stack(
            children: [
              CircleAvatar(
                radius: isCompact ? 13 : 15,
                backgroundColor: isWhatsApp
                    ? const Color(0xFF25D366)
                    : const Color(0xFF2563EB),
                child: Icon(
                  isWhatsApp
                      ? RemixIcons.whatsapp_fill
                      : RemixIcons.robot_line,
                  size: isCompact ? 14 : 16,
                  color: Colors.white,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: bgColor, width: 1.2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        isWhatsApp
                            ? 'EmyChat Store'
                            : 'EmyChat AI Bot',
                        style: TextStyle(
                          fontSize: isCompact ? 12 : 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      RemixIcons.checkbox_circle_fill,
                      size: 11,
                      color: Color(0xFF38BDF8),
                    ),
                  ],
                ),
                Text(
                  provider.isTyping
                      ? 'AI typing response...'
                      : (isWhatsApp
                          ? 'Online • Instant replies'
                          : 'Active now • Automated'),
                  style: TextStyle(
                    fontSize: 9.5,
                    color: provider.isTyping
                        ? const Color(0xFF38BDF8)
                        : Colors.white.withValues(alpha: 0.75),
                    fontWeight: provider.isTyping ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isWhatsApp ? RemixIcons.phone_line : RemixIcons.video_on_line,
              size: 15,
              color: Colors.white,
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(RemixIcons.refresh_line, size: 14, color: Colors.white70),
            onPressed: provider.restartConversation,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Replay demo',
          ),
        ],
      ),
    );
  }

  Widget _buildChatCanvas(PhoneDemoProvider provider, bool isCompact) {
    final isWhatsApp = platform == PhoneDemoPlatform.whatsapp;
    final canvasBg = isWhatsApp
        ? const Color(0xFF0B141A)
        : const Color(0xFF090D16);

    return Container(
      color: canvasBg,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 6 : 8,
      ),
      child: ListView(
        controller: provider.scrollController,
        physics: const ClampingScrollPhysics(),
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: isCompact ? 6 : 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xFF334155).withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(RemixIcons.lock_2_fill, size: 9, color: Color(0xFFFBBF24)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      isWhatsApp
                          ? 'End-to-end encrypted • EmyChat Engine'
                          : 'Official WhatsApp Web Multi-Device Protocol',
                      style: const TextStyle(
                        fontSize: 8.5,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Message 1: Customer (Incoming)
          if (provider.currentStep >= 1) ...[
            _buildCustomerBubble(
              text: 'Hi, I want to know more about your services.',
              time: '9:41 AM',
              isCompact: isCompact,
            ),
            SizedBox(height: isCompact ? 6 : 8),
          ],

          // AI Message 1 (Outgoing)
          if (provider.currentStep >= 2) ...[
            _buildAiBubble(
              provider: provider,
              text: "Hello! Welcome. I'd be happy to help. Are you looking for website development or mobile app development?",
              time: '9:41 AM',
              chips: provider.currentStep == 2
                  ? ['Website development', 'Mobile app development']
                  : null,
              isCompact: isCompact,
            ),
            SizedBox(height: isCompact ? 6 : 8),
          ],

          // Message 2: Customer (Incoming selection)
          if (provider.currentStep >= 3) ...[
            _buildCustomerBubble(
              text: 'Mobile app development.',
              time: '9:42 AM',
              isCompact: isCompact,
            ),
            SizedBox(height: isCompact ? 6 : 8),
          ],

          // AI Message 2 (Outgoing)
          if (provider.currentStep >= 4) ...[
            _buildAiBubble(
              provider: provider,
              text: 'Great! We develop custom mobile applications for businesses. Would you like to discuss your requirements?',
              time: '9:42 AM',
              actions: ['Book Consultation', 'View Portfolio'],
              isCompact: isCompact,
            ),
            SizedBox(height: isCompact ? 6 : 8),
          ],

          if (provider.isTyping) ...[
            _buildTypingBubble(isCompact),
            SizedBox(height: isCompact ? 6 : 8),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerBubble({
    required String text,
    required String time,
    required bool isCompact,
  }) {
    final isWhatsApp = platform == PhoneDemoPlatform.whatsapp;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 210),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 9 : 11,
          vertical: isCompact ? 6 : 7.5,
        ),
        decoration: BoxDecoration(
          color: isWhatsApp
              ? const Color(0xFF202C33)
              : const Color(0xFF1E293B),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
            bottomLeft: Radius.circular(2),
          ),
          border: Border.all(
            color: isWhatsApp
                ? const Color(0xFF2A3942)
                : const Color(0xFF334155),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: isCompact ? 11 : 11.5,
                color: Colors.white,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 3),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 8.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiBubble({
    required PhoneDemoProvider provider,
    required String text,
    required String time,
    List<String>? chips,
    List<String>? actions,
    required bool isCompact,
  }) {
    final isWhatsApp = platform == PhoneDemoPlatform.whatsapp;

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 220),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 9 : 11,
              vertical: isCompact ? 6 : 7.5,
            ),
            decoration: BoxDecoration(
              gradient: isWhatsApp
                  ? const LinearGradient(
                      colors: [Color(0xFF005C4B), Color(0xFF006653)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(2),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x20000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(RemixIcons.flashlight_fill, size: 8, color: Color(0xFFFBBF24)),
                          SizedBox(width: 2),
                          Text(
                            'AI AUTO-REPLY',
                            style: TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Color(0xFFFBBF24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: isCompact ? 11 : 11.5,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 8.5,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      RemixIcons.check_double_line,
                      size: 11,
                      color: Color(0xFF38BDF8),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (chips != null) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: chips.map((c) {
                return InkWell(
                  onTap: () => provider.onQuickReplyTap(c),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF38BDF8)),
                    ),
                    child: Text(
                      c,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF38BDF8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          if (actions != null) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: actions.map((a) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF22C55E)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(RemixIcons.checkbox_circle_line, size: 9, color: Color(0xFF22C55E)),
                      const SizedBox(width: 3),
                      Text(
                        a,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingBubble(bool isCompact) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(RemixIcons.robot_line, size: 10, color: Color(0xFF38BDF8)),
            SizedBox(width: 4),
            Text(
              'Generating smart response...',
              style: TextStyle(
                fontSize: 9.5,
                color: Color(0xFF38BDF8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 5 : 7,
      ),
      color: const Color(0xFF0F172A),
      child: Row(
        children: [
          const Icon(RemixIcons.emotion_line, size: 16, color: Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          const Icon(RemixIcons.add_line, size: 16, color: Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: isCompact ? 26 : 28,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Reply as EmyChat AI...',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(RemixIcons.mic_line, size: 15, color: Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          Container(
            width: isCompact ? 22 : 24,
            height: isCompact ? 22 : 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(RemixIcons.send_plane_2_fill, size: 11, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
