import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_screen.dart';
import '../features/focus_mode/presentation/focus_mode_placeholder_screen.dart';
import '../features/home/presentation/home_placeholder_screen.dart';
import '../features/library/presentation/library_placeholder_screen.dart';
import '../features/onboarding/data/onboarding_repository.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/permissions/presentation/permissions_placeholder_screen.dart';
import '../features/profile/presentation/profile_placeholder_screen.dart';
import '../features/progress/presentation/progress_placeholder_screen.dart';
import '../features/results/presentation/results_placeholder_screen.dart';
import '../features/study_session/presentation/study_session_placeholder_screen.dart';
import '../features/unlock_quiz/presentation/unlock_quiz_placeholder_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final onboardingSeen = ref.watch(initialOnboardingSeenProvider);

  return GoRouter(
    initialLocation: onboardingSeen ? AppRoute.auth.path : AppRoute.onboarding.path,
    routes: [
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoute.auth.path,
        name: AppRoute.auth.name,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoute.permissions.path,
        name: AppRoute.permissions.name,
        builder: (context, state) => const PermissionsPlaceholderScreen(),
      ),
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (context, state) => const HomePlaceholderScreen(),
      ),
      GoRoute(
        path: AppRoute.studySession.path,
        name: AppRoute.studySession.name,
        builder: (context, state) => const StudySessionPlaceholderScreen(),
      ),
      GoRoute(
        path: AppRoute.focusMode.path,
        name: AppRoute.focusMode.name,
        builder: (context, state) => const FocusModePlaceholderScreen(),
      ),
      GoRoute(
        path: AppRoute.unlockQuiz.path,
        name: AppRoute.unlockQuiz.name,
        builder: (context, state) => const UnlockQuizPlaceholderScreen(),
      ),
      GoRoute(
        path: AppRoute.results.path,
        name: AppRoute.results.name,
        builder: (context, state) => const ResultsPlaceholderScreen(),
      ),
      GoRoute(
        path: AppRoute.library.path,
        name: AppRoute.library.name,
        builder: (context, state) => const LibraryPlaceholderScreen(),
      ),
      GoRoute(
        path: AppRoute.progress.path,
        name: AppRoute.progress.name,
        builder: (context, state) => const ProgressPlaceholderScreen(),
      ),
      GoRoute(
        path: AppRoute.profile.path,
        name: AppRoute.profile.name,
        builder: (context, state) => const ProfilePlaceholderScreen(),
      ),
    ],
  );
});

enum AppRoute {
  onboarding('/onboarding'),
  auth('/auth'),
  permissions('/permissions'),
  home('/home'),
  studySession('/study-session'),
  focusMode('/focus-mode'),
  unlockQuiz('/unlock-quiz'),
  results('/results'),
  library('/library'),
  progress('/progress'),
  profile('/profile');

  const AppRoute(this.path);

  final String path;
}
