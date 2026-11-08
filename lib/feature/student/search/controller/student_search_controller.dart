import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:msollaally/feature/student/academics/courses/academic_courses/model/academic_course_model.dart';
import 'package:msollaally/feature/student/academics/courses/academic_courses/service/academic_course_service.dart';
import 'package:msollaally/feature/student/home/controller/student_home_controller.dart';
import 'package:msollaally/feature/student/create_task/controller/student_create_task_controller.dart';
import 'package:msollaally/feature/student/academics/courses/courseDetail/model/course_model.dart';
import 'package:msollaally/feature/student/academics/courses/courseDetail/screen/course_detail_screen.dart';
import 'package:msollaally/routes/app_route.dart';

enum SearchResultType { course, task, chat, tool }

class SearchResult {
  final String title;
  final String subtitle;
  final SearchResultType type;
  final dynamic originalObject;
  final VoidCallback onTap;

  SearchResult({
    required this.title,
    required this.subtitle,
    required this.type,
    this.originalObject,
    required this.onTap,
  });
}

class StudentSearchController extends GetxController {
  final textController = TextEditingController();
  final searchQuery = "".obs;
  final searchResults = <SearchResult>[].obs;
  final recentSearches = <String>[].obs;
  final selectedCategory = "All".obs;
  final isLoading = false.obs;

  final categories = ["All", "Courses", "Tasks", "Chats", "Tools"];

  // Cache for all joinable courses
  final allAvailableCourses = <AcademicCourse>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentSearches();
    fetchAllCourses();
    
