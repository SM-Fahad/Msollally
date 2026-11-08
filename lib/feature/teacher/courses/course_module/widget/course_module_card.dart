import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/routes/app_route.dart';
import '../controller/course_module_controller.dart';
import '../model/course_module_model.dart';
import 'class_card.dart';
import 'file_icon.dart';

class ModuleCard extends StatelessWidget {
  final CourseModule module;
  final CourseModuleController controller;

  const ModuleCard({super.key, required this.module, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      const isExpanded = true;
      final isLoadingDetails = controller.isLoadingModuleDetails(module.id);
      final isUploadingModuleFile = controller.isUploadingModuleFile(module.id);
      final isUpdatingProgress = controller.isUpdatingModuleProgress(module.id);

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      module.title,
                      style: getTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (isLoadingDetails)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    PopupMenuButton<_ModuleCardAction>(
                      onSelected: (value) async {
                        switch (value) {
                          case _ModuleCardAction.edit:
                            await Get.toNamed(
                              AppRoute.teacherAddModuleScreen,
                              arguments: {
                                'courseId':
                                    controller.selectedCourse.value?.id,
                                'courseTitle':
                                    controller.selectedCourse.value?.title,
                                  'module': module,
                                },
                              );
                              await controller.refreshModules();
                              break;
                            case _ModuleCardAction.delete:
                              await controller.confirmDeleteModule(module);
                              break;
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _ModuleCardAction.edit,
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: _ModuleCardAction.delete,
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                  ],
                ),
              if (module.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  module.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(fontSize: 13, color: Colors.grey[700]!),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Files: '),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (module.files.isEmpty)
                          Text(
                            'No files',
                            style: getTextStyle(
                              fontSize: 12,
                              color: Colors.grey[600]!,
                            ),
                          )
                        else
                          ...module.files.map(
                            (file) => _buildModuleFileChip(file),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: isUploadingModuleFile
                        ? null
                        : () => controller.pickFileForModule(module),
                    tooltip: 'Add file',
                    icon: isUploadingModuleFile
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primaryButtonColor,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Created: ${_formatDate(module.createdAt)}',
                style: getTextStyle(color: Colors.grey[600]!, fontSize: 12),
              ),
              if (module.startDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Start date: ${_formatDate(module.startDate)}',
                  style: getTextStyle(color: Colors.grey[600]!, fontSize: 12),
                ),
              ],
              const SizedBox(height: 8),
              if (!module.isCompleted) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'In Progress',
                        style: getTextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: isUpdatingProgress
                          ? null
                          : () => _showProgressUpdateDialog(context),
                      icon: isUpdatingProgress
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.edit_outlined, size: 16),
                      label: Text(
                        isUpdatingProgress ? 'Saving...' : 'Update',
                        style: getTextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  minHeight: 8,
                  value: (module.progress / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${module.progress.toInt()}%',
                    style: getTextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
              ] else ...[
                Text(
                  'Completed',
                  style: getTextStyle(color: Colors.green, fontSize: 12),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: 1,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('100%', style: getTextStyle(fontSize: 12)),
                ),
              ],
              if (isExpanded) ...[
                const SizedBox(height: 8),
                if (module.classes.isEmpty)
                  Text(
                    'No classes found for this module',
                    style: getTextStyle(fontSize: 13, color: Colors.grey[600]!),
                  )
                else
                  ...module.classes.map(
                    (courseClass) => InkWell(
                      onTap: () {
                        Get.toNamed(
                          AppRoute.teacherClassDetailScreen,
                          arguments: {
                            'module': module,
                            'class': courseClass,
                            'courseId': controller.selectedCourse.value?.id,
                            'courseTitle':
                                controller.selectedCourse.value?.title,
                          },
                        );
                      },
                      child: ClassCard(
                        courseClass: courseClass,
                        module: module,
                        controller: controller,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Get.toNamed(
                          AppRoute.teacherAddModuleClassScreen,
                          arguments: {
                            'module': module,
                            'courseId': controller.selectedCourse.value?.id,
                            'courseTitle':
                                controller.selectedCourse.value?.title,
                          },
                        );
                      },
                      icon: Icon(
                        Icons.add_circle_outline_outlined,
                        color: AppColors.primaryButtonColor,
                      ),
                      label: Text(
                        'Add Class',
                        style: getTextStyle(
                          fontSize: 14,
                          color: AppColors.primaryButtonColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        side: BorderSide(
                          width: 2,
                          color: Colors.blue.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.blue.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'N/A';
    return DateFormat('MMM d, yyyy').format(value);
  }

  Widget _buildModuleFileChip(ModuleFile file) {
    final isDeleting = controller.isDeletingModuleFile(file.id);
    final label = file.name.isEmpty ? file.fileType.toUpperCase() : file.name;

    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FileIcon(type: file.fileType),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getTextStyle(fontSize: 12),
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              tooltip: 'Delete file',
              onPressed: isDeleting || file.id == 0
                  ? null
                  : () => controller.confirmDeleteModuleFile(
                      module: module,
                      file: file,
                    ),
              icon: isDeleting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.close, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showProgressUpdateDialog(BuildContext context) async {
    final progressController = TextEditingController(
      text: module.progress.toInt().toString(),
    );

    await Get.dialog(
      AlertDialog(
        title: const Text('Update progress'),
        content: TextField(
          controller: progressController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Progress',
            hintText: 'Enter 0 to 100',
            suffixText: '%',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final parsedValue = double.tryParse(
                progressController.text.trim(),
              );
              if (parsedValue == null || parsedValue < 0 || parsedValue > 100) {
                Get.snackbar(
                  'Invalid progress',
                  'Progress must be a number between 0 and 100.',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back();
              await controller.updateModuleProgress(
                module: module,
                progress: parsedValue,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

enum _ModuleCardAction { edit, delete }
