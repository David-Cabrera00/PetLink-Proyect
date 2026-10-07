import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/pet_theme.dart';
import 'router.dart';
import '../features/profile/providers/theme_mode_provider.dart';

class PetLinkApp extends ConsumerWidget {
  const PetLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return ProviderScope(
      child: MaterialApp.router(
        title: 'PetLink',
        debugShowCheckedModeBanner: false,
        theme: PetTheme.light,
        darkTheme: PetTheme.dark,
        themeMode: themeMode,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
