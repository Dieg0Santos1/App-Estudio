import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusstudy_ai/app/app.dart';
import 'package:focusstudy_ai/features/onboarding/data/onboarding_repository.dart';

void main() {
  testWidgets('app starts on onboarding route', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [initialOnboardingSeenProvider.overrideWithValue(false)],
        child: const FocusStudyApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Convierte tu celular en una herramienta de estudio.'), findsOneWidget);
  });

  testWidgets('auth screen switches to sign up mode', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [initialOnboardingSeenProvider.overrideWithValue(true)],
        child: const FocusStudyApp(),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('Crear cuenta'));
    await tester.tap(find.text('Crear cuenta'));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Crear tu cuenta'), findsNothing);
    expect(find.text('Crear cuenta'), findsWidgets);
  });
}
