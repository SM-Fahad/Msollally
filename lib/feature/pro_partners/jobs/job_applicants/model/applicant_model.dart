class ApplicantModel {
  final String id;
  final String applicationId;
  final String jobId;
  final String applicantId;
  final String name;
  final String phone;
  final String linkedIn;
  final String education;
  final String degree;
  final String university;
  final String year;
  final String gpa;
  final int experience;
  final List<String> skills;
  final String status;
  final String coverLetter;
  final String resumeUrl;
  final String rejectionReason;
  final String appliedAt;
  final String updatedAt;
  final String reviewedAt;
  final String cvId;
  final Map<String, dynamic>? cv;
  final String avatar;

  ApplicantModel({
    required this.id,
    required this.applicationId,
    required this.jobId,
    required this.applicantId,
    required this.name,
    required this.phone,
    required this.linkedIn,
    required this.education,
    required this.degree,
    required this.university,
    required this.year,
    required this.gpa,
    required this.experience,
    required this.skills,
    required this.status,
    required this.coverLetter,
    required this.resumeUrl,
    required this.rejectionReason,
    required this.appliedAt,
    required this.updatedAt,
    required this.reviewedAt,
    required this.cvId,
    required this.cv,
    required this.avatar,
  });

  factory ApplicantModel.fromJson(Map<String, dynamic> json) {
    final applicant = _mapValue(json['applicant']);
    final profile = _mapValue(applicant['profile']);
    final metadata = _mapValue(json['metadata']);
    final cvMap = _mapValue(json['cv']);

    return ApplicantModel(
      id: _text(json['id']),
      applicationId: _firstText([json['applicationId'], json['id']]),
      jobId: _text(json['jobId']),
      applicantId: _firstText([json['applicantId'], applicant['id']]),
      name: _firstText([
        profile['fullName'],
        applicant['fullName'],
        applicant['username'],
        metadata['name'],
      ], fallback: 'Unknown Applicant'),
      phone: _firstText([metadata['phone'], applicant['phoneNumber']]),
      linkedIn: _firstText([metadata['linkedIn'], metadata['linkedin']]),
      education: _firstText([metadata['education']]),
      degree: _firstText([metadata['degree'], metadata['education']]),
      university: _firstText([metadata['university'], metadata['institution']]),
      year: _firstText([metadata['year'], metadata['yearOfStudy']]),
      gpa: _firstText([metadata['gpa']]),
      experience: _intValue(metadata['experience']),
      skills: _listValue(json['skills']),
      status: _firstText([json['status']], fallback: 'pending'),
      coverLetter: _text(json['coverLetter']),
      resumeUrl: _firstText([
        json['resumeUrl'],
        cvMap['url'],
        cvMap['resumeUrl'],
        cvMap['fileUrl'],
      ]),
      rejectionReason: _text(json['rejectionReason']),
      appliedAt: _firstText([json['createdAt'], json['appliedAt']]),
      updatedAt: _text(json['updatedAt']),
      reviewedAt: _firstText([json['reviewedAt'], json['updatedAt']]),
      cvId: _firstText([json['cvId'], cvMap['id']]),
      cv: cvMap.isEmpty ? null : cvMap,
      avatar: _firstText([
        profile['profilePicture'],
        profile['avatar'],
        applicant['profileImage'],
        applicant['avatar'],
      ]),
    );
  }

  static Map<String, dynamic> _mapValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  static List<String> _listValue(dynamic value) {
    if (value is! List) {
      return <String>[];
    }

    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty && item.toLowerCase() != 'null')
        .toList();
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _text(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.toLowerCase() == 'null' ? '' : text;
  }

  static String _firstText(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final text = _text(value);
      if (text.isNotEmpty) {
        return text;
      }
    }
    return fallback;
  }
}
