// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/custom_text_field_nodmac.dart';
import 'package:msollaally/feature/teacher/auth/signup/controller/teacher_sign_up_controller.dart';

class TeacherSignUpScreen extends StatelessWidget {
  TeacherSignUpScreen({super.key});
  final TeacherSignupController controller = Get.put(TeacherSignupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 30, top: 70),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                "assets/icons/logo_name.png",
                height: 150,
                width: 200,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Vertically center
                  crossAxisAlignment: CrossAxisAlignment.start, // Align left
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      "Sign Up As a Faculty",
                      style: getTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    CustomTextFieldNodMac(
                      controller: controller.fullNameController,
                      lebelName: 'Full Name',
                      hinText: 'Dwiky Setiawan',
                    ),
                    const SizedBox(height: 20),

                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        "Phone",
                        style: getTextStyle(fontSize: 14.sp),
                      ),
                    ),
                    IntlPhoneField(
                      controller: controller.phoneController,
                      onChanged: (phone) {
                        controller.setPhoneNumber(phone.completeNumber);
                      },
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryButtonColor),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.darkGray9DA4AE),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 30),

                    // Buttons in center
                    Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Obx(
                              () => CustomButton(
                                text: controller.isLoading.value
                                    ? "Signing up..."
                                    : "Sign up",
                                onPressed: controller.isLoading.value
                                    ? () {}
                                    : () {
                                        controller.signUp();
                                      },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have an account? "),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    "Sign In",
                                    style: getTextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20), // Add some bottom padding
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
