class CandidateModel {
  final String id;
  final String name;
  final String institution;
  final String department;
  final String profileImageUrl;
  final double gpa;
  final List<String> skills;

  CandidateModel({
    required this.id,
    required this.name,
    required this.institution,
    required this.department,
    required this.profileImageUrl,
    required this.gpa,
    required this.skills,
  });
}

class JobApplicantModel {
  final int id;
  final int applicantId;
  final String name;
  final String jobTitle;
  final String profileImageUrl;
  final List<String> skills;
  final String resumeUrl;
  final String coverLetter;
  final String universityName;
  final String departmentName;

  JobApplicantModel({
    required this.id,
    required this.applicantId,
    required this.name,
    required this.jobTitle,
    required this.profileImageUrl,
    required this.skills,
    required this.resumeUrl,
    required this.coverLetter,
    this.universityName = '',
    this.departmentName = '',
  });
}

class JobApplicationsResponse {
  final List<dynamic> applications;
  final int total;
  final int page;
  final int totalPages;

  JobApplicationsResponse({
    required this.applications,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory JobApplicationsResponse.fromJson(Map<String, dynamic> json) {
    return JobApplicationsResponse(
      applications: json['applications'] ?? [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class FilterOptions {
  String? universityName;
  String? grade;
  String? skills;

  FilterOptions({this.universityName, this.grade, this.skills});

  void clear() {
    universityName = null;
    grade = null;
    skills = null;
  }
}
