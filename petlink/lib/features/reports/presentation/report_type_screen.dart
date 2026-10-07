import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final draft = ref.watch(reportDraftProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear reporte'),
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
                'Crear reporte',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: PetSpacing.xs),
              Text(
                '¿Qué ocurrió?',
                style: Theme.of(context).textTheme.bodyMedium,
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
                      title: 'Perdí a mi mascota',
                      subtitle: 'Publica sus datos para que personas cerca puedan ayudarte a encontrarla.',
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
                      title: 'Encontré una mascota',
                      subtitle: 'Comparte dónde la encontraste para ayudarla a volver a casa.',
                      color: PetColors.found,
                      isSelected: draft.reportType == ReportType.found,
                      onTap: () => _selectType(ref, ReportType.found, context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: PetSpacing.lg),
              PetButton(
                label: 'Continuar',
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(PetSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : PetColors.surface,
          borderRadius: PetRadius.xlAll,
          border: Border.all(
            color: isSelected ? color : PetColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(PetSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.15),
                borderRadius: PetRadius.lgAll,
              ),
              child: Icon(
                icon,
                color: isSelected ? PetColors.surface : color,
                size: 28,
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
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : PetColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: PetSpacing.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: PetColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
