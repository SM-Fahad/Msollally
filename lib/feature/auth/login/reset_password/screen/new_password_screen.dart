// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/common/widgets/standard_text_field.dart';
import 'package:msollaally/core/services/user_role_service.dart';
import 'package:msollaally/feature/auth/auth_controller/auth_controller.dart';
import 'package:msollaally/feature/auth/login/reset_password/service/reset_password_service.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:msollaally/feature/recruiter/more/service/recruiter_account_service.dart';
import 'package:msollaally/routes/app_route.dart';

class NewPasswordScreen extends StatelessWidget {
  NewPasswordScreen({super.key});

  final AuthController authController = Get.put(AuthController());
  final SharedPreferenceHelper _prefHelper = SharedPreferenceHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 96),

                      Text(
                        "Set New Password",
                        style: getTextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 20.0),
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 20.0),
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
                                    !authController
                                        .isConfirmPasswordHidden
                                        .value;
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      Obx(() {
                        final loading = authController.isLoading.value;
                        return CustomButton(
                          text: loading ? "Please wait..." : "Finish",
                          onPressed: loading
                              ? () {}
                              : () async {
                                  final password = authController
                                      .passwordController
                                      .text
                                      .trim();
                                  final confirm = authController
                                      .confirmPasswordController
                                      .text
                                      .trim();

                                  if (password.isEmpty || confirm.isEmpty) {
                                    EasyLoading.showError(
                                      'Please enter and confirm your password',
                                    );
                                    return;
                                  }
                                  if (password.length < 6) {
                                    EasyLoading.showError(
                                      'Password must be at least 6 characters',
                                    );
                                    return;
                                  }
                                  if (password != confirm) {
                                    EasyLoading.showError(
                                      'Passwords do not match',
                                    );
                                    return;
                                  }

                                  String? phone = await _prefHelper
                                      .getSavedPhoneNumber();
                                  if (phone == null || phone.isEmpty) {
                                    EasyLoading.showError(
                                      'Phone number not found. Please retry the reset flow.',
                                    );
                                    return;
                                  }

                                  try {
                                    EasyLoading.show(
                                      status: 'Setting password...',
                                    );
                                    final res =
                                        await ResetPasswordService.resetPassword(
                                          phoneNumber: phone,
                                          password: password,
                                        );
                                    EasyLoading.dismiss();
                                    EasyLoading.showSuccess(
                                      res['message'] ??
                                          'New password successfully created',
                                    );
                                    await Future.delayed(
                                      const Duration(seconds: 1),
                                    );
                                    //  Get.offAllNamed(AppRoute.loginScreen);
                                    clearallthings();
                                  } catch (e) {
                                    EasyLoading.dismiss();
                                    EasyLoading.showError(
                                      e.toString().replaceAll(
                                        'Exception: ',
                                        '',
                                      ),
                                    );
                                  }
                                },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> clearallthings() async {
    final accountService = RecruiterAccountService();
    try {
      final accessToken = await _prefHelper.getAccessToken();
      final refreshToken = await _prefHelper.getRefreshToken();
      if (accessToken != null &&
          accessToken.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty) {
        await accountService.logout(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
    } catch (e) {
      debugPrint('Logout failed, but proceeding to clear session: $e');
    }

    await _prefHelper.clearAuthSession();
    UserRoleService.clearSelectedRole();
    Get.offAllNamed(AppRoute.loginScreen);
  }
}
