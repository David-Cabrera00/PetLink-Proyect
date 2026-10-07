import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../design_system/badges/status_badge.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../shared/models/pet_report.dart';
import '../../radar/providers/radar_providers.dart';
import '../providers/report_draft_provider.dart';

class ReportReviewScreen extends ConsumerWidget {
  const ReportReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(reportDraftProvider);
    final isLost = draft.reportType == ReportType.lost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisa tu reporte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/report/new/details'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PetSpacing.lg),
          child: Column(
            children: [
              _buildStepIndicator(context, 6, 6),
              const SizedBox(height: PetSpacing.xl),
              Text(
                'Revisa tu reporte',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: PetSpacing.xs),
              Text(
                'Verifica que toda la información sea correcta antes de publicar.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: PetSpacing.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        context,
                        'Tipo de reporte',
                        Row(
                          children: [
                            StatusBadge(
                              status: isLost ? PetStatus.lost : PetStatus.found,
                            ),
                            const SizedBox(width: PetSpacing.md),
                            Text(
                              isLost ? 'Perdida' : 'Encontrada',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      _buildSection(
                        context,
                        'Fotos',
                        draft.photos.isEmpty
                            ? Text(
                                'Sin fotos',
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                            : Wrap(
                                spacing: PetSpacing.sm,
                                runSpacing: PetSpacing.sm,
                                children: draft.photos
                                    .map((p) => _buildPhotoThumb(context, p))
                                    .toList(),
                              ),
                      ),
                      _buildSection(
                        context,
                        'Nombre',
                        Text(
                          draft.name.isEmpty ? '—' : draft.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _buildSection(
                        context,
                        'Especie',
                        Text(
                          draft.species,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _buildSection(
                        context,
                        'Raza',
                        Text(
                          draft.breed,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _buildSection(
                        context,
                        'Sexo',
                        Text(
                          draft.sex,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _buildSection(
                        context,
                        'Edad',
                        Text(
                          draft.age,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _buildSection(
                        context,
                        'Tamaño',
                        Text(
                          draft.size,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _buildSection(
                        context,
                        'Color',
                        Text(
                          draft.color,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _buildSection(
                        context,
                        'Ubicación',
                        Text(
                          draft.address,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _buildSection(
                        context,
                        isLost ? 'Última vez vista' : 'Fecha de hallazgo',
                        Text(
                          draft.lastSeenAt != null
                              ? _formatDateTime(draft.lastSeenAt!)
                              : '—',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _buildSection(
                        context,
                        'Señas particulares',
                        Text(
                          draft.traits.isEmpty ? '—' : draft.traits,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _buildSection(
                        context,
                        '¿Qué ocurrió?',
                        Text(
                          draft.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      if (draft.reportType == ReportType.found) ...[
                        _buildSection(
                          context,
                          '¿La mascota está contigo?',
                          Text(
                            draft.isPetWithFinder == true
                                ? 'Sí'
                                : draft.isPetWithFinder == false
                                ? 'No'
                                : '—',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: PetSpacing.lg),
              _buildActionButtons(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String label, Widget value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: PetColors.textSecondary,
          ),
        ),
        const SizedBox(height: PetSpacing.xs),
        value,
        const SizedBox(height: PetSpacing.md),
      ],
    );
  }

  Widget _buildPhotoThumb(BuildContext context, String url) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: PetRadius.mdAll,
        border: Border.all(color: PetColors.border),
      ),
      child: ClipRRect(
        borderRadius: PetRadius.mdAll,
        child: url.startsWith('http')
            ? Image.network(
                url,
                fit: BoxFit.cover,
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: PetColors.background,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 24,
          color: PetColors.textSecondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context, int current, int total) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index < current;
        final isCurrent = index == current - 1;
        final children = <Widget>[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: isActive || isCurrent
                    ? PetColors.primary
                    : PetColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ];
        if (index < total - 1) {
          children.add(const SizedBox(width: PetSpacing.sm));
        }
        return Expanded(child: Row(children: children));
      }),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        PetButton(
          label: 'Publicar reporte',
          onPressed: () => _publishReport(context, ref),
          icon: Icons.publish,
        ),
        const SizedBox(height: PetSpacing.md),
        OutlinedButton(
          onPressed: () => context.go('/report/new/details'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: PetSpacing.md),
            minimumSize: const Size(double.infinity, 52),
          ),
          child: const Text('Volver a editar'),
        ),
      ],
    );
  }

  void _publishReport(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!context.mounted) return;
    Navigator.pop(context);

    final notifier = ref.read(reportDraftProvider.notifier);
    final draft = ref.read(reportDraftProvider);

    try {
      final repository = ref.read(petReportRepositoryProvider);
      final _ = await repository.createReport(draft);

      if (context.mounted) {
        notifier.clearDraft();
        context.go('/report/new/published');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar: $e'),
            backgroundColor: PetColors.lost,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
