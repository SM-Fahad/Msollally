import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/teacher/courses/course_module/controller/course_module_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_module/widget/file_upload_box.dart';
import 'package:msollaally/feature/teacher/courses/course_module/widget/uploaded_file_tile.dart';
import 'package:msollaally/feature/teacher/widgets/teacher_custom_text_field.dart';

class TeacherAddModuleScreen extends StatelessWidget {
  TeacherAddModuleScreen({super.key}) {
    controller = Get.isRegistered<CourseModuleController>()
        ? Get.find<CourseModuleController>()
        : Get.put(CourseModuleController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prepareModuleForm(Get.arguments);
    });
  }

  late final CourseModuleController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditingModule ? 'Edit Module' : 'Module'),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            controller.clearModuleForm();
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  '${controller.isEditingModule ? 'Edit Module' : 'Add Module'}${controller.selectedCourse.value?.title.isNotEmpty == true ? ' for ${controller.selectedCourse.value!.title}' : ''}',
                  style: Theme.of(context).textTheme.titleLarge!,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Title',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              TeacherCustomTextField(
                controller: controller.addModuleTitleController,
                hintText: 'Module Title',
              ),
              Text(
                'Description',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              TeacherCustomTextField(
                controller: controller.addModuleDescriptionController,
                hintText: 'Module description (optional)',
              ),
              Text(
                'Start Date',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              TextField(
                controller: controller.addModuleDateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Select date',
                  hintStyle: getTextStyle(color: Colors.grey),
                  border: getOutlineInputBorder(),
                  focusedBorder: getOutlineInputBorder(),
                  disabledBorder: getOutlineInputBorder(),
                  enabledBorder: getOutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: controller.pickDateTime,
                    icon: const Icon(Icons.calendar_month),
                  ),
                ),
              ),
              Text(
                'Upload Files (PDF, PPT, DOCS, XLSX, etc.)',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'File Upload',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Text(
                        'Choose a file (PDF, PPT, DOCS, XLSX, etc.) to attach to this module.',
                      ),
                      const SizedBox(height: 10),
                      FileUploadBox(
                        onSelectFile: controller.pickFile,
                        onUploadFile: controller.pickFile,
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() {
                if (controller.files.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attached Files',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: controller.files.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final file = controller.files[index];
                        return UploadedFileTile(file: file, controller: controller);
                      },
                    ),
                  ],
                );
              }),
              // Text(
              //   'or Upload via URL',
              //   style: getTextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.w500,
              //     color: AppColors.primaryTextColor,
              //   ),
              // ),
              // UploadUrlField(
              //   controller: controller.addModuleUrlController,
              //   onUpload: () {
              //     if (controller.addModuleUrlController.text.isNotEmpty) {
              //       controller.addModuleUrlController.clear();
              //     }
              //   },
              // ),
              const SizedBox(height: 20),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isCreatingModule.value
                      ? null
                      : controller.saveModule,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    controller.isCreatingModule.value
                        ? controller.isEditingModule
                              ? 'Updating Module...'
                              : 'Creating Module...'
                        : controller.isEditingModule
                        ? 'Update Module'
                        : 'Create Module',
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder getOutlineInputBorder() =>
    const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey));
