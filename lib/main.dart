import 'package:flutter/material.dart';

import 'data/lesson_data.dart';
import 'screens/chat_screen.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'services/progress_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progressController = await ProgressController.create();
  runApp(KazakhLearningApp(progressController: progressController));
}

class KazakhLearningApp extends StatelessWidget {
  const KazakhLearningApp({super.key, required this.progressController});

  final ProgressController progressController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QTalk',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: AppShell(progressController: progressController),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.progressController});

  final ProgressController progressController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progressController,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: progressController.onboardingComplete
              ? MainNavigationShell(
                  key: const ValueKey('navigation'),
                  progressController: progressController,
                )
              : OnboardingScreen(
                  key: const ValueKey('onboarding'),
                  onStart: progressController.markOnboardingComplete,
                ),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key, required this.progressController});

  final ProgressController progressController;

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        progressController: widget.progressController,
        lessons: lessonCatalog,
      ),
      ChatScreen(
        progressController: widget.progressController,
        lessons: lessonCatalog,
      ),
      GameScreen(
        progressController: widget.progressController,
        lessons: lessonCatalog,
      ),
      ProfileScreen(
        progressController: widget.progressController,
        lessons: lessonCatalog,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_outlined),
            activeIcon: Icon(Icons.sports_esports_rounded),
            label: 'Games',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
