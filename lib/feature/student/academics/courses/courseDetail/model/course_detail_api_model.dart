import '../../academic_courses/model/academic_course_model.dart';

class CourseDetailApiModel {
  final int id;
  final String title;
  final String description;
  final String courseCode;
  final int instructorId;
  final Instructor? instructor;
  final String status;
  final String coverImage;
  final int enrolledCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<CourseDetailModule> modules;
  final bool isEnrolled;
  final bool isInstructor;
  final CourseEnrollment? enrollment;

  CourseDetailApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseCode,
    required this.instructorId,
    required this.instructor,
    required this.status,
    required this.coverImage,
    required this.enrolledCount,
    required this.startDate,
    required this.endDate,
    required this.modules,
    required this.isEnrolled,
    required this.isInstructor,
    required this.enrollment,
  });

  factory CourseDetailApiModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailApiModel(
      id: _readInt(json['id']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      courseCode: (json['courseCode'] ?? '').toString(),
      instructorId: _readInt(json['instructorId']),
      instructor: json['instructor'] is Map<String, dynamic>
          ? Instructor.fromJson(json['instructor'] as Map<String, dynamic>)
          : null,
      status: (json['status'] ?? '').toString(),
      coverImage: (json['coverImage'] ?? '').toString(),
      enrolledCount: _readInt(json['enrolledCount']),
      startDate: _readDateTime(json['startDate']),
      endDate: _readDateTime(json['endDate']),
      modules: (json['modules'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CourseDetailModule.fromJson)
          .toList(),
      isEnrolled: json['isEnrolled'] == true,
      isInstructor: json['isInstructor'] == true,
      enrollment: json['enrollment'] is Map<String, dynamic>
          ? CourseEnrollment.fromJson(
              json['enrollment'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  int get totalClasses =>
      modules.fold(0, (sum, module) => sum + module.classes.length);

  int get completedModules =>
      modules.where((module) => module.isCompleted).length;

  int get overallProgress {
    final enrollmentProgress = enrollment?.progress;
    if (enrollmentProgress != null) {
      return enrollmentProgress.clamp(0, 100);
    }
    if (modules.isEmpty) return 0;
    final total = modules.fold<int>(0, (sum, module) => sum + module.progress);
    return (total / modules.length).round().clamp(0, 100);
  }

  CourseDetailClass? get nextClass {
    final now = DateTime.now().toUtc();
    final upcoming =
        modules
            .expand((module) => module.classes)
            .where(
              (item) => item.startTime != null && item.startTime!.isAfter(now),
            )
            .toList()
          ..sort((a, b) => a.startTime!.compareTo(b.startTime!));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  List<CourseDetailActivity> get activities {
    final items = <CourseDetailActivity>[];

    for (final module in modules) {
      items.add(
        CourseDetailActivity(
          type: module.isCompleted ? 'module' : 'progress',
          title: module.title,
          description: module.description.isNotEmpty
              ? module.description
              : 'Module progress: ${module.progress}%',
          time: module.startDate,
        ),
      );

      for (final courseClass in module.classes) {
        items.add(
          CourseDetailActivity(
            type: 'class',
            title: courseClass.title,
            description: courseClass.topic.isNotEmpty
                ? courseClass.topic
                : courseClass.classroom,
            time: courseClass.startTime,
          ),
        );
      }
    }

    items.sort((a, b) {
      final aTime = a.time ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.time ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return items;
  }
}

class CourseDetailModule {
  final int id;
  final String title;
  final String description;
  final int orderIndex;
  final DateTime? startDate;
  final int progress;
  final bool isCompleted;
  final List<CourseDetailClass> classes;

  CourseDetailModule({
    required this.id,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.startDate,
    required this.progress,
    required this.isCompleted,
    required this.classes,
  });

  factory CourseDetailModule.fromJson(Map<String, dynamic> json) {
    return CourseDetailModule(
      id: _readInt(json['id']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      orderIndex: _readInt(json['orderIndex']),
      startDate: _readDateTime(json['startDate']),
      progress: _readInt(json['progress']),
      isCompleted: json['isCompleted'] == true,
      classes: (json['classes'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CourseDetailClass.fromJson)
          .toList(),
    );
  }
}

class CourseDetailClass {
  final int id;
  final String title;
  final String classroom;
  final String topic;
  final DateTime? startTime;
  final DateTime? endTime;

  CourseDetailClass({
    required this.id,
    required this.title,
    required this.classroom,
    required this.topic,
    required this.startTime,
    required this.endTime,
  });

  factory CourseDetailClass.fromJson(Map<String, dynamic> json) {
    return CourseDetailClass(
      id: _readInt(json['id']),
      title: (json['title'] ?? '').toString(),
      classroom: (json['classroom'] ?? '').toString(),
      topic: (json['topic'] ?? '').toString(),
      startTime: _readDateTime(json['startTime']),
      endTime: _readDateTime(json['endTime']),
    );
  }
}

class CourseEnrollment {
  final int id;
  final String status;
  final int progress;
  final DateTime? enrolledAt;

  CourseEnrollment({
    required this.id,
    required this.status,
    required this.progress,
    required this.enrolledAt,
  });

  factory CourseEnrollment.fromJson(Map<String, dynamic> json) {
    return CourseEnrollment(
      id: _readInt(json['id']),
      status: (json['status'] ?? '').toString(),
      progress: _readInt(json['progress']),
      enrolledAt: _readDateTime(json['enrolledAt']),
    );
  }
}

class CourseDetailActivity {
  final String type;
  final String title;
  final String description;
  final DateTime? time;

  CourseDetailActivity({
    required this.type,
    required this.title,
    required this.description,
    required this.time,
  });
}

class StudentCourseProgressModel {
  final StudentProgressEnrollment enrollment;
  final StudentAcademicPerformance academicPerformance;
  final List<StudentProgressModule> modules;
  final List<StudentRecentSubmission> recentSubmissions;

  StudentCourseProgressModel({
    required this.enrollment,
    required this.academicPerformance,
    required this.modules,
    required this.recentSubmissions,
  });

  factory StudentCourseProgressModel.fromJson(Map<String, dynamic> json) {
    return StudentCourseProgressModel(
      enrollment: StudentProgressEnrollment.fromJson(
        json['enrollment'] is Map<String, dynamic>
            ? json['enrollment'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
      academicPerformance: StudentAcademicPerformance.fromJson(
        json['academicPerformance'] is Map<String, dynamic>
            ? json['academicPerformance'] as Map<String, dynamic>
            : const <String, dynamic>{},
      ),
      modules: (json['modules'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(StudentProgressModule.fromJson)
          .toList(),
      recentSubmissions: (json['recentSubmissions'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(StudentRecentSubmission.fromJson)
          .toList(),
    );
  }
}

class StudentProgressEnrollment {
  final String status;
  final int progress;
  final String grade;
  final DateTime? enrolledAt;

  StudentProgressEnrollment({
    required this.status,
    required this.progress,
    required this.grade,
    required this.enrolledAt,
  });

  factory StudentProgressEnrollment.fromJson(Map<String, dynamic> json) {
    return StudentProgressEnrollment(
      status: (json['status'] ?? '').toString(),
      progress: _readInt(json['progress']),
      grade: (json['grade'] ?? '').toString(),
      enrolledAt: _readDateTime(json['enrolledAt']),
    );
  }
}

class StudentAcademicPerformance {
  final int totalSubmissions;
  final int gradedSubmissions;
  final int pendingSubmissions;
  final int totalPossibleMarks;
  final String totalEarnedMarks;
  final int overallPercentage;

  StudentAcademicPerformance({
    required this.totalSubmissions,
    required this.gradedSubmissions,
    required this.pendingSubmissions,
    required this.totalPossibleMarks,
    required this.totalEarnedMarks,
    required this.overallPercentage,
  });

  factory StudentAcademicPerformance.fromJson(Map<String, dynamic> json) {
    return StudentAcademicPerformance(
      totalSubmissions: _readInt(json['totalSubmissions']),
      gradedSubmissions: _readInt(json['gradedSubmissions']),
      pendingSubmissions: _readInt(json['pendingSubmissions']),
      totalPossibleMarks: _readInt(json['totalPossibleMarks']),
      totalEarnedMarks: (json['totalEarnedMarks'] ?? '').toString(),
      overallPercentage: _readInt(json['overallPercentage']),
    );
  }
}

class StudentProgressModule {
  final int id;
  final String title;
  final int progress;
  final bool isCompleted;

  StudentProgressModule({
    required this.id,
    required this.title,
    required this.progress,
    required this.isCompleted,
  });

  factory StudentProgressModule.fromJson(Map<String, dynamic> json) {
    return StudentProgressModule(
      id: _readInt(json['id']),
      title: (json['title'] ?? '').toString(),
      progress: _readInt(json['progress']),
      isCompleted: json['isCompleted'] == true,
    );
  }
}

class StudentRecentSubmission {
  final int id;
  final String status;
  final String marks;
  final String feedback;
  final DateTime? submittedAt;
  final StudentSubmissionAssessment? assessment;

  StudentRecentSubmission({
    required this.id,
    required this.status,
    required this.marks,
    required this.feedback,
    required this.submittedAt,
    required this.assessment,
  });

  factory StudentRecentSubmission.fromJson(Map<String, dynamic> json) {
    return StudentRecentSubmission(
      id: _readInt(json['id']),
      status: (json['status'] ?? '').toString(),
      marks: (json['marks'] ?? '').toString(),
      feedback: (json['feedback'] ?? '').toString(),
      submittedAt: _readDateTime(json['submittedAt']),
      assessment: json['assessment'] is Map<String, dynamic>
          ? StudentSubmissionAssessment.fromJson(
              json['assessment'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class StudentSubmissionAssessment {
  final int id;
  final String title;
  final int totalMarks;
  final DateTime? dueDate;

  StudentSubmissionAssessment({
    required this.id,
    required this.title,
    required this.totalMarks,
    required this.dueDate,
  });

  factory StudentSubmissionAssessment.fromJson(Map<String, dynamic> json) {
    return StudentSubmissionAssessment(
      id: _readInt(json['id']),
      title: (json['title'] ?? '').toString(),
      totalMarks: _readInt(json['totalMarks']),
      dueDate: _readDateTime(json['dueDate']),
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _readDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
