import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/student/academics/courses/academic_courses/service/academic_course_service.dart';
import '../../cr/model/cr_course_model.dart';
import '../model/course_detail_api_model.dart';
import '../model/course_model.dart';

class CourseDetailOverview extends StatelessWidget {
  final CourseModel course;
  final double progressPercent;
  final Future<_CourseOverviewData?> _courseOverviewFuture;

  CourseDetailOverview({
    super.key,
    required this.course,
    required this.progressPercent,
  }) : _courseOverviewFuture = _loadCourseOverview(course.id);

  static Future<_CourseOverviewData?> _loadCourseOverview(int? courseId) async {
    if (courseId == null) return null;
    final results = await Future.wait([
      AcademicCourseService.getCourseById(courseId),
      AcademicCourseService.getCourseProgress(courseId),
      AcademicCourseService.getCourseCrs(courseId),
    ]);
    return _CourseOverviewData(
      detail: results[0] as CourseDetailApiModel,
      progress: results[1] as StudentCourseProgressModel,
      crs: (results[2] as List).cast<CourseCrMember>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_CourseOverviewData?>(
      future: _courseOverviewFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 140,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 160,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: 180,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: 100,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                snapshot.error.toString(),
                style: getTextStyle(color: AppColors.uiDangerColor),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final overview = snapshot.data;
        if (overview == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Course id not available for detail lookup.',
                style: getTextStyle(color: AppColors.uiDangerColor),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final detail = overview.detail;
        final progressData = overview.progress;
        final progress = detail.overallProgress / 100;
        final nextClass = detail.nextClass;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Overview: ${detail.title}",
                style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                detail.instructor?.username ?? course.instructor,
                style: getTextStyle(color: AppColors.primaryButtonColor),
              ),
              if (detail.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(detail.description),
              ],
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Classes: ${detail.totalClasses}"),
                        const SizedBox(height: 6),
                        Text("Enrolled Students: ${detail.enrolledCount}"),
                        const SizedBox(height: 10),
                        Text(
                          "Next Class: ${_formatNextClass(nextClass)}",
                          style: getTextStyle(color: AppColors.uiDangerColor),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Duration: ${_formatDateRange(detail.startDate, detail.endDate)}",
                          style: getTextStyle(color: AppColors.uiDangerColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 15,
                          backgroundColor: AppColors.sectionBorderColor,
                          color: AppColors.primaryButtonColor,
                        ),
                        Center(
                          child: Text(
                            "${detail.overallProgress}%",
                            style: getTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _ProgressSection(progress: progressData),
              if (snapshot.data?.crs.isNotEmpty == true) ...[
                const SizedBox(height: 20),
                _ClassRepresentativesSection(crs: snapshot.data!.crs),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatNextClass(CourseDetailClass? nextClass) {
    if (nextClass?.startTime == null) return 'No scheduled class';
    final start = nextClass!.startTime!.toLocal();
    return '${nextClass.title} • ${DateFormat('MMM d, h:mm a').format(start)}';
  }

  String _formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return 'Not scheduled';
    final formatter = DateFormat('MMM d, yyyy');
    return '${formatter.format(startDate.toLocal())} - ${formatter.format(endDate.toLocal())}';
  }
}

class _CourseOverviewData {
  final CourseDetailApiModel detail;
  final StudentCourseProgressModel progress;
  final List<CourseCrMember> crs;

  const _CourseOverviewData({
    required this.detail,
    required this.progress,
    required this.crs,
  });
}

class _ClassRepresentativesSection extends StatelessWidget {
  final List<CourseCrMember> crs;

  const _ClassRepresentativesSection({required this.crs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('👑', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Text(
                'Class Representatives',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${crs.length} Active',
                  style: getTextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: crs.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final cr = crs[index];
              final name = cr.fullName ?? 'Student CR';
              final email = cr.email ?? '';

              return Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryButtonColor.withValues(alpha: 0.1),
                    backgroundImage: (cr.avatar != null && cr.avatar!.isNotEmpty)
                        ? NetworkImage(cr.avatar!)
                        : null,
                    child: (cr.avatar == null || cr.avatar!.isEmpty)
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'C',
                            style: getTextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryButtonColor,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: getTextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'CR',
                                style: getTextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getTextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.progress});

  final StudentCourseProgressModel progress;

  @override
  Widget build(BuildContext context) {
    final enrollment = progress.enrollment;
    final performance = progress.academicPerformance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _InfoChip(label: 'Status', value: _formatLabel(enrollment.status)),
            _InfoChip(
              label: 'Grade',
              value: enrollment.grade.isEmpty ? 'N/A' : enrollment.grade,
            ),
            _InfoChip(label: 'Progress', value: '${enrollment.progress}%'),
            _InfoChip(
              label: 'Enrolled',
              value: enrollment.enrolledAt == null
                  ? 'N/A'
                  : DateFormat(
                      'dd MMM yyyy',
                    ).format(enrollment.enrolledAt!.toLocal()),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _MetricCard(
          title: 'Academic Performance',
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _MetricTile(
                label: 'Submissions',
                value:
                    '${performance.gradedSubmissions}/${performance.totalSubmissions}',
              ),
              _MetricTile(
                label: 'Pending',
                value: '${performance.pendingSubmissions}',
              ),
              _MetricTile(
                label: 'Marks',
                value:
                    '${double.parse(performance.totalEarnedMarks).toInt()}/${performance.totalPossibleMarks}',
              ),
              _MetricTile(
                label: 'Overall',
                value: '${performance.overallPercentage}%',
              ),
            ],
          ),
        ),
        if (progress.modules.isNotEmpty) ...[
          const SizedBox(height: 12),
          _MetricCard(
            title: 'Modules',
            child: Column(
              children: progress.modules
                  .take(3)
                  .map(
                    (module) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  module.title,
                                  style: getTextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: module.progress.clamp(0, 100) / 100,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(999),
                                  backgroundColor: AppColors.sectionBorderColor,
                                  color: AppColors.primaryButtonColor,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            module.isCompleted ? 'Done' : '${module.progress}%',
                            style: getTextStyle(
                              color: module.isCompleted
                                  ? AppColors.checkBoxActiveColor
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
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
    return parts.isEmpty ? 'N/A' : parts.join(' ');
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sectionBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: getTextStyle(
              fontSize: 14,
              color: AppColors.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: getTextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryButtonColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        text: TextSpan(
          style: getTextStyle(fontSize: 13, color: Colors.black87),
          children: [
            TextSpan(
              text: '$label: ',
              style: getTextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
