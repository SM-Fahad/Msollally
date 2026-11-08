import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:msollaally/core/const/icons_path.dart';
import '../../../../../core/common/styles/global_text_style.dart';
import '../model/candidate_model.dart';

class CandidateCard extends StatelessWidget {
  final JobApplicantModel candidate;
  final VoidCallback onMessageTap;
  final VoidCallback onMenuTap;
  final VoidCallback? onTap;

  const CandidateCard({
    super.key,
    required this.candidate,
    required this.onMessageTap,
    required this.onMenuTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.sliderColorInboarding, width: 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25.r),
              child: Image.network(
                candidate.profileImageUrl,
                width: 50.w,
                height: 50.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: AppColors.sliderColorInboarding,
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Center(
                      child: Text(
                        candidate.name.isNotEmpty
                            ? candidate.name[0].toUpperCase()
                            : '?',
                        style: appTextStyleHeading2(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    candidate.name,
                    style: appTextStyleHeading2(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkSlateGray1F2937,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Applied for: ${candidate.jobTitle}',
                    style: appTextStyleHeading2(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  if (candidate.universityName.isNotEmpty ||
                      candidate.departmentName.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Text(
                        '${candidate.universityName.isNotEmpty ? candidate.universityName : ''} ${candidate.departmentName.isNotEmpty ? '- ${candidate.departmentName}' : ''}'
                            .trim(),
                        style: appTextStyleHeading2(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryButtonColor,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Text(
                        'Skills:',
                        style: appTextStyleHeading2(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Wrap(
                        spacing: 6.w,
                        children: candidate.skills
                            .map(
                              (skill) => Text(
                                skill,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.primaryButtonColor,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Row(
              children: [
                InkWell(
                  onTap: () => onMessageTap(),
                  borderRadius: BorderRadius.circular(20.r),
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryButtonColor.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        IconsPath.messageIcon,
                        width: 20.w,
                        height: 20.h,
                        colorFilter: ColorFilter.mode(
                          AppColors.primaryButtonColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              //  SizedBox(width: 4.w),
                // InkWell(
                //   onTap: onMenuTap,
                //   borderRadius: BorderRadius.circular(20.r),
                //   child: SizedBox(
                //     width: 40.w,
                //     height: 40.h,
                //     child: Center(
                //       child: Icon(
                //         Icons.more_vert,
                //         color: AppColors.secondaryTextColor,
                //         size: 20.sp,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
