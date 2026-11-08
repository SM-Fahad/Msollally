import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/feature/student/ai_chat/service/student_ai_chat_service.dart';
import 'package:msollaally/feature/student/academics/courses/academic_courses/service/academic_course_service.dart';
import 'package:msollaally/feature/student/profile/controller/student_profile_controller.dart';
import 'package:msollaally/feature/student/create_task/controller/student_create_task_controller.dart';

class StudentAiTipsController extends GetxController {
  TextEditingController aiTipsTexDitiongController = TextEditingController();
  var studyTipsItem = <String>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAiTips();
  }

  Future<void> fetchAiTips() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      studyTipsItem.clear();

      // Get user details and courses to build the query/fallback
      String studentName = 'User';
      try {
        if (Get.isRegistered<StudentProfileController>()) {
          final profileCtrl = Get.find<StudentProfileController>();
          if (profileCtrl.displayName.value.isNotEmpty) {
            studentName = profileCtrl.displayName.value.split(" ").first;
          }
        } else {
          final savedName = await SharedPreferenceHelper().getSavedUserName();
          if (savedName != null && savedName.isNotEmpty) {
            studentName = savedName.split(" ").first;
          }
        }
      } catch (_) {}

      // Get real enrolled courses
      List<String> courseNames = [];
      try {
        final enrolledResponse = await AcademicCourseService.getMyEnrolledCourses();
        if (enrolledResponse.courses != null) {
          courseNames = enrolledResponse.courses!
              .map((c) => c.title)
              .whereType<String>()
              .where((name) => name.isNotEmpty)
              .toList();
        }
      } catch (_) {}

      // Build prompt for AI
      String coursesStr = courseNames.isNotEmpty ? courseNames.join(", ") : "general subjects";
      String prompt = "Give me exactly 3 short, personalized study tips for $studentName taking courses: $coursesStr. Each tip must be a single line under 15 words. Return ONLY the bullet points, no other text.";

      // Try calling AI chat service
      final userId = await SharedPreferenceHelper().getUserId();
      final response = await StudentAIChatService.sendChatMessage(
        message: prompt,
        userId: userId,
      );

      if (response.isSuccess) {
        final aiMessage = (response.responseData is Map)
            ? (response.responseData['response'] ??
                  response.responseData['message'] ??
                  response.responseData['data'] ??
                  "")
            : response.responseData.toString();

        final rawTips = aiMessage.toString().split("\n");
        final parsedTips = rawTips
            .map((tip) {
              // Strip leading markdown bullets like "- ", "* ", "1. ", etc.
              return tip
                  .replaceFirst(RegExp(r'^[\s\-\*\d\.\•]+'), '')
                  .trim();
            })
            .where((tip) => tip.isNotEmpty)
            .toList();

        if (parsedTips.isNotEmpty) {
          studyTipsItem.assignAll(parsedTips.take(3));
          return;
        }
      }
    } catch (e) {
      debugPrint("Error calling AI tips service: $e");
    } finally {
      isLoading.value = false;
      // If we failed to get tips from AI, use local dynamic fallback
      if (studyTipsItem.isEmpty) {
        _useLocalDynamicFallback();
      }
    }
  }

  void _useLocalDynamicFallback() async {
    final List<String> fallbackTips = [];

    // Get user details
    String studentName = 'student';
    try {
      if (Get.isRegistered<StudentProfileController>()) {
        final profileCtrl = Get.find<StudentProfileController>();
        if (profileCtrl.displayName.value.isNotEmpty) {
          studentName = profileCtrl.displayName.value.split(" ").first;
        }
      }
    } catch (_) {}

    // Enrolled courses
    List<String> courseNames = [];
    try {
      final enrolledResponse = await AcademicCourseService.getMyEnrolledCourses();
      if (enrolledResponse.courses != null) {
        courseNames = enrolledResponse.courses!
            .map((c) => c.title)
            .whereType<String>()
            .where((name) => name.isNotEmpty)
            .toList();
      }
    } catch (_) {}

    if (courseNames.isNotEmpty) {
      fallbackTips.add("$studentName, review the syllabus for ${courseNames.first} and organize core terms.");
      if (courseNames.length > 1) {
        fallbackTips.add("Create summary cheat-sheets for ${courseNames[1]} to recall key concepts.");
      } else {
        fallbackTips.add("Break down larger topics into 25-minute Pomodoro study intervals.");
      }
    } else {
      fallbackTips.add("Based on your recent progress, dedicate 30 minutes to review weak areas.");
      fallbackTips.add("Break down larger exam topics into smaller, actionable task checklists.");
    }

    // Include tasks if available
    try {
      final taskController = Get.isRegistered<StudentCreateTaskController>()
          ? Get.find<StudentCreateTaskController>()
          : Get.put(StudentCreateTaskController());
      
      final activeTasks = taskController.taskListItems
          .where((t) => !t.isTapCheckBox.value)
          .toList();

      if (activeTasks.isNotEmpty) {
        fallbackTips.add("Prioritize task: '${activeTasks.first.title}' today for better exam readiness.");
      } else {
        fallbackTips.add("Schedule a self-quiz session to test retention before exam day.");
      }
    } catch (_) {
      fallbackTips.add("Schedule a self-quiz session to test retention before exam day.");
    }

    studyTipsItem.assignAll(fallbackTips.take(3));
  }

  Future<void> submitQuery() async {
    final text = aiTipsTexDitiongController.text.trim();
    if (text.isEmpty) return;

    aiTipsTexDitiongController.clear();
    isLoading.value = true;

    try {
      // Add user query to list
      studyTipsItem.add("Query: $text");

      final userId = await SharedPreferenceHelper().getUserId();
      final response = await StudentAIChatService.sendChatMessage(
        message: text,
        userId: userId,
      );

      if (response.isSuccess) {
        final aiMessage = (response.responseData is Map)
            ? (response.responseData['response'] ??
                  response.responseData['message'] ??
                  response.responseData['data'] ??
                  "")
            : response.responseData.toString();
        
        studyTipsItem.add(aiMessage.toString().trim());
      } else {
        studyTipsItem.add("Failed to get tip: ${response.errorMessage}");
      }
    } catch (e) {
      studyTipsItem.add("Error: Could not connect to AI service.");
    } finally {
      isLoading.value = false;
    }
  }
}
