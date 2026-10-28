import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../shared/models/pet_report.dart';
import '../../../shared/models/report_draft.dart';
import '../../../shared/widgets/photo_preview.dart';
import '../../../shared/widgets/step_indicator.dart';
import '../../explore/providers/explore_providers.dart';
import '../../radar/providers/radar_providers.dart';
import '../providers/report_draft_provider.dart';
import '../providers/reports_providers.dart';

class ReportReviewScreen extends ConsumerStatefulWidget {
  const ReportReviewScreen({super.key});

  @override
  ConsumerState<ReportReviewScreen> createState() => _ReportReviewScreenState();
}

class _ReportReviewScreenState extends ConsumerState<ReportReviewScreen> {
  bool _isPublishing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(reportDraftProvider);
    final cs = Theme.of(context).colorScheme;
    final isLost = draft.reportType == ReportType.lost;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l10n.reportReviewTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/report/new/details'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  PetSpacing.lg,
                  PetSpacing.xs,
                  PetSpacing.lg,
                  PetSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Barra de progreso por pasos
                    const StepIndicator(current: 6, total: 6),
                    const SizedBox(height: PetSpacing.lg),

                    // Encabezado sin duplicados
                    Text(
                      l10n.reportReviewTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.reportReviewSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: PetSpacing.lg),

                    // 2. Tarjeta Principal y Fotografía de la Mascota
                    _buildMainPetCard(context, draft, isLost),
                    const SizedBox(height: PetSpacing.lg),

                    // 3. Cuadrícula de Atributos Rápidos (2 columnas)
                    _buildQuickAttributesGrid(context, draft, l10n),
                    const SizedBox(height: PetSpacing.lg),

                    // 4. Tarjeta de Ubicación y Fecha
                    _buildLocationAndDateCard(context, draft, isLost, l10n),
                    const SizedBox(height: PetSpacing.lg),

