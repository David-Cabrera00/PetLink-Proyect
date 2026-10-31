import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../core/theme/pet_theme.dart';
import 'router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/profile/providers/locale_provider.dart';
import '../features/profile/providers/theme_mode_provider.dart';

class PetLinkApp extends ConsumerWidget {
  const PetLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'PetLink',
      debugShowCheckedModeBanner: false,
      theme: PetTheme.light,
      darkTheme: PetTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) =>
          _SessionExpiredListener(child: child ?? const SizedBox.shrink()),
      routerConfig: router,
    );
  }
}

/// Muestra un aviso cuando el refresh token deja de ser válido y la sesión
/// se cierra automáticamente.
class _SessionExpiredListener extends ConsumerStatefulWidget {
  const _SessionExpiredListener({required this.child});

  final Widget child;

  @override
  ConsumerState<_SessionExpiredListener> createState() =>
      _SessionExpiredListenerState();
}

class _SessionExpiredListenerState
    extends ConsumerState<_SessionExpiredListener> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.user != null) {
        _shown = false;
        return;
      }
      if (!next.sessionExpired || _shown) return;
      _shown = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        if (l10n == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.authSessionExpired)));
        ref.read(authProvider.notifier).acknowledgeSessionExpired();
      });
    });

    return widget.child;
  }
}
