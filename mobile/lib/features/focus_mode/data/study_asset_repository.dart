import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import '../../../core/network/api_exception.dart';
import 'study_asset.dart';

final studyAssetRepositoryProvider = Provider<StudyAssetRepository>((ref) {
  return StudyAssetRepository(ref.watch(apiClientProvider));
});

final studyAssetsProvider =
    FutureProvider.autoDispose.family<List<StudyAsset>, String>((ref, sessionId) {
  return ref.watch(studyAssetRepositoryProvider).listAssets(sessionId);
});

class StudyAssetRepository {
  const StudyAssetRepository(this._client);

  final Dio _client;

  Future<List<StudyAsset>> listAssets(String sessionId) async {
    return _guard(() async {
      final response = await _client.get<Map<String, dynamic>>(
        '/study-sessions/$sessionId/assets',
      );
      return _parseAssets(response.data);
    });
  }

  Future<List<StudyAsset>> generateAssets({
    required String sessionId,
    bool forceRegenerate = false,
  }) async {
    return _guard(() async {
      final response = await _client.post<Map<String, dynamic>>(
        '/study-sessions/$sessionId/assets',
        data: {'force_regenerate': forceRegenerate},
      );
      return _parseAssets(response.data);
    });
  }

  List<StudyAsset> _parseAssets(Map<String, dynamic>? json) {
    final assets = json?['assets'] as List<dynamic>? ?? const [];
    return assets
        .cast<Map<String, dynamic>>()
        .map(StudyAsset.fromJson)
        .toList(growable: false);
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
