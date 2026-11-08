// module_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../academic_courses/service/academic_course_service.dart';
import '../model/module_model.dart';

class ModuleController extends GetxController {
  ModuleController({required this.courseId});

  final int? courseId;
  var modules = <ModuleModel>[].obs;
  var expandedModules = RxMap<String, bool>({});
  var isLoading = false.obs;
  var errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchModules();
  }

  Future<void> fetchModules() async {
    final id = courseId;
    if (id == null) {
      errorMessage.value = 'Course id not available for modules.';
      modules.clear();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;

      final courseDetail = await AcademicCourseService.getCourseById(id);
      final moduleIds = courseDetail.modules
          .map((module) => module.id)
          .toList();
      debugPrint(
        '📚 [ModuleController] Found ${moduleIds.length} module ids for courseId=$id',
      );

      if (moduleIds.isNotEmpty) {
        final moduleDetails = await Future.wait(
          moduleIds.map(AcademicCourseService.getModuleById),
        );
        modules.value = moduleDetails
            .map((module) => module.toUiModel())
            .toList();
      } else {
        // Fallback: fetch directly from course modules endpoint
        final directModules = await AcademicCourseService.getCourseModules(id);
        modules.value = directModules
            .map((module) => module.toUiModel())
            .toList();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [ModuleController] fetchModules error: $e');
      debugPrint('🧱 [ModuleController] StackTrace: $stackTrace');
      errorMessage.value = e.toString();
      modules.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void toggleModuleExpanded(String moduleTitle, {bool defaultVal = false}) {
    final isExpanded = expandedModules[moduleTitle] ?? defaultVal;
    expandedModules[moduleTitle] = !isExpanded;
  }

  bool isModuleExpanded(String moduleTitle, {bool defaultVal = false}) {
    return expandedModules[moduleTitle] ?? defaultVal;
  }
}
