import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/auth/signup/account_opening/screens/upload_photo.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/custom_text_field_nodmac.dart';
import 'package:msollaally/feature/student/widgets/custom_drop_down.dart';

import '../controller/sign_up_screen_onboarding_controller.dart';

class AcademicInformation extends StatelessWidget {
  const AcademicInformation({super.key, required this.nodeMacController});

  final SignUpScreenOnboardingController nodeMacController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Academic Information",
            style: getTextStyle(
              color: AppColors.black1F1F1F.withValues(alpha: 0.5),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: -.05,
            ),
          ),

          SizedBox(height: 9.h),
          Form(
            key: nodeMacController.formKeyAcademic,
            child: Column(
              children: [
                Obx(() {
                  final current = nodeMacController.selectuniversity.value;
                  final value =
                      nodeMacController.universityNameOption.contains(current)
                      ? current
                      : null;
                  return UserRoleService.isRecruiter ||
                          UserRoleService.isProPartners
                      ? SizedBox.shrink()
                      : CustomDropdown(
                          lebelName: 'University / Institution Name',
                          items: nodeMacController.universityNameOption,
                          value: value,
                          hint: 'Select University',
                          onChanged: (value) {
                            nodeMacController.selectUniversityByName(value);
                          },
                        );
                }),

                SizedBox(height: 9.h),

                Obx(() {
                  if (UserRoleService.isTeacher ||
                      UserRoleService.isRecruiter ||
                      UserRoleService.isProPartners) {
                    return SizedBox.shrink();
                  }

                  final current = nodeMacController.selectProgram.value;
                  final value =
                      nodeMacController.programOption.contains(current)
                      ? current
                      : null;
                  return CustomDropdown(
                    lebelName: 'Program',
                    items: nodeMacController.programOption,
                    value: value,
                    hint: 'Select Program',
                    onChanged: (value) {
                      nodeMacController.selectProgramByName(value);
                    },
                  );
                }),

                // SizedBox(height: 9.h),
                Obx(() {
                  if (UserRoleService.isTeacher ||
                      UserRoleService.isRecruiter ||
                      UserRoleService.isProPartners) {
                    return SizedBox.shrink();
                  }
                  final current = nodeMacController.selectFaculty.value;
                  final value =
                      nodeMacController.facultyOption.contains(current)
                      ? current
                      : null;
                  return CustomDropdown(
                    lebelName: 'Faculty',
                    items: nodeMacController.facultyOption,
                    value: value,
                    hint: 'Select Faculty',
                    onChanged: (value) {
                      nodeMacController.selectDepartmentByName(value);
                    },
                  );
                }),

                //  SizedBox(height: 9.h),
                if (UserRoleService.isTeacher)
                  CustomTextFieldNodMac(
                    controller: nodeMacController.facultyController,
                    lebelName: 'Department',
                    hinText: 'Enter your department',
                  ),
                //    SizedBox(height: 9.h),
                if (UserRoleService.isTeacher ||
                    UserRoleService.isRecruiter ||
                    UserRoleService.isProPartners)
                  CustomTextFieldNodMac(
                    controller: nodeMacController.designationTeacherController,
                    lebelName: 'Designation',
                    hinText: 'Enter your designation',
                  ),

                //      SizedBox(height: 9.h),
                UserRoleService.isRecruiter || UserRoleService.isProPartners
                    ? CustomTextFieldNodMac(
                        controller:
                            nodeMacController.recruiterIndustryController,
                        lebelName: 'Industry Type',
                        hinText: 'Enter your industry type',
                      )
                    : SizedBox.shrink(),

                UserRoleService.isRecruiter || UserRoleService.isProPartners
                    ? CustomTextFieldNodMac(
                        controller:
                            nodeMacController.recruiterLocationController,
                        lebelName: 'Add location',
                        hinText: 'Enter your Location',
                      )
                    : SizedBox.shrink(),

                if (UserRoleService.isTeacher)
                  CustomTextFieldNodMac(
                    controller:
                        nodeMacController.subjectsTaughtTeacherController,
                    lebelName: 'Subjects Taught',
                    hinText: 'Enter your subjects taught',
                  ),
                SizedBox(height: 9.h),

                if (UserRoleService.isStudent)
                  CustomTextFieldNodMac(
                    controller: nodeMacController.studentIDController,
                    lebelName: 'Student ID',
                    hinText: 'Enter your student ID',
                  ),
                SizedBox(height: 9.h),
                if (UserRoleService.isStudent)
                  CustomTextFieldNodMac(
                    controller: nodeMacController.enrollmentYearController,
                    lebelName: 'Enrollment Year',
                    hinText: 'Enter your enrollment year',
                  ),

                SizedBox(height: 39.h),
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: CustomButton(
                    text: "Next",
                    onPressed: () {
                      Get.to(UploadPhotoScreen());
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
