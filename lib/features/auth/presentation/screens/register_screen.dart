import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/auth_widget.dart';
import '../../../pricing/controller/pricing_controller.dart';
import '../../../pricing/data/models/pricing_plan_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.planSlug});

  final String? planSlug;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = true;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    // Keeps the password strength meter live.
    _passwordCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.planSlug != null) {
        context.read<PricingController>().selectPlanBySlug(widget.planSlug!);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── LOGIC ─────────────────────────

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double score = 0.0;
    if (password.length >= 8) score += 0.3;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.25;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  String _passwordStrengthLabel(double strength) {
    if (strength <= 0.0) return 'Too short';
    if (strength < 0.5) return 'Weak';
    if (strength < 0.8) return 'Good';
    return 'Strong';
  }

  Color _passwordStrengthColor(double strength) {
    if (strength < 0.5) return AppColors.error;
    if (strength < 0.8) return AppColors.warning;
    return AppColors.success;
  }

  /// Same rules as before, shown inline under each field.
  bool _validate() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passwordCtrl.text;

    setState(() {
      _nameError = name.length < 2
          ? 'Please enter your full name (at least 2 characters)'
          : null;
      _emailError = (!email.contains('@') || !email.contains('.'))
          ? 'Please enter a valid work email address'
          : null;
      _passwordError = pass.length < 8
          ? 'Password must be at least 8 characters'
          : null;
      _confirmError = _confirmPasswordCtrl.text != pass
          ? 'Passwords do not match'
          : null;
    });

    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmError == null;
  }

  Future<void> _handleRegister() async {
    if (!_validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Please accept the Terms of Service & Privacy Policy.'),
        ),
      );
      return;
    }

    final auth = context.read<AuthController>();
    final success = await auth.signUp(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      // Continue directly to Workspace creation flow
      Navigator.of(context).pushReplacementNamed(AppRouter.workspaceOnboarding);
    } else if (auth.isVerifyingEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceVariant,
          content: Text(
            auth.successMessage ?? 'Verification code sent to your email.',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(auth.errorMessage!),
        ),
      );
    }
  }

  Future<void> _handleVerifyEmailOtp() async {
    final auth = context.read<AuthController>();
    final success = await auth.verifyEmailOtp(_otpCtrl.text.trim());

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed(AppRouter.workspaceOnboarding);
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(auth.errorMessage!),
        ),
      );
    }
  }

  Future<void> _handleResendEmailOtp() async {
    final auth = context.read<AuthController>();
    final ok = await auth.resendEmailVerificationOtp();

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceVariant,
          content: Text(
            auth.successMessage ?? 'New verification code sent to your email.',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(auth.errorMessage!),
        ),
      );
    }
  }

  // ───────────────────────── UI HELPERS ─────────────────────────

  Widget _eyeButton(bool hidden, VoidCallback onTap) => IconButton(
    onPressed: onTap,
    splashRadius: 18,
    icon: Icon(
      hidden ? RemixIcons.eye_line : RemixIcons.eye_off_line,
      size: 20,
      color: AppColors.textSecondary,
    ),
  );

  Widget _fieldError(String? message) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 2),
      child: Text(
        message,
        style: const TextStyle(fontSize: 11.5, color: AppColors.error),
      ),
    );
  }

  Widget _strengthBar(double strength) {
    final color = _passwordStrengthColor(strength);
    final filled = strength <= 0 ? 0 : (strength * 4).ceil().clamp(1, 4);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 3.5,
                    margin: EdgeInsets.only(right: i == 3 ? 0 : 5),
                    decoration: BoxDecoration(
                      color: i < filled ? color : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _passwordStrengthLabel(strength),
            style: AppTextStyles.t(11, w: FontWeight.w600, c: color),
          ),
        ],
      ),
    );
  }

  Widget _planCard(PricingPlanModel plan, PricingController pricing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(
            RemixIcons.sparkling_line,
            color: AppColors.accentPrimary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Plan: ${plan.name}',
                  style: AppTextStyles.t(
                    13,
                    w: FontWeight.w700,
                    c: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pricing.isYearly
                      ? '\$${plan.yearlyMonthlyEquivalent}/mo billed annually'
                      : '\$${plan.monthlyPrice}/mo billed monthly',
                  style: AppTextStyles.t(
                    11,
                    w: FontWeight.w400,
                    c: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AuthTextLink(
            label: 'Change',
            onTap: () => Navigator.of(context).pushNamed(AppRouter.pricing),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final pricing = context.watch<PricingController>();
    final selectedPlan =
        pricing.selectedPlan ?? PricingPlanModel.defaultPlans[1];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 820;
              return Center(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: isWide
                          ? IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _RegisterLogoPanel(
                                      footer: _planCard(selectedPlan, pricing),
                                    ),
                                  ),
                                  Expanded(
                                    child: _formPanel(
                                      isWide,
                                      selectedPlan,
                                      pricing,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  height: 170,
                                  child: _RegisterLogoPanel(compact: true),
                                ),
                                _formPanel(isWide, selectedPlan, pricing),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _formPanel(
    bool isWide,
    PricingPlanModel plan,
    PricingController pricing,
  ) {
    final auth = context.watch<AuthController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 24, vertical: 32),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          child: KeyedSubtree(
            key: ValueKey(auth.isVerifyingEmail),
            child: auth.isVerifyingEmail
                ? _buildEmailVerificationView(auth)
                : _buildRegisterContent(auth, isWide, plan, pricing),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterContent(
    AuthController auth,
    bool isWide,
    PricingPlanModel plan,
    PricingController pricing,
  ) {
    final passwordStrength = _calculatePasswordStrength(_passwordCtrl.text);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeader(
          icon: RemixIcons.user_add_line,
          title: 'Create your account',
          subtitle: 'Set up your messaging workspace in seconds.',
        ),
        if (!isWide) ...[const SizedBox(height: 16), _planCard(plan, pricing)],
        const SizedBox(height: 24),

        // Full name
        const AuthFieldLabel('Full Name'),
        AuthTextField(
          controller: _nameCtrl,
          prefixIcon: RemixIcons.user_3_line,
          hint: 'Jane Doe',
          autofillHints: const [AutofillHints.name],
          textInputAction: TextInputAction.next,
        ),
        _fieldError(_nameError),
        const SizedBox(height: 14),

        // Work email
        const AuthFieldLabel('Work Email'),
        AuthTextField(
          controller: _emailCtrl,
          prefixIcon: RemixIcons.mail_line,
          hint: 'jane@company.com',
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
        ),
        _fieldError(_emailError),
        const SizedBox(height: 14),

        // Password
        const AuthFieldLabel('Password'),
        AuthTextField(
          controller: _passwordCtrl,
          prefixIcon: RemixIcons.lock_line,
          hint: 'At least 8 characters',
          obscureText: _obscurePassword,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.next,
          suffix: _eyeButton(
            _obscurePassword,
            () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        if (_passwordCtrl.text.isNotEmpty) _strengthBar(passwordStrength),
        _fieldError(_passwordError),
        const SizedBox(height: 14),

        // Confirm password
        const AuthFieldLabel('Confirm Password'),
        AuthTextField(
          controller: _confirmPasswordCtrl,
          prefixIcon: RemixIcons.lock_password_line,
          hint: 'Re-enter your password',
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleRegister(),
          suffix: _eyeButton(
            _obscureConfirmPassword,
            () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
          ),
        ),
        _fieldError(_confirmError),
        const SizedBox(height: 16),

        // Terms
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => setState(() => _acceptTerms = !_acceptTerms),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _acceptTerms,
                  onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                  activeColor: AppColors.primary,
                  checkColor: AppColors.onPrimary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.t(
                      12,
                      w: FontWeight.w400,
                      c: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: AppTextStyles.t(
                          12,
                          w: FontWeight.w600,
                          c: AppColors.accentPrimary,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTextStyles.t(
                          12,
                          w: FontWeight.w600,
                          c: AppColors.accentPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        AuthButton(
          label: 'Create Account & Continue',
          icon: RemixIcons.arrow_right_line,
          iconAfter: true,
          gradient: AppColors.darkGradient,
          loading: auth.isLoading,
          loadingLabel: 'Creating account...',
          onPressed: _handleRegister,
        ),

        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account?',
              style: AppTextStyles.t(
                13,
                w: FontWeight.w400,
                c: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => Navigator.of(context).pushNamed(AppRouter.login),
              child: Text(
                'Log in',
                style: AppTextStyles.t(
                  13,
                  w: FontWeight.w700,
                  c: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailVerificationView(AuthController auth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeader(
          icon: RemixIcons.mail_check_line,
          title: 'Verify your email',
          subtitle: 'Enter the 4-digit code sent to your inbox.',
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                RemixIcons.information_line,
                size: 18,
                color: AppColors.accentPrimary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Code sent to ${auth.pendingVerificationEmail}',
                  style: AppTextStyles.t(
                    13,
                    w: FontWeight.w500,
                    c: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const AuthFieldLabel('4-Digit Code'),
        AuthTextField(
          controller: _otpCtrl,
          prefixIcon: RemixIcons.shield_line,
          hint: '••••',
          maxLength: 4,
          letterSpacing: 8,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleVerifyEmailOtp(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              auth.canResend
                  ? "Didn't receive code?"
                  : 'Resend in ${auth.timeText}',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            if (auth.canResend)
              AuthTextLink(label: 'Resend Code', onTap: _handleResendEmailOtp),
          ],
        ),
        const SizedBox(height: 18),
        AuthButton(
          label: 'Verify & Activate Account',
          icon: RemixIcons.check_line,
          iconAfter: true,
          gradient: AppColors.darkGradient,
          loading: auth.isLoading,
          loadingLabel: 'Verifying...',
          onPressed: _handleVerifyEmailOtp,
        ),
        const SizedBox(height: 14),
        Center(
          child: AuthTextLink(
            icon: RemixIcons.arrow_left_line,
            label: 'Use a different email',
            onTap: () {
              auth.cancelEmailVerification();
              _otpCtrl.clear();
            },
          ),
        ),
      ],
    );
  }
}

/// Left brand panel, same look as the login screen's panel.
class _RegisterLogoPanel extends StatelessWidget {
  const _RegisterLogoPanel({this.footer, this.compact = false});

  final Widget? footer;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        border: compact
            ? const Border(bottom: BorderSide(color: AppColors.border))
            : const Border(right: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 24 : 36,
        vertical: compact ? 20 : 40,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetConstants.emychatLogo,
              fit: BoxFit.contain,
              width: compact ? 180 : 240,
              errorBuilder: (context, error, stackTrace) {
                return RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    children: [TextSpan(text: 'emychat')],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 3.5,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Text(
                'MESSAGING AUTOMATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (footer != null) ...[
              const SizedBox(height: 36),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: footer!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
