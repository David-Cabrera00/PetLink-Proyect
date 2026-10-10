import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../shared/models/pet_report.dart';
import '../../../shared/widgets/step_indicator.dart';
import '../providers/report_draft_provider.dart';

class ReportTypeScreen extends ConsumerWidget {
  const ReportTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(reportDraftProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportCreate),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(reportDraftProvider.notifier).clearDraft();
            context.go('/radar');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepIndicator(current: 1, total: 6),
              const SizedBox(height: PetSpacing.xl),
              Text(
                l10n.reportCreate,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: PetSpacing.xs),
              Text(
                l10n.reportWhatHappened,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: PetSpacing.xl),
              Expanded(
                child: Column(
                  children: [
                    _buildTypeCard(
                      context,
                      ref,
                      type: ReportType.lost,
                      icon: Icons.priority_high,
                      title: l10n.reportLostTitle,
                      subtitle: l10n.reportLostDescription,
                      color: PetColors.lost,
                      isSelected: draft.reportType == ReportType.lost,
                      onTap: () => _selectType(ref, ReportType.lost, context),
                    ),
                    const SizedBox(height: PetSpacing.md),
                    _buildTypeCard(
                      context,
                      ref,
                      type: ReportType.found,
                      icon: Icons.check_circle,
                      title: l10n.reportFoundTitle,
                      subtitle: l10n.reportFoundDescription,
                      color: PetColors.found,
                      isSelected: draft.reportType == ReportType.found,
                      onTap: () => _selectType(ref, ReportType.found, context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PetSpacing.lg),
              PetButton(
                label: l10n.continueAction,
                onPressed: draft.reportType != null
                    ? () => context.go('/report/new/pet-info')
                    : null,
                icon: Icons.arrow_forward,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectType(WidgetRef ref, ReportType type, BuildContext context) {
    ref.read(reportDraftProvider.notifier).setReportType(type);
  }

  Widget _buildTypeCard(
    BuildContext context,
    WidgetRef ref, {
    required ReportType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(PetSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : cs.surface,
          borderRadius: PetRadius.xlAll,
          border: Border.all(
            color: isSelected ? color : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(PetSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.12),
                borderRadius: PetRadius.lgAll,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 26,
              ),
            ),
            const SizedBox(width: PetSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? color : cs.onSurface,
                        ),
                  ),
                  const SizedBox(height: PetSpacing.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : cs.outlineVariant,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
