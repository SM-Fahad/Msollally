import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/student/academics/courses/assessment/controller/student_assessment_controller.dart';
import 'package:msollaally/feature/student/academics/courses/examDetail/screen/exam_detail_screen.dart';

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key, required this.courseId});

  final int courseId;

  String get _tag => 'student-assessment-$courseId';

  StudentAssessmentController get controller {
    if (Get.isRegistered<StudentAssessmentController>(tag: _tag)) {
      return Get.find<StudentAssessmentController>(tag: _tag);
    }
    return Get.put(StudentAssessmentController(courseId: courseId), tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final assessmentController = controller;

    return Padding(
      padding: EdgeInsets.all(16.width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 28.fontSize,
                    color: Colors.blueAccent,
                  ),
                  SizedBox(width: 8.width),
                  Text(
                    'Assessments',
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: assessmentController.fetchAssessments,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          SizedBox(height: 12.height),
          const Divider(),
          SizedBox(height: 12.height),
          Expanded(
            child: Obx(() {
              if (assessmentController.isLoading.value &&
                  assessmentController.assessments.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final error = assessmentController.errorMessage.value;
              if (error != null && assessmentController.assessments.isEmpty) {
                return _EmptyState(
                  message: error,
                  actionLabel: 'Retry',
                  onPressed: assessmentController.fetchAssessments,
                );
              }

              if (assessmentController.assessments.isEmpty) {
                return _EmptyState(
                  message: 'No assessments found for this course.',
                  actionLabel: 'Refresh',
                  onPressed: assessmentController.fetchAssessments,
                );
              }

              return ListView.builder(
                itemCount: assessmentController.assessments.length,
                itemBuilder: (context, index) {
                  final assessment = assessmentController.assessments[index];
                  final bgColor = _cardBackground(
                    assessment['type']?.toString(),
                  );
                  final textColor = _textColor(assessment['type']?.toString());

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExamDetailScreen(
                            controller: assessmentController,
                            assessmentId: (assessment['id'] ?? 0) as int,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.height),
                      padding: EdgeInsets.all(18.width),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14.radius),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  (assessment['title'] ?? 'Assessment')
                                      .toString(),
                                  style: getTextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.width),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.width,
                                  vertical: 5.height,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    999.radius,
                                  ),
                                ),
                                child: Text(
                                  (assessment['type'] ?? 'assessment')
                                      .toString()
                                      .toUpperCase(),
                                  style: getTextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.height),
                          Text(
                            assessmentController.remainingLabel(assessment),
                            style: getTextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 6.height),
                          Text(
                            'Due: ${assessmentController.dueDateLabel(assessment)}',
                            style: getTextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 6.height),
                          Text(
                            'Marks: ${assessment['totalMarks'] ?? 0} • ${assessment['questionFormat'] ?? 'N/A'}',
                            style: getTextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _cardBackground(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'exam':
        return Colors.orange.shade50;
      case 'assignment':
        return Colors.blue.shade50;
      case 'quiz':
        return Colors.green.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _textColor(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'exam':
        return Colors.deepOrange;
      case 'assignment':
        return Colors.blue;
      case 'quiz':
        return Colors.green;
      default:
        return Colors.black87;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.width),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              size: 40.fontSize,
              color: Colors.grey,
            ),
            SizedBox(height: 12.height),
            Text(
              message,
              textAlign: TextAlign.center,
              style: getTextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 12.height),
            OutlinedButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
