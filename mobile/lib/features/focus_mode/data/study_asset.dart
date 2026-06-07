import '../../../core/models/study_enums.dart';
import '../../../core/network/json_helpers.dart';

class StudyAsset {
  const StudyAsset({
    required this.id,
    required this.sessionId,
    required this.assetType,
    required this.title,
    required this.content,
    required this.orderIndex,
    required this.createdAt,
    this.materialId,
  });

  factory StudyAsset.fromJson(Map<String, dynamic> json) {
    return StudyAsset(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      materialId: json['material_id'] as String?,
      assetType: StudyAssetType.fromJson(json['asset_type'] as String),
      title: json['title'] as String,
      content: parseJsonMap(json['content']),
      orderIndex: json['order_index'] as int,
      createdAt: parseDateTime(json['created_at']),
    );
  }

  final String id;
  final String sessionId;
  final String? materialId;
  final StudyAssetType assetType;
  final String title;
  final Map<String, dynamic> content;
  final int orderIndex;
  final DateTime createdAt;
}
