import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petlink/l10n/app_localizations.dart';

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
import '../../reports/providers/reports_providers.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _mapController = MapController();
  bool _isLocating = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reportsAsync = ref.watch(exploreReportsProvider);
    final selectedReport = ref.watch(selectedReportProvider);
    final filter = ref.watch(exploreFilterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navigationExplore)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(PetSpacing.lg),
            child: Column(
              children: [
                PetSearchBar(hint: l10n.exploreSearchHint),
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

  Widget _buildFilters(
    BuildContext context,
    WidgetRef ref,
    ExploreFilter currentFilter,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            context,
            ref,
            l10n.exploreAll,
            ExploreFilter.all,
            currentFilter,
            Icons.list,
          ),
          const SizedBox(width: PetSpacing.sm),
          _buildFilterChip(
            context,
            ref,
            l10n.exploreLost,
            ExploreFilter.lost,
            currentFilter,
            Icons.priority_high,
          ),
          const SizedBox(width: PetSpacing.sm),
          _buildFilterChip(
            context,
            ref,
            l10n.exploreFound,
            ExploreFilter.found,
            currentFilter,
            Icons.check_circle,
          ),
          const SizedBox(width: PetSpacing.sm),
          _buildFilterChip(
            context,
            ref,
            l10n.exploreNearby,
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

  Widget _buildMapPlaceholder(
    BuildContext context,
    AsyncValue reportsAsync,
    WidgetRef ref,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: PetColors.background,
      child: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return EmptyState(
              icon: Icons.map,
              title: l10n.exploreNoReports,
              subtitle: l10n.exploreNoReportsDescription,
            );
          }
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(1.2136, -77.2811),
              initialZoom: 12,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.petlink.app',
              ),
              MarkerLayer(
                markers: [
                  for (final report in reports)
                    Marker(
                      point: LatLng(report.latitude, report.longitude),
                      width: 44,
                      height: 44,
                      child: Tooltip(
                        message: report.pet.name,
                        child: GestureDetector(
                          onTap: () => ref
                              .read(selectedReportProvider.notifier)
                              .state = report,
                          child: Container(
                            decoration: BoxDecoration(
                              color: report.type == ReportType.lost
                                  ? PetColors.lost
                                  : PetColors.found,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: PetColors.surface,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              report.type == ReportType.lost
                                  ? Icons.pets
                                  : Icons.pets_outlined,
                              size: 22,
                              color: PetColors.surface,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
              ),
              Positioned(
                left: PetSpacing.sm,
                top: PetSpacing.sm,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(
                      alpha: 0.85,
                    ),
                    borderRadius: PetRadius.smAll,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PetSpacing.sm,
                      vertical: PetSpacing.xs,
                    ),
                    child: Text(
                      '\u00A9 OpenStreetMap contributors',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: PetSpacing.sm,
                top: PetSpacing.sm,
                child: IconButton.filled(
                  tooltip: l10n.useCurrentLocation,
                  onPressed: _isLocating
                      ? null
                      : () => _useCurrentLocation(context),
                  icon: _isLocating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                ),
              ),
            ],
          );
        },
        loading: () =>
            Center(child: CircularProgressIndicator(color: PetColors.primary)),
        error: (Object _, StackTrace _) => ErrorState(
          title: l10n.exploreMapLoadError,
          subtitle: l10n.connectionRetryDescription,
          onRetry: () => ref.invalidate(exploreReportsProvider),
        ),
      ),
    );
  }

  Future<void> _useCurrentLocation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLocating = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showLocationMessage(context, l10n.locationServiceDisabled);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _showLocationMessage(context, l10n.locationPermissionDenied);
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _showLocationMessage(
          context,
          l10n.locationPermissionPermanentlyDenied,
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final location = LatLng(position.latitude, position.longitude);
      ref.read(exploreLocationProvider.notifier).state = location;
      _mapController.move(location, 14);
    } catch (_) {
      if (mounted) _showLocationMessage(context, l10n.locationFetchError);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _showLocationMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildReportPreview(BuildContext context, report, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
                        '${report.pet.breed} · ${report.pet.sex} · ${report.pet.age}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: PetSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: PetColors.textSecondary,
                          ),
                          const SizedBox(width: PetSpacing.xs),
                          Text(
                            '${report.distanceKm} km',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: PetSpacing.md),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: PetColors.textSecondary,
                          ),
                          const SizedBox(width: PetSpacing.xs),
                          Text(
                            l10n.exploreHoursAgo,
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
            Text(report.address, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: PetSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: PetButton(
                    label: l10n.exploreViewReport,
                    onPressed: () => context.go('/reports/${report.id}'),
                  ),
                ),
                const SizedBox(width: PetSpacing.md),
                IconButton(
                  onPressed: () {
                    final saved = {
                      ...ref.read(savedReportIdsProvider),
                    };
                    if (!saved.add(report.id)) saved.remove(report.id);
                    ref.read(savedReportIdsProvider.notifier).state = saved;
                  },
                  icon: Icon(
                    ref.watch(savedReportIdsProvider).contains(report.id)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: PetColors.primary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: PetColors.primarySoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: PetRadius.mdAll,
                    ),
                  ),
                ),
                const SizedBox(width: PetSpacing.sm),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: 'https://petlink.app/reports/${report.id}'),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.shareAction)),
                      );
                    }
                  },
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
