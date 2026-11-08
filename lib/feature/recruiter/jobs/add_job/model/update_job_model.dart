import 'add_job_model.dart';

class UpdateJobModel {
  final String title;
  final String department;
  final String location;
  final String jobType;
  final String? salaryType;
  final String? minimumSalary;
  final String? maximumSalary;
  final String? otherJobType;     // only sent when jobType == 'other'
  final String description;
  final List<String> responsibilities;
  final List<String> requirements;
  final List<String> benefits;
  final List<String> professionalSkills;
  final List<String> otherFacilities;
  final String experienceLevel;
  final int minimumExperience;
  final int maximumExperience;
  final DateTime applicationDeadline;
  final String companyName;
  final String companyLogo;

  UpdateJobModel({
    required this.title,
    required this.department,
    required this.location,
    required this.jobType,
    this.salaryType,
    this.minimumSalary,
    this.maximumSalary,
    this.otherJobType,
    required this.description,
    required this.responsibilities,
    required this.requirements,
    required this.benefits,
    required this.professionalSkills,
    required this.otherFacilities,
    required this.experienceLevel,
    required this.minimumExperience,
    required this.maximumExperience,
    required this.applicationDeadline,
    required this.companyName,
    required this.companyLogo,
  });

  factory UpdateJobModel.fromAddJob(AddJobModel job) {
    return UpdateJobModel(
      title: job.title,
      department: job.department,
      location: job.location,
      jobType: job.jobType,
      salaryType: job.salaryType,
      minimumSalary: job.minimumSalary,
      maximumSalary: job.maximumSalary,
      otherJobType: job.otherJobType,
      description: job.description,
      responsibilities: job.responsibilities,
      requirements: job.requirements,
      benefits: job.benefits,
      professionalSkills: job.professionalSkills,
      otherFacilities: job.otherFacilities,
      experienceLevel: job.experienceLevel,
      minimumExperience: job.minimumExperience,
      maximumExperience: job.maximumExperience,
      applicationDeadline: job.applicationDeadline,
      companyName: job.companyName,
      companyLogo: job.companyLogo,
    );
  }

  factory UpdateJobModel.fromJson(Map<String, dynamic> json) {
    return UpdateJobModel(
      title: json['title']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      jobType: json['jobType']?.toString() ?? '',
      salaryType: json['salaryType']?.toString(),
      minimumSalary: json['minimumSalary']?.toString(),
      maximumSalary: json['maximumSalary']?.toString(),
      otherJobType: json['otherJobType']?.toString(),
      description: json['description']?.toString() ?? '',
      responsibilities: _readStringList(json['responsibilities']),
      requirements: _readStringList(json['requirements']),
      benefits: _readStringList(json['benefits']),
      professionalSkills: _readStringList(json['professionalSkills']),
      otherFacilities: _readStringList(json['otherFacilities']),
      experienceLevel: json['experienceLevel']?.toString() ?? '',
      minimumExperience: _readInt(json['minimumExperience']),
      maximumExperience: _readInt(json['maximumExperience']),
      applicationDeadline:
          DateTime.tryParse(json['applicationDeadline']?.toString() ?? '') ??
          DateTime.now(),
      companyName: json['companyName']?.toString() ?? '',
      companyLogo: json['companyLogo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'department': department,
      'location': location,
      'jobType': jobType,
      if (salaryType != null) 'salaryType': salaryType,
      if (minimumSalary != null) 'minimumSalary': minimumSalary,
      if (maximumSalary != null) 'maximumSalary': maximumSalary,
      if (otherJobType != null && jobType == 'other') 'otherJobType': otherJobType,
      'description': description,
      'responsibilities': responsibilities,
      'requirements': requirements,
      'benefits': benefits,
      'professionalSkills': professionalSkills,
      'otherFacilities': otherFacilities,
      'experienceLevel': experienceLevel,
      'minimumExperience': minimumExperience,
      'maximumExperience': maximumExperience,
      'applicationDeadline': applicationDeadline.toUtc().toIso8601String(),
      'companyName': companyName,
      'companyLogo': companyLogo,
    };
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return double.tryParse(value?.toString() ?? '')?.round() ?? 0;
  }

  static List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return [];

    return text
        .split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
