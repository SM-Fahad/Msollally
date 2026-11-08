import 'package:flutter/material.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/auth/signup/account_opening/controller/sign_up_screen_onboarding_controller.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/custom_logo_text_button.dart';
import 'package:msollaally/feature/chooseProfile/screen/choose_profile_screen.dart';
import 'package:msollaally/routes/app_route.dart';
import 'package:msollaally/feature/auth/signup/account_opening/widgets/onboarding_carousel.dart';

class SignUpScreenOnboarding extends StatelessWidget {
  const SignUpScreenOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SignUpScreenOnboardingController(),
      permanent: true,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 77.h),
                OnboardingCarousel(controller: controller),
                SizedBox(height: 60.h),
                _buildActionButtons(),
                SizedBox(height: 16.h),
                _buildResetPasswordLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: "Sign Up",
          onPressed: () => Get.to(const ChooseProfileScreen()),
        ),
        SizedBox(height: 16.h),
        CustomLogoWithTextButton(
          text: "Login",
          onPressed: () => Get.toNamed(AppRoute.loginScreen),
          color: AppColors.ghostWhiteF9FAFB,
          textColor: AppColors.black18181B,
        ),
      ],
    );
  }

  Widget _buildResetPasswordLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Forgot Password?",
          style: getTextStyle(
            color: AppColors.appBarTitleColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.5,
            letterSpacing: 0.20,
          ),
        ),
        InkWell(
          onTap: () => Get.toNamed(AppRoute.resetpassword),
          child: Text(
            " Forgot Password",
            style: getTextStyle(
              color: AppColors.primaryButtonColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
              letterSpacing: 0.20,
            ),
          ),
        ),
      ],
    );
  }
}
