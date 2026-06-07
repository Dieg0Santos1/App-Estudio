import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client_provider.dart';
import '../../../core/network/api_exception.dart';
import 'study_material.dart';

final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return MaterialRepository(ref.watch(apiClientProvider));
});

final materialsProvider = FutureProvider.autoDispose<List<StudyMaterial>>((ref) {
  return ref.watch(materialRepositoryProvider).listMaterials();
});

class MaterialRepository {
  const MaterialRepository(this._client);

  final Dio _client;

  Future<List<StudyMaterial>> listMaterials() async {
    return _guard(() async {
      final response = await _client.get<List<dynamic>>('/materials');
      return (response.data ?? const [])
          .cast<Map<String, dynamic>>()
          .map(StudyMaterial.fromJson)
          .toList(growable: false);
    });
  }

  Future<StudyMaterial> getMaterial(String materialId) async {
    return _guard(() async {
      final response = await _client.get<Map<String, dynamic>>('/materials/$materialId');
      return StudyMaterial.fromJson(response.data ?? const {});
    });
  }

  Future<StudyMaterial> createTextMaterial({
    required String title,
    required String content,
  }) async {
    return _guard(() async {
      final response = await _client.post<Map<String, dynamic>>(
        '/materials/text',
        data: {'title': title, 'content': content},
      );
      return StudyMaterial.fromJson(response.data?['material'] as Map<String, dynamic>);
    });
  }

  Future<StudyMaterial> uploadMaterial({
    required String filePath,
    String? title,
  }) async {
    return _guard(() async {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        if (title != null && title.isNotEmpty) 'title': title,
      });
      final response = await _client.post<Map<String, dynamic>>(
        '/materials/upload',
        data: formData,
      );
      return StudyMaterial.fromJson(response.data?['material'] as Map<String, dynamic>);
    });
  }

  Future<void> deleteMaterial(String materialId) async {
    return _guard(() => _client.delete<void>('/materials/$materialId'));
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
