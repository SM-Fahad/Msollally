import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/services/device_download_service.dart';
import 'package:msollaally/core/utils/device/device_utility.dart';
import 'package:msollaally/feature/teacher/courses/course_assesment/controller/course_assesment_controller.dart';
import 'package:msollaally/feature/teacher/courses/course_assesment/widget/teacher_assessment_submissions_section.dart';
import 'package:msollaally/feature/teacher/courses/course_module/screen/add_module_screen.dart';
import 'package:msollaally/feature/teacher/courses/course_module/widget/file_icon.dart';
import 'package:msollaally/feature/teacher/widgets/teacher_custom_text_field.dart';

class TeachersAssesmentDetailScreen extends StatelessWidget {
  TeachersAssesmentDetailScreen({super.key}) {
    controller = Get.isRegistered<CourseAssessmentController>()
        ? Get.find<CourseAssessmentController>()
        : Get.put(CourseAssessmentController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prepareAssessmentDetails(Get.arguments);
    });
  }

  late final CourseAssessmentController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assesment Details'),
        centerTitle: false,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () => _showEditAssessmentSheet(context),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: _confirmDeleteAssessment,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Obx(() {
        final assessment = controller.currentAssessment.value;
        if (controller.isLoadingAssessmentDetails.value && assessment == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (assessment == null) {
          return Center(
            child: Text(
              'Assessment details not found',
              style: getTextStyle(fontSize: 15, color: Colors.grey[600]!),
            ),
          );
        }

        final dueDate = _parseDateTime(assessment['dueDate']);
        final course = _asMap(assessment['course']);
        final creator = _asMap(assessment['creator']);

        return RefreshIndicator(
          onRefresh: controller.fetchAssessmentDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    (assessment['title'] ?? 'Assessment').toString(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(assessment['type'] ?? '').toString()} • ${(assessment['questionFormat'] ?? '').toString().replaceAll('_', ' ')}',
                    style: getTextStyle(color: Colors.grey[700]!),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DetailBlock(
                        title: 'Due Date',
                        lines: [_formatDate(dueDate), _formatTime(dueDate)],
                      ),
                      _DetailBlock(
                        title: 'Location',
                        lines: [
                          (assessment['classroom'] ?? 'TBA').toString(),
                          (course['title'] ?? '').toString(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DetailBlock(
                        title: 'Total Marks',
                        lines: ['${assessment['totalMarks'] ?? 0}'],
                      ),
                      _DetailBlock(
                        title: 'Created By',
                        lines: [
                          (creator['username'] ?? 'Unknown').toString(),
                          _formatDate(_parseDateTime(assessment['createdAt'])),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Notes',
                    style: getTextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  NoteCard(
                    title: 'Assessment Notes',
                    content: (assessment['notes'] ?? 'No notes provided.')
                        .toString(),
                  ),
                  const SizedBox(height: 24),
                  TeacherAssessmentSubmissionsSection(controller: controller),
                  const SizedBox(height: 24),
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
                      Obx(
                        () => InkWell(
                          onTap: controller.isUploadingAssessmentFile.value
                              ? null
                              : controller.pickAndUploadAssessmentFile,
                          child: CircleAvatar(
                            backgroundColor:
                                controller.isUploadingAssessmentFile.value
                                ? Colors.grey
                                : Colors.blue,
                            child: controller.isUploadingAssessmentFile.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    if (controller.assessmentFiles.isEmpty) {
                      return const Center(child: Text('No files added yet'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.assessmentFiles.length,
                      itemBuilder: (context, index) {
                        final file = controller.assessmentFiles[index];
                        return _AssessmentFileTile(
                          file: file,
                          onOpen: () => _openAssessmentFile(file),
                          onDownload: () => _downloadAssessmentFile(file),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _confirmDeleteAssessment() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete assessment'),
        content: const Text(
          'Delete this assessment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final deleted = await controller.deleteAssessment();
    if (deleted) {
      Get.back(result: true);
    }
  }

  Future<void> _showEditAssessmentSheet(BuildContext context) async {
    controller.prepareEditAssessmentForm();
    await Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit Assessment',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Title',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: Colors.grey),
                ),
                TeacherCustomTextField(
                  controller: controller.examTitleController,
                  hintText: 'Assessment title',
                ),
                const SizedBox(height: 10),
                Text(
                  'Classroom',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: Colors.grey),
                ),
                TeacherCustomTextField(
                  controller: controller.classroomController,
                  hintText: 'Room 301',
                ),
                const SizedBox(height: 10),
                Text(
                  'Assessment Type',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: Colors.grey),
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
                    items: controller.assessmentTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(controller.formatLabel(value)),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      controller.selectedAssessmentType.value = value;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Total Marks',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: Colors.grey),
                ),
                TeacherCustomTextField(
                  controller: controller.totalMarksController,
                  hintText: '100',
                ),
                const SizedBox(height: 10),
                Text(
                  'Question Format',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: Colors.grey),
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
                    items: controller.questionFormats.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(controller.formatLabel(value)),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      controller.selectedQuestionFormat.value = value;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Notes',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: Colors.grey),
                ),
                TextField(
                  controller: controller.notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Assessment notes',
                    border: getOutlineInputBorder(),
                    focusedBorder: getOutlineInputBorder(),
                    disabledBorder: getOutlineInputBorder(),
                    enabledBorder: getOutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Due Date',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: Colors.grey),
                ),
                TextField(
                  controller: controller.dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select date',
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
                const SizedBox(height: 18),
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isUpdatingAssessment.value
                        ? null
                        : () async {
                            final updated = await controller
                                .updateAssessmentDetails();
                            if (updated) {
                              Get.back();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      controller.isUpdatingAssessment.value
                          ? 'Updating Assessment...'
                          : 'Update Assessment',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw)?.toLocal();
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'Not scheduled';
    }
    return DateFormat('EEE, MMM d, yyyy').format(value);
  }

  String _formatTime(DateTime? value) {
    if (value == null) {
      return '';
    }
    return DateFormat('hh:mm a').format(value);
  }

  Future<void> _openAssessmentFile(dynamic file) async {
    final url = file.fileUrl?.toString() ?? '';
    if (url.isEmpty) {
      EasyLoading.showError('File URL not found.');
      return;
    }
    AppDeviceUtility.launchUrl(url);
  }

  Future<void> _downloadAssessmentFile(dynamic file) async {
    final url = file.fileUrl?.toString() ?? '';
    final name = file.name?.toString();
    final mimeType = file.mimeType?.toString();
    await _downloadRemoteFile(url, fileName: name, mimeType: mimeType);
  }

  Future<void> _downloadRemoteFile(
    String url, {
    String? fileName,
    String? mimeType,
  }) async {
    if (url.isEmpty) {
      EasyLoading.showError('File URL not found.');
      return;
    }

    EasyLoading.show(status: 'Downloading file...');
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Failed to download file.');
      }

      final resolvedName = _resolveDownloadFileName(url, fileName: fileName);
      final tempPath =
          '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}_$resolvedName';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(response.bodyBytes, flush: true);

      final locationLabel = await DeviceDownloadService.saveToDownloads(
        sourcePath: tempFile.path,
        fileName: resolvedName,
        mimeType: mimeType ?? _mimeTypeFromFileName(resolvedName),
      );

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Saved to $locationLabel');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError(_cleanError(e));
    }
  }

  String _resolveDownloadFileName(String url, {String? fileName}) {
    final trimmed = fileName?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      return trimmed;
    }

    final uri = Uri.tryParse(url);
    final fromPath = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : url.split('/').last;
    final cleaned = fromPath.split('?').first.trim();
    return cleaned.isEmpty ? 'attachment' : cleaned;
  }

  String _mimeTypeFromFileName(String fileName) {
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'csv':
        return 'text/csv';
      default:
        return 'application/octet-stream';
    }
  }

  String _cleanError(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final visibleLines = lines.where((line) => line.trim().isNotEmpty).toList();
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          ...visibleLines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(line, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final String title;
  final String content;

  const NoteCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber.withAlpha(200)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.amber[50],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(title, style: getTextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_drop_down),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(content.isEmpty ? 'No notes provided.' : content),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentFileTile extends StatelessWidget {
  const _AssessmentFileTile({
    required this.file,
    required this.onOpen,
    required this.onDownload,
  });

  final dynamic file;
  final VoidCallback onOpen;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: FileIcon(type: file.fileType as String),
      title: Text(file.name.toString(), overflow: TextOverflow.ellipsis),
      subtitle: file.mimeType.toString().isEmpty
          ? null
          : Text(file.mimeType.toString()),
      onTap: onOpen,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onDownload,
            icon: const Icon(Icons.download_outlined),
          ),
          IconButton(onPressed: onOpen, icon: const Icon(Icons.open_in_new)),
        ],
      ),
    );
  }
}
