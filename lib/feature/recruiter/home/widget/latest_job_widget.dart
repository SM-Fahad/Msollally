import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/fullscreen_image_view.dart';
import '../model/recruiter_home_model.dart';

class LatestJobWidget extends StatelessWidget {
  final JobData? job;
  final Function(JobData) onJobTap;

  const LatestJobWidget({super.key, required this.job, required this.onJobTap});

  @override
  Widget build(BuildContext context) {
    if (job == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest Jobs',
          style: TextStyle(
            color: AppColors.blackAlpha7F1E1E1E,
            fontSize: 16.sp,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
            height: 1.38,
            letterSpacing: -0.50,
          ),
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () => onJobTap(job!),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: ShapeDecoration(
              color: AppColors.mediumPurpleAlpha058757F3,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: AppColors.mediumPurpleAlpha5B8757F3),
                borderRadius: BorderRadius.circular(10.r),
              ),
              shadows: [
                BoxShadow(
                  color: AppColors.blackAlpha05000000,
                  blurRadius: 20,
                  offset: Offset(0, 4),
                  spreadRadius: -10,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 113.h,
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: AppColors.todaysQuickPicContainerBGColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: job!.imageUrl.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            Get.to(
                              () => FullscreenImageView(
                                imageUrl: job!.imageUrl,
                                isNetworkImage: true,
                                isFileImage: false,
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              job!.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.business,
                                  size: 48.w,
                                  color: AppColors.mediumPurple8757F3,
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: AppColors.mediumPurple8757F3,
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : Icon(
                          Icons.business,
                          size: 48.w,
                          color: AppColors.mediumPurple8757F3,
                        ),
                ),
                SizedBox(height: 9.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            job!.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.appBarTitleColor,
                              fontSize: 18.sp,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w600,
                              height: 1.30,
                              letterSpacing: -0.18,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5.w,
                              height: 5.h,
                              decoration: const ShapeDecoration(
                                color: AppColors.checkBoxActiveColor,
                                shape: OvalBorder(),
                              ),
                            ),

                            SizedBox(width: 6.w),

                            Text(
                              job!.status,
                              style: TextStyle(
                                color: AppColors.checkBoxActiveColor,
                                fontSize: 10.sp,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w600,
                                height: 1.6,
                                letterSpacing: 0.20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 16.w,
                      runSpacing: 8.h,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15.w,
                            vertical: 3.h,
                          ),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 0.80,
                                color: Colors.black.withValues(alpha: 0.12),
                              ),
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                          ),
                          child: Text(
                            job!.level,
                            style: TextStyle(
                              color: AppColors.appBarTitleColor,
                              fontSize: 14.sp,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w500,
                              height: 1.60,
                              letterSpacing: -0.14,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 4.h,
                          ),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 0.80,
                                color: Colors.black.withValues(alpha: 0.12),
                              ),
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                          ),
                          child: Text(
                            job!.experience,
                            style: TextStyle(
                              color: AppColors.appBarTitleColor,
                              fontSize: 14.sp,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w500,
                              height: 1.60,
                              letterSpacing: -0.14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Deadline: ${job!.deadline}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.darkGray94969D,
                              fontSize: 14.sp,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w400,
                              height: 1.60,
                              letterSpacing: -0.14,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Job Post: ${job!.postDate}',
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.darkGray94969D,
                              fontSize: 14.sp,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w400,
                              height: 1.60,
                              letterSpacing: -0.14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
