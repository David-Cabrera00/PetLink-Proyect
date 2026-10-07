import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/pet_theme.dart';
import 'router.dart';

class PetLinkApp extends StatelessWidget {
  const PetLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'PetLink',
        debugShowCheckedModeBanner: false,
        theme: PetTheme.light,
        darkTheme: PetTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
