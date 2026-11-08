import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/courses/academic_courses/service/academic_course_service.dart';
import '../model/course_notice_model.dart';

class NoticeController extends GetxController {
  NoticeController({required this.courseId});

  final int? courseId;
  var notices = <CourseNoticeModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchNotices();
  }

  Future<void> fetchNotices() async {
    final id = courseId;
    if (id == null) {
      errorMessage.value = 'Course id not available for notices.';
      notices.clear();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;
      notices.value = await AcademicCourseService.getCourseNotices(id);
    } catch (e, stackTrace) {
      debugPrint('❌ [NoticeController] fetchNotices error: $e');
      debugPrint('🧱 [NoticeController] StackTrace: $stackTrace');
      errorMessage.value = e.toString();
      notices.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
