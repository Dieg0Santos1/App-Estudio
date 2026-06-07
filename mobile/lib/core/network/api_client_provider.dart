import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/supabase_auth_provider.dart';
import '../config/app_config_provider.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final supabase = ref.watch(supabaseClientProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final accessToken = supabase?.auth.currentSession?.accessToken;
        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }

        handler.next(options);
      },
    ),
  );

  return dio;
});
