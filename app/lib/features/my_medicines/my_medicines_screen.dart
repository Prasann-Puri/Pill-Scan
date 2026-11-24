import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../providers.dart';
import '../../widgets/big_button.dart';
import '../find_medicine/find_medicine_screen.dart';
import '../scan/scan_placeholder_screen.dart';
import '../result/result_screen.dart';

/// Screen 5 — My Medicines.
/// Lists confirmed medicines; allows adding more and running the check.
/// "Check my medicines" is hidden when the list is empty — not disabled.
class MyMedicinesScreen extends ConsumerWidget {
  const MyMedicinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicines = ref.watch(medicineListProvider);
    final isEmpty = medicines.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.myMedsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: Strings.back,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add / Scan buttons always visible at top
              BigButton(
                label: Strings.myMedsScan,
                icon: Icons.camera_alt_outlined,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScanPlaceholderScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              BigButton(
                label: Strings.myMedsAdd,
                icon: Icons.add,
                variant: BigButtonVariant.secondary,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FindMedicineScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Medicine list or empty state
              Expanded(
                child: isEmpty
                    ? _buildEmptyState()
                    : _buildMedicineList(context, ref, medicines),
              ),
              // "Check my medicines" only when list is non-empty
              if (!isEmpty) ...[
                const SizedBox(height: 16),
                BigButton(
                  label: Strings.myMedsCheck,
                  icon: Icons.search,
                  onPressed: () => _runCheck(context, ref, medicines
                      .map((m) => m.medicineId)
                      .toList()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        Strings.myMedsEmpty,
        style: AppTheme.bodyStyle,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMedicineList(BuildContext context, WidgetRef ref, medicines) {
    return ListView.separated(
      itemCount: medicines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final med = medicines[i];
        final ingredient = med.hasKnownIngredient
            ? med.ingredientSummary
            : Strings.myMedsNoIngredient;
        return Container(
          constraints: const BoxConstraints(minHeight: kMinTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.brandName,
                        style: AppTheme.bodyStyle
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${Strings.myMedsIngredientPrefix}$ingredient',
                      style: AppTheme.smallStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Remove button
              Semantics(
                label: '${Strings.myMedsRemove} ${med.brandName}',
                button: true,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmRemove(context, ref, med.medicineId,
                      med.brandName),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text(Strings.myMedsRemove),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(80, kMinTapTarget),
                    foregroundColor: AppTheme.redBorder,
                    side: const BorderSide(color: AppTheme.redBorder),
                    textStyle: AppTheme.smallStyle
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    int medicineId,
    String brandName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Strings.myMedsRemoveDialogTitle,
            style: AppTheme.headingStyle),
        content: Text('$brandName\n\n${Strings.myMedsRemoveDialogBody}',
            style: AppTheme.bodyStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(Strings.myMedsRemoveNo),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(Strings.myMedsRemoveYes),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(medicineListProvider.notifier).remove(medicineId);
    }
  }

  Future<void> _runCheck(
    BuildContext context,
    WidgetRef ref,
    List<int> ids,
  ) async {
    // Show loading dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text(Strings.loading)),
            ],
          ),
        ),
      ),
    );

    try {
      final repo = ref.read(repositoryProvider);
      final result = await repo.check(ids);
      if (!context.mounted) return;
      Navigator.pop(context); // dismiss loading
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } catch (_) {
      if (!context.mounted) return;
      Navigator.pop(context); // dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Strings.errorGeneric)),
      );
    }
  }
}
