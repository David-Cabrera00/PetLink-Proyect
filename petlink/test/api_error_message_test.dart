import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petlink/core/network/api_client.dart';
import 'package:petlink/core/network/api_error_message.dart';
import 'package:petlink/l10n/app_localizations.dart';

void main() {
  group('apiErrorMessage - Mapeo de errores tipados a mensajes de usuario', () {
    late AppLocalizations l10nEs;
    late AppLocalizations l10nEn;

    setUpAll(() {
      l10nEs = lookupAppLocalizations(const Locale('es'));
      l10nEn = lookupAppLocalizations(const Locale('en'));
    });

    test('Error de red -> errorNoConnection', () {
      const error = ApiException(0, 'No internet', kind: ApiErrorKind.network);
      expect(apiErrorMessage(l10nEs, error), l10nEs.errorNoConnection);
      expect(apiErrorMessage(l10nEn, error), l10nEn.errorNoConnection);
    });

    test('Error de timeout -> errorTimeout', () {
      const error = ApiException(0, 'Timed out', kind: ApiErrorKind.timeout);
      expect(apiErrorMessage(l10nEs, error), l10nEs.errorTimeout);
      expect(apiErrorMessage(l10nEn, error), l10nEn.errorTimeout);
    });

    test('401 en login -> authInvalidCredentials', () {
      const error = ApiException(401, 'Unauthorized', kind: ApiErrorKind.http);
      expect(apiErrorMessage(l10nEs, error, isLogin: true), l10nEs.authInvalidCredentials);
      expect(apiErrorMessage(l10nEn, error, isLogin: true), l10nEn.authInvalidCredentials);
    });

    test('401 fuera de login -> authSessionExpired', () {
      const error = ApiException(401, 'Unauthorized', kind: ApiErrorKind.http);
      expect(apiErrorMessage(l10nEs, error, isLogin: false), l10nEs.authSessionExpired);
      expect(apiErrorMessage(l10nEn, error, isLogin: false), l10nEn.authSessionExpired);
    });

    test('409 conflicto de correo -> authEmailInUse', () {
      const error = ApiException(409, 'Conflict', kind: ApiErrorKind.http);
      expect(apiErrorMessage(l10nEs, error), l10nEs.authEmailInUse);
      expect(apiErrorMessage(l10nEn, error), l10nEn.authEmailInUse);
    });

    test('429 rate limit -> errorTooManyRequests', () {
      const error = ApiException(429, 'Too many requests', kind: ApiErrorKind.http);
      expect(apiErrorMessage(l10nEs, error), l10nEs.errorTooManyRequests);
      expect(apiErrorMessage(l10nEn, error), l10nEn.errorTooManyRequests);
    });

    test('500 error del servidor -> errorServer', () {
      for (final code in [500, 502, 503]) {
        final error = ApiException(code, 'Server error', kind: ApiErrorKind.http);
        expect(apiErrorMessage(l10nEs, error), l10nEs.errorServer);
        expect(apiErrorMessage(l10nEn, error), l10nEn.errorServer);
      }
    });

    test('Error genérico o desconocido -> errorGeneric', () {
      expect(apiErrorMessage(l10nEs, Exception('Unknown')), l10nEs.errorGeneric);
      expect(apiErrorMessage(l10nEs, 'cadena de error'), l10nEs.errorGeneric);
      const error400 = ApiException(400, 'Bad Request');
      expect(apiErrorMessage(l10nEs, error400), l10nEs.errorGeneric);
    });
  });
}

