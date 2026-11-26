import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class RegisterFormProvider extends ChangeNotifier {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();
  final TextEditingController otpCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = true;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  RegisterFormProvider() {
    passwordCtrl.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    notifyListeners();
  }

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get acceptTerms => _acceptTerms;

  String? get nameError => _nameError;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmError => _confirmError;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void toggleAcceptTerms() {
    _acceptTerms = !_acceptTerms;
    notifyListeners();
  }

  void setAcceptTerms(bool value) {
    if (_acceptTerms != value) {
      _acceptTerms = value;
      notifyListeners();
    }
  }

  double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double score = 0.0;
    if (password.length >= 8) score += 0.3;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.25;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  String passwordStrengthLabel(double strength) {
    if (strength <= 0.0) return 'Too short';
    if (strength < 0.5) return 'Weak';
    if (strength < 0.8) return 'Good';
    return 'Strong';
  }

  Color passwordStrengthColor(double strength) {
    if (strength < 0.5) return AppColors.error;
    if (strength < 0.8) return AppColors.warning;
    return AppColors.success;
  }

  bool validate() {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final pass = passwordCtrl.text;

    _nameError = name.length < 2
        ? 'Please enter your full name (at least 2 characters)'
        : null;
    _emailError = (!email.contains('@') || !email.contains('.'))
        ? 'Please enter a valid work email address'
        : null;
    _passwordError = pass.length < 8
        ? 'Password must be at least 8 characters'
        : null;
    _confirmError = confirmPasswordCtrl.text != pass
        ? 'Passwords do not match'
        : null;

    notifyListeners();

    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmError == null;
  }

  @override
  void dispose() {
    passwordCtrl.removeListener(_onPasswordChanged);
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    otpCtrl.dispose();
    super.dispose();
  }
}
