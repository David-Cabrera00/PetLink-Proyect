// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navigationRadar => 'Radar';

  @override
  String get navigationExplore => 'Explorar';

  @override
  String get navigationReport => 'Reportar';

  @override
  String get navigationActivity => 'Actividad';

  @override
  String get navigationProfile => 'Perfil';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String radarGreeting({required Object name}) => 'Buenos días, $name';

  @override
  String get radarNearYou => 'Esto está ocurriendo cerca de ti.';

  @override
  String get radarLocation => 'La Aurora, Pasto';

  @override
  String get radarRadius => 'Radio 5 km';

  @override
  String get radarActive => 'Radar activo';

  @override
  String radarReportsCount({required Object count}) => '$count reportes';

  @override
  String radarReportsWithinRadius({required Object count}) =>
      '$count reportes en un radio de 5 km';

  @override
  String radarPublishedLast24Hours({required Object count}) =>
      '$count publicados en las últimas 24 h';

  @override
  String get radarExplore => 'Explorar el radar';

  @override
  String get radarPossibleMatches => 'Posibles coincidencias';

  @override
  String get radarMatchesLoadError => 'No pudimos cargar las coincidencias';

  @override
  String get radarNoMatches => 'Sin coincidencias todavía';

  @override
  String get radarNoMatchesDescription =>
      'Seguimos comparando tu reporte con mascotas encontradas cerca de ti.';

  @override
  String get radarNearby => 'Cerca de ti';

  @override
  String get radarNoNearbyReports => 'No hay reportes cerca';

  @override
  String get radarNoNearbyReportsDescription =>
      'Los reportes de mascotas aparecerán aquí cuando estén cerca de tu ubicación.';

  @override
  String get radarReportsLoadError => 'No pudimos cargar los reportes';

  @override
  String get connectionRetryDescription =>
      'Verifica tu conexión e intenta nuevamente.';

  @override
  String get exploreSearchHint => 'Buscar mascota o zona';

  @override
  String get exploreAll => 'Todos';

  @override
  String get exploreLost => 'Perdidas';

  @override
  String get exploreFound => 'Encontradas';

  @override
  String get exploreNearby => '< 5 km';

  @override
  String get exploreNoReports => 'No hay reportes en esta zona';

  @override
  String get exploreNoReportsDescription =>
      'Intenta cambiar los filtros o ampliar el radio de búsqueda.';

  @override
  String get exploreMapTitle => 'Mapa de exploración';

  @override
  String get exploreMapDescription =>
      'Aquí se mostrará el mapa con los reportes';

  @override
  String get exploreMapLoadError => 'No pudimos cargar el mapa';

  @override
  String get exploreHoursAgo => 'Hace 3 horas';

  @override
  String get exploreViewReport => 'Ver reporte';

  @override
  String get activityRecent => 'Actividad Reciente';

  @override
  String get activityDescription =>
      'Recibe notificaciones sobre coincidencias y actualizaciones.';

  @override
  String get profileTitle => 'Mi Perfil';

  @override
  String get profileDescription =>
      'Gestiona tu información personal y configuración.';

  @override
  String get appearance => 'Apariencia';

  @override
  String get themeSystemDescription =>
      'Usa la configuración del dispositivo';

  @override
  String get themeLightDescription => 'Tema claro siempre';

  @override
  String get themeDarkDescription => 'Tema oscuro siempre';

  @override
  String get language => 'Idioma';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get reportCreate => 'Crear reporte';

  @override
  String get reportWhatHappened => '¿Qué ocurrió?';

  @override
  String get reportLostTitle => 'Perdí a mi mascota';

  @override
  String get reportLostDescription =>
      'Publica sus datos para que personas cerca puedan ayudarte a encontrarla.';

  @override
  String get reportFoundTitle => 'Encontré una mascota';

  @override
  String get reportFoundDescription =>
      'Comparte dónde la encontraste para ayudarla a volver a casa.';

  @override
  String get continueAction => 'Continuar';
}
