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
  String get connectionRetryDescription => 'Check your connection and try again.';

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
  String get exploreMapDescription =>
      'The map with reports will appear here';

  @override
  String get exploreMapLoadError => "We couldn't load the map";

  @override
  String get exploreHoursAgo => '3 hours ago';

  @override
  String get exploreViewReport => 'View report';

  @override
  String get activityRecent => 'Recent Activity';

  @override
  String get activityDescription => 'Receive notifications about matches and updates.';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileDescription => 'Manage your personal information and settings.';

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
}
