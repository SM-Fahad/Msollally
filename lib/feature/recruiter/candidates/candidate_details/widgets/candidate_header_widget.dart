import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../candidate_details/controller/candidate_details_controller.dart';
import '../../candidate_details/model/candidate_details_model.dart';
import '../../../../../core/const/icons_path.dart' show IconsPath;
import '../../../../../core/common/styles/global_text_style.dart';

class CandidateHeaderWidget extends StatelessWidget {
  final CandidateDetailsModel candidate;
  final CandidateDetailsController controller;
  const CandidateHeaderWidget({
    super.key,
    required this.candidate,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipOval(
              child: Image.network(
                candidate.profileImageUrl,
                width: 59.w,
                height: 59.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 59.w,
                    height: 59.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.person,
                      size: 28.sp,
                      color: Colors.grey.shade600,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                candidate.coverLetter,
                style: appTextStyleHeading2(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkSlateGrayAlphaB23F3F3F,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => controller.messageCandidate(),
              child: SvgPicture.asset(IconsPath.messageIcon),
            ),
          ],
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}
