import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/feature/teacher/courses/course_module/model/course_module_model.dart';
import 'package:msollaally/feature/teacher/courses/course_module/model/upload_file.dart';
import 'package:msollaally/feature/teacher/courses/course_module/service/class_service.dart';
import 'package:msollaally/feature/teacher/courses/course_module/service/module_service.dart';
import 'package:msollaally/feature/teacher/courses/model/teacher_course_model.dart';
import 'package:msollaally/feature/teacher/courses/service/teacher_course_service.dart';

class CourseModuleController extends GetxController {
  final TextEditingController addModuleTitleController =
      TextEditingController();
  final TextEditingController addModuleDescriptionController =
      TextEditingController();
  final TextEditingController addModuleDateController = TextEditingController();
  final TextEditingController addModuleUrlController = TextEditingController();

  final TextEditingController classTitleController = TextEditingController();
  final TextEditingController classClassroomController =
      TextEditingController();
  final TextEditingController classTopicController = TextEditingController();
  final TextEditingController classTopicsController = TextEditingController();
  final TextEditingController classNoteController = TextEditingController();
  final TextEditingController classDateController = TextEditingController();
  final TextEditingController startClassController = TextEditingController();
  final TextEditingController endClassController = TextEditingController();

  final modules = <CourseModule>[].obs;
  final expandedModuleId = (-1).obs;
  final selectedDate = Rxn<DateTime>();
  final selectedDateTime = Rxn<DateTime>();
  final selectedCourse = Rxn<TeacherCourseModel>();
  final currentModule = Rxn<CourseModule>();
  final currentEditingModule = Rxn<CourseModule>();
  final currentEditingClass = Rxn<CourseClass>();
  final currentViewingClass = Rxn<CourseClass>();
  final isLoadingModules = false.obs;
  final isCreatingModule = false.obs;
  final isSavingClass = false.obs;
  final isLoadingClassDetails = false.obs;
  final isUploadingClassFile = false.obs;
  final loadingModuleDetailsIds = <int>{}.obs;
  final uploadingModuleFileIds = <int>{}.obs;
  final deletingModuleFileIds = <int>{}.obs;
  final updatingModuleProgressIds = <int>{}.obs;
  final selectedDateForClass = Rxn<DateTime>();
  final selectedStartClassTime = Rxn<TimeOfDay>();
  final selectedEndClassTime = Rxn<TimeOfDay>();

  final TeacherCourseService _courseService = TeacherCourseService();
  final ModuleService _moduleService = ModuleService();
  final ClassService _classService = ClassService();

  final files = <UploadFile>[].obs;
  final selectedDays = <String>[].obs;
  final classFiles = <ClassFile>[].obs;

  void syncCourseFromArguments(dynamic args) {
    if (args == null) return;

    if (args is TeacherCourseModel) {
      selectedCourse.value = args;
      modules.assignAll(args.modules);
      expandedModuleId.value = -1;
      _loadAllModulesDetails();
      return;
    }

    int resolvedId = 0;
    String resolvedTitle = 'Course';
    String resolvedCode = '';
    String resolvedCover = '';

    if (args is int) {
      resolvedId = args;
    } else if (args is num) {
      resolvedId = args.toInt();
    } else if (args is Map) {
      if (args['course'] is TeacherCourseModel) {
        final course = args['course'] as TeacherCourseModel;
        selectedCourse.value = course;
        modules.assignAll(course.modules);
        expandedModuleId.value = -1;
        _loadAllModulesDetails();
        return;
      }
      resolvedId = _parseInt(args['courseId'] ?? args['id']);
      if (args['course'] != null && resolvedId == 0) {
        try {
          resolvedId = _parseInt((args['course'] as dynamic).id);
        } catch (_) {}
      }
      resolvedTitle = (args['courseTitle'] ?? args['title'] ?? 'Course').toString();
      if (resolvedTitle == 'Course' && args['course'] != null) {
        try {
          final t = (args['course'] as dynamic).title;
          if (t != null && t.toString().isNotEmpty) resolvedTitle = t.toString();
        } catch (_) {}
      }
      resolvedCode = (args['courseCode'] ?? args['code'] ?? '').toString();
      resolvedCover = (args['coverImage'] ?? '').toString();

      if (args['module'] is CourseModule) {
        _setCurrentModule(args['module'] as CourseModule);
      }
    } else {
      try {
        final dynamic idVal = (args as dynamic).id;
        resolvedId = _parseInt(idVal);
      } catch (_) {}
      try {
        final dynamic titleVal = (args as dynamic).title;
        if (titleVal != null && titleVal.toString().isNotEmpty) {
          resolvedTitle = titleVal.toString();
        }
      } catch (_) {}
      try {
        final dynamic codeVal = (args as dynamic).courseCode;
        if (codeVal != null) resolvedCode = codeVal.toString();
      } catch (_) {}
      try {
        final dynamic imgVal = (args as dynamic).coverImage;
        if (imgVal != null) resolvedCover = imgVal.toString();
      } catch (_) {}
    }

    if (resolvedId != 0) {
      selectedCourse.value = TeacherCourseModel(
        id: resolvedId,
        title: resolvedTitle,
        description: '',
        courseCode: resolvedCode,
        students: 0,
        status: 'active',
        coverImage: resolvedCover,
        startDate: null,
        endDate: null,
        createdAt: null,
        modules: const <CourseModule>[],
        progress: 0,
        isPublic: true,
      );
      modules.clear();
      expandedModuleId.value = -1;
    }
  }

