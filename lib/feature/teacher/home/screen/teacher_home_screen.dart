import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/navbar/controller/navbar_controller.dart';
import 'package:msollaally/feature/navbar/model/navbar_item.dart';
import 'package:msollaally/feature/teacher/home/controller/teacher_home_controller.dart';
import 'package:msollaally/feature/teacher/home/widgets/quick_tool_button.dart';
import 'package:msollaally/feature/teacher/home/widgets/recent_course_widget.dart';
import 'package:msollaally/feature/teacher/home/widgets/schedule_activity.dart';
import 'package:msollaally/feature/teacher/home/widgets/summary_card.dart';
import 'package:msollaally/feature/teacher/widgets/default_teacher_app_bar.dart';
import 'package:msollaally/routes/app_route.dart';
import '../../../../core/const/icons_path.dart';

class TeacherHomeScreen extends StatelessWidget {
  TeacherHomeScreen({super.key});

  final TeacherHomeController controller = Get.put(TeacherHomeController());
  final NavbarController navController = Get.put(
    NavbarController(userProfile: UserProfile.teacher),
    tag: UserProfile.teacher.name,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultTeacherAppBar(
        title: 'Teacher Dashboard',
        isHomePage: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Tools
            Text(
              "Quick Tools",
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    navController.changeTab(1);
                  },
                  child: QuickToolButton(
                    title: "Courses",
                    iconPath: IconsPath.coursesIcon,
                    color: Colors.purple,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    navController.changeTab(2);
                  },
                  child: QuickToolButton(
                    title: "Students",
                    iconPath: IconsPath.studentsIconTeacherFlow,
                    color: Colors.orange,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoute.teacherScheduleClassScreen);
                  },
                  child: QuickToolButton(
                    title: "Scheduled Class",
                    iconPath: IconsPath.scheduleClassIconTeacherFlow,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Summary
            Text(
              "Summary",
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            Obx(() {
              double itemHeight = 145;
              return GridView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: itemHeight,
                ),
                children: [
                  SummaryCard(
                    title: "Total Students",
                    value: controller.totalStudents.value.toString(),
                    iconPath: IconsPath.studentsIconTeacherFlow,
                    color: Colors.orange,
                  ),
                  SummaryCard(
                    title: "Courses",
                    value: controller.courses.value.toString(),
                    iconPath: IconsPath.coursesIcon,
                    color: Colors.green,
                  ),
                  SummaryCard(
                    title: "Pending Submissions",
                    value: controller.exams.value.toString(),
                    iconPath: IconsPath.scheduleClassIconTeacherFlow,
                    color: Colors.blue,
                  ),
                  SummaryCard(
                    title: "Published Courses",
                    value: controller.engagementRate.value.toString(),
                    iconPath: IconsPath.engagementIconTeacherFlow,
                    color: Colors.purple,
                  ),
                ],
              );
            }),
            SizedBox(height: 12),

            // Scheduled Activity
            Text(
              "Scheduled Activity",
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Obx(() {
              if (controller.isLoading.value &&
                  controller.activityList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.activityList.isEmpty) {
                return const _TeacherHomeEmptyState(
                  message: 'No scheduled activity found.',
                );
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: controller.activityList.map((course) {
                    return ScheduleActivityCard(course: course);
                  }).toList(),
                ),
              );
            }),
            SizedBox(height: 12),

            // Recent Courses
            Text(
              "Recent Courses",
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Obx(() {
              if (controller.isLoading.value &&
                  controller.recentCourses.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.recentCourses.isEmpty) {
                return const _TeacherHomeEmptyState(
                  message: 'No recent courses found.',
                );
              }
              return SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: controller.recentCourses.length,
                  itemBuilder: (context, index) {
                    final course = controller.recentCourses[index];
                    return RecentCourseWidget(course: course);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    ),
    );
  }
}

class _TeacherHomeEmptyState extends StatelessWidget {
  const _TeacherHomeEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: getTextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
    );
  }
}
