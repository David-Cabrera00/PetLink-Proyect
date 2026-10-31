import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../core/theme/pet_tokens.dart';
import 'widgets/pet_nav_bar.dart';
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
import '../features/reports/presentation/report_sighting_screen.dart';
import '../features/matches/presentation/match_detail_screen.dart';
import '../features/activity/activity_screen.dart';
import '../features/activity/providers/activity_providers.dart';
import '../features/profile/profile_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/create_account_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/intro_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/auth/providers/auth_provider.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(Ref ref) {
    final refresh = _AuthRouterRefresh(ref);

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/intro',
      refreshListenable: refresh,
      redirect: (_, state) {
        final authState = ref.read(authProvider);
        if (authState.isLoading) return null;

        final path = state.uri.path;
        final isAuthenticated = authState.isAuthenticated;
        final isPublicRoute =
            path == '/intro' ||
            path == '/welcome' ||
            path == '/login' ||
            path == '/register' ||
            path == '/forgot-password';

        // Todo lo que no sea público requiere sesión (incluye reportes,
        // coincidencias y enlaces profundos).
        if (!isAuthenticated && !isPublicRoute) return '/welcome';
        if (isAuthenticated && isPublicRoute) return '/radar';
        return null;
      },
      routes: [
        GoRoute(
          path: '/intro',
          builder: (context, state) => const IntroScreen(),
        ),
        GoRoute(
          path: '/welcome',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 550),
            reverseTransitionDuration: const Duration(milliseconds: 400),
            child: const WelcomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(curved),
                      child: child,
                    ),
                  );
                },
          ),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 380),
            reverseTransitionDuration: const Duration(milliseconds: 320),
            child: const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(curved),
                      child: child,
                    ),
                  );
                },
          ),
        ),
        GoRoute(
          path: '/register',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: 380),
            reverseTransitionDuration: const Duration(milliseconds: 320),
            child: const CreateAccountScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(curved),
                      child: child,
                    ),
                  );
                },
          ),
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
              path: '/reports/mine',
              builder: (context, state) =>
                  const ReportsScreen(onlyMyReports: true),
            ),
            GoRoute(
              path: '/reports/:id/sighting',
              builder: (context, state) =>
                  ReportSightingScreen(reportId: state.pathParameters['id']!),
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
  _AuthRouterRefresh(Ref ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      _scheduleRefresh();
    });
    ref.onDispose(dispose);
  }

  bool _refreshScheduled = false;

  void _scheduleRefresh() {
    if (_refreshScheduled) return;
    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (!hasListeners) return;
      notifyListeners();
    });
  }
}

class ScaffoldWithNav extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNav({super.key, required this.child});

  static const _routes = [
    '/radar',
    '/explore',
    '/reports',
    '/activity',
    '/profile',
  ];

  static int _indexFromLocation(String location) {
    for (var i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);
    final unreadCount = ref.watch(unreadActivityCountProvider);

    return Scaffold(
      body: Stack(
        children: [
          // La barra flota sobre el contenido: se reserva espacio inferior
          // para que los últimos controles sigan accesibles.
          Padding(
            padding: const EdgeInsets.only(
              bottom: PetTokens.contentBottomPadding,
            ),
            child: child,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PetNavBar(
              currentIndex: currentIndex,
              onSelected: (i) => context.go(_routes[i]),
              destinations: [
                PetNavDestination(
                  icon: PhosphorIconsRegular.broadcast,
                  selectedIcon: PhosphorIconsFill.broadcast,
                  label: l10n.navigationRadar,
                ),
                PetNavDestination(
                  icon: PhosphorIconsRegular.mapTrifold,
                  selectedIcon: PhosphorIconsFill.mapTrifold,
                  label: l10n.navigationExplore,
                ),
                PetNavDestination(
                  icon: PhosphorIconsRegular.plus,
                  selectedIcon: PhosphorIconsFill.plus,
                  label: l10n.navigationReport,
                  isPrimary: true,
                ),
                PetNavDestination(
                  icon: PhosphorIconsRegular.bell,
                  selectedIcon: PhosphorIconsFill.bell,
                  label: l10n.navigationActivity,
                  badge: unreadCount > 0,
                ),
                PetNavDestination(
                  icon: PhosphorIconsRegular.userCircle,
                  selectedIcon: PhosphorIconsFill.userCircle,
                  label: l10n.navigationProfile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