  bool get isEditingModule => currentEditingModule.value != null;
  bool get isEditingClass => currentEditingClass.value != null;

  void prepareModuleForm(dynamic args) {
    syncCourseFromArguments(args);

    CourseModule? module;
    if (args is CourseModule) {
      module = args;
    } else if (args is Map<String, dynamic> && args['module'] is CourseModule) {
      module = args['module'] as CourseModule;
    }

    if (module == null) {
      clearModuleForm();
      return;
    }

    currentEditingModule.value = module;
    addModuleTitleController.text = module.title;
    addModuleDescriptionController.text = module.description;
    addModuleUrlController.clear();
    files.clear();
    selectedDate.value = module.startDate;
    selectedDateTime.value = module.startDate;
    addModuleDateController.text = _formatModuleDateTime(module.startDate);
  }

  void prepareClassForm(dynamic args) {
    syncCourseFromArguments(args);

    CourseModule? module = currentModule.value;
    CourseClass? courseClass;

    if (args is Map<String, dynamic>) {
      if (args['module'] is CourseModule) {
        module = args['module'] as CourseModule;
      }
      if (args['class'] is CourseClass) {
        courseClass = args['class'] as CourseClass;
      }
    } else if (args is CourseClass) {
      courseClass = args;
    }

    if (module != null) {
      _setCurrentModule(module);
    }

    if (courseClass == null) {
      clearClassForm();
      return;
    }

    currentEditingClass.value = courseClass;
    classTitleController.text = courseClass.title;
    classClassroomController.text = courseClass.classroom;
    classTopicController.text = courseClass.topic;
    classTopicsController.text = courseClass.topics.join(', ');
    classNoteController.text = courseClass.notes;
    selectedDateForClass.value = courseClass.startTime;
    selectedStartClassTime.value = _timeOfDayFromDateTime(
      courseClass.startTime,
    );
    selectedEndClassTime.value = _timeOfDayFromDateTime(courseClass.endTime);
    classDateController.text = _formatClassDate(courseClass.startTime);
    startClassController.text = _formatClassTime(courseClass.startTime);
    endClassController.text = _formatClassTime(courseClass.endTime);
  }

  Future<void> prepareClassDetails(dynamic args) async {
    syncCourseFromArguments(args);

    CourseModule? module = currentModule.value;
    CourseClass? courseClass;
    int classId = 0;

    if (args is Map<String, dynamic>) {
      if (args['module'] is CourseModule) {
        module = args['module'] as CourseModule;
      }
      if (args['class'] is CourseClass) {
        courseClass = args['class'] as CourseClass;
      }
      classId = _parseInt(args['classId']);
    } else if (args is CourseClass) {
      courseClass = args;
    }

    if (module != null) {
      _setCurrentModule(module);
    }

    currentViewingClass.value = courseClass;
    classFiles.assignAll(courseClass?.files ?? const <ClassFile>[]);

    classId = courseClass?.id ?? classId;
    if (classId != 0) {
      await fetchClassDetails(classId);
    }
  }

