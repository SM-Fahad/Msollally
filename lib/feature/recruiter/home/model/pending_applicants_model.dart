class PendingApplicationsResponse {
  final List<ApplicationData> applications;
  final int total;
  final int page;
  final int totalPages;

  PendingApplicationsResponse({
    required this.applications,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory PendingApplicationsResponse.fromJson(Map<String, dynamic> json) {
    return PendingApplicationsResponse(
      applications:
          (json['applications'] as List?)
              ?.map((e) => ApplicationData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class ApplicationData {
  final int id;
  final int jobId;
  final int applicantId;
  final String applicantName;
  final String jobTitle;
  final String coverLetter;
  final String resumeUrl;
  final String profilePictureUrl;
  final List<String> skills;
  final Map<String, dynamic>? metadata;

  ApplicationData({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.applicantName,
    required this.jobTitle,
    required this.coverLetter,
    required this.resumeUrl,
    required this.profilePictureUrl,
    required this.skills,
    this.metadata,
  });

  factory ApplicationData.fromJson(Map<String, dynamic> json) {
    final job = json['job'] as Map<String, dynamic>? ?? {};
    final applicant = json['applicant'] as Map<String, dynamic>? ?? {};
    final meta = json['metadata'] as Map<String, dynamic>?;

    // Safely extract full name with fallback to username, then 'Unknown'
    String fullName = 'Unknown';
    final profile = applicant['profile'] as Map<String, dynamic>?;
    if (profile != null && profile['fullName'] != null) {
      fullName = profile['fullName'].toString();
    } else if (applicant['username'] != null) {
      fullName = applicant['username'].toString();
    }

    // Extract profile picture URL
    String profilePictureUrl = '';
    if (profile != null && profile['profilePicture'] != null) {
      profilePictureUrl = profile['profilePicture'].toString();
    }

    return ApplicationData(
      id: json['id'] as int? ?? 0,
      jobId: json['jobId'] as int? ?? 0,
      applicantId: json['applicantId'] as int? ?? 0,
      applicantName: fullName,
      jobTitle: job['title']?.toString() ?? 'Job Title',
      coverLetter: json['coverLetter']?.toString() ?? '',
      resumeUrl: json['resumeUrl']?.toString() ?? '',
      profilePictureUrl: profilePictureUrl,
      skills:
          (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      metadata: meta,
    );
  }
}
