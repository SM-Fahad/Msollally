import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/recruiter_home_model.dart';

class LatestApplicantsWidget extends StatelessWidget {
  final List<ApplicantData> applicants;
  final Function(ApplicantData) onApplicantTap;

  const LatestApplicantsWidget({
    super.key,
    required this.applicants,
    required this.onApplicantTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest Applicants',
          style: TextStyle(
            color: AppColors.blackAlpha7F1E1E1E,
            fontSize: 16.sp,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
            height: 1.38,
            letterSpacing: -0.50,
          ),
        ),
        SizedBox(height: 20.h),
        Column(
          children: applicants
              .map((applicant) => _buildApplicantCard(applicant))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildApplicantCard(ApplicantData applicant) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoute.recruiterCandidateDetails,
          arguments: applicant.applicationId,
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(13.w),
        decoration: ShapeDecoration(
          color: applicant.backgroundColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.50, color: applicant.borderColor),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 17.r,
              backgroundColor: applicant.nameColor.withValues(alpha: 0.1),
              backgroundImage: applicant.avatarUrl.isNotEmpty
                  ? NetworkImage(applicant.avatarUrl)
                  : null,
              onBackgroundImageError: applicant.avatarUrl.isNotEmpty
                  ? (exception, stackTrace) =>
                        debugPrint('Failed to load profile image')
                  : null,
              child: applicant.avatarUrl.isEmpty
                  ? Icon(Icons.person, size: 18.sp, color: applicant.nameColor)
                  : null,
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    applicant.name,
                    style: TextStyle(
                      color: applicant.nameColor,
                      fontSize: 14.sp,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                      height: 2,
                      letterSpacing: 0.20,
                    ),
                  ),

                  Text(
                    'Applied To: ${applicant.appliedTo}',
                    style: TextStyle(
                      color: AppColors.appBarTitleColor,
                      fontSize: 12.sp,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                      height: 2.33,
                      letterSpacing: 0.20,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                Text(
                  applicant.date,
                  style: TextStyle(
                    color: AppColors.appBarTitleColor.withValues(alpha: 0.50),
                    fontSize: 10.sp,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                    letterSpacing: 0.20,
                  ),
                ),

                SizedBox(height: 5.h),

                GestureDetector(
                  onTap: () async {
                    await _openResumeUrl(applicant.resumeUrl);
                  },
                  child: Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withValues(alpha: 0.1),
                    ),
                    child: Icon(Icons.public, size: 16.w, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openResumeUrl(String resumeUrl) async {
    if (resumeUrl.isEmpty) return;
    try {
      var url = resumeUrl;
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      debugPrint('Error opening resume URL: $e');
    }
  }
}
