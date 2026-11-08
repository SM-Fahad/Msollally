import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/teacher/courses/course_module/controller/course_module_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_notices/model/course_notice_model.dart';
import 'package:msollaally/feature/teacher/courses/course_notices/service/course_notice_service.dart';

class CourseNoticeController extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noticeController = TextEditingController();

  final notices = <CourseNotice>[].obs;
  final currentNotice = Rxn<CourseNotice>();
  final currentCourseId = 0.obs;
  final isLoadingNotices = false.obs;
  final isSavingNotice = false.obs;
  final isLoadingNoticeDetails = false.obs;
  final isDeletingNotice = false.obs;

  final CourseNoticeService _noticeService = CourseNoticeService();

  void initialize(dynamic args) {
    final nextCourseId = _resolveCourseId(args);
    if (nextCourseId == 0) {
      return;
    }

    final hasCourseChanged = currentCourseId.value != nextCourseId;
    currentCourseId.value = nextCourseId;

    if (hasCourseChanged) {
      notices.clear();
    }

    if (hasCourseChanged || notices.isEmpty) {
      fetchCourseNotices();
    }
  }

  void prepareCreateNotice(dynamic args) {
    final nextCourseId = _resolveCourseId(args);
    if (nextCourseId != 0) {
      currentCourseId.value = nextCourseId;
    }
    currentNotice.value = null;
    clearForm();
  }

  Future<void> prepareNoticeDetails(dynamic args) async {
    final nextCourseId = _resolveCourseId(args);
    if (nextCourseId != 0) {
      currentCourseId.value = nextCourseId;
    }

    CourseNotice? notice;
    int noticeId = 0;
    if (args is Map<String, dynamic>) {
      if (args['notice'] is CourseNotice) {
        notice = args['notice'] as CourseNotice;
      }
      noticeId = _parseInt(args['noticeId']);
    } else if (args is CourseNotice) {
      notice = args;
    }

    currentNotice.value = notice;
    if (notice != null) {
      titleController.text = notice.title;
      noticeController.text = notice.notice;
    } else {
      clearForm();
    }

    noticeId = notice?.id ?? noticeId;
    if (noticeId != 0) {
      await fetchNoticeDetails(noticeId);
    }
  }

  Future<void> fetchCourseNotices() async {
    if (currentCourseId.value == 0 || isLoadingNotices.value) {
      return;
    }

    isLoadingNotices.value = true;
    try {
      final items = await _noticeService.getCourseNotices(
        currentCourseId.value,
      );
      notices.assignAll(items);
    } catch (_) {
    } finally {
      isLoadingNotices.value = false;
    }
  }

  Future<void> fetchNoticeDetails(int noticeId) async {
    if (isLoadingNoticeDetails.value) {
      return;
    }

    isLoadingNoticeDetails.value = true;
    try {
      final notice = await _noticeService.getCourseNoticeDetails(noticeId);
      currentNotice.value = notice;
      if (notice.courseId != 0) {
        currentCourseId.value = notice.courseId;
      }
      titleController.text = notice.title;
      noticeController.text = notice.notice;
      _upsertNotice(notice);
    } catch (_) {
    } finally {
      isLoadingNoticeDetails.value = false;
    }
  }

  Future<void> createNotice() async {
    final courseId = currentCourseId.value;
    if (courseId == 0) {
      return;
    }
    if (isSavingNotice.value) {
      return;
    }

    final title = titleController.text.trim();
    final notice = noticeController.text.trim();
    if (!_validateForm(title, notice)) {
      return;
    }

    isSavingNotice.value = true;
    try {
      final created = await _noticeService.createCourseNotice(
        courseId: courseId,
        title: title,
        notice: notice,
      );
      notices.insert(0, created);
      currentNotice.value = created;
      Get.back(result: created);
    } catch (_) {
    } finally {
      isSavingNotice.value = false;
    }
  }

  Future<void> updateNotice() async {
    final noticeItem = currentNotice.value;
    if (noticeItem == null) {
      return;
    }
    if (isSavingNotice.value) {
      return;
    }

    final title = titleController.text.trim();
    final notice = noticeController.text.trim();
    if (!_validateForm(title, notice)) {
      return;
    }

    isSavingNotice.value = true;
    try {
      final updated = await _noticeService.updateCourseNotice(
        noticeId: noticeItem.id,
        title: title,
        notice: notice,
      );
      currentNotice.value = updated;
      _upsertNotice(updated);
    } catch (_) {
    } finally {
      isSavingNotice.value = false;
    }
  }

  Future<void> deleteNotice() async {
    final noticeItem = currentNotice.value;
    if (noticeItem == null || isDeletingNotice.value) {
      return;
    }

    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete notice'),
        content: Text(
          'Delete "${noticeItem.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    isDeletingNotice.value = true;
    try {
      await _noticeService.deleteCourseNotice(noticeItem.id);
      notices.removeWhere((item) => item.id == noticeItem.id);
      currentNotice.value = null;
      Get.back(result: true);
    } catch (_) {
    } finally {
      isDeletingNotice.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    noticeController.clear();
  }

  void clearCurrentNotice() {
    currentNotice.value = null;
    clearForm();
    isLoadingNoticeDetails.value = false;
    isSavingNotice.value = false;
    isDeletingNotice.value = false;
  }

  @override
  void onClose() {
    titleController.dispose();
    noticeController.dispose();
    super.onClose();
  }

  bool _validateForm(String title, String notice) {
    if (title.isEmpty) {
      return false;
    }
    if (notice.isEmpty) {
      return false;
    }
    return true;
  }

  int _resolveCourseId(dynamic args) {
    if (args is Map<String, dynamic>) {
      final fromArgs = _parseInt(args['courseId']);
      if (fromArgs != 0) {
        return fromArgs;
      }
    }

    if (Get.isRegistered<CourseModuleController>()) {
      return Get.find<CourseModuleController>().selectedCourse.value?.id ?? 0;
    }

    return 0;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  void _upsertNotice(CourseNotice notice) {
    final index = notices.indexWhere((item) => item.id == notice.id);
    if (index == -1) {
      notices.insert(0, notice);
    } else {
      notices[index] = notice;
    }
  }
}
