import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/services/end_points.dart';
import '../controller/jobs.controller.dart';
import '../model/jobs.model.dart';

class JobApplyBottomSheet extends StatefulWidget {
  final JobModel job;
  final JobController controller;

  const JobApplyBottomSheet({
    super.key,
    required this.job,
    required this.controller,
  });

  @override
  State<JobApplyBottomSheet> createState() => _JobApplyBottomSheetState();
}

class _JobApplyBottomSheetState extends State<JobApplyBottomSheet> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.myCvs.isEmpty) {
      widget.controller.loadMyCvs();
    } else if (widget.controller.selectedCvIndex.value < 0) {
      widget.controller.selectedCvIndex.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final controller = widget.controller;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
        ),
        child: Column(
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apply for ${job.title}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.company,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 16),

            // Scrollable form fields
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Cover Letter
                    const Text(
                      'Cover Letter (Optional)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Why are you a good fit for this position? (Max 5,000 chars)',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.coverLetterController,
                      maxLines: 4,
                      maxLength: 5000,
                      decoration: InputDecoration(
                        hintText: 'Why are you a good fit for this role?',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryButtonColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Resume URL / Upload Resume
                    const Text(
                      'Resume URL (Optional)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.resumeUrlController,
                            decoration: InputDecoration(
                              hintText: 'Link to your portfolio or resume',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                              prefixIcon: const Icon(Icons.link, color: Colors.grey, size: 20),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: controller.pickAndUploadResume,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryButtonColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text('Upload'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. Select In-App CV
                    const Text(
                      'Select CV (Optional)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Attach one of your created in-app CVs (optional)',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      if (controller.myCvs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'No in-app CVs found. You can upload a resume file above or build a CV in My Career.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        );
                      }

                      final items = controller.myCvs.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final cv = entry.value;
                        final name = [cv['firstName'], cv['lastName']]
                            .where((s) => s != null && s.toString().isNotEmpty)
                            .join(' ');
                        final createdAt = (cv['createdAt'] ?? '').toString().split('T').first;

                        return DropdownMenuItem<int>(
                          value: idx,
                          child: Text(
                            '${name.isNotEmpty ? name : 'CV ${idx + 1}'} - $createdAt',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList();

                      final current = controller.selectedCvIndex.value >= 0 &&
                              controller.selectedCvIndex.value < controller.myCvs.length
                          ? controller.selectedCvIndex.value
                          : 0;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: current,
                            items: items,
                            onChanged: (v) {
                              if (v != null) controller.selectedCvIndex.value = v;
                            },
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // 4. Attach Certificates
                    const Text(
                      'Attach Certificates (Optional)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Form Four, Form Six, Diploma, Degree, or Birth Certificate (PDF/Image)',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (controller.certificates.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: controller.certificates.asMap().entries.map((entry) {
                                final index = entry.key;
                                final url = entry.value;
                                final fileName = url.split('/').last;

                                return Chip(
                                  avatar: const Icon(Icons.verified_outlined, size: 16, color: Colors.green),
                                  label: Text(
                                    fileName.length > 20 ? '${fileName.substring(0, 18)}...' : fileName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () => controller.certificates.removeAt(index),
                                  backgroundColor: Colors.green.shade50,
                                  side: BorderSide(color: Colors.green.shade200),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                          ],
                          OutlinedButton.icon(
                            onPressed: controller.pickAndUploadCertificate,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryButtonColor,
                              side: const BorderSide(color: AppColors.primaryButtonColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: const Text('+ Upload Certificate'),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),

                    // 5. Proof of Identity
                    const Text(
                      'Proof of Identity (Optional)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Passport, National ID (NIDA), or Birth Certificate',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final idUrl = controller.identityProofUrl.value;
                      if (idUrl.isNotEmpty) {
                        final fileName = idUrl.split('/').last;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            // border: BorderSide(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.badge_outlined, color: AppColors.primaryButtonColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  fileName,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                onPressed: () => controller.identityProofUrl.value = '',
                              ),
                            ],
                          ),
                        );
                      }
                      return OutlinedButton.icon(
                        onPressed: controller.pickAndUploadIdentityProof,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryButtonColor,
                          side: const BorderSide(color: AppColors.primaryButtonColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text('Upload Identity Document'),
                      );
                    }),
                    const SizedBox(height: 20),

                    // 6. Applicant Photo
                    const Text(
                      'Applicant Photo (Optional)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Professional headshot photo',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final photo = controller.photoUrl.value;
                      if (photo.isNotEmpty) {
                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                photo,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: controller.pickAndUploadPhoto,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Change Photo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => controller.photoUrl.value = '',
                            ),
                          ],
                        );
                      }
                      return OutlinedButton.icon(
                        onPressed: controller.pickAndUploadPhoto,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryButtonColor,
                          side: const BorderSide(color: AppColors.primaryButtonColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text('Upload Photo'),
                      );
                    }),
                    const SizedBox(height: 20),

                    // 7. Other Documents
                    const Text(
                      'Other Documents (Optional)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recommendation letters, transcripts, or other files',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (controller.otherDocuments.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: controller.otherDocuments.asMap().entries.map((entry) {
                                final index = entry.key;
                                final url = entry.value;
                                final fileName = url.split('/').last;

                                return Chip(
                                  avatar: const Icon(Icons.insert_drive_file_outlined, size: 16),
                                  label: Text(
                                    fileName.length > 20 ? '${fileName.substring(0, 18)}...' : fileName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () => controller.otherDocuments.removeAt(index),
                                  backgroundColor: Colors.grey.shade100,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                          ],
                          OutlinedButton.icon(
                            onPressed: controller.pickAndUploadOtherDocument,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryButtonColor,
                              side: const BorderSide(color: AppColors.primaryButtonColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: const Text('+ Add Document'),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 20),

                    // 8. Phone Number
                    const Text(
                      'Phone Number',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'e.g. +255 717 000 000',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.phone, color: Colors.grey, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 9. Experience & Education
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Experience (Years)',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: controller.experienceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'e.g. 2',
                                  hintStyle: TextStyle(color: Colors.grey.shade400),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Education',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: controller.educationController,
                                decoration: InputDecoration(
                                  hintText: 'e.g. BSc in CS',
                                  hintStyle: TextStyle(color: Colors.grey.shade400),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 10. LinkedIn & Portfolio
                    TextField(
                      controller: controller.linkedInController,
                      decoration: InputDecoration(
                        labelText: 'LinkedIn Profile URL (Optional)',
                        hintText: 'https://linkedin.com/in/username',
                        prefixIcon: const Icon(Icons.public, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.portfolioController,
                      decoration: InputDecoration(
                        labelText: 'Portfolio Website URL (Optional)',
                        hintText: 'https://myportfolio.dev',
                        prefixIcon: const Icon(Icons.language, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 11. Recruiter Email & URL (Optional)
                    TextField(
                      controller: controller.recruiterEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Recruiter Email (Optional)',
                        hintText: 'recruiter@company.com',
                        prefixIcon: const Icon(Icons.email_outlined, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.recruiterUrlController,
                      decoration: InputDecoration(
                        labelText: 'Recruiter Application URL (Optional)',
                        hintText: 'https://company.com/apply',
                        prefixIcon: const Icon(Icons.link, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 12. Skills
                    const Text(
                      'Skills',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add skills relevant to this role (press Enter or "+" to add)',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.skillsController,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) => controller.addSkill(value),
                            decoration: InputDecoration(
                              hintText: 'e.g. JavaScript, React...',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => controller.addSkill(controller.skillsController.text),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryButtonColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Obx(() {
                      if (controller.appliedSkills.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: controller.appliedSkills.map((skill) {
                          return Chip(
                            label: Text(skill, style: const TextStyle(fontSize: 13)),
                            backgroundColor: Colors.blue.shade50,
                            side: BorderSide(color: Colors.blue.shade200),
                            deleteIcon: const Icon(Icons.close, size: 16, color: Colors.blue),
                            onDeleted: () => controller.removeSkill(skill),
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 28),

                    // Submit Application Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _handleSubmit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButtonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Submit Application',
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context) {
    final controller = widget.controller;
    final job = widget.job;

    final coverLetter = controller.coverLetterController.text.trim();
    String resumeUrl = controller.resumeUrlController.text.trim();
    String? cvId;

    if (controller.selectedCvIndex.value >= 0 &&
        controller.selectedCvIndex.value < controller.myCvs.length) {
      cvId = controller.myCvs[controller.selectedCvIndex.value]['id']?.toString();
    }

    // If resumeUrl is empty, but cvId is selected, resolve resumeUrl from CV download endpoint or CV object
    if (resumeUrl.isEmpty && cvId != null && cvId.isNotEmpty) {
      final cvMap = (controller.selectedCvIndex.value >= 0 &&
              controller.selectedCvIndex.value < controller.myCvs.length)
          ? controller.myCvs[controller.selectedCvIndex.value]
          : null;
      final cvUrl = cvMap?['fileUrl'] ??
          cvMap?['resumeUrl'] ??
          cvMap?['downloadUrl'] ??
          cvMap?['pdfUrl'] ??
          cvMap?['url'];
      if (cvUrl != null && cvUrl.toString().trim().isNotEmpty) {
        resumeUrl = cvUrl.toString().trim();
      } else {
        resumeUrl = Urls.downloadCv(cvId);
      }
    }

    final hasCv = cvId != null && cvId.isNotEmpty;

    Navigator.pop(context);

    final applyData = <String, dynamic>{
      if (coverLetter.isNotEmpty) 'coverLetter': coverLetter,
      if (resumeUrl.isNotEmpty) 'resumeUrl': resumeUrl,
      if (hasCv) 'cvId': int.tryParse(cvId) ?? cvId,
      if (controller.certificates.isNotEmpty)
        'certificates': controller.certificates.toList(),
      if (controller.identityProofUrl.value.isNotEmpty)
        'identityProofUrl': controller.identityProofUrl.value,
      if (controller.photoUrl.value.isNotEmpty)
        'photoUrl': controller.photoUrl.value,
      if (controller.otherDocuments.isNotEmpty)
        'otherDocuments': controller.otherDocuments.toList(),
      if (controller.recruiterEmailController.text.trim().isNotEmpty)
        'recruiterEmail': controller.recruiterEmailController.text.trim(),
      if (controller.recruiterUrlController.text.trim().isNotEmpty)
        'recruiterUrl': controller.recruiterUrlController.text.trim(),
      'skills': controller.appliedSkills.isNotEmpty
          ? controller.appliedSkills.toList()
          : (job.professionalSkills.isNotEmpty ? job.professionalSkills : <String>[]),
      'metadata': {
        'experience': controller.experienceController.text.trim().isNotEmpty
            ? int.tryParse(controller.experienceController.text.trim()) ?? 0
            : 0,
        'education': controller.educationController.text.trim().isNotEmpty
            ? controller.educationController.text.trim()
            : '',
        'phone': controller.phoneController.text.trim().isNotEmpty
            ? controller.phoneController.text.trim()
            : '',
        if (controller.linkedInController.text.trim().isNotEmpty)
          'linkedIn': controller.linkedInController.text.trim(),
        if (controller.portfolioController.text.trim().isNotEmpty)
          'portfolio': controller.portfolioController.text.trim(),
      },
    };

    controller.applyForJob(job.id, applyData);
  }
}

void showJobApplyBottomSheet(
  BuildContext context,
  JobModel job,
  JobController controller,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => JobApplyBottomSheet(job: job, controller: controller),
  );
}
