import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/auth/signup/account_opening/controller/sign_up_screen_onboarding_controller.dart';

class OnboardingCarousel extends StatelessWidget {
  const OnboardingCarousel({super.key, required this.controller});

  final SignUpScreenOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnimatedImage(),
        SizedBox(height: 12.h),
        _buildIndicators(),
        SizedBox(height: 24.h),
        _buildAnimatedText(),
      ],
    );
  }

  Widget _buildAnimatedImage() {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: Image.asset(
          controller.onboardingImages[controller.currentImageIndex.value],
          height: 273.78.h,
          width: 343.01.w,
          key: ValueKey<int>(controller.currentImageIndex.value),
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Obx(
      () => Row(
        children: List.generate(
          controller.onboardingImages.length,
          (index) => Container(
            height: 4.h,
            width: 42.34.w,
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(90),
              color: index == controller.currentImageIndex.value
                  ? AppColors.primaryButtonColor
                  : AppColors.sliderColorInboarding,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText() {
    return Obx(
      () => Row(
        children: List.generate(
          controller.onboardingImages.length,
          (index) => index == controller.currentImageIndex.value
              ? Expanded(
                  child: Text(
                    controller.onboardingText[index],
                    style: getTextStyle(
                      color: AppColors.appBarTitleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