  Future<void> refreshModules() async {
    final courseId = selectedCourse.value?.id;
    if (courseId == null || courseId == 0 || isLoadingModules.value) {
      return;
    }

    isLoadingModules.value = true;
    try {
      final courses = await _courseService.getMyCourses();
      final matchedCourse = courses.firstWhereOrNull(
        (course) => course.id == courseId,
      );
      if (matchedCourse != null) {
        selectedCourse.value = matchedCourse;
        modules.assignAll(matchedCourse.modules);
        _loadAllModulesDetails();
        if (currentModule.value != null) {
          final updatedCurrent = matchedCourse.modules.firstWhereOrNull(
            (module) => module.id == currentModule.value!.id,
          );
          currentModule.value = updatedCurrent;
        }
      } else {
        modules.clear();
        currentModule.value = null;
      }
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isLoadingModules.value = false;
    }
  }

  Future<void> toggleExpand(int id) async {
    if (expandedModuleId.value == id) {
      expandedModuleId.value = -1;
      return;
    }

    expandedModuleId.value = id;
    await fetchModuleDetails(id);
  }

  Future<void> fetchModuleDetails(int moduleId) async {
    if (loadingModuleDetailsIds.contains(moduleId)) {
      return;
    }

    loadingModuleDetailsIds.add(moduleId);
    try {
      final detailedModule = await _moduleService.getModuleDetails(moduleId);
      _upsertModule(detailedModule);
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      loadingModuleDetailsIds.remove(moduleId);
      loadingModuleDetailsIds.refresh();
    }
  }

  void _loadAllModulesDetails() {
    for (final module in modules) {
      fetchModuleDetails(module.id);
    }
  }

  bool isLoadingModuleDetails(int moduleId) =>
      loadingModuleDetailsIds.contains(moduleId);

  bool isUploadingModuleFile(int moduleId) =>
      uploadingModuleFileIds.contains(moduleId);

  bool isDeletingModuleFile(int fileId) =>
      deletingModuleFileIds.contains(fileId);

  bool isUpdatingModuleProgress(int moduleId) =>
      updatingModuleProgressIds.contains(moduleId);

  Future<void> saveModule() async {
    if (isEditingModule) {
      await updateModule();
      return;
    }
    await createModule();
  }

  Future<void> createModule() async {
    final courseId = selectedCourse.value?.id;
    if (courseId == null || courseId == 0) {
      EasyLoading.showError('Course not found.');
      return;
    }
    if (isCreatingModule.value) {
      return;
    }

    final title = addModuleTitleController.text.trim();
    final description = addModuleDescriptionController.text.trim();

    if (title.isEmpty) {
      EasyLoading.showError('Please enter a module title.');
      return;
    }
    if (description.isEmpty) {
      EasyLoading.showError('Please enter a module description.');
      return;
    }

    isCreatingModule.value = true;
    EasyLoading.show(status: 'Creating module...');

    try {
      final createdModule = await _moduleService.createModule(
        courseId: courseId,
        title: title,
        description: description,
        startDate: selectedDateTime.value,
      );

      // Upload any attached files (PDF, PPT, DOCX) to the created module
      if (files.isNotEmpty) {
        for (final attached in files) {
          try {
            final fileUrl = await _moduleService.uploadModuleFile(
              File(attached.path),
              fileName: attached.name,
            );
            await _moduleService.addModuleFile(
              moduleId: createdModule.id,
              name: attached.name,
              fileUrl: fileUrl,
              type: getFileType(attached.extension),
              size: attached.size.toInt(),
              mimeType: _getMimeType(attached.extension),
            );
          } catch (fileErr) {
            debugPrint('Failed to upload attached module file: $fileErr');
          }
        }
      }

      modules.insert(0, createdModule);
      _syncSelectedCourseModules();
      clearModuleForm();
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Module created with attachments.');
      Get.back(result: createdModule);
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isCreatingModule.value = false;
    }
  }

