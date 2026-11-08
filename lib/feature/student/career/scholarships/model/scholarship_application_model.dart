import 'scholarship_model.dart';

class ScholarshipApplicationModel {
  final int applicationId;
  final ScholarshipModel scholarship;
  final String motivationLetter;
  final List<String> certificates;
  final String resumeUrl;
  final String transcriptUrl;
  final String recommendationLetterUrl;
  final String recruiterEmail;
  final String recruiterUrl;
  final String photoUrl;
  final String identityProofUrl;
  final String applicationFormUrl;
  final List<String> documents;
  final String gpa;
  final String applicantEmail;
  final String applicantAddress;
  final String fieldOfStudy;
  final String institution;
  final String yearOfStudy;
  final String countryOfResidence;
  final String status;
  final String reviewNotes;
  final DateTime submittedAt;
  final DateTime lastUpdated;

  ScholarshipApplicationModel({
    required this.applicationId,
    required this.scholarship,
    required this.motivationLetter,
    this.certificates = const [],
    this.resumeUrl = '',
    this.transcriptUrl = '',
    this.recommendationLetterUrl = '',
    this.recruiterEmail = '',
    this.recruiterUrl = '',
    this.photoUrl = '',
    this.identityProofUrl = '',
    this.applicationFormUrl = '',
    this.documents = const [],
    this.gpa = '0.0',
    this.applicantEmail = '',
    this.applicantAddress = '',
    this.fieldOfStudy = '',
    this.institution = '',
    this.yearOfStudy = '',
    this.countryOfResidence = '',
    this.status = 'pending',
    this.reviewNotes = '',
    required this.submittedAt,
    required this.lastUpdated,
  });

  factory ScholarshipApplicationModel.fromJson(Map<String, dynamic> json) {
    return ScholarshipApplicationModel(
      applicationId: json['applicationId'] ?? json['id'] ?? 0,
      scholarship: ScholarshipModel.fromJson(json['scholarship'] ?? {}),
      motivationLetter: json['motivationLetter'] ?? '',
      certificates: List<String>.from(json['certificates'] ?? []),
      resumeUrl: json['resumeUrl'] ?? '',
      transcriptUrl: json['transcriptUrl'] ?? '',
      recommendationLetterUrl: json['recommendationLetterUrl'] ?? '',
      recruiterEmail: json['recruiterEmail'] ?? '',
      recruiterUrl: json['recruiterUrl'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      identityProofUrl: json['identityProofUrl'] ?? '',
      applicationFormUrl: json['applicationFormUrl'] ?? '',
      documents: List<String>.from(json['documents'] ?? []),
      gpa: json['gpa']?.toString() ?? '0.0',
      applicantEmail: json['applicantEmail'] ?? '',
      applicantAddress: json['applicantAddress'] ?? '',
      fieldOfStudy: json['fieldOfStudy'] ?? '',
      institution: json['institution'] ?? '',
      yearOfStudy: json['yearOfStudy'] ?? '',
      countryOfResidence: json['countryOfResidence'] ?? '',
      status: json['status'] ?? 'pending',
      reviewNotes: json['reviewNotes'] ?? '',
      submittedAt: DateTime.parse(
        json['submittedAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
