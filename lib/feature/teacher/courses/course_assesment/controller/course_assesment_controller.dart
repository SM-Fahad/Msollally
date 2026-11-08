import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/feature/teacher/courses/course_assesment/service/course_assessment_detail_service.dart';
import 'package:msollaally/feature/teacher/courses/course_assesment/service/course_assessment_service.dart';
import 'package:msollaally/feature/teacher/courses/course_module/controller/course_module_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_module/model/course_module_model.dart';
import 'package:msollaally/feature/teacher/courses/course_module/model/upload_file.dart';
import 'package:msollaally/feature/teacher/courses/model/teacher_course_model.dart';

class CourseAssessmentController extends GetxController {
  final TextEditingController examTitleController = TextEditingController();
  final TextEditingController classroomController = TextEditingController();
  final TextEditingController totalMarksController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  final selectedFilter = '--'.obs;
  final currentCourseId = 0.obs;
  final currentCourseTitle = ''.obs;
  final currentAssessmentId = 0.obs;
  final isLoadingAssessments = false.obs;
  final isLoadingAssessmentDetails = false.obs;
  final isLoadingAssessmentSubmissions = false.obs;
  final isCreatingAssessment = false.obs;
  final isUpdatingAssessment = false.obs;
  final isDeletingAssessment = false.obs;
  final isUploadingAssessmentFile = false.obs;
  final isGradingSubmission = false.obs;
  final selectedAssessmentType = RxnString();
  final selectedQuestionFormat = RxnString();
  final currentAssessment = Rxn<Map<String, dynamic>>();

  final CourseAssessmentService _assessmentService = CourseAssessmentService();
  final CourseAssessmentDetailService _assessmentDetailService =
      CourseAssessmentDetailService();

  final List<String> assessmentTypes = const [
    'exam',
    'quiz',
    'assignment',
    'project',
    'presentation',
  ];

  final List<String> questionFormats = const [
    'multiple_choice',
    'short_answer',
    'essay',
    'true_false',
    'mixed',
  ];

  final assessments = <Map<String, dynamic>>[].obs;
  final assessmentFiles = <ClassFile>[].obs;
  final assessmentSubmissions = <Map<String, dynamic>>[].obs;
  final files = <UploadFile>[].obs;

  List<Map<String, dynamic>> get filteredAssessments => assessments;

  List<String> get filterOptions => <String>['--', ...assessmentTypes];

  Future<void> updateFilter(String value) async {
    selectedFilter.value = value;
    await fetchAssessments();
  }

  void initialize(dynamic args) {
    final previousCourseId = currentCourseId.value;
    final nextCourseId = _resolveCourseId(args);
    if (nextCourseId != 0) {
      currentCourseId.value = nextCourseId;
    }
    final title = _resolveCourseTitle(args);
    if (title.isNotEmpty) {
      currentCourseTitle.value = title;
    }

    final hasCourseChanged = previousCourseId != currentCourseId.value;
    if (hasCourseChanged) {
      assessments.clear();
    }

    if (hasCourseChanged || assessments.isEmpty) {
      fetchAssessments();
    }
  }

  void prepareCreateAssessment(dynamic args) {
    initialize(args);
    clearCreateAssessmentForm();
  }

  // Reactive variable to store the selected date
  var selectedDate = Rxn<DateTime>(); // Rxn for nullable DateTime
  var selectedDateTime = Rxn<DateTime>();

  Future<void> pickDateTime() async {
    // Step 1: Pick Date
    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return; // user cancelled

    // Step 2: Pick Time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return; // user cancelled

    // Step 3: Combine Date + Time
    final combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    selectedDateTime.value = combinedDateTime;

    final dt = selectedDateTime.value!;

    // Format date (yyyy-MM-dd)
    String formattedDate = DateFormat('yyyy-MM-dd').format(dt);

    // Format time (HH:mm) → 24-hour
    DateFormat('HH:mm').format(dt);

    // Or 12-hour with AM/PM
    String formattedTime12h = DateFormat('hh:mm a').format(dt);

    // Example: set to TextEditingController
    dateController.text = "$formattedDate $formattedTime12h";
  }

