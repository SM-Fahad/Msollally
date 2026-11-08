import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/feature/student/academics/courses/assessment/service/student_assessment_service.dart';
import 'package:msollaally/feature/teacher/courses/course_module/model/course_module_model.dart';

class StudentAssessmentController extends GetxController {
  StudentAssessmentController({required this.courseId});

  final int courseId;
  final StudentAssessmentService _service = StudentAssessmentService();

  final assessments = <Map<String, dynamic>>[].obs;
  final myCourseSubmissions = <Map<String, dynamic>>[].obs;
  final selectedFiles = <File>[].obs;
  final isLoading = false.obs;
  final isLoadingDetails = false.obs;
  final isSubmitting = false.obs;
  final isDeletingSubmission = false.obs;
  final errorMessage = RxnString();
  final currentAssessment = Rxn<Map<String, dynamic>>();
  final mySubmission = Rxn<Map<String, dynamic>>();
  final currentAssessmentId = 0.obs;
  final loadedSubmissionAssessmentId = 0.obs;
  final submissionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchAssessments();
    fetchCourseMySubmissions();
  }

  @override
  void onClose() {
    submissionController.dispose();
    super.onClose();
  }

  Future<void> fetchAssessments() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final items = await _service.getAssessments(courseId);
      assessments.assignAll(items.map(_normalizeAssessmentListItem).toList());
    } catch (e) {
      assessments.clear();
      // errorMessage.value = _cleanError(e, 'Failed to load assessments.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAssessmentDetails(int assessmentId) async {
    try {
      isLoadingDetails.value = true;
      currentAssessmentId.value = assessmentId;
      final details = await _service.getAssessmentDetails(assessmentId);
      final normalized = _normalizeAssessmentDetails(details);
      currentAssessment.value = normalized;
    } catch (e) {
      currentAssessment.value = null;
      // EasyLoading.showError(
      //   _cleanError(e, 'Failed to load assessment details.'),
      // );
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> fetchMySubmission([int? assessmentId]) async {
    final id = assessmentId ?? currentAssessmentId.value;
    if (id == 0) return;

    try {
      final submission = await _service.getMySubmission(id);
      if (submission == null || submission.isEmpty) {
        mySubmission.value = null;
        loadedSubmissionAssessmentId.value = id;
        return;
      }

      final normalized = _normalizeSubmission(submission);
      mySubmission.value = normalized;
      loadedSubmissionAssessmentId.value = id;
      if (submissionController.text.trim().isEmpty) {
        submissionController.text = (normalized['content'] ?? '').toString();
      }
    } catch (e) {
      mySubmission.value = null;
      loadedSubmissionAssessmentId.value = 0;
    }
  }

  Future<void> fetchCourseMySubmissions() async {
    try {
      final items = await _service.getCourseMySubmissions(courseId);
      myCourseSubmissions.assignAll(items.map(_normalizeSubmission).toList());
    } catch (_) {
      myCourseSubmissions.clear();
    }
  }

  Future<void> openAssessment(int assessmentId) async {
    clearDraftSubmission();
    await fetchAssessmentDetails(assessmentId);
    await fetchMySubmission(assessmentId);
  }

  Future<void> ensureAssessmentOpened(int assessmentId) async {
    final sameAssessment = currentAssessmentId.value == assessmentId;
    final hasAssessment = currentAssessment.value != null;
    final submissionLoaded = loadedSubmissionAssessmentId.value == assessmentId;

    if (sameAssessment && hasAssessment && submissionLoaded) {
      return;
    }

    if (sameAssessment && isLoadingDetails.value) {
      return;
    }

    await openAssessment(assessmentId);
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result == null) {
      return;
    }

    final files = result.paths
        .whereType<String>()
        .map(File.new)
        .where((file) => file.existsSync())
        .toList();

    if (files.isEmpty) {
      return;
    }

    final existingPaths = selectedFiles.map((file) => file.path).toSet();
    final merged = <File>[...selectedFiles];
    for (final file in files) {
      if (!existingPaths.contains(file.path)) {
        merged.add(file);
      }
    }
    selectedFiles.assignAll(merged);
  }

  void removePickedFileAt(int index) {
    if (index < 0 || index >= selectedFiles.length) return;
    selectedFiles.removeAt(index);
  }

  void clearDraftSubmission() {
    selectedFiles.clear();
    submissionController.clear();
    mySubmission.value = null;
    loadedSubmissionAssessmentId.value = 0;
  }

  Future<void> submitCurrentAssessment() async {
    final assessmentId = currentAssessmentId.value;
    if (assessmentId == 0) {
      EasyLoading.showError('Assessment not found.');
      return;
    }

    final content = submissionController.text.trim();
    if (content.isEmpty && selectedFiles.isEmpty) {
      EasyLoading.showError('Add an answer or attach at least one file.');
      return;
    }

    try {
      isSubmitting.value = true;
      EasyLoading.show(status: 'Submitting assessment...');

      final uploadedUrls = await _service.uploadAssessmentFiles(selectedFiles);

      await _service.submitAssessment(
        assessmentId: assessmentId,
        content: content,
        fileUrls: uploadedUrls,
      );

      selectedFiles.clear();
      await fetchAssessmentDetails(assessmentId);
      await fetchMySubmission(assessmentId);
      await fetchCourseMySubmissions();

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Assessment submitted successfully.');
    } catch (e) {
      EasyLoading.showError(_cleanError(e, 'Failed to submit assessment.'));
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteCurrentSubmission() async {
    final assessmentId = currentAssessmentId.value;
    if (assessmentId == 0) {
      EasyLoading.showError('Assessment not found.');
      return false;
    }
    if (isDeletingSubmission.value) {
      return false;
    }

    try {
      isDeletingSubmission.value = true;
      EasyLoading.show(status: 'Deleting submission...');

      await _service.deleteMySubmission(assessmentId);

      mySubmission.value = null;
      loadedSubmissionAssessmentId.value = assessmentId;
      submissionController.clear();
      selectedFiles.clear();
      myCourseSubmissions.removeWhere(
        (item) => _parseInt(item['assessmentId']) == assessmentId,
      );

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Submission deleted successfully.');
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(
        _cleanError(e, 'Failed to delete your submission.'),
      );
      return false;
    } finally {
      isDeletingSubmission.value = false;
    }
  }

  String dueDateLabel(Map<String, dynamic> assessment) {
    final dueDate = _parseDate(assessment['dueDate']);
    if (dueDate == null) {
      return 'No due date';
    }
    return DateFormat('dd MMM yyyy • hh:mm a').format(dueDate.toLocal());
  }

  String remainingLabel(Map<String, dynamic> assessment) {
    final dueDate = _parseDate(assessment['dueDate']);
    if (dueDate == null) {
      return 'Schedule pending';
    }

    final difference = dueDate.difference(DateTime.now());
    if (difference.isNegative) {
      final daysLate = difference.inDays.abs();
      return daysLate == 0 ? 'Deadline passed' : '$daysLate days overdue';
    }

    if (difference.inDays > 0) {
      return '${difference.inDays} days remaining';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} hours remaining';
    }
    final minutes = difference.inMinutes.clamp(0, 59);
    return '$minutes minutes remaining';
  }

  List<ClassFile> assessmentFiles(Map<String, dynamic>? assessment) {
    final rawFiles = assessment?['files'];
    if (rawFiles is! List) {
      return const <ClassFile>[];
    }

    return rawFiles
        .whereType<Map>()
        .map((item) => ClassFile.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  List<String> submissionFileUrls(Map<String, dynamic>? submission) {
    final rawFileUrls =
        submission?['fileUrls'] ??
        submission?['files'] ??
        submission?['attachments'];
    if (rawFileUrls is List) {
      return rawFileUrls
          .map((item) {
            if (item is String) return item;
            if (item is Map) {
              return (item['url'] ?? item['fileUrl'] ?? '').toString();
            }
            return '';
          })
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  Map<String, dynamic> _normalizeAssessmentListItem(Map<String, dynamic> item) {
    return {
      ...item,
      'id': _parseInt(item['id']),
      'courseId': _parseInt(item['courseId']),
      'title': (item['title'] ?? 'Assessment').toString(),
      'type': (item['type'] ?? 'assessment').toString(),
      'questionFormat': (item['questionFormat'] ?? '').toString(),
      'classroom': (item['classroom'] ?? 'TBA').toString(),
      'notes': (item['notes'] ?? '').toString(),
      'totalMarks': _parseInt(item['totalMarks']),
      'files': item['files'] is List ? item['files'] : const [],
      'dueDate': item['dueDate']?.toString(),
    };
  }

  Map<String, dynamic> _normalizeAssessmentDetails(Map<String, dynamic> item) {
    return {
      ..._normalizeAssessmentListItem(item),
      'course': item['course'],
      'creator': item['creator'],
      'createdAt': item['createdAt']?.toString(),
      'updatedAt': item['updatedAt']?.toString(),
      'submissions': item['submissions'] is List
          ? item['submissions']
          : const [],
    };
  }

  Map<String, dynamic> _normalizeSubmission(Map<String, dynamic> item) {
    final submittedAt = _parseDate(
      item['submittedAt'] ?? item['createdAt'] ?? item['updatedAt'],
    );
    final gradedAt = _parseDate(item['gradedAt']);
    final grader = item['grader'];
    final graderName = grader is Map
        ? (grader['username'] ??
                  grader['name'] ??
                  grader['fullName'] ??
                  grader['teacherName'] ??
                  '')
              .toString()
        : '';

    return {
      ...item,
      'id': _parseInt(item['id']),
      'content': (item['content'] ?? item['answer'] ?? '').toString(),
      'status': (item['status'] ?? 'submitted').toString(),
      'marks': (item['marks'] ?? item['score'] ?? '').toString(),
      'feedback': (item['feedback'] ?? item['remarks'] ?? '').toString(),
      'gradedBy': _parseInt(item['gradedBy']),
      'graderName': graderName,
      'gradedAt': gradedAt?.toIso8601String(),
      'gradedAtLabel': gradedAt == null
          ? ''
          : DateFormat('dd MMM yyyy • hh:mm a').format(gradedAt.toLocal()),
      'submittedAt': submittedAt?.toIso8601String(),
      'submittedAtLabel': submittedAt == null
          ? 'Not submitted yet'
          : DateFormat('dd MMM yyyy • hh:mm a').format(submittedAt.toLocal()),
    };
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _cleanError(Object error, String fallback) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty ? fallback : message;
  }
}
