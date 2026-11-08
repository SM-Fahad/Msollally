import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/custom_text_field_nodmac.dart';
import 'package:msollaally/feature/student/widgets/custom_drop_down.dart';
import 'package:msollaally/feature/teacher/auth/signup/controller/teacher_sign_up_controller.dart';
import 'package:msollaally/feature/teacher/auth/signup/screen/basic_information/controller/teacher_basic_info_controller.dart';
import 'package:msollaally/feature/teacher/widgets/show_error.dart';
import 'package:msollaally/routes/app_route.dart';

class TeacherAcademicProfessionalInfo extends StatelessWidget {
  TeacherAcademicProfessionalInfo({super.key});

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

                TeacherAcademicProfessionalInfoWidget(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TeacherAcademicProfessionalInfoWidget extends StatelessWidget {
  TeacherAcademicProfessionalInfoWidget({super.key, required this.controller});

  final TeacherBasicInfoController controller;
  final TeacherSignupController signupController = Get.put(
    TeacherSignupController(),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Academic & Professional Info",
          style: TextStyle(
            color: AppColors.black1F1F1F.withValues(alpha: 0.5),
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            letterSpacing: -.05.sp,
          ),
        ),

        SizedBox(height: 9.h),
        Column(
          children: [
            Obx(
              () => CustomDropdown(
                lebelName: 'University / Institution Name',
                items: controller.universityNameOption,
                value: controller.selectuniversity.value,
                hint: 'Dwiky Setiawan',
                onChanged: (value) {
                  controller.selectuniversity.value = value;
                },
              ),
            ),

            SizedBox(height: 9.h),

            Obx(
              () => CustomDropdown(
                lebelName: 'Department/Faculty',
                items: controller.facultyOption,
                value: controller.selectFaculty.value,
                hint: 'Ex. CSE',
                onChanged: (value) {
                  controller.selectFaculty.value = value;
                },
              ),
            ),

            SizedBox(height: 9.h),
            CustomTextFieldNodMac(
              controller: controller.designationController,
              lebelName: 'Designation',
              hinText: 'EX Professor',
            ),
            SizedBox(height: 9.h),
            CustomTextFieldNodMac(
              controller: controller.subjectTaughtController,
              lebelName: ' Subjects Taught',
              hinText: '16434',
            ),

            SizedBox(height: 39.h),
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: CustomButton(
                text: "Next",
                onPressed: () {
                  //validation(controller, signupController);
                  Get.toNamed(AppRoute.teacherUploadPhotoScreen);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void validation(
  TeacherBasicInfoController controller,
  TeacherSignupController signupController,
) async {
  if (controller.selectuniversity.value == null ||
      controller.selectuniversity.value!.isEmpty) {
    showError('Please select institution');
  } else if (controller.selectFaculty.value == null ||
      controller.selectFaculty.value!.isEmpty) {
    showError('Please select department');
  } else if (controller.designationController.text.isEmpty) {
    showError('Enter designation');
  } else if (controller.subjectTaughtController.text.isEmpty) {
    showError('Enter subject');
  } else {
    signupController.university = controller.selectuniversity.value!;
    signupController.faculty = controller.selectFaculty.value!;
    signupController.designation = controller.designationController.text;
    signupController.subjectTaught = controller.subjectTaughtController.text;
  }
}
