import 'package:emychat/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(color: AppColors.background, child: child);
  }
}

//
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleSpan,
    this.green = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final InlineSpan? subtitleSpan;
  final bool green;

  @override
  Widget build(BuildContext context) {
    const subStyle = TextStyle(
      fontSize: 13.5,
      color: AppColors.textSecondary,
      height: 1.4,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: green
                ? AppColors.mint.withValues(alpha: 0.12)
                : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: green
                  ? AppColors.mint.withValues(alpha: 0.25)
                  : AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            color: green ? AppColors.mint : AppColors.textPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              if (subtitleSpan != null)
                Text.rich(subtitleSpan!, style: subStyle)
              else if (subtitle != null)
                Text(subtitle!, style: subStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    ),
  );
}

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.maxLength,
    this.letterSpacing,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;
  final double? letterSpacing;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isFocused ? AppColors.accentPrimary : AppColors.inputBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (widget.prefixIcon != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                widget.prefixIcon,
                size: 16,
                color: _isFocused
                    ? AppColors.accentPrimary
                    : AppColors.textMuted,
              ),
            ),
          ] else
            const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              autofillHints: widget.autofillHints,
              textInputAction: widget.textInputAction,
              onSubmitted: widget.onSubmitted,
              maxLength: widget.maxLength,
              cursorColor: AppColors.accentPrimary,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textPrimary,
                letterSpacing: widget.letterSpacing,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                counterText: '',
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          if (widget.suffix != null) widget.suffix!,
        ],
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.icon,
    this.gradient,
    required this.onPressed,
    this.loading = false,
    this.loadingLabel,
    this.iconAfter = false,
    this.shadowColor,
  });

  final String label;
  final IconData icon;
  final Gradient? gradient;
  final VoidCallback onPressed;
  final bool loading;
  final String? loadingLabel;
  final bool iconAfter;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      loading ? (loadingLabel ?? label) : label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.onPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
    );

    final leading = loading
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.onPrimary,
            ),
          )
        : Icon(icon, color: AppColors.onPrimary, size: 17);

    return SizedBox(
      width: double.infinity,
      height: 42,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.white.withValues(alpha: 0.12),
          onTap: loading ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: iconAfter && !loading
                  ? [Flexible(child: text), const SizedBox(width: 8), leading]
                  : [leading, const SizedBox(width: 8), Flexible(child: text)],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthTextLink extends StatelessWidget {
  const AuthTextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accentPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Official multi-color Google "G" icon rendered via vector paths.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: const _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final rect = Rect.fromLTWH(0, 0, w, h);

    // Blue #4285F4
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    // Green #34A853
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    // Yellow #FBBC05
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    // Red #EA4335
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;

    final center = Offset(w * 0.5, h * 0.5);
    final radius = w * 0.5;
    final innerRadius = w * 0.28;

    // Red segment (top)
    final redPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, -0.785, -2.356, false)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // Yellow segment (bottom-left)
    final yellowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, 1.57, 1.57, false)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Green segment (bottom-right)
    final greenPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, 0.0, 1.57, false)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Blue horizontal bar and right arc
    final bluePath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(w, center.dy)
      ..arcTo(rect, 0.0, -0.785, false)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Inner cutout to form the 'G'
    final cutoutPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, cutoutPaint);

    // Middle bar for 'G'
    final barRect = Rect.fromLTWH(
      center.dx,
      center.dy - (innerRadius * 0.5),
      radius - 1,
      innerRadius,
    );
    canvas.drawRect(barRect, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Polished, production-ready "Continue with Google" button.
class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    super.key,
    required this.onPressed,
    this.loading = false,
    this.label = 'Continue with Google',
  });

  final VoidCallback? onPressed;
  final bool loading;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceVariant,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GoogleLogo(size: 19),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Sleek divider with centered text.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}

/// Displays Google account picker dialog.
Future<Map<String, String>?> showGoogleAccountChooserDialog(
  BuildContext context,
) {
  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) => const GoogleAccountChooserDialog(),
  );
}

class GoogleAccountChooserDialog extends StatefulWidget {
  const GoogleAccountChooserDialog({super.key});

  @override
  State<GoogleAccountChooserDialog> createState() =>
      _GoogleAccountChooserDialogState();
}

class _GoogleAccountChooserDialogState
    extends State<GoogleAccountChooserDialog> {
  bool _showCustomInput = false;
  final _customEmailCtrl = TextEditingController();
  final _customNameCtrl = TextEditingController();

  @override
  void dispose() {
    _customEmailCtrl.dispose();
    _customNameCtrl.dispose();
    super.dispose();
  }

  void _selectAccount(String email, String name) {
    Navigator.of(context).pop({'email': email, 'name': name});
  }

  void _submitCustomAccount() {
    final email = _customEmailCtrl.text.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) return;
    final name = _customNameCtrl.text.trim().isEmpty
        ? email.split('@').first
        : _customNameCtrl.text.trim();
    Navigator.of(context).pop({'email': email, 'name': name});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GoogleLogo(size: 32),
              const SizedBox(height: 16),
              const Text(
                'Choose an account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'to continue to EmyChat',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Option 1: Demo / Recommended Profile
              _buildAccountTile(
                name: 'EmyChat User',
                email: 'user@emychat.com',
                badgeText: 'Default',
                color: const Color(0xFF4285F4),
                initial: 'E',
                onTap: () => _selectAccount('user@emychat.com', 'EmyChat User'),
              ),
              const Divider(color: AppColors.border, height: 1),

              // Option 2: Personal Google Account
              _buildAccountTile(
                name: 'Personal Account',
                email: 'user@gmail.com',
                color: const Color(0xFF34A853),
                initial: 'G',
                onTap: () => _selectAccount('user@gmail.com', 'Google User'),
              ),
              const Divider(color: AppColors.border, height: 1),

              // Option 3: Custom Google Account
              if (!_showCustomInput)
                InkWell(
                  onTap: () => setState(() => _showCustomInput = true),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            RemixIcons.user_add_line,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Use another Google account',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GOOGLE EMAIL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _customEmailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'alex@gmail.com',
                          prefixIcon: const Icon(
                            RemixIcons.mail_line,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _submitCustomAccount(),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () =>
                                setState(() => _showCustomInput = false),
                            child: const Text('Back'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _submitCustomAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: const Text('Continue'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
              const Text(
                'To continue, Google will share your name, email address, and language preference with EmyChat.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTile({
    required String name,
    required String email,
    required Color color,
    required String initial,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mint.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mint,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              RemixIcons.arrow_right_s_line,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
