import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
import '../../radar/providers/radar_providers.dart';
import '../../explore/providers/explore_providers.dart';

class ReportDetailScreen extends ConsumerWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final reportAsync = ref.watch(reportByIdProvider(reportId));
    final isSaved = ref.watch(savedReportIdsProvider).contains(reportId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportDetailTitle),
        actions: [
          IconButton(
            icon: Icon(
              isSaved
                  ? PhosphorIconsFill.bookmark
                  : PhosphorIconsRegular.bookmark,
            ),
            onPressed: () {
              final saved = {...ref.read(savedReportIdsProvider)};
              if (!saved.add(reportId)) saved.remove(reportId);
              ref.read(savedReportIdsProvider.notifier).state = saved;
            },
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.shareNetwork),
            onPressed: () async {
              await SharePlus.instance.share(
                ShareParams(text: 'https://petlink.app/reports/$reportId'),
              );
            },
          ),
          if (reportAsync.valueOrNull?.isOwner == true)
            IconButton(
              icon: const Icon(PhosphorIconsRegular.trash),
              tooltip: 'Eliminar reporte',
              onPressed: () => _confirmDelete(context, ref),
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
          title: l10n.reportDetailLoadError,
          subtitle: l10n.connectionRetryDescription,
          onRetry: () => ref.invalidate(reportByIdProvider(reportId)),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, ref),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: PhosphorIconsRegular.fileText,
      title: l10n.reportDetailNotFound,
      subtitle: l10n.reportDetailNotFoundDescription,
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

  Widget _buildReportDetail(BuildContext context, dynamic report) {
    final l10n = AppLocalizations.of(context)!;
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
          SectionHeader(title: l10n.reportDetailTraits),
          const SizedBox(height: PetSpacing.md),
          _buildTraitsSection(context, report),
          const SizedBox(height: PetSpacing.lg),
          SectionHeader(title: l10n.reportDetailHowItHappened),
          const SizedBox(height: PetSpacing.md),
          _buildDescriptionSection(context, report),
          const SizedBox(height: PetSpacing.lg),
          SectionHeader(title: l10n.reportDetailLastLocation),
          const SizedBox(height: PetSpacing.md),
          _buildMapPlaceholder(context, report),
          const SizedBox(height: PetSpacing.lg),
          _buildCTASection(context, report),
          const SizedBox(height: PetSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context, dynamic report) {
    return Container(
      width: double.infinity,
      height: 270,
      decoration: BoxDecoration(
        color: PetColors.primarySoft,
        borderRadius: PetRadius.lgAll,
        boxShadow: [
          BoxShadow(
            color: PetColors.primary.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
        PhosphorIconsRegular.pawPrint,
        size: 64,
        color: PetColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, dynamic report) {
    final l10n = AppLocalizations.of(context)!;
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
        Text(report.pet.name, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: PetSpacing.xs),
        Text(report.pet.breed, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: PetSpacing.xs),
        Text(
          '${report.pet.sex} · ${report.pet.age}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: PetSpacing.xs),
        Text(
          l10n.reportDetailWeight(report.pet.size),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context, dynamic report) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              PhosphorIconsRegular.mapPin,
              size: 20,
              color: PetColors.textSecondary,
            ),
            const SizedBox(width: PetSpacing.xs),
            Expanded(
              child: Text(
                l10n.reportDetailLastSeenAt(report.address.split(',').first),
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
                l10n.reportDetailRegion,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSection(BuildContext context, dynamic report) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        const Icon(
          PhosphorIconsRegular.clock,
          size: 20,
          color: PetColors.textSecondary,
        ),
        const SizedBox(width: PetSpacing.xs),
        Text(
          l10n.exploreHoursAgo,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildTraitsSection(BuildContext context, dynamic report) {
    final l10n = AppLocalizations.of(context)!;
    const unspecified = 'No especificado';
    final traits = [
      (l10n.reportDetailColor, report.pet.color.trim().isEmpty ? unspecified : report.pet.color),
      (l10n.reportDetailPhysicalMark, report.traits.trim().isEmpty ? unspecified : report.traits),
    ];

    return Column(
      children: traits.map((trait) {
        return Padding(
          padding: const EdgeInsets.only(bottom: PetSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  trait.$1,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildDescriptionSection(BuildContext context, dynamic report) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PetSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: PetRadius.lgAll,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        report.description,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildMapPlaceholder(BuildContext context, dynamic report) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => _openMap(report),
      child: Container(
        width: double.infinity,
        height: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: PetRadius.lgAll,
          border: Border.all(color: PetColors.border),
        ),
        child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(report.latitude, report.longitude),
              initialZoom: 13,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.petlink.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(report.latitude, report.longitude),
                    width: 48,
                    height: 48,
                    child: Icon(
                      PhosphorIconsFill.mapPin,
                      size: 42,
                      color: PetColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: PetSpacing.sm,
            right: PetSpacing.sm,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface
                    .withValues(alpha: 0.9),
                borderRadius: PetRadius.smAll,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PetSpacing.sm,
                  vertical: PetSpacing.xs,
                ),
                child: Text(
                  l10n.reportDetailMapTitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: PetSpacing.xs,
            right: PetSpacing.sm,
            child: Text(
              '\u00A9 OpenStreetMap contributors',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                backgroundColor: Theme.of(context).colorScheme.surface
                    .withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildCTASection(BuildContext context, report) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportDetailSightingPrompt(report.pet.name),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: PetSpacing.md),
        PetButton(
          label: l10n.reportDetailReportSighting,
          onPressed: () => context.push('/reports/$reportId/sighting'),
          icon: PhosphorIconsRegular.mapPinPlus,
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(PetSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await SharePlus.instance.share(
                    ShareParams(text: 'https://petlink.app/reports/$reportId'),
                  );
                },
                icon: const Icon(PhosphorIconsRegular.shareNetwork),
                label: Text(l10n.shareAction),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: PetSpacing.md),
                ),
              ),
            ),
            const SizedBox(width: PetSpacing.md),
            Expanded(
              child: PetButton(
                label: l10n.contactAction,
                onPressed: () => _contactOwner(context, ref),
                icon: PhosphorIconsRegular.phone,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMap(dynamic report) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${report.latitude},${report.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _contactOwner(BuildContext context, WidgetRef ref) async {
    final report = await ref.read(reportByIdProvider(reportId).future);
    final email = report?.ownerEmail;
    if (email == null || email.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay datos de contacto disponibles')),
        );
      }
      return;
    }
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Sobre tu reporte en PetLink'},
    );
    if (!await launchUrl(uri) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el correo')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar reporte'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(petReportRepositoryProvider).deleteReport(reportId);
      ref.invalidate(nearbyReportsProvider);
      ref.invalidate(myReportsProvider);
      ref.invalidate(exploreReportsProvider);
      if (context.mounted) context.go('/reports');
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $error')));
    }
  }
}