  Future<void> createAssessment() async {
    if (isCreatingAssessment.value) {
      return;
    }

    final courseId = currentCourseId.value;
    if (courseId == 0) {
      EasyLoading.showError('Course not found.');
      return;
    }

    final title = examTitleController.text.trim();
    final classroom = classroomController.text.trim();
    final notes = notesController.text.trim();
    final totalMarks = int.tryParse(totalMarksController.text.trim());
    final type = selectedAssessmentType.value;
    final questionFormat = selectedQuestionFormat.value;
    final dueDate = selectedDateTime.value;

    if (title.isEmpty) {
      EasyLoading.showError('Please enter an assessment title.');
      return;
    }
    if (classroom.isEmpty) {
      EasyLoading.showError('Please enter a classroom.');
      return;
    }
    if (type == null || type.isEmpty) {
      EasyLoading.showError('Please select an assessment type.');
      return;
    }
    if (totalMarks == null) {
      EasyLoading.showError('Please enter valid total marks.');
      return;
    }
    if (questionFormat == null || questionFormat.isEmpty) {
      EasyLoading.showError('Please select a question format.');
      return;
    }
    if (dueDate == null) {
      EasyLoading.showError('Please select a due date.');
      return;
    }

    isCreatingAssessment.value = true;
    EasyLoading.show(status: 'Creating assessment...');
    try {
      final created = await _assessmentService.createAssessment(
        courseId: courseId,
        title: title,
        classroom: classroom,
        type: type,
        notes: notes,
        totalMarks: totalMarks,
        questionFormat: questionFormat,
        dueDate: dueDate.toUtc().toIso8601String(),
      );
      final createdAssessmentId = _parseInt(created['id']);
      // Upload any attached files (PDF, PPT, DOCS, XLSX, etc) to created assessment
      if (files.isNotEmpty && createdAssessmentId > 0) {
        for (final attached in files) {
          try {
            final fileUrl = await _assessmentDetailService.uploadAssessmentFile(
              File(attached.path),
              fileName: attached.name,
            );
            final fileType = _normalizeUploadType(attached.extension);
            final mimeType = _mimeTypeFromExtension(attached.extension);
            await _assessmentDetailService.addAssessmentFile(
              assessmentId: createdAssessmentId,
              name: attached.name,
              fileUrl: fileUrl,
              type: fileType,
              size: (attached.size * 1024).toInt(),
              mimeType: mimeType,
            );
          } catch (fileErr) {
            debugPrint('Failed to upload assessment attached file: $fileErr');
          }
        }
      }

      final createdItem = _toAssessmentListItem(created);
      if (_matchesCurrentFilter(createdItem['rawType']?.toString())) {
        assessments.insert(0, createdItem);
      }
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Assessment created successfully.');
      clearCreateAssessmentForm();
      Get.back(result: created);
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isCreatingAssessment.value = false;
    }
  }

