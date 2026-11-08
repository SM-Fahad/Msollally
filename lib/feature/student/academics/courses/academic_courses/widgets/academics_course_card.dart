import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../controller/academics_controller.dart';
import '../../courseDetail/screen/course_detail_screen.dart';

class AcademicsCourseCard extends StatelessWidget {
  final dynamic course;
  final VoidCallback onDropCourse;

  const AcademicsCourseCard({
    super.key,
    required this.course,
    required this.onDropCourse,
  });

  @override
  Widget build(BuildContext context) {
    final title = _getTitle();
    final courseCode = _getCourseCode();
    final instructor = _getInstructor();
    final coverImage = _getCoverImage();
    final status = _getStatus();
    final progress = _getProgress();
    final grade = _getGrade();

    final isCompleted = status.toLowerCase() == 'completed';
    final isActive = status.toLowerCase() == 'active';
    final courseId = _getId();
    final isCr = Get.isRegistered<CourseController>()
        ? Get.find<CourseController>().isCrForCourse(courseId)
        : false;

    return GestureDetector(
      onTap: () {
        Get.to(() => CourseDetailScreen(course: course));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
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
                // Cover Image Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: coverImage.isNotEmpty
                      ? Image.network(
                          coverImage,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
                const SizedBox(width: 12),
                // Course Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Code & Status Row
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (isCr)
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
                          if (courseCode.isNotEmpty)
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
                                courseCode,
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
                              color: isCompleted
                                  ? const Color(0xFFECFDF5)
                                  : isActive
                                      ? const Color(0xFFF0FDF4)
                                      : const Color(0xFFF8FAFC),
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
                                    color: isCompleted || isActive
                                        ? const Color(0xFF16A34A)
                                        : Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  status.toUpperCase(),
                                  style: getTextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isCompleted || isActive
                                        ? const Color(0xFF15803D)
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (grade != null && grade.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Grade: $grade',
                                style: getTextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Instructor
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              instructor.isNotEmpty
                                  ? instructor
                                  : 'Instructor unassigned',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions Menu
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'drop') {
                      onDropCourse();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'drop',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Drop course',
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
            const SizedBox(height: 12),
            // Progress Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up_rounded,
                            size: 15,
                            color: AppColors.primaryButtonColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Course Progress',
                            style: getTextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: getTextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryButtonColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted
                            ? const Color(0xFF16A34A)
                            : AppColors.primaryButtonColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Footer CTA
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Course Details',
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
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
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

  String _getTitle() {
    try {
      final val = course.title;
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString();
      }
    } catch (_) {}
    return 'Untitled Course';
  }

  String _getCourseCode() {
    try {
      final val = course.courseCode;
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString();
      }
    } catch (_) {}
    return '';
  }

  String _getInstructor() {
    try {
      final val = course.instructor;
      if (val != null) {
        if (val is String && val.trim().isNotEmpty) return val;
        if (val.username != null && val.username.toString().trim().isNotEmpty) {
          return val.username.toString();
        }
      }
      final name = course.instructorName;
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    } catch (_) {}
    return '';
  }

  String _getCoverImage() {
    try {
      final val = course.coverImage;
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString();
      }
    } catch (_) {}
    return '';
  }

  double _getProgress() {
    try {
      final val = course.progress;
      if (val != null) {
        final d = (val is num)
            ? val.toDouble()
            : double.tryParse(val.toString()) ?? 0.0;
        return (d > 1.0 ? d / 100.0 : d).clamp(0.0, 1.0);
      }
    } catch (_) {}
    return 0.0;
  }

  String _getStatus() {
    try {
      final val = course.status;
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString();
      }
    } catch (_) {}
    return 'active';
  }

  String? _getGrade() {
    try {
      final val = course.grade;
      if (val != null &&
          val.toString().trim().isNotEmpty &&
          val.toString() != 'null') {
        return val.toString();
      }
    } catch (_) {}
    return null;
  }

  int? _getId() {
    try {
      final val = course.id;
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString());
    } catch (_) {}
    return null;
  }
}
