import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/teacher/courses/model/teacher_course_model.dart';
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 18,
                  color: AppColors.primaryButtonColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Your Courses",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              Obx(
                () => IconButton(
                  tooltip: 'Refresh courses',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                  ),
                  onPressed: courseController.isLoading.value
                      ? null
                      : courseController.refreshCourses,
                  icon: const Icon(Icons.refresh_rounded, size: 21),
                ),
              ),
              const SizedBox(width: 4),
              OutlinedButton.icon(
                onPressed: () => Get.to(() => JoinCourseScreen()),
                icon: const Icon(
                  Icons.explore_outlined,
                  size: 16,
                  color: AppColors.primaryButtonColor,
                ),
                label: Text(
                  "Join Courses",
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryButtonColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryButtonColor,
                  side: BorderSide(
                    color: AppColors.primaryButtonColor.withValues(alpha: 0.35),
                  ),
                  backgroundColor: const Color(0xFFEFF6FF).withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
                courseController.dashboardItems.isEmpty &&
                courseController.myCreatedCourses.isEmpty;

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
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _DashboardSection(courseController: courseController),
                  if (courseController.isCr.value)
                    _CrCreatedCoursesSection(
                      courseController: courseController,
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Row(
                      children: [
                        Text(
                          "Enrolled Courses",
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${courseController.courses.length}',
                            style: getTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (courseController.courses.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        top: courseController.isCr.value
                            ? 28
                            : MediaQuery.of(context).size.height * .12,
                        bottom: 32,
                      ),
                      child: Center(
                        child: Text(
                          "No courses enrolled yet",
                          style: getTextStyle(color: Colors.grey, fontSize: 15),
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

class _CrCreatedCoursesSection extends StatelessWidget {
  const _CrCreatedCoursesSection({required this.courseController});

  final CourseController courseController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final createdCourses = courseController.myCreatedCourses;
      final isLoading = courseController.isLoadingCreatedCourses.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('👑', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 3),
                      Text(
                        'CR',
                        style: getTextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          'My Created Courses',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: getTextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${createdCourses.length}',
                          style: getTextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryButtonColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  onPressed: courseController.openCreateCourse,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Create Course',
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading && createdCourses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ShimmerLoading.list(
                itemCount: 1,
                height: 96,
                borderRadius: 16,
              ),
            )
          else if (createdCourses.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.auto_stories_outlined,
                      color: AppColors.primaryButtonColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No courses created yet',
                          style: getTextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'As a Class Representative, you can create and publish courses for your class.',
                          style: getTextStyle(
                            fontSize: 12.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            ...createdCourses.map(
              (course) => _CrCreatedCourseCard(
                course: course,
                courseController: courseController,
              ),
            ),
        ],
      );
    });
  }
}

class _CrCreatedCourseCard extends StatelessWidget {
  const _CrCreatedCourseCard({
    required this.course,
    required this.courseController,
  });

  final TeacherCourseModel course;
  final CourseController courseController;

  @override
  Widget build(BuildContext context) {
    final statusLower = course.status.toLowerCase();
    final isDraft = statusLower == 'draft';
    final isArchived = statusLower == 'archived';
    final isPublished = statusLower == 'published';

    final Color statusColor = isPublished
        ? const Color(0xFF15803D)
        : isDraft
        ? const Color(0xFFB45309)
        : const Color(0xFF475569);
    final Color statusBg = isPublished
        ? const Color(0xFFECFDF5)
        : isDraft
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFF1F5F9);
    final Color dotColor = isPublished
        ? const Color(0xFF16A34A)
        : isDraft
        ? const Color(0xFFF59E0B)
        : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => courseController.openManageCourse(course),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: course.coverImage.isNotEmpty
                      ? Image.network(
                          course.coverImage,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholderThumb(),
                        )
                      : _placeholderThumb(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFF59E0B),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '👑',
                                  style: TextStyle(fontSize: 10),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'CR',
                                  style: getTextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (course.courseCode.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFBFDBFE),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                course.courseCode,
                                style: getTextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1D4ED8),
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: dotColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  course.status.toUpperCase(),
                                  style: getTextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        course.title.isEmpty ? 'Untitled Course' : course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.layers_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.moduleCount} Modules',
                            style: getTextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.people_outline_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.students} Students',
                            style: getTextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'manage':
                        courseController.openManageCourse(course);
                        break;
                      case 'edit':
                        courseController.openEditCourse(course);
                        break;
                      case 'publish':
                        courseController.publishCreatedCourse(course);
                        break;
                      case 'archive':
                        courseController.archiveCreatedCourse(course);
                        break;
                      case 'delete':
                        courseController.confirmDeleteCreatedCourse(course);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'manage',
                      child: Row(
                        children: [
                          Icon(Icons.folder_open_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Manage Modules & Notices'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit Course'),
                        ],
                      ),
                    ),
                    if (isDraft)
                      const PopupMenuItem(
                        value: 'publish',
                        child: Row(
                          children: [
                            Icon(
                              Icons.publish_outlined,
                              size: 18,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text('Publish Course'),
                          ],
                        ),
                      ),
                    if (!isArchived)
                      const PopupMenuItem(
                        value: 'archive',
                        child: Row(
                          children: [
                            Icon(
                              Icons.archive_outlined,
                              size: 18,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text('Archive Course'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete Course',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  if (isDraft) ...[
                    Obx(() {
                      final isPublishing = courseController.isPublishingCourse(
                        course.id,
                      );
                      return ElevatedButton(
                        onPressed: isPublishing
                            ? null
                            : () =>
                                  courseController.publishCreatedCourse(course),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButtonColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isPublishing ? 'Publishing...' : 'Publish Now',
                          style: getTextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }),
                    const Spacer(),
                  ] else ...[
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Modules, Notices & Assessments',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    'Manage Course',
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryButtonColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: AppColors.primaryButtonColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderThumb() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.menu_book_rounded,
        color: AppColors.primaryButtonColor,
        size: 32,
      ),
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
