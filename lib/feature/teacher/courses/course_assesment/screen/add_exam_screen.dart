import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/teacher/courses/course_assesment/controller/course_assesment_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_module/screen/add_module_screen.dart';
import 'package:msollaally/feature/teacher/courses/course_module/widget/file_upload_box.dart';
import 'package:msollaally/feature/teacher/courses/course_module/widget/uploaded_file_tile.dart';
import 'package:msollaally/feature/teacher/widgets/teacher_custom_text_field.dart';

class AddAssesmentExamScreen extends StatelessWidget {
  AddAssesmentExamScreen({super.key}) {
    controller = Get.isRegistered<CourseAssessmentController>()
        ? Get.find<CourseAssessmentController>()
        : Get.put(CourseAssessmentController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prepareCreateAssessment(Get.arguments);
    });
  }

  late final CourseAssessmentController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assesment"),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            controller.clearCreateAssessmentForm();
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  controller.currentCourseTitle.value.isNotEmpty
                      ? 'Create assessment for ${controller.currentCourseTitle.value}'
                      : 'Create assessment',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                'Exam Title',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              TeacherCustomTextField(
                controller: controller.examTitleController,
                hintText: "Exam title",
              ),
              Text(
                'Classroom',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              TeacherCustomTextField(
                controller: controller.classroomController,
                hintText: "Room Number",
              ),
              Text(
                'Exam Type',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: controller.selectedAssessmentType.value,
                  decoration: InputDecoration(
                    border: getOutlineInputBorder(),
                    focusedBorder: getOutlineInputBorder(),
                    disabledBorder: getOutlineInputBorder(),
                    enabledBorder: getOutlineInputBorder(),
                  ),
                  hint: Text(
                    'Select assessment type',
                    style: getTextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  items: controller.assessmentTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(controller.formatLabel(value)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    controller.selectedAssessmentType.value = newValue;
                  },
                ),
              ),
              Text(
                'Total Marks',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              TeacherCustomTextField(
                controller: controller.totalMarksController,
                hintText: "e.g. 100",
              ),
              Text(
                'Question Format',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: controller.selectedQuestionFormat.value,
                  decoration: InputDecoration(
                    border: getOutlineInputBorder(),
                    focusedBorder: getOutlineInputBorder(),
                    disabledBorder: getOutlineInputBorder(),
                    enabledBorder: getOutlineInputBorder(),
                  ),
                  hint: Text(
                    'Select question format',
                    style: getTextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  items: controller.questionFormats.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(controller.formatLabel(value)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    controller.selectedQuestionFormat.value = newValue;
                  },
                ),
              ),
              Text(
                'Notes',
               style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              TeacherCustomTextField(
                controller: controller.notesController,
                hintText: "Additional notes (optional)",
              ),
              Text(
                'Date',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryTextColor,
                ),
              ),
              TextField(
                controller: controller.dateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Select date",
                  hintStyle: getTextStyle(color: Colors.grey),
                  border: getOutlineInputBorder(),
                  focusedBorder: getOutlineInputBorder(),
                  disabledBorder: getOutlineInputBorder(),
                  enabledBorder: getOutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.pickDateTime();
                    },
                    icon: Icon(Icons.calendar_month),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                        'Choose a file (PDF, PPT, DOCS, XLSX, etc.) to attach to this assessment.',
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
                        return UploadedFileTile(
                          file: file,
                          controller: controller,
                        );
                      },
                    ),
                  ],
                );
              }),
              const SizedBox(height: 12),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isCreatingAssessment.value
                      ? null
                      : controller.createAssessment,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    controller.isCreatingAssessment.value
                        ? "Creating Assessment..."
                        : "Create Assessment",
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
