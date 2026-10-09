// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navigationRadar => 'Radar';

  @override
  String get navigationExplore => 'Explore';

  @override
  String get navigationReport => 'Report';

  @override
  String get navigationActivity => 'Activity';

  @override
  String get navigationProfile => 'Profile';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get backAction => 'Back';
  @override
  String get retryAction => 'Retry';
  @override
  String get statusLost => 'Lost';
  @override
  String get statusFound => 'Found';
  @override
  String get statusMatch => 'Possible match';
  @override
  String get statusRecovered => 'Recovered';
  @override
  String get matchCardYourReport => 'Your report';
  @override
  String get matchCardPetFound => 'Pet found';
  @override
  String timeHoursAgo({required Object count}) => '$count h ago';
  @override
  String timeMinutesAgo({required Object count}) => '$count min ago';
  @override
  String get reportDetailTitle => 'Pet details';
  @override
  String get reportDetailLoadError => "We couldn't load the report";
  @override
  String get reportDetailNotFound => "We couldn't find this report.";
  @override
  String get reportDetailNotFoundDescription =>
      'The report may have been deleted or the ID is incorrect.';
  @override
  String get reportDetailTraits => 'Traits and identifying marks';
  @override
  String get reportDetailHowItHappened => 'What happened?';
  @override
  String get reportDetailLastLocation => 'Last location';
  @override
  String reportDetailLastSeenAt({required Object location}) =>
      'Last seen at $location';
  @override
  String get reportDetailMapTitle => 'Area map';
  @override
  String get reportDetailMapDescription =>
      'The last known location will appear here';
  @override
  String reportDetailSightingPrompt({required Object name}) =>
      'Did you see $name or do you have a clue?';
  @override
  String get reportDetailReportSighting => 'Report sighting';
  @override
  String get shareAction => 'Share';
  @override
  String get contactAction => 'Contact';
  @override
  String get reportDetailColor => 'Color';
  @override
  String get reportDetailCollar => 'Collar';
  @override
  String get reportDetailPhysicalMark => 'Physical mark';
  @override
  String get reportDetailTemperament => 'Temperament';
  @override
  String get reportDetailSoftGold => 'Soft gold';
  @override
  String get reportDetailBrownCollar => 'Brown leather with gold buckle';
  @override
  String get reportDetailWhiteMark => 'White mark on chest';
  @override
  String get reportDetailDocile => 'Docile, responds to its name';
  @override
  String reportDetailWeight({required Object size}) => '$size · 28 kg';
  @override
  String get matchDetailTitle => 'Possible match';
  @override
  String get matchDetailLoadError => "We couldn't load the match";
  @override
  String get matchDetailNotFound => 'This match is no longer available.';
  @override
  String get matchDetailNotFoundDescription =>
      'It may have been dismissed or deleted.';
  @override
  String get matchDetailComparison => 'Feature comparison';
  @override
  String get matchDetailLocationTime => 'Location and time';
  @override
  String get matchDetailTraits => 'Identifying traits';
  @override
  String get matchDetailHigh => 'High match';
  @override
  String get matchDetailDescription =>
      'The features, location and timing of both reports are similar. Review the information before contacting them.';
  @override
  String get matchDetailYourReport => 'Your report';
  @override
  String get matchDetailFoundPet => 'Pet found';
  @override
  String get matchDetailSpecies => 'Species';
  @override
  String get matchDetailBreed => 'Breed';
  @override
  String get matchDetailColor => 'Color';
  @override
  String get matchDetailSize => 'Size';
  @override
  String get matchDetailSex => 'Sex';
  @override
  String get matchDetailMatches => 'Matches';
  @override
  String get matchDetailDistance => 'Distance between reports';
  @override
  String get matchDetailTimeBetween => 'Time between reports';
  @override
  String get matchDetailLostTraits =>
      'Color: Soft gold\nCollar: Brown leather with gold buckle\nPhysical mark: White mark on chest\nTemperament: Docile, responds to its name';
  @override
  String get matchDetailFoundTraits =>
      'Color: Gold\nCollar: No visible collar\nPhysical mark: White mark on chest\nTemperament: Calm and approachable';
  @override
  String get matchDetailContactFinder => 'Contact the finder';
  @override
  String get matchDetailDismiss => 'Dismiss match';
  @override
  String get matchDetailBack => 'Back';
  @override
  String get reportPetInfoTitle => 'Pet information';
  @override
  String get reportPetInfoName => 'Name';
  @override
  String get reportPetInfoNameOptional => 'Name (optional)';
  @override
  String get reportPetInfoSpecies => 'Species';
  @override
  String get reportPetInfoBreed => 'Breed';
  @override
  String get reportPetInfoSex => 'Sex';
  @override
  String get reportPetInfoAge => 'Age';
  @override
  String get reportPetInfoSize => 'Size';
  @override
  String get reportPetInfoColor => 'Color';
  @override
  String get reportPetInfoNameHint => 'E.g. Luna';
  @override
  String get reportPetInfoSpeciesHint => 'E.g. Dog';
  @override
  String get reportPetInfoBreedHint => 'E.g. Golden Retriever';
  @override
  String get reportPetInfoSexHint => 'Male / Female';
  @override
  String get reportPetInfoAgeHint => 'E.g. 4 years';
  @override
  String get reportPetInfoSizeHint => 'Small / Medium / Large';
  @override
  String get reportPetInfoColorHint => 'E.g. Golden';
  @override
  String get requiredName => 'Name is required';
  @override
  String get requiredSpecies => 'Species is required';
  @override
  String get requiredBreed => 'Breed is required';
  @override
  String get requiredField => 'Required';
  @override
  String get reportPhotosTitle => 'Photos';
  @override
  String get reportPhotosHeading => 'Pet photos';
  @override
  String get reportPhotosDescription =>
      'Clear photos make it easier to identify the pet.';
  @override
  String reportPhotosCount({required Object count}) => '$count of 3 photos';
  @override
  String get reportPhotosAddPrompt => 'Add photos of the pet';
  @override
  String get reportPhotosLimit => 'You can add up to 3 photos';
  @override
  String get addPhoto => 'Add photo';
  @override
  String get takePhoto => 'Take photo';
  @override
  String get gallery => 'Gallery';
  @override
  String get reportLocationTitle => 'Location';
  @override
  String get reportLocationLostQuestion => 'Where did you last see it?';
  @override
  String get reportLocationFoundQuestion => 'Where did you find it?';
  @override
  String get reportLocationLostLabel => 'Last known location';
  @override
  String get reportLocationFoundLabel => 'Place where you found it';
  @override
  String get reportLocationHint => 'E.g. La Aurora neighborhood, Pasto';
  @override
  String get requiredLocation => 'Location is required';
  @override
  String get reportLocationExample => 'Example: La Aurora neighborhood, Pasto';
  @override
  String get reportLocationMapTitle => 'Area map';
  @override
  String get reportLocationMapDescription =>
      'The map for selecting the location will appear here';
  @override
  String get useCurrentLocation => 'Use current location';
  @override
  String get reportDetailsTitle => 'Details';
  @override
  String get reportDetailsHeading => 'Additional details';
  @override
  String get reportDetailsDescription =>
      'Information that will help identify the pet.';
  @override
  String get reportDetailsTraits => 'Identifying marks';
  @override
  String get reportDetailsTraitsHint =>
      'E.g. White mark on chest, brown collar...';
  @override
  String get reportDetailsLostQuestion => 'What happened?';
  @override
  String get reportDetailsFoundQuestion => 'Tell us how you found it';
  @override
  String get reportDetailsDescriptionHint => 'Describe the circumstances...';
  @override
  String get reportDetailsDateLost => 'When was it last seen?';
  @override
  String get reportDetailsDateFound => 'When did you find it?';
  @override
  String get selectDateTime => 'Select date and time';
  @override
  String get reportDetailsWithPet => 'Is the pet with you?';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
  @override
  String get selectDateTimeError => 'Select the date and time';
  @override
  String get reportReviewTitle => 'Review your report';
  @override
  String get reportReviewDescription =>
      'Check that all information is correct before publishing.';
  @override
  String get reportReviewType => 'Report type';
  @override
  String get reportReviewPhotos => 'Photos';
  @override
  String get noPhotos => 'No photos';
  @override
  String get reportReviewName => 'Name';
  @override
  String get reportReviewSpecies => 'Species';
  @override
  String get reportReviewBreed => 'Breed';
  @override
  String get reportReviewSex => 'Sex';
  @override
  String get reportReviewAge => 'Age';
  @override
  String get reportReviewSize => 'Size';
  @override
  String get reportReviewColor => 'Color';
  @override
  String get reportReviewLocation => 'Location';
  @override
  String get reportReviewLastSeen => 'Last seen';
  @override
  String get reportReviewFoundDate => 'Date found';
  @override
  String get reportReviewTraits => 'Identifying marks';
  @override
  String get reportReviewWhatHappened => 'What happened?';
  @override
  String get reportReviewPetWithFinder => 'Is the pet with you?';
  @override
  String get publishReport => 'Publish report';
  @override
  String get editReport => 'Edit report';
  @override
  String publishError({required Object error}) => 'Error publishing: $error';
  @override
  String get reportPublishedTitle => 'Your report is now active';
  @override
  String get reportPublishedDescription =>
      'People nearby will be able to see it and PetLink will look for possible matches.';
  @override
  String get viewMyReport => 'View my report';
  @override
  String get backToRadar => 'Back to radar';

  @override
  String radarGreeting({required Object name}) => 'Good morning, $name';

  @override
  String get radarNearYou => 'This is what is happening near you.';

  @override
  String get radarLocation => 'La Aurora, Pasto';

  @override
  String get radarRadius => '5 km radius';

  @override
  String get radarActive => 'Active radar';

  @override
  String radarReportsCount({required Object count}) => '$count reports';

  @override
  String radarReportsWithinRadius({required Object count}) =>
      '$count reports within a 5 km radius';

  @override
  String radarPublishedLast24Hours({required Object count}) =>
      '$count published in the last 24 hours';

  @override
  String get radarExplore => 'Explore the radar';

  @override
  String get radarPossibleMatches => 'Possible matches';

  @override
  String get radarMatchesLoadError => "We couldn't load the matches";

  @override
  String get radarNoMatches => 'No matches yet';

  @override
  String get radarNoMatchesDescription =>
      'We are still comparing your report with pets found near you.';

  @override
  String get radarNearby => 'Near you';

  @override
  String get radarNoNearbyReports => 'No reports nearby';

  @override
  String get radarNoNearbyReportsDescription =>
      'Pet reports will appear here when they are near your location.';

  @override
  String get radarReportsLoadError => "We couldn't load the reports";

  @override
  String get connectionRetryDescription =>
      'Check your connection and try again.';

  @override
  String get exploreSearchHint => 'Search for a pet or area';

  @override
  String get exploreAll => 'All';

  @override
  String get exploreLost => 'Lost';

  @override
  String get exploreFound => 'Found';

  @override
  String get exploreNearby => '< 5 km';

  @override
  String get exploreNoReports => 'No reports in this area';

  @override
  String get exploreNoReportsDescription =>
      'Try changing the filters or expanding the search radius.';

  @override
  String get exploreMapTitle => 'Explore map';

  @override
  String get exploreMapDescription => 'The map with reports will appear here';

  @override
  String get exploreMapLoadError => "We couldn't load the map";

  @override
  String get exploreHoursAgo => '3 hours ago';

  @override
  String get exploreViewReport => 'View report';

  @override
  String get activityRecent => 'Recent Activity';

  @override
  String get activityDescription =>
      'Receive notifications about matches and updates.';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileDescription =>
      'Manage your personal information and settings.';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystemDescription => 'Use the device settings';

  @override
  String get themeLightDescription => 'Always use light theme';

  @override
  String get themeDarkDescription => 'Always use dark theme';

  @override
  String get language => 'Language';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get reportCreate => 'Create report';

  @override
  String get reportWhatHappened => 'What happened?';

  @override
  String get reportLostTitle => 'I lost my pet';

  @override
  String get reportLostDescription =>
      'Post its details so people nearby can help you find it.';

  @override
  String get reportFoundTitle => 'I found a pet';

  @override
  String get reportFoundDescription =>
      'Share where you found it to help it get back home.';

  @override
  String get continueAction => 'Continue';
  @override
  String get reportPetInfoTitle => 'Pet information';
  @override
  String get reportPetInfoName => 'Name';
  @override
  String get reportPetInfoNameOptional => 'Name (optional)';
  @override
  String get reportPetInfoSpecies => 'Species';
  @override
  String get reportPetInfoBreed => 'Breed';
  @override
  String get reportPetInfoSex => 'Sex';
  @override
  String get reportPetInfoAge => 'Age';
  @override
  String get reportPetInfoSize => 'Size';
  @override
  String get reportPetInfoColor => 'Color';
  @override
  String get reportPetInfoNameHint => 'E.g. Luna';
  @override
  String get reportPetInfoSpeciesHint => 'E.g. Dog';
  @override
  String get reportPetInfoBreedHint => 'E.g. Golden Retriever';
  @override
  String get reportPetInfoSexHint => 'Male / Female';
  @override
  String get reportPetInfoAgeHint => 'E.g. 4 years';
  @override
  String get reportPetInfoSizeHint => 'Small / Medium / Large';
  @override
  String get reportPetInfoColorHint => 'E.g. Golden';
  @override
  String get requiredName => 'Name is required';
  @override
  String get requiredSpecies => 'Species is required';
  @override
  String get requiredBreed => 'Breed is required';
  @override
  String get requiredField => 'Required';
  @override
  String get reportPhotosTitle => 'Photos';
  @override
  String get reportPhotosHeading => 'Pet photos';
  @override
  String get reportPhotosDescription =>
      'Clear photos make it easier to identify the pet.';
  @override
  String reportPhotosCount({required Object count}) => '$count of 3 photos';
  @override
  String get reportPhotosAddPrompt => 'Add photos of the pet';
  @override
  String get reportPhotosLimit => 'You can add up to 3 photos';
  @override
  String get addPhoto => 'Add photo';
  @override
  String get takePhoto => 'Take photo';
  @override
  String get gallery => 'Gallery';
  @override
  String get reportLocationTitle => 'Location';
  @override
  String get reportLocationLostQuestion => 'Where did you last see it?';
  @override
  String get reportLocationFoundQuestion => 'Where did you find it?';
  @override
  String get reportLocationLostLabel => 'Last known location';
  @override
  String get reportLocationFoundLabel => 'Place where you found it';
  @override
  String get reportLocationHint => 'E.g. La Aurora neighborhood, Pasto';
  @override
  String get requiredLocation => 'Location is required';
  @override
  String get reportLocationExample => 'Example: La Aurora neighborhood, Pasto';
  @override
  String get reportLocationMapTitle => 'Area map';
  @override
  String get reportLocationMapDescription =>
      'The map for selecting the location will appear here';
  @override
  String get useCurrentLocation => 'Use current location';
  @override
  String get reportDetailsTitle => 'Details';
  @override
  String get reportDetailsHeading => 'Additional details';
  @override
  String get reportDetailsDescription =>
      'Information that will help identify the pet.';
  @override
  String get reportDetailsTraits => 'Identifying marks';
  @override
  String get reportDetailsTraitsHint =>
      'E.g. White mark on chest, brown collar...';
  @override
  String get reportDetailsLostQuestion => 'What happened?';
  @override
  String get reportDetailsFoundQuestion => 'Tell us how you found it';
  @override
  String get reportDetailsDescriptionHint => 'Describe the circumstances...';
  @override
  String get reportDetailsDateLost => 'When was it last seen?';
  @override
  String get reportDetailsDateFound => 'When did you find it?';
  @override
  String get selectDateTime => 'Select date and time';
  @override
  String get reportDetailsWithPet => 'Is the pet with you?';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
  @override
  String get selectDateTimeError => 'Select the date and time';
  @override
  String get reportReviewTitle => 'Review your report';
  @override
  String get reportReviewDescription =>
      'Check that all information is correct before publishing.';
  @override
  String get reportReviewType => 'Report type';
  @override
  String get reportReviewPhotos => 'Photos';
  @override
  String get noPhotos => 'No photos';
  @override
  String get reportReviewName => 'Name';
  @override
  String get reportReviewSpecies => 'Species';
  @override
  String get reportReviewBreed => 'Breed';
  @override
  String get reportReviewSex => 'Sex';
  @override
  String get reportReviewAge => 'Age';
  @override
  String get reportReviewSize => 'Size';
  @override
  String get reportReviewColor => 'Color';
  @override
  String get reportReviewLocation => 'Location';
  @override
  String get reportReviewLastSeen => 'Last seen';
  @override
  String get reportReviewFoundDate => 'Date found';
  @override
  String get reportReviewTraits => 'Identifying marks';
  @override
  String get reportReviewWhatHappened => 'What happened?';
  @override
  String get reportReviewPetWithFinder => 'Is the pet with you?';
  @override
  String get publishReport => 'Publish report';
  @override
  String get editReport => 'Edit report';
  @override
  String publishError({required Object error}) => 'Error publishing: $error';
  @override
  String get reportPublishedTitle => 'Your report is now active';
  @override
  String get reportPublishedDescription =>
      'People nearby will be able to see it and PetLink will look for possible matches.';
  @override
  String get viewMyReport => 'View my report';
  @override
  String get backToRadar => 'Back to radar';
  @override
  String get reportDetailRegion => 'Pasto, Nariño';
  @override
  String get matchValueDog => 'Dog';
  @override
  String get matchValueGoldenRetriever => 'Golden Retriever';
  @override
  String get matchValueGold => 'Gold';
  @override
  String get matchValueLarge => 'Large';
  @override
  String get matchValueFemale => 'Female';
  @override
  String get matchValueNoVisibleCollar => 'No visible collar';
  @override
  String get matchValueCalm => 'Calm and approachable';
  @override
  String get authWelcomeTitle => 'Find the way back home';
  @override
  String get authWelcomeDescription =>
      'Report lost pets, help those who find them, and connect with your community.';
  @override
  String get authLogin => 'Sign in';
  @override
  String get authCreateAccount => 'Create account';
  @override
  String get authLoginTitle => 'Welcome back';
  @override
  String get authLoginDescription =>
      'Sign in to keep helping pets find their way home.';
  @override
  String get authEmail => 'Email';
  @override
  String get authEmailHint => 'you@email.com';
  @override
  String get authEmailRequired => 'Email is required';
  @override
  String get authEmailInvalid => 'Enter a valid email';
  @override
  String get authPassword => 'Password';
  @override
  String get authPasswordHint => 'Enter your password';
  @override
  String get authPasswordRequired => 'Password is required';
  @override
  String get authPasswordVisibility => 'Show or hide password';
  @override
  String get authForgotPassword => 'Forgot your password?';
  @override
  String get authContinueWithGoogle => 'Continue with Google';
  @override
  String get authRegister => 'Create account';
  @override
  String get authRegisterTitle => 'Create your account';
  @override
  String get authRegisterDescription =>
      'Join the community helping pets find their way home.';
  @override
  String get authName => 'Name';
  @override
  String get authNameHint => 'Your name';
  @override
  String get authNameRequired => 'Name is required';
  @override
  String get authConfirmPassword => 'Confirm password';
  @override
  String get authConfirmPasswordHint => 'Repeat your password';
  @override
  String get authConfirmPasswordRequired => 'Confirm your password';
  @override
  String get authPasswordsMismatch => 'Passwords do not match';
  @override
  String get authForgotPasswordTitle => 'Reset your password';
  @override
  String get authForgotPasswordDescription =>
      'We will send instructions to help you regain access to your account.';
  @override
  String get authSendInstructions => 'Send instructions';
  @override
  String get authForgotPasswordConfirmation =>
      'If the email is registered, you will receive instructions to reset your password.';
  @override
  String get profileLogout => 'Sign out';
}
