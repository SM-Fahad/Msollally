import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/teacher/courses/course_module/controller/course_module_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_module/widget/file_upload_box.dart';
import 'package:msollaally/feature/teacher/courses/course_module/widget/uploaded_file_tile.dart';
import 'package:msollaally/feature/teacher/widgets/teacher_custom_text_field.dart';

class AddModuleClassScreen extends StatelessWidget {
  AddModuleClassScreen({super.key}) {
    controller = Get.isRegistered<CourseModuleController>()
        ? Get.find<CourseModuleController>()
        : Get.put(CourseModuleController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prepareClassForm(Get.arguments);
    });
  }

  late final CourseModuleController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.currentModule.value?.title.isNotEmpty == true
                ? controller.currentModule.value!.title
                : 'Create Class',
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            controller.clearClassForm();
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Create Class',
              style: Theme.of(context).textTheme.titleLarge!,
            ),
            const SizedBox(height: 5),
            _FieldLabel(label: 'Title'),
            TeacherCustomTextField(
              controller: controller.classTitleController,
              hintText: 'Enter class title',
            ),
            _FieldLabel(label: 'Classroom'),
            TeacherCustomTextField(
              controller: controller.classClassroomController,
              hintText: 'Enter classroom',
            ),
            _FieldLabel(label: 'Topic'),
            TeacherCustomTextField(
              controller: controller.classTopicController,
              hintText: 'Enter main topic',
            ),
            _FieldLabel(label: 'Topics'),
            TextField(
              controller: controller.classTopicsController,
              decoration: _inputDecoration('Comma separated topics'),
            ),
            _FieldLabel(label: 'Notes'),
            TextField(
              controller: controller.classNoteController,
              maxLines: 4,
              decoration: _inputDecoration('Enter class notes'),
            ),
            _FieldLabel(label: 'Date'),
            TextField(
              controller: controller.classDateController,
              readOnly: true,
              decoration: _inputDecoration(
                'Select date',
                suffixIcon: IconButton(
                  onPressed: controller.pickClassDate,
                  icon: const Icon(Icons.calendar_month),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'Start Time',
                    controller: controller.startClassController,
                    onTap: () => controller.pickClassTime(isStart: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TimeField(
                    label: 'End Time',
                    controller: controller.endClassController,
                    onTap: () => controller.pickClassTime(isStart: false),
                  ),
                ),
              ],
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
                    const Text('Choose a file (PDF, PPT, DOCS, XLSX, etc.) to attach to this class.'),
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
            Obx(
              () => ElevatedButton(
                onPressed: controller.isSavingClass.value
                    ? null
                    : controller.createClass,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  controller.isSavingClass.value
                      ? 'Creating Class...'
                      : 'Create Class',
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleMedium!.copyWith(color: Colors.grey),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.controller,
    required this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        _FieldLabel(label: label),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: _inputDecoration(
            'Select time',
            filled: true,
            fillColor: Colors.grey[200],
            suffixIcon: IconButton(
              onPressed: onTap,
              icon: const Icon(Icons.access_time),
            ),
          ),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration(
  String hintText, {
  Widget? suffixIcon,
  bool filled = false,
  Color? fillColor,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: getTextStyle(color: Colors.grey),
    border: _outlineInputBorder(),
    focusedBorder: _outlineInputBorder(),
    disabledBorder: _outlineInputBorder(),
    enabledBorder: _outlineInputBorder(),
    suffixIcon: suffixIcon,
    filled: filled,
    fillColor: fillColor,
  );
}

OutlineInputBorder _outlineInputBorder() =>
    const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey));
