class NotificationPreferenceModel {
  final int? id;
  final int? userId;
  final String? type;
  final String? category;
  final bool inAppEnabled;
  final bool emailEnabled;
  final bool pushEnabled;
  final String? createdAt;
  final String? updatedAt;

  NotificationPreferenceModel({
    this.id,
    this.userId,
    this.type,
    this.category,
    this.inAppEnabled = true,
    this.emailEnabled = true,
    this.pushEnabled = true,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      category: json['category'],
      inAppEnabled: json['inAppEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? true,
      pushEnabled: json['pushEnabled'] ?? true,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type ?? 'grade_update',
      'category': category ?? 'all',
      'inAppEnabled': inAppEnabled,
      'emailEnabled': emailEnabled,
      'pushEnabled': pushEnabled,
    };
  }
}