  Future<void> updateModule() async {
    final module = currentEditingModule.value;
    if (module == null || isCreatingModule.value) {
      return;
    }

    final title = addModuleTitleController.text.trim();
    final description = addModuleDescriptionController.text.trim();

    if (title.isEmpty) {
      EasyLoading.showError('Please enter a module title.');
      return;
    }
    if (description.isEmpty) {
      EasyLoading.showError('Please enter a module description.');
      return;
    }

    isCreatingModule.value = true;
    EasyLoading.show(status: 'Updating module...');

    try {
      final updatedModule = await _moduleService.updateModule(
        moduleId: module.id,
        title: title,
        description: description,
        orderIndex: module.orderIndex,
        startDate: selectedDateTime.value,
      );

      _upsertModule(updatedModule);
      clearModuleForm();
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Module updated successfully.');
      Get.back(result: updatedModule);
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isCreatingModule.value = false;
    }
  }

  Future<void> confirmDeleteModule(CourseModule module) async {
    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete module'),
        content: Text(
          'Delete "${module.title}"? This action cannot be undone.',
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

    EasyLoading.show(status: 'Deleting module...');
    try {
      await _moduleService.deleteModule(module.id);
      modules.removeWhere((item) => item.id == module.id);
      if (expandedModuleId.value == module.id) {
        expandedModuleId.value = -1;
      }
      if (currentModule.value?.id == module.id) {
        currentModule.value = null;
      }
      _syncSelectedCourseModules();
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Module deleted successfully.');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    }
  }

  Future<void> updateModuleProgress({
    required CourseModule module,
    required double progress,
  }) async {
    if (updatingModuleProgressIds.contains(module.id)) {
      return;
    }

    final normalizedProgress = progress.clamp(0, 100).toDouble();
    if ((module.progress - normalizedProgress).abs() < 0.001) {
      return;
    }

    updatingModuleProgressIds.add(module.id);
    updatingModuleProgressIds.refresh();

    try {
      final updatedModule = await _moduleService.updateModuleProgress(
        moduleId: module.id,
        progress: normalizedProgress,
      );
      _upsertModule(updatedModule);
      EasyLoading.showSuccess('Module progress updated.');
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      updatingModuleProgressIds.remove(module.id);
      updatingModuleProgressIds.refresh();
    }
  }

  Future<void> saveClass() async {
    if (isEditingClass) {
      await updateClass();
      return;
    }
    await createClass();
  }

  Future<void> createClass() async {
    final module = currentModule.value;
    if (module == null) {
      EasyLoading.showError('Module not found.');
      return;
    }
    if (isSavingClass.value) {
      return;
    }

    final payload = _buildClassPayload(orderIndex: module.classes.length);
    if (payload == null) {
      return;
    }

    isSavingClass.value = true;
    EasyLoading.show(status: 'Creating class...');

    try {
      final createdClass = await _classService.createClass(
        moduleId: module.id,
        title: payload.title,
        classroom: payload.classroom,
        topic: payload.topic,
        notes: payload.notes,
        startTime: payload.startTime,
        endTime: payload.endTime,
        orderIndex: payload.orderIndex,
        topics: payload.topics,
      );

      // Upload any attached files (PDF, PPT, DOCS, XLSX, etc) to created class
      if (files.isNotEmpty) {
        for (final attached in files) {
          try {
            final fileUrl = await _classService.uploadClassFile(
              File(attached.path),
              fileName: attached.name,
            );
            await _classService.addClassFile(
              classId: createdClass.id,
              name: attached.name,
              fileUrl: fileUrl,
              type: getFileType(attached.extension),
              size: (attached.size * 1024).toInt(),
              mimeType: _getMimeType(attached.extension),
            );
          } catch (fileErr) {
            debugPrint('Failed to upload attached class file: $fileErr');
          }
        }
      }

      await fetchModuleDetails(module.id);
      clearClassForm();
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Class created successfully.');
      Get.back(result: true);
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isSavingClass.value = false;
    }
  }

  Future<void> updateClass() async {
    final module = currentModule.value;
    final courseClass = currentEditingClass.value;
    if (module == null || courseClass == null || isSavingClass.value) {
      return;
    }

    final payload = _buildClassPayload(orderIndex: courseClass.orderIndex);
    if (payload == null) {
      return;
    }

    isSavingClass.value = true;
    EasyLoading.show(status: 'Updating class...');

    try {
      await _classService.updateClass(
        classId: courseClass.id,
        title: payload.title,
        classroom: payload.classroom,
        topic: payload.topic,
        notes: payload.notes,
        startTime: payload.startTime,
        endTime: payload.endTime,
        orderIndex: payload.orderIndex,
        topics: payload.topics,
      );

      // Upload any newly attached files to updated class
      if (files.isNotEmpty) {
        for (final attached in files) {
          try {
            final fileUrl = await _classService.uploadClassFile(
              File(attached.path),
              fileName: attached.name,
            );
            await _classService.addClassFile(
              classId: courseClass.id,
              name: attached.name,
              fileUrl: fileUrl,
              type: getFileType(attached.extension),
              size: (attached.size * 1024).toInt(),
              mimeType: _getMimeType(attached.extension),
            );
          } catch (fileErr) {
            debugPrint('Failed to upload attached class file: $fileErr');
          }
        }
      }

      await fetchModuleDetails(module.id);
      clearClassForm();
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Class updated successfully.');
      Get.back(result: true);
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isSavingClass.value = false;
    }
  }

  Future<void> confirmDeleteClass(CourseClass courseClass) async {
    final module = currentModule.value;
    if (module == null) {
      EasyLoading.showError('Module not found.');
      return;
    }

    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete class'),
        content: Text(
          'Delete "${courseClass.title}"? This action cannot be undone.',
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

    EasyLoading.show(status: 'Deleting class...');
    try {
      await _classService.deleteClass(courseClass.id);
      await fetchModuleDetails(module.id);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('Class deleted successfully.');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    }
  }

  Future<void> fetchClassDetails(int classId) async {
    if (isLoadingClassDetails.value) {
      return;
    }

    isLoadingClassDetails.value = true;
    try {
      final detailedClass = await _classService.getClassDetails(classId);
      currentViewingClass.value = detailedClass;
      classFiles.assignAll(detailedClass.files);

      final module = currentModule.value;
      if (module != null) {
        final updatedClasses = module.classes
            .map((item) => item.id == detailedClass.id ? detailedClass : item)
            .toList();
        _upsertModule(module.copyWith(classes: updatedClasses));
      }
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isLoadingClassDetails.value = false;
    }
  }

  Future<void> pickFileForClassDetail() async {
    final courseClass = currentViewingClass.value;
    if (courseClass == null) {
      EasyLoading.showError('Class not found.');
      return;
    }

    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    final picked = result?.files.single;
    if (picked == null || picked.path == null) {
      return;
    }

    isUploadingClassFile.value = true;
    EasyLoading.show(status: 'Uploading file...');

    try {
      final uploadedUrl = await _classService.uploadClassFile(
        File(picked.path!),
        fileName: picked.name,
      );
      await _classService.addClassFile(
        classId: courseClass.id,
        name: picked.name,
        fileUrl: uploadedUrl,
        type: getFileType(picked.extension),
        size: picked.size,
        mimeType: _getMimeType(picked.extension),
      );
      await fetchClassDetails(courseClass.id);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('File added successfully.');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isUploadingClassFile.value = false;
    }
  }

  Future<void> pickFileForModule(CourseModule module) async {
    if (uploadingModuleFileIds.contains(module.id)) {
      return;
    }

    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    final picked = result?.files.single;
    if (picked == null || picked.path == null) {
      return;
    }

    uploadingModuleFileIds.add(module.id);
    EasyLoading.show(status: 'Uploading file...');

    try {
      final uploadedUrl = await _moduleService.uploadModuleFile(
        File(picked.path!),
        fileName: picked.name,
      );
      await _moduleService.addModuleFile(
        moduleId: module.id,
        name: picked.name,
        fileUrl: uploadedUrl,
        type: getFileType(picked.extension),
        size: picked.size,
        mimeType: _getMimeType(picked.extension),
      );
      await fetchModuleDetails(module.id);
      EasyLoading.dismiss();
      EasyLoading.showSuccess('File added successfully.');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      uploadingModuleFileIds.remove(module.id);
      uploadingModuleFileIds.refresh();
    }
  }

  Future<void> confirmDeleteModuleFile({
    required CourseModule module,
    required ModuleFile file,
  }) async {
    if (file.id == 0 || deletingModuleFileIds.contains(file.id)) {
      return;
    }

    final shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete file'),
        content: Text(
          'Delete "${file.name.isEmpty ? 'this file' : file.name}"? This action cannot be undone.',
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

    deletingModuleFileIds.add(file.id);
    deletingModuleFileIds.refresh();

    try {
      await _moduleService.deleteModuleFile(file.id);
      final updatedFiles = module.files
          .where((item) => item.id != file.id)
          .toList();
      _upsertModule(module.copyWith(files: updatedFiles));
      EasyLoading.showSuccess('File deleted successfully.');
    } catch (e) {
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      deletingModuleFileIds.remove(file.id);
      deletingModuleFileIds.refresh();
    }
  }

  double _calculateProgress(List<CourseModule> currentModules) {
    if (currentModules.isEmpty) return 0;
    final totalProgress = currentModules.fold<double>(
      0,
      (sum, module) => sum + module.progress.clamp(0, 100),
    );
    return (totalProgress / currentModules.length) / 100;
  }

  Future<void> pickDateTime() async {
    final initialDate = selectedDateTime.value ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final combinedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    selectedDateTime.value = combinedDateTime;
    addModuleDateController.text = _formatModuleDateTime(combinedDateTime);
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

  void simulateUpload(UploadFile file) async {
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      file.progress.value = i.toDouble();
    }
    file.isUploading.value = false;
    file.isCompleted.value = true;
  }

  void removeFile(UploadFile file) {
    files.remove(file);
  }

  void toggleDaySelection(String day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
  }

  String getFileType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'pdf';
      case 'mp4':
      case 'mov':
      case 'avi':
        return 'video';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      case 'doc':
      case 'docx':
        return 'doc';
      case 'ppt':
      case 'pptx':
        return 'ppt';
      case 'xls':
      case 'xlsx':
      case 'csv':
        return 'xls';
      case 'txt':
        return 'txt';
      default:
        return 'file';
    }
  }

  Future<void> pickClassDate() async {
    final pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDateForClass.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) {
      return;
    }

    selectedDateForClass.value = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
    );
    classDateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(selectedDateForClass.value!);
  }

