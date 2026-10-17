import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../core/theme/pet_radius.dart';
import '../../core/theme/pet_spacing.dart';
import '../../core/theme/pet_theme_extension.dart';
import '../../shared/models/activity_item.dart';
import 'providers/activity_providers.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final activity = ref.watch(activityProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navigationActivity)),
      body: activity.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_localized(context, 'No se pudo cargar la actividad', 'Could not load activity')),
              const SizedBox(height: PetSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(activityProvider),
                child: Text(_localized(context, 'Reintentar', 'Retry')),
              ),
            ],
          ),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(activityProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              PetSpacing.lg,
              PetSpacing.md,
              PetSpacing.lg,
              PetSpacing.xxl,
            ),
            children: [
              Text(
                l10n.activityRecent,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: PetSpacing.xs),
              Text(
                l10n.activityDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: PetSpacing.xl),
              if (items.isEmpty)
                Padding(
                  padding: EdgeInsets.all(PetSpacing.xl),
                  child: Center(child: Text(_localized(context, 'Todavía no hay actividad', 'There is no activity yet'))),
                )
              else
                ...items.map((item) => _buildItem(context, item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, ActivityItem item) {
    final theme = Theme.of(context);
    final accent = PetThemeExtension.of(context).accent;

    return InkWell(
      borderRadius: PetRadius.xlAll,
      onTap: () => context.go('/reports/${item.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: PetSpacing.md),
        padding: const EdgeInsets.all(PetSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: PetRadius.xlAll,
          border: Border.all(color: accent.withValues(alpha: 0.24)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: PetRadius.lgAll,
              ),
              child: Icon(
                PhosphorIconsFill.checkCircle,
                color: accent,
                size: 23,
              ),
            ),
            const SizedBox(width: PetSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _localizedTitle(context, item),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: PetSpacing.xs),
                  Text(
                    _localized(
                      context,
                      'Estado: ${_localizedStatus(item.status, false)}',
                      'Status: ${_localizedStatus(item.status, true)}',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

  String _localized(BuildContext context, String spanish, String english) =>
      Localizations.localeOf(context).languageCode == 'en' ? english : spanish;

  String _localizedTitle(BuildContext context, ActivityItem item) {
    final title = item.title;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    if (!isEnglish) return title;
    if (title.startsWith('Reporte de ')) {
      return 'Report of ${title.substring('Reporte de '.length)}';
    }
    if (title.startsWith('Nuevo avistamiento de ')) {
      return 'New sighting of ${title.substring('Nuevo avistamiento de '.length)}';
    }
    return title;
  }

  String _localizedStatus(String status, bool english) {
    switch (status.toLowerCase()) {
      case 'active':
        return english ? 'Active' : 'Activo';
      case 'recovered':
        return english ? 'Recovered' : 'Recuperado';
      case 'possible_match':
      case 'possiblematch':
        return english ? 'Possible match' : 'Posible coincidencia';
      case 'closed':
        return english ? 'Closed' : 'Cerrado';
      default:
        return english ? 'Unknown status' : 'Sin estado';
    }
  }
}
