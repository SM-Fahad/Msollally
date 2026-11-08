class JobDetailsModel {
  final int? id;
  final String title;
  final String status;
  final String salary;
  final String type;
  final String location;
  final String experience;
  final String education;
  final String deadline;
  final List<String> skills;
  final String about;
  final String department;
  final String jobType;
  final String? otherJobType;   // populated only when jobType == 'other'
  final String salaryType;
  final int minimumSalary;
  final int maximumSalary;
  final String description;
  final List<String> responsibilities;
  final List<String> requirements;
  final List<String> benefits;
  final List<String> professionalSkills;
  final List<String> otherFacilities;
  final String experienceLevel;
  final int minimumExperience;
  final int maximumExperience;
  final DateTime? applicationDeadline;
  final String companyName;
  final String companyLogo;

  JobDetailsModel({
    this.id,
    required this.title,
    required this.status,
    required this.salary,
    required this.type,
    required this.location,
    required this.experience,
    required this.education,
    required this.deadline,
    required this.skills,
    required this.about,
    required this.department,
    required this.jobType,
    this.otherJobType,
    required this.salaryType,
    required this.minimumSalary,
    required this.maximumSalary,
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

  factory JobDetailsModel.fromJson(Map<String, dynamic> json) {
    final minSalary = json['minimumSalary']?.toString() ?? '0';
    final maxSalary = json['maximumSalary']?.toString() ?? '0';
    final salaryType = json['salaryType']?.toString() ?? '';

    final minExp = _readInt(json['minimumExperience']);
    final maxExp = _readInt(json['maximumExperience']);

    final minSalaryNum = _readInt(minSalary);
    final maxSalaryNum = _readInt(maxSalary);

    final description = json['description']?.toString() ?? '';
    final responsibilities =
        (json['responsibilities'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final benefits =
        (json['benefits'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final otherFacilities =
        (json['otherFacilities'] as List?)?.map((e) => e.toString()).toList() ??
        [];

    // Format about section
    final aboutParts = <String>[];
    if (description.isNotEmpty) {
      aboutParts.add(description);
    }

    if (responsibilities.isNotEmpty) {
      aboutParts.add('\n📋 Responsibilities\n');
      for (final resp in responsibilities) {
        aboutParts.add('• $resp');
      }
    }

    if (benefits.isNotEmpty) {
      aboutParts.add('\n💰 Benefits\n');
      for (final benefit in benefits) {
        aboutParts.add('• $benefit');
      }
    }

    if (otherFacilities.isNotEmpty) {
      aboutParts.add('\n🎁 Other Facilities\n');
      for (final facility in otherFacilities) {
        aboutParts.add('• $facility');
      }
    }

    // Format deadline
    String formattedDeadline = '';
    DateTime? parsedDeadline;
    try {
      parsedDeadline = DateTime.parse(
        json['applicationDeadline']?.toString() ?? '',
      );
      formattedDeadline =
          '${parsedDeadline.day.toString().padLeft(2, '0')}-${parsedDeadline.month.toString().padLeft(2, '0')}-${parsedDeadline.year}';
    } catch (e) {
      formattedDeadline = json['applicationDeadline']?.toString() ?? '';
    }

    // Format job type
    final jobType = json['jobType']?.toString() ?? '';
    final formattedType = jobType.replaceAll('_', ' ').toUpperCase();

    // Build salary display string — omit when not provided
    final hasSalary = minSalaryNum != 0 || maxSalaryNum != 0;
    final salaryDisplay = hasSalary
        ? [
            '\$$minSalaryNum - \$$maxSalaryNum',
            if (salaryType.isNotEmpty) '/ ${salaryType.toLowerCase()}',
          ].join(' ')
        : 'Not specified';

    return JobDetailsModel(
      id: _readNullableInt(json['id']),
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      salary: salaryDisplay,
      type: formattedType.isEmpty ? 'Full Time' : formattedType,
      location: json['location']?.toString() ?? '',
      experience: '$minExp-$maxExp Years',
      education: json['experienceLevel']?.toString() ?? 'Not specified',
      deadline: formattedDeadline,
      skills:
          (json['professionalSkills'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      about: aboutParts.join('\n').trim(),
      department: json['department']?.toString() ?? '',
      jobType: jobType,
      otherJobType: json['otherJobType']?.toString(),
      salaryType: salaryType,
      minimumSalary: minSalaryNum,
      maximumSalary: maxSalaryNum,
      description: description,
      responsibilities: responsibilities,
      requirements:
          (json['requirements'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      benefits: benefits,
      professionalSkills:
          (json['professionalSkills'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      otherFacilities: otherFacilities,
      experienceLevel: json['experienceLevel']?.toString() ?? '',
      minimumExperience: minExp,
      maximumExperience: maxExp,
      applicationDeadline: parsedDeadline,
      companyName: json['companyName']?.toString() ?? '',
      companyLogo: json['companyLogo']?.toString() ?? '',
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return double.tryParse(value?.toString() ?? '')?.round() ?? 0;
  }

  static int? _readNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString());
  }
}
