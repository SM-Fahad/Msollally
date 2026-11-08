import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/courses/course_module/widget/file_icon.dart';
import 'package:msollaally/feature/teacher/widgets/get_random_color.dart';

class CourseAssessmentCard extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final controller;
  final int index;

  const CourseAssessmentCard({super.key, this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    final assessment = controller.filteredAssessments[index];
    final String title = (assessment['title'] ?? '').toString();
    final String type = (assessment['type'] ?? '').toString();
    final String date = (assessment['date'] ?? '').toString();
    final int files = assessment['files'] is int
        ? assessment['files'] as int
        : 0;
    final String fileType = (assessment['fileType'] ?? 'file').toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: getRandomColor().withValues(alpha: 0.1),
        title: Text(title, style: getTextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 3,
          children: [
            if (type.isNotEmpty) Text(type),
            if (files > 0)
              Row(
                children: List.generate(
                  files,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: FileIcon(type: fileType),
                  ),
                ),
              ),
            Text(date),
          ],
        ),
      ),
    );
  }
}
