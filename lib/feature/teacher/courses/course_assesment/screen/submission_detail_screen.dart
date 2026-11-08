import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/services/device_download_service.dart';
import 'package:msollaally/core/utils/device/device_utility.dart';
import 'package:msollaally/feature/teacher/courses/course_assesment/controller/course_assesment_controller.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class TeacherSubmissionDetailScreen extends StatelessWidget {
  const TeacherSubmissionDetailScreen({
    super.key,
    required this.controller,
    required this.submissionId,
  });

  final CourseAssessmentController controller;
  final int submissionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Submission')),
      body: Obx(() {
        final submission = _findSubmission();
        if (submission == null) {
          return Center(
            child: Text(
              'Submission not found.',
              style: getTextStyle(color: Colors.grey[700]!),
            ),
          );
        }

        final studentName = (submission['studentName'] ?? 'Student').toString();
        final status = (submission['status'] ?? 'submitted').toString();
        final submittedDateLabel =
            (submission['submittedDateLabel'] ?? 'Not submitted yet')
                .toString();
        final marks = submission['marks'];
        final feedback = (submission['feedback'] ?? '').toString();
        final files = submission['files'] is List
            ? List<Map<String, dynamic>>.from(
                (submission['files'] as List).whereType<Map>().map(
                  (item) => Map<String, dynamic>.from(item),
                ),
              )
            : const <Map<String, dynamic>>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: getTextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Status: $status', style: getTextStyle()),
                const SizedBox(height: 4),
                Text(
                  submittedDateLabel,
                  style: getTextStyle(color: Colors.grey[700]!),
                ),
                if (marks != null) ...[
                  const SizedBox(height: 8),
                  Text('Marks: $marks', style: getTextStyle()),
                ],
                if (feedback.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Feedback: $feedback', style: getTextStyle()),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => _showGradeSubmissionSheet(submission),
                    icon: const Icon(Icons.grading_outlined),
                    label: Text(marks == null ? 'Grade' : 'Update Grade'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Submitted Files',
                  style: getTextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (files.isEmpty)
                  Text(
                    'No files submitted.',
                    style: getTextStyle(color: Colors.grey[700]!),
                  )
                else
                  ...files.map(_buildSubmissionFileTile),
              ],
            ),
          ),
        );
      }),
    );
  }

  Map<String, dynamic>? _findSubmission() {
    for (final item in controller.assessmentSubmissions) {
      if (_toInt(item['id']) == submissionId) {
        return item;
      }
    }
    return null;
  }

  Future<void> _openSubmissionFile(Map<String, dynamic> file) async {
    final url = (file['fileUrl'] ?? file['url'] ?? '').toString();
    if (url.isEmpty) {
      EasyLoading.showError('File URL not found.');
      return;
    }
    AppDeviceUtility.launchUrl(url);
  }

  Future<void> _downloadSubmissionFile(Map<String, dynamic> file) async {
    final url = (file['fileUrl'] ?? file['url'] ?? '').toString();
    final name = (file['name'] ?? '').toString();
    final mimeType = (file['mimeType'] ?? '').toString();
    await _downloadRemoteFile(
      url,
      fileName: name.isEmpty ? null : name,
      mimeType: mimeType.isEmpty ? null : mimeType,
    );
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

  Future<void> _showGradeSubmissionSheet(
    Map<String, dynamic> submission,
  ) async {
    final marksController = TextEditingController(
      text: submission['marks']?.toString() ?? '',
    );
    final feedbackController = TextEditingController(
      text: (submission['feedback'] ?? '').toString(),
    );

    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grade Submission',
                style: getTextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                (submission['studentName'] ?? 'Student').toString(),
                style: getTextStyle(color: Colors.grey[700]!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: marksController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Marks',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Feedback',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isGradingSubmission.value
                        ? null
                        : () async {
                            final marks = int.tryParse(
                              marksController.text.trim(),
                            );
                            final feedback = feedbackController.text.trim();

                            if (marks == null) {
                              EasyLoading.showError(
                                'Please enter valid marks.',
                              );
                              return;
                            }

                            final success = await controller.gradeSubmission(
                              submissionId: submissionId,
                              marks: marks,
                              feedback: feedback,
                            );
                            if (success) {
                              Get.back();
                            }
                          },
                    child: Text(
                      controller.isGradingSubmission.value
                          ? 'Saving...'
                          : 'Save Grade',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
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

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Widget _buildSubmissionFileTile(Map<String, dynamic> file) {
    final url = (file['fileUrl'] ?? file['url'] ?? '').toString();
    final name = (file['name'] ?? _fileNameFromUrl(url)).toString();
    final extension = _fileExtension(name, url);
    final isImage = _isImageExtension(extension);
    final isPdf = extension == 'pdf';

    if (isImage) {
      return InkWell(
        onTap: url.isEmpty ? null : () => _openSubmissionFile(file),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    url,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 32,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Container(
                        color: Colors.grey.shade100,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 18,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: url.isEmpty
                          ? null
                          : () => _downloadSubmissionFile(file),
                      icon: const Icon(
                        Icons.download_outlined,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.open_in_new, size: 18, color: Colors.blue),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isPdf) {
      return InkWell(
        onTap: url.isEmpty ? null : () => _openSubmissionFile(file),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: SfPdfViewer.network(
                    url,
                    canShowScrollHead: false,
                    canShowScrollStatus: false,
                    pageSpacing: 0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: url.isEmpty
                          ? null
                          : () => _downloadSubmissionFile(file),
                      icon: const Icon(
                        Icons.download_outlined,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.open_in_new, size: 18, color: Colors.blue),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: url.isEmpty ? null : () => _openSubmissionFile(file),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            _SubmissionFileIcon(extension: extension),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getTextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: url.isEmpty
                  ? null
                  : () => _downloadSubmissionFile(file),
              icon: const Icon(
                Icons.download_outlined,
                size: 20,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.open_in_new, size: 18, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  String _fileNameFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final lastSegment = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : url.split('/').last;
    return lastSegment.isEmpty ? 'Attachment' : lastSegment;
  }

  String _fileExtension(String name, String url) {
    final source = name.contains('.') ? name : _fileNameFromUrl(url);
    if (!source.contains('.')) {
      return 'file';
    }
    return source.split('.').last.toLowerCase();
  }

  bool _isImageExtension(String extension) {
    return extension == 'jpg' ||
        extension == 'jpeg' ||
        extension == 'png' ||
        extension == 'webp' ||
        extension == 'gif';
  }
}

class _SubmissionFileIcon extends StatelessWidget {
  const _SubmissionFileIcon({required this.extension});

  final String extension;

  @override
  Widget build(BuildContext context) {
    final iconData = switch (extension) {
      'pdf' => Icons.picture_as_pdf_outlined,
      'jpg' || 'jpeg' || 'png' || 'webp' || 'gif' => Icons.image_outlined,
      'doc' || 'docx' => Icons.description_outlined,
      'mp4' || 'mov' || 'avi' => Icons.smart_display_outlined,
      _ => Icons.insert_drive_file_outlined,
    };

    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.blue.withValues(alpha: 0.08),
      child: Icon(iconData, size: 18, color: Colors.blue),
    );
  }
}
