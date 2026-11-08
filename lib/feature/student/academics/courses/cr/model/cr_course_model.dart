class MyCrCourse {
  final int id;
  final int courseId;
  final bool canManageModules;
  final bool canManageNotices;
  final bool canManageAssessments;
  final DateTime? assignedAt;
  final CrCourseInfo? course;

  MyCrCourse({
    required this.id,
    required this.courseId,
    required this.canManageModules,
    required this.canManageNotices,
    required this.canManageAssessments,
    this.assignedAt,
    this.course,
  });

  factory MyCrCourse.fromJson(Map<String, dynamic> json) {
    int parsedCourseId = 0;
    if (json['courseId'] != null) {
      parsedCourseId = json['courseId'] is int
          ? json['courseId']
          : int.tryParse(json['courseId'].toString()) ?? 0;
    } else if (json['course'] != null && json['course']['id'] != null) {
      parsedCourseId = json['course']['id'] is int
          ? json['course']['id']
          : int.tryParse(json['course']['id'].toString()) ?? 0;
    }

    return MyCrCourse(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      courseId: parsedCourseId,
      canManageModules: json['canManageModules'] == true || json['can_manage_modules'] == true,
      canManageNotices: json['canManageNotices'] == true || json['can_manage_notices'] == true,
      canManageAssessments:
          json['canManageAssessments'] == true || json['can_manage_assessments'] == true,
      assignedAt: json['assignedAt'] != null
          ? DateTime.tryParse(json['assignedAt'].toString())
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null),
      course: json['course'] != null && json['course'] is Map<String, dynamic>
          ? CrCourseInfo.fromJson(json['course'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'canManageModules': canManageModules,
      'canManageNotices': canManageNotices,
      'canManageAssessments': canManageAssessments,
      'assignedAt': assignedAt?.toIso8601String(),
      'course': course?.toJson(),
    };
  }
}

class CrCourseInfo {
  final int id;
  final String? title;
  final String? code;
  final String? coverImage;
  final String? instructorName;

  CrCourseInfo({
    required this.id,
    this.title,
    this.code,
    this.coverImage,
    this.instructorName,
  });

  factory CrCourseInfo.fromJson(Map<String, dynamic> json) {
    String? instructor;
    if (json['instructor'] != null) {
      if (json['instructor'] is Map<String, dynamic>) {
        final ins = json['instructor'] as Map<String, dynamic>;
        if (ins['profile'] != null && ins['profile']['fullName'] != null) {
          instructor = ins['profile']['fullName'];
        } else {
          instructor = ins['username'] ?? ins['name'];
        }
      } else {
        instructor = json['instructor'].toString();
      }
    }

    return CrCourseInfo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? json['name'],
      code: json['code'] ?? json['courseCode'],
      coverImage: json['coverImage'] ?? json['cover_image'],
      instructorName: instructor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'code': code,
      'coverImage': coverImage,
      'instructorName': instructorName,
    };
  }
}

class CourseCrMember {
  final int id;
  final int courseId;
  final int userId;
  final bool isActive;
  final bool canManageModules;
  final bool canManageNotices;
  final bool canManageAssessments;
  final String? fullName;
  final String? email;
  final String? avatar;

  CourseCrMember({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.isActive,
    required this.canManageModules,
    required this.canManageNotices,
    required this.canManageAssessments,
    this.fullName,
    this.email,
    this.avatar,
  });

  factory CourseCrMember.fromJson(Map<String, dynamic> json) {
    String? name;
    String? mail;
    String? img;

    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      final user = json['user'] as Map<String, dynamic>;
      name = user['username'];
      mail = user['email'];
      if (user['profile'] != null && user['profile'] is Map<String, dynamic>) {
        final prof = user['profile'] as Map<String, dynamic>;
        name = prof['fullName'] ?? prof['name'] ?? name;
        mail = prof['email'] ?? mail;
        img = prof['avatar'] ?? prof['profileImage'] ?? prof['photo'];
      }
    }

    return CourseCrMember(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      courseId: json['courseId'] is int
          ? json['courseId']
          : int.tryParse(json['courseId']?.toString() ?? '0') ?? 0,
      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      canManageModules: json['canManageModules'] == true || json['can_manage_modules'] == true,
      canManageNotices: json['canManageNotices'] == true || json['can_manage_notices'] == true,
      canManageAssessments:
          json['canManageAssessments'] == true || json['can_manage_assessments'] == true,
      fullName: name,
      email: mail,
      avatar: img,
    );
  }
}
