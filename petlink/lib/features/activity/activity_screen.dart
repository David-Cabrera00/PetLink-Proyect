import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/theme/pet_radius.dart';
import '../../core/theme/pet_spacing.dart';
import '../../shared/models/activity_item.dart';
import 'providers/activity_providers.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final activityAsync = ref.watch(activityProvider);
    final unreadCount = ref.watch(unreadActivityCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navigationActivity),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: PetSpacing.sm),
              child: TextButton.icon(
                onPressed: () =>
                    ref.read(activityProvider.notifier).markAllAsRead(),
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: Text(
                  l10n.activityMarkAllAsRead,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      body: activityAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(PetSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 44,
                  color: cs.error,
                ),
                const SizedBox(height: PetSpacing.md),
                Text(
                  l10n.activityError,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: PetSpacing.md),
                FilledButton.tonal(
                  onPressed: () =>
                      ref.read(activityProvider.notifier).refresh(),
                  child: Text(l10n.activityRetry),
                ),
              ],
            ),
          ),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.read(activityProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              PetSpacing.lg,
              PetSpacing.md,
              PetSpacing.lg,
              PetSpacing.xxl,
            ),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PetSpacing.xl),
              if (items.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PetSpacing.xl,
                    vertical: PetSpacing.xxl,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: PetRadius.xlAll,
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIconsRegular.bellSlash,
                          size: 40,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: PetSpacing.md),
                        Text(
                          l10n.activityEmpty,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...items.map((item) => _buildItem(context, ref, item, l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    WidgetRef ref,
    ActivityItem item,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isUnread = !item.isRead;

    // Colores e icono según el tipo de actividad
    final (IconData icon, Color iconColor, Color iconBg) = switch (item.type) {
      'sighting' => (
        PhosphorIconsFill.binoculars,
        cs.primary,
        cs.primary.withValues(alpha: 0.12),
      ),
      'report' => (
        PhosphorIconsFill.pawPrint,
        cs.secondary,
        cs.secondary.withValues(alpha: 0.12),
      ),
      'match' => (
        PhosphorIconsFill.sparkle,
        const Color(0xFFE65100),
        const Color(0xFFFFF3E0),
      ),
      _ => (
        PhosphorIconsFill.bell,
        cs.primary,
        cs.primary.withValues(alpha: 0.12),
      ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: PetSpacing.md),
      child: Material(
        color: isUnread
            ? cs.primaryContainer.withValues(alpha: 0.28)
            : cs.surface,
        borderRadius: PetRadius.xlAll,
        child: InkWell(
          borderRadius: PetRadius.xlAll,
          onTap: () {
            if (isUnread) {
              ref.read(activityProvider.notifier).markAsRead(item.id);
            }
            context.push('/reports/${item.targetReportId}');
          },
          child: Container(
            padding: const EdgeInsets.all(PetSpacing.md),
            decoration: BoxDecoration(
              borderRadius: PetRadius.xlAll,
              border: Border.all(
                color: isUnread
                    ? cs.primary.withValues(alpha: 0.45)
                    : cs.outlineVariant.withValues(alpha: 0.35),
                width: isUnread ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono del tipo de evento
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: PetRadius.lgAll,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: PetSpacing.md),

                // Contenido textual
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              _localizedTitle(context, item),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: isUnread
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: PetSpacing.xs),
                          Text(
                            _formatRelativeTime(item.createdAt, l10n),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: PetSpacing.xs),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: PetSpacing.xs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest.withValues(
                                alpha: 0.6,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _localizedStatus(item.status, l10n),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: PetSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.activityUnread,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (item.body != null &&
                          item.body!.trim().isNotEmpty) ...[
                        const SizedBox(height: PetSpacing.xs),
                        Text(
                          item.body!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime time, AppLocalizations l10n) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return l10n.activityTimeJustNow;
    if (diff.inMinutes < 60) return l10n.activityTimeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.activityTimeHoursAgo(diff.inHours);
    return l10n.activityTimeDaysAgo(diff.inDays);
  }

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

  String _localizedStatus(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'active':
        return l10n.activityStatusActive;
      case 'recovered':
        return l10n.activityStatusRecovered;
      case 'possible_match':
      case 'possiblematch':
        return l10n.activityStatusPossibleMatch;
      case 'closed':
        return l10n.activityStatusClosed;
      default:
        return l10n.activityStatusUnknown;
    }
  }
}
