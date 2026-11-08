import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/teacher/courses/course_assesment/controller/course_assesment_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_assesment/widget/course_assesment_card.dart'
    show CourseAssessmentCard;
import 'package:msollaally/routes/app_route.dart';

class CourseAssessmentScreen extends StatelessWidget {
  CourseAssessmentScreen({super.key}) {
    controller = Get.isRegistered<CourseAssessmentController>()
        ? Get.find<CourseAssessmentController>()
        : Get.put(CourseAssessmentController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialize(Get.arguments);
    });
  }

  late final CourseAssessmentController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        onRefresh: controller.fetchAssessments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exam/Test/Quiz',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        underline: const SizedBox.shrink(),
                        value: controller.selectedFilter.value,
                        items: controller.filterOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.updateFilter(newValue);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  controller.selectedFilter.value == '--'
                      ? "All Assessments"
                      : "${controller.selectedFilter.value} Assessments",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(),
                if (controller.isLoadingAssessments.value &&
                    controller.assessments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.assessments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Center(
                      child: Text(
                        'No assessments found for this course',
                        style: getTextStyle(
                          fontSize: 15,
                          color: Colors.grey[600]!,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.filteredAssessments.length,
                    itemBuilder: (context, index) {
                      final assessment = controller.filteredAssessments[index];
                      return InkWell(
                        onTap: () {
                          Get.toNamed(
                            AppRoute.teacherAssesmentDetailScreen,
                            arguments: {
                              'assessmentId': assessment['id'],
                              'assessment': assessment,
                            },
                          );
                        },
                        child: CourseAssessmentCard(
                          controller: controller,
                          index: index,
                        ),
                      );
                    },
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Get.toNamed(
                          AppRoute.teacherAddAssesmentExamScreen,
                          arguments: {
                            'courseId': controller.currentCourseId.value,
                            'courseTitle': controller.currentCourseTitle.value,
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle_outline_outlined,
                        color: AppColors.primaryButtonColor,
                      ),
                      label: Text(
                        "Add Exam",
                        style: getTextStyle(
                          fontSize: 14,
                          color: AppColors.primaryButtonColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        side: BorderSide(
                          width: 2,
                          color: Colors.blue.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
