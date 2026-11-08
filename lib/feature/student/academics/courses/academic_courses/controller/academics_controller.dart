import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/academic_course_model.dart';
import '../../courseDetail/model/course_model.dart';
import '../../cr/model/cr_course_model.dart';
import '../service/academic_course_service.dart';

class CourseController extends GetxController {
  var courses = <CourseModel>[].obs;
  var dashboardItems = <StudentCourseDashboardItem>[].obs;
  var myCrCourses = <MyCrCourse>[].obs;
  var isLoading = false.obs;
  var isLoadingDashboard = false.obs;
  var isLoadingCr = false.obs;
  var isDroppingCourse = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshCourses();
  }

  Future<void> fetchCourses() async {
    debugPrint('🚀 [CourseController] fetchCourses() called');
    try {
      isLoading.value = true;
      final response = await AcademicCourseService.getMyEnrolledCourses();
      debugPrint(
        '📊 [CourseController] response.courses is null: ${response.courses == null}',
      );
      debugPrint(
        '📊 [CourseController] response.courses count: ${response.courses?.length}',
      );
      debugPrint('📊 [CourseController] response.total: ${response.total}');
      if (response.courses != null) {
        courses.value = response.courses!.map((apiCourse) {
          final displayTitle =
              apiCourse.title ??
              apiCourse.courseCode ??
              'Course #${apiCourse.id}';
          final displayInstructor =
              apiCourse.instructorName ??
              apiCourse.instructor?.username ??
              '';
          final double courseProgress = (apiCourse.progress is num)
              ? ((apiCourse.progress as num) > 1.0
                  ? (apiCourse.progress as num).toDouble() / 100.0
                  : (apiCourse.progress as num).toDouble())
              : 0.0;

          debugPrint(
            '📖 [CourseController] Mapping course: $displayTitle | instructor: $displayInstructor',
          );
          return CourseModel(
            id: apiCourse.id,
            title: displayTitle,
            instructor: displayInstructor,
            status: apiCourse.status ?? 'active',
            progress: courseProgress,
            totalClasses: 0,
            attendedClasses: 0,
            nextClass: 'N/A',
            nextExam: 'N/A',
            activities: [],
            courseCode: apiCourse.courseCode,
            coverImage: apiCourse.coverImage,
            grade: apiCourse.grade?.toString(),
          );
        }).toList();
        debugPrint(
          '✅ [CourseController] courses.value set, count: ${courses.length}',
        );
      } else {
        debugPrint(
          '⚠️ [CourseController] response.courses is NULL — list stays empty',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [CourseController] fetchCourses error: $e');
      debugPrint('🧱 [CourseController] StackTrace: $stackTrace');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
      debugPrint(
        '🏁 [CourseController] fetchCourses() done. Total courses: ${courses.length}',
      );
    }
  }

  Future<void> fetchDashboard() async {
    debugPrint('🚀 [CourseController] fetchDashboard() called');
    try {
      isLoadingDashboard.value = true;
      final items = await AcademicCourseService.getStudentDashboard();
      dashboardItems.assignAll(items);
      debugPrint(
        '✅ [CourseController] dashboardItems set, count: ${dashboardItems.length}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [CourseController] fetchDashboard error: $e');
      debugPrint('🧱 [CourseController] StackTrace: $stackTrace');
      dashboardItems.clear();
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  Future<void> fetchMyCrCourses() async {
    debugPrint('🚀 [CourseController] fetchMyCrCourses() called');
    try {
      isLoadingCr.value = true;
      final crList = await AcademicCourseService.getMyCrCourses();
      myCrCourses.assignAll(crList);
      debugPrint('👑 [CourseController] myCrCourses count: ${myCrCourses.length}');
    } catch (e) {
      debugPrint('❌ [CourseController] fetchMyCrCourses error: $e');
    } finally {
      isLoadingCr.value = false;
    }
  }

  // ─── CR Permissions & Status Helpers ─────────────────────────────────────
  bool isCrForCourse(int? courseId) {
    if (courseId == null || courseId == 0) return false;
    return myCrCourses.any((cr) => cr.courseId == courseId);
  }

  MyCrCourse? getCrInfo(int? courseId) {
    if (courseId == null || courseId == 0) return null;
    return myCrCourses.firstWhereOrNull((cr) => cr.courseId == courseId);
  }

  bool canManageNotices(int? courseId) {
    final info = getCrInfo(courseId);
    return info?.canManageNotices ?? false;
  }

  bool canManageModules(int? courseId) {
    final info = getCrInfo(courseId);
    return info?.canManageModules ?? false;
  }

  bool canManageAssessments(int? courseId) {
    final info = getCrInfo(courseId);
    return info?.canManageAssessments ?? false;
  }

  Future<void> refreshCourses() async {
    await Future.wait([fetchCourses(), fetchDashboard(), fetchMyCrCourses()]);
  }

  /// Add a new course dynamically
  void joinCourse(CourseModel newCourse) {
    courses.add(newCourse);
  }

  /// Update course progress
  void updateProgress(int index, double newProgress) {
    if (index < courses.length) {
      courses[index].progress = newProgress;
      courses[index].status = newProgress >= 1.0 ? "Completed" : "In Progress";
      courses.refresh();
    }
  }

  /// Add a new activity to a specific course
  void addActivity(int courseIndex, ActivityModel activity) {
    if (courseIndex < courses.length) {
      courses[courseIndex].activities.add(activity);
      courses.refresh();
    }
  }

  Future<void> confirmAndDropCourse(CourseModel course) async {
    final courseId = course.id;
    if (courseId == null || courseId == 0) {
      Get.snackbar('Error', 'Course id not found.');
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Drop course'),
        content: Text('Drop "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Drop'),
          ),
        ],
      ),
    );

    if (confirmed != true || isDroppingCourse.value) {
      return;
    }

    try {
      isDroppingCourse.value = true;
      await AcademicCourseService.dropCourse(courseId);
      await refreshCourses();
      Get.snackbar(
        'Success',
        'Course dropped successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [CourseController] dropCourse error: $e');
      debugPrint('🧱 [CourseController] StackTrace: $stackTrace');
      Get.snackbar('Error', e.toString());
    } finally {
      isDroppingCourse.value = false;
    }
  }
}
