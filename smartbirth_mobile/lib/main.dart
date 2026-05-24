import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';
import 'pages/splash_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/anatomy_page.dart';
import 'pages/mechanism_page.dart';
import 'pages/calibration_page.dart';
import 'pages/dilation_page.dart';
import 'pages/quiz_page.dart';
import 'pages/badge_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SmartBirthApp(),
    ),
  );
}

// Global state provider for progress, coins, XP, and active theme
class SmartBirthState {
  final int xp;
  final int coins;
  final Map<String, bool> completedStages;
  final Map<String, bool> checklist;
  final int dilationHighScore;
  final int quizHighScore;
  final String studentName;
  final String theme; // 'warm' or 'blue'

  SmartBirthState({
    required this.xp,
    required this.coins,
    required this.completedStages,
    required this.checklist,
    required this.dilationHighScore,
    required this.quizHighScore,
    required this.studentName,
    required this.theme,
  });

  SmartBirthState copyWith({
    int? xp,
    int? coins,
    Map<String, bool>? completedStages,
    Map<String, bool>? checklist,
    int? dilationHighScore,
    int? quizHighScore,
    String? studentName,
    String? theme,
  }) {
    return SmartBirthState(
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      completedStages: completedStages ?? this.completedStages,
      checklist: checklist ?? this.checklist,
      dilationHighScore: dilationHighScore ?? this.dilationHighScore,
      quizHighScore: quizHighScore ?? this.quizHighScore,
      studentName: studentName ?? this.studentName,
      theme: theme ?? this.theme,
    );
  }
}

class SmartBirthStateNotifier extends StateNotifier<SmartBirthState> {
  SmartBirthStateNotifier()
      : super(
          SmartBirthState(
            xp: 0,
            coins: 0,
            completedStages: {
              'stage1': false,
              'stage2': false,
              'stage3': false,
              'stage4': false,
              'stage5': false,
            },
            checklist: {
              'scissors': false,
              'clamp': false,
              'bulb': false,
              'gloves': false,
            },
            dilationHighScore: 0,
            quizHighScore: 0,
            studentName: '',
            theme: 'warm',
          ),
        );

  void addRewards(int xpToAdd, int coinsToAdd) {
    state = state.copyWith(
      xp: state.xp + xpToAdd,
      coins: state.coins + coinsToAdd,
    );
  }

  void toggleTheme() {
    state = state.copyWith(
      theme: state.theme == 'warm' ? 'blue' : 'warm',
    );
  }

  void completeStage(String stageKey) {
    final updatedCompleted = Map<String, bool>.from(state.completedStages);
    updatedCompleted[stageKey] = true;
    state = state.copyWith(completedStages: updatedCompleted);
  }

  void toggleChecklist(String id) {
    final updatedChecklist = Map<String, bool>.from(state.checklist);
    final wasChecked = updatedChecklist[id] ?? false;
    updatedChecklist[id] = !wasChecked;
    state = state.copyWith(checklist: updatedChecklist);
    if (!wasChecked) {
      addRewards(15, 5); // checklist bonus
    }
  }

  void updateDilationScore(int score) {
    if (score > state.dilationHighScore) {
      state = state.copyWith(dilationHighScore: score);
    }
  }

  void updateQuizScore(int score) {
    if (score > state.quizHighScore) {
      state = state.copyWith(quizHighScore: score);
    }
  }

  void updateName(String name) {
    state = state.copyWith(studentName: name);
  }

  void resetProgress() {
    state = SmartBirthState(
      xp: 0,
      coins: 0,
      completedStages: {
        'stage1': false,
        'stage2': false,
        'stage3': false,
        'stage4': false,
        'stage5': false,
      },
      checklist: {
        'scissors': false,
        'clamp': false,
        'bulb': false,
        'gloves': false,
      },
      dilationHighScore: 0,
      quizHighScore: 0,
      studentName: '',
      theme: 'warm',
    );
  }
}

final smartBirthStateProvider =
    StateNotifierProvider<SmartBirthStateNotifier, SmartBirthState>((ref) {
  return SmartBirthStateNotifier();
});

class SmartBirthApp extends ConsumerWidget {
  const SmartBirthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(smartBirthStateProvider);

    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/stage1',
          builder: (context, state) => const AnatomyPage(),
        ),
        GoRoute(
          path: '/stage2',
          builder: (context, state) => const MechanismPage(),
        ),
        GoRoute(
          path: '/stage3',
          builder: (context, state) => const CalibrationPage(),
        ),
        GoRoute(
          path: '/stage4',
          builder: (context, state) => const DilationPage(),
        ),
        GoRoute(
          path: '/stage5',
          builder: (context, state) => const QuizPage(),
        ),
        GoRoute(
          path: '/stage6',
          builder: (context, state) => const BadgePage(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'SmartBirth Quest',
      theme: buildSmartBirthTheme(themeName: state.theme),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
