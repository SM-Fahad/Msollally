import 'package:flutter/material.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/utils/device/device_utility.dart';
import 'package:msollaally/feature/student/academics/courses/assessment/controller/student_assessment_controller.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:msollaally/feature/teacher/courses/course_module/model/course_module_model.dart';

class ExamDetailScreen extends StatelessWidget {
  ExamDetailScreen({
    super.key,
    required this.controller,
    required this.assessmentId,
  }) {
    controller.ensureAssessmentOpened(assessmentId);
  }

  final StudentAssessmentController controller;
  final int assessmentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final title =
              (controller.currentAssessment.value?['title'] ?? 'Assessment')
                  .toString();
          return Text(
            title,
            style: getTextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.openAssessment(assessmentId),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingDetails.value &&
            controller.currentAssessment.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final assessment = controller.currentAssessment.value;
        if (assessment == null) {
          return Center(
            child: Text(
              'Assessment details are unavailable.',
              style: getTextStyle(color: Colors.black54),
            ),
          );
        }

        final files = controller.assessmentFiles(assessment);
        final submission = controller.mySubmission.value;
        final submissionFiles = controller.submissionFileUrls(submission);

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.width),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(
                title: (assessment['title'] ?? 'Assessment').toString(),
                type: (assessment['type'] ?? 'assessment').toString(),
                classroom: (assessment['classroom'] ?? 'TBA').toString(),
                dueDate: controller.dueDateLabel(assessment),
                marks: (assessment['totalMarks'] ?? 0).toString(),
                questionFormat: (assessment['questionFormat'] ?? 'N/A')
                    .toString(),
              ),
              SizedBox(height: 16.height),
              _SectionTitle(title: 'Notes'),
              SizedBox(height: 8.height),
              _BodyCard(
                child: Text(
                  (assessment['notes'] ?? 'No notes provided.').toString(),
                  style: getTextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _SectionTitle(title: 'Assessment Files'),
              
              if (files.isEmpty)
                const _HintCard(
                  message: 'No files attached to this assessment.',
                )
              else
                ...files.map(_buildAssessmentFileTile),
              SizedBox(height: 24.height),
              _SectionTitle(title: 'My Submission'),
             
              if (submission == null)
                const _HintCard(
                  message: 'You have not submitted this assessment yet.',
                )
              else
                Obx(
                  () => _SubmittedCard(
                    content: (submission['content'] ?? '').toString(),
                    submittedAt: (submission['submittedAtLabel'] ?? 'Submitted')
                        .toString(),
                    status: (submission['status'] ?? 'submitted').toString(),
                    marks: (submission['marks'] ?? '').toString(),
                    feedback: (submission['feedback'] ?? '').toString(),
                    gradedBy: (submission['graderName'] ?? '').toString(),
                    gradedAt: (submission['gradedAtLabel'] ?? '').toString(),
                    files: submissionFiles,
                    isDeleting: controller.isDeletingSubmission.value,
                    onDelete: () => _confirmDeleteSubmission(context),
                  ),
                ),
              // SizedBox(height: 16.height),
              _SectionTitle(title: 'Submit Response'),
              // SizedBox(height: 8.height),
              _BodyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller.submissionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Write your answer or submission note',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12.height),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: controller.pickFiles,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Add Files'),
                        ),
                        SizedBox(width: 12.width),
                        Expanded(
                          child: Obx(
                            () => Text(
                              '${controller.selectedFiles.length} file(s) selected',
                              style: getTextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.height),
                    Obx(() {
                      final selectedFiles = controller.selectedFiles;
                      if (selectedFiles.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        children: List.generate(selectedFiles.length, (index) {
                          final file = selectedFiles[index];
                          final name = file.path.split('/').last;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.height),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.radius),
                              ),
                              tileColor: Colors.grey.shade100,
                              dense: true,
                              leading: const Icon(
                                Icons.insert_drive_file_outlined,
                              ),
                              title: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    controller.removePickedFileAt(index),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                    SizedBox(height: 8.height),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.submitCurrentAssessment,
                          child: Text(
                            controller.isSubmitting.value
                                ? 'Submitting...'
                                : 'Submit Assessment',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAssessmentFileTile(ClassFile file) {
    return _AttachmentPreviewCard(
      name: file.name.isEmpty ? 'Attachment' : file.name,
      url: file.fileUrl,
      fileType: file.fileType,
      subtitle: file.mimeType.isEmpty ? file.fileType : file.mimeType,
    );
  }

  Future<void> _confirmDeleteSubmission(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Submission'),
          content: const Text(
            'Are you sure you want to delete your submission? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await controller.deleteCurrentSubmission();
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.type,
    required this.classroom,
    required this.dueDate,
    required this.marks,
    required this.questionFormat,
  });

  final String title;
  final String type;
  final String classroom;
  final String dueDate;
  final String marks;
  final String questionFormat;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.width),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: getTextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.height),
          Wrap(
            spacing: 16.width,
            runSpacing: 10.height,
            children: [
              _MetaChip(label: 'Type', value: type),
              _MetaChip(label: 'Classroom', value: classroom),
              _MetaChip(label: 'Due', value: dueDate),
              _MetaChip(label: 'Marks', value: marks),
              _MetaChip(label: 'Format', value: questionFormat),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.width, vertical: 10.height),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.radius),
      ),
      child: RichText(
        text: TextSpan(
          style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          children: [
            TextSpan(
              text: '$label: ',
              style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: getTextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }
}

class _BodyCard extends StatelessWidget {
  const _BodyCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.width),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(14.radius),
      //   border: Border.all(color: Colors.grey.shade300),
      // ),
      child: child,
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _BodyCard(
      child: Text(
        message,
        style: getTextStyle(fontSize: 14, color: Colors.black54),
      ),
    );
  }
}

class _SubmittedCard extends StatelessWidget {
  const _SubmittedCard({
    required this.content,
    required this.submittedAt,
    required this.status,
    required this.marks,
    required this.feedback,
    required this.gradedBy,
    required this.gradedAt,
    required this.files,
    required this.isDeleting,
    required this.onDelete,
  });

  final String content;
  final String submittedAt;
  final String status;
  final String marks;
  final String feedback;
  final String gradedBy;
  final String gradedAt;
  final List<String> files;
  final bool isDeleting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.trim().toLowerCase();
    final hasGradingDetails =
        marks.trim().isNotEmpty ||
        feedback.trim().isNotEmpty ||
        gradedBy.trim().isNotEmpty ||
        gradedAt.trim().isNotEmpty ||
        normalizedStatus == 'graded';

    return _BodyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Status: ${_formatStatus(status)}',
                  style: getTextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: isDeleting ? null : onDelete,
                icon: isDeleting
                    ? SizedBox(
                        width: 16.width,
                        height: 16.width,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete_outline),
                label: Text(isDeleting ? 'Deleting...' : 'Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
          SizedBox(height: 6.height),
          Text(
            submittedAt,
            style: getTextStyle(fontSize: 13, color: Colors.black54),
          ),
          SizedBox(height: 12.height),
          Text(
            content.isEmpty ? 'No written answer added.' : content,
            style: getTextStyle(fontSize: 14, color: Colors.black87),
          ),
          if (hasGradingDetails) ...[
            SizedBox(height: 8.height),
            Divider(color: Colors.grey.shade300, height: 1),
            SizedBox(height: 8.height),
            Text(
              'Grading Details:',
              style: getTextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            SizedBox(height: 10.height),
            Wrap(
              children: [
                if (marks.trim().isNotEmpty)
                  _MetaChip(label: 'Marks', value: marks),
                if (gradedBy.trim().isNotEmpty)
                  _MetaChip(label: 'Faculty', value: gradedBy),
                if (gradedAt.trim().isNotEmpty)
                  _MetaChip(label: 'Graded At', value: gradedAt),
              ],
            ),
            if (feedback.trim().isNotEmpty) ...[
              SizedBox(height: 8.height),
              Text(
                'Faculty\'s Feedback: $feedback',
                style: getTextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
          if (files.isNotEmpty) ...[
            SizedBox(height: 12.height),
            ...files.map(
              (url) => Padding(
                padding: EdgeInsets.only(bottom: 10.height),
                child: _AttachmentPreviewCard(
                  name: _fileNameFromUrl(url),
                  url: url,
                  fileType: _fileTypeFromUrl(url),
                  subtitle: _fileTypeFromUrl(url).toUpperCase(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatStatus(String rawStatus) {
    final parts = rawStatus
        .trim()
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .toList();

    return parts.isEmpty ? 'Submitted' : parts.join(' ');
  }

  String _fileNameFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final name = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : url.split('/').last;
    return name.isEmpty ? 'Attachment' : name;
  }

  String _fileTypeFromUrl(String url) {
    final name = _fileNameFromUrl(url).toLowerCase();
    if (name.endsWith('.pdf')) return 'pdf';
    if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.webp') ||
        name.endsWith('.gif')) {
      return 'image';
    }
    if (name.endsWith('.doc') || name.endsWith('.docx')) return 'doc';
    if (name.endsWith('.mp4') || name.endsWith('.mov')) return 'video';
    return 'file';
  }
}

class _AttachmentPreviewCard extends StatelessWidget {
  const _AttachmentPreviewCard({
    required this.name,
    required this.url,
    required this.fileType,
    required this.subtitle,
  });

  final String name;
  final String url;
  final String fileType;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final normalizedType = fileType.toLowerCase();
    if (normalizedType == 'image') {
      return _ImagePreviewCard(name: name, url: url, subtitle: subtitle);
    }
    if (normalizedType == 'pdf') {
      return _PdfPreviewCard(name: name, url: url, subtitle: subtitle);
    }

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.radius),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      tileColor: Colors.white,
        leading: Icon(_iconForType(normalizedType), color: Colors.blueAccent),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new),
        onTap: url.isEmpty ? null : () => AppDeviceUtility.launchUrl(url),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'image':
        return Icons.image_outlined;
      case 'video':
        return Icons.smart_display_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}

class _ImagePreviewCard extends StatelessWidget {
  const _ImagePreviewCard({
    required this.name,
    required this.url,
    required this.subtitle,
  });

  final String name;
  final String url;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: url.isEmpty ? null : () => AppDeviceUtility.launchUrl(url),
      borderRadius: BorderRadius.circular(12.radius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.radius),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.radius)),
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
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
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
            ListTile(
              leading: const Icon(
                Icons.image_outlined,
                color: Colors.blueAccent,
              ),
              title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(subtitle),
              // trailing: const Icon(Icons.open_in_new),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfPreviewCard extends StatelessWidget {
  const _PdfPreviewCard({
    required this.name,
    required this.url,
    required this.subtitle,
  });

  final String name;
  final String url;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: url.isEmpty ? null : () => AppDeviceUtility.launchUrl(url),
      borderRadius: BorderRadius.circular(12.radius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.radius),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 240.height,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.radius)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.radius)),
                child: SfPdfViewer.network(
                  url,
                  canShowScrollHead: false,
                  canShowScrollStatus: false,
                  pageSpacing: 0,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf_outlined,
                color: Colors.redAccent,
              ),
              title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.open_in_new),
            ),
          ],
        ),
      ),
    );
  }
}
