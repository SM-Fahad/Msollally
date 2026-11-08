class JobModel {
  final int id;
  final String title;
  final String company;
  final String companyLogo;
  final String location;
  final String jobType;
  final String salaryType;
  final String minimumSalary;
  final String maximumSalary;
  final String description;
  final List<String> responsibilities;
  final List<String> requirements;
  final List<String> benefits;
  final List<String> professionalSkills;
  final List<String> otherFacilities;
  final String experienceLevel;
  final int minimumExperience;
  final int maximumExperience;
  final String applicationDeadline;
  final String status;
  final String department;
  final DateTime postedDate;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    this.companyLogo = '',
    required this.location,
    required this.jobType,
    this.salaryType = '',
    this.minimumSalary = '',
    this.maximumSalary = '',
    required this.description,
    this.responsibilities = const [],
    this.requirements = const [],
    this.benefits = const [],
    this.professionalSkills = const [],
    this.otherFacilities = const [],
    this.experienceLevel = '',
    this.minimumExperience = 0,
    this.maximumExperience = 0,
    required this.applicationDeadline,
    this.status = '',
    this.department = '',
    required this.postedDate,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    return JobModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      company: json['companyName'] ?? '',
      companyLogo: json['companyLogo'] ?? '',
      location: json['location'] ?? '',
      jobType: json['jobType'] ?? '',
      salaryType: json['salaryType'] ?? '',
      minimumSalary: json['minimumSalary']?.toString() ?? '',
      maximumSalary: json['maximumSalary']?.toString() ?? '',
      description: json['description'] ?? '',
      responsibilities: parseList(json['responsibilities']),
      requirements: parseList(json['requirements']),
      benefits: parseList(json['benefits']),
      professionalSkills: parseList(json['professionalSkills']),
      otherFacilities: parseList(json['otherFacilities']),
      experienceLevel: json['experienceLevel'] ?? '',
      minimumExperience: json['minimumExperience'] ?? 0,
      maximumExperience: json['maximumExperience'] ?? 0,
      applicationDeadline: json['applicationDeadline'] ?? '',
      status: json['status'] ?? '',
      department: json['department'] ?? '',
      postedDate: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Formatted salary range string, e.g. "$1,100 – $2,000 / month"
  String get salaryRange {
    if (minimumSalary.isEmpty && maximumSalary.isEmpty) return 'N/A';
    final minNum = double.tryParse(minimumSalary);
    final maxNum = double.tryParse(maximumSalary);
    final minStr = minNum != null
        ? '\$${minNum.toStringAsFixed(0)}'
        : minimumSalary;
    final maxStr = maxNum != null
        ? '\$${maxNum.toStringAsFixed(0)}'
        : maximumSalary;
    final interval = salaryType == 'monthly' ? '/ month' : salaryType;
    return '$minStr – $maxStr $interval'.trim();
  }

  /// Human-readable job type
  String get jobTypeLabel {
    switch (jobType) {
      case 'full_time':
        return 'Full-Time';
      case 'part_time':
        return 'Part-Time';
      case 'internship':
        return 'Internship';
      case 'contract':
        return 'Contract';
      default:
        return jobType;
    }
  }
}
