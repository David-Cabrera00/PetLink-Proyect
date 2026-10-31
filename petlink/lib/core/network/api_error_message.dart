import 'package:petlink/l10n/app_localizations.dart';

import 'api_client.dart';

/// Traduce errores de red/API a mensajes que se puedan mostrar al usuario.
String apiErrorMessage(
  AppLocalizations l10n,
  Object error, {
  bool isLogin = false,
}) {
  if (error is ApiException) {
    switch (error.kind) {
      case ApiErrorKind.network:
        return l10n.errorNoConnection;
      case ApiErrorKind.timeout:
        return l10n.errorTimeout;
      case ApiErrorKind.http:
        break;
    }

    if (error.statusCode == 401) {
      return isLogin ? l10n.authInvalidCredentials : l10n.authSessionExpired;
    }
    if (error.statusCode == 409) return l10n.authEmailInUse;
    if (error.statusCode == 429) return l10n.errorTooManyRequests;
    if (error.statusCode >= 500) return l10n.errorServer;
  }
  return l10n.errorGeneric;
}
