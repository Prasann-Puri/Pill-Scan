import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../domain/medicine_search_result.dart';
import '../../domain/my_medicine.dart';
import '../../providers.dart';
import '../../widgets/big_button.dart';
import '../my_medicines/my_medicines_screen.dart';

/// Screen 4 — Confirm.
/// Shows the scanned/found medicine for the user to verify.
/// A medicine is ONLY added after the user taps "Yes, add it".
/// (README §5 rule 3 / Phase 3 spec rule 2).
class ConfirmScreen extends ConsumerWidget {
  const ConfirmScreen({super.key, required this.medicine});

  final MedicineSearchResult medicine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasIngredient = medicine.hasKnownIngredient;
    final ingredientText = hasIngredient
        ? medicine.salts
            .map((s) =>
                s.strengthText != null ? '${s.name} ${s.strengthText}' : s.name)
            .join(', ')
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.confirmTitle),
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
              // Question label
              Text(
                Strings.confirmQuestion,
                style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              // Medicine name — large
              Text(medicine.brandName, style: AppTheme.headingStyle),
              const SizedBox(height: 20),
              // Ingredient section
              Text(
                Strings.confirmIngredientLabel,
                style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 6),
              if (hasIngredient) ...[
                Text(ingredientText!, style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.greyFill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.greyBorder),
                  ),
                  child: Text(
                    Strings.confirmNoIngredient,
                    style: AppTheme.bodyStyle,
                  ),
                ),
              ],
              const Spacer(),
              // YES button — adds medicine
              BigButton(
                label: Strings.confirmYes,
                icon: Icons.check,
                onPressed: () => _onConfirm(context, ref),
              ),
              const SizedBox(height: 16),
              // NO button — search again
              BigButton(
                label: Strings.confirmNo,
                icon: Icons.search,
                variant: BigButtonVariant.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onConfirm(BuildContext context, WidgetRef ref) {
    final myMedicine = MyMedicine(
      medicineId: medicine.medicineId,
      brandName: medicine.brandName,
      salts: medicine.salts,
      confirmedAt: DateTime.now(),
    );
    ref.read(medicineListProvider.notifier).add(myMedicine);

    // Pop back to Home, then push My Medicines so the stack is clean (ADR-005).
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MyMedicinesScreen()),
    );
  }
}
