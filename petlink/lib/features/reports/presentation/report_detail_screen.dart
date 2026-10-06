import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/pet_colors.dart';
import '../../../core/theme/pet_spacing.dart';
import '../../../core/theme/pet_radius.dart';
import '../../../design_system/buttons/pet_button.dart';
import '../../../design_system/badges/status_badge.dart';
import '../../../shared/models/pet_report.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../providers/reports_providers.dart';

class ReportDetailScreen extends ConsumerWidget {
  final String reportId;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportByIdProvider(reportId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de mascota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) {
          if (report == null) {
            return _buildNotFound(context);
          }

          return _buildReportDetail(context, report);
        },
        loading: () => _buildLoading(context),
        error: (Object _, StackTrace _) => ErrorState(
          title: 'No pudimos cargar el reporte',
          subtitle: 'Verifica tu conexión e intenta nuevamente.',
          onRetry: () => ref.invalidate(reportByIdProvider(reportId)),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return const EmptyState(
      icon: Icons.description,
      title: 'No encontramos este reporte.',
      subtitle:
          'El reporte puede haber sido eliminado o el ID es incorrecto.',
    );
  }

  Widget _buildLoading(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(PetSpacing.lg),
      children: [
        _buildSkeletonImage(),
        const SizedBox(height: PetSpacing.lg),
        _buildSkeletonText(),
        const SizedBox(height: PetSpacing.md),
        _buildSkeletonText(),
        const SizedBox(height: PetSpacing.lg),
        _buildSkeletonText(),
      ],
    );
  }

  Widget _buildSkeletonImage() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: PetColors.border,
        borderRadius: PetRadius.lgAll,
      ),
    );
  }

  Widget _buildSkeletonText() {
    return Container(
      height: 16,
      width: double.infinity,
      decoration: BoxDecoration(
        color: PetColors.border,
        borderRadius: PetRadius.smAll,
      ),
    );
  }

  Widget _buildReportDetail(
    BuildContext context,
    dynamic report,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(PetSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhotoSection(context, report),
          const SizedBox(height: PetSpacing.lg),
          _buildHeaderSection(context, report),
          const SizedBox(height: PetSpacing.lg),
          _buildLocationSection(context, report),
          const SizedBox(height: PetSpacing.lg),
          _buildTimeSection(context, report),
          const SizedBox(height: PetSpacing.lg),
          const SectionHeader(
            title: 'Rasgos y señas particulares',
          ),
          const SizedBox(height: PetSpacing.md),
          _buildTraitsSection(context),
          const SizedBox(height: PetSpacing.lg),
          const SectionHeader(
            title: '¿Cómo ocurrió?',
          ),
          const SizedBox(height: PetSpacing.md),
          _buildDescriptionSection(context, report),
          const SizedBox(height: PetSpacing.lg),
          const SectionHeader(
            title: 'Última ubicación',
          ),
          const SizedBox(height: PetSpacing.md),
          _buildMapPlaceholder(context),
          const SizedBox(height: PetSpacing.lg),
          _buildCTASection(context),
          const SizedBox(height: PetSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(
    BuildContext context,
    dynamic report,
  ) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: PetColors.primarySoft,
        borderRadius: PetRadius.lgAll,
      ),
      child: report.pet.primaryPhotoUrl != null
          ? ClipRRect(
              borderRadius: PetRadius.lgAll,
              child: Image.network(
                report.pet.primaryPhotoUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, _, _) => _buildPlaceholderPhoto(),
              ),
            )
          : _buildPlaceholderPhoto(),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Center(
      child: Icon(
        Icons.pets,
        size: 64,
        color: PetColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    dynamic report,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StatusBadge(
              status: report.type == ReportType.lost
                  ? PetStatus.lost
                  : PetStatus.found,
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: PetSpacing.md),
        Text(
          report.pet.name,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: PetSpacing.xs),
        Text(
          report.pet.breed,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: PetSpacing.xs),
        Text(
          '${report.pet.sex} · ${report.pet.age}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: PetSpacing.xs),
        Text(
          '${report.pet.size} · 28 kg',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLocationSection(
    BuildContext context,
    dynamic report,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 20,
              color: PetColors.textSecondary,
            ),
            const SizedBox(width: PetSpacing.xs),
            Expanded(
              child: Text(
                'Última vez vista en ${report.address.split(',').first}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: PetSpacing.xs),
        Row(
          children: [
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                'Pasto, Nariño',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSection(
    BuildContext context,
    dynamic report,
  ) {
    return Row(
      children: [
        const Icon(
          Icons.access_time,
          size: 20,
          color: PetColors.textSecondary,
        ),
        const SizedBox(width: PetSpacing.xs),
        Text(
          'Hace 3 horas',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildTraitsSection(BuildContext context) {
    final traits = [
      ('Color', 'Dorado suave'),
      ('Collar', 'Cuero marrón con hebilla dorada'),
      ('Seña física', 'Mancha blanca en el pecho'),
      ('Temperamento', 'Dócil, responde a su nombre'),
    ];

    return Column(
      children: traits.map((trait) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: PetSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  trait.$1,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: PetColors.textSecondary,
                      ),
                ),
              ),
              const SizedBox(width: PetSpacing.md),
              Expanded(
                child: Text(
                  trait.$2,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescriptionSection(
    BuildContext context,
    dynamic report,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PetSpacing.md),
      decoration: BoxDecoration(
        color: PetColors.surface,
        borderRadius: PetRadius.lgAll,
        border: Border.all(
          color: PetColors.border,
        ),
      ),
      child: Text(
        report.description,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildMapPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: PetColors.background,
        borderRadius: PetRadius.lgAll,
        border: Border.all(
          color: PetColors.border,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 48,
              color: PetColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: PetSpacing.md),
            Text(
              'Mapa de la zona',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: PetSpacing.xs),
            Text(
              'Aquí se mostrará la última ubicación conocida',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Viste a Luna o tienes una pista?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: PetSpacing.md),
        PetButton(
          label: 'Reportar avistamiento',
          onPressed: () {},
          icon: Icons.add_location,
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(PetSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: const Text('Compartir'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: PetSpacing.md,
                  ),
                ),
              ),
            ),
            const SizedBox(width: PetSpacing.md),
            Expanded(
              child: PetButton(
                label: 'Contactar',
                onPressed: () {},
                icon: Icons.phone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}