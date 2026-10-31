import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_tokens.dart';
import '../../../shared/models/pet_match.dart';
import '../../../shared/models/pet_report.dart';
import '../../auth/providers/auth_provider.dart';
import '../../explore/providers/explore_providers.dart';
import '../providers/radar_providers.dart';
import 'widgets/animated_radar_sweep.dart';

class RadarScreen extends ConsumerStatefulWidget {
  const RadarScreen({super.key});

  @override
  ConsumerState<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends ConsumerState<RadarScreen> {
  String _locationLabel = 'Radio 5 km';

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    try {
      await Geolocator.getCurrentPosition();
      if (mounted) setState(() => _locationLabel = 'Radio 5 km');
    } catch (_) {
      // Mantiene el label predeterminado
    }
  }

  String _getGreeting(BuildContext context, String? userName) {
    final hour = DateTime.now().hour;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    if (hour < 12) {
      return isEn ? 'Good morning' : 'Buenos días';
    } else if (hour < 18) {
      return isEn ? 'Good afternoon' : 'Buenas tardes';
    } else {
      return isEn ? 'Good evening' : 'Buenas noches';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nearbyAsync = ref.watch(nearbyReportsProvider);
    final matchesAsync = ref.watch(matchesProvider);
    final summary = ref.watch(radarSummaryProvider);
    final user = ref.watch(authProvider).user;
    final greeting = _getGreeting(context, user?.name);
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: PetTokens.bgOf(context),
      body: RefreshIndicator(
        color: PetTokens.plum,
        onRefresh: () async {
          ref.invalidate(nearbyReportsProvider);
          ref.invalidate(matchesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            0,
            top + 16,
            0,
            PetTokens.contentBottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header con Saludo y Botón "Radio 5 km"
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PetTokens.gutter + 4,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting.toUpperCase(),
                            style: PetTokens.eyebrow(color: PetTokens.muted2),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.navigationRadar,
                            style: PetTokens.displayThemed(context, 36),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        ref.read(exploreViewModeProvider.notifier).state =
                            ExploreViewMode.map;
                        context.go('/explore');
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: PetTokens.surfaceOf(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: PetTokens.borderOf(context)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: PetTokens.plum,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _locationLabel,
                              style: PetTokens.body(
                                13,
                                color: PetTokens.plum,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Tarjeta Hero Ciruela con Radar Animado
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PetTokens.gutter,
                ),
                child: _RadarHeroCard(
                  summary: summary,
                  onExploreTap: () => context.go('/explore'),
                ),
              ),
              const SizedBox(height: 28),

              // 3. Sección "Posibles coincidencias"
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PetTokens.gutter + 4,
                ),
                child: Text(
                  l10n.radarPossibleMatches,
                  style: PetTokens.displayThemed(context, 22),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PetTokens.gutter,
                ),
                child: matchesAsync.when(
                  data: (matches) {
                    if (matches.isEmpty) {
                      return _EmptyMatchesCard(l10n: l10n);
                    }
                    return Column(
                      children: [
                        for (final match in matches) ...[
                          _MatchItemCard(
                            match: match,
                            onTap: () => context.go('/matches/${match.id}'),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                  loading: () => const _LoadingPlaceholder(),
                  error: (err, st) => const _EmptyMatchesCard(),
                ),
              ),
              const SizedBox(height: 28),

              // 4. Sección "Cerca de ti"
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PetTokens.gutter + 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      l10n.radarNearby,
                      style: PetTokens.displayThemed(context, 22),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/explore'),
                      child: Text(
                        l10n.exploreAll,
                        style: PetTokens.body(
                          14,
                          color: PetTokens.plumAccentOf(context),
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PetTokens.gutter,
                ),
                child: nearbyAsync.when(
                  data: (reports) {
                    if (reports.isEmpty) {
                      return const _EmptyNearbyCard();
                    }
                    return Column(
                      children: [
                        for (final report in reports.take(4)) ...[
                          _NearbyPetCard(
                            report: report,
                            onTap: () => context.go('/reports/${report.id}'),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                  loading: () => const _LoadingPlaceholder(),
                  error: (err, st) => const _EmptyNearbyCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta Hero en plum con radar animado y contador grande Fraunces
class _RadarHeroCard extends StatelessWidget {
  const _RadarHeroCard({
    required this.summary,
    required this.onExploreTap,
  });

  final RadarSummary summary;
  final VoidCallback onExploreTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: PetTokens.isDark(context)
            ? const Color(0xFF2E1C2E)
            : PetTokens.plum,
        borderRadius: BorderRadius.circular(PetTokens.rCardHero),
        border: PetTokens.isDark(context)
            ? Border.all(color: const Color(0xFF5A3E5C), width: 1.5)
            : null,
        boxShadow: PetTokens.shadowCardThemed(context),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              // Radar con haz giratorio continuo
              const AnimatedRadarSweep(size: 140),
              const SizedBox(width: 16),
              // Datos y contador en Fraunces 64px
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge "● ACTIVO"
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: PetTokens.mintOnDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.radarActive.toUpperCase(),
                          style: PetTokens.eyebrow(color: PetTokens.peach),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Contador gigante
                    Text(
                      '${summary.totalReports}',
                      style: PetTokens.display(
                        60,
                        color: PetTokens.cream,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.radarReportsWithinRadius(summary.totalReports),
                      style: PetTokens.body(
                        13,
                        color: PetTokens.lilacText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Botón ancho crema "Explorar el radar"
          InkWell(
            onTap: onExploreTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: PetTokens.isDark(context)
                    ? const Color(0xFFE8D4E8)
                    : PetTokens.cream,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.radarExplore,
                    style: PetTokens.body(
                      15,
                      color: PetTokens.plum,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: PetTokens.plum,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de coincidencia con avatar doble
class _MatchItemCard extends StatelessWidget {
  const _MatchItemCard({
    required this.match,
    required this.onTap,
  });

  final PetMatch match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: PetTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(PetTokens.rCard),
        border: Border.all(color: const Color(0xFFCFE5DD)),
        boxShadow: PetTokens.shadowCard,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PetTokens.rCard),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar doble superpuesto 56x56
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  children: [
                    // Mascota perdida (arriba izquierda)
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: PetTokens.lostBg,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: PetTokens.surfaceOf(context),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.pets_rounded,
                          size: 18,
                          color: PetTokens.clayText,
                        ),
                      ),
                    ),
                    // Mascota encontrada (abajo derecha)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: PetTokens.mintBg,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: PetTokens.surfaceOf(context),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: PetTokens.mint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Datos de la coincidencia
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: match.lostReport.pet.name,
                            style: PetTokens.body(
                              16,
                              color: PetTokens.inkOf(context),
                              weight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: l10n.radarYourReportSuffix,
                            style: PetTokens.body(
                              14,
                              color: PetTokens.muted,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.radarMatchFoundNotice,
                      style: PetTokens.bodyThemed(context, 13, color: PetTokens.mutedOf(context)),
                    ),
                    const SizedBox(height: 6),
                    // Chips de especie, distancia y tiempo
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: PetTokens.mintBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '✓ Especie',
                            style: PetTokens.body(
                              12,
                              color: PetTokens.mintText,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: PetTokens.muted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${match.distanceKm.toStringAsFixed(1)} km',
                              style: PetTokens.body(12, color: PetTokens.muted),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: PetTokens.muted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Hace ${match.timeDifference.inHours > 0 ? '${match.timeDifference.inHours} h' : '${match.timeDifference.inMinutes} m'}',
                              style: PetTokens.body(12, color: PetTokens.muted),
                            ),
                          ],
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

/// Tarjeta de reporte cercano según `Radar.dc.html`
class _NearbyPetCard extends StatelessWidget {
  const _NearbyPetCard({
    required this.report,
    required this.onTap,
  });

  final PetReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLost = report.type == ReportType.lost;
    final badgeBg = isLost ? PetTokens.lostBg : PetTokens.mintBg;
    final badgeColor = isLost ? PetTokens.clayText : PetTokens.mintText;
    final statusText = isLost ? l10n.statusLost : l10n.statusFound;

    return Container(
      decoration: BoxDecoration(
        color: PetTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(PetTokens.rCard),
        border: Border.all(color: PetTokens.borderOf(context)),
        boxShadow: PetTokens.shadowCard,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PetTokens.rCard),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar ilustrado / foto de la mascota
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
              // Datos de la mascota
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
                            style: PetTokens.displayThemed(context, 20),
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
                    const SizedBox(height: 3),
                    Text(
                      '${report.pet.species} · ${report.pet.sex}',
                      style: PetTokens.bodyThemed(context, 13, color: PetTokens.mutedOf(context)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: PetTokens.muted,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            (report.distanceKm > 0.05 ? '${report.distanceKm.toStringAsFixed(1)} km · ' : '') + (report.address.isNotEmpty ? report.address : 'Cerca de ti'),
                            overflow: TextOverflow.ellipsis,
                            style: PetTokens.body(12, color: PetTokens.muted),
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

class _EmptyMatchesCard extends StatelessWidget {
  const _EmptyMatchesCard({this.l10n});
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final l10n = this.l10n ?? AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PetTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(PetTokens.rCard),
        border: Border.all(color: PetTokens.borderOf(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: PetTokens.isDark(context) ? const Color(0xFF382338) : PetTokens.lilacBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.search_rounded,
              color: PetTokens.plumAccentOf(context),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.radarNoMatchesTitle,
                  style: PetTokens.bodyThemed(context, 15, color: PetTokens.inkOf(context), weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Te avisaremos en cuanto detectemos una mascota similar en tu radar.',
                  style: PetTokens.bodyThemed(context, 13, color: PetTokens.mutedOf(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNearbyCard extends StatelessWidget {
  const _EmptyNearbyCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PetTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(PetTokens.rCard),
        border: Border.all(color: PetTokens.borderOf(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: PetTokens.isDark(context) ? const Color(0xFF382338) : PetTokens.lilacBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.pets_rounded,

              color: PetTokens.plumAccentOf(context),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.radarNoReportsTitle,
                  style: PetTokens.bodyThemed(context, 15, color: PetTokens.inkOf(context), weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.radarNoReportsDescription,
                  style: PetTokens.bodyThemed(context, 13, color: PetTokens.mutedOf(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: PetTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(PetTokens.rCard),
        border: Border.all(color: PetTokens.borderOf(context)),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: PetTokens.plum,
          ),
        ),
      ),
    );
  }
}