  Future<void> pickClassTime({required bool isStart}) async {
    final initialTime = isStart
        ? (selectedStartClassTime.value ?? TimeOfDay.now())
        : (selectedEndClassTime.value ?? TimeOfDay.now());
    final pickedTime = await showTimePicker(
      context: Get.context!,
      initialTime: initialTime,
    );

    if (pickedTime == null) {
      return;
    }

    final date = selectedDateForClass.value ?? DateTime.now();
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final formattedTime = DateFormat('hh:mm a').format(dateTime);
    if (isStart) {
      selectedStartClassTime.value = pickedTime;
      startClassController.text = formattedTime;
    } else {
      selectedEndClassTime.value = pickedTime;
      endClassController.text = formattedTime;
    }
  }

  void clearModuleForm() {
    addModuleTitleController.clear();
    addModuleDescriptionController.clear();
    addModuleDateController.clear();
    addModuleUrlController.clear();
    selectedDate.value = null;
    selectedDateTime.value = null;
    currentEditingModule.value = null;
    files.clear();
  }

  void clearClassForm() {
    classTitleController.clear();
    classClassroomController.clear();
    classTopicController.clear();
    classTopicsController.clear();
    classNoteController.clear();
    classDateController.clear();
    startClassController.clear();
    endClassController.clear();
    selectedDateForClass.value = null;
    selectedStartClassTime.value = null;
    selectedEndClassTime.value = null;
    currentEditingClass.value = null;
    selectedDays.clear();
    files.clear();
  }

