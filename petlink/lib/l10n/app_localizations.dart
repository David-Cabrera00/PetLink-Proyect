import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
  ];

  /// No description provided for @navigationRadar.
  ///
  /// In es, this message translates to:
  /// **'Radar'**
  String get navigationRadar;

  /// No description provided for @navigationExplore.
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get navigationExplore;

  /// No description provided for @navigationReport.
  ///
  /// In es, this message translates to:
  /// **'Reportar'**
  String get navigationReport;

  /// No description provided for @navigationActivity.
  ///
  /// In es, this message translates to:
  /// **'Actividad'**
  String get navigationActivity;

  /// No description provided for @navigationProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navigationProfile;

  /// No description provided for @themeSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// No description provided for @radarGreeting.
  ///
  /// In es, this message translates to:
  /// **'Buenos días, {name}'**
  String radarGreeting(Object name);

  /// No description provided for @radarNearYou.
  ///
  /// In es, this message translates to:
  /// **'Esto está ocurriendo cerca de ti.'**
  String get radarNearYou;

  /// No description provided for @radarLocation.
  ///
  /// In es, this message translates to:
  /// **'La Aurora, Pasto'**
  String get radarLocation;

  /// No description provided for @radarRadius.
  ///
  /// In es, this message translates to:
  /// **'Radio 5 km'**
  String get radarRadius;

  /// No description provided for @radarActive.
  ///
  /// In es, this message translates to:
  /// **'Radar activo'**
  String get radarActive;

  /// No description provided for @radarReportsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} reportes'**
  String radarReportsCount(Object count);

  /// No description provided for @radarReportsWithinRadius.
  ///
  /// In es, this message translates to:
  /// **'{count} reportes en un radio de 5 km'**
  String radarReportsWithinRadius(Object count);

  /// No description provided for @radarPublishedLast24Hours.
  ///
  /// In es, this message translates to:
  /// **'{count} publicados en las últimas 24 h'**
  String radarPublishedLast24Hours(Object count);

  /// No description provided for @radarExplore.
  ///
  /// In es, this message translates to:
  /// **'Explorar el radar'**
  String get radarExplore;

  /// No description provided for @radarPossibleMatches.
  ///
  /// In es, this message translates to:
  /// **'Posibles coincidencias'**
  String get radarPossibleMatches;

  /// No description provided for @radarMatchesLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las coincidencias'**
  String get radarMatchesLoadError;

  /// No description provided for @radarNoMatches.
  ///
  /// In es, this message translates to:
  /// **'Sin coincidencias todavía'**
  String get radarNoMatches;

  /// No description provided for @radarNoMatchesDescription.
  ///
  /// In es, this message translates to:
  /// **'Seguimos comparando tu reporte con mascotas encontradas cerca de ti.'**
  String get radarNoMatchesDescription;

  /// No description provided for @radarNearby.
  ///
  /// In es, this message translates to:
  /// **'Cerca de ti'**
  String get radarNearby;

  /// No description provided for @radarNoNearbyReports.
  ///
  /// In es, this message translates to:
  /// **'No hay reportes cerca'**
  String get radarNoNearbyReports;

  /// No description provided for @radarNoNearbyReportsDescription.
  ///
  /// In es, this message translates to:
  /// **'Los reportes de mascotas aparecerán aquí cuando estén cerca de tu ubicación.'**
  String get radarNoNearbyReportsDescription;

  /// No description provided for @radarReportsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar los reportes'**
  String get radarReportsLoadError;

  /// No description provided for @connectionRetryDescription.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu conexión e intenta nuevamente.'**
  String get connectionRetryDescription;

  /// No description provided for @exploreSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar mascota o zona'**
  String get exploreSearchHint;

  /// No description provided for @exploreAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get exploreAll;

  /// No description provided for @exploreLost.
  ///
  /// In es, this message translates to:
  /// **'Perdidas'**
  String get exploreLost;

  /// No description provided for @exploreFound.
  ///
  /// In es, this message translates to:
  /// **'Encontradas'**
  String get exploreFound;

  /// No description provided for @exploreNearby.
  ///
  /// In es, this message translates to:
  /// **'< 5 km'**
  String get exploreNearby;

  /// No description provided for @exploreNoReports.
  ///
  /// In es, this message translates to:
  /// **'No hay reportes en esta zona'**
  String get exploreNoReports;

  /// No description provided for @exploreNoReportsDescription.
  ///
  /// In es, this message translates to:
  /// **'Intenta cambiar los filtros o ampliar el radio de búsqueda.'**
  String get exploreNoReportsDescription;

  /// No description provided for @exploreMapTitle.
  ///
  /// In es, this message translates to:
  /// **'Mapa de exploración'**
  String get exploreMapTitle;

  /// No description provided for @exploreMapDescription.
  ///
  /// In es, this message translates to:
  /// **'Aquí se mostrará el mapa con los reportes'**
  String get exploreMapDescription;

  /// No description provided for @exploreMapLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el mapa'**
  String get exploreMapLoadError;

  /// No description provided for @exploreHoursAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace 3 horas'**
  String get exploreHoursAgo;

  /// No description provided for @exploreViewReport.
  ///
  /// In es, this message translates to:
  /// **'Ver reporte'**
  String get exploreViewReport;

  /// No description provided for @activityRecent.
  ///
  /// In es, this message translates to:
  /// **'Actividad Reciente'**
  String get activityRecent;

  /// No description provided for @activityDescription.
  ///
  /// In es, this message translates to:
  /// **'Recibe notificaciones sobre coincidencias y actualizaciones.'**
  String get activityDescription;

  /// No description provided for @reportsTitle.
  String get reportsTitle;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get profileTitle;

  /// No description provided for @profileDescription.
  ///
  /// In es, this message translates to:
  /// **'Gestiona tu información personal y configuración.'**
  String get profileDescription;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// No description provided for @themeSystemDescription.
  ///
  /// In es, this message translates to:
  /// **'Usa la configuración del dispositivo'**
  String get themeSystemDescription;

  /// No description provided for @themeLightDescription.
  ///
  /// In es, this message translates to:
  /// **'Tema claro siempre'**
  String get themeLightDescription;

  /// No description provided for @themeDarkDescription.
  ///
  /// In es, this message translates to:
  /// **'Tema oscuro siempre'**
  String get themeDarkDescription;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @reportCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear reporte'**
  String get reportCreate;

  /// No description provided for @reportWhatHappened.
  ///
  /// In es, this message translates to:
  /// **'¿Qué ocurrió?'**
  String get reportWhatHappened;

  /// No description provided for @reportLostTitle.
  ///
  /// In es, this message translates to:
  /// **'Perdí a mi mascota'**
  String get reportLostTitle;

  /// No description provided for @reportLostDescription.
  ///
  /// In es, this message translates to:
  /// **'Publica sus datos para que personas cerca puedan ayudarte a encontrarla.'**
  String get reportLostDescription;

  /// No description provided for @reportFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Encontré una mascota'**
  String get reportFoundTitle;

  /// No description provided for @reportFoundDescription.
  ///
  /// In es, this message translates to:
  /// **'Comparte dónde la encontraste para ayudarla a volver a casa.'**
  String get reportFoundDescription;

  /// No description provided for @continueAction.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueAction;

  /// No description provided for @backAction.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get backAction;

  /// No description provided for @retryAction.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retryAction;

  /// No description provided for @statusLost.
  ///
  /// In es, this message translates to:
  /// **'Perdida'**
  String get statusLost;

  /// No description provided for @statusFound.
  ///
  /// In es, this message translates to:
  /// **'Encontrada'**
  String get statusFound;

  /// No description provided for @statusMatch.
  ///
  /// In es, this message translates to:
  /// **'Posible coincidencia'**
  String get statusMatch;

  /// No description provided for @statusRecovered.
  ///
  /// In es, this message translates to:
  /// **'Recuperada'**
  String get statusRecovered;

  /// No description provided for @matchCardYourReport.
  ///
  /// In es, this message translates to:
  /// **'Tu reporte'**
  String get matchCardYourReport;

  /// No description provided for @matchCardPetFound.
  ///
  /// In es, this message translates to:
  /// **'Mascota encontrada'**
  String get matchCardPetFound;

  /// No description provided for @timeHoursAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} h'**
  String timeHoursAgo(Object count);

  /// No description provided for @timeMinutesAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count} min'**
  String timeMinutesAgo(Object count);

  /// No description provided for @reportDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle de mascota'**
  String get reportDetailTitle;

  /// No description provided for @reportDetailLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el reporte'**
  String get reportDetailLoadError;

  /// No description provided for @reportDetailNotFound.
  ///
  /// In es, this message translates to:
  /// **'No encontramos este reporte.'**
  String get reportDetailNotFound;

  /// No description provided for @reportDetailNotFoundDescription.
  ///
  /// In es, this message translates to:
  /// **'El reporte puede haber sido eliminado o el ID es incorrecto.'**
  String get reportDetailNotFoundDescription;

  /// No description provided for @reportDetailTraits.
  ///
  /// In es, this message translates to:
  /// **'Rasgos y señas particulares'**
  String get reportDetailTraits;

  /// No description provided for @reportDetailHowItHappened.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo ocurrió?'**
  String get reportDetailHowItHappened;

  /// No description provided for @reportDetailLastLocation.
  ///
  /// In es, this message translates to:
  /// **'Última ubicación'**
  String get reportDetailLastLocation;

  /// No description provided for @reportDetailLastSeenAt.
  ///
  /// In es, this message translates to:
  /// **'Última vez vista en {location}'**
  String reportDetailLastSeenAt(Object location);

  /// No description provided for @reportDetailMapTitle.
  ///
  /// In es, this message translates to:
  /// **'Mapa de la zona'**
  String get reportDetailMapTitle;

  /// No description provided for @reportDetailMapDescription.
  ///
  /// In es, this message translates to:
  /// **'Aquí se mostrará la última ubicación conocida'**
  String get reportDetailMapDescription;

  /// No description provided for @reportDetailSightingPrompt.
  ///
  /// In es, this message translates to:
  /// **'¿Viste a {name} o tienes una pista?'**
  String reportDetailSightingPrompt(Object name);

  /// No description provided for @reportDetailReportSighting.
  ///
  /// In es, this message translates to:
  /// **'Reportar avistamiento'**
  String get reportDetailReportSighting;

  /// No description provided for @shareAction.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get shareAction;

  /// No description provided for @contactAction.
  ///
  /// In es, this message translates to:
  /// **'Contactar'**
  String get contactAction;

  /// No description provided for @reportDetailColor.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get reportDetailColor;

  /// No description provided for @reportDetailCollar.
  ///
  /// In es, this message translates to:
  /// **'Collar'**
  String get reportDetailCollar;

  /// No description provided for @reportDetailPhysicalMark.
  ///
  /// In es, this message translates to:
  /// **'Seña física'**
  String get reportDetailPhysicalMark;

  /// No description provided for @reportDetailTemperament.
  ///
  /// In es, this message translates to:
  /// **'Temperamento'**
  String get reportDetailTemperament;

  /// No description provided for @reportDetailSoftGold.
  ///
  /// In es, this message translates to:
  /// **'Dorado suave'**
  String get reportDetailSoftGold;

  /// No description provided for @reportDetailBrownCollar.
  ///
  /// In es, this message translates to:
  /// **'Cuero marrón con hebilla dorada'**
  String get reportDetailBrownCollar;

  /// No description provided for @reportDetailWhiteMark.
  ///
  /// In es, this message translates to:
  /// **'Mancha blanca en el pecho'**
  String get reportDetailWhiteMark;

  /// No description provided for @reportDetailDocile.
  ///
  /// In es, this message translates to:
  /// **'Dócil, responde a su nombre'**
  String get reportDetailDocile;

  /// No description provided for @reportDetailWeight.
  ///
  /// In es, this message translates to:
  /// **'{size} · 28 kg'**
  String reportDetailWeight(Object size);

  /// No description provided for @matchDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Posible coincidencia'**
  String get matchDetailTitle;

  /// No description provided for @matchDetailLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar la coincidencia'**
  String get matchDetailLoadError;

  /// No description provided for @matchDetailNotFound.
  ///
  /// In es, this message translates to:
  /// **'Esta coincidencia ya no está disponible.'**
  String get matchDetailNotFound;

  /// No description provided for @matchDetailNotFoundDescription.
  ///
  /// In es, this message translates to:
  /// **'Puede haber sido descartada o eliminada.'**
  String get matchDetailNotFoundDescription;

  /// No description provided for @matchDetailComparison.
  ///
  /// In es, this message translates to:
  /// **'Comparación de características'**
  String get matchDetailComparison;

  /// No description provided for @matchDetailLocationTime.
  ///
  /// In es, this message translates to:
  /// **'Ubicación y momento'**
  String get matchDetailLocationTime;

  /// No description provided for @matchDetailTraits.
  ///
  /// In es, this message translates to:
  /// **'Rasgos particulares'**
  String get matchDetailTraits;

  /// No description provided for @matchDetailHigh.
  ///
  /// In es, this message translates to:
  /// **'Coincidencia alta'**
  String get matchDetailHigh;

  /// No description provided for @matchDetailDescription.
  ///
  /// In es, this message translates to:
  /// **'Las características, la ubicación y el momento de ambos reportes son similares. Revisa la información antes de contactar.'**
  String get matchDetailDescription;

  /// No description provided for @matchDetailYourReport.
  ///
  /// In es, this message translates to:
  /// **'Tu reporte'**
  String get matchDetailYourReport;

  /// No description provided for @matchDetailFoundPet.
  ///
  /// In es, this message translates to:
  /// **'Mascota encontrada'**
  String get matchDetailFoundPet;

  /// No description provided for @matchDetailSpecies.
  ///
  /// In es, this message translates to:
  /// **'Especie'**
  String get matchDetailSpecies;

  /// No description provided for @matchDetailBreed.
  ///
  /// In es, this message translates to:
  /// **'Raza'**
  String get matchDetailBreed;

  /// No description provided for @matchDetailColor.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get matchDetailColor;

  /// No description provided for @matchDetailSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño'**
  String get matchDetailSize;

  /// No description provided for @matchDetailSex.
  ///
  /// In es, this message translates to:
  /// **'Sexo'**
  String get matchDetailSex;

  /// No description provided for @matchDetailMatches.
  ///
  /// In es, this message translates to:
  /// **'Coincide'**
  String get matchDetailMatches;

  /// No description provided for @matchDetailDistance.
  ///
  /// In es, this message translates to:
  /// **'Distancia entre reportes'**
  String get matchDetailDistance;

  /// No description provided for @matchDetailTimeBetween.
  ///
  /// In es, this message translates to:
  /// **'Tiempo entre reportes'**
  String get matchDetailTimeBetween;

  /// No description provided for @matchDetailLostTraits.
  ///
  /// In es, this message translates to:
  /// **'Color: Dorado suave\nCollar: Cuero marrón con hebilla dorada\nSeña física: Mancha blanca en el pecho\nTemperamento: Dócil, responde a su nombre'**
  String get matchDetailLostTraits;

  /// No description provided for @matchDetailFoundTraits.
  ///
  /// In es, this message translates to:
  /// **'Color: Dorado\nCollar: Sin collar visible\nSeña física: Mancha blanca en el pecho\nTemperamento: Tranquila, se deja acercar'**
  String get matchDetailFoundTraits;

  /// No description provided for @matchDetailContactFinder.
  ///
  /// In es, this message translates to:
  /// **'Contactar a quien la encontró'**
  String get matchDetailContactFinder;

  /// No description provided for @matchDetailDismiss.
  ///
  /// In es, this message translates to:
  /// **'Descartar coincidencia'**
  String get matchDetailDismiss;

  /// No description provided for @matchDetailBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get matchDetailBack;

  /// No description provided for @reportPetInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos de la mascota'**
  String get reportPetInfoTitle;

  /// No description provided for @reportPetInfoName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get reportPetInfoName;

  /// No description provided for @reportPetInfoNameOptional.
  ///
  /// In es, this message translates to:
  /// **'Nombre (opcional)'**
  String get reportPetInfoNameOptional;

  /// No description provided for @reportPetInfoSpecies.
  ///
  /// In es, this message translates to:
  /// **'Especie'**
  String get reportPetInfoSpecies;

  /// No description provided for @reportPetInfoBreed.
  ///
  /// In es, this message translates to:
  /// **'Raza'**
  String get reportPetInfoBreed;

  /// No description provided for @reportPetInfoSex.
  ///
  /// In es, this message translates to:
  /// **'Sexo'**
  String get reportPetInfoSex;

  /// No description provided for @reportPetInfoAge.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get reportPetInfoAge;

  /// No description provided for @reportPetInfoSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño'**
  String get reportPetInfoSize;

  /// No description provided for @reportPetInfoColor.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get reportPetInfoColor;

  /// No description provided for @reportPetInfoNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Luna'**
  String get reportPetInfoNameHint;

  /// No description provided for @reportPetInfoSpeciesHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Perro'**
  String get reportPetInfoSpeciesHint;

  /// No description provided for @reportPetInfoBreedHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Golden Retriever'**
  String get reportPetInfoBreedHint;

  /// No description provided for @reportPetInfoSexHint.
  ///
  /// In es, this message translates to:
  /// **'Macho / Hembra'**
  String get reportPetInfoSexHint;

  /// No description provided for @reportPetInfoAgeHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 4 años'**
  String get reportPetInfoAgeHint;

  /// No description provided for @reportPetInfoSizeHint.
  ///
  /// In es, this message translates to:
  /// **'Pequeño / Mediano / Grande'**
  String get reportPetInfoSizeHint;

  /// No description provided for @reportPetInfoColorHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Dorado'**
  String get reportPetInfoColorHint;

  /// No description provided for @requiredName.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get requiredName;

  /// No description provided for @requiredSpecies.
  ///
  /// In es, this message translates to:
  /// **'La especie es obligatoria'**
  String get requiredSpecies;

  /// No description provided for @requiredBreed.
  ///
  /// In es, this message translates to:
  /// **'La raza es obligatoria'**
  String get requiredBreed;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Requerido'**
  String get requiredField;

  /// No description provided for @reportPhotosTitle.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get reportPhotosTitle;

  /// No description provided for @reportPhotosHeading.
  ///
  /// In es, this message translates to:
  /// **'Fotos de la mascota'**
  String get reportPhotosHeading;

  /// No description provided for @reportPhotosDescription.
  ///
  /// In es, this message translates to:
  /// **'Las fotos claras ayudan a identificar mejor a la mascota.'**
  String get reportPhotosDescription;

  /// No description provided for @reportPhotosCount.
  ///
  /// In es, this message translates to:
  /// **'{count} de 3 fotos'**
  String reportPhotosCount(Object count);

  /// No description provided for @reportPhotosAddPrompt.
  ///
  /// In es, this message translates to:
  /// **'Agrega fotos de la mascota'**
  String get reportPhotosAddPrompt;

  /// No description provided for @reportPhotosLimit.
  ///
  /// In es, this message translates to:
  /// **'Puedes agregar hasta 3 fotografías'**
  String get reportPhotosLimit;

  /// No description provided for @addPhoto.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto'**
  String get addPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get takePhoto;

  /// No description provided for @gallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get gallery;

  /// No description provided for @reportLocationTitle.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get reportLocationTitle;

  /// No description provided for @reportLocationLostQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde la viste por última vez?'**
  String get reportLocationLostQuestion;

  /// No description provided for @reportLocationFoundQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde la encontraste?'**
  String get reportLocationFoundQuestion;

  /// No description provided for @reportLocationLostLabel.
  ///
  /// In es, this message translates to:
  /// **'Última ubicación conocida'**
  String get reportLocationLostLabel;

  /// No description provided for @reportLocationFoundLabel.
  ///
  /// In es, this message translates to:
  /// **'Lugar donde la encontraste'**
  String get reportLocationFoundLabel;

  /// No description provided for @reportLocationHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Barrio La Aurora, Pasto'**
  String get reportLocationHint;

  /// No description provided for @requiredLocation.
  ///
  /// In es, this message translates to:
  /// **'La ubicación es obligatoria'**
  String get requiredLocation;

  /// No description provided for @reportLocationExample.
  ///
  /// In es, this message translates to:
  /// **'Ejemplo: Barrio La Aurora, Pasto'**
  String get reportLocationExample;

  /// No description provided for @reportLocationMapTitle.
  ///
  /// In es, this message translates to:
  /// **'Mapa de la zona'**
  String get reportLocationMapTitle;

  /// No description provided for @reportLocationMapDescription.
  ///
  /// In es, this message translates to:
  /// **'Aquí se mostrará el mapa para seleccionar la ubicación'**
  String get reportLocationMapDescription;

  /// No description provided for @useCurrentLocation.
  ///
  /// In es, this message translates to:
  /// **'Usar ubicación actual'**
  String get useCurrentLocation;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In es, this message translates to:
  /// **'Activa los servicios de ubicación para continuar.'**
  String get locationServiceDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Se necesita permiso de ubicación para continuar.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In es, this message translates to:
  /// **'El permiso está bloqueado. Actívalo desde los ajustes del dispositivo.'**
  String get locationPermissionPermanentlyDenied;

  String get locationOpenSettings;

  /// No description provided for @locationFetchError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener tu ubicación.'**
  String get locationFetchError;

  /// No description provided for @reportDetailsTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get reportDetailsTitle;

  /// No description provided for @reportDetailsHeading.
  ///
  /// In es, this message translates to:
  /// **'Detalles adicionales'**
  String get reportDetailsHeading;

  /// No description provided for @reportDetailsDescription.
  ///
  /// In es, this message translates to:
  /// **'Información que ayudará a identificar a la mascota.'**
  String get reportDetailsDescription;

  /// No description provided for @reportDetailsTraits.
  ///
  /// In es, this message translates to:
  /// **'Señas particulares'**
  String get reportDetailsTraits;

  /// No description provided for @reportDetailsTraitsHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Mancha blanca en el pecho, collar marrón...'**
  String get reportDetailsTraitsHint;

  /// No description provided for @reportDetailsLostQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Qué ocurrió?'**
  String get reportDetailsLostQuestion;

  /// No description provided for @reportDetailsFoundQuestion.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos cómo la encontraste'**
  String get reportDetailsFoundQuestion;

  /// No description provided for @reportDetailsDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Describe las circunstancias...'**
  String get reportDetailsDescriptionHint;

  /// No description provided for @reportDetailsDateLost.
  ///
  /// In es, this message translates to:
  /// **'¿Cuándo fue vista por última vez?'**
  String get reportDetailsDateLost;

  /// No description provided for @reportDetailsDateFound.
  ///
  /// In es, this message translates to:
  /// **'¿Cuándo la encontraste?'**
  String get reportDetailsDateFound;

  /// No description provided for @selectDateTime.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fecha y hora'**
  String get selectDateTime;

  /// No description provided for @reportDetailsWithPet.
  ///
  /// In es, this message translates to:
  /// **'¿La mascota está contigo?'**
  String get reportDetailsWithPet;

  /// No description provided for @yes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @selectDateTimeError.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la fecha y hora'**
  String get selectDateTimeError;

  /// No description provided for @reportReviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu reporte'**
  String get reportReviewTitle;

  /// No description provided for @reportReviewDescription.
  ///
  /// In es, this message translates to:
  /// **'Verifica que toda la información sea correcta antes de publicar.'**
  String get reportReviewDescription;

  /// No description provided for @reportReviewType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de reporte'**
  String get reportReviewType;

  /// No description provided for @reportReviewPhotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get reportReviewPhotos;

  /// No description provided for @noPhotos.
  ///
  /// In es, this message translates to:
  /// **'Sin fotos'**
  String get noPhotos;

  /// No description provided for @reportReviewName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get reportReviewName;

  /// No description provided for @reportReviewSpecies.
  ///
  /// In es, this message translates to:
  /// **'Especie'**
  String get reportReviewSpecies;

  /// No description provided for @reportReviewBreed.
  ///
  /// In es, this message translates to:
  /// **'Raza'**
  String get reportReviewBreed;

  /// No description provided for @reportReviewSex.
  ///
  /// In es, this message translates to:
  /// **'Sexo'**
  String get reportReviewSex;

  /// No description provided for @reportReviewAge.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get reportReviewAge;

  /// No description provided for @reportReviewSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño'**
  String get reportReviewSize;

  /// No description provided for @reportReviewColor.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get reportReviewColor;

  /// No description provided for @reportReviewLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get reportReviewLocation;

  /// No description provided for @reportReviewLastSeen.
  ///
  /// In es, this message translates to:
  /// **'Última vez vista'**
  String get reportReviewLastSeen;

  /// No description provided for @reportReviewFoundDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de hallazgo'**
  String get reportReviewFoundDate;

  /// No description provided for @reportReviewTraits.
  ///
  /// In es, this message translates to:
  /// **'Señas particulares'**
  String get reportReviewTraits;

  /// No description provided for @reportReviewWhatHappened.
  ///
  /// In es, this message translates to:
  /// **'¿Qué ocurrió?'**
  String get reportReviewWhatHappened;

  /// No description provided for @reportReviewPetWithFinder.
  ///
  /// In es, this message translates to:
  /// **'¿La mascota está contigo?'**
  String get reportReviewPetWithFinder;

  /// No description provided for @publishReport.
  ///
  /// In es, this message translates to:
  /// **'Publicar reporte'**
  String get publishReport;

  /// No description provided for @editReport.
  ///
  /// In es, this message translates to:
  /// **'Volver a editar'**
  String get editReport;

  /// No description provided for @publishError.
  ///
  /// In es, this message translates to:
  /// **'Error al publicar: {error}'**
  String publishError(Object error);

  /// No description provided for @reportPublishedTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu reporte ya está activo'**
  String get reportPublishedTitle;

  /// No description provided for @reportPublishedDescription.
  ///
  /// In es, this message translates to:
  /// **'Las personas cerca podrán verlo y PetLink buscará posibles coincidencias.'**
  String get reportPublishedDescription;

  /// No description provided for @viewMyReport.
  ///
  /// In es, this message translates to:
  /// **'Ver mi reporte'**
  String get viewMyReport;

  /// No description provided for @backToRadar.
  ///
  /// In es, this message translates to:
  /// **'Volver al radar'**
  String get backToRadar;

  /// No description provided for @reportDetailRegion.
  ///
  /// In es, this message translates to:
  /// **'Pasto, Nariño'**
  String get reportDetailRegion;

  /// No description provided for @matchValueDog.
  ///
  /// In es, this message translates to:
  /// **'Perro'**
  String get matchValueDog;

  /// No description provided for @matchValueGoldenRetriever.
  ///
  /// In es, this message translates to:
  /// **'Golden Retriever'**
  String get matchValueGoldenRetriever;

  /// No description provided for @matchValueGold.
  ///
  /// In es, this message translates to:
  /// **'Dorado'**
  String get matchValueGold;

  /// No description provided for @matchValueLarge.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get matchValueLarge;

  /// No description provided for @matchValueFemale.
  ///
  /// In es, this message translates to:
  /// **'Hembra'**
  String get matchValueFemale;

  /// No description provided for @matchValueNoVisibleCollar.
  ///
  /// In es, this message translates to:
  /// **'Sin collar visible'**
  String get matchValueNoVisibleCollar;

  /// No description provided for @matchValueCalm.
  ///
  /// In es, this message translates to:
  /// **'Tranquila, se deja acercar'**
  String get matchValueCalm;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Encuentra el camino de vuelta a casa'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeDescription.
  ///
  /// In es, this message translates to:
  /// **'Reporta mascotas perdidas, ayuda a quienes las encontraron y conecta con tu comunidad.'**
  String get authWelcomeDescription;

  /// No description provided for @authLogin.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authLogin;

  /// No description provided for @authCreateAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authCreateAccount;

  /// No description provided for @authLoginTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de nuevo'**
  String get authLoginTitle;

  /// No description provided for @authLoginDescription.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión para continuar ayudando a las mascotas a volver a casa.'**
  String get authLoginDescription;

  /// No description provided for @authEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authEmail;

  /// No description provided for @authEmailHint.
  ///
  /// In es, this message translates to:
  /// **'tu@correo.com'**
  String get authEmailHint;

  /// No description provided for @authEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'El correo es obligatorio'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido'**
  String get authEmailInvalid;

  /// No description provided for @authPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPassword;

  /// No description provided for @authPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get authPasswordHint;

  /// No description provided for @authPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'La contraseña es obligatoria'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordVisibility.
  ///
  /// In es, this message translates to:
  /// **'Mostrar u ocultar contraseña'**
  String get authPasswordVisibility;

  /// No description provided for @authForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get authForgotPassword;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authRegister.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authRegister;

  /// No description provided for @authRegisterTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterDescription.
  ///
  /// In es, this message translates to:
  /// **'Únete a la comunidad que ayuda a las mascotas a volver a casa.'**
  String get authRegisterDescription;

  /// No description provided for @authName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get authName;

  /// No description provided for @authNameHint.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get authNameHint;

  /// No description provided for @authNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get authNameRequired;

  /// No description provided for @authConfirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get authConfirmPassword;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Repite tu contraseña'**
  String get authConfirmPasswordHint;

  /// No description provided for @authConfirmPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get authConfirmPasswordRequired;

  /// No description provided for @authPasswordsMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get authPasswordsMismatch;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Recupera tu contraseña'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordDescription.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos instrucciones para recuperar el acceso a tu cuenta.'**
  String get authForgotPasswordDescription;

  /// No description provided for @authSendInstructions.
  ///
  /// In es, this message translates to:
  /// **'Enviar instrucciones'**
  String get authSendInstructions;

  /// No description provided for @authForgotPasswordConfirmation.
  ///
  /// In es, this message translates to:
  /// **'Si el correo está registrado, recibirás instrucciones para recuperar tu contraseña.'**
  String get authForgotPasswordConfirmation;

  /// No description provided for @profileLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileLogout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
