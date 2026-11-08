import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/courses/model/teacher_course_model.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CoursesCard extends StatelessWidget {
  final TeacherCourseModel activity;
  final VoidCallback? onPublish;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onClone;
  final bool isPublishing;

  const CoursesCard({
    super.key,
    required this.activity,
    this.onPublish,
    this.onEdit,
    this.onDelete,
    this.onClone,
    this.isPublishing = false,
  });

  @override
  Widget build(BuildContext context) {
    final status = activity.status.toLowerCase();
    final isDraft = status == 'draft';
    final statusColor = status == 'published'
        ? Colors.green
        : status == 'draft'
        ? Colors.orange
        : Colors.blue;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activity.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: activity.coverImage.isNotEmpty
                    ? Image.network(
                        activity.coverImage,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: getTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.courseCode.isEmpty
                          ? 'No course code'
                          : activity.courseCode,
                      style: getTextStyle(
                        fontSize: 13,
                        color: Colors.grey[700]!,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _infoChip('Modules', activity.moduleCount.toString()),
                        _infoChip('Students', activity.students.toString()),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PopupMenuButton<_CourseCardAction>(
                    onSelected: (value) {
                      switch (value) {
                        case _CourseCardAction.edit:
                          onEdit?.call();
                          break;
                        case _CourseCardAction.delete:
                          onDelete?.call();
                          break;
                        case _CourseCardAction.clone:
                          onClone?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _CourseCardAction.edit,
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: _CourseCardAction.delete,
                        child: Text('Delete'),
                      ),
                      PopupMenuItem(
                        value: _CourseCardAction.clone,
                        child: Text('Clone Course'),
                      ),
                    ],
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.more_vert),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CircularPercentIndicator(
                    radius: 28,
                    lineWidth: 6,
                    percent: activity.progress.clamp(0.0, 1.0),
                    progressColor: activity.color,
                    backgroundColor: activity.color.withValues(alpha: 0.2),
                    center: Text(
                      '${(activity.progress * 100).toInt()}%',
                      style: getTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            activity.description.isEmpty
                ? 'No description'
                : activity.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: getTextStyle(fontSize: 13, color: Colors.grey[700]!),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Start: ${_formatDate(activity.startDate)}',
                  style: getTextStyle(fontSize: 12, color: Colors.grey[600]!),
                ),
              ),
              Expanded(
                child: Text(
                  'End: ${_formatDate(activity.endDate)}',
                  textAlign: TextAlign.end,
                  style: getTextStyle(fontSize: 12, color: Colors.grey[600]!),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  activity.status.toUpperCase(),
                  style: getTextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (isDraft)
                ElevatedButton(
                  onPressed: isPublishing ? null : onPublish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButtonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(isPublishing ? 'Publishing...' : 'Publish'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ghostWhiteF5F8FF,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryButtonColor.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        '$label: $value',
        style: getTextStyle(fontSize: 12, color: Colors.blueGrey),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.ghostWhiteF5F8FF,
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book_outlined, color: AppColors.primaryButtonColor),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not scheduled';
    return DateFormat('MMM d, yyyy').format(date);
  }
}

enum _CourseCardAction { edit, delete, clone }
