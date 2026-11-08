class CampaignModel {
  final int id;
  final String title;
  final String status;
  final int clicks;
  final double ctr;
  final double spent;
  final String imageOrVideoLink;
  final String description;
  final String caption;
  final String destinationUrl;
  final String callToAction;
  final double totalBudget;
  final DateTime? startDate;
  final DateTime? endDate;
  final String university;
  final String gender;
  final String major;
  final String yearOfStudy;
  final bool isSponsored;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String companyName;
  final String companyLogo;

  CampaignModel({
    required this.id,
    required this.title,
    required this.status,
    required this.clicks,
    required this.ctr,
    required this.spent,
    required this.imageOrVideoLink,
    required this.description,
    required this.caption,
    required this.destinationUrl,
    required this.callToAction,
    required this.totalBudget,
    required this.startDate,
    required this.endDate,
    required this.university,
    required this.gender,
    required this.major,
    required this.yearOfStudy,
    required this.isSponsored,
    required this.createdAt,
    required this.updatedAt,
    this.companyName = '',
    this.companyLogo = '',
  });
}
