import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';

const _codeLength = 6;

/// Six digit boxes drawn over one invisible text field, so paste, backspace,
/// keyboard and SMS autofill all behave like a normal input.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.onCompleted,
    required this.semanticLabel,
    this.errorText,
    this.enabled = true,
  });

  final ValueChanged<String> onCompleted;
  final String semanticLabel;
  final String? errorText;
  final bool enabled;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    _controller.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _lastSubmitted = '';

  // The listener also fires on caret moves, so only submit a new full code.
  void _handleChanged() {
    setState(() {});
    final code = _controller.text;
    if (code.length == _codeLength && code != _lastSubmitted) {
      _lastSubmitted = code;
      widget.onCompleted(code);
    } else if (code.length < _codeLength) {
      _lastSubmitted = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = _controller.text;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Row(
              children: [
                for (var i = 0; i < _codeLength; i++) ...[
                  if (i > 0)
                    SizedBox(width: i == 3 ? AppSpacing.s4 : AppSpacing.s2),
                  Expanded(
                    child: _DigitBox(
                      digit: i < code.length ? code[i] : null,
                      isActive:
                          _focusNode.hasFocus &&
                          (i == code.length ||
                              (i == _codeLength - 1 &&
                                  code.length == _codeLength)),
                      hasError: hasError,
                    ),
                  ),
                ],
              ],
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: true,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(_codeLength),
                  ],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    labelText: widget.semanticLabel,
                  ),
                ),
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: AppMotion.fast,
          curve: AppMotion.standardCurve,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s3),
                  child: Text(
                    widget.errorText!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.statusRisk,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.digit,
    required this.isActive,
    required this.hasError,
  });

  final String? digit;
  final bool isActive;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = hasError
        ? AppColors.statusRisk
        : isActive
        ? AppColors.actionPrimary
        : digit != null
        ? AppColors.borderStrong
        : AppColors.borderSubtle;

    return AnimatedContainer(
      key: const Key('otp-digit-box'),
      duration: AppMotion.fast,
      curve: AppMotion.standardCurve,
      height: AppLayout.touchTarget + AppSpacing.s3,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: digit != null
            ? AppColors.surfaceRaised
            : AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.card - 4),
        border: Border.all(color: borderColor, width: isActive ? 2 : 1),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.actionPrimary.withValues(alpha: 0.12),
                  blurRadius: AppSpacing.s4,
                  offset: const Offset(0, AppSpacing.s1 + 2),
                ),
              ]
            : null,
      ),
      child: Text(
        digit ?? '',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: AppColors.textPrimary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
