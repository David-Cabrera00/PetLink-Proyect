import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petlink/l10n/app_localizations.dart';

import '../core/theme/pet_theme.dart';
import 'router.dart';
import '../features/profile/providers/locale_provider.dart';
import '../features/profile/providers/theme_mode_provider.dart';

class PetLinkApp extends ConsumerWidget {
  const PetLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return ProviderScope(
      child: MaterialApp.router(
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
        routerConfig: AppRouter.router,
      ),
    );
  }
}
