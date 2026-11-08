class RecruiterStatsModel {
  final int totalJobs;
  final int activeJobs;
  final int closedJobs;
  final int draftJobs;
  final int totalApplications;
  final int totalViews;
  final int appliedToday;

  RecruiterStatsModel({
    required this.totalJobs,
    required this.activeJobs,
    required this.closedJobs,
    required this.draftJobs,
    required this.totalApplications,
    required this.totalViews,
    required this.appliedToday,
  });

  factory RecruiterStatsModel.fromJson(Map<String, dynamic> json) {
    return RecruiterStatsModel(
      totalJobs: json['totalJobs'] as int? ?? 0,
      activeJobs: json['activeJobs'] as int? ?? 0,
      closedJobs: json['closedJobs'] as int? ?? 0,
      draftJobs: json['draftJobs'] as int? ?? 0,
      totalApplications: json['totalApplications'] as int? ?? 0,
      totalViews: json['totalViews'] as int? ?? 0,
      appliedToday: json['appliedToday'] as int? ?? 0,
    );
  }
}
