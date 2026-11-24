import 'package:flutter/material.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../widgets/big_button.dart';
import '../scan/camera_scan_screen.dart';
import '../my_medicines/my_medicines_screen.dart';

/// Screen 1 — Home.
/// ONE primary action: Scan medicine.
/// ONE secondary action: My medicines.
/// Nothing else (README §18 / Phase 3 spec).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App title
              Text(
                Strings.appName,
                style: AppTheme.headingStyle.copyWith(fontSize: 36),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Scan your medicine strips to check for problems.',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Primary CTA — Scan medicine
              BigButton(
                label: Strings.homeScan,
                icon: Icons.camera_alt_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CameraScanScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Secondary — My medicines
              BigButton(
                label: Strings.homeMyMeds,
                icon: Icons.medication_outlined,
                variant: BigButtonVariant.secondary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyMedicinesScreen(),
                    ),
                  );
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
