import 'dart:io';
import 'package:msollaally/core/const/appcolors.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/custom_textfield.dart';
import 'package:msollaally/feature/teacher/courses/controller/course_controller.dart';

class TeacherAddCourseScreen extends StatelessWidget {
  TeacherAddCourseScreen({super.key}) {
    controller = Get.isRegistered<CourseScreenController>()
        ? Get.find<CourseScreenController>()
        : Get.put(CourseScreenController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prepareCourseForm(Get.arguments);
    });
  }

  late final CourseScreenController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.clearCourseForm();
                      Get.back();
                    },
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.isEditingCourse ? "Edit Course" : "Add Course",
                    style: getTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Divider(height: 1, color: Colors.grey[300]),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(
                      "Course settings",
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Title',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: controller.addCourseTitleController,
                            hintText: 'Course Title',
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            controller.isPublic.value = !controller.isPublic.value;
                          },
                          child: Obx(() {
                            final bool isPublic = controller.isPublic.value;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isPublic ? Colors.blue : Colors.grey[400],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isPublic) ...[
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Public",
                                      style: getTextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      "Private",
                                      style: getTextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    Text(
                      'Course Code',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    CustomTextField(
                      controller: controller.addCourseCodeController,
                      hintText: '',
                    ),
                    Text(
                      'Start Date',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextField(
                      controller: controller.addCourseStartDateController,
                      readOnly: true,
                      decoration: _dateDecoration(
                        hintText: 'Select start date',
                        onTap: () => controller.pickCourseDate(isStart: true),
                      ),
                    ),
                    Text(
                      'End Date',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextField(
                      controller: controller.addCourseEndDateController,
                      readOnly: true,
                      decoration: _dateDecoration(
                        hintText: 'Select end date',
                        onTap: () => controller.pickCourseDate(isStart: false),
                      ),
                    ),
                    Text(
                      'Description',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    CustomTextField(
                      controller: controller.addCourseDescriptionController,
                      hintText:
                          'Course description (optional)',
                      maxLines: 7,
                    ),
                    Text(
                      'Cover Image',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Obx(() {
                      final File? imageFile =
                          controller.selectedCoverImage.value;
                      final String imageUrl =
                          controller.currentCoverImageUrl.value;
                      final bool isBusy =
                          controller.isSubmitting.value ||
                          controller.isUploadingImage.value;
                      final bool hasExistingImage = imageUrl.trim().isNotEmpty;

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            if (imageFile != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  imageFile,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else if (hasExistingImage)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _imagePlaceholder(),
                                ),
                              )
                            else
                              _imagePlaceholder(),
                            Row(
                              spacing: 12,
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryButtonColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: isBusy
                                        ? null
                                        : controller.pickCoverImage,
                                    icon: const Icon(Icons.upload_outlined),
                                    label: Text(
                                      imageFile == null && !hasExistingImage
                                          ? 'Select image'
                                          : 'Replace image',
                                    ),
                                  ),
                                ),
                                if (imageFile != null)
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: isBusy
                                        ? null
                                        : controller.removeCoverImage,
                                    child: const Text('Remove'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Obx(() {
                final bool isBusy =
                    controller.isSubmitting.value ||
                    controller.isUploadingImage.value;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isBusy ? null : controller.saveCourse,
                    child: Text(
                      controller.isSubmitting.value
                          ? controller.isEditingCourse
                                ? "Updating..."
                                : "Creating..."
                          : controller.isEditingCourse
                          ? "Update Course"
                          : "Create Course",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dateDecoration({
    required String hintText,
    required VoidCallback onTap,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: getTextStyle(color: Colors.grey),
      border: _outlineInputBorder(),
      focusedBorder: _outlineInputBorder(),
      disabledBorder: _outlineInputBorder(),
      enabledBorder: _outlineInputBorder(),
      suffixIcon: IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.calendar_month_outlined),
      ),
    );
  }

  OutlineInputBorder _outlineInputBorder() =>
      const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey));

  Widget _imagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.ghostWhiteF8FAFF,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 42,
            color: Colors.blue.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 10),
          Text(
            'Upload a course cover from your device',
            style: getTextStyle(
              color: Colors.grey[700]!,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The selected image will be uploaded before saving the course.',
            textAlign: TextAlign.center,
            style: getTextStyle(fontSize: 12, color: Colors.grey[500]!),
          ),
        ],
      ),
    );
  }
}
