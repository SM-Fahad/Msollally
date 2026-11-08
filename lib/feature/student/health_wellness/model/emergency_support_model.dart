class EmergencySupportModel {
  final int id;
  final String title;
  final String description;
  final String type;
  final String supportType;
  final String? otherSupportType;
  final String? pdfUrl;
  final String? imageUrl;
  final String? videoUrl;
  final String createdAt;
  final String updatedAt;

  EmergencySupportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.supportType,
    this.otherSupportType,
    this.pdfUrl,
    this.imageUrl,
    this.videoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmergencySupportModel.fromJson(Map<String, dynamic> json) {
    return EmergencySupportModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      supportType: json['supportType'] ?? '',
      otherSupportType: json['otherSupportType'],
      pdfUrl: json['pdfUrl'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
