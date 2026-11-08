import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/feature/teacher/auth/signup/controller/teacher_sign_up_controller.dart';

class TeacherBioNodMac extends StatelessWidget {
  TeacherBioNodMac({super.key});

  final TeacherSignupController signupController = Get.put(
    TeacherSignupController(),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bio",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.black18181B,

              letterSpacing: 0.2.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Stack(
            children: [
              SizedBox(
                child: TextField(
                  controller: signupController.bioController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Enter your bio",
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.appBarTitleColor.withValues(alpha: 0.3),

                      letterSpacing: 0.2.sp,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.darkGray9DA4AE,
                        width: 1.w,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 12.h,
                right: 12.w,
                child: Row(
                  children: [
                    Text(
                      "13,",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.appBarTitleColor.withValues(alpha: 0.3),

                        letterSpacing: 0.2.sp,
                      ),
                    ),
                    Text(
                      "/",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.appBarTitleColor.withValues(alpha: 0.3),

                        letterSpacing: 0.2.sp,
                      ),
                    ),
                    Text(
                      "300",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.appBarTitleColor.withValues(alpha: 0.3),

                        letterSpacing: 0.2.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
