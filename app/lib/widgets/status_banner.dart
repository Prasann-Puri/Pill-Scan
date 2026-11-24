import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../domain/check_result.dart';

/// Coloured banner that shows the result status.
/// Always shows colour + icon + word — never colour alone (README §18).
/// Targets WCAG AAA 7:1 contrast with dark text on light tinted background.
class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.status});

  final OverallStatus status;

  @override
  Widget build(BuildContext context) {
    final config = _configFor(status);
    return Semantics(
      label: config.semanticsLabel,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: config.fill,
          border: Border.all(color: config.border, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(config.icon, size: 36, color: config.textColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                config.word,
                style: TextStyle(
                  fontSize: kHeadingTextSp,
                  fontWeight: FontWeight.bold,
                  color: config.textColor,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static _BannerConfig _configFor(OverallStatus status) {
    switch (status) {
      case OverallStatus.green:
        return _BannerConfig(
          fill: AppTheme.greenFill,
          border: AppTheme.greenBorder,
          textColor: AppTheme.greenText,
          icon: Icons.check_circle_outline,
          word: Strings.statusGreen,
          semanticsLabel: 'Status: ${Strings.statusGreen}',
        );
      case OverallStatus.yellow:
        return _BannerConfig(
          fill: AppTheme.yellowFill,
          border: AppTheme.yellowBorder,
          textColor: AppTheme.yellowText,
          icon: Icons.warning_amber_outlined,
          word: Strings.statusYellow,
          semanticsLabel: 'Status: ${Strings.statusYellow}',
        );
      case OverallStatus.red:
        return _BannerConfig(
          fill: AppTheme.redFill,
          border: AppTheme.redBorder,
          textColor: AppTheme.redText,
          icon: Icons.block_outlined,
          word: Strings.statusRed,
          semanticsLabel: 'Status: ${Strings.statusRed}',
        );
      case OverallStatus.grey:
        return _BannerConfig(
          fill: AppTheme.greyFill,
          border: AppTheme.greyBorder,
          textColor: AppTheme.greyText,
          icon: Icons.help_outline,
          word: Strings.statusGrey,
          semanticsLabel: 'Status: ${Strings.statusGrey}',
        );
    }
  }
}

class _BannerConfig {
  const _BannerConfig({
    required this.fill,
    required this.border,
    required this.textColor,
    required this.icon,
    required this.word,
    required this.semanticsLabel,
  });

  final Color fill;
  final Color border;
  final Color textColor;
  final IconData icon;
  final String word;
  final String semanticsLabel;
}
