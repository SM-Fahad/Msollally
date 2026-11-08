import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';

import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/shimmer_loading.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/navbar/controller/navbar_controller.dart';
import 'package:msollaally/feature/navbar/model/navbar_item.dart';
import 'package:msollaally/feature/student/academics/courses/academic_courses/model/academic_course_model.dart';
import 'package:msollaally/feature/student/academics/courses/courseDetail/model/course_model.dart';
import 'package:msollaally/feature/student/academics/courses/courseDetail/screen/course_detail_screen.dart';
import 'package:msollaally/feature/student/home/controller/student_home_controller.dart';
import 'package:msollaally/routes/app_route.dart';

const _titleColor = Color(0xFF0F172A);

class StudentHomeCourses extends StatelessWidget {
  const StudentHomeCourses({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentHomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final enrolled = controller.enrolledCourses;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    'Enrolled Courses',
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _titleColor,
                    ),
                  ),
                  if (enrolled.isNotEmpty) ...[
                    SizedBox(width: 8.width),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.width,
                        vertical: 2.height,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryButtonColor.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(10.radius),
                      ),
                      child: Text(
                        '${enrolled.length}',
                        style: getTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryButtonColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (enrolled.isNotEmpty)
                InkWell(
                  onTap: _goToAcademics,
                  borderRadius: BorderRadius.circular(6.radius),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.width,
                      vertical: 2.height,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'See all',
                          style: getTextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryButtonColor,
                          ),
                        ),
                        SizedBox(width: 3.width),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 13.fontSize,
                          color: AppColors.primaryButtonColor,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
        SizedBox(height: 10.height),
        Obx(() {
          if (controller.isLoadingCourses.value) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: [
                  const _CourseSkeleton(),
                  SizedBox(width: 10.width),
                  const _CourseSkeleton(),
                  SizedBox(width: 10.width),
                  const _CourseSkeleton(),
                ],
              ),
            );
          }

          final enrolled = controller.enrolledCourses;
          if (enrolled.isEmpty) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: 12.height,
                horizontal: 14.width,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.radius),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 20.fontSize,
                    color: const Color(0xFF94A3B8),
                  ),
                  SizedBox(width: 8.width),
                  Expanded(
                    child: Text(
                      'No enrolled courses yet',
                      style: getTextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _goToAcademics,
                    child: Text(
                      'Explore',
                      style: getTextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryButtonColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...enrolled.map((course) {
                    return Padding(
                      padding: EdgeInsets.only(right: 10.width),
                      child: _HomeCourseCard(course: course),
                    );
                  }),
                  _MoreCoursesCard(onTap: _goToAcademics),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Rich course card for student home dashboard displaying thumbnail, code, instructor, title, and progress
class _HomeCourseCard extends StatelessWidget {
  final AcademicCourse course;

  const _HomeCourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final title = course.title ?? course.courseCode ?? 'Course #${course.id}';
    final courseCode = (course.courseCode ?? '').trim();
    final instructor = course.instructorName ?? course.instructor?.username ?? '';
    final coverImage = course.coverImage ?? '';
    final rawProgress = course.progress;
    final double progress = (rawProgress != null)
        ? (rawProgress > 1.0
              ? (rawProgress / 100.0).clamp(0.0, 1.0)
              : rawProgress.clamp(0.0, 1.0))
        : 0.0;
    final isCompleted =
        course.status?.toLowerCase() == 'completed' || progress >= 1.0;
    final int percentInt = (progress * 100).toInt();

    return InkWell(
      onTap: () => _openCourseDetail(course),
      borderRadius: BorderRadius.circular(16.radius),
      child: Container(
        width: 235.width,
        padding: EdgeInsets.all(12.width),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.radius),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.radius),
                  child: coverImage.isNotEmpty
                      ? Image.network(
                          coverImage,
                          width: 42.width,
                          height: 42.height,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderThumb(),
                        )
                      : _placeholderThumb(),
                ),
                SizedBox(width: 10.width),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (courseCode.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.width,
                                vertical: 2.height,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(5.radius),
                                border: Border.all(
                                  color: const Color(0xFFC7D2FE),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                courseCode,
                                style: getTextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4338CA),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.width,
                              vertical: 2.height,
                            ),
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(5.radius),
                            ),
                            child: Text(
                              isCompleted ? 'Done' : 'Active',
                              style: getTextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: isCompleted
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.height),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 12.fontSize,
                            color: const Color(0xFF94A3B8),
                          ),
                          SizedBox(width: 3.width),
                          Expanded(
                            child: Text(
                              instructor.isNotEmpty
                                  ? instructor
                                  : 'Instructor unassigned',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(
                                fontSize: 10.5,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.height),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getTextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _titleColor,
              ),
            ),
            SizedBox(height: 8.height),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.radius),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted
                            ? const Color(0xFF16A34A)
                            : AppColors.primaryButtonColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.width),
                Text(
                  isCompleted ? 'Done' : '$percentInt%',
                  style: getTextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? const Color(0xFF16A34A)
                        : AppColors.primaryButtonColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderThumb() {
    return Container(
      width: 42.width,
      height: 42.height,
      decoration: BoxDecoration(
        color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.radius),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.auto_stories_rounded,
        color: AppColors.primaryButtonColor,
        size: 20.fontSize,
      ),
    );
  }
}

