import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import '../controller/academics_controller.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import '../model/academic_course_model.dart';
import '../../join_courses/screen/join_courses_screen.dart';
import 'academics_course_card.dart';

class AcademicsCoursesSection extends StatelessWidget {
  final CourseController courseController;

  const AcademicsCoursesSection({super.key, required this.courseController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book, color: Colors.grey),
                  SizedBox(width: 6),
                  Text(
                    "Your Courses",
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Obx(
                    () => IconButton(
                      tooltip: 'Refresh courses',
                      onPressed: courseController.isLoading.value
                          ? null
                          : courseController.refreshCourses,
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Get.to(JoinCourseScreen()),
                    icon: Icon(Icons.add, size: 18),
                    label: Text("Join Courses"),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final isLoading =
                courseController.isLoading.value &&
                courseController.isLoadingDashboard.value &&
                courseController.courses.isEmpty &&
                courseController.dashboardItems.isEmpty;

            if (isLoading) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: ShimmerLoading.list(
                  itemCount: 3,
                  height: 110,
                  borderRadius: 16,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: courseController.refreshCourses,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _DashboardSection(courseController: courseController),
                  if (courseController.courses.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * .14,
                      ),
                      child: Center(
                        child: Text(
                          "No courses enrolled yet",
                          style: getTextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    )
                  else
                    ...courseController.courses.map(
                      (course) => AcademicsCourseCard(
                        course: course,
                        onDropCourse: () =>
                            courseController.confirmAndDropCourse(course),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({required this.courseController});

  final CourseController courseController;

  @override
  Widget build(BuildContext context) {
    final items = courseController.dashboardItems;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard_customize_outlined, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Dashboard',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Upcoming course activity',
              style: getTextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            if (courseController.isLoadingDashboard.value && items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ShimmerLoading.list(
                  itemCount: 1,
                  height: 72,
                  borderRadius: 14,
                ),
              )
            else if (items.isEmpty)
              Text(
                'No upcoming items right now.',
                style: getTextStyle(fontSize: 14, color: Colors.black54),
              )
            else
              ...items.take(3).map((item) => _DashboardItemCard(item: item)),
          ],
        ),
      ),
    );
  }
}

class _DashboardItemCard extends StatelessWidget {
  const _DashboardItemCard({required this.item});

  final StudentCourseDashboardItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TypePill(
                label: item.assessmentType.isEmpty
                    ? item.type
                    : item.assessmentType,
              ),
              const Spacer(),
              Text(
                _formatDueDate(item.dueDate),
                style: getTextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title.isEmpty ? 'Untitled item' : item.title,
            style: getTextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            item.courseName.isEmpty ? 'Unknown course' : item.courseName,
            style: getTextStyle(fontSize: 13, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  String _formatDueDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return 'No due date';
    return 'Due ${DateFormat('dd MMM • hh:mm a').format(parsed.toLocal())}';
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.isEmpty ? 'Item' : _formatLabel(label),
        style: getTextStyle(
          fontSize: 12,
          color: Colors.blue.shade900,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatLabel(String raw) {
    final parts = raw
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .toList();
    return parts.isEmpty ? 'Item' : parts.join(' ');
  }
}
