// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/controller/job_applicants_controller.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/model/applicant_model.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/widgets/applicant_action_buttons.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/widgets/applicant_info_section.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/widgets/applicant_status_badge.dart';

class ApplicantDetailsScreen extends StatelessWidget {
  final ApplicantModel applicant;
  final String controllerTag;

  ApplicantDetailsScreen({
    super.key,
    required this.applicant,
    required this.controllerTag,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobApplicantsController>(tag: controllerTag);

    return Scaffold(
      backgroundColor: AppColors.aliceBlueF4F7FB,
      appBar: AppBar(
        backgroundColor: AppColors.aliceBlueF4F7FB,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Candidate: ${applicant.name}',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.black0F172A,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(applicant: applicant, controllerTag: controllerTag),
            ApplicantInfoSection(
              title: 'CV / Resume',
              rows: [
                ApplicantInfoRowData(
                  label: 'Resume status',
                  value: applicant.resumeUrl.trim().isEmpty
                      ? 'No CV uploaded'
                      : 'CV available',
                ),
              ],
              child: _DocumentActions(
                applicant: applicant,
                controllerTag: controllerTag,
              ),
            ),
            ApplicantInfoSection(
              title: 'Cover Letter',
              rows: [],
              child: Text(
                applicant.coverLetter.trim().isEmpty
                    ? 'No cover letter provided.'
                    : applicant.coverLetter,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: AppColors.darkSlateGray334155,
                ),
              ),
            ),
            ApplicantInfoSection(
              title: 'Personal Information',
              rows: [
                ApplicantInfoRowData(
                  label: 'Candidate name',
                  value: applicant.name,
                ),
                ApplicantInfoRowData(label: 'Phone', value: applicant.phone),
                ApplicantInfoRowData(
                  label: 'LinkedIn',
                  value: applicant.linkedIn.trim().isEmpty
                      ? 'Not provided'
                      : applicant.linkedIn,
                  valueColor: applicant.linkedIn.trim().isEmpty
                      ? AppColors.black0F172A
                      : AppColors.royalBlue2563EB,
                  onTap: applicant.linkedIn.trim().isEmpty
                      ? null
                      : () => controller.openLinkedIn(applicant.linkedIn),
                  trailing: applicant.linkedIn.trim().isEmpty
                      ? null
                      : Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: AppColors.royalBlue2563EB,
                        ),
                ),
                ApplicantInfoRowData(
                  label: 'Applicant ID',
                  value: applicant.applicantId,
                ),
                ApplicantInfoRowData(
                  label: 'Status',
                  value: controller.prettyLabel(applicant.status),
                ),
              ],
            ),
            ApplicantInfoSection(
              title: 'Education Information',
              rows: [
                ApplicantInfoRowData(
                  label: 'Education',
                  value: applicant.education,
                ),
                ApplicantInfoRowData(label: 'Degree', value: applicant.degree),
                ApplicantInfoRowData(
                  label: 'University',
                  value: applicant.university,
                ),
                ApplicantInfoRowData(label: 'GPA', value: applicant.gpa),
                ApplicantInfoRowData(label: 'Year', value: applicant.year),
              ],
            ),
            ApplicantInfoSection(
              title: 'Work Experience',
              rows: [
                ApplicantInfoRowData(
                  label: 'Experience years',
                  value: controller.formatExperience(applicant.experience),
                ),
              ],
            ),
            ApplicantInfoSection(
              title: 'Skills',
              rows: [],
              child: applicant.skills.isEmpty
                  ? Text(
                      'No skills added.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.slateGray64748B,
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: applicant.skills.map(_SkillChip.new).toList(),
                    ),
            ),
            ApplicantInfoSection(
              title: 'Decision',
              rows: [
                ApplicantInfoRowData(
                  label: 'Applied date',
                  value: controller.formatDateTime(applicant.appliedAt),
                ),
              ],
              child: ApplicantActionButtons(
                applicant: applicant,
                controllerTag: controllerTag,
                popAfterSuccess: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ApplicantModel applicant;
  final String controllerTag;

  _HeaderCard({required this.applicant, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobApplicantsController>(tag: controllerTag);
    final education = [
      applicant.education,
      applicant.degree,
      applicant.university,
    ].where((item) => item.trim().isNotEmpty).join(' • ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Color.fromARGB(255, 82, 125, 243),
        // gradient: LinearGradient(
        //   colors: [AppColors.black0F172A, AppColors.darkSlateBlue1E40AF],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(applicant: applicant, controllerTag: controllerTag),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (education.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        education,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: AppColors.lavenderE2E8F0,
                        ),
                      ),
                    ],
                    SizedBox(height: 10),
                    Row(
                      children: [
                        ApplicantStatusBadge(status: applicant.status),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            controller.formatExperience(applicant.experience),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lavenderE2E8F0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.formatDateTime(applicant.appliedAt).isEmpty
                        ? 'Applied recently'
                        : 'Applied ${controller.formatDateTime(applicant.appliedAt)}',
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final ApplicantModel applicant;
  final String controllerTag;

  _Avatar({required this.applicant, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobApplicantsController>(tag: controllerTag);
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.16),
      ),
      clipBehavior: Clip.antiAlias,
      child: applicant.avatar.trim().isNotEmpty
          ? Image.network(
              applicant.avatar,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(controller),
            )
          : _fallback(controller),
    );
  }

  Widget _fallback(JobApplicantsController controller) {
    return Center(
      child: Text(
        controller.applicantInitials(applicant),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _DocumentActions extends StatelessWidget {
  final ApplicantModel applicant;
  final String controllerTag;

  _DocumentActions({required this.applicant, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobApplicantsController>(tag: controllerTag);
    final hasResume = applicant.resumeUrl.trim().isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            label: hasResume ? 'Open CV' : 'No CV Uploaded',
            backgroundColor: hasResume ? AppColors.lavenderE0F2FE : AppColors.whiteSmokeF1F5F9,
            foregroundColor: hasResume ? AppColors.teal0369A1 : AppColors.darkGray94A3B8,
            onTap: hasResume ? () => controller.openResume(applicant) : null,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  _ActionTile({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: foregroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;

  _SkillChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.darkSlateGray334155,
        ),
      ),
    );
  }
}
