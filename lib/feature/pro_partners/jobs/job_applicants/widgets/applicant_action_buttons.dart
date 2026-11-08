// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/controller/job_applicants_controller.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/model/applicant_model.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_applicants/widgets/reject_application_dialog.dart';

class ApplicantActionButtons extends StatelessWidget {
  final ApplicantModel applicant;
  final String controllerTag;
  final bool popAfterSuccess;

  ApplicantActionButtons({
    super.key,
    required this.applicant,
    required this.controllerTag,
    this.popAfterSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobApplicantsController>(tag: controllerTag);

    return Obx(() {
      final isUpdating = controller.updatingApplicationIds.contains(
        applicant.applicationId,
      );
      final activeStatus =
          controller.updatingApplicationStatuses[applicant.applicationId];
      final status = applicant.status.toLowerCase();

      if (status == 'shortlisted') {
        return _SingleActionButton(
          label: 'Move Back to Pending',
          isLoading: activeStatus == 'pending',
          isDisabled: isUpdating,
          backgroundColor: AppColors.seaShellFFF7ED,
          foregroundColor: AppColors.siennaB45309,
          onTap: () => controller.updateApplicationStatus(
            applicationId: applicant.applicationId,
            status: 'pending',
            popAfterSuccess: popAfterSuccess,
          ),
        );
      }

      if (status == 'rejected') {
        return _SingleActionButton(
          label: 'Move Back to Pending',
          isLoading: activeStatus == 'pending',
          isDisabled: isUpdating,
          backgroundColor: AppColors.seaShellFFF7ED,
          foregroundColor: AppColors.siennaB45309,
          onTap: () => controller.updateApplicationStatus(
            applicationId: applicant.applicationId,
            status: 'pending',
            popAfterSuccess: popAfterSuccess,
          ),
        );
      }

      return Row(
        children: [
          Expanded(
            child: _SingleActionButton(
              label: 'Reject',
              isLoading: activeStatus == 'rejected',
              isDisabled: isUpdating,
              backgroundColor: AppColors.lavenderBlushFFF1F2,
              foregroundColor: AppColors.crimsonDC2626,
              onTap: () async {
                final reason = await showRejectApplicationDialog(context);
                if (reason == null || reason.trim().isEmpty) {
                  return;
                }
                await controller.updateApplicationStatus(
                  applicationId: applicant.applicationId,
                  status: 'rejected',
                  rejectionReason: reason,
                  popAfterSuccess: popAfterSuccess,
                );
              },
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _SingleActionButton(
              label: 'Shortlist',
              isLoading: activeStatus == 'shortlisted',
              isDisabled: isUpdating,
              backgroundColor: AppColors.royalBlue1D4ED8,
              foregroundColor: Colors.white,
              onTap: () => controller.updateApplicationStatus(
                applicationId: applicant.applicationId,
                status: 'shortlisted',
                popAfterSuccess: popAfterSuccess,
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _SingleActionButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isDisabled;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  _SingleActionButton({
    required this.label,
    required this.isLoading,
    required this.isDisabled,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: isDisabled
                ? backgroundColor.withValues(alpha: 0.65)
                : backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: foregroundColor,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
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
