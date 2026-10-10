import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../design_system/badges/status_badge.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../shared/models/pet_report.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../providers/reports_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final reportsAsync = ref.watch(myReportsProvider);
    final filter = ref.watch(reportsFilterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(PetSpacing.lg),
            child: _buildFilters(context, ref, filter),
          ),
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                if (reports.isEmpty) {
                  return _buildEmptyState(context, filter);
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PetSpacing.lg,
                  ),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: PetSpacing.md),
                      child: _buildReportCard(context, reports[index]),
                    );
                  },
                );
              },
              loading: () => _buildLoadingState(),
              error: (Object _, StackTrace _) => ErrorState(
                title: l10n.reportsLoadError,
                subtitle: l10n.reportsConnectionError,
                onRetry: () => ref.invalidate(myReportsProvider),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(PetSpacing.lg),
            child: PetButton(
              label: l10n.reportCreate,
              onPressed: () => context.go('/report/new'),
              icon: Icons.add,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    WidgetRef ref,
    ReportsFilter currentFilter,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: PetSpacing.sm,
      runSpacing: PetSpacing.sm,
      children: [
        _buildFilterButton(
          context,
          ref,
          l10n.reportsFilterActive,
          ReportsFilter.active,
          currentFilter,
        ),
        _buildFilterButton(
          context,
          ref,
          l10n.reportsFilterRecovered,
          ReportsFilter.recovered,
          currentFilter,
        ),
        _buildFilterButton(
          context,
          ref,
          l10n.reportsFilterAll,
          ReportsFilter.all,
          currentFilter,
        ),
      ],
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    ReportsFilter value,
    ReportsFilter currentFilter,
  ) {
    final isSelected = value == currentFilter;

    return GestureDetector(
      onTap: () => ref.read(reportsFilterProvider.notifier).state = value,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PetSpacing.md,
            vertical: PetSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected ? PetColors.primary : PetColors.surface,
            borderRadius: PetRadius.mdAll,
            border: Border.all(
              color: isSelected ? PetColors.primary : PetColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? PetColors.surface : PetColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, report) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.go('/reports/${report.id}'),
        borderRadius: PetRadius.xlAll,
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: PetColors.primarySoft,
                      borderRadius: PetRadius.mdAll,
                    ),
                    child: Icon(Icons.pets, color: PetColors.primary, size: 32),
                  ),
                  const SizedBox(width: PetSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                report.pet.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            StatusBadge(
                              status: report.type == ReportType.lost
                                  ? PetStatus.lost
                                  : PetStatus.found,
                            ),
                          ],
                        ),
                        const SizedBox(height: PetSpacing.xs),
                        Text(
                          report.status == ReportStatus.active
                              ? 'Búsqueda activa'
                              : 'Recuperada',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PetSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: PetColors.textSecondary,
                  ),
                  const SizedBox(width: PetSpacing.xs),
                  Expanded(
                    child: Text(
                      report.address,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PetSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: PetColors.textSecondary,
                  ),
                  const SizedBox(width: PetSpacing.xs),
                  Text(
                    'Hace 3 horas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: PetSpacing.md),
              Row(
                children: [
                  _buildIndicator(
                    context,
                    Icons.visibility,
                    '${report.sightingsCount} avistamientos',
                    PetColors.primary,
                  ),
                  const SizedBox(width: PetSpacing.lg),
                  _buildIndicator(
                    context,
                    Icons.diamond,
                    '1 posible coincidencia',
                    PetColors.match,
                  ),
                ],
              ),
              const SizedBox(height: PetSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/activity'),
                  child: Text(l10n.navigationActivity),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: PetSpacing.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ReportsFilter filter) {
    String title;
    String subtitle;

    switch (filter) {
      case ReportsFilter.active:
        title = 'No tienes reportes activos';
        subtitle = 'Cuando crees un reporte de mascota perdida o encontrada, aparecerá aquí.';
      case ReportsFilter.recovered:
        title = 'Aún no has recuperado mascotas';
        subtitle = 'Cuando marques un reporte como recuperado, aparecerá en esta lista.';
      case ReportsFilter.all:
        title = 'No tienes reportes todavía';
        subtitle = 'Crea tu primer reporte para comenzar a buscar o reportar mascotas.';
    }

    return EmptyState(
      icon: Icons.description,
      title: title,
      subtitle: subtitle,
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(PetSpacing.lg),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          height: 200,
          margin: const EdgeInsets.only(bottom: PetSpacing.md),
          decoration: BoxDecoration(
            color: PetColors.surface,
            borderRadius: PetRadius.xlAll,
            border: Border.all(color: PetColors.border),
          ),
          child: Center(
            child: CircularProgressIndicator(color: PetColors.primary),
          ),
        );
      },
    );
  }
}
