import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/student/widgets/custom_drop_down.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/custom_text_field_nodmac.dart';
import 'package:msollaally/feature/teacher/auth/signup/controller/teacher_sign_up_controller.dart';
import 'package:msollaally/feature/teacher/auth/signup/screen/basic_information/controller/teacher_basic_info_controller.dart';

class TeacherBasicInfoScreen extends StatelessWidget {
  TeacherBasicInfoScreen({super.key});
  final TeacherBasicInfoController controller = Get.put(
    TeacherBasicInfoController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 6.w, right: 6.w),

                  child: Row(
                    children: [
                      SizedBox(height: 26.h),
                      Image.asset(IconsPath.appLogoPng),
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

                SizedBox(height: 20.h),

                Row(
                  children: [
                    Container(
                      height: 6.h,
                      width: 90.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: AppColors.primaryButtonColor,
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
                        color: AppColors.sliderColorInboarding,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 19.h),
                SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Help us personalize your experience",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.22.sp,
                        ),
                      ),
                      Text(
                        "To start your profile, share where you are",
                        style: TextStyle(
                          color: AppColors.appBarTitleColor.withValues(alpha: 0.7),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.0.sp,
                        ),
                      ),
                      Text(
                        "on your journey.",
                        style: TextStyle(
                          color: AppColors.appBarTitleColor.withValues(alpha: 0.7),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.0.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                TeacherBasicInfoWidget(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TeacherBasicInfoWidget extends StatelessWidget {
  TeacherBasicInfoWidget({super.key, required this.controller});

  final TeacherBasicInfoController controller;

  final TeacherSignupController teacherSignupController = Get.put(
    TeacherSignupController(),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 27.h),
        Text(
          "Basic Information",
          style: getTextStyle(
            color: AppColors.black1F1F1F.withValues(alpha: 0.5),
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 9.h),
        Form(
          key: controller.formKey,
          child: Column(
            children: [
              CustomTextFieldNodMac(
                controller: controller.fullNameController,
                lebelName: 'Full Name',
                hinText: 'Dwiky Setiawan',
              ),
              SizedBox(height: 9.h),
              CustomTextFieldNodMac(
                controller: controller.emailController,
                lebelName: 'Email',
                hinText: 'cheers@design.com',
              ),
              SizedBox(height: 9.h),
              Obx(
                () => CustomDropdown(
                  lebelName: "Gender",

                  onChanged: (value) {
                    if (value != null) {
                      controller.gender.value = value;
                    }
                  },
                  value: controller.gender.value,
                  items: ['Male', 'Female'],
                  hint: "Select Gender",
                ),
              ),

              SizedBox(height: 29.h),

              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: CustomButton(
                  text: "Next",
                  onPressed: () {
                    controller.saveProfileData();
                    debugPrint(
                      'All signUp info: ${teacherSignupController.getAllSignUpInfo()}',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
