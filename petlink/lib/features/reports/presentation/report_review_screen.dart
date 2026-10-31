import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/theme/pet_tokens.dart';
import '../../../shared/models/pet_report.dart';
import '../../../shared/widgets/pet_paw_painters.dart';
import '../../../shared/widgets/photo_preview.dart';
import '../../explore/providers/explore_providers.dart';
import '../../radar/providers/radar_providers.dart';
import '../providers/report_draft_provider.dart';
import '../providers/reports_providers.dart';
import 'widgets/report_flow_stepper.dart';

class ReportReviewScreen extends ConsumerStatefulWidget {
  const ReportReviewScreen({super.key});

  @override
  ConsumerState<ReportReviewScreen> createState() => _ReportReviewScreenState();
}

class _ReportReviewScreenState extends ConsumerState<ReportReviewScreen> {
  bool _isPublishing = false;

  Future<void> _publishReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isPublishing = true);

    final notifier = ref.read(reportDraftProvider.notifier);
    final draft = ref.read(reportDraftProvider);

    try {
      final repository = ref.read(petReportRepositoryProvider);
      await repository.createReport(draft);

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
            backgroundColor: PetTokens.clayText,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Hoy';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(reportDraftProvider);
    final isLost = draft.reportType == ReportType.lost;
    final petName = draft.name.trim().isNotEmpty
        ? draft.name.trim()
        : (isLost ? l10n.unnamedPet : l10n.foundPet);

    final summaryParts = [
      draft.breed.isNotEmpty ? draft.breed : draft.species,
      if (draft.sex.isNotEmpty) draft.sex,
      if (draft.size.isNotEmpty) draft.size,
      if (draft.color.isNotEmpty) draft.color,
    ];
    final summary = summaryParts.join(' \u00B7 ');

    return Scaffold(
      backgroundColor: PetTokens.bgOf(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Stepper oficial Paso 6 de 6
            ReportFlowStepper(
              currentStep: 6,
              stepTitle: l10n.reportReviewTitle,
              onBack: () => context.pop(),
            ),

            // Contenido escroleable
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  PetTokens.gutter,
                  12,
                  PetTokens.gutter,
                  110,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título según Paso6Publicar.dc.html
                    Text(
                      l10n.reportReviewTitle,
                      style: PetTokens.displayThemed(context, 26),
                    ),
                    const SizedBox(height: 18),

                    // Afiche estilo Póster Oficial (Paso6Publicar.dc.html)
                    Transform.rotate(
                      angle: -0.02,
                      child: _WantedPosterCard(
                        isLost: isLost,
                        petName: petName,
                        summary: summary,
                        photoPath: draft.photos.isNotEmpty
                            ? draft.photos.first
                            : null,
                        address: draft.address.isNotEmpty
                            ? draft.address
                            : 'Ubicaci\u00F3n registrada',
                        dateFormatted: _formatDateTime(draft.lastSeenAt),
                        traits: draft.traits,
                        description: draft.description,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botones inferiores (Editar + Publicar reporte)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PetTokens.gutter,
                0,
                PetTokens.gutter,
                24,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: _isPublishing ? null : () => context.pop(),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 110,
                      height: 56,
                      decoration: BoxDecoration(
                        color: PetTokens.isDark(context)
                            ? PetTokens.surfaceHigherOf(context)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: PetTokens.isDark(context)
                              ? PetTokens.borderOf(context)
                              : PetTokens.plum,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.backAction,
                        style: PetTokens.body(
                          15,
                          color: PetTokens.isDark(context)
                              ? PetTokens.inkOf(context)
                              : PetTokens.plum,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _isPublishing
                          ? null
                          : () => _publishReport(context),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: PetTokens.clay,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x59E07A5F),
                              offset: Offset(0, 12),
                              blurRadius: 26,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: _isPublishing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.publishReport,
                                    style: PetTokens.body(
                                      16,
                                      color: Colors.white,
                                      weight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    PhosphorIconsBold.paperPlaneRight,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PÓSTER AFICHE OFICIAL "SE BUSCA" / "ENCONTRADA" (Paso6Publicar.dc.html)
// -----------------------------------------------------------------------------
class _WantedPosterCard extends StatelessWidget {
  const _WantedPosterCard({
    required this.isLost,
    required this.petName,
    required this.summary,
    required this.photoPath,
    required this.address,
    required this.dateFormatted,
    this.traits,
    this.description,
  });

  final bool isLost;
  final String petName;
  final String summary;
  final String? photoPath;
  final String address;
  final String dateFormatted;
  final String? traits;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final posterColor = isLost ? PetTokens.lostTextOf(context) : PetTokens.mintTextOf(context);
    final stampText = isLost ? 'PERDIDA\nAY\u00DADANOS' : 'ENCONTRADA\nHOGAR';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: PetTokens.surfaceOf(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PetTokens.borderOf(context)),
            boxShadow: PetTokens.shadowCardThemed(context),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado afiche
              Text(
                isLost ? 'SE BUSCA' : 'MASCOTA ENCONTRADA',
                textAlign: TextAlign.center,
                style: PetTokens.body(
                  14,
                  color: posterColor,
                  weight: FontWeight.w900,
                  letterSpacing: 0.3 * 14,
                ),
              ),
              const SizedBox(height: 12),

              // Foto principal o placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: PetTokens.isDark(context)
                      ? const Color(0xFF28212F)
                      : const Color(0xFFF1E6DC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: photoPath != null
                      ? (photoPath!.startsWith('http')
                            ? Image.network(
                                photoPath!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : buildLocalPhotoPreview(
                                photoPath!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: PetTokens.muted,
                                  ),
                                ),
                              ))
                      : Center(
                          child: PetPaw(
                            size: 64,
                            color: posterColor.withValues(alpha: 0.5),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Nombre
              Text(
                petName,
                style: PetTokens.displayThemed(
                  context,
                  32,
                  italic: true,
                ),
              ),
              const SizedBox(height: 4),

              // Resumen
              Text(summary, style: PetTokens.bodyThemed(context, 13, color: PetTokens.mutedOf(context))),
              const SizedBox(height: 12),

              // Pills de ubicación y fecha
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: PetTokens.isDark(context)
                          ? const Color(0xFF2C2232)
                          : const Color(0xFFEFE3EC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIconsRegular.mapPin,
                          size: 14,
                          color: PetTokens.plumAccentOf(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          address,
                          style: PetTokens.bodyThemed(
                            context,
                            12,
                            color: PetTokens.plumAccentOf(context),
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: PetTokens.isDark(context)
                          ? const Color(0xFF2C2232)
                          : const Color(0xFFEFE3EC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIconsRegular.clock,
                          size: 14,
                          color: PetTokens.plumAccentOf(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateFormatted,
                          style: PetTokens.bodyThemed(
                            context,
                            12,
                            color: PetTokens.plumAccentOf(context),
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Señas particulares / Circunstancias
              if (traits != null && traits!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Se\u00F1as: ${traits!.trim()}',
                  style: PetTokens.bodyThemed(context, 13, color: PetTokens.inkOf(context)),
                ),
              ],
              if (description != null && description!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description!.trim(),
                  style: PetTokens.bodyThemed(context, 13, color: PetTokens.mutedOf(context)),
                ),
              ],
            ],
          ),
        ),

        // Cinta adhesiva superior izquierda
        Positioned(
          top: -8,
          left: 24,
          child: Transform.rotate(
            angle: -0.1,
            child: Container(
              width: 70,
              height: 20,
              color: PetTokens.clay.withValues(alpha: 0.45),
            ),
          ),
        ),

        // Cinta adhesiva superior derecha
        Positioned(
          top: -8,
          right: 24,
          child: Transform.rotate(
            angle: 0.08,
            child: Container(
              width: 70,
              height: 20,
              color: PetTokens.clay.withValues(alpha: 0.45),
            ),
          ),
        ),

        // Sello circular inclinado (stampx de Paso6Publicar.dc.html)
        Positioned(
          right: 12,
          top: 170,
          child: Transform.rotate(
            angle: -0.24,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: posterColor, width: 3),
                color: PetTokens.isDark(context) ? PetTokens.surfaceHigherOf(context) : PetTokens.surface.withValues(alpha: 0.88),
              ),
              alignment: Alignment.center,
              child: Text(
                stampText,
                textAlign: TextAlign.center,
                style: PetTokens.body(
                  10,
                  color: posterColor,
                  weight: FontWeight.w900,
                  letterSpacing: 0.08 * 10,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