  void clearClassDetails() {
    currentViewingClass.value = null;
    classFiles.clear();
    isLoadingClassDetails.value = false;
    isUploadingClassFile.value = false;
  }

  String _extractErrorMessage(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '');
  }

  void _setCurrentModule(CourseModule module) {
    currentModule.value = module;
  }

  void _upsertModule(CourseModule module) {
    final index = modules.indexWhere((item) => item.id == module.id);
    if (index == -1) {
      modules.add(module);
    } else {
      modules[index] = module;
    }
    if (currentModule.value?.id == module.id || currentModule.value == null) {
      currentModule.value = module;
    }
    _syncSelectedCourseModules();
  }

  void _syncSelectedCourseModules() {
    final current = selectedCourse.value;
    if (current == null) {
      return;
    }

    final updatedModules = modules.toList();
    selectedCourse.value = current.copyWith(
      modules: updatedModules,
      progress: _calculateProgress(updatedModules),
    );
  }

  _ClassPayload? _buildClassPayload({required int orderIndex}) {
    final title = classTitleController.text.trim();
    final classroom = classClassroomController.text.trim();
    final topic = classTopicController.text.trim();
    final notesText = classNoteController.text.trim();
    final classDate = selectedDateForClass.value;
    final startTime = selectedStartClassTime.value;
    final endTime = selectedEndClassTime.value;
    final topics = _parseTopics();

    if (title.isEmpty) {
      EasyLoading.showError('Please enter a class title.');
      return null;
    }
    if (classroom.isEmpty) {
      EasyLoading.showError('Please enter a classroom.');
      return null;
    }
    if (topic.isEmpty) {
      EasyLoading.showError('Please enter a topic.');
      return null;
    }
    if (classDate == null) {
      EasyLoading.showError('Please select a date.');
      return null;
    }
    if (startTime == null) {
      EasyLoading.showError('Please select a start time.');
      return null;
    }
    if (endTime == null) {
      EasyLoading.showError('Please select an end time.');
      return null;
    }

    final startDateTime = DateTime(
      classDate.year,
      classDate.month,
      classDate.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      classDate.year,
      classDate.month,
      classDate.day,
      endTime.hour,
      endTime.minute,
    );

    if (!endDateTime.isAfter(startDateTime)) {
      EasyLoading.showError('End time must be after the start time.');
      return null;
    }

    return _ClassPayload(
      title: title,
      classroom: classroom,
      topic: topic,
      notes: notesText,
      startTime: startDateTime,
      endTime: endDateTime,
      orderIndex: orderIndex,
      topics: topics.isEmpty ? <String>[topic] : topics,
    );
  }

  List<String> _parseTopics() {
    return classTopicsController.text
        .split(',')
        .map((topic) => topic.trim())
        .where((topic) => topic.isNotEmpty)
        .toList();
  }

  String _formatModuleDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }

    final localDateTime = dateTime.toLocal();
    final formattedDate = DateFormat('yyyy-MM-dd').format(localDateTime);
    final formattedTime12h = DateFormat('hh:mm a').format(localDateTime);
    return '$formattedDate $formattedTime12h';
  }

  String _formatClassDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    return DateFormat('yyyy-MM-dd').format(dateTime.toLocal());
  }

  String _formatClassTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    return DateFormat('hh:mm a').format(dateTime.toLocal());
  }

  TimeOfDay? _timeOfDayFromDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    final localDateTime = dateTime.toLocal();
    return TimeOfDay(hour: localDateTime.hour, minute: localDateTime.minute);
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _getMimeType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
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
      default:
        return 'application/octet-stream';
    }
  }

  @override
  void onClose() {
    addModuleTitleController.dispose();
    addModuleDescriptionController.dispose();
    addModuleDateController.dispose();
    addModuleUrlController.dispose();
    classTitleController.dispose();
    classClassroomController.dispose();
    classTopicController.dispose();
    classTopicsController.dispose();
    classNoteController.dispose();
    classDateController.dispose();
    startClassController.dispose();
    endClassController.dispose();
    super.onClose();
  }
}

class _ClassPayload {
  final String title;
  final String classroom;
  final String topic;
  final String notes;
  final DateTime startTime;
  final DateTime endTime;
  final int orderIndex;
  final List<String> topics;

  const _ClassPayload({
    required this.title,
    required this.classroom,
    required this.topic,
    required this.notes,
    required this.startTime,
    required this.endTime,
    required this.orderIndex,
    required this.topics,
  });
}