  void clearCreateAssessmentForm() {
    examTitleController.clear();
    classroomController.clear();
    totalMarksController.clear();
    notesController.clear();
    dateController.clear();
    selectedDate.value = null;
    selectedDateTime.value = null;
    selectedAssessmentType.value = null;
    selectedQuestionFormat.value = null;
    files.clear();
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'ppt',
        'pptx',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'txt',
        'csv',
      ],
    );
    if (result != null && result.files.single.path != null) {
      final file = result.files.single;

      final uploadFile = UploadFile(
        name: file.name,
        size: file.size / 1024,
        path: file.path!,
        extension: file.extension,
      );

      files.add(uploadFile);
    }
  }

  void removeFile(UploadFile file) {
    files.remove(file);
  }

  Future<void> fetchAssessments() async {
    if (currentCourseId.value == 0 || isLoadingAssessments.value) {
      return;
    }

    isLoadingAssessments.value = true;
    try {
      final items = await _assessmentService.getAssessments(
        currentCourseId.value,
        type: selectedFilter.value == '--' ? null : selectedFilter.value,
      );
      assessments.assignAll(items.map(_toAssessmentListItem).toList());
    } catch (e) {
      // EasyLoading.showError(
      //   _extractErrorMessage(e, fallback: 'Failed to load assessments.'),
      // );
    } finally {
      isLoadingAssessments.value = false;
    }
  }

  void prepareAssessmentDetails(dynamic args) {
    final seededAssessment = _resolveAssessmentMap(args);
    if (seededAssessment != null && seededAssessment.isNotEmpty) {
      final mapped = Map<String, dynamic>.from(seededAssessment);
      currentAssessment.value = mapped;
      currentAssessmentId.value = _parseInt(mapped['id']);
      assessmentFiles.assignAll(
        _parseClassFiles(mapped['filesData'] ?? mapped['files']),
      );
      assessmentSubmissions.clear();
    }

    final assessmentId = _resolveAssessmentId(args);
    if (assessmentId != 0) {
      currentAssessmentId.value = assessmentId;
      fetchAssessmentDetails(assessmentId);
    }
  }

  Future<void> fetchAssessmentDetails([int? assessmentId]) async {
    final id = assessmentId ?? currentAssessmentId.value;
    if (id == 0 || isLoadingAssessmentDetails.value) {
      return;
    }

    isLoadingAssessmentDetails.value = true;
    try {
      final item = await _assessmentDetailService.getAssessmentDetails(id);
      currentAssessmentId.value = _parseInt(item['id']);
      currentCourseId.value = _parseInt(item['courseId']);
      final course = _asMap(item['course']);
      final courseTitle = (course['title'] ?? '').toString();
      if (courseTitle.isNotEmpty) {
        currentCourseTitle.value = courseTitle;
      }

      final mapped = _toAssessmentListItem(item);
      currentAssessment.value = mapped;
      assessmentFiles.assignAll(_parseClassFiles(item['files']));
      assessmentSubmissions.clear();
      _upsertAssessment(mapped);
      await fetchAssessmentSubmissions(id);
    } catch (e) {
      // EasyLoading.showError(
      //   _extractErrorMessage(e, fallback: 'Failed to load assessment details.'),
      // );
    } finally {
      isLoadingAssessmentDetails.value = false;
    }
  }

  Future<void> fetchAssessmentSubmissions([int? assessmentId]) async {
    final id = assessmentId ?? currentAssessmentId.value;
    if (id == 0 || isLoadingAssessmentSubmissions.value) {
      return;
    }

    isLoadingAssessmentSubmissions.value = true;
    try {
      final items = await _assessmentDetailService.getAssessmentSubmissions(id);
      final parsed = _parseSubmissionList(items);
      assessmentSubmissions.assignAll(parsed);

      final current = currentAssessment.value;
      if (current != null) {
        currentAssessment.value = Map<String, dynamic>.from(current)
          ..['submissions'] = parsed;
      }
    } catch (e) {
      // EasyLoading.showError(
      //   _extractErrorMessage(
      //     e,
      //     fallback: 'Failed to load assessment submissions.',
      //   ),
      // );
    } finally {
      isLoadingAssessmentSubmissions.value = false;
    }
  }

  Future<bool> gradeSubmission({
    required int submissionId,
    required int marks,
    required String feedback,
  }) async {
    if (submissionId == 0 || isGradingSubmission.value) {
      return false;
    }

    isGradingSubmission.value = true;
    EasyLoading.show(status: 'Saving grade...');
    try {
      final updated = await _assessmentDetailService.gradeSubmission(
        submissionId: submissionId,
        marks: marks,
        feedback: feedback,
      );
      final normalized = _normalizeSubmission(updated);
      final index = assessmentSubmissions.indexWhere(
        (item) => _parseInt(item['id']) == submissionId,
      );
      if (index != -1) {
        assessmentSubmissions[index] = normalized;
        assessmentSubmissions.refresh();
      } else {
        assessmentSubmissions.add(normalized);
      }

      final current = currentAssessment.value;
      if (current != null) {
        currentAssessment.value = Map<String, dynamic>.from(current)
          ..['submissions'] = assessmentSubmissions.toList();
      }

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Submission graded successfully.');
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(
        _extractErrorMessage(e, fallback: 'Failed to grade submission.'),
      );
      return false;
    } finally {
      isGradingSubmission.value = false;
    }
  }

  void prepareEditAssessmentForm() {
    final item = currentAssessment.value;
    if (item == null) {
      return;
    }

    examTitleController.text = (item['title'] ?? '').toString();
    classroomController.text = (item['classroom'] ?? '').toString();
    totalMarksController.text = (item['totalMarks'] ?? 0).toString();
    notesController.text = (item['notes'] ?? '').toString();
    selectedAssessmentType.value = (item['rawType'] ?? '').toString();
    selectedQuestionFormat.value = (item['questionFormat'] ?? '').toString();
    selectedDateTime.value = _parseDateTime(item['dueDate']);
    dateController.text = _formatDateTimeField(selectedDateTime.value);
  }

  Future<bool> updateAssessmentDetails() async {
    if (isUpdatingAssessment.value) {
      return false;
    }

    final assessmentId = currentAssessmentId.value;
    if (assessmentId == 0) {
      EasyLoading.showError('Assessment not found.');
      return false;
    }

    final title = examTitleController.text.trim();
    final classroom = classroomController.text.trim();
    final notes = notesController.text.trim();
    final totalMarks = int.tryParse(totalMarksController.text.trim());
    final type = selectedAssessmentType.value;
    final questionFormat = selectedQuestionFormat.value;
    final dueDate = selectedDateTime.value;

    if (title.isEmpty) {
      EasyLoading.showError('Please enter an assessment title.');
      return false;
    }
    if (classroom.isEmpty) {
      EasyLoading.showError('Please enter a classroom.');
      return false;
    }
    if (type == null || type.isEmpty) {
      EasyLoading.showError('Please select an assessment type.');
      return false;
    }
    if (totalMarks == null) {
      EasyLoading.showError('Please enter valid total marks.');
      return false;
    }
    if (questionFormat == null || questionFormat.isEmpty) {
      EasyLoading.showError('Please select a question format.');
      return false;
    }
    if (dueDate == null) {
      EasyLoading.showError('Please select a due date.');
      return false;
    }

    isUpdatingAssessment.value = true;
    EasyLoading.show(status: 'Updating assessment...');
    try {
      final updated = await _assessmentDetailService.updateAssessment(
        assessmentId: assessmentId,
        title: title,
        classroom: classroom,
        type: type,
        notes: notes,
        totalMarks: totalMarks,
        questionFormat: questionFormat,
        dueDate: dueDate.toUtc().toIso8601String(),
      );
      final merged = <String, dynamic>{
        ...?currentAssessment.value,
        ...updated,
        'files': currentAssessment.value?['filesData'] ?? assessmentFiles,
      };
      final mapped = _toAssessmentListItem(merged);
      currentAssessment.value = mapped;
      _upsertAssessment(mapped);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Assessment updated successfully.');
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(
        _extractErrorMessage(e, fallback: 'Failed to update assessment.'),
      );
      return false;
    } finally {
      isUpdatingAssessment.value = false;
    }
  }

  Future<bool> deleteAssessment() async {
    if (isDeletingAssessment.value) {
      return false;
    }

    final assessmentId = currentAssessmentId.value;
    if (assessmentId == 0) {
      EasyLoading.showError('Assessment not found.');
      return false;
    }

    isDeletingAssessment.value = true;
    EasyLoading.show(status: 'Deleting assessment...');
    try {
      await _assessmentDetailService.deleteAssessment(assessmentId);
      _removeAssessment(assessmentId);
      currentAssessment.value = null;
      assessmentFiles.clear();
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Assessment deleted successfully.');
      return true;
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(
        _extractErrorMessage(e, fallback: 'Failed to delete assessment.'),
      );
      return false;
    } finally {
      isDeletingAssessment.value = false;
    }
  }

  Future<void> pickAndUploadAssessmentFile() async {
    if (isUploadingAssessmentFile.value) {
      return;
    }

    final assessmentId = currentAssessmentId.value;
    if (assessmentId == 0) {
      EasyLoading.showError('Assessment not found.');
      return;
    }

    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    final pickedFile = result?.files.single;
    final path = pickedFile?.path;
    if (pickedFile == null || path == null || path.isEmpty) {
      return;
    }

    isUploadingAssessmentFile.value = true;
    EasyLoading.show(status: 'Uploading file...');
    try {
      final uploadedUrl = await _assessmentDetailService.uploadAssessmentFile(
        File(path),
        fileName: pickedFile.name,
      );
      final fileType = _normalizeUploadType(pickedFile.extension);
      final mimeType = _mimeTypeFromExtension(pickedFile.extension);
      final createdFile = await _assessmentDetailService.addAssessmentFile(
        assessmentId: assessmentId,
        name: pickedFile.name,
        fileUrl: uploadedUrl,
        type: fileType,
        size: pickedFile.size,
        mimeType: mimeType,
      );
      assessmentFiles.add(createdFile);
      assessmentFiles.refresh();
      _appendAssessmentFile(createdFile);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('File uploaded successfully.');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(
        _extractErrorMessage(e, fallback: 'Failed to upload assessment file.'),
      );
    } finally {
      isUploadingAssessmentFile.value = false;
    }
  }

  /// Get file icon based on extension
  String getFileType(String? extension) {
    switch (extension?.toLowerCase()) {
      case "pdf":
        return "pdf";
      case "mp4":
      case "mov":
      case "avi":
        return "video";
      case "jpg":
      case "jpeg":
      case "png":
        return "image";
      case "doc":
      case "docx":
        return "doc";
      case "ppt":
      case "pptx":
        return "ppt";
      case "xls":
      case "xlsx":
      case "csv":
        return "xls";
      case "txt":
        return "txt";
      default:
        return "file";
    }
  }

  String formatLabel(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Map<String, dynamic> _toAssessmentListItem(Map<String, dynamic> created) {
    final rawType = (created['type'] ?? selectedAssessmentType.value ?? '')
        .toString()
        .toLowerCase();
    final dueDate = _parseDateTime(
      created['dueDate'] ?? selectedDateTime.value?.toIso8601String(),
    );
    final files = _asList(created['files']);
    final fileType = _resolveFileType(files);

    return {
      'id': created['id'],
      'title': (created['title'] ?? examTitleController.text.trim()).toString(),
      'type': formatLabel(rawType),
      'rawType': rawType,
      'date': dueDate != null
          ? DateFormat('EEE, MMM d, yyyy').format(dueDate.toLocal())
          : dateController.text.trim(),
      'files': files.length,
      'fileType': fileType,
      'classroom': (created['classroom'] ?? classroomController.text.trim())
          .toString(),
      'notes': (created['notes'] ?? notesController.text.trim()).toString(),
      'totalMarks':
          created['totalMarks'] ??
          int.tryParse(totalMarksController.text.trim()) ??
          0,
      'questionFormat':
          (created['questionFormat'] ?? selectedQuestionFormat.value ?? '')
              .toString(),
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': created['createdAt'],
      'updatedAt': created['updatedAt'],
      'creator': created['creator'],
      'createdBy': created['createdBy'],
      'course': _asMap(created['course']),
      'submissions': _asList(created['submissions']),
      'filesData': files,
    };
  }

  String _formatDateTimeField(DateTime? value) {
    if (value == null) {
      return '';
    }
    return '${DateFormat('yyyy-MM-dd').format(value)} ${DateFormat('hh:mm a').format(value)}';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) {
      return value;
    }
    return const <dynamic>[];
  }

  List<ClassFile> _parseClassFiles(dynamic raw) {
    if (raw is! List) {
      return const <ClassFile>[];
    }
    return raw
        .whereType<Map>()
        .map((item) => ClassFile.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  List<Map<String, dynamic>> _parseSubmissionList(dynamic raw) {
    if (raw is! List) {
      return const <Map<String, dynamic>>[];
    }
    return raw
        .whereType<Map>()
        .map((item) => _normalizeSubmission(Map<String, dynamic>.from(item)))
        .toList();
  }

  Map<String, dynamic> _normalizeSubmission(Map<String, dynamic> raw) {
    final student = _asMap(
      raw['student'] ?? raw['user'] ?? raw['submittedBy'] ?? raw['creator'],
    );
    final profile = _asMap(student['profile']);
    final files = _extractSubmissionFiles(raw);
    final submittedAt = _parseDateTime(
      raw['submittedAt'] ?? raw['createdAt'] ?? raw['updatedAt'],
    );

    return {
      'id': _parseInt(raw['id']),
      'studentName': _firstNonEmptyString([
        profile['fullName'],
        student['username'],
        raw['studentName'],
        raw['name'],
      ], fallback: 'Student'),
      'status': _firstNonEmptyString([
        raw['status'],
        raw['submissionStatus'],
      ], fallback: 'submitted'),
      'marks': raw['marks'] ?? raw['score'] ?? raw['obtainedMarks'],
      'feedback': (raw['feedback'] ?? '').toString(),
      'submittedAt': submittedAt?.toIso8601String(),
      'submittedDateLabel': submittedAt == null
          ? 'Not submitted yet'
          : DateFormat(
              'EEE, MMM d, yyyy • hh:mm a',
            ).format(submittedAt.toLocal()),
      'fileCount': files.length,
      'files': files,
      'raw': raw,
    };
  }

  List<Map<String, dynamic>> _extractSubmissionFiles(Map<String, dynamic> raw) {
    final normalizedFiles = <Map<String, dynamic>>[];

    for (final item in _asList(raw['files'] ?? raw['attachments'])) {
      if (item is Map<String, dynamic>) {
        normalizedFiles.add(Map<String, dynamic>.from(item));
        continue;
      }
      if (item is Map) {
        normalizedFiles.add(Map<String, dynamic>.from(item));
      }
    }

    for (final item in _asList(raw['fileUrls'])) {
      final url = item?.toString() ?? '';
      if (url.isEmpty) {
        continue;
      }
      normalizedFiles.add({
        'fileUrl': url,
        'url': url,
        'name': _fileNameFromUrl(url),
      });
    }

    return normalizedFiles;
  }

  String _fileNameFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final lastSegment = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : url.split('/').last;
    return lastSegment.isEmpty ? 'Attachment' : lastSegment;
  }

  String _resolveFileType(List<dynamic> files) {
    if (files.isEmpty) {
      return 'file';
    }

    final first = files.first;
    if (first is Map<String, dynamic>) {
      return getFileType(
        (first['extension'] ?? first['type'] ?? first['mimeType'])
            ?.toString()
            .split('/')
            .last,
      );
    }
    if (first is Map) {
      final normalized = Map<String, dynamic>.from(first);
      return getFileType(
        (normalized['extension'] ??
                normalized['type'] ??
                normalized['mimeType'])
            ?.toString()
            .split('/')
            .last,
      );
    }
    return 'file';
  }

  String _normalizeUploadType(String? extension) {
    final trimmed = (extension ?? '').trim().toLowerCase();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return 'file';
  }

  String _mimeTypeFromExtension(String? extension) {
    switch ((extension ?? '').toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'csv':
        return 'text/csv';
      case 'txt':
        return 'text/plain';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }

  bool _matchesCurrentFilter(String? rawType) {
    if (selectedFilter.value == '--') {
      return true;
    }
    return rawType == selectedFilter.value;
  }

  void _appendAssessmentFile(ClassFile file) {
    final current = currentAssessment.value;
    if (current == null) {
      return;
    }

    final rawFiles = _asList(
      current['filesData'],
    ).whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    rawFiles.add({
      'id': file.id,
      'name': file.name,
      'fileUrl': file.fileUrl,
      'type': file.type,
      'size': file.size,
      'mimeType': file.mimeType,
    });

    final updated = Map<String, dynamic>.from(current)
      ..['files'] = rawFiles.length
      ..['fileType'] = file.fileType
      ..['filesData'] = rawFiles;

    currentAssessment.value = updated;
    _upsertAssessment(updated);
  }

  void _upsertAssessment(Map<String, dynamic> item) {
    final id = _parseInt(item['id']);
    if (id == 0) {
      return;
    }

    final index = assessments.indexWhere(
      (assessment) => _parseInt(assessment['id']) == id,
    );
    if (index == -1) {
      if (_matchesCurrentFilter(item['rawType']?.toString())) {
        assessments.insert(0, item);
      }
      return;
    }

    if (_matchesCurrentFilter(item['rawType']?.toString())) {
      assessments[index] = item;
      assessments.refresh();
    } else {
      assessments.removeAt(index);
    }
  }

  void _removeAssessment(int assessmentId) {
    assessments.removeWhere(
      (assessment) => _parseInt(assessment['id']) == assessmentId,
    );
  }

  int _resolveAssessmentId(dynamic args) {
    if (args is Map<String, dynamic>) {
      if (args['assessmentId'] != null) {
        return _parseInt(args['assessmentId']);
      }
      final assessment = _resolveAssessmentMap(args);
      if (assessment != null) {
        return _parseInt(assessment['id']);
      }
    }

    if (args is int) {
      if (args >= 0 && args < filteredAssessments.length) {
        return _parseInt(filteredAssessments[args]['id']);
      }
      return args;
    }

    return 0;
  }

  Map<String, dynamic>? _resolveAssessmentMap(dynamic args) {
    if (args is Map<String, dynamic>) {
      if (args['assessment'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(args['assessment']);
      }
      if (args['assessment'] is Map) {
        return Map<String, dynamic>.from(args['assessment']);
      }
    }

    if (args is int && args >= 0 && args < filteredAssessments.length) {
      return Map<String, dynamic>.from(filteredAssessments[args]);
    }

    return null;
  }

  String _firstNonEmptyString(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') {
        return text;
      }
    }
    return fallback;
  }

  int _resolveCourseId(dynamic args) {
    if (args is int) return args;
    if (args is num) return args.toInt();

    final moduleController = Get.isRegistered<CourseModuleController>()
        ? Get.find<CourseModuleController>()
        : null;
    final selectedCourseId = moduleController?.selectedCourse.value?.id ?? 0;
    if (selectedCourseId != 0) {
      return selectedCourseId;
    }

    if (args is TeacherCourseModel) {
      return args.id;
    }

    if (args is Map) {
      if (args['course'] is TeacherCourseModel) {
        return (args['course'] as TeacherCourseModel).id;
      }
      final id = _parseInt(args['courseId'] ?? args['id']);
      if (id != 0) return id;
      if (args['course'] != null) {
        try {
          return _parseInt((args['course'] as dynamic).id);
        } catch (_) {}
      }
    } else if (args != null) {
      try {
        return _parseInt((args as dynamic).id);
      } catch (_) {}
    }

    return 0;
  }

  String _resolveCourseTitle(dynamic args) {
    final moduleController = Get.isRegistered<CourseModuleController>()
        ? Get.find<CourseModuleController>()
        : null;
    final selectedCourseTitle =
        moduleController?.selectedCourse.value?.title ?? '';
    if (selectedCourseTitle.isNotEmpty) {
      return selectedCourseTitle;
    }

    if (args is TeacherCourseModel) {
      return args.title;
    }

    if (args is Map) {
      if (args['course'] is TeacherCourseModel) {
        return (args['course'] as TeacherCourseModel).title;
      }
      final t = args['courseTitle'] ?? args['title'];
      if (t != null && t.toString().isNotEmpty) return t.toString();
      if (args['course'] != null) {
        try {
          final ct = (args['course'] as dynamic).title;
          if (ct != null && ct.toString().isNotEmpty) return ct.toString();
        } catch (_) {}
      }
    } else if (args != null) {
      try {
        final t = (args as dynamic).title;
        if (t != null && t.toString().isNotEmpty) return t.toString();
      } catch (_) {}
    }

    return '';
  }

  int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  String _extractErrorMessage(
    Object error, {
    String fallback = 'Failed to create assessment.',
  }) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return fallback;
    }
    return message;
  }

  @override
  void onClose() {
    examTitleController.dispose();
    classroomController.dispose();
    totalMarksController.dispose();
    notesController.dispose();
    dateController.dispose();
    super.onClose();
  }
}
