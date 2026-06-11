import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/config/app_config_provider.dart';
import 'features/onboarding/data/onboarding_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF061B34),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final config = AppConfig.fromEnvironment();
  final onboardingSeen = await OnboardingRepository.loadSeen();

  if (config.isSupabaseConfigured) {
    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabaseAnonKey,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        initialOnboardingSeenProvider.overrideWithValue(onboardingSeen),
      ],
      child: const FocusStudyApp(),
    ),
  );
}
