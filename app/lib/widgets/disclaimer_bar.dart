import 'package:flutter/material.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../core/constants.dart';

/// Persistent disclaimer bar shown at the bottom of every Result screen.
/// Cannot be dismissed (README §5 rule 8).
class DisclaimerBar extends StatelessWidget {
  const DisclaimerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: Strings.disclaimer,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFFFF9C4),
          border: Border(
            top: BorderSide(color: Color(0xFFCDC200), width: 2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 22, color: Color(0xFF5F4A00)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                Strings.disclaimer,
                style: const TextStyle(
                  fontSize: kSmallTextSp,
                  color: Color(0xFF3D3000),
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
