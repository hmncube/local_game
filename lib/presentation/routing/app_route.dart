import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:local_game/core/routes.dart';
import 'package:local_game/presentation/crossword/crossword_screen.dart';
import 'package:local_game/presentation/models/points.dart';
import 'package:local_game/presentation/word_link/word_link_screen.dart';
import 'package:local_game/presentation/level_complete/level_complete_screen.dart';
import 'package:local_game/presentation/map/map_screen.dart';
import 'package:local_game/presentation/onboarding/onboarding_screen.dart';
import 'package:local_game/presentation/similar_words/similar_words_game_screen.dart';
import 'package:local_game/presentation/splash/splash_screen.dart';
import 'package:local_game/presentation/word_search/find_word_game_screen.dart';

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
        path: Routes.onboarding.toPath,
        name: Routes.onboarding.toNamed,
        builder: (context, state) => const OnboardingScreen(),
        pageBuilder:
            (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const OnboardingScreen(),
            ),
      ),
      GoRoute(
        path: Routes.gameScreen.toPath,
        name: Routes.gameScreen.toNamed,
        pageBuilder:
            (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: WordLinkScreen(level: (state.extra as int)),
            ),
      ),
      GoRoute(
        path: Routes.wordSearch.toPath,
        name: Routes.wordSearch.toNamed,
        builder:
            (context, state) =>
                FindWordGameScreen(levelId: (state.extra as int)),
        pageBuilder:
            (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: FindWordGameScreen(levelId: (state.extra as int)),
            ),
      ),
      GoRoute(
        path: Routes.similarWords.toPath,
        name: Routes.similarWords.toNamed,
        builder:
            (context, state) =>
                SimilarWordsGameScreen(levelId: (state.extra as int)),
        pageBuilder:
            (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: SimilarWordsGameScreen(levelId: (state.extra as int)),
            ),
      ),
      GoRoute(
        path: Routes.crosswordScreen.toPath,
        name: Routes.crosswordScreen.toNamed,
        builder: (context, state) => const CrosswordScreen(),
        pageBuilder:
            (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: const CrosswordScreen(),
            ),
      ),
      GoRoute(
        path: Routes.levelCompleteScreen.toPath,
        name: Routes.levelCompleteScreen.toNamed,
        builder:
            (context, state) =>
                LevelCompleteScreen(points: state.extra as Points),
        pageBuilder:
            (context, state) => buildPageWithDefaultTransition(
              context: context,
              state: state,
              child: LevelCompleteScreen(points: state.extra as Points),
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
