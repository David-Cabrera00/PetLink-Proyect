import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_tokens.dart';
import '../../../shared/models/pet_report.dart';
import '../../../shared/widgets/pet_paw_painters.dart';
import '../providers/explore_providers.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _mapController = MapController();
  final _filterScrollController = ScrollController();
  late final TextEditingController _searchController;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(exploreSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterScrollController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLocating = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!mounted) {
          return;
        }
        _showToast(l10n.locationServiceDisabled);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        if (!mounted) {
          return;
        }
        _showToast(l10n.locationPermissionDenied);
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) {
          return;
        }
        _showToast(l10n.locationPermissionPermanentlyDenied);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) {
        return;
      }
      final location = LatLng(position.latitude, position.longitude);
      ref.read(exploreLocationProvider.notifier).state = location;
      _mapController.move(location, 14.5);
    } catch (_) {
      if (mounted) {
        _showToast(l10n.locationFetchError);
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _showToast(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(exploreReportsProvider);
    final selectedReport = ref.watch(selectedReportProvider);
    final filter = ref.watch(exploreFilterProvider);
    final viewMode = ref.watch(exploreViewModeProvider);

    // Si la búsqueda da 1 resultado exacto, seleccionar y centrar en el mapa
    ref.listen<AsyncValue<List<PetReport>>>(exploreReportsProvider, (
      previous,
      next,
    ) {
      final query = ref.read(exploreSearchQueryProvider).trim();
      final reports = next.valueOrNull;
      if (query.isNotEmpty && reports != null && reports.length == 1) {
        final target = reports.first;
        ref.read(selectedReportProvider.notifier).state = target;
        try {
          _mapController.move(LatLng(target.latitude, target.longitude), 14.5);
        } catch (_) {}
      }
    });

    return Scaffold(
      backgroundColor: PetTokens.bgOf(context),
      body: viewMode == ExploreViewMode.map
          ? _buildMapView(context, reportsAsync, selectedReport, filter)
          : _buildListView(context, reportsAsync, filter),
    );
  }

  // ---------------------------------------------------------------------------
  // VISTA LISTA (Explorar.dc.html)
  // ---------------------------------------------------------------------------
  Widget _buildListView(
    BuildContext context,
    AsyncValue<List<PetReport>> reportsAsync,
    ExploreFilter currentFilter,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          0,
          16,
          0,
          PetTokens.contentBottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // Header con título "Explora tu zona" y botón a mapa
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PetTokens.gutter + 4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: PetTokens.displayThemed(context, 36),
                      children: [
                        TextSpan(
                          text: l10n.navigationExplore,
                          style: PetTokens.display(
                            36,
                            color: PetTokens.lostTextOf(context),
                            italic: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    ref.read(exploreViewModeProvider.notifier).state =
                        ExploreViewMode.map;
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: PetTokens.plum,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: PetTokens.shadowButton,
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      color: PetTokens.cream,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Buscador
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PetTokens.gutter,
            ),
            child: _buildSearchBar(l10n),
          ),
          const SizedBox(height: 12),

          // Chips de filtro
          _buildFilterChips(currentFilter, l10n: l10n),
          const SizedBox(height: 14),

          // Contador de resultados y lista
          reportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return const _EmptyStateSwaying();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PetTokens.gutter + 4,
                    ),
                    child: Text(
                      l10n.radarReportsCount(reports.length),
                      style: PetTokens.body(
                        13,
                        color: PetTokens.mutedOf(context),
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PetTokens.gutter,
                    ),
                    child: Column(
                      children: [
                        for (final report in reports) ...[
                          _PetListCard(
                            report: report,
                            onTap: () => context.go('/reports/${report.id}'),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: CircularProgressIndicator(color: PetTokens.plum),
              ),
            ),
            error: (err, st) => const _EmptyStateSwaying(),
          ),
        ],
      ),
    ),
  );
}

  // ---------------------------------------------------------------------------
  // VISTA MAPA (ExplorarMapa.dc.html)
  // ---------------------------------------------------------------------------
  Widget _buildMapView(
    BuildContext context,
    AsyncValue<List<PetReport>> reportsAsync,
    PetReport? selectedReport,
    ExploreFilter currentFilter,
  ) {
    final top = MediaQuery.of(context).padding.top;
    final userLocation = ref.watch(exploreLocationProvider);
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Mapa OpenStreetMap con flutter_map (siempre activo en segundo plano)
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userLocation ?? const LatLng(1.2136, -77.2811),
            initialZoom: 13,
            minZoom: 3,
            maxZoom: 19,
            onTap: (_, _) {
              if (ref.read(selectedReportProvider) != null) {
                ref.read(selectedReportProvider.notifier).state = null;
              }
            },
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              fallbackUrl:
                  'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.petlink',
              maxZoom: 19,
            ),
            // Marcador del usuario con pulso
            if (userLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation,
                    width: 70,
                    height: 70,
                    child: const _UserPulseMarker(),
                  ),
                ],
              ),
            // Pines en forma de gota con huella
            MarkerLayer(
              markers: [
                for (final report in reportsAsync.valueOrNull ?? const <PetReport>[])
                  Marker(
                    point: LatLng(report.latitude, report.longitude),
                    width: 52,
                    height: 62,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedReportProvider.notifier).state =
                            report;
                        _mapController.move(
                          LatLng(report.latitude, report.longitude),
                          15,
                        );
                      },
                      child: PetMapPin(
                        color: report.type == ReportType.lost
                            ? PetTokens.pinLost
                            : PetTokens.mint,
                        isSelected: selectedReport?.id == report.id,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Indicador sutil de carga de reportes si esta consultando la red
        if (reportsAsync.isLoading)
          Positioned(
            top: top + 175,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: PetTokens.surfaceOf(context).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: PetTokens.borderOf(context)),
                  boxShadow: [
                    BoxShadow(
                      color: PetTokens.isDark(context)
                          ? Colors.black.withValues(alpha: 0.3)
                          : const Color(0x1F2A1A29),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PetTokens.plumAccentOf(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.exploreSearching,
                      style: PetTokens.body(
                        12,
                        color: PetTokens.mutedOf(context),
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 2. Barra de búsqueda y alternador de lista flotante superior
        Positioned(
          left: 14,
          right: 14,
          top: top + 10,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: PetTokens.surfaceOf(context).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: PetTokens.borderOf(context)),
                        boxShadow: [
                          BoxShadow(
                            color: PetTokens.isDark(context)
                                ? Colors.black.withValues(alpha: 0.35)
                                : const Color(0x1F2A1A29),
                            offset: const Offset(0, 8),
                            blurRadius: 22,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: PetTokens.muted2,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: PetTokens.body(15, color: PetTokens.inkOf(context)),
                              decoration: InputDecoration(
                                hintText: l10n.exploreSearchHint,
                                hintStyle: PetTokens.body(
                                  15,
                                  color: PetTokens.placeholder,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (v) {
                                ref.read(exploreSearchQueryProvider.notifier).state =
                                    v;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // botón "Ver lista"
                  InkWell(
                    onTap: () {
                      ref.read(exploreViewModeProvider.notifier).state =
                          ExploreViewMode.list;
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: PetTokens.plum,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x404A2D4A),
                            offset: Offset(0, 8),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.view_list_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Chips de filtro flotantes
              _buildFilterChips(currentFilter, isFloating: true, l10n: l10n),
            ],
          ),
        ),

        // 3. botón flotante para centrar en mi ubicación
        Positioned(
          right: 14,
          top: top + 130,
          child: InkWell(
            onTap: _isLocating ? null : _useCurrentLocation,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: PetTokens.surfaceOf(context).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PetTokens.borderOf(context)),
                boxShadow: [
                  BoxShadow(
                    color: PetTokens.isDark(context)
                        ? Colors.black.withValues(alpha: 0.3)
                        : const Color(0x1F2A1A29),
                    offset: const Offset(0, 6),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: _isLocating
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: PetTokens.mint,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.my_location_rounded,
                      color: PetTokens.mint,
                      size: 22,
                    ),
            ),
          ),
        ),

        // 4. Tarjeta inferior flotante (cuando se selecciona un pin)
        if (selectedReport != null)
          Positioned(
            left: 14,
            right: 14,
            bottom: PetTokens.contentBottomPadding + 8,
            child: _SelectedReportSheet(
              report: selectedReport,
              onTap: () => context.go('/reports/${selectedReport.id}'),
              onClose: () {
                ref.read(selectedReportProvider.notifier).state = null;
              },
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // COMPONENTES COMUNES
  // ---------------------------------------------------------------------------
  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: PetTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(PetTokens.rInput),
        border: Border.all(color: PetTokens.borderOf(context), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 20,
            color: PetTokens.muted2,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: PetTokens.body(15, color: PetTokens.inkOf(context)),
              decoration: InputDecoration(
                hintText: l10n.exploreSearchHint,
                hintStyle: PetTokens.body(15, color: PetTokens.placeholder),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) {
                ref.read(exploreSearchQueryProvider.notifier).state = v;
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                ref.read(exploreSearchQueryProvider.notifier).state = '';
              },
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: PetTokens.muted2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    ExploreFilter currentFilter, {
    bool isFloating = false,
    required AppLocalizations l10n,
  }) {
    final filters = [
      (ExploreFilter.all, l10n.exploreAll, null),
      (ExploreFilter.lost, l10n.exploreLost, PetTokens.clay),
      (ExploreFilter.found, l10n.exploreFound, PetTokens.mint),
      (ExploreFilter.nearby, l10n.exploreNearby, null),
      (ExploreFilter.mine, l10n.reportsTitle, null),
    ];

    return SingleChildScrollView(
      controller: isFloating ? null : _filterScrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isFloating ? 0 : PetTokens.gutter,
      ),
      child: Row(
        children: [
          for (final (f, label, dotColor) in filters) ...[
            _FilterChip(
              label: label,
              isSelected: currentFilter == f,
              dotColor: dotColor,
              isFloating: isFloating,
              onTap: () => ref.read(exploreFilterProvider.notifier).state = f,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.dotColor,
    this.isFloating = false,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color? dotColor;
  final bool isFloating;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = PetTokens.isDark(context);
    final bg = isSelected
        ? (isDark ? const Color(0xFF6B366B) : PetTokens.plum)
        : (isFloating
            ? PetTokens.surfaceOf(context).withValues(alpha: 0.95)
            : PetTokens.surfaceOf(context));
    final fg = isSelected ? Colors.white : PetTokens.inkOf(context);
    final border = isSelected
        ? (isDark ? PetTokens.plumAccentOf(context) : PetTokens.plum)
        : PetTokens.borderOf(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.2),
          boxShadow: isFloating
              ? [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : const Color(0x142A1A29),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null && !isSelected) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: PetTokens.body(
                13,
                color: fg,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetListCard extends StatelessWidget {
  const _PetListCard({
    required this.report,
    required this.onTap,
  });

  final PetReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLost = report.type == ReportType.lost;
    final l10n = AppLocalizations.of(context)!;
    final badgeBg =
        isLost ? PetTokens.lostBgOf(context) : PetTokens.mintBgOf(context);
    final badgeColor =
        isLost ? PetTokens.lostTextOf(context) : PetTokens.mintTextOf(context);
    final statusText = isLost ? l10n.statusLost : l10n.statusFound;

    return Container(
      decoration: BoxDecoration(
        color: PetTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(PetTokens.rCard),
        border: Border.all(color: PetTokens.borderOf(context)),
        boxShadow: PetTokens.shadowCardThemed(context),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PetTokens.rCard),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar 68x68 con foto o icono temático
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: report.pet.primaryPhotoUrl != null &&
                        report.pet.primaryPhotoUrl!.isNotEmpty
                    ? Image.network(
                        report.pet.primaryPhotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.pets_rounded, color: badgeColor, size: 30),
                      )
                    : Icon(Icons.pets_rounded, color: badgeColor, size: 30),
              ),
              const SizedBox(width: 14),
              // Datos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            report.pet.name,
                            overflow: TextOverflow.ellipsis,
                            style: PetTokens.displayThemed(context, 21),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            statusText,
                            style: PetTokens.body(
                              12,
                              color: badgeColor,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${report.pet.species} · ${report.pet.sex}',
                      style: PetTokens.body(13, color: PetTokens.mutedOf(context)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: PetTokens.mutedOf(context),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${report.distanceKm.toStringAsFixed(2)} km · ${report.address.isNotEmpty ? report.address : "Cerca de ti"}',
                            overflow: TextOverflow.ellipsis,
                            style: PetTokens.body(12, color: PetTokens.mutedOf(context)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta flotante en el mapa al seleccionar un pin segÃºn `ExplorarMapa.dc.html`
class _SelectedReportSheet extends StatelessWidget {
  const _SelectedReportSheet({
    required this.report,
    required this.onTap,
    required this.onClose,
  });

  final PetReport report;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isLost = report.type == ReportType.lost;
    final l10n = AppLocalizations.of(context)!;
    final badgeBg =
        isLost ? PetTokens.lostBgOf(context) : PetTokens.mintBgOf(context);
    final badgeColor =
        isLost ? PetTokens.lostTextOf(context) : PetTokens.mintTextOf(context);
    final statusText = isLost ? l10n.statusLost : l10n.statusFound;

    return Container(
      decoration: BoxDecoration(
        color: PetTokens.surfaceOf(context).withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(PetTokens.rCard),
        border: Border.all(color: PetTokens.borderOf(context)),
        boxShadow: PetTokens.shadowCardThemed(context),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PetTokens.rCard),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: report.pet.primaryPhotoUrl != null &&
                        report.pet.primaryPhotoUrl!.isNotEmpty
                    ? Image.network(
                        report.pet.primaryPhotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.pets_rounded, color: badgeColor, size: 28),
                      )
                    : Icon(Icons.pets_rounded, color: badgeColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            report.pet.name,
                            overflow: TextOverflow.ellipsis,
                            style: PetTokens.displayThemed(context, 21),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: PetTokens.body(
                              12,
                              color: badgeColor,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${report.pet.species} · ${report.pet.sex} · ${report.address}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PetTokens.body(13, color: PetTokens.mutedOf(context)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.exploreViewReport} →',
                      style: PetTokens.body(
                        13,
                        color: PetTokens.plumAccentOf(context),
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: PetTokens.muted2,
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Estado vacÃ­o con huella oscilando segÃºn `Explorar.dc.html`
class _EmptyStateSwaying extends StatefulWidget {
  const _EmptyStateSwaying();

  @override
  State<_EmptyStateSwaying> createState() => _EmptyStateSwayingState();
}

class _EmptyStateSwayingState extends State<_EmptyStateSwaying>
    with SingleTickerProviderStateMixin {
  late final AnimationController _swayController;

  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _swayController,
            builder: (context, child) {
              final angle =
                  math.sin(_swayController.value * 2 * math.pi) *
                  (6 * math.pi / 180);
              return Transform.rotate(
                angle: angle,
                alignment: const Alignment(0, 0.9),
                child: child,
              );
            },
            child: PetPaw(size: 72, color: PetTokens.trackOf(context)),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.exploreNoReports,
            style: PetTokens.displayThemed(context, 20),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.exploreNoReportsDescription,
            style: PetTokens.body(14, color: PetTokens.mutedOf(context)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Marcador pulsante para la ubicación del usuario
class _UserPulseMarker extends StatefulWidget {
  const _UserPulseMarker();

  @override
  State<_UserPulseMarker> createState() => _UserPulseMarkerState();
}

class _UserPulseMarkerState extends State<_UserPulseMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final t = _pulseController.value;
        final ringScale = 0.3 + 1.1 * t;
        final ringOpacity = (1.0 - t).clamp(0.0, 1.0) * 0.45;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: ringScale,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: PetTokens.mint.withValues(alpha: ringOpacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: PetTokens.mint,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

