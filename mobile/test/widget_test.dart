import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusstudy_ai/app/app.dart';
import 'package:focusstudy_ai/features/onboarding/data/onboarding_repository.dart';
import 'package:focusstudy_ai/features/permissions/data/device_permissions.dart';
import 'package:focusstudy_ai/features/permissions/presentation/permissions_screen.dart';

void main() {
  testWidgets('app starts on onboarding route', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [initialOnboardingSeenProvider.overrideWithValue(false)],
        child: const FocusStudyApp(),
      ),
    );
    await tester.pump();

    expect(
      find.text('Convierte tu celular en una herramienta de estudio.'),
      findsOneWidget,
    );
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

  testWidgets('permissions screen shows ready state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          devicePermissionsProvider.overrideWithValue(
            const _FakeDevicePermissionsService(
              PermissionSnapshot(
                notificationsAllowed: true,
                usageAccessAllowed: true,
                overlayAllowed: true,
                isAndroid: true,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: PermissionsScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Configura tu modo de enfoque'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
    expect(find.text('Activo'), findsWidgets);
  });
}

class _FakeDevicePermissionsService implements DevicePermissionsService {
  const _FakeDevicePermissionsService(this.snapshot);

  final PermissionSnapshot snapshot;

  @override
  Future<PermissionSnapshot> load() async => snapshot;

  @override
  Future<void> openOverlaySettings() async {}

  @override
  Future<void> openUsageAccessSettings() async {}

  @override
  Future<void> requestNotifications() async {}
}
