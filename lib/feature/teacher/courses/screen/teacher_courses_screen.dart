import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/courses/controller/course_controller.dart';
import 'package:msollaally/feature/teacher/courses/widget/courses_card.dart';
import 'package:msollaally/feature/teacher/widgets/default_teacher_app_bar.dart';
import 'package:msollaally/routes/app_route.dart';

class TeacherCoursesScreen extends StatelessWidget {
  TeacherCoursesScreen({super.key});

  final CourseScreenController controller = Get.put(CourseScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultTeacherAppBar(isHomePage: false, title: 'Courses'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 10,
          children: [
            const YourCourseTitleSection(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.activityList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.activityList.isEmpty) {
                  return Center(
                    child: Text(
                      'No courses found',
                      style: getTextStyle(
                        fontSize: 16,
                        color: Colors.grey[600]!,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchMyCourses(),
                  child: ListView.builder(
                    itemCount: controller.activityList.length,
                    itemBuilder: (context, index) {
                      final activity = controller.activityList[index];
                      return InkWell(
                        onTap: () async {
                          await Get.toNamed(
                            AppRoute.teacherCourseModule,
                            arguments: activity,
                          );
                          await controller.fetchMyCourses();
                        },
                        child: CoursesCard(
                          activity: activity,
                          isPublishing: controller.isPublishing(activity.id),
                          onPublish: () => controller.publishCourse(activity),
                          onEdit: () async {
                            await Get.toNamed(
                              AppRoute.teacherAddCourse,
                              arguments: {'course': activity},
                            );
                            await controller.fetchMyCourses();
                          },
                          onClone: () => controller.promptCloneCourse(activity),
                          onDelete: () =>
                              controller.confirmDeleteCourse(activity),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class YourCourseTitleSection extends StatelessWidget {
  const YourCourseTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseScreenController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Your Course',
            style: getTextStyle(color: Colors.grey[600]!, fontSize: 18),
          ),
          GestureDetector(
            onTap: () async {
              await Get.toNamed(AppRoute.teacherAddCourse);
              await controller.fetchMyCourses();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryButtonColor),
              ),
              child: Text(
                '+ Add course',
                style: getTextStyle(color: AppColors.primaryButtonColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
