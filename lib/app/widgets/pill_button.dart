import 'package:flutter/material.dart';
import 'package:smart_crops/app/theme/app_tokens.dart';

/// The primary action of a screen (ADR 0017): a full-width pill with its
/// trailing arrow nested in its own circle.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(
          AppLayout.touchTarget + AppSpacing.s2,
        ),
        backgroundColor: AppColors.actionPrimary,
        foregroundColor: AppColors.textInverse,
        disabledBackgroundColor: AppColors.actionPrimary.withValues(alpha: 0.6),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.only(
          left: AppSpacing.s6,
          right: AppSpacing.s2,
        ),
        elevation: 0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.textInverse),
            ),
          ),
          Container(
            width: AppSpacing.s10,
            height: AppSpacing.s10,
            decoration: BoxDecoration(
              color: AppColors.textInverse.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.s3 - 1),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textInverse,
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.textInverse,
                    size: AppSpacing.s5,
                  ),
          ),
        ],
      ),
    );
  }
}
