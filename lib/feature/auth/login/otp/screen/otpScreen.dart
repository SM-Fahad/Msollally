// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/feature/auth/auth_controller/auth_controller.dart';

class OtpScreen extends StatelessWidget {
  OtpScreen({super.key});

  final AuthController otpController = Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    if (!otpController.hasStartedOtpTimer.value) otpController.startOtpTimer();
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    Text(
                      "Enter OTP Code",
                      style: getTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      "Enter the 6-digit code sent to your phone number",
                      style: getTextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 26),

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
                                otpController.otpControllers[index - 1].clear();
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      final expired = otpController.isTimerExpired.value;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 18,
                            color: expired ? Colors.red : Colors.blueAccent,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            expired
                                ? 'OTP Expired'
                                : otpController.timerDisplay,
                            style: getTextStyle(
                              color: expired ? Colors.red : Colors.black54,
                              fontWeight: expired
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 30),
                    Center(
                      child: Obx(() {
                        final expired = otpController.isTimerExpired.value;
                        final loading = otpController.isLoading.value;

                        return GestureDetector(
                          onTap: expired && !loading
                              ? () => otpController.resendOtp()
                              : null,
                          child: Text(
                            "Resend Code",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: expired ? Colors.blue : Colors.grey,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 30),

                    Obx(() {
                      final loading = otpController.isLoading.value;

                      return CustomButton(
                        text: loading ? "Verifying..." : "Continue",
                        color: Colors.blue,
                        onPressed: loading
                            ? () {}
                            : () => otpController.verifyOtp(),
                      );
                    }),

                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "By signing up or logging in, I accept the app's Terms of Service and Privacy Policy",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
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
