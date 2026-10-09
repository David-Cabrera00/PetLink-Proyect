import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('es'));

  void setLocale(Locale locale) {
    if (locale.languageCode != 'es' && locale.languageCode != 'en') {
      return;
    }

    state = locale;
  }
}
