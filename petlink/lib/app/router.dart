import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/radar/presentation/radar_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/reports/presentation/report_detail_screen.dart';
import '../features/reports/presentation/report_type_screen.dart';
import '../features/reports/presentation/report_pet_info_screen.dart';
import '../features/reports/presentation/report_photos_screen.dart';
import '../features/reports/presentation/report_location_screen.dart';
import '../features/reports/presentation/report_details_screen.dart';
import '../features/reports/presentation/report_review_screen.dart';
import '../features/reports/presentation/report_published_screen.dart';
import '../features/matches/presentation/match_detail_screen.dart';
import '../features/activity/activity_screen.dart';
import '../features/profile/profile_screen.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/radar',
    routes: [
      GoRoute(
        path: '/report/new',
        builder: (context, state) => const ReportTypeScreen(),
      ),
      GoRoute(
        path: '/report/new/pet-info',
        builder: (context, state) => const ReportPetInfoScreen(),
      ),
      GoRoute(
        path: '/report/new/photos',
        builder: (context, state) => const ReportPhotosScreen(),
      ),
      GoRoute(
        path: '/report/new/location',
        builder: (context, state) => const ReportLocationScreen(),
      ),
      GoRoute(
        path: '/report/new/details',
        builder: (context, state) => const ReportDetailsScreen(),
      ),
      GoRoute(
        path: '/report/new/review',
        builder: (context, state) => const ReportReviewScreen(),
      ),
      GoRoute(
        path: '/report/new/published',
        builder: (context, state) => const ReportPublishedScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNav(child: child);
        },
        routes: [
          GoRoute(
            path: '/radar',
            builder: (context, state) => const RadarScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/reports/:id',
            builder: (context, state) =>
                ReportDetailScreen(reportId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/matches/:id',
            builder: (context, state) =>
                MatchDetailScreen(matchId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/activity',
            builder: (context, state) => const ActivityScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNav({super.key, required this.child});

  static int _indexFromLocation(String location) {
    if (location.startsWith('/radar')) return 0;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/reports')) return 2;
    if (location.startsWith('/activity')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/radar');
            case 1:
              context.go('/explore');
            case 2:
              context.go('/report/new');
            case 3:
              context.go('/activity');
            case 4:
              context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.radar_outlined),
            selectedIcon: Icon(Icons.radar),
            label: 'Radar',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Explorar',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Reportar',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Actividad',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
