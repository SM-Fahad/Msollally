import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/standard_text_field.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import '../../../../../../auth/auth_controller/auth_controller.dart';

class TeacherCreatePasswordScreen extends StatelessWidget {
  TeacherCreatePasswordScreen({super.key});

  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 12, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 96),
                      Text(
                        "Create Password",
                        style: getTextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0, top: 20.0),
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
                          controller: controller.passwordController,
                          obscureText: controller.isPasswordHidden.value,
                          onChanged: (value) =>
                              controller.passwordStrength.value = value,
                          decoration: standardInputDecoration(
                            hintText: "Enter your password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordHidden.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () =>
                                  controller.isPasswordHidden.value =
                                      !controller.isPasswordHidden.value,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Obx(() {
                        String strength = controller.getPasswordStrength(
                          controller.passwordStrength.value,
                        );
                        int level = controller.getStrengthLevel(
                          controller.passwordStrength.value,
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
                                  margin: EdgeInsets.symmetric(horizontal: 2),
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
                      SizedBox(height: 8),
                      Obx(
                        () => TextField(
                          controller: controller.confirmPasswordController,
                          obscureText: controller.isConfirmPasswordHidden.value,
                          decoration: standardInputDecoration(
                            hintText: "Re-enter your password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isConfirmPasswordHidden.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () =>
                                  controller.isConfirmPasswordHidden.value =
                                      !controller.isConfirmPasswordHidden.value,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Obx(
                        () => CustomButton(
                          text: controller.isLoading.value
                              ? "Setting Password..."
                              : "Finish",
                          onPressed: () {
                            if (!controller.isLoading.value) {
                              controller.setPasswordForTeacher(
                                password: controller.passwordController.text,
                                confirmPassword:
                                    controller.confirmPasswordController.text,
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildSignInRow(),
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

  Widget _buildSignInRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Already have an account? "),
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
    );
  }
}
