import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/utils/responsive.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import '../../controller/jobs.controller.dart';
import '../../model/jobs.model.dart';
import '../job_apply_bottom_sheet.dart';

class JobDetailBottomBar extends StatelessWidget {
  final JobModel job;
  final JobController controller;

  const JobDetailBottomBar({
    super.key,
    required this.job,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.width, vertical: 16.height),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52.height,
          child: ElevatedButton(
            onPressed: () => showJobApplyBottomSheet(context, job, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButtonColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.radius),
              ),
            ),
            child: Text(
              'Apply Now',
              style: getTextStyle(
                fontSize: 14.fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
