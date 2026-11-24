import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

/// A large, labelled button — the primary interactive element in PillSafe.
///
/// Every instance is at least [kMinTapTarget] dp tall.
/// Every icon has a text label (README §18).
///
/// [variant] controls fill (primary) vs outline (secondary).
enum BigButtonVariant { primary, secondary }

class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = BigButtonVariant.primary,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final BigButtonVariant variant;

  /// Override for screen-reader label when the visible text is not enough.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final child = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label,
                  style: AppTheme.buttonStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        : Text(label, style: AppTheme.buttonStyle, textAlign: TextAlign.center);

    final button = switch (variant) {
      BigButtonVariant.primary => ElevatedButton(
          onPressed: onPressed,
          child: child,
        ),
      BigButtonVariant.secondary => OutlinedButton(
          onPressed: onPressed,
          child: child,
        ),
    };

    return Semantics(
      label: semanticsLabel ?? label,
      button: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinTapTarget),
        child: button,
      ),
    );
  }
}
