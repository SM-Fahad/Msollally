import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/feature/teacher/courses/model/teacher_course_model.dart';
import 'package:msollaally/feature/teacher/courses/service/teacher_course_service.dart';

class CourseScreenController extends GetxController {
  final activityList = <TeacherCourseModel>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isUploadingImage = false.obs;
  final publishingCourseIds = <int>{}.obs;
  final cloningCourseIds = <int>{}.obs;
  final selectedCoverImage = Rx<File?>(null);
  final currentEditingCourse = Rxn<TeacherCourseModel>();
  final selectedStartDate = Rxn<DateTime>();
  final selectedEndDate = Rxn<DateTime>();
  final currentCoverImageUrl = ''.obs;
  final isPublic = true.obs;

  final TextEditingController addCourseTitleController =
      TextEditingController();
  final TextEditingController addCourseDescriptionController =
      TextEditingController();
  final TextEditingController addCourseCodeController = TextEditingController();
  final TextEditingController addCourseStartDateController =
      TextEditingController();
  final TextEditingController addCourseEndDateController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final TeacherCourseService _courseService = TeacherCourseService();

  @override
  void onInit() {
    super.onInit();
    fetchMyCourses();
  }

  bool get isEditingCourse => currentEditingCourse.value != null;

  Future<void> fetchMyCourses({bool showLoader = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    if (showLoader) {
      EasyLoading.show(status: 'Loading courses...');
    }

    try {
      final courses = await _courseService.getMyCourses();
      activityList.assignAll(courses);
    } catch (e) {
      if (showLoader) {
        EasyLoading.showError(_extractErrorMessage(e));
      }
    } finally {
      if (showLoader) {
        EasyLoading.dismiss();
      }
      isLoading.value = false;
    }
  }

  void prepareCourseForm(dynamic args) {
    TeacherCourseModel? course;
    if (args is TeacherCourseModel) {
      course = args;
    } else if (args is Map<String, dynamic> &&
        args['course'] is TeacherCourseModel) {
      course = args['course'] as TeacherCourseModel;
    }

    if (course == null) {
      clearCourseForm();
      return;
    }

    currentEditingCourse.value = course;
    addCourseTitleController.text = course.title;
    addCourseDescriptionController.text = course.description;
    addCourseCodeController.text = course.courseCode;
    selectedStartDate.value = course.startDate;
    selectedEndDate.value = course.endDate;
    addCourseStartDateController.text = _formatFormDate(course.startDate);
    addCourseEndDateController.text = _formatFormDate(course.endDate);
    currentCoverImageUrl.value = course.coverImage;
    selectedCoverImage.value = null;
    isPublic.value = course.isPublic;
  }

  Future<void> pickCoverImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedCoverImage.value = File(pickedFile.path);
      }
    } catch (_) {
      EasyLoading.showError('Failed to pick cover image.');
    }
  }

  void removeCoverImage() {
    selectedCoverImage.value = null;
  }

  Future<void> pickCourseDate({required bool isStart}) async {
    final initialDate =
        (isStart ? selectedStartDate.value : selectedEndDate.value) ??
        DateTime.now();

    final pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) {
      return;
    }

    final normalizedDate = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
    );

    if (isStart) {
      selectedStartDate.value = normalizedDate;
      addCourseStartDateController.text = _formatFormDate(normalizedDate);
    } else {
      selectedEndDate.value = normalizedDate;
      addCourseEndDateController.text = _formatFormDate(normalizedDate);
    }
  }

  Future<void> saveCourse() async {
    if (isEditingCourse) {
      await updateCourse();
      return;
    }
    await createCourse();
  }

  Future<void> createCourse() async {
    if (isSubmitting.value || isUploadingImage.value) {
      return;
    }

    final title = addCourseTitleController.text.trim();
    final description = addCourseDescriptionController.text.trim();
    final courseCode = addCourseCodeController.text.trim();
    final coverImageFile = selectedCoverImage.value;
    final startDate = selectedStartDate.value;
    final endDate = selectedEndDate.value;

    final validationError = _validateCourseForm(
      title: title,
      description: description,
      courseCode: courseCode,
      startDate: startDate,
      endDate: endDate,
      requireCoverImage: false,
      hasCoverImage: coverImageFile != null,
    );
    if (validationError != null) {
      EasyLoading.showError(validationError);
      return;
    }

    isSubmitting.value = true;
    isUploadingImage.value = coverImageFile != null;
    EasyLoading.show(status: 'Creating course...');

    try {
      final createdCourse = await _courseService.createCourse(
        title: title,
        description: description,
        courseCode: courseCode,
        coverImageFile: coverImageFile,
        startDate: startDate,
        endDate: endDate,
        isPublic: isPublic.value,
      );

      activityList.insert(0, createdCourse);
      clearCourseForm();
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Course created successfully.');
      Get.back(result: createdCourse);
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isSubmitting.value = false;
      isUploadingImage.value = false;
    }
  }

  Future<void> updateCourse() async {
    final course = currentEditingCourse.value;
    if (course == null || isSubmitting.value || isUploadingImage.value) {
      return;
    }

    final title = addCourseTitleController.text.trim();
    final description = addCourseDescriptionController.text.trim();
    final courseCode = addCourseCodeController.text.trim();
    final startDate = selectedStartDate.value;
    final endDate = selectedEndDate.value;
    final hasCoverImage =
        selectedCoverImage.value != null ||
        currentCoverImageUrl.value.trim().isNotEmpty;

    final validationError = _validateCourseForm(
      title: title,
      description: description,
      courseCode: courseCode,
      startDate: startDate,
      endDate: endDate,
      requireCoverImage: false,
      hasCoverImage: hasCoverImage,
    );
    if (validationError != null) {
      EasyLoading.showError(validationError);
      return;
    }

    isSubmitting.value = true;
    EasyLoading.show(status: 'Updating course...');

    try {
      if (selectedCoverImage.value != null) {
        isUploadingImage.value = true;
      }

      final updatedCourse = await _courseService.updateCourse(
        courseId: course.id,
        title: title,
        description: description,
        courseCode: courseCode,
        currentCoverImage: currentCoverImageUrl.value.trim(),
        coverImageFile: selectedCoverImage.value,
        startDate: startDate,
        endDate: endDate,
        status: course.status,
        isPublic: isPublic.value,
      );

      _upsertCourse(updatedCourse);
      clearCourseForm();
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Course updated successfully.');
      Get.back(result: updatedCourse);
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isSubmitting.value = false;
      isUploadingImage.value = false;
    }
  }

  Future<void> confirmDeleteCourse(TeacherCourseModel course) async {
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    EasyLoading.show(status: 'Deleting course...');
    try {
      await _courseService.deleteCourse(course.id);
      activityList.removeWhere((item) => item.id == course.id);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Course deleted successfully.');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    }
  }

  Future<void> publishCourse(TeacherCourseModel course) async {
    if (publishingCourseIds.contains(course.id)) {
      return;
    }
    if (course.moduleCount == 0) {
      EasyLoading.showError('Add at least one module before publishing.');
      return;
    }

    publishingCourseIds.add(course.id);
    try {
      final publishedCourse = await _courseService.publishCourse(course.id);
      final index = activityList.indexWhere((item) => item.id == course.id);
      if (index != -1) {
        activityList[index] = publishedCourse.id == 0
            ? activityList[index].copyWith(status: 'published')
            : publishedCourse;
      }
      EasyLoading.showSuccess('Course published successfully.');
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      publishingCourseIds.remove(course.id);
      publishingCourseIds.refresh();
    }
  }

  bool isPublishing(int courseId) => publishingCourseIds.contains(courseId);

  bool isCloning(int courseId) => cloningCourseIds.contains(courseId);

  Future<void> promptCloneCourse(TeacherCourseModel course) async {
    if (cloningCourseIds.contains(course.id)) {
      return;
    }

    final titleController = TextEditingController(text: '${course.title} Copy');
    final courseCodeController = TextEditingController(
      text: '${course.courseCode}-COPY',
    );

    try {
      final clonePayload = await Get.dialog<Map<String, String>>(
        AlertDialog(
          title: const Text('Clone course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a new copy of "${course.title}" with a new title and course code.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Course title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: courseCodeController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Course code',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) {
                  final title = titleController.text.trim();
                  final courseCode = courseCodeController.text.trim();
                  if (title.isEmpty || courseCode.isEmpty) {
                    return;
                  }
                  Get.back(result: {'title': title, 'courseCode': courseCode});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final title = titleController.text.trim();
                final courseCode = courseCodeController.text.trim();
                if (title.isEmpty || courseCode.isEmpty) {
                  EasyLoading.showError(
                    'Please enter a title and course code.',
                  );
                  return;
                }
                Get.back(result: {'title': title, 'courseCode': courseCode});
              },
              child: const Text('Clone'),
            ),
          ],
        ),
      );

      if (clonePayload == null) {
        return;
      }

      await cloneCourse(
        course: course,
        title: clonePayload['title'] ?? '',
        courseCode: clonePayload['courseCode'] ?? '',
      );
    } finally {
      titleController.dispose();
      courseCodeController.dispose();
    }
  }

  Future<void> cloneCourse({
    required TeacherCourseModel course,
    required String title,
    required String courseCode,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedCourseCode = courseCode.trim();

    if (trimmedTitle.isEmpty) {
      EasyLoading.showError('Please enter a course title.');
      return;
    }
    if (trimmedCourseCode.isEmpty) {
      EasyLoading.showError('Please enter a course code.');
      return;
    }
    if (cloningCourseIds.contains(course.id)) {
      return;
    }

    cloningCourseIds.add(course.id);
    try {
      EasyLoading.show(status: 'Cloning course...');
      final clonedCourse = await _courseService.cloneCourse(
        courseId: course.id,
        title: trimmedTitle,
        courseCode: trimmedCourseCode,
      );
      activityList.insert(0, clonedCourse);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Course cloned successfully.');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      cloningCourseIds.remove(course.id);
      cloningCourseIds.refresh();
    }
  }

  void clearCourseForm() {
    addCourseTitleController.clear();
    addCourseDescriptionController.clear();
    addCourseCodeController.clear();
    addCourseStartDateController.clear();
    addCourseEndDateController.clear();
    selectedCoverImage.value = null;
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    currentEditingCourse.value = null;
    currentCoverImageUrl.value = '';
    isPublic.value = true;
  }

  String _extractErrorMessage(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '');
  }

  String? _validateCourseForm({
    required String title,
    required String description,
    required String courseCode,
    required DateTime? startDate,
    required DateTime? endDate,
    required bool requireCoverImage,
    required bool hasCoverImage,
  }) {
    if (title.isEmpty) {
      return 'Please enter a course title.';
    }
    if (title.length > 255) {
      return 'Course title must be at most 255 characters.';
    }
    if (courseCode.isEmpty) {
      return 'Please enter a course code.';
    }
    if (courseCode.length > 50) {
      return 'Course code must be at most 50 characters.';
    }
    if (startDate != null && endDate != null && !endDate.isAfter(startDate)) {
      return 'End date must be after the start date.';
    }
    if (requireCoverImage && !hasCoverImage) {
      return 'Please select a cover image.';
    }
    return null;
  }

  void _upsertCourse(TeacherCourseModel course) {
    final index = activityList.indexWhere((item) => item.id == course.id);
    if (index == -1) {
      activityList.insert(0, course);
      return;
    }
    activityList[index] = course;
  }

  String _formatFormDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  void onClose() {
    addCourseTitleController.dispose();
    addCourseDescriptionController.dispose();
    addCourseCodeController.dispose();
    addCourseStartDateController.dispose();
    addCourseEndDateController.dispose();
    super.onClose();
  }
}
