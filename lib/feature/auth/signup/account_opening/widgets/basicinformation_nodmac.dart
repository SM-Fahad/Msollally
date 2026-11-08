import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/feature/auth/signup/account_opening/screens/academic_info.dart';
import 'package:msollaally/feature/student/widgets/custom_drop_down.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/custom_text_field_nodmac.dart';
import '../controller/sign_up_screen_onboarding_controller.dart';

class BasicInformation extends StatelessWidget {
  const BasicInformation({super.key});

  @override
  Widget build(BuildContext context) {
    SignUpScreenOnboardingController nodemacController = Get.put(
      SignUpScreenOnboardingController(),
      permanent: true,
    );

    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 27.h),
          Text(
            "Basic Information",
            style: getTextStyle(
              color: AppColors.black1F1F1F.withValues(alpha: 0.5),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: -.05,
            ),
          ),
          SizedBox(height: 9.h),
          Form(
            key: nodemacController.formKeyBasic,
            child: Column(
              children: [
                CustomTextFieldNodMac(
                  controller: nodemacController.nameController,
                  lebelName: 'Full Name',
                  hinText: 'Enter your full name',
                ),
                SizedBox(height: 9.h),

                if (UserRoleService.isRecruiter ||
                    UserRoleService.isProPartners)
                  CustomTextFieldNodMac(
                    controller: nodemacController.companyNameController,
                    lebelName: 'Company Name',
                    hinText: 'Enter your company name',
                  ),
                UserRoleService.isRecruiter || UserRoleService.isProPartners
                    ? SizedBox(height: 9.h)
                    : SizedBox.shrink(),

                CustomTextFieldNodMac(
                  controller: nodemacController.emailController,
                  lebelName: 'Email',
                  hinText: 'email@example.com',
                ),
                SizedBox(height: 9.h),

                Obx(
                  () => CustomDropdown(
                    lebelName: "Gender",

                    onChanged: (value) {
                      nodemacController.selectedGender.value = value;
                      nodemacController.genderController.text = value ?? " ";
                    },
                    value: nodemacController.selectedGender.value,
                    items: nodemacController.genderOptions,
                    hint: "Select Gender",
                  ),
                ),

                SizedBox(height: 9.h),

                Obx(() {
                  // Show DOB only for students. Hide for faculty/others.
                  if (!UserRoleService.isStudent) {
                    return SizedBox.shrink();
                  }

                  nodemacController.dateOfBirthController.text =
                      nodemacController.formattedDateTime;

                  return CustomTextFieldNodMac(
                    controller: nodemacController.dateOfBirthController,
                    lebelName: 'Date of Birth',
                    hinText: 'yyyy-MM-dd',
                    suffixIcon: InkWell(
                      onTap: () async {
                        await nodemacController.pickDateTime(context);
                      },
                      child: Icon(Icons.calendar_month, color: Colors.black),
                    ),
                  );
                }),

                SizedBox(height: 129.h),
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: CustomButton(
                    text: "Next",
                    onPressed: () async {
                      final name = nodemacController.nameController.text.trim();
                      final email = nodemacController.emailController.text
                          .trim();

                      if (name.isEmpty) {
                        EasyLoading.showError('Full name is required');
                        return;
                      }

                      if (email.isEmpty) {
                        EasyLoading.showError('Email is required');
                        return;
                      }

                      if (!GetUtils.isEmail(email)) {
                        EasyLoading.showError('Please enter a valid email');
                        return;
                      }

                      Get.to(AcademicInfoScreen());
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
