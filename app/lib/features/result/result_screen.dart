import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../domain/check_result.dart';
import '../../widgets/big_button.dart';
import '../../widgets/disclaimer_bar.dart';
import '../../widgets/status_banner.dart';

/// Screen 6 — Result.
///
/// Layout order (Phase 3 spec):
///   1. StatusBanner (colour + icon + word)
///   2. ONE-sentence summary (large text)
///   3. "Call my doctor / family" (RED only, before "Tell me more")
///   4. "Tell me more" toggle
///   5. [Expanded details when toggled]
///   6. DisclaimerBar pinned to bottom (always, cannot be dismissed)
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});

  final CheckResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final isRed = result.overall == OverallStatus.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.resultTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: Strings.back,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // DisclaimerBar is pinned — use a Column inside body
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Status banner
                  StatusBanner(status: result.overall),
                  const SizedBox(height: 20),

                  // 2. ONE-sentence summary
                  Text(
                    result.summary,
                    style: AppTheme.bodyStyle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // 3. Call button — RED results only, placed before "Tell me more"
                  if (isRed) ...[
                    BigButton(
                      label: Strings.resultCallButton,
                      icon: Icons.phone_outlined,
                      onPressed: () => _showCallDialog(context),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 4. Tell me more toggle
                  OutlinedButton.icon(
                    icon: Icon(
                      _showDetails
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                    label: Text(
                      _showDetails
                          ? Strings.resultHideDetails
                          : Strings.resultTellMore,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 64),
                      textStyle: AppTheme.buttonStyle,
                    ),
                    onPressed: () =>
                        setState(() => _showDetails = !_showDetails),
                  ),

                  // 5. Expanded details
                  if (_showDetails) ...[
                    const SizedBox(height: 20),
                    _buildDetails(result),
                  ],

                  const SizedBox(height: 20),
                  // Done button
                  BigButton(
                    label: Strings.resultDone,
                    icon: Icons.check,
                    variant: BigButtonVariant.secondary,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // 6. Persistent disclaimer bar — always visible, cannot be dismissed
          const DisclaimerBar(),
        ],
      ),
    );
  }

  Widget _buildDetails(CheckResult result) {
    final children = <Widget>[];

    // Interactions
    for (final interaction in result.interactions) {
      children.add(_DetailCard(
        heading: Strings.resultInteractionHeading,
        headingColor: AppTheme.redBorder,
        lines: [
          '${interaction.saltA} + ${interaction.saltB}',
          interaction.description,
          '${Strings.resultSourceLabel}${interaction.source}',
          if (interaction.sourceDate != null)
            '${Strings.resultDataLabel}${interaction.sourceDate}',
        ],
      ));
    }

    // Duplicates
    for (final dup in result.duplicates) {
      children.add(_DetailCard(
        heading: Strings.resultDuplicateHeading,
        headingColor: AppTheme.yellowBorder,
        lines: [dup.message],
      ));
    }

    // Unchecked
    for (final u in result.unchecked) {
      children.add(_DetailCard(
        heading: Strings.resultUncheckedHeading,
        headingColor: AppTheme.greyBorder,
        lines: [
          'Medicine ID ${u.medicineId}: ${u.reason}',
        ],
      ));
    }

    // Data version
    if (result.dataVersion.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          '${Strings.resultDataLabel}${result.dataVersion}',
          style: AppTheme.smallStyle,
          textAlign: TextAlign.center,
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  void _showCallDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Strings.resultCallDialogTitle,
            style: AppTheme.headingStyle),
        content:
            const Text(Strings.resultCallDialogBody, style: AppTheme.bodyStyle),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(Strings.resultCallDialogOk),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.heading,
    required this.headingColor,
    required this.lines,
  });

  final String heading;
  final Color headingColor;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: headingColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 8),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(line, style: AppTheme.bodyStyle),
            ),
          ),
        ],
      ),
    );
  }
}
