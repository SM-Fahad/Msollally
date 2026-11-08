import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/student/create_task/controller/student_create_task_controller.dart';
import '../widgets/task_attachment_view.dart';
import '../widgets/task_details_header.dart';

class StudentTaskDetailsPage extends StatelessWidget {
  const StudentTaskDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final controller = Get.isRegistered<StudentCreateTaskController>()
        ? Get.find<StudentCreateTaskController>()
        : Get.put(StudentCreateTaskController());

    if (args is! int || args <= 0) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Text(
              'Task not found',
              style: appTextStyleHeading2(color: AppColors.tertiaryTextColor),
            ),
          ),
        ),
      );
    }

    controller.fetchTaskDetails(args);

    return Scaffold(
      body: Obx(() {
        if (controller.isTaskDetailsLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.taskDetailsErrorMessage.value.isNotEmpty) {
          return SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.width),
                child: Text(
                  controller.taskDetailsErrorMessage.value,
                  style: appTextStyleHeading2(color: AppColors.tertiaryTextColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final items = controller.selectedTask.value;
        if (items == null) {
          return SafeArea(
            child: Center(
              child: Text(
                'Task not found',
                style: appTextStyleHeading2(color: AppColors.tertiaryTextColor),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(top: 38.height),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskDetailsHeader(items: items),
                SizedBox(height: 8.height),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.width),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTaskInfo("Task", items.title),
                      SizedBox(height: 20.height),
                      _buildTaskInfo("Note", items.note),
                      SizedBox(height: 20.height),
                      _buildTaskInfo("Date & time", items.date),
                      SizedBox(height: 15.height),
                      TaskAttachmentView(fileUrl: items.fileUrl),
                      SizedBox(height: 54.height),
                      Obx(
                        () => CustomButton(
                          vertical: 8.height,
                          text: controller.isDeleting.value
                              ? "Deleting..."
                              : "Delete Task",
                          onPressed: () {
                            final taskId = items.id ?? args;
                            controller.deleteTaskById(taskId);
                          },
                          color: AppColors.uiDangerColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTaskInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: appTextStyleHeading2(
            letterSpacing: 0.2.fontSize,
            color: AppColors.black18181B,
          ),
        ),
        Text(
          value,
          style: appTextStyleHeading2(
            letterSpacing: 0.2.fontSize,
            color: AppColors.tertiaryTextColor,
          ),
        ),
      ],
    );
  }
}
