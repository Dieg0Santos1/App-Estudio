import '../../../core/models/study_enums.dart';
import '../../../core/network/json_helpers.dart';

class StudyMaterial {
  const StudyMaterial({
    required this.id,
    required this.userId,
    required this.title,
    required this.fileType,
    required this.analysisStatus,
    required this.createdAt,
    this.fileUrl,
    this.extractedText,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      fileType: json['file_type'] as String,
      fileUrl: json['file_url'] as String?,
      extractedText: json['extracted_text'] as String?,
      analysisStatus: MaterialAnalysisStatus.fromJson(json['analysis_status'] as String),
      createdAt: parseDateTime(json['created_at']),
    );
  }

  final String id;
  final String userId;
  final String title;
  final String fileType;
  final String? fileUrl;
  final String? extractedText;
  final MaterialAnalysisStatus analysisStatus;
  final DateTime createdAt;
}
