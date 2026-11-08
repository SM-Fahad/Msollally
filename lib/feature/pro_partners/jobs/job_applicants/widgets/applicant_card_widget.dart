// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/controller/job_applicants_controller.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/model/applicant_model.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/screen/applicant_details_screen.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/widgets/applicant_status_badge.dart';

class ApplicantCardWidget extends StatelessWidget {
  final ApplicantModel applicant;
  final String controllerTag;

  ApplicantCardWidget({
    super.key,
    required this.applicant,
    required this.controllerTag,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobApplicantsController>(tag: controllerTag);
    final educationLine =
        [
              applicant.education,
              applicant.degree,
              controller.formatExperience(applicant.experience),
            ]
            .where((item) => item.trim().isNotEmpty && item != 'Not specified')
            .join(' • ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetails(),
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.black0F172A.withValues(alpha: 0.05),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ApplicantAvatar(
                    avatar: applicant.avatar,
                    initials: controller.applicantInitials(applicant),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applicant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black0F172A,
                          ),
                        ),
                        if (educationLine.isNotEmpty) ...[
                          SizedBox(height: 6),
                          Text(
                            educationLine,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: AppColors.slateGray64748B,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  ApplicantStatusBadge(status: applicant.status),
                ],
              ),
              if (applicant.skills.isNotEmpty) ...[
                SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: applicant.skills
                      .take(5)
                      .map(_SkillChip.new)
                      .toList(),
                ),
              ],
              SizedBox(height: 14),
              Row(
                children: [
                  _MetaItem(
                    icon: Icons.schedule_outlined,
                    text: controller.formatDateTime(applicant.appliedAt).isEmpty
                        ? 'Applied recently'
                        : controller.formatDateTime(applicant.appliedAt),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _MetaItem(
                      icon: Icons.work_outline,
                      text: controller.formatExperience(applicant.experience),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _CardButton(
                      label: 'View Details',
                      backgroundColor: AppColors.black0F172A,
                      foregroundColor: Colors.white,
                      onTap: _openDetails,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _CardButton(
                      label: applicant.resumeUrl.trim().isEmpty
                          ? 'No CV Uploaded'
                          : 'Open CV',
                      backgroundColor: applicant.resumeUrl.trim().isEmpty
                          ? AppColors.whiteSmokeF1F5F9
                          : AppColors.lavenderE0F2FE,
                      foregroundColor: applicant.resumeUrl.trim().isEmpty
                          ? AppColors.darkGray94A3B8
                          : AppColors.teal0369A1,
                      onTap: applicant.resumeUrl.trim().isEmpty
                          ? null
                          : () => controller.openResume(applicant),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails() {
    Get.to(
      () => ApplicantDetailsScreen(
        applicant: applicant,
        controllerTag: controllerTag,
      ),
    );
  }
}

class _ApplicantAvatar extends StatelessWidget {
  final String avatar;
  final String initials;

  _ApplicantAvatar({required this.avatar, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.lavenderDBEAFE, AppColors.lavenderE0F2FE],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: avatar.trim().isNotEmpty
          ? Image.network(
              avatar,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.royalBlue1D4ED8,
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.darkSlateGray475569,
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.slateGray64748B),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, color: AppColors.slateGray64748B),
          ),
        ),
      ],
    );
  }
}

class _CardButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onTap;

  _CardButton({
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
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            color: onTap == null
                ? backgroundColor.withValues(alpha: 0.9)
                : backgroundColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
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
