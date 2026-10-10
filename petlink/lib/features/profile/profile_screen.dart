import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../../core/theme/pet_colors.dart';
import '../../core/theme/pet_spacing.dart';
import '../../core/theme/pet_radius.dart';
import '../../design_system/buttons/pet_button.dart';
import '../auth/providers/auth_provider.dart';
import '../../features/profile/providers/locale_provider.dart';
import '../../features/profile/providers/theme_mode_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

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
          Text(
            l10n.profileTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: PetSpacing.sm),
          Text(
            l10n.profileDescription,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PetSpacing.xl),
          if (user != null) ...[
            _buildUserSection(context, user),
            const SizedBox(height: PetSpacing.xl),
          ],
          _buildAppearanceSection(context, ref, themeMode),
          const SizedBox(height: PetSpacing.xl),
          _buildLanguageSection(context, ref, locale),
          if (user != null) ...[
            const SizedBox(height: PetSpacing.xl),
            PetButton(
              label: l10n.profileLogout,
              variant: PetButtonVariant.outline,
              icon: Icons.logout,
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserSection(BuildContext context, AuthUser user) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PetSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: PetRadius.lgAll,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary,
            child: Icon(Icons.person, color: theme.colorScheme.onPrimary),
          ),
          const SizedBox(width: PetSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PetSpacing.xs),
                Text(user.email, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      (const Locale('es'), l10n.languageSpanish),
      (const Locale('en'), l10n.languageEnglish),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.language,
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
              for (var index = 0; index < options.length; index++) ...[
                InkWell(
                  onTap: () => ref
                      .read(localeProvider.notifier)
                      .setLocale(options[index].$1),
                  borderRadius: PetRadius.lgAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PetSpacing.lg,
                      vertical: PetSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            options[index].$2,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: currentLocale == options[index].$1
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                              width: 2,
                            ),
                            color: currentLocale == options[index].$1
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                          ),
                          child: currentLocale == options[index].$1
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < options.length - 1) _buildDivider(context),
              ],
            ],
          ),
        ),
      ],
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
          l10n.appearance,
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
                l10n.themeSystemDescription,
              ),
              _buildDivider(context),
              _buildThemeOption(
                context,
                ref,
                ThemeMode.light,
                currentMode,
                Icons.light_mode,
                l10n.themeLight,
                l10n.themeLightDescription,
              ),
              _buildDivider(context),
              _buildThemeOption(
                context,
                ref,
                ThemeMode.dark,
                currentMode,
                Icons.dark_mode,
                l10n.themeDark,
                l10n.themeDarkDescription,
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
