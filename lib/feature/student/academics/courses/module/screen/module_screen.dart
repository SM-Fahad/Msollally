// module_screen.dart
import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/student/academics/courses/classDetail/screen/class_detail_screen.dart';
import 'package:msollaally/core/utils/file_viewer_helper.dart';

import '../controller/module_controller.dart';
import '../model/module_model.dart';

class ModuleScreen extends StatelessWidget {
  final int? courseId;

  const ModuleScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ModuleController(courseId: courseId),
      tag: 'student-module-$courseId',
    );

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              controller.errorMessage.value!,
              style: getTextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      if (controller.modules.isEmpty) {
        return Center(
          child: Text(
            'No modules found.',
            style: getTextStyle(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: controller.modules.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  "Course Modules",
                  style: getTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(),
                SizedBox(height: 20),
              ],
            );
          } else {
            final module = controller.modules[index - 1];
            return ModuleCard(
              module: module,
              controllerTag: 'student-module-$courseId',
              isFirst: index == 1,
            );
          }
        },
      );
    });
  }
}

class ModuleCard extends StatelessWidget {
  final ModuleModel module;
  final String controllerTag;
  final bool isFirst;

  const ModuleCard({
    super.key,
    required this.module,
    required this.controllerTag,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ModuleController>(tag: controllerTag)
        ? Get.find<ModuleController>(tag: controllerTag)
        : null;

    return Obx(() {
      final isExpanded =
          controller?.isModuleExpanded(module.title, defaultVal: isFirst) ??
              isFirst;

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        elevation: 0.5,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Collapsible Header row
              InkWell(
                onTap: () {
                  controller?.toggleModuleExpanded(
                    module.title,
                    defaultVal: isFirst,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          module.title,
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (module.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  module.description,
                  style: getTextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              /// Progress bar
              LinearProgressIndicator(
                value: module.progress,
                color: module.progress == 1.0
                    ? Colors.green
                    : (module.progress > 0 ? Colors.blue : Colors.grey),
                backgroundColor: Colors.grey.shade200,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    module.progress == 1.0
                        ? "Completed"
                        : module.progress == 0
                            ? "Not Started"
                            : "In Progress",
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: module.progress == 1.0
                          ? Colors.green
                          : (module.progress > 0 ? Colors.blue : Colors.grey),
                    ),
                  ),
                  Text(
                    '${(module.progress * 100).toInt()}%',
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              if (isExpanded) ...[
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 8),

                /// Files Row
                if (module.files.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.attach_file_rounded,
                        size: 16,
                        color: AppColors.primaryButtonColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Materials & Files (${module.files.length}):",
                        style: getTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: module.files
                          .map(
                            (file) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => openCourseFile(
                                  context,
                                  url: file.url,
                                  name: file.name,
                                  type: file.displayType,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getFileIcon(file.displayType),
                                        color: Colors.redAccent,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 140,
                                        ),
                                        child: Text(
                                          file.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: getTextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                /// Classes List or Empty Placeholder
                if (module.classes.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 16,
                        color: AppColors.primaryButtonColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Classes (${module.classes.length}):",
                        style: getTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: module.classes
                        .map(
                          (classItem) => GestureDetector(
                            onTap: () {
                              _navigateToClassDetail(
                                context,
                                module,
                                classItem,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: classItem.status == "Completed"
                                      ? Colors.green.shade200
                                      : classItem.status == "In Progress"
                                          ? Colors.blue.shade200
                                          : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          classItem.title,
                                          style: getTextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (classItem.status ==
                                                          "Completed"
                                                      ? Colors.green
                                                      : classItem.status ==
                                                              "In Progress"
                                                          ? Colors.blue
                                                          : Colors.grey)
                                                  .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          classItem.status,
                                          style: getTextStyle(
                                            fontSize: 11,
                                            color: classItem.status ==
                                                    "Completed"
                                                ? Colors.green
                                                : classItem.status ==
                                                        "In Progress"
                                                    ? Colors.blue
                                                    : Colors.grey.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (classItem.time.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          classItem.time,
                                          style: getTextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (classItem.location.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.room_rounded,
                                          size: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          classItem.location,
                                          style: getTextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],

                if (module.classes.isEmpty && module.files.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No classes or materials uploaded for this module yet.',
                            style: getTextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      );
    });
  }

  IconData _getFileIcon(String type) {
    switch (type) {
      case "pdf":
        return Icons.picture_as_pdf;
      case "doc":
        return Icons.description;
      case "img":
        return Icons.image;
      case "video":
        return Icons.play_circle;
      case "ppt":
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _navigateToClassDetail(
    BuildContext context,
    ModuleModel module,
    ClassModel classItem,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassDetailScreen(module: module, classItem: classItem),
      ),
    );
  }
}
