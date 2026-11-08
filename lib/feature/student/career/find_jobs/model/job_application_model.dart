import 'jobs.model.dart';

class JobApplicationModel {
  final int id;
  final int jobId;
  final String status;
  final String coverLetter;
  final String resumeUrl;
  final List<String> skills;
  final List<String> certificates;
  final String identityProofUrl;
  final String photoUrl;
  final List<String> otherDocuments;
  final String recruiterEmail;
  final String recruiterUrl;
  final String reviewNotes;
  final DateTime submittedAt;
  final DateTime? updatedAt;
  final JobModel? job;
  final String jobTitle;
  final String companyName;
  final String companyLogo;
  final String location;
  final String jobType;

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.status,
    this.coverLetter = '',
    this.resumeUrl = '',
    this.skills = const [],
    this.certificates = const [],
    this.identityProofUrl = '',
    this.photoUrl = '',
    this.otherDocuments = const [],
    this.recruiterEmail = '',
    this.recruiterUrl = '',
    this.reviewNotes = '',
    required this.submittedAt,
    this.updatedAt,
    this.job,
    this.jobTitle = '',
    this.companyName = '',
    this.companyLogo = '',
    this.location = '',
    this.jobType = '',
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    JobModel? parsedJob;
    if (json['job'] is Map<String, dynamic>) {
      parsedJob = JobModel.fromJson(json['job'] as Map<String, dynamic>);
    }

    final id = json['id'] is int
        ? json['id'] as int
        : (json['applicationId'] is int
            ? json['applicationId'] as int
            : int.tryParse('${json['id'] ?? json['applicationId']}') ?? 0);

    final jobId = json['jobId'] is int
        ? json['jobId'] as int
        : (json['job_id'] is int
            ? json['job_id'] as int
            : int.tryParse('${json['jobId'] ?? json['job_id']}') ?? parsedJob?.id ?? 0);

    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    final title = (parsedJob != null && parsedJob.title.isNotEmpty)
        ? parsedJob.title
        : (json['jobTitle'] ?? json['title'] ?? '').toString();

    final company = (parsedJob != null && parsedJob.company.isNotEmpty)
        ? parsedJob.company
        : (json['companyName'] ?? json['company'] ?? '').toString();

    final logo = (parsedJob != null && parsedJob.companyLogo.isNotEmpty)
        ? parsedJob.companyLogo
        : (json['companyLogo'] ?? json['logo'] ?? '').toString();

    final loc = (parsedJob != null && parsedJob.location.isNotEmpty)
        ? parsedJob.location
        : (json['location'] ?? '').toString();

    final jType = (parsedJob != null && parsedJob.jobTypeLabel.isNotEmpty)
        ? parsedJob.jobTypeLabel
        : (json['jobType'] ?? '').toString();

    final createdAtStr = json['createdAt'] ?? json['submittedAt'] ?? json['created_at'];
    final updatedAtStr = json['updatedAt'] ?? json['updated_at'];

    return JobApplicationModel(
      id: id,
      jobId: jobId,
      status: json['status']?.toString() ?? 'pending',
      coverLetter: json['coverLetter']?.toString() ?? '',
      resumeUrl: json['resumeUrl']?.toString() ?? '',
      skills: parseList(json['skills']),
      certificates: parseList(json['certificates']),
      identityProofUrl: json['identityProofUrl']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString() ?? '',
      otherDocuments: parseList(json['otherDocuments']),
      recruiterEmail: json['recruiterEmail']?.toString() ?? '',
      recruiterUrl: json['recruiterUrl']?.toString() ?? '',
      reviewNotes: json['reviewNotes']?.toString() ?? '',
      submittedAt: createdAtStr != null
          ? DateTime.tryParse(createdAtStr.toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: updatedAtStr != null
          ? DateTime.tryParse(updatedAtStr.toString())
          : null,
      job: parsedJob,
      jobTitle: title,
      companyName: company,
      companyLogo: logo,
      location: loc,
      jobType: jType,
    );
  }
}
