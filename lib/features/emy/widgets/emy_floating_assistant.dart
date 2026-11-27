import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../app/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/emy_models.dart';
import '../providers/emy_provider.dart';

class EmyFloatingAssistant extends StatefulWidget {
  const EmyFloatingAssistant({super.key});

  @override
  State<EmyFloatingAssistant> createState() => _EmyFloatingAssistantState();
}

class _EmyFloatingAssistantState extends State<EmyFloatingAssistant> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? preset]) async {
    final text = (preset ?? _inputController.text).trim();
    if (text.isEmpty) return;

    if (preset == null) {
      _inputController.clear();
    }

    final auth = context.read<AuthController>();
    final emy = context.read<EmyProvider>();

    _scrollToBottom();
    await emy.sendMessage(text, isAuthenticated: auth.isAuthenticated);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final emy = context.watch<EmyProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        emy.syncAuthState(auth.isAuthenticated);
      }
    });

    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 520;
    final windowWidth = isCompact ? size.width - 24 : 390.0;
    final windowHeight = isCompact ? (size.height * 0.72).clamp(360.0, 560.0) : 540.0;

    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (overlayContext) => Stack(
            children: [
              Positioned(
                right: 20,
                bottom: 20,
                child: Material(
                  type: MaterialType.transparency,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) {
                          return FadeTransition(
                            opacity: anim,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.92, end: 1.0)
                                  .animate(anim),
                              alignment: Alignment.bottomRight,
                              child: child,
                            ),
                          );
                        },
                        child: emy.isOpen
                            ? Padding(
                                key: const ValueKey('emy-window'),
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _buildChatWindow(
                                  overlayContext,
                                  emy: emy,
                                  isAuthenticated: auth.isAuthenticated,
                                  width: windowWidth,
                                  height: windowHeight,
                                ),
                              )
                            : const SizedBox.shrink(key: ValueKey('emy-closed')),
                      ),
                      _buildFloatingTrigger(emy),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingTrigger(EmyProvider emy) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!emy.isOpen)
          GestureDetector(
            onTap: emy.toggleOpen,
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.arcticBlue.withValues(alpha: 0.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Chat with Emy',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        Tooltip(
          message: emy.isOpen ? 'Close Emy' : 'Chat with Emy',
          child: InkWell(
            onTap: emy.toggleOpen,
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.arcticBlue,
                    AppColors.sapphireBlue,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sapphireBlue.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(
                emy.isOpen
                    ? RemixIcons.close_line
                    : RemixIcons.sparkling_2_fill,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatWindow(
    BuildContext context, {
    required EmyProvider emy,
    required bool isAuthenticated,
    required double width,
    required double height,
  }) {
    final messages = emy.messages;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: const BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.arcticBlue, AppColors.sapphireBlue],
                    ),
                  ),
                  child: const Icon(
                    RemixIcons.sparkling_2_fill,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Emy',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'EmyChat AI Support Assistant',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (emy.hasUserMessages)
                  IconButton(
                    icon: const Icon(
                      RemixIcons.delete_bin_6_line,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: 'Clear chat',
                    onPressed: () =>
                        emy.clearChat(isAuthenticated: isAuthenticated),
                  ),
                IconButton(
                  icon: const Icon(
                    RemixIcons.close_line,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Minimize',
                  onPressed: emy.closeChat,
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: emy.isLoadingHistory
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(14),
                    itemCount: messages.length +
                        (emy.isSending ? 1 : 0) +
                        (!emy.hasUserMessages ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < messages.length) {
                        return _MessageBubble(message: messages[index]);
                      }
                      if (!emy.hasUserMessages && index == messages.length) {
                        return _QuickPrompts(onSelect: _handleSend);
                      }
                      return const _TypingIndicatorBubble();
                    },
                  ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: const BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: TextField(
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ask Emy about EmyChat or your docs...',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: emy.isSending ? null : () => _handleSend(),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.sapphireBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                    child: emy.isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(RemixIcons.send_plane_2_fill, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final EmyMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [AppColors.sapphireBlue, AppColors.royalSapphire],
                )
              : null,
          color: isUser
              ? null
              : message.isError
                  ? AppColors.error.withValues(alpha: 0.14)
                  : AppColors.darkCardMuted,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 14),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: message.isError
                      ? AppColors.error.withValues(alpha: 0.4)
                      : AppColors.borderSubtle,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              message.content.replaceAll('**', ''),
              style: TextStyle(
                color: isUser
                    ? Colors.white
                    : message.isError
                        ? AppColors.error
                        : AppColors.textPrimary,
                fontSize: 13.2,
                height: 1.42,
              ),
            ),
            if (message.sources.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: message.sources
                    .map(
                      (src) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sapphireBlue.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.arcticBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              RemixIcons.file_text_line,
                              size: 11,
                              color: AppColors.arcticBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              src,
                              style: const TextStyle(
                                color: AppColors.arcticBlueLight,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickPrompts extends StatelessWidget {
  const _QuickPrompts({required this.onSelect});

  final ValueChanged<String> onSelect;

  static const _prompts = [
    'How do I connect WhatsApp?',
    'How do automations work?',
    'What is in my company docs?',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: _prompts
            .map(
              (prompt) => ActionChip(
                label: Text(
                  prompt,
                  style: const TextStyle(
                    color: AppColors.arcticBlueLight,
                    fontSize: 11.5,
                  ),
                ),
                backgroundColor: AppColors.inputFill,
                side: const BorderSide(color: AppColors.border),
                onPressed: () => onSelect(prompt),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TypingIndicatorBubble extends StatefulWidget {
  const _TypingIndicatorBubble();

  @override
  State<_TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<_TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkCardMuted,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(14),
          ),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final phase = (_controller.value - i * 0.2) % 1.0;
                final opacity = phase < 0.5 ? 0.35 + phase : 1.35 - phase;
                return Container(
                  width: 7,
                  height: 7,
                  margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
                  decoration: BoxDecoration(
                    color: AppColors.arcticBlue.withValues(
                      alpha: opacity.clamp(0.25, 1.0),
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
