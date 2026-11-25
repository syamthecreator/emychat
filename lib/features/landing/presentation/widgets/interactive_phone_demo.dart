import 'dart:async';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

enum PhoneDemoPlatform {
  neutral,
  whatsapp,
}

class InteractivePhoneDemo extends StatefulWidget {
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
  State<InteractivePhoneDemo> createState() => _InteractivePhoneDemoState();
}

class _InteractivePhoneDemoState extends State<InteractivePhoneDemo> {
  int _currentStep = 0;
  bool _isTyping = false;
  Timer? _sequenceTimer;
  Timer? _loopTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      _startConversationLoop();
    }
  }

  @override
  void didUpdateWidget(covariant InteractivePhoneDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.platform != widget.platform) {
      _restartConversation();
    }
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    _loopTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _restartConversation() {
    _sequenceTimer?.cancel();
    _loopTimer?.cancel();
    setState(() {
      _currentStep = 0;
      _isTyping = false;
    });
    _startConversationLoop();
  }

  void _startConversationLoop() {
    _sequenceTimer?.cancel();
    _loopTimer?.cancel();

    // T=0.5s: Customer sends message 1
    _sequenceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _currentStep = 1;
        _isTyping = false;
      });
      _scrollToBottom();

      // T=1.5s: AI starts typing
      _sequenceTimer = Timer(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _isTyping = true;
        });
        _scrollToBottom();

        // T=2.7s: AI sends message 1
        _sequenceTimer = Timer(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          setState(() {
            _currentStep = 2;
            _isTyping = false;
          });
          _scrollToBottom();

          // T=4.2s: Customer sends reply
          _sequenceTimer = Timer(const Duration(milliseconds: 1500), () {
            if (!mounted) return;
            setState(() {
              _currentStep = 3;
              _isTyping = false;
            });
            _scrollToBottom();

            // T=5.4s: AI starts typing reply 2
            _sequenceTimer = Timer(const Duration(milliseconds: 1000), () {
              if (!mounted) return;
              setState(() {
                _isTyping = true;
              });
              _scrollToBottom();

              // T=6.6s: AI sends message 2
              _sequenceTimer = Timer(const Duration(milliseconds: 1200), () {
                if (!mounted) return;
                setState(() {
                  _currentStep = 4;
                  _isTyping = false;
                });
                _scrollToBottom();

                // T=11s: Loop restarts
                _loopTimer = Timer(const Duration(milliseconds: 4000), () {
                  if (!mounted) return;
                  setState(() {
                    _currentStep = 0;
                    _isTyping = false;
                  });
                  _startConversationLoop();
                });
              });
            });
          });
        });
      });
    });
  }

  void _onQuickReplyTap(String selection) {
    if (_currentStep == 2) {
      _sequenceTimer?.cancel();
      setState(() {
        _currentStep = 3;
        _isTyping = true;
      });
      _scrollToBottom();

      _sequenceTimer = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          _currentStep = 4;
          _isTyping = false;
        });
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = widget.height < 520;

    return Container(
      width: widget.width,
      height: widget.height,
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
            _buildChatHeader(isCompact),

            // Message Canvas
            Expanded(
              child: _buildChatCanvas(isCompact),
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
          // Dynamic Island Pill
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

  Color _getHeaderBgColor() {
    switch (widget.platform) {
      case PhoneDemoPlatform.whatsapp:
        return const Color(0xFF128C7E);
      case PhoneDemoPlatform.neutral:
        return const Color(0xFF0F172A);
    }
  }

  Widget _buildChatHeader(bool isCompact) {
    final bgColor = _getHeaderBgColor();
    final isWhatsApp = widget.platform == PhoneDemoPlatform.whatsapp;

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
                  _isTyping
                      ? 'AI typing response...'
                      : (isWhatsApp
                          ? 'Online • Instant replies'
                          : 'Active now • Automated'),
                  style: TextStyle(
                    fontSize: 9.5,
                    color: _isTyping
                        ? const Color(0xFF38BDF8)
                        : Colors.white.withValues(alpha: 0.75),
                    fontWeight: _isTyping ? FontWeight.w600 : FontWeight.w400,
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
            onPressed: _restartConversation,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Replay demo',
          ),
        ],
      ),
    );
  }

  Widget _buildChatCanvas(bool isCompact) {
    final isWhatsApp = widget.platform == PhoneDemoPlatform.whatsapp;

    final canvasBg = isWhatsApp
        ? const Color(0xFF0B141A) // WhatsApp dark wallpaper
        : const Color(0xFF090D16);

    return Container(
      color: canvasBg,
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 6 : 8,
      ),
      child: ListView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        children: [
          // Security / Session Encryption Badge
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
          if (_currentStep >= 1) ...[
            _buildCustomerBubble(
              text: 'Hi, I want to know more about your services.',
              time: '9:41 AM',
              isCompact: isCompact,
            ),
            SizedBox(height: isCompact ? 6 : 8),
          ],

          // AI Message 1 (Outgoing)
          if (_currentStep >= 2) ...[
            _buildAiBubble(
              text: "Hello! Welcome. I'd be happy to help. Are you looking for website development or mobile app development?",
              time: '9:41 AM',
              chips: _currentStep == 2
                  ? ['Website development', 'Mobile app development']
                  : null,
              isCompact: isCompact,
            ),
            SizedBox(height: isCompact ? 6 : 8),
          ],

          // Message 2: Customer (Incoming selection)
          if (_currentStep >= 3) ...[
            _buildCustomerBubble(
              text: 'Mobile app development.',
              time: '9:42 AM',
              isCompact: isCompact,
            ),
            SizedBox(height: isCompact ? 6 : 8),
          ],

          // AI Message 2 (Outgoing)
          if (_currentStep >= 4) ...[
            _buildAiBubble(
              text: 'Great! We develop custom mobile applications for businesses. Would you like to discuss your requirements?',
              time: '9:42 AM',
              actions: ['Book Consultation', 'View Portfolio'],
              isCompact: isCompact,
            ),
            SizedBox(height: isCompact ? 6 : 8),
          ],

          // Live Typing Indicator when AI is thinking
          if (_isTyping) ...[
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
    final isWhatsApp = widget.platform == PhoneDemoPlatform.whatsapp;

    final bubbleColor = isWhatsApp
        ? const Color(0xFF005C4B)
        : const Color(0xFF1E293B);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: widget.width * 0.8),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 9 : 11,
          vertical: isCompact ? 6 : 7,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: isCompact ? 11 : 11.5,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 8.5,
                    color: Colors.white.withValues(alpha: 0.6),
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
    );
  }

  Widget _buildAiBubble({
    required String text,
    required String time,
    List<String>? chips,
    List<String>? actions,
    required bool isCompact,
  }) {
    final isWhatsApp = widget.platform == PhoneDemoPlatform.whatsapp;

    final bubbleColor = isWhatsApp
        ? const Color(0xFF202C33)
        : const Color(0xFF0F172A);

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: widget.width * 0.84),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 9 : 11,
              vertical: isCompact ? 6 : 7,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(3),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(RemixIcons.sparkling_fill, size: 8, color: Color(0xFF38BDF8)),
                          SizedBox(width: 3),
                          Text(
                            'AI AUTO-REPLY',
                            style: TextStyle(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF38BDF8),
                              letterSpacing: 0.3,
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
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 8.5,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Interactive Chips
          if (chips != null && chips.isNotEmpty) ...[
            const SizedBox(height: 5),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: chips.map((chip) {
                return InkWell(
                  onTap: () => _onQuickReplyTap(chip),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      chip,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Interactive CTA Action Buttons
          if (actions != null && actions.isNotEmpty) ...[
            const SizedBox(height: 5),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: actions.map((act) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    act,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
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
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(RemixIcons.sparkling_fill, size: 9, color: Color(0xFF38BDF8)),
            const SizedBox(width: 5),
            const Text(
              'EmyChat AI replying',
              style: TextStyle(
                fontSize: 9.5,
                color: Color(0xFFCBD5E1),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            _buildAnimatedDot(0),
            _buildAnimatedDot(1),
            _buildAnimatedDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 150)),
      curve: Curves.easeInOut,
      builder: (context, val, child) {
        return Container(
          width: 3.5,
          height: 3.5,
          margin: const EdgeInsets.symmetric(horizontal: 1.2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: val),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputBar(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 5 : 6,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(
          top: BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      child: Row(
        children: [
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
