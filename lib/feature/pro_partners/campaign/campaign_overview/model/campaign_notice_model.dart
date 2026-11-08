class CampaignNoticeModel {
  final int id;
  final int campaignId;
  final String title;
  final String notice;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CampaignNoticeModel({
    required this.id,
    required this.campaignId,
    required this.title,
    required this.notice,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CampaignNoticeModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) => int.tryParse('$value') ?? 0;

    return CampaignNoticeModel(
      id: toInt(json['id']),
      campaignId: toInt(json['campaignId']),
      title: (json['title'] ?? '').toString(),
      notice: (json['notice'] ?? '').toString(),
      createdBy: json['createdBy'] == null ? null : toInt(json['createdBy']),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }
}