/// MORE courses card matching the height and style of the course cards
class _MoreCoursesCard extends StatelessWidget {
  final VoidCallback onTap;

  const _MoreCoursesCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.radius),
      child: Container(
        width: 110.width,
        padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 14.height),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.radius),
          border: Border.all(
            color: AppColors.primaryButtonColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.width),
              decoration: BoxDecoration(
                color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primaryButtonColor,
                size: 18.fontSize,
              ),
            ),
            SizedBox(height: 8.height),
            Text(
              'MORE',
              style: getTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryButtonColor,
              ),
            ),
            SizedBox(height: 2.height),
            Text(
              'All courses',
              style: getTextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseSkeleton extends StatelessWidget {
  const _CourseSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 235.width,
      padding: EdgeInsets.all(12.width),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.radius),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerLoading.card(
                height: 42.height,
                width: 42.width,
                borderRadius: 10.radius,
              ),
              SizedBox(width: 10.width),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShimmerLoading.card(
                          height: 14.height,
                          width: 50.width,
                          borderRadius: 4.radius,
                        ),
                        const Spacer(),
                        ShimmerLoading.card(
                          height: 14.height,
                          width: 40.width,
                          borderRadius: 4.radius,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.height),
                    ShimmerLoading.card(
                      height: 10.height,
                      width: 90.width,
                      borderRadius: 3.radius,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.height),
          ShimmerLoading.card(
            height: 14.height,
            width: 160.width,
            borderRadius: 4.radius,
          ),
          SizedBox(height: 8.height),
          ShimmerLoading.card(
            height: 5.height,
            width: double.infinity,
            borderRadius: 3.radius,
          ),
        ],
      ),
    );
  }
}

void _openCourseDetail(AcademicCourse course) {
  final rawProgress = course.progress;
  final double progress = (rawProgress != null)
      ? (rawProgress > 1.0
            ? (rawProgress / 100.0).clamp(0.0, 1.0)
            : rawProgress.clamp(0.0, 1.0))
      : 0.0;

  final courseModel = CourseModel(
    id: course.id,
    title: course.title ?? course.courseCode ?? 'Course #${course.id}',
    instructor: course.instructorName ?? course.instructor?.username ?? '',
    status: course.status ?? 'active',
    progress: progress,
    totalClasses: 0,
    attendedClasses: 0,
    nextClass: 'N/A',
    nextExam: 'N/A',
    activities: const [],
    courseCode: course.courseCode,
    coverImage: course.coverImage,
    grade: course.grade?.toString(),
  );
  Get.to(() => CourseDetailScreen(course: courseModel));
}

void _goToAcademics() {
  if (Get.isRegistered<NavbarController>(tag: UserProfile.student.name)) {
    Get.find<NavbarController>(tag: UserProfile.student.name).changeTab(1);
  } else {
    Get.toNamed(AppRoute.studentAcademics);
  }
}
