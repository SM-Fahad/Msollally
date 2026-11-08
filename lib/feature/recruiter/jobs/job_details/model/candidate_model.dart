class CandidateModel {
  final int id;
  final int jobId;
  final int applicantId;
  final String name;
  final String phoneNumber;
  final String education;
  final int experience;
  final String linkedIn;
  final String coverLetter;
  final String resumeUrl;
  final List<String> skills;
  final String status;
  final String? rejectionReason;
  final bool isShortlisted;

  CandidateModel({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.name,
    required this.phoneNumber,
    required this.education,
    required this.experience,
    required this.linkedIn,
    required this.coverLetter,
    required this.resumeUrl,
    required this.skills,
    required this.status,
    this.rejectionReason,
    this.isShortlisted = false,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>? ?? {};
    final applicant = json['applicant'] as Map<String, dynamic>? ?? {};

    return CandidateModel(
      id: json['id'] as int? ?? 0,
      jobId: json['jobId'] as int? ?? 0,
      applicantId: json['applicantId'] as int? ?? 0,
      name: applicant['username']?.toString() ?? 'Unknown',
      phoneNumber:
          metadata['phone']?.toString() ??
          applicant['phoneNumber']?.toString() ??
          '',
      education: metadata['education']?.toString() ?? 'Not specified',
      experience: metadata['experience'] as int? ?? 0,
      linkedIn: metadata['linkedIn']?.toString() ?? '',
      coverLetter: json['coverLetter']?.toString() ?? '',
      resumeUrl: json['resumeUrl']?.toString() ?? '',
      skills:
          (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status']?.toString() ?? 'pending',
      rejectionReason: json['rejectionReason'] as String?,
      isShortlisted: false,
    );
  }
}
