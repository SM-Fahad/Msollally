class AcademicCourseResponse {
  List<AcademicCourse>? courses;
  int? total;
  int? page;
  int? totalPages;

  AcademicCourseResponse({
    this.courses,
    this.total,
    this.page,
    this.totalPages,
  });

  factory AcademicCourseResponse.fromJson(Map<String, dynamic> json) {
    // API returns 'data' for myEnrollCourse and 'courses' for the full list
    final rawList = json['data'] ?? json['courses'];
    return AcademicCourseResponse(
      courses: rawList != null
          ? List<AcademicCourse>.from(
              (rawList as List).map((x) => AcademicCourse.fromJson(x)),
            )
          : null,
      total: json['total'],
      page: json['page'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courses': courses?.map((x) => x.toJson()).toList(),
      'total': total,
      'page': page,
      'totalPages': totalPages,
    };
  }
}

class AcademicCourse {
  int? id;
  String? title;
  String? description;
  String? courseCode;
  int? instructorId;
  Instructor? instructor;
  String? instructorName;
  String? status;
  String? coverImage;
  int? enrolledCount;
  double? progress;
  dynamic grade;
  String? startDate;
  String? endDate;
  String? createdAt;
  String? updatedAt;

  AcademicCourse({
    this.id,
    this.title,
    this.description,
    this.courseCode,
    this.instructorId,
    this.instructor,
    this.instructorName,
    this.status,
    this.coverImage,
    this.enrolledCount,
    this.progress,
    this.grade,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory AcademicCourse.fromJson(Map<String, dynamic> json) {
    // myEnrollCourse uses 'courseId'; full /courses list uses 'id'
    final rawProgress = json['progress'];
    double? parsedProgress;
    if (rawProgress != null) {
      final p = double.tryParse(rawProgress.toString());
      if (p != null) {
        parsedProgress = p > 1.0 ? p / 100.0 : p;
      }
    }

    return AcademicCourse(
      id: json['id'] ?? json['courseId'],
      title: json['title'],
      description: json['description'],
      courseCode: json['courseCode'],
      instructorId: json['instructorId'],
      instructor: json['instructor'] != null
          ? Instructor.fromJson(json['instructor'])
          : null,
      instructorName: json['instructorName']?.toString(),
      status: json['status'],
      coverImage: json['coverImage'],
      enrolledCount: json['enrolledCount'],
      progress: parsedProgress,
      grade: json['grade'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseCode': courseCode,
      'instructorId': instructorId,
      'instructor': instructor?.toJson(),
      'instructorName': instructorName,
      'status': status,
      'coverImage': coverImage,
      'enrolledCount': enrolledCount,
      'progress': progress,
      'grade': grade,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class Instructor {
  int? id;
  String? username;
  String? phoneNumber;
  bool? isPhoneVerified;
  String? role;
  bool? isAccRefered;
  bool? isReferEnabled;
  String? premiumUntil;
  bool? isFreemiumClaimed;
  String? billingInterval;
  int? friendsCount;
  String? proPartnerName;
  String? createdAt;
  String? updatedAt;
  String? lastLoginAt;

  Instructor({
    this.id,
    this.username,
    this.phoneNumber,
    this.isPhoneVerified,
    this.role,
    this.isAccRefered,
    this.isReferEnabled,
    this.premiumUntil,
    this.isFreemiumClaimed,
    this.billingInterval,
    this.friendsCount,
    this.proPartnerName,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['id'],
      username: json['username'],
      phoneNumber: json['phoneNumber'],
      isPhoneVerified: json['isPhoneVerified'],
      role: json['role'],
      isAccRefered: json['is_acc_refered'],
      isReferEnabled: json['isReferEnabled'],
      premiumUntil: json['premiumUntil'],
      isFreemiumClaimed: json['isFreemiumClaimed'],
      billingInterval: json['billingInterval'],
      friendsCount: json['friendsCount'],
      proPartnerName: json['proPartnerName'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      lastLoginAt: json['lastLoginAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'phoneNumber': phoneNumber,
      'isPhoneVerified': isPhoneVerified,
      'role': role,
      'is_acc_refered': isAccRefered,
      'isReferEnabled': isReferEnabled,
      'premiumUntil': premiumUntil,
      'isFreemiumClaimed': isFreemiumClaimed,
      'billingInterval': billingInterval,
      'friendsCount': friendsCount,
      'proPartnerName': proPartnerName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLoginAt': lastLoginAt,
    };
  }
}

class StudentCourseDashboardItem {
  final String type;
  final int id;
  final String title;
  final String dueDate;
  final String courseName;
  final String assessmentType;

  const StudentCourseDashboardItem({
    required this.type,
    required this.id,
    required this.title,
    required this.dueDate,
    required this.courseName,
    required this.assessmentType,
  });

  factory StudentCourseDashboardItem.fromJson(Map<String, dynamic> json) {
    return StudentCourseDashboardItem(
      type: (json['type'] ?? '').toString(),
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: (json['title'] ?? '').toString(),
      dueDate: (json['dueDate'] ?? '').toString(),
      courseName: (json['courseName'] ?? '').toString(),
      assessmentType: (json['assessmentType'] ?? '').toString(),
    );
  }
}
