import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';
import 'package:smart_crops/app/widgets/app_logo.dart';
import 'package:smart_crops/app/widgets/pill_button.dart';
import 'package:smart_crops/app/widgets/reticle_frame.dart';
import 'package:smart_crops/app/widgets/scrimmed_image.dart';
import 'package:smart_crops/features/auth/domain/auth_failure.dart';
import 'package:smart_crops/features/auth/domain/philippine_mobile.dart';
import 'package:smart_crops/features/auth/widgets/otp_code_field.dart';
import 'package:smart_crops/l10n/app_localizations.dart';
import 'package:smart_crops/services/smart_crops_service.dart';

const _heroImage = 'assets/images/overlays/onboarding.webp';
const _resendWait = 60;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _usePhone = true;
  bool _isLogin = true;
  bool _isLoading = false;

  // Phone sign-in: null until a code has been sent to this E.164 number.
  String? _sentTo;
  String? _phoneError;
  String? _codeError;
  int _resendSeconds = 0;
  Timer? _resendTimer;
  int _codeAttempt = 0;

  final _formKey = GlobalKey<FormState>();
  final _phoneInputController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneInputController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _farmNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final l10n = AppLocalizations.of(context);
    final phone =
        _sentTo ?? normalizePhilippineMobile(_phoneInputController.text);
    if (phone == null) {
      setState(() => _phoneError = l10n.authPhoneInvalid);
      return;
    }
    setState(() {
      _isLoading = true;
      _phoneError = null;
      _codeError = null;
    });
    try {
      await context.read<SmartCropsService>().signInWithPhoneOtp(phone);
      if (!mounted) return;
      setState(() {
        _sentTo = phone;
        _codeAttempt++;
      });
      _startResendCountdown();
    } catch (error) {
      if (!mounted) return;
      final message = _describe(AuthFailure.from(error), l10n);
      setState(
        () => _sentTo == null ? _phoneError = message : _codeError = message,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode(String code) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _codeError = null;
    });
    try {
      await context.read<SmartCropsService>().verifyPhoneOtp(_sentTo!, code);
      if (mounted) context.go('/setup/profile');
    } catch (error) {
      if (mounted) {
        setState(() => _codeError = _describe(AuthFailure.from(error), l10n));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = _resendWait);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _resendSeconds--);
      if (_resendSeconds == 0) timer.cancel();
    });
  }

  void _changeNumber() {
    _resendTimer?.cancel();
    setState(() {
      _sentTo = null;
      _codeError = null;
      _resendSeconds = 0;
    });
  }

  String _describe(AuthFailure failure, AppLocalizations l10n) {
    return switch (failure.kind) {
      AuthFailureKind.badCode => l10n.authErrorBadCode,
      AuthFailureKind.tooManyAttempts =>
        failure.waitSeconds == null
            ? l10n.authErrorTooMany
            : l10n.authErrorTooManyWait(failure.waitSeconds!),
      AuthFailureKind.unreachableNumber => l10n.authErrorUnreachable,
      AuthFailureKind.noConnection => l10n.authErrorOffline,
      AuthFailureKind.unknown => l10n.authErrorGeneric,
    };
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _emailError = null;
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
      if (mounted) context.go('/setup/profile');
    } on AuthException catch (error) {
      // Supabase wording for wrong credentials is already plain English.
      if (mounted) setState(() => _emailError = error.message);
    } catch (error) {
      if (mounted) {
        setState(() => _emailError = _describe(AuthFailure.from(error), l10n));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
    final form = _buildForm(context, l10n);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < AppLayout.breakpoints['expanded']!) {
            return _CompactLayout(form: form);
          }
          return Row(
            children: [
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s4),
                  child: ClipRRect(
                    key: const Key('auth-trust-panel'),
                    borderRadius: BorderRadius.circular(AppRadius.hero),
                    child: ScrimmedImage(
                      imagePath: _heroImage,
                      scrim: AppColors.overlayScrim,
                      child: _HeroContent(
                        padding: const EdgeInsets.all(AppSpacing.s12),
                        trustTitle: l10n.authTrustTitle,
                        trustBody: l10n.authTrustBody,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12,
                        vertical: AppSpacing.s8,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: form,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, AppLocalizations l10n) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final Widget step;
    if (!_usePhone) {
      step = _buildEmailStep(context, l10n);
    } else if (_sentTo == null) {
      step = _buildPhoneStep(context, l10n);
    } else {
      step = _buildCodeStep(context, l10n);
    }

    return Theme(
      data: _fieldTheme(Theme.of(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: reduceMotion ? Duration.zero : AppMotion.standard,
            switchInCurve: AppMotion.emphasizedCurve,
            switchOutCurve: AppMotion.exitCurve,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0.08, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: KeyedSubtree(
              key: ValueKey('${_usePhone}_${_sentTo != null}'),
              child: step,
            ),
          ),
          if (_sentTo == null) ...[
            const SizedBox(height: AppSpacing.s8),
            _buildOtherWays(context, l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildPhoneStep(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.authOtpTitle, style: _titleStyle(theme)),
        const SizedBox(height: AppSpacing.s2),
        Text(
          l10n.authPhoneHelper,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        TextField(
          key: const Key('auth-phone-field'),
          controller: _phoneInputController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.telephoneNumberNational],
          inputFormatters: [PhilippineMobileInputFormatter()],
          onSubmitted: (_) => _sendCode(),
          onChanged: (_) {
            if (_phoneError != null) setState(() => _phoneError = null);
          },
          style: theme.textTheme.titleLarge?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
            letterSpacing: 0.5,
          ),
          decoration: InputDecoration(
            labelText: l10n.authOtpMobile,
            hintText: '0917 123 4567',
            errorText: _phoneError,
            errorMaxLines: 3,
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        PillButton(
          label: l10n.authSendOtp,
          isLoading: _isLoading,
          onPressed: _sendCode,
        ),
      ],
    );
  }

  Widget _buildCodeStep(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: _changeNumber,
            tooltip: l10n.authBack,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceSunken,
              foregroundColor: AppColors.textPrimary,
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(l10n.authOtpCode, style: _titleStyle(theme)),
        const SizedBox(height: AppSpacing.s2),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.s1,
          children: [
            Text(
              l10n.authCodeSentTo(maskPhilippineMobile(_sentTo!)),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            TextButton(
              onPressed: _changeNumber,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2),
                foregroundColor: AppColors.canopy,
              ),
              child: Text(l10n.authChangeNumber),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s6),
        KeyedSubtree(
          key: const Key('auth-otp-field'),
          // A fresh field per sent code clears the boxes after a resend.
          child: OtpCodeField(
            key: ValueKey(_codeAttempt),
            semanticLabel: l10n.authOtpCode,
            enabled: !_isLoading,
            errorText: _codeError,
            onCompleted: _verifyCode,
          ),
        ),
        const SizedBox(height: AppSpacing.s6),
        SizedBox(
          height: AppLayout.touchTarget,
          child: Center(
            child: _isLoading
                ? const SizedBox.square(
                    dimension: AppSpacing.s6,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.canopy,
                    ),
                  )
                : TextButton(
                    onPressed: _resendSeconds > 0 ? null : _sendCode,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.canopy,
                    ),
                    child: Text(
                      _resendSeconds > 0
                          ? l10n.authResendIn(_resendSeconds)
                          : l10n.authResendCode,
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailStep(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isLogin ? l10n.authSignIn : l10n.authCreateAccount,
            style: _titleStyle(theme),
          ),
          const SizedBox(height: AppSpacing.s6),
          if (!_isLogin) ...[
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: l10n.fullName),
              validator: (value) => value == null || value.isEmpty
                  ? l10n.authFullNameRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.s3),
            TextFormField(
              controller: _farmNameController,
              decoration: InputDecoration(labelText: l10n.farmName),
              validator: (value) => value == null || value.isEmpty
                  ? l10n.authFarmNameRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.s3),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(labelText: l10n.location),
              validator: (value) => value == null || value.isEmpty
                  ? l10n.authLocationRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.s3),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.authPhoneLabel),
            ),
            const SizedBox(height: AppSpacing.s3),
          ],
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(labelText: l10n.authEmail),
            validator: (value) => value == null || !value.contains('@')
                ? l10n.authEmailInvalid
                : null,
          ),
          const SizedBox(height: AppSpacing.s3),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(labelText: l10n.authPassword),
            validator: (value) => value == null || value.length < 6
                ? l10n.authPasswordMinLength
                : null,
          ),
          if (_emailError != null) ...[
            const SizedBox(height: AppSpacing.s3),
            Text(
              _emailError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.statusRisk,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s6),
          PillButton(
            label: _isLogin ? l10n.authSignIn : l10n.authCreateAccount,
            isLoading: _isLoading,
            onPressed: _submitEmail,
          ),
          const SizedBox(height: AppSpacing.s2),
          TextButton(
            onPressed: () => setState(() => _isLogin = !_isLogin),
            style: TextButton.styleFrom(foregroundColor: AppColors.canopy),
            child: Text(
              _isLogin ? l10n.authSignUpPrompt : l10n.authSignInPrompt,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherWays(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.borderSubtle)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
              child: Text(
                l10n.authOtherWays,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.borderSubtle)),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ProviderButton(
              tooltip: l10n.authContinueGoogle,
              asset: 'assets/images/brand/google.svg',
              onPressed: () =>
                  _oauth(OAuthProvider.google, l10n.authGoogleError),
            ),
            const SizedBox(width: AppSpacing.s4),
            _ProviderButton(
              tooltip: l10n.authContinueFacebook,
              asset: 'assets/images/brand/facebook.svg',
              onPressed: () =>
                  _oauth(OAuthProvider.facebook, l10n.authFacebookError),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s2),
        TextButton(
          onPressed: () => setState(() {
            _usePhone = !_usePhone;
            _phoneError = null;
            _emailError = null;
          }),
          style: TextButton.styleFrom(foregroundColor: AppColors.canopy),
          child: Text(_usePhone ? l10n.authUseEmail : l10n.authUsePhone),
        ),
      ],
    );
  }

  TextStyle? _titleStyle(ThemeData theme) => theme.textTheme.headlineMedium
      ?.copyWith(color: AppColors.textPrimary, height: 1.15);

  ThemeData _fieldTheme(ThemeData theme) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card - 4),
          borderSide: BorderSide(color: color, width: width),
        );
    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceSunken,
        floatingLabelStyle: const TextStyle(color: AppColors.canopy),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s4,
          vertical: AppSpacing.s4 + 2,
        ),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(AppColors.actionPrimary, 2),
        errorBorder: border(AppColors.statusRisk),
        focusedErrorBorder: border(AppColors.statusRisk, 2),
        errorStyle: const TextStyle(color: AppColors.statusRisk),
      ),
    );
  }
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grows past the minimum for long translations and large text.
          IntrinsicHeight(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (height * 0.44).clamp(320.0, 420.0),
              ),
              child: ScrimmedImage(
                imagePath: _heroImage,
                scrim: AppColors.overlayScrim,
                child: SafeArea(
                  bottom: false,
                  child: _HeroContent(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s6,
                      AppSpacing.s4,
                      AppSpacing.s6,
                      AppSpacing.s10,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // The sheet rises over the photo's lower edge.
          Transform.translate(
            offset: const Offset(0, -AppSpacing.s6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.hero),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.forestInk.withValues(alpha: 0.18),
                    blurRadius: AppSpacing.s8,
                    offset: const Offset(0, -AppSpacing.s2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s6,
                  AppSpacing.s8,
                  AppSpacing.s6,
                  AppSpacing.s6,
                ),
                child: SafeArea(top: false, child: form),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo lockup, promise and (on wide screens) the trust copy over the photo.
class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.padding, this.trustTitle, this.trustBody});

  final EdgeInsets padding;
  final String? trustTitle;
  final String? trustBody;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final inverse = AppColors.textInverse;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppLogo(size: 44),
              const SizedBox(width: AppSpacing.s3),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.authBrandName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: 'Fraunces',
                      color: inverse,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    l10n.authBrandByline,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: inverse.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.s8),
          ReticleFrame(
            child: Text(
              l10n.authTagline,
              style: theme.textTheme.displayLarge?.copyWith(
                color: inverse,
                height: 1.05,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            l10n.authPromiseBody,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: inverse.withValues(alpha: 0.85),
            ),
          ),
          if (trustTitle != null) ...[
            const SizedBox(height: AppSpacing.s10),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s4),
              decoration: BoxDecoration(
                color: AppColors.forestInk.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: inverse.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline_rounded, color: AppColors.leaf),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trustTitle!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: inverse,
                          ),
                        ),
                        Text(
                          trustBody!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: inverse.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.tooltip,
    required this.asset,
    required this.onPressed,
  });

  final String tooltip;
  final String asset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size.square(AppLayout.touchTarget + AppSpacing.s2),
        backgroundColor: AppColors.surfaceRaised,
        side: const BorderSide(color: AppColors.borderSubtle),
        shadowColor: AppColors.forestInk.withValues(alpha: 0.08),
        elevation: 2,
      ),
      icon: SvgPicture.asset(asset, width: 22, height: 22),
    );
  }
}
