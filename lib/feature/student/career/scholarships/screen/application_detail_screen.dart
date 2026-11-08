import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/scholarship_controller.dart';
import '../model/scholarship_application_model.dart';
import '../widgets/scholarship_detail_widgets.dart';

class ScholarshipApplicationDetailScreen extends StatelessWidget {
  const ScholarshipApplicationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScholarshipController controller = Get.find<ScholarshipController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Application Details'), elevation: 0),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final app = controller.selectedApplication.value;
        if (app == null) {
          return const Center(child: Text('Application not found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScholarshipDetailHeader(
                title: app.scholarship.title,
                foundation: app.scholarship.foundationName,
                thumbnailUrl: app.scholarship.fullThumbnailUrl,
                foundationLogoUrl: app.scholarship.fullFoundationLogoUrl,
              ),
              const SizedBox(height: 24),
              _buildStatusSection(app.status),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildSubmissionDetails(app),
              const SizedBox(height: 24),
              if (app.motivationLetter.isNotEmpty)
                _buildTextSection('Motivation Letter', app.motivationLetter),
              if (app.recruiterEmail.isNotEmpty || app.recruiterUrl.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildRecruiterSection(app),
              ],
              if (_hasAttachments(app)) ...[
                const SizedBox(height: 20),
                _buildAttachmentsSection(app),
              ],
              if (app.reviewNotes.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildTextSection(
                  'Reviewer Notes',
                  app.reviewNotes,
                  isHighlight: true,
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  bool _hasAttachments(ScholarshipApplicationModel app) {
    return app.resumeUrl.isNotEmpty ||
        app.transcriptUrl.isNotEmpty ||
        app.certificates.isNotEmpty ||
        app.recommendationLetterUrl.isNotEmpty ||
        app.identityProofUrl.isNotEmpty ||
        app.applicationFormUrl.isNotEmpty ||
        app.documents.isNotEmpty ||
        app.photoUrl.isNotEmpty;
  }

  Widget _buildRecruiterSection(ScholarshipApplicationModel app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recruiter / Sponsor Info',
          style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (app.recruiterEmail.isNotEmpty)
          _InfoRow(label: 'Email', value: app.recruiterEmail),
        if (app.recruiterUrl.isNotEmpty)
          _InfoRow(label: 'Website', value: app.recruiterUrl),
      ],
    );
  }

  Widget _buildAttachmentsSection(ScholarshipApplicationModel app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attached Documents',
          style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (app.photoUrl.isNotEmpty)
          _buildAttachmentTile('Applicant Photo', app.photoUrl, Icons.person),
        if (app.resumeUrl.isNotEmpty)
          _buildAttachmentTile('Resume / CV', app.resumeUrl, Icons.description),
        if (app.transcriptUrl.isNotEmpty)
          _buildAttachmentTile('Academic Transcript', app.transcriptUrl, Icons.school),
        if (app.recommendationLetterUrl.isNotEmpty)
          _buildAttachmentTile(
            'Recommendation Letter',
            app.recommendationLetterUrl,
            Icons.mark_email_read,
          ),
        if (app.identityProofUrl.isNotEmpty)
          _buildAttachmentTile(
            'Proof of Identity',
            app.identityProofUrl,
            Icons.badge_outlined,
          ),
        if (app.applicationFormUrl.isNotEmpty)
          _buildAttachmentTile(
            'Application Form',
            app.applicationFormUrl,
            Icons.assignment_outlined,
          ),
        ...app.certificates.map(
          (url) => _buildAttachmentTile(
            'Certificate',
            url,
            Icons.card_membership,
          ),
        ),
        ...app.documents.map(
          (url) => _buildAttachmentTile(
            'Supporting Document',
            url,
            Icons.attachment,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentTile(String label, String url, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: getTextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  url.split('/').last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getTextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final uri = Uri.tryParse(url);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('View'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(String status) {
    final color = _getStatusColor(status);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Application Status',
          style: getTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ScholarshipInfoBadge(
          label: status.toUpperCase(),
          icon: Icons.info_outline,
          color: color,
        ),
      ],
    );
  }

  Widget _buildSubmissionDetails(app) {
    return Column(
      children: [
        _InfoRow(label: 'GPA', value: app.gpa),
        _InfoRow(label: 'Field of Study', value: app.fieldOfStudy),
        _InfoRow(label: 'Institution', value: app.institution),
        _InfoRow(label: 'Year', value: app.yearOfStudy),
        _InfoRow(label: 'Country', value: app.countryOfResidence),
        _InfoRow(
          label: 'Date',
          value:
              '${app.submittedAt.day}/${app.submittedAt.month}/${app.submittedAt.year}',
        ),
      ],
    );
  }

  Widget _buildTextSection(
    String title,
    String content, {
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.orange : Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isHighlight
                ? Colors.orange.withValues(alpha: 0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighlight
                  ? Colors.orange.withValues(alpha: 0.2)
                  : Colors.grey.shade200,
            ),
          ),
          child: Text(
            content,
            style: getTextStyle(
              fontSize: 14,
              color: isHighlight ? Colors.orange.shade900 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase() == 'approved') return Colors.green;
    if (status.toLowerCase() == 'rejected') return Colors.red;
    if (status.toLowerCase() == 'submitted') return Colors.teal;
    return Colors.orange;
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: getTextStyle(fontSize: 14, color: Colors.black54)),
          Text(
            value.isEmpty ? 'N/A' : value,
            style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
