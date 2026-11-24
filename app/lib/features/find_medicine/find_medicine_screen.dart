import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/strings.dart';
import '../../core/theme.dart';
import '../../domain/medicine_search_result.dart';
import '../../providers.dart';
import '../../widgets/big_button.dart';
import '../confirm/confirm_screen.dart';

/// Screen 3 — Find / Add medicine.
/// Large text field → results list → tap to go to Confirm.
/// Never adds a medicine directly — only Confirm screen does that (Phase 3 spec).
class FindMedicineScreen extends ConsumerStatefulWidget {
  const FindMedicineScreen({super.key});

  @override
  ConsumerState<FindMedicineScreen> createState() => _FindMedicineScreenState();
}

class _FindMedicineScreenState extends ConsumerState<FindMedicineScreen> {
  final _controller = TextEditingController();
  List<MedicineSearchResult>? _results;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _results = null;
    });
    try {
      final repo = ref.read(repositoryProvider);
      final results = await repo.search(q);
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _error = Strings.errorGeneric);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.findTitle),
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
              // Search field
              TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: Strings.findHint,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, size: 28),
                    tooltip: 'Search',
                    onPressed: _search,
                  ),
                ),
                style: AppTheme.bodyStyle,
              ),
              const SizedBox(height: 20),
              BigButton(
                label: 'Search',
                icon: Icons.search,
                onPressed: _search,
              ),
              const SizedBox(height: 24),
              // Results area
              Expanded(child: _buildResults()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: AppTheme.bodyStyle,
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_results == null) {
      return const SizedBox.shrink();
    }
    if (_results!.isEmpty) {
      return Center(
        child: Text(
          Strings.findNoResults,
          style: AppTheme.bodyStyle,
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Strings.findResultsHelp, style: AppTheme.smallStyle),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: _results!.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final med = _results![i];
              return _MedicineTile(medicine: med);
            },
          ),
        ),
      ],
    );
  }
}

class _MedicineTile extends StatelessWidget {
  const _MedicineTile({required this.medicine});
  final MedicineSearchResult medicine;

  @override
  Widget build(BuildContext context) {
    final ingredientText = medicine.hasKnownIngredient
        ? medicine.salts
            .map((s) =>
                s.strengthText != null ? '${s.name} ${s.strengthText}' : s.name)
            .join(', ')
        : Strings.myMedsNoIngredient;

    return Semantics(
      button: true,
      label: '${medicine.brandName}, $ingredientText. Tap to review.',
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConfirmScreen(medicine: medicine),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: kMinTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(medicine.brandName, style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                '${Strings.myMedsIngredientPrefix}$ingredientText',
                style: AppTheme.smallStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
