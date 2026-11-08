class CampaignStatsModel {
  final int campaignId;
  final String title;
  final int impressions;
  final int clicks;
  final double ctr;
  final List<CampaignMajorPercentage> majorPercentages;
  final String totalBudget;
  final String spentBudget;
  final double remainingBudget;
  final String status;
  final bool isSponsored;
  final DateTime? startDate;
  final DateTime? endDate;

  const CampaignStatsModel({
    required this.campaignId,
    required this.title,
    required this.impressions,
    required this.clicks,
    required this.ctr,
    required this.majorPercentages,
    required this.totalBudget,
    required this.spentBudget,
    required this.remainingBudget,
    required this.status,
    required this.isSponsored,
    required this.startDate,
    required this.endDate,
  });

  factory CampaignStatsModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) => int.tryParse('$value') ?? 0;
    double toDouble(dynamic value) => double.tryParse('$value') ?? 0;

    final rawMajors = json['majorPercentages'];
    return CampaignStatsModel(
      campaignId: toInt(json['campaignId']),
      title: (json['title'] ?? '').toString(),
      impressions: toInt(json['impressions']),
      clicks: toInt(json['clicks']),
      ctr: toDouble(json['ctr']),
      majorPercentages: rawMajors is List
          ? rawMajors
                .whereType<Map>()
                .map(
                  (e) => CampaignMajorPercentage.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
      totalBudget: (json['totalBudget'] ?? '0').toString(),
      spentBudget: (json['spentBudget'] ?? '0').toString(),
      remainingBudget: toDouble(json['remainingBudget']),
      status: (json['status'] ?? '').toString(),
      isSponsored: json['isSponsored'] is bool
          ? json['isSponsored'] as bool
          : false,
      startDate: DateTime.tryParse((json['startDate'] ?? '').toString()),
      endDate: DateTime.tryParse((json['endDate'] ?? '').toString()),
    );
  }
}

class CampaignMajorPercentage {
  final String major;
  final double percentage;

  const CampaignMajorPercentage({
    required this.major,
    required this.percentage,
  });

  factory CampaignMajorPercentage.fromJson(Map<String, dynamic> json) {
    return CampaignMajorPercentage(
      major: (json['major'] ?? json['name'] ?? 'Other').toString(),
      percentage:
          double.tryParse('${json['percentage'] ?? json['value'] ?? 0}') ?? 0,
    );
  }
}
