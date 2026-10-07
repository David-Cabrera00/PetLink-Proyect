import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../design_system/badges/status_badge.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../shared/models/pet_report.dart';
import '../../../shared/widgets/search_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../providers/explore_providers.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(exploreReportsProvider);
    final selectedReport = ref.watch(selectedReportProvider);
    final filter = ref.watch(exploreFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(PetSpacing.lg),
            child: Column(
              children: [
                const PetSearchBar(hint: 'Buscar mascota o zona'),
                const SizedBox(height: PetSpacing.md),
                _buildFilters(context, ref, filter),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                _buildMapPlaceholder(context, reportsAsync, ref),
                if (selectedReport != null)
                  Positioned(
                    left: PetSpacing.lg,
                    right: PetSpacing.lg,
                    bottom: PetSpacing.lg,
                    child: _buildReportPreview(context, selectedReport, ref),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, WidgetRef ref, ExploreFilter currentFilter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            context,
            ref,
            'Todos',
            ExploreFilter.all,
            currentFilter,
            Icons.list,
          ),
          const SizedBox(width: PetSpacing.sm),
          _buildFilterChip(
            context,
            ref,
            'Perdidas',
            ExploreFilter.lost,
            currentFilter,
            Icons.priority_high,
          ),
          const SizedBox(width: PetSpacing.sm),
          _buildFilterChip(
            context,
            ref,
            'Encontradas',
            ExploreFilter.found,
            currentFilter,
            Icons.check_circle,
          ),
          const SizedBox(width: PetSpacing.sm),
          _buildFilterChip(
            context,
            ref,
            '< 5 km',
            ExploreFilter.nearby,
            currentFilter,
            Icons.near_me,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    ExploreFilter value,
    ExploreFilter currentFilter,
    IconData icon,
  ) {
    final isSelected = value == currentFilter;

    return GestureDetector(
      onTap: () => ref.read(exploreFilterProvider.notifier).state = value,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PetSpacing.md,
            vertical: PetSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected ? PetColors.primary : PetColors.surface,
            borderRadius: PetRadius.xxlAll,
            border: Border.all(
              color: isSelected ? PetColors.primary : PetColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? PetColors.surface : PetColors.textSecondary,
              ),
              const SizedBox(width: PetSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? PetColors.surface : PetColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder(BuildContext context, AsyncValue reportsAsync, WidgetRef ref) {
    return Container(
      color: PetColors.background,
      child: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return EmptyState(
              icon: Icons.map,
              title: 'No hay reportes en esta zona',
              subtitle: 'Intenta cambiar los filtros o ampliar el radio de búsqueda.',
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth;
              final maxH = constraints.maxHeight;
              return Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 64,
                          color: PetColors.primary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: PetSpacing.md),
                        Text(
                          'Mapa de exploración',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: PetSpacing.xs),
                        Text(
                          'Aquí se mostrará el mapa con los reportes',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ...reports.map((report) => _buildMarker(context, report, ref, maxW, maxH)),
                ],
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: PetColors.primary),
        ),
        error: (Object _, StackTrace _) => ErrorState(
          title: 'No pudimos cargar el mapa',
          subtitle: 'Verifica tu conexión e intenta nuevamente.',
          onRetry: () => ref.invalidate(exploreReportsProvider),
        ),
      ),
    );
  }

  Widget _buildMarker(BuildContext context, report, WidgetRef ref, double maxW, double maxH) {
    final isLost = report.type == ReportType.lost;
    final color = isLost ? PetColors.lost : PetColors.found;
    final icon = isLost ? Icons.priority_high : Icons.check_circle;

    final safeLeft = (maxW * 0.1).clamp(16.0, maxW * 0.3);
    final safeTop = (maxH * 0.15).clamp(24.0, maxH * 0.3);
    final rangeX = (maxW * 0.7).clamp(100.0, 300.0);
    final rangeY = (maxH * 0.5).clamp(80.0, 250.0);

    final normalizedDist = (report.distanceKm / 10.0).clamp(0.0, 1.0);
    final left = safeLeft + (normalizedDist * rangeX);
    final top = safeTop + (normalizedDist * rangeY * 0.6);

    return Positioned(
      left: left.clamp(0.0, maxW - 80),
      top: top.clamp(0.0, maxH - 40),
      child: GestureDetector(
        onTap: () => ref.read(selectedReportProvider.notifier).state = report,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PetSpacing.sm,
            vertical: PetSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: PetRadius.smAll,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: PetColors.surface),
              const SizedBox(width: PetSpacing.xs),
              Text(
                report.pet.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PetColors.surface,
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }

  Widget _buildReportPreview(BuildContext context, report, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(PetSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                  child: Icon(
                    Icons.pets,
                    color: PetColors.primary,
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
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          StatusBadge(
                            status: report.type == ReportType.lost ? PetStatus.lost : PetStatus.found,
                          ),
                        ],
                      ),
                      const SizedBox(height: PetSpacing.xs),
                      Text(
                        '${report.pet.breed} · ${report.pet.sex} · ${report.pet.age}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: PetSpacing.xs),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: PetColors.textSecondary),
                          const SizedBox(width: PetSpacing.xs),
                          Text(
                            '${report.distanceKm} km',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: PetSpacing.md),
                          Icon(Icons.access_time, size: 14, color: PetColors.textSecondary),
                          const SizedBox(width: PetSpacing.xs),
                          Text(
                            'Hace 3 horas',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: PetSpacing.md),
            Text(
              report.address,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: PetSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: PetButton(
                    label: 'Ver reporte',
                    onPressed: () => context.go('/reports/${report.id}'),
                  ),
                ),
                const SizedBox(width: PetSpacing.md),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.bookmark_border, color: PetColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: PetColors.primarySoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: PetRadius.mdAll,
                    ),
                  ),
                ),
                const SizedBox(width: PetSpacing.sm),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.share, color: PetColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: PetColors.primarySoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: PetRadius.mdAll,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
