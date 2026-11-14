import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/teacher/courses/model/teacher_course_model.dart';
import 'package:msollaally/feature/teacher/courses/service/teacher_course_service.dart';
import 'package:msollaally/routes/app_route.dart';
import '../model/academic_course_model.dart';
import '../../courseDetail/model/course_model.dart';
import '../../cr/model/cr_course_model.dart';
import '../service/academic_course_service.dart';

class CourseController extends GetxController {
  var courses = <CourseModel>[].obs;
  var dashboardItems = <StudentCourseDashboardItem>[].obs;
  var myCrCourses = <MyCrCourse>[].obs;
  var myCreatedCourses = <TeacherCourseModel>[].obs;
  var isCr = false.obs;
  var isLoading = false.obs;
  var isLoadingDashboard = false.obs;
  var isLoadingCr = false.obs;
  var isLoadingCreatedCourses = false.obs;
  var isDroppingCourse = false.obs;
  final publishingCourseIds = <int>{}.obs;
  final archivingCourseIds = <int>{}.obs;

  final TeacherCourseService _crCourseService = TeacherCourseService();

  @override
  void onInit() {
    super.onInit();
    _loadCachedCrStatus();
    refreshCourses();
  }

  Future<void> _loadCachedCrStatus() async {
    final cached = await SharedPreferenceHelper().getIsCr();
    if (cached && !isCr.value) {
      isCr.value = true;
    }
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
      final results = await Future.wait([
        AcademicCourseService.getAuthMeCrStatus(),
        AcademicCourseService.getMyCrCourses(),
      ]);

      final authMe =
          results[0] as ({bool isCr, List<MyCrCourse> crAssignments});
      final crList = results[1] as List<MyCrCourse>;

      final mergedByCourseId = <int, MyCrCourse>{};
      for (final item in authMe.crAssignments) {
        if (item.courseId != 0) {
          mergedByCourseId[item.courseId] = item;
        }
      }
      for (final item in crList) {
        if (item.courseId != 0) {
          mergedByCourseId[item.courseId] = item;
        }
      }

      myCrCourses.assignAll(mergedByCourseId.values);
      isCr.value = authMe.isCr || myCrCourses.isNotEmpty;

      debugPrint(
        '👑 [CourseController] isCr: ${isCr.value}, myCrCourses count: ${myCrCourses.length}',
      );

      if (isCr.value) {
        await fetchMyCreatedCourses();
      } else {
        myCreatedCourses.clear();
      }
    } catch (e) {
      debugPrint('❌ [CourseController] fetchMyCrCourses error: $e');
    } finally {
      isLoadingCr.value = false;
    }
  }

  Future<void> fetchMyCreatedCourses() async {
    debugPrint('🚀 [CourseController] fetchMyCreatedCourses() called');
    try {
      isLoadingCreatedCourses.value = true;
      final createdList = await _crCourseService.getMyCourses();
      myCreatedCourses.assignAll(createdList);
      debugPrint(
        '👑 [CourseController] myCreatedCourses count: ${myCreatedCourses.length}',
      );
    } catch (e) {
      debugPrint('❌ [CourseController] fetchMyCreatedCourses error: $e');
    } finally {
      isLoadingCreatedCourses.value = false;
    }
  }

  // ─── CR Permissions & Status Helpers ─────────────────────────────────────
  bool isCreatedByMe(int? courseId) {
    if (courseId == null || courseId == 0) return false;
    return myCreatedCourses.any((c) => c.id == courseId);
  }

  bool isCrForCourse(int? courseId) {
    if (courseId == null || courseId == 0) return false;
    return myCrCourses.any((cr) => cr.courseId == courseId) ||
        isCreatedByMe(courseId);
  }

  MyCrCourse? getCrInfo(int? courseId) {
    if (courseId == null || courseId == 0) return null;
    final assigned = myCrCourses.firstWhereOrNull(
      (cr) => cr.courseId == courseId,
    );
    if (assigned != null) return assigned;

    final created = myCreatedCourses.firstWhereOrNull((c) => c.id == courseId);
    if (created != null) {
      return MyCrCourse(
        id: created.id,
        courseId: created.id,
        canManageModules: true,
        canManageNotices: true,
        canManageAssessments: true,
        assignedAt: created.createdAt,
        course: CrCourseInfo(
          id: created.id,
          title: created.title,
          code: created.courseCode,
          coverImage: created.coverImage,
        ),
      );
    }
    return null;
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

  // ─── CR Course Creation & Management Actions ─────────────────────────────
  bool isPublishingCourse(int courseId) =>
      publishingCourseIds.contains(courseId);

  bool isArchivingCourse(int courseId) => archivingCourseIds.contains(courseId);

  Future<void> openCreateCourse() async {
    await Get.toNamed(AppRoute.teacherAddCourse);
    await Future.wait([fetchMyCreatedCourses(), fetchCourses()]);
  }

  Future<void> openEditCourse(TeacherCourseModel course) async {
    await Get.toNamed(AppRoute.teacherAddCourse, arguments: {'course': course});
    await Future.wait([fetchMyCreatedCourses(), fetchCourses()]);
  }

  Future<void> openManageCourse(TeacherCourseModel course) async {
    await Get.toNamed(AppRoute.teacherCourseModule, arguments: course);
    await fetchMyCreatedCourses();
  }

  Future<void> publishCreatedCourse(TeacherCourseModel course) async {
    if (publishingCourseIds.contains(course.id)) return;
    if (course.moduleCount == 0) {
      EasyLoading.showError(
        'Add at least one module before publishing, or edit the course and set it to Public.',
      );
      return;
    }

    publishingCourseIds.add(course.id);
    try {
      final published = await _crCourseService.publishCourse(course.id);
      final index = myCreatedCourses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        myCreatedCourses[index] = published.id == 0
            ? myCreatedCourses[index].copyWith(
                status: 'published',
                isPublic: true,
              )
            : published;
      }
      EasyLoading.showSuccess('Course published successfully.');
    } catch (e) {
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      publishingCourseIds.remove(course.id);
      publishingCourseIds.refresh();
    }
  }

  Future<void> archiveCreatedCourse(TeacherCourseModel course) async {
    if (archivingCourseIds.contains(course.id)) return;

    archivingCourseIds.add(course.id);
    try {
      final archived = await _crCourseService.archiveCourse(course.id);
      final index = myCreatedCourses.indexWhere((c) => c.id == course.id);
      if (index != -1) {
        myCreatedCourses[index] = archived.id == 0
            ? myCreatedCourses[index].copyWith(
                status: 'archived',
                isPublic: false,
              )
            : archived;
      }
      EasyLoading.showSuccess('Course archived successfully.');
    } catch (e) {
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      archivingCourseIds.remove(course.id);
      archivingCourseIds.refresh();
    }
  }

  Future<void> confirmDeleteCreatedCourse(TeacherCourseModel course) async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete course'),
        content: Text(
          'Delete "${course.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    EasyLoading.show(status: 'Deleting course...');
    try {
      await _crCourseService.deleteCourse(course.id);
      myCreatedCourses.removeWhere((item) => item.id == course.id);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Course deleted successfully.');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(e.toString().replaceFirst('Exception: ', ''));
    }
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
