import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/home/model/schedule_activity_model.dart';

class ScheduleActivityCard extends StatelessWidget {
  final ScheduleActivityModel course;
  final Color bgColor;

  const ScheduleActivityCard({
    super.key,
    required this.course,
    this.bgColor = AppColors.ghostWhiteF5F5FF,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: course.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "${course.students} ",
                  style: getTextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                TextSpan(text: "Students"),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Next Class: ",
                  style: getTextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: course.nextClass),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Next Exam: ",
                  style: getTextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: course.nextExam),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
