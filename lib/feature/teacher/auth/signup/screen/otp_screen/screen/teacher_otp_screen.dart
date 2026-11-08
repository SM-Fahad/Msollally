// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/feature/auth/auth_controller/auth_controller.dart';

class TeacherOtpScreen extends StatelessWidget {
  TeacherOtpScreen({super.key});
  final AuthController otpController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back button aligned to left with padding
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
            SizedBox(height: 20),

            /// Grey line below back button (full width)
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey.shade300,
            ),
            // Rest of the content with padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    /// Title
                    Text(
                      "Send OTP Code",
                      style: getTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    /// Subtitle
                    Text(
                      "Enter the 6-digit that we have sent via the email to +123456789",
                      style: getTextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 26),

                    /// OTP Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 50,
                          height: 50,
                          child: TextField(
                            controller: otpController.otpControllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            decoration: const InputDecoration(
                              counterText: "",
                              filled: true,
                              fillColor: AppColors.ghostWhiteF9FAFB,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                FocusScope.of(context).nextFocus();
                              } else if (value.isEmpty && index > 0) {
                                /// FIX: go back and also clear previous
                                otpController.otpControllers[index - 1].clear();
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 30),

                    /// Countdown + Resend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.timer, size: 18, color: Colors.blueAccent),
                        SizedBox(width: 5),
                        Obx(
                          () => Text(
                            otpController.timerDisplay,
                            style: getTextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 90),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          otpController.resendOtpForTeacher();
                        },
                        child: Text(
                          "Resend Code",
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    /// Remove button
                    Obx(
                      () => CustomButton(
                        text: otpController.isLoading.value
                            ? "Verifying..."
                            : "Continue",
                        color: Colors.blue,
                        onPressed: otpController.isLoading.value
                            ? () {}
                            : () {
                                otpController.verifyOtpForTeacher();
                              },
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Terms
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "By signing up or logging in, i accept the apps Terms of Service and Privacy Policy",
                        textAlign: TextAlign.center,
                        style: getTextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
