import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/courses/academic_courses/model/academic_course_model.dart';
import 'package:msollaally/feature/student/academics/courses/academic_courses/service/academic_course_service.dart';
import 'package:msollaally/feature/student/academics/courses/courseDetail/model/course_detail_api_model.dart';
import 'package:msollaally/feature/teacher/schedule_classes/service/class_schedule_service.dart';

class StudentCalenderController extends GetxController {
  final EventController<StudentCalendarClassEvent> eventController =
      EventController<StudentCalendarClassEvent>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final initialDay = DateTime.now().obs;
  final scheduledClassCount = 0.obs;

  final ClassScheduleService _scheduleService = ClassScheduleService();

  /// Maps "title|yyyy-MM-dd|HH:mm:ss" → schedule ID for API-fetched events.
  final Map<String, int> _apiScheduleIdMap = {};

  @override
  void onInit() {
    super.onInit();
    loadScheduledClasses();
  }

  Future<void> loadScheduledClasses() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Load course-based events and class-schedule API events in parallel.
      final results = await Future.wait([
        _buildCourseEvents(),
        _buildApiScheduleEvents(),
      ]);

      final events = [...results[0], ...results[1]]
        ..sort((a, b) {
          final first = a.startTime ?? a.date;
          final second = b.startTime ?? b.date;
          return first.compareTo(second);
        });

      eventController.removeWhere((_) => true);
      if (events.isNotEmpty) {
        eventController.addAll(events);
      }

      scheduledClassCount.value = events.length;
      initialDay.value = DateTime.now();
    } catch (error) {
      eventController.removeWhere((_) => true);
      scheduledClassCount.value = 0;
      errorMessage.value = _extractErrorMessage(error);
      initialDay.value = DateTime.now();
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<CalendarEventData<StudentCalendarClassEvent>>>
  _buildCourseEvents() async {
    try {
      final response = await AcademicCourseService.getMyEnrolledCourses();
      final courses = response.courses ?? [];
      return await _buildCalendarEvents(courses);
    } catch (e) {
      debugPrint('⚠️ [StudentCalender] Failed to load enrolled courses: $e');
      return [];
    }
  }

  Future<List<CalendarEventData<StudentCalendarClassEvent>>>
  _buildApiScheduleEvents() async {
    try {
      final schedules = await _scheduleService.getSchedules();
      _apiScheduleIdMap.clear();
      return schedules.map((s) {
        // Cache the ID so the detail sheet can look it up.
        _apiScheduleIdMap[_makeScheduleKey(s.title, s.startDateTime)] = s.id;
        return CalendarEventData<StudentCalendarClassEvent>(
          title: s.title,
          description: s.description,
          date: s.startDateTime,
          startTime: s.startDateTime,
          endTime: s.endDateTime,
          color: _getColorForTitle(s.title),
        );
      }).toList();
    } catch (e) {
      debugPrint('⚠️ [StudentCalender] Failed to load API schedules: $e');
      return [];
    }
  }

  /// Returns the API schedule ID for an event, or null if it's a course event.
  int? getApiScheduleId(String title, DateTime? startTime) {
    if (startTime == null) return null;
    return _apiScheduleIdMap[_makeScheduleKey(title, startTime)];
  }

  String _makeScheduleKey(String title, DateTime startTime) {
    final d = startTime;
    final date =
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    final time =
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}:'
        '${d.second.toString().padLeft(2, '0')}';
    return '$title|$date|$time';
  }

  Future<List<CalendarEventData<StudentCalendarClassEvent>>>
  _buildCalendarEvents(List<AcademicCourse> courses) async {
    // Fetch course details in parallel, but handle each course independently
    // so a single course failure (e.g. "You do not have access to this course")
    // doesn't crash the entire student calendar.
    final futures = courses
        .where((c) => c.id != null)
        .map((course) async {
          try {
            return await AcademicCourseService.getCourseById(course.id!);
          } catch (e) {
            debugPrint(
              '⚠️ [StudentCalender] Skipping course #${course.id} (${course.title ?? course.courseCode}): $e',
            );
            return null;
          }
        });

    final results = await Future.wait(futures);
    final courseDetails = results.whereType<CourseDetailApiModel>().toList();
    final events = <CalendarEventData<StudentCalendarClassEvent>>[];

    for (final detail in courseDetails) {
      for (final module in detail.modules) {
        for (final courseClass in module.classes) {
          if (courseClass.startTime != null) {
            events.add(_toCalendarEvent(
              courseDetail: detail,
              module: module,
              courseClass: courseClass,
            ));
          }
        }
      }
    }

    events.sort((a, b) {
      final first = a.startTime ?? a.date;
      final second = b.startTime ?? b.date;
      return first.compareTo(second);
    });

    return events;
  }

  CalendarEventData<StudentCalendarClassEvent> _toCalendarEvent({
    required CourseDetailApiModel courseDetail,
    required CourseDetailModule module,
    required CourseDetailClass courseClass,
  }) {
    final start = courseClass.startTime!.toLocal();
    final end = _resolveEndTime(courseClass, start);
    final metadata = StudentCalendarClassEvent(
      courseDetail: courseDetail,
      module: module,
      courseClass: courseClass,
    );

    final descriptionParts = <String>[
      if (courseDetail.title.trim().isNotEmpty) courseDetail.title.trim(),
      if (module.title.trim().isNotEmpty) module.title.trim(),
      if (courseClass.classroom.trim().isNotEmpty &&
          courseClass.classroom.trim().toLowerCase() != 'tba')
        courseClass.classroom.trim(),
    ];

    Color courseColor = _getColorForTitle(courseClass.title);

    return CalendarEventData<StudentCalendarClassEvent>(
      title: courseClass.title,
      description: descriptionParts.join(' • '),
      date: start,
      startTime: start,
      endTime: end,
      color: courseColor,
      event: metadata,
    );
  }

  DateTime _resolveEndTime(CourseDetailClass courseClass, DateTime start) {
    final end = courseClass.endTime?.toLocal();
    if (end != null && end.isAfter(start)) {
      return end;
    }
    return start.add(const Duration(hours: 1));
  }



  String _extractErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }

  static const List<Color> _gorgeousColors = [
    Color(0xFF8757F3), // Royal Purple
    Color(0xFFF95B72), // Vibrant Pink
    Color(0xFF00C48C), // Mint Green
    Color(0xFFF39C12), // Vibrant Orange
    Color(0xFF2980B9), // Deep Blue
    Color(0xFFE74C3C), // Strong Red
    Color(0xFF9B59B6), // Amethyst
    Color(0xFF1ABC9C), // Turquoise
    Color(0xFF34495E), // Midnight Blue
    Color(0xFFD35400), // Pumpkin
  ];

  Color _getColorForTitle(String title) {
    final index = title.hashCode.abs() % _gorgeousColors.length;
    return _gorgeousColors[index];
  }
}

class StudentCalendarClassEvent {
  const StudentCalendarClassEvent({
    required this.courseDetail,
    required this.module,
    required this.courseClass,
  });

  final CourseDetailApiModel courseDetail;
  final CourseDetailModule module;
  final CourseDetailClass courseClass;
}
