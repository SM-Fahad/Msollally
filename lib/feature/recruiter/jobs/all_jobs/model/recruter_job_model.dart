class JobModel {
  final int id;
  final String title;
  final String department;
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
  final int postedBy;
  final String companyName;
  final String companyLogo;
  final int viewsCount;
  final int applicationsCount;
  final String publishedAt;
  final String createdAt;
  final String updatedAt;

  JobModel({
    required this.id,
    required this.title,
    required this.department,
    required this.location,
    required this.jobType,
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
    required this.status,
    required this.postedBy,
    required this.companyName,
    required this.companyLogo,
    required this.viewsCount,
    required this.applicationsCount,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      department: json['department'] ?? '',
      location: json['location'] ?? '',
      jobType: json['jobType'] ?? '',
      salaryType: json['salaryType']?.toString() ?? '',
      minimumSalary: json['minimumSalary']?.toString() ?? '',
      maximumSalary: json['maximumSalary']?.toString() ?? '',
      description: json['description'] ?? '',
      responsibilities: List<String>.from(json['responsibilities'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      professionalSkills: List<String>.from(json['professionalSkills'] ?? []),
      otherFacilities: List<String>.from(json['otherFacilities'] ?? []),
      experienceLevel: json['experienceLevel'] ?? '',
      minimumExperience: json['minimumExperience'] ?? 0,
      maximumExperience: json['maximumExperience'] ?? 0,
      applicationDeadline: json['applicationDeadline'] ?? '',
      status: json['status'] ?? '',
      postedBy: json['postedBy'] ?? 0,
      companyName: json['companyName'] ?? '',
      companyLogo: json['companyLogo'] ?? '',
      viewsCount: json['viewsCount'] ?? 0,
      applicationsCount: json['applicationsCount'] ?? 0,
      publishedAt: json['publishedAt'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  /// Computed property for display salary
  String get salary {
    final hasMin = minimumSalary.isNotEmpty && minimumSalary != '0';
    final hasMax = maximumSalary.isNotEmpty && maximumSalary != '0';
    final type = _formatSalaryType(salaryType);

    if (!hasMin && !hasMax) return 'Not specified';

    final salaryRange = [
      if (hasMin) '\$$minimumSalary',
      if (hasMax) '\$$maximumSalary',
    ].join(' - ');

    return type.isEmpty ? salaryRange : '$salaryRange / $type';
  }

  /// Computed property for display experience
  String get experience => '$minimumExperience-$maximumExperience Years';

  /// Computed property for display experience level
  String get level => experienceLevel.isNotEmpty
      ? '${experienceLevel[0].toUpperCase()}${experienceLevel.substring(1)}-level'
      : 'Mid-level';

  /// Computed property for display deadline
  String get deadline => _formatDate(applicationDeadline);

  /// Computed property for display post date
  String get postDate => _formatDate(publishedAt);

  /// Computed property for image URL
  String get imageUrl =>
      companyLogo.isNotEmpty ? companyLogo : 'assets/images/book1.png';

  String _formatSalaryType(String v) {
    if (v.trim().isEmpty) return '';
    return v
        .split('_')
        .map((s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1))
        .join(' ');
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
    } catch (e) {
      return dateString;
    }
  }
}
