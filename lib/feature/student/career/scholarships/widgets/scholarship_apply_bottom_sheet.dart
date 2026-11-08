import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/scholarship_controller.dart';
import '../model/scholarship_model.dart';
import '../model/scholarship_application_model.dart';

class ScholarshipApplyBottomSheet extends StatelessWidget {
  final ScholarshipModel scholarship;
  final ScholarshipController controller;
  final ScholarshipApplicationModel? existingApplication;

  const ScholarshipApplyBottomSheet({
    super.key,
    required this.scholarship,
    required this.controller,
    this.existingApplication,
  });

  @override
  Widget build(BuildContext context) {
    final isEdit = existingApplication != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Sheet Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEdit
                                ? 'Update Application'
                                : 'Apply for Scholarship',
                            style: getTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scholarship.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getTextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Scrollable Form Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  children: [
                    // Helper banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryButtonColor.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryButtonColor.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: AppColors.primaryButtonColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'All 10 fields below are optional. You may attach PDFs, enter links, or fill in text.',
                              style: getTextStyle(
                                fontSize: 12,
                                color: AppColors.primaryButtonColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── 1st: Motivation Letter ──
                    _buildSectionHeader(
                      '1. Motivation Letter',
                      Icons.edit_note_rounded,
                      badge: '1st',
                    ),
                    _buildInputField(
                      label: 'Motivation Letter / Statement of Purpose',
                      textController: controller.motivationController,
                      maxLines: 4,
                      hint:
                          'I am writing to express my eager interest in this scholarship...',
                    ),
                    const SizedBox(height: 16),

                    // ── 2nd to 5th: Academic & Professional Documents ──
                    _buildSectionHeader(
                      'Essential Documents',
                      Icons.folder_shared_outlined,
                      badge: '2nd - 5th',
                    ),

                    // 3rd: Resume / CV
                    _buildSingleFileCard(
                      label: '3rd. Resume or CV (PDF)',
                      fieldKey: 'resume',
                      urlRx: controller.resumeUrl,
                      nameRx: controller.resumeFileName,
                      icon: Icons.description_rounded,
                      hint: 'Attach your updated Resume or CV (PDF format)',
                      allowedExtensions: ['pdf'],
                    ),

                    // 4th: Academic Transcript
                    _buildSingleFileCard(
                      label: '4th. Academic Transcript (PDF)',
                      fieldKey: 'transcript',
                      urlRx: controller.transcriptUrl,
                      nameRx: controller.transcriptFileName,
                      icon: Icons.school_rounded,
                      hint: 'Attach official/unofficial transcript (PDF format)',
                      allowedExtensions: ['pdf'],
                    ),

                    // 2nd: Certificates (Multiple)
                    _buildMultiFileCard(
                      label: '2nd. Certificates (PDF)',
                      fieldKey: 'certificate',
                      urlsRx: controller.certificates,
                      namesRx: controller.certificateNames,
                      icon: Icons.card_membership_rounded,
                      addLabel: 'Add Certificate (PDF)',
                      allowedExtensions: ['pdf'],
                    ),

                    // 5th: Recommendation Letters
                    _buildSingleFileCard(
                      label: '5th. Recommendation Letters (PDF)',
                      fieldKey: 'recommendation',
                      urlRx: controller.recommendationLetterUrl,
                      nameRx: controller.recommendationLetterFileName,
                      icon: Icons.mark_email_read_rounded,
                      hint: 'Attach academic/professional recommendation (PDF format)',
                      allowedExtensions: ['pdf'],
                    ),
                    const SizedBox(height: 16),

                    // ── 6th: Recruiter / Sponsor Contact ──
                    _buildSectionHeader(
                      '6. Recruiter & Sponsor Contact',
                      Icons.contact_mail_outlined,
                      badge: '6th',
                    ),
                    _buildInputField(
                      label: 'Recruiter Email',
                      textController: controller.recruiterEmailController,
                      hint: 'scholarships@unesco.org',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                    ),
                    _buildInputField(
                      label: 'Recruiter Website / Portal URL',
                      textController: controller.recruiterUrlController,
                      hint: 'https://unesco.org/apply',
                      keyboardType: TextInputType.url,
                      prefixIcon: Icons.link_rounded,
                    ),
                    const SizedBox(height: 16),

                    // ── 7th to 9th: Identification & Forms ──
                    _buildSectionHeader(
                      'Identity & Formal Applications',
                      Icons.verified_user_outlined,
                      badge: '7th - 9th',
                    ),

                    // 7th: Insert Picture
                    _buildPhotoCard(),

                    // 8th: Proof of Identity
                    _buildSingleFileCard(
                      label: '8th. Proof of Identity (PDF)',
                      fieldKey: 'identity',
                      urlRx: controller.identityProofUrl,
                      nameRx: controller.identityProofFileName,
                      icon: Icons.badge_outlined,
                      hint:
                          'Passport / National ID / Birth Cert (PDF format)',
                      allowedExtensions: ['pdf'],
                    ),

                    // 9th: Application Form
                    _buildSingleFileCard(
                      label: '9th. Application Form (PDF)',
                      fieldKey: 'applicationForm',
                      urlRx: controller.applicationFormUrl,
                      nameRx: controller.applicationFormFileName,
                      icon: Icons.assignment_outlined,
                      hint: 'Completed and signed application form (PDF format)',
                      allowedExtensions: ['pdf'],
                    ),
                    const SizedBox(height: 16),

                    // ── 10th: Other Documents ──
                    _buildSectionHeader(
                      '10. Other Supporting Documents',
                      Icons.attachment_rounded,
                      badge: '10th',
                    ),
                    _buildMultiFileCard(
                      label: 'Other Documents (PDF)',
                      fieldKey: 'document',
                      urlsRx: controller.documents,
                      namesRx: controller.documentNames,
                      icon: Icons.snippet_folder_outlined,
                      addLabel: 'Add Document (PDF)',
                      allowedExtensions: ['pdf'],
                    ),
                    const SizedBox(height: 16),

                    // ── Additional Student Profile / Academic Info ──
                    _buildSectionHeader(
                      'Academic & Applicant Profile',
                      Icons.person_outline_rounded,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'GPA / Grade',
                            textController: controller.gpaController,
                            hint: '3.85',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildInputField(
                            label: 'Year of Study',
                            textController: controller.yearOfStudyController,
                            hint: 'Year 3',
                          ),
                        ),
                      ],
                    ),
                    _buildInputField(
                      label: 'Field of Study',
                      textController: controller.studyFieldController,
                      hint: 'Computer Science',
                    ),
                    _buildInputField(
                      label: 'Institution',
                      textController: controller.institutionController,
                      hint: 'University of Dar es Salaam',
                    ),
                    _buildInputField(
                      label: 'Applicant Email',
                      textController: controller.applicantEmailController,
                      hint: 'student@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildInputField(
                      label: 'Applicant Address',
                      textController: controller.applicantAddressController,
                      hint: 'Dar es Salaam, Tanzania',
                    ),
                    _buildInputField(
                      label: 'Country of Residence',
                      textController: controller.countryController,
                      hint: 'Tanzania',
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Bottom Action Bar
              _buildBottomAction(context, isEdit),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {String? badge}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryButtonColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                badge,
                style: getTextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController textController,
    int maxLines = 1,
    String? hint,
    TextInputType? keyboardType,
    IconData? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: textController,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: getTextStyle(fontSize: 13, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: getTextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, size: 18, color: Colors.grey.shade500)
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.primaryButtonColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleFileCard({
    required String label,
    required String fieldKey,
    required RxString urlRx,
    required RxString nameRx,
    required IconData icon,
    required String hint,
    required List<String> allowedExtensions,
  }) {
    return Obx(() {
      final isUploading = controller.uploadingField.value == fieldKey;
      final hasFile = urlRx.value.isNotEmpty;

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: getTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: hasFile
                    ? Colors.green.shade50.withValues(alpha: 0.5)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasFile ? Colors.green.shade300 : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: hasFile
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hasFile ? Icons.check_circle_rounded : icon,
                      size: 20,
                      color: hasFile
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasFile
                              ? (nameRx.value.isNotEmpty
                                    ? nameRx.value
                                    : urlRx.value.split('/').last)
                              : hint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: getTextStyle(
                            fontSize: 12,
                            fontWeight: hasFile
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: hasFile
                                ? Colors.black87
                                : Colors.grey.shade500,
                          ),
                        ),
                        if (hasFile) ...[
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: () => _openUrl(urlRx.value),
                            child: Text(
                              'View Attachment',
                              style: getTextStyle(
                                fontSize: 11,
                                color: AppColors.primaryButtonColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isUploading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (hasFile)
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.red,
                      ),
                      tooltip: 'Remove',
                      onPressed: () => controller.clearFile(fieldKey),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () => controller.pickAndUploadFile(
                        fieldKey: fieldKey,
                        allowedExtensions: allowedExtensions,
                      ),
                      icon: const Icon(Icons.upload_file, size: 14),
                      label: const Text('Upload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButtonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        textStyle: getTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMultiFileCard({
    required String label,
    required String fieldKey,
    required RxList<String> urlsRx,
    required RxList<String> namesRx,
    required IconData icon,
    required String addLabel,
    required List<String> allowedExtensions,
  }) {
    return Obx(() {
      final isUploading = controller.uploadingField.value == fieldKey;

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: isUploading
                      ? null
                      : () => controller.pickAndUploadFile(
                          fieldKey: fieldKey,
                          allowedExtensions: allowedExtensions,
                        ),
                  icon: isUploading
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        )
                      : const Icon(Icons.add, size: 14),
                  label: Text(addLabel),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryButtonColor,
                    textStyle: getTextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (urlsRx.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  'No files attached yet. Tap "$addLabel" to upload.',
                  style: getTextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              )
            else
              Column(
                children: List.generate(urlsRx.length, (index) {
                  final url = urlsRx[index];
                  final name = index < namesRx.length
                      ? namesRx[index]
                      : url.split('/').last;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: AppColors.primaryButtonColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _openUrl(url),
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            if (fieldKey == 'certificate') {
                              controller.removeCertificate(index);
                            } else {
                              controller.removeDocument(index);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPhotoCard() {
    return Obx(() {
      final isUploading = controller.uploadingField.value == 'photo';
      final hasPhoto = controller.photoUrl.value.isNotEmpty;

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '7th. Insert Picture (Photo URL / Upload)',
              style: getTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: hasPhoto
                        ? NetworkImage(controller.photoUrl.value)
                        : null,
                    child: hasPhoto
                        ? null
                        : Icon(
                            Icons.person,
                            size: 28,
                            color: Colors.grey.shade400,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasPhoto ? 'Photo Uploaded' : 'No photo uploaded',
                          style: getTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasPhoto
                                ? Colors.green.shade700
                                : Colors.black87,
                          ),
                        ),
                        Text(
                          'Upload a clear portrait picture',
                          style: getTextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUploading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (hasPhoto) ...[
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      tooltip: 'Change Photo',
                      onPressed: () => controller.pickAndUploadPhoto(),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.red,
                      ),
                      tooltip: 'Remove',
                      onPressed: () => controller.clearFile('photo'),
                    ),
                  ] else
                    ElevatedButton.icon(
                      onPressed: () => controller.pickAndUploadPhoto(),
                      icon: const Icon(Icons.camera_alt_outlined, size: 14),
                      label: const Text('Pick'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButtonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        textStyle: getTextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBottomAction(BuildContext context, bool isEdit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.height,
        child: ElevatedButton(
          onPressed: () async {
            final success = isEdit
                ? await controller.updateApplication(
                    existingApplication!.applicationId,
                  )
                : await controller.applyForScholarship(scholarship.id);

            if (success && context.mounted) {
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryButtonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
          ),
          child: Text(
            isEdit ? 'Update Application' : 'Submit Application',
            style: getTextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

void showScholarshipApplyBottomSheet(
  BuildContext context,
  ScholarshipModel s,
  ScholarshipController c, {
  ScholarshipApplicationModel? existingApplication,
}) {
  if (existingApplication != null) {
    c.populateForm(existingApplication);
  } else {
    c.clearForm();
    if (s.sponsorEmail.trim().isNotEmpty) {
      c.recruiterEmailController.text = s.sponsorEmail.trim();
    }
    if (s.applicationLink.trim().isNotEmpty) {
      c.recruiterUrlController.text = s.applicationLink.trim();
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ScholarshipApplyBottomSheet(
      scholarship: s,
      controller: c,
      existingApplication: existingApplication,
    ),
  );
}
