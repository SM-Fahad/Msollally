// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/auth/login/login_page/screen/loginScreen.dart';
import 'package:msollaally/feature/auth/auth_controller/auth_controller.dart';
import 'package:msollaally/core/common/widgets/standard_text_field.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/custom_text_field_nodmac.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final AuthController authController = Get.put(AuthController());

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
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    Obx(() {
                      final roleString =
                          UserRoleService.controller.selectedRoleString;
                      final title = _getSignUpTitle(roleString);
                      return Text(
                        title,
                        style: getTextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                    SizedBox(height: 8),
                    _buildRoleBadge(),
                    SizedBox(height: 20),
                    CustomTextFieldNodMac(
                      controller: authController.nameController,
                      lebelName: 'User Name',
                      hinText: 'LinkYetu',
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        "Phone",
                        style: getTextStyle(fontSize: 14, letterSpacing: .07),
                      ),
                    ),
                    IntlPhoneField(
                      decoration: standardInputDecoration(
                        hintText: 'Phone number',
                        borderRadius: 12.0,
                      ),
                      initialCountryCode: 'US',
                      onChanged: (phone) {
                        authController.setPhoneNumber(phone.completeNumber);
                      },
                    ),

                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Password",
                        style: getTextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Obx(
                      () => TextField(
                        controller: authController.passwordController,
                        obscureText: authController.isPasswordHidden.value,
                        onChanged: (value) {
                          authController.passwordStrength.value = value;
                        },
                        decoration: standardInputDecoration(
                          hintText: "Enter your password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              authController.isPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              authController.isPasswordHidden.value =
                                  !authController.isPasswordHidden.value;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      String strength = authController.getPasswordStrength(
                        authController.passwordStrength.value,
                      );
                      int level = authController.getStrengthLevel(
                        authController.passwordStrength.value,
                      );
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            strength,
                            style: getTextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: strength.isEmpty
                                  ? Colors.grey
                                  : strength == "Very Weak"
                                  ? Colors.red
                                  : strength == "Weak"
                                  ? Colors.orange
                                  : strength == "Medium"
                                  ? Colors.blue
                                  : Colors.green,
                            ),
                          ),
                          Row(
                            children: List.generate(3, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                height: 4,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: index < level
                                      ? (strength == "Very Weak"
                                            ? Colors.red
                                            : strength == "Weak"
                                            ? Colors.orange
                                            : strength == "Medium"
                                            ? Colors.blue
                                            : Colors.green)
                                      : Colors.grey.shade300,
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Confirm Password",
                        style: getTextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Obx(
                      () => TextField(
                        controller: authController.confirmPasswordController,
                        obscureText:
                            authController.isConfirmPasswordHidden.value,
                        decoration: standardInputDecoration(
                          hintText: "Re-enter your password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              authController.isConfirmPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              authController.isConfirmPasswordHidden.value =
                                  !authController.isConfirmPasswordHidden.value;
                            },
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Obx(
                              () => CustomButton(
                                text: authController.isLoading.value
                                    ? "Please wait..."
                                    : "Sign up",
                                onPressed: authController.isLoading.value
                                    ? () {}
                                    : () => authController.signUp(),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Already have an account? "),
                                GestureDetector(
                                  onTap: () {
                                    Get.to(LoginScreen());
                                  },
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
                    SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge() {
    final roleDisplayName = UserRoleService.controller.selectedRoleString;
    if (roleDisplayName == null) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryButtonColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryButtonColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 16, color: AppColors.primaryButtonColor),
          SizedBox(width: 6),
          Text(
            roleDisplayName,
            style: getTextStyle(
              color: AppColors.primaryButtonColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getSignUpTitle(String? roleString) {
    switch (roleString) {
      case 'Teacher':
        return 'Sign Up As a Faculty';
      case 'Recruiter':
        return 'Sign Up As a Recruiter';
      case 'Pro Partners':
        return 'Sign Up As a Pro Partner';
      case 'Student':
      default:
        return 'Sign Up As a Student';
    }
  }
}
