import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusstudy_ai/app/app.dart';

void main() {
  testWidgets('app starts on onboarding route', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FocusStudyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Onboarding'), findsWidgets);
  });
}
