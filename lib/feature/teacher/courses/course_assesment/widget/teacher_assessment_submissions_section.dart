import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/courses/course_assesment/controller/course_assesment_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_assesment/screen/submission_detail_screen.dart';

class TeacherAssessmentSubmissionsSection extends StatelessWidget {
  const TeacherAssessmentSubmissionsSection({
    super.key,
    required this.controller,
  });

  final CourseAssessmentController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Submissions',
              style: getTextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Obx(
              () => Text(
                '(${controller.assessmentSubmissions.length})',
                style: getTextStyle(color: Colors.grey[700]!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isLoadingAssessmentSubmissions.value &&
              controller.assessmentSubmissions.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.assessmentSubmissions.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                'No submissions yet',
                style: getTextStyle(color: Colors.grey[700]!),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.assessmentSubmissions.length,
            itemBuilder: (context, index) {
              final submission = controller.assessmentSubmissions[index];
              return _SubmissionCard(
                submission: submission,
                onTap: () => Get.to(
                  () => TeacherSubmissionDetailScreen(
                    controller: controller,
                    submissionId: _toInt(submission['id']),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({required this.submission, required this.onTap});

  final Map<String, dynamic> submission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final studentName = (submission['studentName'] ?? 'Student').toString();
    final status = (submission['status'] ?? 'submitted').toString();
    final submittedDateLabel =
        (submission['submittedDateLabel'] ?? 'Not submitted yet').toString();
    final marks = submission['marks'];
    final fileCount = submission['fileCount'] is int
        ? submission['fileCount'] as int
        : 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    studentName,
                    style: getTextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: getTextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              submittedDateLabel,
              style: getTextStyle(color: Colors.grey[700]!),
            ),
            if (marks != null) ...[
              const SizedBox(height: 4),
              Text('Marks: $marks', style: getTextStyle()),
            ],
            const SizedBox(height: 4),
            Text('Files: $fileCount', style: getTextStyle()),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Tap to open submission',
                style: getTextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
