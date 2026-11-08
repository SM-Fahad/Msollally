import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/courses/course_module/controller/course_module_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_module/widget/class_detail_file_tile.dart';

class TeachersClassDetailScreen extends StatelessWidget {
  TeachersClassDetailScreen({super.key}) {
    controller = Get.isRegistered<CourseModuleController>()
        ? Get.find<CourseModuleController>()
        : Get.put(CourseModuleController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prepareClassDetails(Get.arguments);
    });
  }

  late final CourseModuleController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Details'),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            controller.clearClassDetails();
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingClassDetails.value &&
            controller.currentViewingClass.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final courseClass = controller.currentViewingClass.value;
        if (courseClass == null) {
          return const Center(child: Text('Class details not found'));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                if (controller.isLoadingClassDetails.value)
                  const LinearProgressIndicator(),
                Text(
                  courseClass.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _DetailBlock(
                        title: 'Date & Time',
                        lines: [
                          _formatDate(courseClass.startTime),
                          courseClass.time,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _DetailBlock(
                        title: 'Location',
                        lines: [courseClass.classroom],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Topics',
                  style: getTextStyle(fontWeight: FontWeight.bold),
                ),
                if (courseClass.topics.isEmpty && courseClass.topic.isEmpty)
                  const Text('No topics added')
                else ...[
                  if (courseClass.topics.isNotEmpty)
                    ...courseClass.topics.map((topic) => Text('• $topic'))
                  else
                    Text('• ${courseClass.topic}'),
                ],
                const SizedBox(height: 5),
                Text('Notes', style: getTextStyle(fontWeight: FontWeight.bold)),
                Text(
                  courseClass.notes.isEmpty
                      ? 'No notes added'
                      : courseClass.notes,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Files',
                        style: getTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(color: Colors.blue.shade50, height: 2),
                    ),
                    InkWell(
                      onTap: controller.isUploadingClassFile.value
                          ? null
                          : controller.pickFileForClassDetail,
                      child: CircleAvatar(
                        backgroundColor: controller.isUploadingClassFile.value
                            ? Colors.grey
                            : Colors.blue,
                        child: controller.isUploadingClassFile.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (controller.classFiles.isEmpty)
                  const Center(child: Text('No files added yet'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.classFiles.length,
                    itemBuilder: (context, index) {
                      final file = controller.classFiles[index];
                      return FileTile(file: file);
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'Not scheduled';
    }
    return DateFormat('EEE, MMM d, yyyy').format(value.toLocal());
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        ...lines.map(
          (line) => Text(line, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
