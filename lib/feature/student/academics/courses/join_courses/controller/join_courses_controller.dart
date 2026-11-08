import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../courseDetail/model/course_model.dart';
import '../../academic_courses/model/academic_course_model.dart';
import '../../academic_courses/service/academic_course_service.dart';

class JoinCourseController extends GetxController {
  // Holds courses fetched from API, keyed by their real id
  var apiCourses = <AcademicCourse>[].obs;

  // Adapts to the existing CourseModel used by the UI
  var courses = <CourseModel>[].obs;

  // Tracks which courseIds are currently being enrolled (for button state)
  var enrollingIds = <int>{}.obs;

  // Tracks enrolled courseIds locally so button disables immediately
  var enrolledIds = <int>{}.obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  Future<void> loadCourses() async {
    debugPrint('🚀 [JoinCourseController] loadCourses() called');
    try {
      isLoading.value = true;
      final response = await AcademicCourseService.getAllCourses();
      debugPrint(
        '📊 [JoinCourseController] courses from API: ${response.courses?.length}',
      );

      if (response.courses != null) {
        apiCourses.value = response.courses!;
        courses.value = response.courses!.map((c) {
          return CourseModel(
            id: c.id,
            title: c.title ?? 'Unknown Title',
            instructor: c.instructor?.username ?? 'Unknown Instructor',
            status: c.status ?? 'published',
            progress: 0.0,
            totalClasses: 0,
            attendedClasses: 0,
            nextClass: 'N/A',
            nextExam: 'N/A',
            activities: [],
          );
        }).toList();
        debugPrint(
          '✅ [JoinCourseController] courses mapped: ${courses.length}',
        );
      } else {
        debugPrint('⚠️ [JoinCourseController] response.courses is null');
      }
    } catch (e, st) {
      debugPrint('❌ [JoinCourseController] loadCourses error: $e');
      debugPrint('🧱 [JoinCourseController] StackTrace: $st');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinCourse(int index) async {
    if (index >= apiCourses.length) return;

    final apiCourse = apiCourses[index];
    final courseId = apiCourse.id;
    if (courseId == null) {
      debugPrint('⚠️ [JoinCourseController] courseId is null at index $index');
      return;
    }

    if (enrolledIds.contains(courseId)) {
      debugPrint(
        'ℹ️ [JoinCourseController] Already enrolled in course $courseId',
      );
      return;
    }

    debugPrint(
      '📝 [JoinCourseController] Attempting to join courseId=$courseId',
    );
    enrollingIds.add(courseId);

    try {
      await AcademicCourseService.enrollCourse(courseId);
      enrolledIds.add(courseId);
      courses[index].status = 'Joined';
      courses.refresh();
      debugPrint('✅ [JoinCourseController] Enrolled in courseId=$courseId');
      Get.snackbar(
        'Success',
        'You have joined "${apiCourse.title}"!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('❌ [JoinCourseController] Enroll error: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      enrollingIds.remove(courseId);
    }
  }

  bool isEnrolling(int index) {
    if (index >= apiCourses.length) return false;
    final id = apiCourses[index].id;
    return id != null && enrollingIds.contains(id);
  }

  bool isEnrolled(int index) {
    if (index >= apiCourses.length) return false;
    final id = apiCourses[index].id;
    return id != null && enrolledIds.contains(id);
  }
}
