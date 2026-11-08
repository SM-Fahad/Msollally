import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/feature/teacher/home/model/recent_courses_model.dart';
import 'package:msollaally/feature/teacher/home/model/schedule_activity_model.dart';
import 'package:msollaally/feature/teacher/home/model/teacher_home_dashboard_model.dart';
import 'package:msollaally/feature/teacher/home/service/teacher_home_service.dart';

class TeacherHomeController extends GetxController {
  final totalStudents = 0.obs;
  final courses = 0.obs;
  final exams = 0.obs;
  final engagementRate = 0.obs;
  final isLoading = false.obs;
  final dashboard = Rxn<TeacherHomeDashboardModel>();

  final activityList = <ScheduleActivityModel>[].obs;
  final quickTools = [
    {"title": "Courses", "icon": "📄"},
    {"title": "Students", "icon": "👥"},
    {"title": "Scheduled Class", "icon": "📅"},
  ];
  final TeacherHomeService _teacherHomeService = TeacherHomeService();

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  final RxList<RecentCoursesModel> recentCourses = <RecentCoursesModel>[].obs;

  Future<void> fetchDashboard() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final dashboardData = await _teacherHomeService.getInstructorDashboard();
      dashboard.value = dashboardData;
      _applyDashboard(dashboardData);
    } catch (e) {
      activityList.clear();
      recentCourses.clear();
      dashboard.value = null;
      totalStudents.value = 0;
      courses.value = 0;
      exams.value = 0;
      engagementRate.value = 0;
      EasyLoading.showError(_extractErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void _applyDashboard(TeacherHomeDashboardModel dashboardData) {
    totalStudents.value = dashboardData.statistics.totalStudents;
    courses.value = dashboardData.statistics.totalCourses;
    exams.value = dashboardData.statistics.pendingSubmissions;
    engagementRate.value = dashboardData.statistics.publishedCourses;

    activityList.assignAll(
      dashboardData.upcomingClasses.map(
        (item) => ScheduleActivityModel(
          title: item.courseName.isNotEmpty ? item.courseName : item.title,
          students: 0,
          nextClass: _formatDateTimeRange(item.startTime, item.endTime),
          nextExam: item.classroom.isNotEmpty ? item.classroom : 'N/A',
          color: AppColors.royalBlue5757E7,
        ),
      ),
    );

    recentCourses.assignAll(
      dashboardData.courses.map(
        (item) => RecentCoursesModel(
          title: item.title,
          date: item.courseCode.isNotEmpty ? item.courseCode : 'N/A',
          status: _formatCourseStatus(item.status),
        ),
      ),
    );
  }

  String _formatDateTimeRange(DateTime? start, DateTime? end) {
    if (start == null) {
      return 'N/A';
    }
    final startLocal = start.toLocal();
    final date = DateFormat('MMM d').format(startLocal);
    final startText = DateFormat('hh:mm a').format(startLocal);
    if (end == null) {
      return '$date, $startText';
    }
    final endText = DateFormat('hh:mm a').format(end.toLocal());
    return '$date, $startText - $endText';
  }

  String _formatCourseStatus(String status) {
    final normalized = status.trim().toLowerCase();
    switch (normalized) {
      case 'published':
        return 'Published';
      case 'draft':
        return 'Draft';
      case 'completed':
        return 'Completed';
      default:
        if (normalized.isEmpty) {
          return 'Unknown';
        }
        return normalized[0].toUpperCase() + normalized.substring(1);
    }
  }

  String _extractErrorMessage(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '');
  }
}
