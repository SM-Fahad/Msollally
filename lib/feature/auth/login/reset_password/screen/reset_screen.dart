import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:msollaally/core/common/styles/global_text_style.dart';
import 'package:msollaally/core/common/widgets/custom_button.dart';
import 'package:msollaally/feature/auth/login/reset_password/controller/reset_password_controller.dart';

import '../../../../../core/const/icons_path.dart';
import 'package:msollaally/core/const/appcolors.dart';
import '../../../../../routes/app_route.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResetPasswordController());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: Padding(
                  padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 6.h),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        IconsPath.nodmacIconNext,
                        height: 40.h,
                        width: 47.63.w,
                      ),
                      Text(
                        "LinkYetu",
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 16.sp * 0.03,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 72.h),
              Text(
                "Reset Password",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2.sp,
                  color: AppColors.black18181B,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Phone",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  letterSpacing: .02.sp,
                ),
              ),
              SizedBox(height: 8.h),
              IntlPhoneField(
                initialCountryCode: 'BD',
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
                onChanged: (phone) {
                  controller.onPhoneChanged(phone.completeNumber);
                },
              ),
              SizedBox(height: 24.h),
              Obx(
                () => CustomButton(
                  text: controller.isLoading.value ? "Sending..." : "Get Code",
                  onPressed: () {
                    if (controller.isLoading.value) return;
                    controller.sendOtp();
                  },
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: getTextStyle(
                      color: AppColors.appBarTitleColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.5.h,
                      letterSpacing: 0.20,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.toNamed(AppRoute.signUpScreen);
                    },
                    child: Text(
                      " Sign Up",
                      style: TextStyle(
                        color: AppColors.primaryButtonColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.5.h,
                        letterSpacing: 0.20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
