class CandidateDetailsModel {
  final String id;
  final String applicantId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String linkedIn;
  final String university;
  final String degree;
  final String department;
  final String gpa;
  final String graduationDate;
  // structured skills: list of skillsets (title + values)
  final List<SkillSet> skillSets;
  final List<String> languages;
  final List<String> activities;
  final List<String> documents;
  final String cvId;
  final String profileImageUrl;
  final String bio;
  final String jobTitle;
  final String resumeUrl;
  final String coverLetter;
  final List<String> skills;
  final int experience;
  final String status;
  final String? rejectionReason;

  CandidateDetailsModel({
    required this.id,
    required this.applicantId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.linkedIn,
    required this.university,
    required this.degree,
    required this.department,
    required this.gpa,
    required this.graduationDate,
    required this.skillSets,
    required this.languages,
    required this.activities,
    required this.documents,
    required this.cvId,
    required this.profileImageUrl,
    required this.bio,
    required this.jobTitle,
    required this.resumeUrl,
    required this.coverLetter,
    required this.skills,
    required this.experience,
    required this.status,
    this.rejectionReason,
  });

  factory CandidateDetailsModel.fromJson(
    Map<String, dynamic> json, {
    Map<int, String> universityCache = const {},
  }) {
    // Handle nested maps safely - don't force cast to specific types
    final applicant = json['applicant'] as Map?;
    final profile = (applicant != null ? applicant['profile'] : null) as Map?;
    final job = (json['job'] ?? {}) as Map;
    final metadata = (json['metadata'] ?? {}) as Map;
    final skillsList = (json['skills'] ?? []) as List<dynamic>;

    // Get university name from cache using universityId
    String universityName = '';
    if (profile != null) {
      final universityId = profile['universityId'] as int?;
      if (universityId != null && universityCache.containsKey(universityId)) {
        universityName = universityCache[universityId] ?? '';
      }
    }

    // Get applicant username as fallback for name
    String fullName = applicant?['username']?.toString() ?? '';
    if (profile != null && profile['fullName'] != null) {
      fullName = profile['fullName'].toString();
    }

    // Extract skills as non-empty list
    List<String> skillslistParsed = skillsList
        .map((s) => s.toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Extract documents (only resume URL)
    List<String> documents = [];
    final resumeUrl = json['resumeUrl']?.toString() ?? '';
    if (resumeUrl.isNotEmpty) {
      documents.add(resumeUrl);
    }

    // Extract status and rejection reason if present
    String status = json['status']?.toString() ?? 'pending';
    String? rejectionReason = json['rejectionReason']?.toString();

    return CandidateDetailsModel(
      id: json['id']?.toString() ?? '',
      applicantId:
          json['applicantId']?.toString() ?? applicant?['id']?.toString() ?? '',
      name: fullName.trim().isEmpty ? 'N/A' : fullName.trim(),
      email:
          profile?['email']?.toString() ??
          applicant?['email']?.toString() ??
          '',
      phone:
          metadata['phone']?.toString() ??
          profile?['cellPhoneNumber']?.toString() ??
          applicant?['phoneNumber']?.toString() ??
          '',
      address: profile?['location']?.toString() ?? '',
      linkedIn: metadata['linkedIn']?.toString() ?? '',
      university: universityName.trim().isEmpty ? 'N/A' : universityName.trim(),
      degree: metadata['education']?.toString() ?? '',
      department: profile?['faculty']?.toString() ?? '',
      cvId: json['cvId']?.toString() ?? '',
      gpa: '-',
      graduationDate: profile?['enrollmentYear']?.toString() ?? '',
      skillSets: skillslistParsed.isNotEmpty
          ? [SkillSet(title: 'Skills', values: skillslistParsed)]
          : [],
      languages: [],
      activities: [],
      documents: documents,
      profileImageUrl: profile?['profilePicture']?.toString() ?? '',
      bio: profile?['bio']?.toString() ?? '',
      jobTitle: job['title']?.toString() ?? '',
      resumeUrl: resumeUrl,
      coverLetter: json['coverLetter']?.toString() ?? '',
      skills: skillslistParsed,
      experience: int.tryParse(metadata['experience']?.toString() ?? '0') ?? 0,
      status: status,
      rejectionReason: rejectionReason,
    );
  }
}

class SkillSet {
  final String title;
  final List<String> values;

  SkillSet({required this.title, required this.values});
}

extension CandidateDetailsModelCopy on CandidateDetailsModel {
  CandidateDetailsModel copyWith({String? status, String? rejectionReason}) {
    return CandidateDetailsModel(
      id: id,
      applicantId: applicantId,
      name: name,
      email: email,
      phone: phone,
      cvId: cvId,
      address: address,
      linkedIn: linkedIn,
      university: university,
      degree: degree,
      department: department,
      gpa: gpa,
      graduationDate: graduationDate,
      skillSets: skillSets,
      languages: languages,
      activities: activities,
      documents: documents,
      profileImageUrl: profileImageUrl,
      bio: bio,
      jobTitle: jobTitle,
      resumeUrl: resumeUrl,
      coverLetter: coverLetter,
      skills: skills,
      experience: experience,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
