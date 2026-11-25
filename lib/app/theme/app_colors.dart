import 'package:flutter/material.dart';

/// EmyChat Design System — Ultra Premium Midnight Sapphire Palette
/// Sophisticated Midnight Navy, Deep Sapphire, Arctic Blue, Silver & Crisp White
abstract final class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // 1. MIDNIGHT SAPPHIRE DARK THEME TOKENS (PRIMARY CANVAS)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color midnightNavy = Color(0xFF060B14); // Deepest abyss canvas
  static const Color deepNavy = Color(0xFF080F1D);     // Main background
  static const Color darkBackground = Color(0xFF080F1D);
  static const Color darkSidebar = Color(0xFF060B14);
  static const Color darkCard = Color(0xFF0E1A30);     // Deep Sapphire card surface
  static const Color darkCardMuted = Color(0xFF142442);// Elevated card / hover
  static const Color darkBorder = Color(0xFF1E335A);   // Subtle sapphire border
  static const Color darkBorderSubtle = Color(0xFF16274A);
  static const Color darkDivider = Color(0xFF172847);
  static const Color darkInput = Color(0xFF0B1528);
  static const Color darkInputBorder = Color(0xFF223A63);

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. ARCTIC SILVER LIGHT THEME TOKENS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color lightBackground = Color(0xFFF8FAFC); // Crisp soft silver ice
  static const Color lightSidebar = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardMuted = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderSubtle = Color(0xFFEDF2F7);
  static const Color lightInput = Color(0xFFFFFFFF);
  static const Color lightInputBorder = Color(0xFFCBD5E1);

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. BRAND ACCENTS (ARCTIC BLUE & SAPPHIRE)
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color arcticBlue = Color(0xFF38BDF8);      // Electric Arctic Blue
  static const Color arcticBlueLight = Color(0xFF7DD3FC);
  static const Color sapphireBlue = Color(0xFF2563EB);    // Vibrant Sapphire
  static const Color deepSapphire = Color(0xFF0E1A30);
  static const Color royalSapphire = Color(0xFF1D4ED8);
  static const Color silver = Color(0xFF94A3B8);
  static const Color crispWhite = Color(0xFFFFFFFF);

  // Default Semantic Bindings (Dark-default application)
  static const Color primary = Color(0xFF38BDF8);         // Arctic Blue accent
  static const Color onPrimary = Color(0xFF060B14);
  static const Color secondary = Color(0xFF1E335A);
  static const Color onSecondary = Color(0xFFF8FAFC);
  static const Color accent = Color(0xFF38BDF8);
  static const Color accentPrimary = Color(0xFF38BDF8);
  static const Color accentLime = Color(0xFF38BDF8);      // Alias for Arctic Blue
  static const Color accentMint = Color(0xFF38BDF8);      // Alias for Arctic Blue
  static const Color mint = Color(0xFF38BDF8);

  static const Color background = darkBackground;
  static const Color surface = darkCard;
  static const Color surfaceVariant = darkCardMuted;
  static const Color surfaceMuted = darkCardMuted;
  static const Color card = darkCard;
  static const Color cardMuted = darkCardMuted;
  static const Color dialog = darkCard;
  static const Color navBar = darkSidebar;
  static const Color sidebar = darkSidebar;
  static const Color sidebarBorder = darkBorder;

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. TYPOGRAPHY COLORS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFFF8FAFC);      // Crisp White-Silver
  static const Color textSecondary = Color(0xFF94A3B8);    // Silver Slate
  static const Color textMuted = Color(0xFF64748B);        // Deep Silver
  static const Color lightTextPrimary = Color(0xFF0F172A); // Midnight Navy text
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. BORDERS & INPUTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color border = darkBorder;
  static const Color borderSubtle = darkBorderSubtle;
  static const Color borderGlow = Color(0xFF38BDF8);
  static const Color divider = darkDivider;

  static const Color input = darkInput;
  static const Color inputFill = darkInput;
  static const Color inputBorder = darkInputBorder;
  static const Color inputFocused = Color(0xFF38BDF8);

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. FUNCTIONAL & CHANNEL ACCENTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Colors.white;
  static const Color success = Color(0xFF10B981);
  static const Color onSuccess = Color(0xFF060B14);
  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Colors.black;
  static const Color info = Color(0xFF38BDF8);

  static const Color waColor = Color(0xFF25D366);
  static const Color whatsapp = Color(0xFF25D366);

  // ═══════════════════════════════════════════════════════════════════════════
  // 7. ULTRA PREMIUM MIDNIGHT SAPPHIRE GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Midnight Sapphire Hero Gradient
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF060B14),
      Color(0xFF0B172E),
      Color(0xFF0E1F3D),
    ],
  );

  /// Controlled Sapphire-to-Arctic-Blue CTA Gradient
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF0EA5E9),
    ],
  );

  /// Soft Silver-Blue Light Gradient
  static const LinearGradient softSilverBlueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8FAFC),
      Color(0xFFEDF4FC),
      Color(0xFFE2EDFB),
    ],
  );

  /// Deep Ocean Dark Feature Gradient
  static const LinearGradient deepOceanGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF070D18),
      Color(0xFF0C1931),
    ],
  );

  /// Subtle Radial Sapphire Illumination
  static RadialGradient sapphireRadialGlow({
    Alignment center = Alignment.topCenter,
    double radius = 1.0,
    double opacity = 0.22,
  }) {
    return RadialGradient(
      center: center,
      radius: radius,
      colors: [
        const Color(0xFF1D4ED8).withValues(alpha: opacity),
        const Color(0xFF0EA5E9).withValues(alpha: opacity * 0.4),
        Colors.transparent,
      ],
      stops: const [0.0, 0.55, 1.0],
    );
  }

  // Gradient aliases
  static const LinearGradient darkGradient = ctaGradient;
  static const LinearGradient primaryGradient = ctaGradient;
  static const LinearGradient sapphireGradient = ctaGradient;
  static const LinearGradient neonLaserGradient = ctaGradient;

  /// Dynamic status color mapping
  static Color statusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'active':
      case 'live':
      case 'running':
      case 'connected':
      case 'open':
        return success;
      case 'paused':
      case 'draft':
      case 'pending':
      case 'warning':
      case 'reconnect':
        return warning;
      case 'error':
      case 'failed':
      case 'disabled':
      case 'disconnected':
        return error;
      default:
        return textMuted;
    }
  }

  // Backward-compatibility palette aliases
  static const Color paletteMidnightAbyss = midnightNavy;
  static const Color paletteNeonCyan = arcticBlue;
  static const Color paletteHydroSlate = darkCard;
  static const Color paletteSpecularIce = silver;
  static const Color paletteCyberNavy = darkCardMuted;
  static const Color paletteLaserGlow = arcticBlue;
  static const Color paletteObsidian = midnightNavy;
  static const Color paletteCobalt = sapphireBlue;
  static const Color paletteCharcoal = darkCard;
  static const Color paletteSteel = silver;
  static const Color paletteOrange = warning;
  static const Color paletteSatinViolet = sapphireBlue;
  static const Color paletteSlateViolet = darkCardMuted;
  static const Color paletteLuminousLilac = silver;
  static const Color paletteMineralStone = darkCardMuted;
  static const Color paletteDeepPlum = darkCard;
}
