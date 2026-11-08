import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/teacher/courses/course_notices/controller/course_notice_controller.dart';
import 'package:msollaally/feature/teacher/widgets/teacher_custom_text_field.dart';

class CreateCourseNoticeScreen extends StatelessWidget {
  CreateCourseNoticeScreen({super.key}) {
    controller = Get.isRegistered<CourseNoticeController>()
        ? Get.find<CourseNoticeController>()
        : Get.put(CourseNoticeController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prepareCreateNotice(Get.arguments);
    });
  }

  late final CourseNoticeController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Notice'),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            controller.clearForm();
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                'Title',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              TeacherCustomTextField(
                controller: controller.titleController,
                hintText: 'Notice Title',
              ),
              SizedBox(height: 8),
              Text(
                'Notice',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              TextField(
                maxLines: 4,
                controller: controller.noticeController,
                decoration: InputDecoration(
                  hintText:
                      'Notice details and information goes here. You can include important updates, reminders, or any relevant information for the students.',
                  hintStyle: getTextStyle(color: Colors.grey),
                  border: _outlineInputBorder(),
                  focusedBorder: _outlineInputBorder(),
                  disabledBorder: _outlineInputBorder(),
                  enabledBorder: _outlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isSavingNotice.value
                      ? null
                      : controller.createNotice,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: controller.isSavingNotice.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Notice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder _outlineInputBorder() => OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.5), width: 2),
);
