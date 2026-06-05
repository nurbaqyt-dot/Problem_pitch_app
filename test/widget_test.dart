import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:problem_pitch_app/main.dart';
import 'package:problem_pitch_app/services/progress_controller.dart';

void main() {
  testWidgets('shows the QTalk onboarding flow', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final progressController = await ProgressController.create();

    await tester.pumpWidget(
      KazakhLearningApp(progressController: progressController),
    );
    await tester.pumpAndSettle();

    expect(find.text('QTalk'), findsOneWidget);
    expect(find.text('Start Learning'), findsOneWidget);
  });
}
