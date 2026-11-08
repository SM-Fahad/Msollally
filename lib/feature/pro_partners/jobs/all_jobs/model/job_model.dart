class JobModel {
  final String id;
  final String title;
  final String locationType;
  final String jobType;
  final String status;
  final int applications;
  final int views;
  final String department;
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
  final String otherExperienceLevel;
  final String applicationDeadline;
  final String companyName;
  final String companyLogo;
  final String publishedAt;
  final String createdAt;
  final String updatedAt;
  final bool hasApplied;
  final bool isSaved;

  JobModel({
    required this.id,
    required this.title,
    required this.locationType,
    required this.jobType,
    required this.status,
    required this.applications,
    required this.views,
    this.department = '',
    this.salaryType = '',
    this.minimumSalary = '',
    this.maximumSalary = '',
    required this.description,
    required this.responsibilities,
    required this.requirements,
    required this.benefits,
    required this.professionalSkills,
    required this.otherFacilities,
    required this.experienceLevel,
    this.otherExperienceLevel = '',
    required this.minimumExperience,
    required this.maximumExperience,
    required this.applicationDeadline,
    required this.companyName,
    required this.companyLogo,
    required this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.hasApplied,
    required this.isSaved,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: _text(json['id']),
      title: _text(json['title']),
      locationType: _firstText([json['location'], json['locationType']]),
      jobType: _text(json['jobType']),
      status: _text(json['status']),
      applications: _intValue(
        json['applicationsCount'] ?? json['applications'],
      ),
      views: _intValue(json['viewsCount'] ?? json['views']),
      department: _text(json['department']),
      salaryType: _text(json['salaryType']),
      minimumSalary: _moneyText(json['minimumSalary']),
      maximumSalary: _moneyText(json['maximumSalary']),
      description: _text(json['description']),
      responsibilities: _listValue(json['responsibilities']),
      requirements: _listValue(json['requirements']),
      benefits: _listValue(json['benefits']),
      professionalSkills: _listValue(json['professionalSkills']),
      otherFacilities: _listValue(json['otherFacilities']),
      experienceLevel: _text(json['experienceLevel']),
      otherExperienceLevel: _text(json['otherExperienceLevel']),
      minimumExperience: _intValue(json['minimumExperience']),
      maximumExperience: _intValue(json['maximumExperience']),
      applicationDeadline: _text(json['applicationDeadline']),
      companyName: _text(json['companyName']),
      companyLogo: _text(json['companyLogo']),
      publishedAt: _text(json['publishedAt']),
      createdAt: _text(json['createdAt']),
      updatedAt: _text(json['updatedAt']),
      hasApplied: json['hasApplied'] == true,
      isSaved: json['isSaved'] == true,
    );
  }

  static String _text(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.toLowerCase() == 'null' ? '' : text;
  }

  static String _firstText(List<dynamic> values) {
    for (final value in values) {
      final text = _text(value);
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  static int _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _moneyText(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is int || value is double) {
      return value.toString();
    }
    return _text(value);
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
}
