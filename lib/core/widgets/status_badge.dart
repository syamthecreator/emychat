import 'package:emychat/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum StatusType {
  active,
  connected,
  open,
  pending,
  warning,
  reconnectRequired,
  error,
  disconnected,
  closed,
  resolved,
  highlight,
  neutral,
}

/// A clean, minimalist status badge inspired by Emey Chat.
/// Uses restrained background opacity (10%), subtle 20% border, and a colored status dot.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.neutral,
    this.showDot = true,
    this.customColor,
    this.isSmall = false,
  });

  final String label;
  final StatusType type;
  final bool showDot;
  final Color? customColor;
  final bool isSmall;

  Color get _color {
    if (customColor != null) return customColor!;
    return switch (type) {
      StatusType.active ||
      StatusType.connected ||
      StatusType.open => AppColors.success,
      StatusType.pending ||
      StatusType.warning ||
      StatusType.reconnectRequired => AppColors.warning,
      StatusType.error => AppColors.error,
      StatusType.highlight => AppColors.arcticBlue,
      StatusType.disconnected ||
      StatusType.closed ||
      StatusType.resolved ||
      StatusType.neutral => AppColors.textMuted,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 7 : 9,
        vertical: isSmall ? 2.5 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: isSmall ? 5 : 6,
              height: isSmall ? 5 : 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: isSmall ? 4 : 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isSmall ? 10.5 : 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
