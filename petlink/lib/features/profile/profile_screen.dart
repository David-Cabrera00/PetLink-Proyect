import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../core/theme/pet_colors.dart';
import '../../core/theme/pet_spacing.dart';
import '../../core/theme/pet_radius.dart';
import '../../features/profile/providers/theme_mode_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navigationProfile)),
      body: ListView(
        padding: const EdgeInsets.all(PetSpacing.lg),
        children: [
          Icon(
            Icons.person,
            size: 64,
            color: PetColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: PetSpacing.lg),
          Text('Mi Perfil', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: PetSpacing.sm),
          Text(
            'Gestiona tu información personal y configuración.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PetSpacing.xl),
          _buildAppearanceSection(context, ref, themeMode),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apariencia',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: PetSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: PetRadius.lgAll,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              _buildThemeOption(
                context,
                ref,
                ThemeMode.system,
                currentMode,
                Icons.settings_brightness,
                l10n.themeSystem,
                'Usa la configuración del dispositivo',
              ),
              _buildDivider(context),
              _buildThemeOption(
                context,
                ref,
                ThemeMode.light,
                currentMode,
                Icons.light_mode,
                l10n.themeLight,
                'Tema claro siempre',
              ),
              _buildDivider(context),
              _buildThemeOption(
                context,
                ref,
                ThemeMode.dark,
                currentMode,
                Icons.dark_mode,
                l10n.themeDark,
                'Tema oscuro siempre',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: PetSpacing.lg,
      endIndent: PetSpacing.lg,
      color: Theme.of(context).dividerColor,
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
    ThemeMode currentMode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = currentMode == mode;
    return InkWell(
      onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(mode),
      borderRadius: PetRadius.lgAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PetSpacing.lg,
          vertical: PetSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(PetSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: PetRadius.mdAll,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: PetSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: PetSpacing.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
