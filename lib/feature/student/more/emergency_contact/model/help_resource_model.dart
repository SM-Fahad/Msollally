class HelpResourceModel {
  final int id;
  final String resourceName;
  final String category;
  final String? otherCategory;
  final String summary;
  final String description;
  final String? imageUrl;
  final String? videoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HelpResourceModel({
    required this.id,
    required this.resourceName,
    required this.category,
    this.otherCategory,
    required this.summary,
    required this.description,
    this.imageUrl,
    this.videoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory HelpResourceModel.fromJson(Map<String, dynamic> json) {
    return HelpResourceModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      resourceName: json['resourceName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      otherCategory: json['otherCategory'] as String?,
      summary: json['summary'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }
}
