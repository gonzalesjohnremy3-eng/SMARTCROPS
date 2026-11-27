import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/overlay_hero.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _usePhone = true;
  bool _isOtpSent = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpPhoneController = TextEditingController();
  final _otpCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _farmNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _otpPhoneController.dispose();
    _otpCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = context.read<SmartCropsService>();
      if (_isLogin) {
        await service.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await service.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          _fullNameController.text.trim(),
          _farmNameController.text.trim(),
          _locationController.text.trim(),
          _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
        );
      }
      if (mounted) {
        context.go('/setup/profile');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitPhone() async {
    final l10n = AppLocalizations.of(context);
    final phone = _otpPhoneController.text.trim();
    final code = _otpCodeController.text.trim();
    if (phone.isEmpty || (_isOtpSent && code.isEmpty)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final service = context.read<SmartCropsService>();
      if (!_isOtpSent) {
        await service.signInWithPhoneOtp(phone);
        if (!mounted) return;
        setState(() => _isOtpSent = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.authOtpSent)));
      } else {
        await service.verifyPhoneOtp(phone, code);
        if (mounted) context.go('/setup/profile');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _switchMethod() {
    setState(() {
      _usePhone = !_usePhone;
      _errorMessage = null;
    });
  }

  Future<void> _oauth(OAuthProvider provider, String errorMessage) async {
    try {
      await context.read<SmartCropsService>().signInWithOAuth(provider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final form = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            key: const Key('auth-form-card'),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.eco, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontFamily: 'Fraunces',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.authTagline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(AppRadius.button),
                          border: Border.all(color: theme.colorScheme.error),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (_usePhone) ...[
                      TextField(
                        controller: _otpPhoneController,
                        enabled: !_isOtpSent,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.authOtpMobile,
                          prefixIcon: const Icon(Icons.phone),
                        ),
                      ),
                      if (_isOtpSent) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _otpCodeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.authOtpCode,
                            prefixIcon: const Icon(Icons.lock_clock),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _isLoading ? null : _submitPhone,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: Text(
                          _isOtpSent ? l10n.authVerifyOtp : l10n.authSendOtp,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _switchMethod,
                        child: Text(l10n.authUseEmail),
                      ),
                    ] else ...[
                      if (!_isLogin) ...[
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            labelText: l10n.fullName,
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? l10n.authFullNameRequired
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _farmNameController,
                          decoration: InputDecoration(
                            labelText: l10n.farmName,
                            prefixIcon: const Icon(Icons.agriculture),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? l10n.authFarmNameRequired
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: l10n.location,
                            prefixIcon: const Icon(Icons.location_on),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? l10n.authLocationRequired
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: l10n.authPhoneLabel,
                            prefixIcon: const Icon(Icons.phone),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: l10n.authEmail,
                          prefixIcon: const Icon(Icons.email),
                        ),
                        validator: (value) =>
                            value == null || !value.contains('@')
                            ? l10n.authEmailInvalid
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: l10n.authPassword,
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        validator: (value) => value == null || value.length < 6
                            ? l10n.authPasswordMinLength
                            : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isLogin
                                    ? l10n.authSignIn
                                    : l10n.authCreateAccount,
                              ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => setState(() => _isLogin = !_isLogin),
                        child: Text(
                          _isLogin
                              ? l10n.authSignUpPrompt
                              : l10n.authSignInPrompt,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _switchMethod,
                        child: Text(l10n.authUsePhone),
                      ),
                    ],
                    const Divider(height: 32),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _oauth(OAuthProvider.google, l10n.authGoogleError),
                      icon: const Icon(Icons.g_mobiledata, size: 28),
                      label: Text(l10n.authContinueGoogle),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _oauth(
                        OAuthProvider.facebook,
                        l10n.authFacebookError,
                      ),
                      icon: const Icon(Icons.facebook, size: 24),
                      label: Text(l10n.authContinueFacebook),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < AppLayout.breakpoints['expanded']!) {
              return form;
            }
            return Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    key: const Key('auth-trust-panel'),
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 520,
                          minHeight: 520,
                        ),
                        child: OverlayHero(
                          eyebrow: l10n.authTrustEyebrow,
                          title: l10n.authTrustTitle,
                          body: l10n.authTrustBody,
                          height: 520,
                          imagePath: 'assets/images/overlays/home.webp',
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(flex: 5, child: form),
              ],
            );
          },
        ),
      ),
    );
  }
}
