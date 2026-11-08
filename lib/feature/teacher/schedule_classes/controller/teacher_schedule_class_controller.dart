import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/teacher/courses/course_module/model/course_module_model.dart';
import 'package:msollaally/feature/teacher/courses/course_module/service/module_service.dart';
import 'package:msollaally/feature/teacher/courses/model/teacher_course_model.dart';
import 'package:msollaally/feature/teacher/courses/service/teacher_course_service.dart';
import 'package:msollaally/feature/teacher/schedule_classes/service/class_schedule_service.dart';

class TeacherScheduleClassController extends GetxController {
  TeacherScheduleClassController();

  final EventController<TeacherCalendarClassEvent> eventController =
      EventController<TeacherCalendarClassEvent>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final initialDay = DateTime.now().obs;
  final scheduledClassCount = 0.obs;

  final TeacherCourseService _courseService = TeacherCourseService();
  final ModuleService _moduleService = ModuleService();
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
      initialDay.value = _resolveInitialDay(events);
    } catch (error) {
      eventController.removeWhere((_) => true);
      scheduledClassCount.value = 0;
      errorMessage.value = _extractErrorMessage(error);
      initialDay.value = DateTime.now();
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<CalendarEventData<TeacherCalendarClassEvent>>>
  _buildCourseEvents() async {
    try {
      final courses = await _courseService.getMyCourses();
      return _buildCalendarEvents(courses);
    } catch (_) {
      return [];
    }
  }

  Future<List<CalendarEventData<TeacherCalendarClassEvent>>>
  _buildApiScheduleEvents() async {
    try {
      final schedules = await _scheduleService.getSchedules();
      _apiScheduleIdMap.clear();
      return schedules.map((s) {
        // Cache the ID so the detail sheet can look it up.
        _apiScheduleIdMap[_makeScheduleKey(s.title, s.startDateTime)] = s.id;
        return CalendarEventData<TeacherCalendarClassEvent>(
          title: s.title,
          description: s.description,
          date: s.startDateTime,
          startTime: s.startDateTime,
          endTime: s.endDateTime,
          color: const Color(0xFF1565C0),
        );
      }).toList();
    } catch (_) {
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

  Future<List<CalendarEventData<TeacherCalendarClassEvent>>>
  _buildCalendarEvents(List<TeacherCourseModel> courses) async {
    final moduleEventFutures =
        <Future<List<CalendarEventData<TeacherCalendarClassEvent>>>>[];

    for (final course in courses) {
      for (final module in course.modules) {
        moduleEventFutures.add(
          _buildModuleEvents(course: course, module: module),
        );
      }
    }

    final nestedEvents = await Future.wait(moduleEventFutures);
    final events = nestedEvents.expand((items) => items).toList()
      ..sort((a, b) {
        final first = a.startTime ?? a.date;
        final second = b.startTime ?? b.date;
        return first.compareTo(second);
      });

    return events;
  }

  Future<List<CalendarEventData<TeacherCalendarClassEvent>>>
  _buildModuleEvents({
    required TeacherCourseModel course,
    required CourseModule module,
  }) async {
    var resolvedModule = module;

    if (resolvedModule.classes.isEmpty && resolvedModule.id != 0) {
      try {
        resolvedModule = await _moduleService.getModuleDetails(
          resolvedModule.id,
        );
      } catch (_) {
        return const <CalendarEventData<TeacherCalendarClassEvent>>[];
      }
    }

    return resolvedModule.classes
        .where((courseClass) => courseClass.startTime != null)
        .map(
          (courseClass) => _toCalendarEvent(
            course: course,
            module: resolvedModule,
            courseClass: courseClass,
          ),
        )
        .toList();
  }

  CalendarEventData<TeacherCalendarClassEvent> _toCalendarEvent({
    required TeacherCourseModel course,
    required CourseModule module,
    required CourseClass courseClass,
  }) {
    final start = courseClass.startTime!.toLocal();
    final end = _resolveEndTime(courseClass, start);
    final metadata = TeacherCalendarClassEvent(
      course: course,
      module: module,
      courseClass: courseClass,
    );

    final descriptionParts = <String>[
      if (course.title.trim().isNotEmpty) course.title.trim(),
      if (module.title.trim().isNotEmpty) module.title.trim(),
      if (courseClass.classroom.trim().isNotEmpty &&
          courseClass.classroom.trim().toLowerCase() != 'tba')
        courseClass.classroom.trim(),
    ];

    return CalendarEventData<TeacherCalendarClassEvent>(
      title: courseClass.title,
      description: descriptionParts.join(' • '),
      date: start,
      startTime: start,
      endTime: end,
      color: course.color,
      event: metadata,
    );
  }

  DateTime _resolveEndTime(CourseClass courseClass, DateTime start) {
    final end = courseClass.endTime?.toLocal();
    if (end != null && end.isAfter(start)) {
      return end;
    }
    return start.add(const Duration(hours: 1));
  }

  DateTime _resolveInitialDay(
    List<CalendarEventData<TeacherCalendarClassEvent>> events,
  ) {
    if (events.isEmpty) return DateTime.now();

    final now = DateTime.now();
    final upcomingEvents = events
        .where((event) => !(event.endTime ?? event.date).isBefore(now))
        .toList();

    if (upcomingEvents.isNotEmpty) {
      final nextEvent = upcomingEvents.reduce((current, next) {
        final currentStart = current.startTime ?? current.date;
        final nextStart = next.startTime ?? next.date;
        return nextStart.isBefore(currentStart) ? next : current;
      });
      return nextEvent.date;
    }

    return events.first.date;
  }

  String _extractErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}

class TeacherCalendarClassEvent {
  const TeacherCalendarClassEvent({
    required this.course,
    required this.module,
    required this.courseClass,
  });

  final TeacherCourseModel course;
  final CourseModule module;
  final CourseClass courseClass;
}