                    // 5. Tarjeta de Observaciones
                    _buildObservationsSection(context, draft, l10n),
                  ],
                ),
              ),
            ),

            // 6. Botones de Acción fijos en la parte inferior
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// Tarjeta principal con la fotografía destacada, chip de estado flotante y nombre/especie
  Widget _buildMainPetCard(
    BuildContext context,
    ReportDraft draft,
    bool isLost,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhotos = draft.photos.isNotEmpty;
    final mainPhotoUrl = hasPhotos ? draft.photos.first : '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fotografía con chip flotante
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(19),
                ),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: hasPhotos
                      ? (mainPhotoUrl.startsWith('http')
                            ? Image.network(
                                mainPhotoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPhotoPlaceholder(context),
                              )
                            : buildLocalPhotoPreview(
                                mainPhotoUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPhotoPlaceholder(context),
                              ))
                      : _buildPhotoPlaceholder(context),
                ),
              ),

              // Chip de estado flotante sobre la foto (arriba a la derecha)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isLost
                        ? const Color(0xFFFFEBEE).withValues(alpha: 0.94)
                        : const Color(0xFFE8F5E9).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLost
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 16,
                        color: isLost
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF2E7D32),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isLost ? l10n.statusLost : l10n.statusFound,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isLost
                              ? const Color(0xFFB71C1C)
                              : const Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Si tiene fotos adicionales, indicador de cantidad
              if (draft.photos.length > 1)
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${draft.photos.length} fotos',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Datos al pie de la foto
          Padding(
            padding: const EdgeInsets.all(PetSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.name.trim().isNotEmpty
                      ? draft.name.trim()
                      : (isLost ? l10n.unnamedPet : l10n.foundPet),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.pets_rounded,
                      size: 16,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        [
                          if (draft.species.trim().isNotEmpty)
                            draft.species.trim(),
                          if (draft.breed.trim().isNotEmpty) draft.breed.trim(),
                        ].join(' • '),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pets_rounded,
              size: 42,
              color: cs.onSurfaceVariant.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.noPhotosAttached,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Cuadrícula 2x2 para Sexo, Edad, Tamaño y Color
  Widget _buildQuickAttributesGrid(
    BuildContext context,
    ReportDraft draft,
    AppLocalizations l10n,
  ) {
    final sexLower = draft.sex.toLowerCase();
    final isFemale =
        sexLower.contains('hembra') ||
        sexLower.contains('female') ||
        sexLower.contains('femenino');
    final sexIcon = isFemale ? Icons.female_rounded : Icons.male_rounded;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAttributeCard(
                context,
                icon: sexIcon,
                label: l10n.reportReviewSex,
                value: draft.sex,
              ),
            ),
            const SizedBox(width: PetSpacing.sm),
            Expanded(
              child: _buildAttributeCard(
                context,
                icon: Icons.cake_outlined,
                label: l10n.reportReviewAge,
                value: draft.age,
              ),
            ),
          ],
        ),
        const SizedBox(height: PetSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildAttributeCard(
                context,
                icon: Icons.straighten_rounded,
                label: l10n.reportReviewSize,
                value: draft.size,
              ),
            ),
            const SizedBox(width: PetSpacing.sm),
            Expanded(
              child: _buildAttributeCard(
                context,
                icon: Icons.palette_outlined,
                label: l10n.reportReviewColor,
                value: draft.color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttributeCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? cs.surfaceContainerHighest.withValues(alpha: 0.55)
        : const Color(0xFFF8F6F4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: cs.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.trim().isNotEmpty ? value.trim() : '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta agrupada para Ubicación y Fecha/Hora
  Widget _buildLocationAndDateCard(
    BuildContext context,
    ReportDraft draft,
    bool isLost,
    AppLocalizations l10n,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? cs.surfaceContainerHighest.withValues(alpha: 0.55)
        : const Color(0xFFF8F6F4);

    final dateText = draft.lastSeenAt != null
        ? _formatDateTime(draft.lastSeenAt!)
        : '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PetSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Fila de Ubicación
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportReviewLocation,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      draft.address.trim().isNotEmpty
                          ? draft.address.trim()
                          : l10n.locationNotSpecified,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: PetSpacing.xs),
            child: Divider(
              color: cs.outlineVariant.withValues(alpha: 0.3),
              thickness: 1,
            ),
          ),

          // Fila de Fecha y Hora
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLost
                          ? l10n.reportReviewLastSeen
                          : l10n.reportReviewFoundDate,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLost
                          ? '${l10n.lastSeenAtPrefix}: $dateText'
                          : '${l10n.foundDatePrefix}: $dateText',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Bloques tipo nota para Señas particulares y ¿Qué ocurrió?
  Widget _buildObservationsSection(
    BuildContext context,
    ReportDraft draft,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        if (draft.traits.trim().isNotEmpty) ...[
          _buildNoteCard(
            context,
            icon: Icons.notes_rounded,
            title: l10n.reportReviewTraits,
            content: draft.traits.trim(),
          ),
          const SizedBox(height: PetSpacing.md),
        ],
        if (draft.description.trim().isNotEmpty) ...[
          _buildNoteCard(
            context,
            icon: Icons.info_outline_rounded,
            title: l10n.reportReviewWhatHappened,
            content: draft.description.trim(),
          ),
          const SizedBox(height: PetSpacing.md),
        ],
        if (draft.reportType == ReportType.found &&
            draft.isPetWithFinder != null) ...[
          _buildNoteCard(
            context,
            icon: Icons.home_outlined,
            title: l10n.reportReviewPetWithFinder,
            content: draft.isPetWithFinder == true ? l10n.yes : l10n.no,
          ),
          const SizedBox(height: PetSpacing.md),
        ],
      ],
    );
  }

  Widget _buildNoteCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? cs.surfaceContainerHighest.withValues(alpha: 0.55)
        : const Color(0xFFF8F6F4);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PetSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: PetSpacing.xs),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  /// Botones de acción inferiores con separación segura
  Widget _buildActionButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        PetSpacing.lg,
        PetSpacing.sm,
        PetSpacing.lg,
        PetSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón principal: Publicar reporte
          FilledButton.icon(
            onPressed: _isPublishing ? null : () => _publishReport(context),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              elevation: 2,
              shadowColor: cs.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: PetRadius.mdAll),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            icon: _isPublishing
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: cs.onPrimary,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 19),
            label: Text(l10n.publishReport),
          ),
          const SizedBox(height: PetSpacing.xs),

          // Botón secundario: Volver a editar
          OutlinedButton.icon(
            onPressed: _isPublishing
                ? null
                : () => context.go('/report/new/details'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
              shape: RoundedRectangleBorder(borderRadius: PetRadius.mdAll),
              foregroundColor: cs.onSurface,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(l10n.editReport),
          ),
        ],
      ),
    );
  }

  Future<void> _publishReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isPublishing = true);

    final notifier = ref.read(reportDraftProvider.notifier);
    final draft = ref.read(reportDraftProvider);

    try {
      final repository = ref.read(petReportRepositoryProvider);
      final _ = await repository.createReport(draft);

      if (context.mounted) {
        ref.invalidate(nearbyReportsProvider);
        ref.invalidate(myReportsProvider);
        ref.invalidate(exploreReportsProvider);
        notifier.clearDraft();
        context.go('/report/new/published');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.publishError(e)),
            backgroundColor: PetColors.lost,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
