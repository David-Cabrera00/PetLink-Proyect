import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';

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
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/create_account_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/auth/providers/auth_provider.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(Ref ref) {
    final refresh = _AuthRouterRefresh();
    ref.onDispose(refresh.dispose);
    ref.listen<AuthState>(authProvider, (_, __) => refresh.notify());

    return GoRouter(
      navigatorKey: GlobalKey<NavigatorState>(),
      initialLocation: '/radar',
      refreshListenable: refresh,
      redirect: (context, state) {
        final isAuthenticated = ref.read(authProvider).isAuthenticated;
        final path = state.uri.path;
        final isProtected = path == '/radar' ||
            path == '/explore' ||
            path == '/activity' ||
            path == '/profile' ||
            path == '/report/new' ||
            path.startsWith('/report/new/');
        final isAuthRoute =
            path == '/welcome' || path == '/login' || path == '/register';

        if (!isAuthenticated && isProtected) return '/welcome';
        if (isAuthenticated && isAuthRoute) return '/radar';
        return null;
      },
      routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
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
        navigatorKey: GlobalKey<NavigatorState>(),
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
}

final appRouterProvider = Provider<GoRouter>(AppRouter.createRouter);

class _AuthRouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
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
    final l10n = AppLocalizations.of(context)!;
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
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.radar_outlined),
            selectedIcon: Icon(Icons.radar),
            label: l10n.navigationRadar,
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: l10n.navigationExplore,
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: l10n.navigationReport,
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: l10n.navigationActivity,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: l10n.navigationProfile,
          ),
        ],
      ),
    );
  }
}
