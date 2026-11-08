// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/pro_partners/jobs/all_jobs/controller/all_jobs_controller.dart';
import 'package:msollaally/feature/pro_partners/jobs/all_jobs/model/job_model.dart';
import 'package:msollaally/feature/pro_partners/jobs/job_details/screen/job_details_screen.dart';

class JobCardWidget extends StatelessWidget {
  final JobModel job;

  JobCardWidget({super.key, required this.job});

  bool get _canPublish => job.status.toLowerCase() == 'draft';
  bool get _canUpdatePublished => job.status.toLowerCase() == 'published';

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AllJobsController>();
    final statusStyle = _statusStyleFor(job.status);

    return GestureDetector(
      onTap: () {
        controller.countJobView(job.id);
        Get.to(() => JobDetailsScreen(job: job));
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 18.w),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.sectionBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CompanyLogo(
                  companyName: job.companyName,
                  companyLogo: job.companyLogo,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title.trim().isEmpty ? 'Untitled Job' : job.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.appBarTitleColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _companyDepartmentText(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.tertiaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: _formatEnumLabel(job.status),
                  style: statusStyle,
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                _InfoPill(
                  icon: Icons.location_on_outlined,
                  text: _safeText(job.locationType, fallback: 'Location TBD'),
                ),
                _InfoPill(
                  icon: Icons.schedule_outlined,
                  text: _formatEnumLabel(job.jobType, fallback: 'Job Type'),
                ),
                _InfoPill(icon: Icons.payments_outlined, text: _formatSalary()),
                _InfoPill(
                  icon: Icons.calendar_today_outlined,
                  text: _formatDeadline(job.applicationDeadline),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${job.applications} Applications • ${job.views} Views',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.tertiaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Obx(() {
              final isEditing = controller.loadingJobDetailId.value == job.id;
              final isDeleting = controller.deletingJobId.value == job.id;
              final isUpdatingStatus = controller.updatingJobId.value == job.id;

              return Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _CardActionButton(
                    label: 'Update',
                    icon: Icons.edit_outlined,
                    isLoading: isEditing,
                    backgroundColor: AppColors.aliceBlueEFF6FF,
                    foregroundColor: AppColors.royalBlue2563EB,
                    borderColor: AppColors.powderBlueBFDBFE,
                    onTap: () => controller.openUpdateJob(job.id),
                  ),
                  _CardActionButton(
                    label: 'Delete',
                    icon: Icons.delete_outline,
                    isLoading: isDeleting,
                    backgroundColor: AppColors.lavenderBlushFFF1F2,
                    foregroundColor: AppColors.crimsonDC2626,
                    borderColor: AppColors.lightPinkFDA4AF,
                    onTap: () => controller.confirmDeleteJob(job),
                  ),
                  if (_canPublish)
                    _CardActionButton(
                      label: 'Publish',
                      icon: Icons.upload_outlined,
                      isLoading: isUpdatingStatus,
                      backgroundColor: AppColors.primaryButtonColor,
                      foregroundColor: Colors.white,
                      borderColor: AppColors.primaryButtonColor,
                      onTap: () =>
                          controller.updateJobStatus(job.id, 'published'),
                    ),
                  if (_canUpdatePublished)
                    _CardActionButton(
                      label: 'Update Status',
                      icon: Icons.swap_horiz_rounded,
                      isLoading: isUpdatingStatus,
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryButtonColor,
                      borderColor: AppColors.primaryButtonColor,
                      onTap: () => _showStatusSheet(controller),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showStatusSheet(AllJobsController controller) {
    final actions = [
      _StatusAction(
        label: 'Close Job',
        status: 'closed',
        icon: Icons.cancel_outlined,
      ),
      _StatusAction(
        label: 'Mark as Filled',
        status: 'filled',
        icon: Icons.check_circle_outline,
      ),
      _StatusAction(
        label: 'Archive Job',
        status: 'archived',
        icon: Icons.archive_outlined,
      ),
    ];

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: AppColors.sectionBorderColor,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Update Job Status',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.appBarTitleColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                job.title.trim().isEmpty ? 'Untitled Job' : job.title,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.tertiaryTextColor,
                ),
              ),
              SizedBox(height: 18.h),
              ...actions.map(
                (action) => _BottomSheetActionTile(
                  action: action,
                  onTap: () {
                    Get.back();
                    controller.updateJobStatus(job.id, action.status);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _companyDepartmentText() {
    final parts = <String>[
      if (job.companyName.trim().isNotEmpty) job.companyName.trim(),
      if (job.department.trim().isNotEmpty) job.department.trim(),
    ];
    if (parts.isEmpty) {
      return 'Company details unavailable';
    }
    return parts.join(' • ');
  }

  String _safeText(String value, {required String fallback}) {
    return value.trim().isEmpty ? fallback : value.trim();
  }

  String _formatEnumLabel(String value, {String? fallback}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return fallback ?? '';
    }

    return trimmed
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _formatSalary() {
    final min = job.minimumSalary.trim();
    final max = job.maximumSalary.trim();
    final salaryType = _formatEnumLabel(job.salaryType);

    if (min.isEmpty && max.isEmpty) {
      return salaryType.isEmpty ? 'Salary not specified' : salaryType;
    }

    if (min.isNotEmpty && max.isNotEmpty) {
      return '$min - $max${salaryType.isEmpty ? '' : ' / $salaryType'}';
    }

    final value = min.isNotEmpty ? min : max;
    return '$value${salaryType.isEmpty ? '' : ' / $salaryType'}';
  }

  String _formatDeadline(String isoDate) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) {
      return 'Deadline TBD';
    }
    return 'Deadline ${DateFormat('dd MMM yyyy').format(parsed.toLocal())}';
  }

  _StatusStyle _statusStyleFor(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'draft') {
      return _StatusStyle(
        background: AppColors.cornsilkFFF8E1,
        border: AppColors.khakiF5D27A,
        text: AppColors.chocolateB7791F,
      );
    }
    if (normalized == 'published') {
      return _StatusStyle(
        background: AppColors.createTaskButtonColorHomePage,
        border: AppColors.powderBlueB7E4CA,
        text: AppColors.seaGreen2F9E62,
      );
    }
    if (normalized == 'closed') {
      return _StatusStyle(
        background: AppColors.lavenderBlushFEF2F2,
        border: AppColors.lightPinkF3C0C0,
        text: AppColors.indianRedC24141,
      );
    }
    if (normalized == 'filled') {
      return _StatusStyle(
        background: AppColors.aliceBlueEFF6FF,
        border: AppColors.powderBlueBFDBFE,
        text: AppColors.royalBlue2563EB,
      );
    }
    return _StatusStyle(
      background: AppColors.whiteSmokeF4F4F5,
      border: AppColors.sectionBorderColor,
      text: AppColors.tertiaryTextColor,
    );
  }
}

class _CardActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  _CardActionButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isLoading
              ? backgroundColor.withValues(alpha: 0.7)
              : backgroundColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: borderColor),
        ),
        child: isLoading
            ? SizedBox(
                width: 14.w,
                height: 14.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 15.w, color: foregroundColor),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  final String companyName;
  final String companyLogo;

  _CompanyLogo({required this.companyName, required this.companyLogo});

  @override
  Widget build(BuildContext context) {
    final name = companyName.trim();
    final logo = companyLogo.trim();

    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.sectionBorderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: logo.isNotEmpty
          ? Image.network(
              logo,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _LogoFallback(companyName: name),
            )
          : _LogoFallback(companyName: name),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  final String companyName;

  _LogoFallback({required this.companyName});

  @override
  Widget build(BuildContext context) {
    final hasName = companyName.isNotEmpty;
    final initial = hasName ? companyName[0].toUpperCase() : '';

    return Container(
      color: AppColors.primaryButtonColor.withValues(alpha: 0.10),
      alignment: Alignment.center,
      child: hasName
          ? Text(
              initial,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryButtonColor,
              ),
            )
          : Icon(
              Icons.business_center_outlined,
              size: 22.w,
              color: AppColors.primaryButtonColor,
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final _StatusStyle style;

  _StatusChip({required this.label, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: style.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: style.text,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.panelBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.sectionBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.w, color: AppColors.tertiaryTextColor),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.appBarTitleColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetActionTile extends StatelessWidget {
  final _StatusAction action;
  final VoidCallback onTap;

  _BottomSheetActionTile({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.panelBackgroundColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.sectionBorderColor),
        ),
        child: Row(
          children: [
            Icon(action.icon, color: AppColors.primaryButtonColor, size: 22.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                action.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.appBarTitleColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.w,
              color: AppColors.tertiaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusStyle {
  final Color background;
  final Color border;
  final Color text;

  _StatusStyle({
    required this.background,
    required this.border,
    required this.text,
  });
}

class _StatusAction {
  final String label;
  final String status;
  final IconData icon;

  _StatusAction({
    required this.label,
    required this.status,
    required this.icon,
  });
}