    // Automatically trigger search when text or category changes
    textController.addListener(_onTextChanged);
    ever(selectedCategory, (_) => performSearch());
  }

  void _onTextChanged() {
    searchQuery.value = textController.text;
    performSearch();
  }

  Future<void> loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('student_recent_searches') ?? [];
      recentSearches.assignAll(history);
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
    }
  }

  Future<void> saveRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = List<String>.from(recentSearches);
      current.remove(trimmed);
      current.insert(0, trimmed);
      
      // Limit to 10 items
      if (current.length > 10) {
        current.removeLast();
      }
      
      recentSearches.assignAll(current);
      await prefs.setStringList('student_recent_searches', current);
    } catch (e) {
      debugPrint('Error saving recent search: $e');
    }
  }

  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('student_recent_searches');
      recentSearches.clear();
    } catch (e) {
      debugPrint('Error clearing recent searches: $e');
    }
  }

  Future<void> removeRecentSearch(String item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = List<String>.from(recentSearches);
      current.remove(item);
      recentSearches.assignAll(current);
      await prefs.setStringList('student_recent_searches', current);
    } catch (e) {
      debugPrint('Error removing search item: $e');
    }
  }

  Future<void> fetchAllCourses() async {
    try {
      isLoading.value = true;
      final response = await AcademicCourseService.getAllCourses();
      if (response.courses != null) {
        allAvailableCourses.assignAll(response.courses!);
      }
    } catch (e) {
      debugPrint("Error fetching all available courses for search: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void performSearch() {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    final resultsList = <SearchResult>[];

    // 1. Filter Courses
    if (selectedCategory.value == "All" || selectedCategory.value == "Courses") {
      // Search enrolled courses
      final homeController = Get.isRegistered<StudentHomeController>()
          ? Get.find<StudentHomeController>()
          : Get.put(StudentHomeController());

      final enrolledMatched = homeController.enrolledCourses.where((c) {
        final title = (c.title ?? '').toLowerCase();
        final code = (c.courseCode ?? '').toLowerCase();
        final instructor = (c.instructor?.username ?? '').toLowerCase();
        return title.contains(query) || code.contains(query) || instructor.contains(query);
      });

      for (var c in enrolledMatched) {
        resultsList.add(SearchResult(
          title: c.title ?? 'Enrolled Course',
          subtitle: '${c.courseCode ?? ""} • Instructor: ${c.instructor?.username ?? "N/A"} (Enrolled)',
          type: SearchResultType.course,
          originalObject: c,
          onTap: () {
            saveRecentSearch(textController.text);
            final courseModel = CourseModel(
              id: c.id,
              title: c.title ?? c.courseCode ?? 'Course #${c.id}',
              instructor: c.instructor?.username ?? '',
              status: c.status ?? 'Enrolled',
              progress: 0.0,
              totalClasses: 0,
              attendedClasses: 0,
              nextClass: 'N/A',
              nextExam: 'N/A',
              activities: [],
            );
            Get.to(() => CourseDetailScreen(course: courseModel));
          },
        ));
      }

      // Search available courses that are NOT enrolled
      final enrolledIds = homeController.enrolledCourses.map((c) => c.id).toSet();
      final availableMatched = allAvailableCourses.where((c) {
        if (enrolledIds.contains(c.id)) return false;
        final title = (c.title ?? '').toLowerCase();
        final code = (c.courseCode ?? '').toLowerCase();
        final instructor = (c.instructor?.username ?? '').toLowerCase();
        return title.contains(query) || code.contains(query) || instructor.contains(query);
      });

      for (var c in availableMatched) {
        resultsList.add(SearchResult(
          title: c.title ?? 'Available Course',
          subtitle: '${c.courseCode ?? ""} • Instructor: ${c.instructor?.username ?? "N/A"}',
          type: SearchResultType.course,
          originalObject: c,
          onTap: () {
            saveRecentSearch(textController.text);
            final courseModel = CourseModel(
              id: c.id,
              title: c.title ?? c.courseCode ?? 'Course #${c.id}',
              instructor: c.instructor?.username ?? '',
              status: c.status ?? 'Available',
              progress: 0.0,
              totalClasses: 0,
              attendedClasses: 0,
              nextClass: 'N/A',
              nextExam: 'N/A',
              activities: [],
            );
            Get.to(() => CourseDetailScreen(course: courseModel));
          },
        ));
      }
    }

    // 2. Filter Tasks
    if (selectedCategory.value == "All" || selectedCategory.value == "Tasks") {
      final taskController = Get.isRegistered<StudentCreateTaskController>()
          ? Get.find<StudentCreateTaskController>()
          : Get.put(StudentCreateTaskController());

      // Fetch tasks if list is empty
      if (taskController.taskListItems.isEmpty) {
        taskController.fetchAllTasks();
      }

      final matchedTasks = taskController.taskListItems.where((t) {
        final title = t.title.toLowerCase();
        final note = t.note.toLowerCase();
        return title.contains(query) || note.contains(query);
      });

      for (var t in matchedTasks) {
        resultsList.add(SearchResult(
          title: t.title,
          subtitle: t.note.isNotEmpty
              ? t.note
              : 'No description • Task',
          type: SearchResultType.task,
          originalObject: t,
          onTap: () {
            saveRecentSearch(textController.text);
            // Navigate to task details
            if (t.id != null) {
              Get.toNamed(AppRoute.studentDetailsTask, arguments: t.id);
            } else {
              Get.toNamed(AppRoute.studentAllTaskList);
            }
          },
        ));
      }
    }

    // 3. Filter Chats / Community
    if (selectedCategory.value == "All" || selectedCategory.value == "Chats") {
      final homeController = Get.isRegistered<StudentHomeController>()
          ? Get.find<StudentHomeController>()
          : Get.put(StudentHomeController());

      final matchedChats = homeController.community.where((c) {
        final text = c.text.toLowerCase();
        return text.contains(query);
      });

      for (var c in matchedChats) {
        resultsList.add(SearchResult(
          title: c.text,
          subtitle: 'Active Community Group Study Room',
          type: SearchResultType.chat,
          originalObject: c,
          onTap: () {
            saveRecentSearch(textController.text);
            c.ontap();
          },
        ));
      }
    }

    // 4. Filter Tools
    if (selectedCategory.value == "All" || selectedCategory.value == "Tools") {
      final staticTools = [
        {'title': 'Calendar', 'desc': 'View your academic schedule, events, and reminder calendar.', 'route': AppRoute.studentCalenderPage},
        {'title': 'File Converter', 'desc': 'Convert documents, images, and notes directly on the fly.', 'route': AppRoute.studentFileConverterPage},
        {'title': 'AI Chat Study Companion', 'desc': 'Talk to our AI bot assistant for educational hints.', 'route': AppRoute.studentAIChatpage},
        {'title': 'Task Creator / Checklist', 'desc': 'Create task lists, prioritize homework and track progress.', 'route': AppRoute.studentCreateTask},
        {'title': 'Tasks Board', 'desc': 'Check all pending, incomplete, and completed assignments.', 'route': AppRoute.studentAllTaskList},
        {'title': 'Student Profile', 'desc': 'View courses summary, personal info, ID, and bio.', 'route': AppRoute.studentProfilePage},
        {'title': 'Settings & Edits', 'desc': 'Update profile details, email, ID, or application options.', 'route': AppRoute.studentSettings},
        {'title': 'Health Resources', 'desc': 'Access physical and mental health resources and guidance.', 'route': AppRoute.studentHealthScreen},
        {'title': 'Wellness Resources', 'desc': 'Discover wellness resources and additional support information.', 'route': AppRoute.studentWellnessScreen},
        {'title': 'Referral Program', 'desc': 'Invite friends and claim promotional rewards or points.', 'route': AppRoute.referralScreen},
      ];

      final matchedTools = staticTools.where((tool) {
        final title = tool['title']!.toLowerCase();
        final desc = tool['desc']!.toLowerCase();
        return title.contains(query) || desc.contains(query);
      });

      for (var t in matchedMatched(matchedTools)) {
        resultsList.add(SearchResult(
          title: t['title']!,
          subtitle: t['desc']!,
          type: SearchResultType.tool,
          originalObject: t,
          onTap: () {
            saveRecentSearch(textController.text);
            Get.toNamed(t['route']!);
          },
        ));
      }
    }

    searchResults.assignAll(resultsList);
  }

  // helper to convert generic iterator to list of maps
  List<Map<String, String>> matchedMatched(Iterable<Map<String, String>> iterable) {
    return iterable.toList();
  }

  @override
  void onClose() {
    textController.removeListener(_onTextChanged);
    textController.dispose();
    super.onClose();
  }
}
