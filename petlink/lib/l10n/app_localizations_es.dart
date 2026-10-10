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
  String radarGreeting(Object name) {
    return 'Buenos días, $name';
  }

  @override
  String get radarNearYou => 'Esto está ocurriendo cerca de ti.';

  @override
  String get radarLocation => 'La Aurora, Pasto';

  @override
  String get radarRadius => 'Radio 5 km';

  @override
  String get radarActive => 'Radar activo';

  @override
  String radarReportsCount(Object count) {
    return '$count reportes';
  }

  @override
  String radarReportsWithinRadius(Object count) {
    return '$count reportes en un radio de 5 km';
  }

  @override
  String radarPublishedLast24Hours(Object count) {
    return '$count publicados en las últimas 24 h';
  }

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
  String get themeSystemDescription => 'Usa la configuración del dispositivo';

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

  @override
  String get backAction => 'Volver';

  @override
  String get retryAction => 'Reintentar';

  @override
  String get statusLost => 'Perdida';

  @override
  String get statusFound => 'Encontrada';

  @override
  String get statusMatch => 'Posible coincidencia';

  @override
  String get statusRecovered => 'Recuperada';

  @override
  String get matchCardYourReport => 'Tu reporte';

  @override
  String get matchCardPetFound => 'Mascota encontrada';

  @override
  String timeHoursAgo(Object count) {
    return 'Hace $count h';
  }

  @override
  String timeMinutesAgo(Object count) {
    return 'Hace $count min';
  }

  @override
  String get reportDetailTitle => 'Detalle de mascota';

  @override
  String get reportDetailLoadError => 'No pudimos cargar el reporte';

  @override
  String get reportDetailNotFound => 'No encontramos este reporte.';

  @override
  String get reportDetailNotFoundDescription =>
      'El reporte puede haber sido eliminado o el ID es incorrecto.';

  @override
  String get reportDetailTraits => 'Rasgos y señas particulares';

  @override
  String get reportDetailHowItHappened => '¿Cómo ocurrió?';

  @override
  String get reportDetailLastLocation => 'Última ubicación';

  @override
  String reportDetailLastSeenAt(Object location) {
    return 'Última vez vista en $location';
  }

  @override
  String get reportDetailMapTitle => 'Mapa de la zona';

  @override
  String get reportDetailMapDescription =>
      'Aquí se mostrará la última ubicación conocida';

  @override
  String reportDetailSightingPrompt(Object name) {
    return '¿Viste a $name o tienes una pista?';
  }

  @override
  String get reportDetailReportSighting => 'Reportar avistamiento';

  @override
  String get shareAction => 'Compartir';

  @override
  String get contactAction => 'Contactar';

  @override
  String get reportDetailColor => 'Color';

  @override
  String get reportDetailCollar => 'Collar';

  @override
  String get reportDetailPhysicalMark => 'Seña física';

  @override
  String get reportDetailTemperament => 'Temperamento';

  @override
  String get reportDetailSoftGold => 'Dorado suave';

  @override
  String get reportDetailBrownCollar => 'Cuero marrón con hebilla dorada';

  @override
  String get reportDetailWhiteMark => 'Mancha blanca en el pecho';

  @override
  String get reportDetailDocile => 'Dócil, responde a su nombre';

  @override
  String reportDetailWeight(Object size) {
    return '$size · 28 kg';
  }

  @override
  String get matchDetailTitle => 'Posible coincidencia';

  @override
  String get matchDetailLoadError => 'No pudimos cargar la coincidencia';

  @override
  String get matchDetailNotFound => 'Esta coincidencia ya no está disponible.';

  @override
  String get matchDetailNotFoundDescription =>
      'Puede haber sido descartada o eliminada.';

  @override
  String get matchDetailComparison => 'Comparación de características';

  @override
  String get matchDetailLocationTime => 'Ubicación y momento';

  @override
  String get matchDetailTraits => 'Rasgos particulares';

  @override
  String get matchDetailHigh => 'Coincidencia alta';

  @override
  String get matchDetailDescription =>
      'Las características, la ubicación y el momento de ambos reportes son similares. Revisa la información antes de contactar.';

  @override
  String get matchDetailYourReport => 'Tu reporte';

  @override
  String get matchDetailFoundPet => 'Mascota encontrada';

  @override
  String get matchDetailSpecies => 'Especie';

  @override
  String get matchDetailBreed => 'Raza';

  @override
  String get matchDetailColor => 'Color';

  @override
  String get matchDetailSize => 'Tamaño';

  @override
  String get matchDetailSex => 'Sexo';

  @override
  String get matchDetailMatches => 'Coincide';

  @override
  String get matchDetailDistance => 'Distancia entre reportes';

  @override
  String get matchDetailTimeBetween => 'Tiempo entre reportes';

  @override
  String get matchDetailLostTraits =>
      'Color: Dorado suave\nCollar: Cuero marrón con hebilla dorada\nSeña física: Mancha blanca en el pecho\nTemperamento: Dócil, responde a su nombre';

  @override
  String get matchDetailFoundTraits =>
      'Color: Dorado\nCollar: Sin collar visible\nSeña física: Mancha blanca en el pecho\nTemperamento: Tranquila, se deja acercar';

  @override
  String get matchDetailContactFinder => 'Contactar a quien la encontró';

  @override
  String get matchDetailDismiss => 'Descartar coincidencia';

  @override
  String get matchDetailBack => 'Volver';

  @override
  String get reportPetInfoTitle => 'Datos de la mascota';

  @override
  String get reportPetInfoName => 'Nombre';

  @override
  String get reportPetInfoNameOptional => 'Nombre (opcional)';

  @override
  String get reportPetInfoSpecies => 'Especie';

  @override
  String get reportPetInfoBreed => 'Raza';

  @override
  String get reportPetInfoSex => 'Sexo';

  @override
  String get reportPetInfoAge => 'Edad';

  @override
  String get reportPetInfoSize => 'Tamaño';

  @override
  String get reportPetInfoColor => 'Color';

  @override
  String get reportPetInfoNameHint => 'Ej. Luna';

  @override
  String get reportPetInfoSpeciesHint => 'Ej. Perro';

  @override
  String get reportPetInfoBreedHint => 'Ej. Golden Retriever';

  @override
  String get reportPetInfoSexHint => 'Macho / Hembra';

  @override
  String get reportPetInfoAgeHint => 'Ej. 4 años';

  @override
  String get reportPetInfoSizeHint => 'Pequeño / Mediano / Grande';

  @override
  String get reportPetInfoColorHint => 'Ej. Dorado';

  @override
  String get requiredName => 'El nombre es obligatorio';

  @override
  String get requiredSpecies => 'La especie es obligatoria';

  @override
  String get requiredBreed => 'La raza es obligatoria';

  @override
  String get requiredField => 'Requerido';

  @override
  String get reportPhotosTitle => 'Fotos';

  @override
  String get reportPhotosHeading => 'Fotos de la mascota';

  @override
  String get reportPhotosDescription =>
      'Las fotos claras ayudan a identificar mejor a la mascota.';

  @override
  String reportPhotosCount(Object count) {
    return '$count de 3 fotos';
  }

  @override
  String get reportPhotosAddPrompt => 'Agrega fotos de la mascota';

  @override
  String get reportPhotosLimit => 'Puedes agregar hasta 3 fotografías';

  @override
  String get addPhoto => 'Agregar foto';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get gallery => 'Galería';

  @override
  String get reportLocationTitle => 'Ubicación';

  @override
  String get reportLocationLostQuestion => '¿Dónde la viste por última vez?';

  @override
  String get reportLocationFoundQuestion => '¿Dónde la encontraste?';

  @override
  String get reportLocationLostLabel => 'Última ubicación conocida';

  @override
  String get reportLocationFoundLabel => 'Lugar donde la encontraste';

  @override
  String get reportLocationHint => 'Ej. Barrio La Aurora, Pasto';

  @override
  String get requiredLocation => 'La ubicación es obligatoria';

  @override
  String get reportLocationExample => 'Ejemplo: Barrio La Aurora, Pasto';

  @override
  String get reportLocationMapTitle => 'Mapa de la zona';

  @override
  String get reportLocationMapDescription =>
      'Aquí se mostrará el mapa para seleccionar la ubicación';

  @override
  String get useCurrentLocation => 'Usar ubicación actual';

  @override
  String get locationServiceDisabled =>
      'Activa los servicios de ubicación para continuar.';

  @override
  String get locationPermissionDenied =>
      'Se necesita permiso de ubicación para continuar.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'El permiso está bloqueado. Actívalo desde los ajustes del dispositivo.';

  @override
  String get locationFetchError => 'No se pudo obtener tu ubicación.';

  @override
  String get reportDetailsTitle => 'Detalles';

  @override
  String get reportDetailsHeading => 'Detalles adicionales';

  @override
  String get reportDetailsDescription =>
      'Información que ayudará a identificar a la mascota.';

  @override
  String get reportDetailsTraits => 'Señas particulares';

  @override
  String get reportDetailsTraitsHint =>
      'Ej. Mancha blanca en el pecho, collar marrón...';

  @override
  String get reportDetailsLostQuestion => '¿Qué ocurrió?';

  @override
  String get reportDetailsFoundQuestion => 'Cuéntanos cómo la encontraste';

  @override
  String get reportDetailsDescriptionHint => 'Describe las circunstancias...';

  @override
  String get reportDetailsDateLost => '¿Cuándo fue vista por última vez?';

  @override
  String get reportDetailsDateFound => '¿Cuándo la encontraste?';

  @override
  String get selectDateTime => 'Seleccionar fecha y hora';

  @override
  String get reportDetailsWithPet => '¿La mascota está contigo?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get selectDateTimeError => 'Selecciona la fecha y hora';

  @override
  String get reportReviewTitle => 'Revisa tu reporte';

  @override
  String get reportReviewDescription =>
      'Verifica que toda la información sea correcta antes de publicar.';

  @override
  String get reportReviewType => 'Tipo de reporte';

  @override
  String get reportReviewPhotos => 'Fotos';

  @override
  String get noPhotos => 'Sin fotos';

  @override
  String get reportReviewName => 'Nombre';

  @override
  String get reportReviewSpecies => 'Especie';

  @override
  String get reportReviewBreed => 'Raza';

  @override
  String get reportReviewSex => 'Sexo';

  @override
  String get reportReviewAge => 'Edad';

  @override
  String get reportReviewSize => 'Tamaño';

  @override
  String get reportReviewColor => 'Color';

  @override
  String get reportReviewLocation => 'Ubicación';

  @override
  String get reportReviewLastSeen => 'Última vez vista';

  @override
  String get reportReviewFoundDate => 'Fecha de hallazgo';

  @override
  String get reportReviewTraits => 'Señas particulares';

  @override
  String get reportReviewWhatHappened => '¿Qué ocurrió?';

  @override
  String get reportReviewPetWithFinder => '¿La mascota está contigo?';

  @override
  String get publishReport => 'Publicar reporte';

  @override
  String get editReport => 'Volver a editar';

  @override
  String publishError(Object error) {
    return 'Error al publicar: $error';
  }

  @override
  String get reportPublishedTitle => 'Tu reporte ya está activo';

  @override
  String get reportPublishedDescription =>
      'Las personas cerca podrán verlo y PetLink buscará posibles coincidencias.';

  @override
  String get viewMyReport => 'Ver mi reporte';

  @override
  String get backToRadar => 'Volver al radar';

  @override
  String get reportDetailRegion => 'Pasto, Nariño';

  @override
  String get matchValueDog => 'Perro';

  @override
  String get matchValueGoldenRetriever => 'Golden Retriever';

  @override
  String get matchValueGold => 'Dorado';

  @override
  String get matchValueLarge => 'Grande';

  @override
  String get matchValueFemale => 'Hembra';

  @override
  String get matchValueNoVisibleCollar => 'Sin collar visible';

  @override
  String get matchValueCalm => 'Tranquila, se deja acercar';

  @override
  String get authWelcomeTitle => 'Encuentra el camino de vuelta a casa';

  @override
  String get authWelcomeDescription =>
      'Reporta mascotas perdidas, ayuda a quienes las encontraron y conecta con tu comunidad.';

  @override
  String get authLogin => 'Iniciar sesión';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authLoginTitle => 'Bienvenido de nuevo';

  @override
  String get authLoginDescription =>
      'Inicia sesión para continuar ayudando a las mascotas a volver a casa.';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authEmailHint => 'tu@correo.com';

  @override
  String get authEmailRequired => 'El correo es obligatorio';

  @override
  String get authEmailInvalid => 'Ingresa un correo válido';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authPasswordHint => 'Ingresa tu contraseña';

  @override
  String get authPasswordRequired => 'La contraseña es obligatoria';

  @override
  String get authPasswordVisibility => 'Mostrar u ocultar contraseña';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authContinueWithGoogle => 'Continuar con Google';

  @override
  String get authRegister => 'Crear cuenta';

  @override
  String get authRegisterTitle => 'Crea tu cuenta';

  @override
  String get authRegisterDescription =>
      'Únete a la comunidad que ayuda a las mascotas a volver a casa.';

  @override
  String get authName => 'Nombre';

  @override
  String get authNameHint => 'Tu nombre';

  @override
  String get authNameRequired => 'El nombre es obligatorio';

  @override
  String get authConfirmPassword => 'Confirmar contraseña';

  @override
  String get authConfirmPasswordHint => 'Repite tu contraseña';

  @override
  String get authConfirmPasswordRequired => 'Confirma tu contraseña';

  @override
  String get authPasswordsMismatch => 'Las contraseñas no coinciden';

  @override
  String get authForgotPasswordTitle => 'Recupera tu contraseña';

  @override
  String get authForgotPasswordDescription =>
      'Te enviaremos instrucciones para recuperar el acceso a tu cuenta.';

  @override
  String get authSendInstructions => 'Enviar instrucciones';

  @override
  String get authForgotPasswordConfirmation =>
      'Si el correo está registrado, recibirás instrucciones para recuperar tu contraseña.';

  @override
  String get profileLogout => 'Cerrar sesión';
}
