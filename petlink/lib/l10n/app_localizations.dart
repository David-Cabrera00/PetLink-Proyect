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

  String radarGreeting({required Object name});

  String get radarNearYou;

  String get radarLocation;

  String get radarRadius;

  String get radarActive;

  String radarReportsCount({required Object count});

  String radarReportsWithinRadius({required Object count});

  String radarPublishedLast24Hours({required Object count});

  String get radarExplore;

  String get radarPossibleMatches;

  String get radarMatchesLoadError;

  String get radarNoMatches;

  String get radarNoMatchesDescription;

  String get radarNearby;

  String get radarNoNearbyReports;

  String get radarNoNearbyReportsDescription;

  String get radarReportsLoadError;

  String get connectionRetryDescription;

  String get exploreSearchHint;

  String get exploreAll;

  String get exploreLost;

  String get exploreFound;

  String get exploreNearby;

  String get exploreNoReports;

  String get exploreNoReportsDescription;

  String get exploreMapTitle;

  String get exploreMapDescription;

  String get exploreMapLoadError;

  String get exploreHoursAgo;

  String get exploreViewReport;

  String get activityRecent;

  String get activityDescription;

  String get profileTitle;

  String get profileDescription;

  String get appearance;

  String get themeSystemDescription;

  String get themeLightDescription;

  String get themeDarkDescription;

  String get language;

  String get languageSpanish;

  String get languageEnglish;

  String get reportCreate;

  String get reportWhatHappened;

  String get reportLostTitle;

  String get reportLostDescription;

  String get reportFoundTitle;

  String get reportFoundDescription;

  String get continueAction;

  String get backAction;
  String get retryAction;
  String get statusLost;
  String get statusFound;
  String get statusMatch;
  String get statusRecovered;
  String get matchCardYourReport;
  String get matchCardPetFound;
  String timeHoursAgo({required Object count});
  String timeMinutesAgo({required Object count});
  String get reportDetailTitle;
  String get reportDetailLoadError;
  String get reportDetailNotFound;
  String get reportDetailNotFoundDescription;
  String get reportDetailTraits;
  String get reportDetailHowItHappened;
  String get reportDetailLastLocation;
  String reportDetailLastSeenAt({required Object location});
  String get reportDetailMapTitle;
  String get reportDetailMapDescription;
  String reportDetailSightingPrompt({required Object name});
  String get reportDetailReportSighting;
  String get shareAction;
  String get contactAction;
  String get reportDetailColor;
  String get reportDetailCollar;
  String get reportDetailPhysicalMark;
  String get reportDetailTemperament;
  String get reportDetailSoftGold;
  String get reportDetailBrownCollar;
  String get reportDetailWhiteMark;
  String get reportDetailDocile;
  String reportDetailWeight({required Object size});
  String get matchDetailTitle;
  String get matchDetailLoadError;
  String get matchDetailNotFound;
  String get matchDetailNotFoundDescription;
  String get matchDetailComparison;
  String get matchDetailLocationTime;
  String get matchDetailTraits;
  String get matchDetailHigh;
  String get matchDetailDescription;
  String get matchDetailYourReport;
  String get matchDetailFoundPet;
  String get matchDetailSpecies;
  String get matchDetailBreed;
  String get matchDetailColor;
  String get matchDetailSize;
  String get matchDetailSex;
  String get matchDetailMatches;
  String get matchDetailDistance;
  String get matchDetailTimeBetween;
  String get matchDetailLostTraits;
  String get matchDetailFoundTraits;
  String get matchDetailContactFinder;
  String get matchDetailDismiss;
  String get matchDetailBack;
  String get reportPetInfoTitle;
  String get reportPetInfoName;
  String get reportPetInfoNameOptional;
  String get reportPetInfoSpecies;
  String get reportPetInfoBreed;
  String get reportPetInfoSex;
  String get reportPetInfoAge;
  String get reportPetInfoSize;
  String get reportPetInfoColor;
  String get reportPetInfoNameHint;
  String get reportPetInfoSpeciesHint;
  String get reportPetInfoBreedHint;
  String get reportPetInfoSexHint;
  String get reportPetInfoAgeHint;
  String get reportPetInfoSizeHint;
  String get reportPetInfoColorHint;
  String get requiredName;
  String get requiredSpecies;
  String get requiredBreed;
  String get requiredField;
  String get reportPhotosTitle;
  String get reportPhotosHeading;
  String get reportPhotosDescription;
  String reportPhotosCount({required Object count});
  String get reportPhotosAddPrompt;
  String get reportPhotosLimit;
  String get addPhoto;
  String get takePhoto;
  String get gallery;
  String get reportLocationTitle;
  String get reportLocationLostQuestion;
  String get reportLocationFoundQuestion;
  String get reportLocationLostLabel;
  String get reportLocationFoundLabel;
  String get reportLocationHint;
  String get requiredLocation;
  String get reportLocationExample;
  String get reportLocationMapTitle;
  String get reportLocationMapDescription;
  String get useCurrentLocation;
  String get reportDetailsTitle;
  String get reportDetailsHeading;
  String get reportDetailsDescription;
  String get reportDetailsTraits;
  String get reportDetailsTraitsHint;
  String get reportDetailsLostQuestion;
  String get reportDetailsFoundQuestion;
  String get reportDetailsDescriptionHint;
  String get reportDetailsDateLost;
  String get reportDetailsDateFound;
  String get selectDateTime;
  String get reportDetailsWithPet;
  String get yes;
  String get no;
  String get selectDateTimeError;
  String get reportReviewTitle;
  String get reportReviewDescription;
  String get reportReviewType;
  String get reportReviewPhotos;
  String get noPhotos;
  String get reportReviewName;
  String get reportReviewSpecies;
  String get reportReviewBreed;
  String get reportReviewSex;
  String get reportReviewAge;
  String get reportReviewSize;
  String get reportReviewColor;
  String get reportReviewLocation;
  String get reportReviewLastSeen;
  String get reportReviewFoundDate;
  String get reportReviewTraits;
  String get reportReviewWhatHappened;
  String get reportReviewPetWithFinder;
  String get publishReport;
  String get editReport;
  String publishError({required Object error});
  String get reportPublishedTitle;
  String get reportPublishedDescription;
  String get viewMyReport;
  String get backToRadar;
  String get reportDetailRegion;
  String get matchValueDog;
  String get matchValueGoldenRetriever;
  String get matchValueGold;
  String get matchValueLarge;
  String get matchValueFemale;
  String get matchValueNoVisibleCollar;
  String get matchValueCalm;
  String get authWelcomeTitle;
  String get authWelcomeDescription;
  String get authLogin;
  String get authCreateAccount;
  String get authLoginTitle;
  String get authLoginDescription;
  String get authEmail;
  String get authEmailHint;
  String get authEmailRequired;
  String get authEmailInvalid;
  String get authPassword;
  String get authPasswordHint;
  String get authPasswordRequired;
  String get authPasswordVisibility;
  String get authForgotPassword;
  String get authContinueWithGoogle;
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
