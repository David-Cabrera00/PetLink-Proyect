import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petlink/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

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
        final isProtected =
            path == '/radar' ||
            path == '/explore' ||
            path == '/activity' ||
            path == '/profile' ||
            path == '/report/new' ||
            path.startsWith('/report/new/');
        final isAuthRoute =
            path == '/intro' ||
            path == '/welcome' ||
            path == '/login' ||
            path == '/register';

        if (!isAuthenticated && isProtected) return '/welcome';
        if (isAuthenticated && isAuthRoute) return '/radar';
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
          builder: (context, state) => const LoginScreen(),
        ),
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
    final cs = Theme.of(context).colorScheme;
    final selectionAlignment = switch (currentIndex) {
      0 => Alignment.centerLeft,
      1 => const Alignment(-0.5, 0),
      2 => Alignment.center,
      3 => const Alignment(0.5, 0),
      _ => Alignment.centerRight,
    };

    return Scaffold(
      body: Stack(
        children: [
          // The navigation bar floats above the shell content. Reserve its
          // space so the last controls on long screens remain reachable.
          Padding(
            padding: const EdgeInsets.only(bottom: 96),
            child: child,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.52),
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.34),
                      Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.20),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.34),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 26,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 7,
                  ),
                  child: SizedBox(
                    height: 58,
                    child: Stack(
                      children: [
                        IgnorePointer(
                          child: AnimatedAlign(
                            alignment: selectionAlignment,
                            duration: const Duration(milliseconds: 360),
                            curve: Curves.easeOutBack,
                            child: FractionallySizedBox(
                              widthFactor: 0.2,
                              heightFactor: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: currentIndex == 2
                                        ? cs.primary
                                        : cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.24,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                      color: cs.primary
                                            .withValues(alpha: 0.22),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            _LiquidNavItem(
                              icon: PhosphorIconsRegular.radar,
                              selectedIcon: PhosphorIconsFill.radar,
                              label: l10n.navigationRadar,
                              selected: currentIndex == 0,
                              onTap: () => context.go('/radar'),
                            ),
                            _LiquidNavItem(
                              icon: PhosphorIconsRegular.mapTrifold,
                              selectedIcon: PhosphorIconsFill.mapTrifold,
                              label: l10n.navigationExplore,
                              selected: currentIndex == 1,
                              onTap: () => context.go('/explore'),
                            ),
                            _LiquidNavItem(
                              icon: PhosphorIconsRegular.plusCircle,
                              selectedIcon: PhosphorIconsFill.plusCircle,
                              label: l10n.navigationReport,
                              selected: currentIndex == 2,
                              isPrimary: true,
                              onTap: () => context.go('/reports'),
                            ),
                            _LiquidNavItem(
                              icon: PhosphorIconsRegular.bell,
                              selectedIcon: PhosphorIconsFill.bell,
                              label: l10n.navigationActivity,
                              selected: currentIndex == 3,
                              onTap: () => context.go('/activity'),
                            ),
                            _LiquidNavItem(
                              icon: PhosphorIconsRegular.userCircle,
                              selectedIcon: PhosphorIconsFill.userCircle,
                              label: l10n.navigationProfile,
                              selected: currentIndex == 4,
                              onTap: () => context.go('/profile'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiquidNavItem extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final bool isPrimary;
  final VoidCallback onTap;

  const _LiquidNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  State<_LiquidNavItem> createState() => _LiquidNavItemState();
}

class _LiquidNavItemState extends State<_LiquidNavItem> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (mounted && _pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedForeground = widget.isPrimary
        ? cs.onPrimary
        : cs.onPrimaryContainer;

    return Expanded(
      child: Semantics(
        button: true,
        selected: widget.selected,
        label: widget.label,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          borderRadius: BorderRadius.circular(22),
          splashColor: cs.primary.withValues(
            alpha: 0.16,
          ),
          highlightColor: cs.primary.withValues(alpha: 0.08),
          child: AnimatedScale(
            scale: _pressed ? 0.94 : 1,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: Icon(
                      widget.selected ? widget.selectedIcon : widget.icon,
                      key: ValueKey(widget.selected),
                      size: 22,
                      color: widget.selected
                          ? selectedForeground
                          : cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: widget.selected
                          ? selectedForeground
                          : cs.onSurfaceVariant,
                      fontWeight: widget.selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
