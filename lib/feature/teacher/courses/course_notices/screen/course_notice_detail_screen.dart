import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/feature/teacher/courses/course_notices/controller/course_notice_controller.dart';
import 'package:msollaally/feature/teacher/widgets/teacher_custom_text_field.dart';

class CourseNoticeDetailScreen extends StatelessWidget {
  CourseNoticeDetailScreen({super.key}) {
    controller = Get.isRegistered<CourseNoticeController>()
        ? Get.find<CourseNoticeController>()
        : Get.put(CourseNoticeController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prepareNoticeDetails(Get.arguments);
    });
  }

  late final CourseNoticeController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Details'),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            controller.clearCurrentNotice();
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.isDeletingNotice.value
                  ? null
                  : controller.deleteNotice,
              icon: controller.isDeletingNotice.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingNoticeDetails.value &&
            controller.currentNotice.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final notice = controller.currentNotice.value;
        if (notice == null) {
          return const Center(child: Text('Notice not found'));
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                if (controller.isLoadingNoticeDetails.value)
                  const LinearProgressIndicator(),
                Text(
                  _formatDate(notice.createdAt),
                  style: getTextStyle(fontSize: 13, color: Colors.black54),
                ),
                Text(
                  'Title',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: Colors.grey),
                ),
                TeacherCustomTextField(
                  controller: controller.titleController,
                  hintText: 'Class Rescheduled',
                ),
                Text(
                  'Notice',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: Colors.grey),
                ),
                TextField(
                  maxLines: 8,
                  controller: controller.noticeController,
                  decoration: InputDecoration(
                    hintText:
                        'Tomorrow class will start at 11 AM instead of 10 AM',
                    hintStyle: getTextStyle(color: Colors.grey),
                    border: _outlineInputBorder(),
                    focusedBorder: _outlineInputBorder(),
                    disabledBorder: _outlineInputBorder(),
                    enabledBorder: _outlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 36),
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isSavingNotice.value
                        ? null
                        : controller.updateNotice,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: controller.isSavingNotice.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Update Notice'),
                  ),
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
      return 'Created date unavailable';
    }
    return DateFormat('EEE, MMM d, yyyy hh:mm a').format(value.toLocal());
  }
}

OutlineInputBorder _outlineInputBorder() => OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide(color: Colors.blue.withValues(alpha: 0.5), width: 2),
);
