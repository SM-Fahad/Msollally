class FeedbackModel {
  int? id;
  String? title;
  String? description;
  String? category;
  String? attachmentUrl;
  String? status;
  String? adminReply;
  String? repliedAt;
  int? repliedById;
  String? internalNotes;
  int? userId;
  String? createdAt;
  String? updatedAt;

  FeedbackUserModel? repliedBy;
  List<dynamic>? replies;

  FeedbackModel({
    this.id,
    this.title,
    this.description,
    this.category,
    this.attachmentUrl,
    this.status,
    this.adminReply,
    this.repliedAt,
    this.repliedById,
    this.internalNotes,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.repliedBy,
    this.replies,
  });

  FeedbackModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    category = json['category'];
    attachmentUrl = json['attachmentUrl'];
    status = json['status'];
    adminReply = json['adminReply'];
    repliedAt = json['repliedAt'];
    repliedById = json['repliedById'];
    internalNotes = json['internalNotes'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    repliedBy = json['repliedBy'] != null ? FeedbackUserModel.fromJson(json['repliedBy']) : null;
    replies = json['replies'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['category'] = category;
    data['attachmentUrl'] = attachmentUrl;
    data['status'] = status;
    data['adminReply'] = adminReply;
    data['repliedAt'] = repliedAt;
    data['repliedById'] = repliedById;
    data['internalNotes'] = internalNotes;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (repliedBy != null) {
      data['repliedBy'] = repliedBy!.toJson();
    }
    data['replies'] = replies;
    return data;
  }
}

class FeedbackUserModel {
  int? id;
  String? username;
  String? role;

  FeedbackUserModel({this.id, this.username, this.role});

  FeedbackUserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['role'] = role;
    return data;
  }
}
