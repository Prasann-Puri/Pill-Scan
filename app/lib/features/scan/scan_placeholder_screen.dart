import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../widgets/big_button.dart';
import '../find_medicine/find_medicine_screen.dart';

/// Screen 2 — Scan placeholder.
/// Camera scanning is a later phase. This screen explains that
/// and offers the "Type the name instead" path.
class ScanPlaceholderScreen extends StatelessWidget {
  const ScanPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.scanTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: Strings.back,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Camera placeholder icon
              const Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: 24),
              Text(
                Strings.scanComingSoon,
                style: AppTheme.bodyStyle,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              BigButton(
                label: Strings.scanTypeInstead,
                icon: Icons.keyboard_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FindMedicineScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
