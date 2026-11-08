import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/teacher/auth/signup/widget/bio_field_widget.dart';
import 'package:msollaally/feature/teacher/auth/signup/widget/teacher_upload_photo.dart';
import 'package:msollaally/routes/app_route.dart';

class TeacherUploadPhotoScreen extends StatelessWidget {
  const TeacherUploadPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 26.h),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // SizedBox(height: 26.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            IconsPath.nodmacIconNext,
                            height: 40.h,
                            width: 47.63.w,
                          ),
                          Text(
                            "LinkYetu",
                            style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 16.sp * 0.03,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Get.toNamed(AppRoute.teacherHomeScreen);
                      },
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.18.sp,
                          color: AppColors.appBarTitleColor,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 6.h,
                      width: 90.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: AppColors.sliderColorInboarding,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      height: 6.h,
                      width: 90.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: AppColors.sliderColorInboarding,
                      ),
                    ),
                    SizedBox(width: 12.w),

                    Container(
                      height: 6.h,
                      width: 90.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: AppColors.primaryButtonColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 17.h),
                TeacherUploadYourPhoto(),
                SizedBox(height: 24.h),
                TeacherBioNodMac(),
                SizedBox(height: 60.h),
                CustomButton(
                  text: "Finish",
                  onPressed: () {
                    if (kDebugMode) {
                      debugPrint("");
                    }
                    Get.toNamed(AppRoute.teacherHomeScreen);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
