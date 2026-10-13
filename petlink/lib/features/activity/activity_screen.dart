import 'package:flutter/material.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/theme/pet_radius.dart';
import '../../core/theme/pet_spacing.dart';
import '../../core/theme/pet_theme_extension.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extension = PetThemeExtension.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navigationActivity)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(PetSpacing.lg, PetSpacing.md, PetSpacing.lg, PetSpacing.xxl),
        children: [
          Text('Novedades para ti', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: PetSpacing.xs),
          Text('Mantente al día con tus reportes y coincidencias.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: PetSpacing.xl),
          _buildItem(context, PhosphorIconsFill.diamond, extension.match, 'Posible coincidencia encontrada', 'Luna · Las características coinciden con un reporte cercano.', 'Hace 3 h', true),
          _buildItem(context, PhosphorIconsFill.eye, theme.colorScheme.primary, 'Nuevo avistamiento', 'Alguien consultó el reporte de Luna.', 'Ayer'),
          _buildItem(context, PhosphorIconsFill.checkCircle, extension.found, 'Reporte actualizado', 'Tu reporte sigue activo y visible para la comunidad.', 'Hace 2 días'),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, Color color, String title, String subtitle, String time, [bool highlighted = false]) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: PetSpacing.md),
      padding: const EdgeInsets.all(PetSpacing.md),
      decoration: BoxDecoration(
        color: highlighted ? color.withValues(alpha: 0.08) : theme.colorScheme.surface,
        borderRadius: PetRadius.xlAll,
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: PetRadius.lgAll), child: Icon(icon, color: color, size: 23)),
          const SizedBox(width: PetSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
              Text(time, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ]),
            const SizedBox(height: PetSpacing.xs),
            Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.35)),
          ])),
        ],
      ),
    );
  }
}
