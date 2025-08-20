import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/game/game_screen.dart';
import 'package:local_game/presentation/map/map_screen.dart';
import 'package:local_game/presentation/splash/splash_screen.dart';

class AppRoutes {
  static final GoRouter _router = GoRouter(
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        name: Routes.splashScreen.toNamed,
        builder: (context, state) => const SplashScreen(),
        pageBuilder:
            (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const SplashScreen(),
            ),
      ),
      GoRoute(
        path: Routes.mapScreen.toPath,
        name: Routes.mapScreen.toNamed,
        builder: (context, state) => const MapScreen(),
        pageBuilder:
            (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const MapScreen(),
            ),
      ),
      GoRoute(
        path: Routes.gameScreen.toPath,
        name: Routes.gameScreen.toNamed,
        builder: (context, state) => GameScreen(level: (state.extra as int)),
        pageBuilder:
            (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: GameScreen(level: (state.extra as int)),
            ),
      ),
    ],
  );

  static GoRouter get router => _router;

  static buildPageWithDefaultTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder:
          (context, animation, secondaryAnimation, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
