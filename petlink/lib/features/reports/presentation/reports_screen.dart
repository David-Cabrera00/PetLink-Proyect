import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../core/theme/pet_theme_extension.dart';
import '../../../design_system/badges/status_badge.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../shared/models/pet_report.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../providers/reports_providers.dart';
import '../../explore/providers/explore_providers.dart';

class ReportsScreen extends ConsumerWidget {
  final bool onlyMyReports;

  const ReportsScreen({super.key, this.onlyMyReports = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (onlyMyReports) {
      return _buildMyReportsScreen(context, ref, l10n);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navigationReport),
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(PetSpacing.lg),
        child: Column(
          children: [
            _buildHubAction(
              context,
              icon: PhosphorIconsRegular.plusCircle,
              title: 'Crear nuevo reporte',
              subtitle: 'Informa sobre una mascota perdida o encontrada',
              onTap: () => context.go('/report/new'),
              emphasized: true,
            ),
            const SizedBox(height: PetSpacing.md),
            _buildHubAction(
              context,
              icon: PhosphorIconsRegular.usersThree,
              title: 'Reportes de la comunidad',
              subtitle: 'Consulta reportes de otras personas cerca de ti',
              onTap: () {
                ref.read(exploreViewModeProvider.notifier).state =
                    ExploreViewMode.list;
                context.go('/explore');
              },
            ),
            const Spacer(),
            Text(
              'Tus reportes personales están disponibles desde Perfil.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyReportsScreen(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final reportsAsync = ref.watch(myReportsProvider);
    final filter = ref.watch(reportsFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportsTitle),
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
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
              icon: PhosphorIconsRegular.plus,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHubAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool emphasized = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: emphasized ? cs.primary : cs.surface,
      borderRadius: PetRadius.lgAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: PetRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: emphasized ? cs.onPrimary : cs.primary),
              const SizedBox(width: PetSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: emphasized ? cs.onPrimary : cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: emphasized
                            ? cs.onPrimary.withValues(alpha: 0.78)
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIconsRegular.caretRight,
                color: emphasized ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
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
    final theme = Theme.of(context);
    final extension = PetThemeExtension.of(context);
    final isLost = report.type == ReportType.lost;
    final statusColor = isLost ? extension.lost : extension.found;
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surface,
      elevation: 3,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: PetRadius.xlAll,
        side: BorderSide(color: statusColor.withValues(alpha: 0.28)),
      ),
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
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: PetRadius.lgAll,
                    ),
                    child: Icon(
                      PhosphorIconsRegular.pawPrint,
                      color: statusColor,
                      size: 32,
                    ),
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
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
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
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
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
                    PhosphorIconsRegular.mapPin,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: PetSpacing.xs),
                  Expanded(
                    child: Text(
                      report.address,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PetSpacing.xs),
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.clock,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
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
                    PhosphorIconsRegular.eye,
                    '${report.sightingsCount} avistamientos',
                    PetColors.primary,
                  ),
                  const Spacer(),
                  Text(
                    'Ver detalle',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: PetSpacing.xs),
                  Icon(
                    PhosphorIconsRegular.arrowUpRight,
                    size: 17,
                    color: theme.colorScheme.primary,
                  ),
                ],
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
      icon: PhosphorIconsRegular.fileText,
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
