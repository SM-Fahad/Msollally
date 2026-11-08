import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/student/academics/courses/module/screen/module_screen.dart';
import 'package:msollaally/feature/student/academics/courses/module/controller/module_controller.dart';
import 'package:msollaally/feature/student/academics/courses/notice/screen/notices_sreen.dart';
import 'package:msollaally/feature/student/academics/courses/notice/controller/notice_controller.dart';
import 'package:msollaally/feature/student/academics/courses/academic_courses/controller/academics_controller.dart';
import 'package:msollaally/feature/student/academics/courses/cr/model/cr_course_model.dart';
import 'package:msollaally/feature/student/academics/courses/cr/widgets/cr_post_notice_dialog.dart';
import 'package:msollaally/routes/app_route.dart';
import '../model/course_model.dart';
import '../../assessment/screen/assess_screen.dart';
import '../widgets/course_detail_overview.dart';

class CourseDetailController extends GetxController {
  var selectedIndex = 0.obs;
}

class CourseDetailScreen extends StatelessWidget {
  final CourseModel course;
  final CourseDetailController controller = Get.put(CourseDetailController());

  CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    double progressPercent = course.totalClasses > 0
        ? (course.attendedClasses / course.totalClasses)
        : 0.0;

    final courseController = Get.isRegistered<CourseController>()
        ? Get.find<CourseController>()
        : null;
    final isCr = courseController?.isCrForCourse(course.id) ?? false;
    final crInfo = courseController?.getCrInfo(course.id);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(course.title),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: getTextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        actions: [
          if (isCr)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('👑', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  Text(
                    'CR Access',
                    style: getTextStyle(
                      color: const Color(0xFFB45309),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context, isCr, crInfo),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          Expanded(
            child: Obx(() => _buildSection(progressPercent)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Obx(
          () => Row(
            children: [
              _tabItem("Overview", 0, Icons.info_outline_rounded),
              const SizedBox(width: 8),
              _tabItem("Modules", 1, Icons.menu_book_rounded),
              const SizedBox(width: 8),
              _tabItem("Assessments", 2, Icons.assignment_outlined),
              const SizedBox(width: 8),
              _tabItem("Notices", 3, Icons.campaign_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabItem(String title, int index, IconData icon) {
    final isActive = controller.selectedIndex.value == index;
    return GestureDetector(
      onTap: () => controller.selectedIndex.value = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryButtonColor.withValues(alpha: 0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.primaryButtonColor.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? AppColors.primaryButtonColor
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: getTextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? AppColors.primaryButtonColor
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(double progressPercent) {
    switch (controller.selectedIndex.value) {
      case 0:
        return CourseDetailOverview(
          course: course,
          progressPercent: progressPercent,
        );
      case 1:
        return ModuleScreen(courseId: course.id);
      case 2:
        return AssessmentScreen(courseId: course.id ?? 0);
      case 3:
        return NoticeScreen(courseId: course.id);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    bool isCr,
    MyCrCourse? crInfo,
  ) {
    if (!isCr || crInfo == null) return null;

    return Obx(() {
      final selectedTab = controller.selectedIndex.value;

      // Tab 3: Notices (canManageNotices)
      if (selectedTab == 3 && crInfo.canManageNotices) {
        return FloatingActionButton.extended(
          heroTag: 'cr_post_notice_fab',
          backgroundColor: AppColors.primaryButtonColor,
          icon: const Icon(Icons.add_comment_rounded, color: Colors.white, size: 20),
          label: Text(
            'Post Notice',
            style: getTextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            CrPostNoticeDialog.show(
              context,
              courseId: course.id ?? 0,
              onNoticeCreated: () {
                final tag = 'student-notice-${course.id}';
                if (Get.isRegistered<NoticeController>(tag: tag)) {
                  Get.find<NoticeController>(tag: tag).fetchNotices();
                }
              },
            );
          },
        );
      }

      // Tab 1: Modules (canManageModules)
      if (selectedTab == 1 && crInfo.canManageModules) {
        return FloatingActionButton.extended(
          heroTag: 'cr_add_module_fab',
          backgroundColor: AppColors.primaryButtonColor,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: Text(
            'Add Module',
            style: getTextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            final result = await Get.toNamed(
              AppRoute.teacherAddModuleScreen,
              arguments: {
                'courseId': course.id,
                'courseTitle': course.title,
                'course': course,
              },
            );
            if (result != null) {
              final tag = 'student-module-${course.id}';
              if (Get.isRegistered<ModuleController>(tag: tag)) {
                Get.find<ModuleController>(tag: tag).fetchModules();
              }
            }
          },
        );
      }

      // Tab 2: Assessments (canManageAssessments)
      if (selectedTab == 2 && crInfo.canManageAssessments) {
        return FloatingActionButton.extended(
          heroTag: 'cr_add_assessment_fab',
          backgroundColor: AppColors.primaryButtonColor,
          icon: const Icon(Icons.quiz_rounded, color: Colors.white, size: 20),
          label: Text(
            'Add Exam/Quiz',
            style: getTextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Get.toNamed(
              AppRoute.teacherAddAssesmentExamScreen,
              arguments: {
                'courseId': course.id,
                'courseTitle': course.title,
                'course': course,
              },
            );
          },
        );
      }

      return const SizedBox.shrink();
    });
  }
}
