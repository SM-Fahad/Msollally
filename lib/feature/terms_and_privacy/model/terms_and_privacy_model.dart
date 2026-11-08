class TermsAndPrivacyModel {
  final int? id;
  final String? title;
  final String? content;
  final String? type;
  final String? createdAt;
  final String? updatedAt;

  TermsAndPrivacyModel({
    this.id,
    this.title,
    this.content,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory TermsAndPrivacyModel.fromJson(Map<String, dynamic> json) {
    return TermsAndPrivacyModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
