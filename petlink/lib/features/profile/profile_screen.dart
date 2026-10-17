import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

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
            PhosphorIconsRegular.userCircle,
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
            _buildUserSection(context, ref, user),
            const SizedBox(height: PetSpacing.xl),
          ],
          _buildMyReportsTile(context),
          const SizedBox(height: PetSpacing.xl),
          _buildAppearanceSection(context, ref, themeMode),
          const SizedBox(height: PetSpacing.xl),
          _buildLanguageSection(context, ref, locale),
          if (user != null) ...[
            const SizedBox(height: PetSpacing.xl),
            PetButton(
              label: l10n.profileLogout,
              variant: PetButtonVariant.outline,
              icon: PhosphorIconsRegular.signOut,
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMyReportsTile(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: PetRadius.lgAll,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: PetRadius.lgAll,
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: PetRadius.lgAll),
          leading: Container(
            padding: const EdgeInsets.all(PetSpacing.sm),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: PetRadius.mdAll,
            ),
            child: Icon(PhosphorIconsRegular.pawPrint, color: cs.primary),
          ),
          title: Text(
            l10n.reportsTitle,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'Administra y consulta tus mascotas reportadas',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          trailing: Icon(
            PhosphorIconsRegular.caretRight,
            color: cs.onSurfaceVariant,
          ),
          onTap: () => context.go('/reports/mine'),
        ),
      ),
    );
  }

  Widget _buildUserSection(BuildContext context, WidgetRef ref, AuthUser user) {
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
          Stack(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.primary,
                backgroundImage: user.avatarUrl == null ? null : NetworkImage(user.avatarUrl!),
                child: user.avatarUrl == null
                    ? Icon(PhosphorIconsFill.user, color: theme.colorScheme.onPrimary)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Tooltip(
                  message: 'Cambiar foto',
                  child: Material(
                    color: theme.colorScheme.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _pickAvatar(context, ref),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          PhosphorIconsRegular.camera,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                const SizedBox(height: PetSpacing.sm),
                TextButton.icon(
                  onPressed: () => _editName(context, ref, user.name),
                  icon: const Icon(PhosphorIconsRegular.pencilSimple, size: 16),
                  label: const Text('Editar nombre'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 800);
    if (image == null) return;
    try {
      await ref.read(authProvider.notifier).uploadAvatar(image.path);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto de perfil actualizada')));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo actualizar la foto: $error')));
    }
  }

  Future<void> _editName(BuildContext context, WidgetRef ref, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cambiar nombre'),
        content: TextField(controller: controller, autofocus: true, textCapitalization: TextCapitalization.words, maxLength: 60),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Guardar')),
        ],
      ),
    );
    if (name == null || name.length < 2 || !context.mounted) return;
    try {
      await ref.read(authProvider.notifier).updateName(name);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre actualizado')));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo actualizar el nombre: $error')));
    }
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
                                  PhosphorIconsBold.check,
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
                PhosphorIconsRegular.slidersHorizontal,
                l10n.themeSystem,
                l10n.themeSystemDescription,
              ),
              _buildDivider(context),
              _buildThemeOption(
                context,
                ref,
                ThemeMode.light,
                currentMode,
                PhosphorIconsRegular.sun,
                l10n.themeLight,
                l10n.themeLightDescription,
              ),
              _buildDivider(context),
              _buildThemeOption(
                context,
                ref,
                ThemeMode.dark,
                currentMode,
                PhosphorIconsRegular.moon,
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
                PhosphorIconsFill.checkCircle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
